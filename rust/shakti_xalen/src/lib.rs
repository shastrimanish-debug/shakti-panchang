use xalen_ayanamsa::Ayanamsa;
use xalen_coords::obliquity::mean_obliquity;
use xalen_ephem::{Almanac, Body};
use xalen_houses::{compute_houses, GeoLocation, HouseSystem};
use xalen_time::{calendar_to_jd, CalendarSystem, DeltaTModel, JdUT1, JulianDay};

#[repr(C)]
pub struct XalenResult { pub sun_sidereal_deg: f64, pub moon_sidereal_deg: f64, pub ayanamsa_deg: f64, pub status: i32 }
#[repr(C)]
pub struct XalenPlanetResult {
    pub sidereal_deg: f64, pub tropical_deg: f64, pub latitude_deg: f64,
    pub speed_deg_day: f64, pub retrograde: i32, pub status: i32,
}
#[repr(C)]
pub struct XalenHousesResult {
    pub cusps: [f64; 12], pub ascendant_deg: f64, pub mc_deg: f64, pub status: i32,
}

fn norm(v: f64) -> f64 { v.rem_euclid(360.0) }
fn jd_for_local(year: i32, month: i32, day: i32, hour: i32, minute: i32, second: i32, tz: f64) -> Option<JdUT1> {
    if !(1..=12).contains(&month) || !(1..=31).contains(&day) || !(0..=23).contains(&hour) || !(0..=59).contains(&minute) || !(0..=60).contains(&second) || !tz.is_finite() { return None; }
    let local = hour as f64 + minute as f64 / 60.0 + second as f64 / 3600.0;
    Some(calendar_to_jd(year, month as u32, day as u32, local - tz, CalendarSystem::default()))
}
fn ayan(jd: JdUT1) -> f64 {
    let tt = jd.to_tt(&DeltaTModel::StephensonMorrisonHohenkerk2016);
    // Fixed ayanamsa calculation to match xalen-ayanamsa API
    Ayanamsa::Lahiri.compute_deg(tt.as_f64())
}
fn body_from_id(id: i32) -> Option<Body> { match id {
    0=>Some(Body::Sun),1=>Some(Body::Moon),2=>Some(Body::Mars),3=>Some(Body::Mercury),4=>Some(Body::Jupiter),5=>Some(Body::Venus),6=>Some(Body::Saturn),7=>Some(Body::MeanNode),8=>Some(Body::TrueNode),9=>Some(Body::Uranus),10=>Some(Body::Neptune),11=>Some(Body::Pluto),_=>None
} }

#[no_mangle]
pub extern "C" fn shakti_xalen_calculate(year:i32,month:i32,day:i32,hour:i32,minute:i32,second:i32,tz_hours:f64,out:*mut XalenResult)->i32 {
    if out.is_null() { return -1; }
    let Some(jd)=jd_for_local(year,month,day,hour,minute,second,tz_hours) else { return -2; };
    let a=Almanac::default_vedic(); let aya=ayan(jd);
    let sun=match a.geocentric_ecliptic(Body::Sun,jd){Ok(v)=>v,Err(_)=>return -3};
    let moon=match a.geocentric_ecliptic(Body::Moon,jd){Ok(v)=>v,Err(_)=>return -4};
    unsafe {*out=XalenResult{sun_sidereal_deg:norm(sun.longitude.to_degrees()-aya),moon_sidereal_deg:norm(moon.longitude.to_degrees()-aya),ayanamsa_deg:aya,status:0};}
    0
}

#[no_mangle]
pub extern "C" fn shakti_xalen_planet(year:i32,month:i32,day:i32,hour:i32,minute:i32,second:i32,tz_hours:f64,body_id:i32,out:*mut XalenPlanetResult)->i32 {
    if out.is_null(){return -1;}
    let Some(jd)=jd_for_local(year,month,day,hour,minute,second,tz_hours) else{return -2;};
    let Some(body)=body_from_id(body_id) else{return -3;};
    let a=Almanac::default_vedic();
    let pos=match a.geocentric_ecliptic(body,jd){Ok(v)=>v,Err(_)=>return -4};
    let sp=match a.geocentric_speed(body,jd){Ok(v)=>v,Err(_)=>return -5};
    let aya=ayan(jd);
    unsafe {*out=XalenPlanetResult{sidereal_deg:norm(pos.longitude.to_degrees()-aya),tropical_deg:norm(pos.longitude.to_degrees()),latitude_deg:pos.latitude.to_degrees(),speed_deg_day:sp.longitude_deg_per_day(),retrograde:i32::from(sp.longitude<0.0),status:0};}
    0
}

#[no_mangle]
pub extern "C" fn shakti_xalen_houses(year:i32,month:i32,day:i32,hour:i32,minute:i32,second:i32,tz_hours:f64,lat:f64,lon:f64,out:*mut XalenHousesResult)->i32 {
    if out.is_null(){return -1;}
    if !lat.is_finite()||!lon.is_finite()||lat.abs()>90.0||lon.abs()>180.0{return -2;}
    let Some(jd)=jd_for_local(year,month,day,hour,minute,second,tz_hours) else{return -3;};
    let t=(jd.as_f64()-2451545.0)/36525.0;
    let eps=mean_obliquity(t);
    let a=Almanac::default_vedic(); let aya=ayan(jd);
    let loc=GeoLocation::new(lat,lon);
    let h=compute_houses(jd.as_f64(),&loc,eps,HouseSystem::Placidus).to_sidereal(aya.to_radians());
    unsafe { for i in 0..12 {(*out).cusps[i]=h.cusp_deg(i);} (*out).ascendant_deg=h.ascendant.to_degrees().rem_euclid(360.0); (*out).mc_deg=h.mc.to_degrees().rem_euclid(360.0); (*out).status=0; }
    let _=a; 0
}

fn varga_sign(sidereal_deg: f64, division: i32) -> Option<i32> {
    if !sidereal_deg.is_finite() || !(1..=60).contains(&division) { return None; }
    let deg = sidereal_deg.rem_euclid(360.0);
    let sign = (deg / 30.0).floor() as i32;
    let within = deg.rem_euclid(30.0);
    let d = division as f64;
    let part = ((within / (30.0 / d)).floor() as i32).clamp(0, division - 1);

    let norm12 = |v: i32| v.rem_euclid(12);

    let out = match division {
        1 => sign,
        // Hora: odd signs -> Leo then Cancer; even signs -> Cancer then Leo.
        2 => if sign % 2 == 0 {
            if part == 0 { 4 } else { 3 }
        } else {
            if part == 0 { 3 } else { 4 }
        },
        // Drekkana: own, 5th, 9th.
        3 => norm12(sign + [0, 4, 8][part as usize]),
        // Chaturthamsha: own, 4th, 7th, 10th.
        4 => norm12(sign + [0, 3, 6, 9][part as usize]),
        // Saptamsha: odd sign starts from itself; even sign from 7th.
        7 => {
            let start = if sign % 2 == 0 { sign } else { norm12(sign + 6) };
            norm12(start + part)
        },
        // Navamsha: movable own, fixed 9th, dual 5th.
        9 => {
            let start = match sign % 3 {
                0 => sign,
                1 => norm12(sign + 8),
                _ => norm12(sign + 4),
            };
            norm12(start + part)
        },
        // Dashamsha: odd sign starts from itself; even from 9th.
        10 => {
            let start = if sign % 2 == 0 { sign } else { norm12(sign + 8) };
            norm12(start + part)
        },
        12 => norm12(sign + part),
        // Shodashamsha: movable Aries, fixed Leo, dual Sagittarius.
        16 => {
            let start = match sign % 3 {
                0 => 0,
                1 => 4,
                _ => 8,
            };
            norm12(start + part)
        },
        // Vimshamsha: fire -> Aries, earth -> Sagittarius, air -> Leo, water -> Cancer.
        20 => {
            let start = match sign % 4 {
                0 => 0,
                1 => 8,
                2 => 4,
                _ => 3,
            };
            norm12(start + part)
        },
        // Chaturvimshamsha: odd signs Leo, even signs Cancer.
        24 => {
            let start = if sign % 2 == 0 { 4 } else { 3 };
            norm12(start + part)
        },
        // Bhamsa: fire -> Aries, earth -> Cancer, air -> Libra, water -> Capricorn.
        27 => {
            let start = match sign % 4 {
                0 => 0,
                1 => 3,
                2 => 6,
                _ => 9,
            };
            norm12(start + part)
        },
        // Trimshamsha: classical odd/even unequal 30-degree scheme.
        30 => {
            if sign % 2 == 0 {
                if within < 5.0 { 5 }       // Mars
                else if within < 10.0 { 10 } // Saturn
                else if within < 18.0 { 8 }  // Jupiter
                else if within < 25.0 { 2 }  // Mercury
                else { 6 }                    // Venus
            } else {
                if within < 5.0 { 1 }       // Mars
                else if within < 10.0 { 7 }  // Saturn
                else if within < 18.0 { 9 } // Jupiter
                else if within < 25.0 { 3 } // Mercury
                else { 5 }                   // Venus
            }
        },
        // Khavedamsha: odd signs Leo, even signs Cancer (traditional Parashari convention).
        40 => {
            let start = if sign % 2 == 0 { 4 } else { 3 };
            norm12(start + part)
        },
        // Akshavedamsha: movable Aries, fixed Leo, dual Sagittarius.
        45 => {
            let start = match sign % 3 {
                0 => 0,
                1 => 4,
                _ => 8,
            };
            norm12(start + part)
        },
        // Shashtiamsha: sequential from sign.
        60 => norm12(sign + part),
        _ => return None,
    };
    Some(out)
}

#[no_mangle]
pub extern "C" fn shakti_xalen_varga_sign(sidereal_deg: f64, division: i32, out: *mut i32) -> i32 {
    if out.is_null() { return -1; }
    let Some(v) = varga_sign(sidereal_deg, division) else { return -2; };
    unsafe { *out = v; }
    0
}
