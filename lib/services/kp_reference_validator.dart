import 'dart:convert';
import 'dart:io';

class KpReferenceTolerance {
  const KpReferenceTolerance({
    this.longitudeArcSeconds = 2.0,
    this.cuspArcSeconds = 5.0,
  });
  final double longitudeArcSeconds;
  final double cuspArcSeconds;
}

class KpReferenceMismatch {
  const KpReferenceMismatch({
    required this.kind,
    required this.name,
    required this.expected,
    required this.actual,
    required this.deltaArcSeconds,
  });
  final String kind;
  final String name;
  final double expected;
  final double actual;
  final double deltaArcSeconds;
}

class KpReferenceValidationReport {
  const KpReferenceValidationReport(this.passed, this.checked, this.mismatches);
  final bool passed;
  final int checked;
  final List<KpReferenceMismatch> mismatches;
  Map<String,dynamic> toJson()=> {
    'passed': passed,
    'checked': checked,
    'mismatches': mismatches.map((m)=> {
      'kind':m.kind,'name':m.name,'expected':m.expected,
      'actual':m.actual,'deltaArcSeconds':m.deltaArcSeconds,
    }).toList(),
  };
}

class KpReferenceValidator {
  const KpReferenceValidator(this.tolerance);
  final KpReferenceTolerance tolerance;

  Future<KpReferenceValidationReport> validateFile({
    required String actualJsonPath,
    required String referenceJsonPath,
  }) async {
    final actual=jsonDecode(await File(actualJsonPath).readAsString()) as Map<String,dynamic>;
    final reference=jsonDecode(await File(referenceJsonPath).readAsString()) as Map<String,dynamic>;
    return validate(actual:actual, reference:reference);
  }

  KpReferenceValidationReport validate({
    required Map<String,dynamic> actual,
    required Map<String,dynamic> reference,
  }) {
    final mismatches=<KpReferenceMismatch>[];
    var checked=0;
    final actualPlanets=Map<String,dynamic>.from(actual['planets']??{});
    final refPlanets=Map<String,dynamic>.from(reference['planets']??{});
    for(final name in refPlanets.keys){
      if(!actualPlanets.containsKey(name)) {
        mismatches.add(KpReferenceMismatch(kind:'planet',name:name,expected:_num(refPlanets[name]),actual:double.nan,deltaArcSeconds:double.infinity));
        continue;
      }
      checked++;
      _compare(mismatches,'planet',name,_num(refPlanets[name]),_num(actualPlanets[name]),tolerance.longitudeArcSeconds);
    }
    final actualCusps=Map<String,dynamic>.from(actual['cusps']??{});
    final refCusps=Map<String,dynamic>.from(reference['cusps']??{});
    for(final name in refCusps.keys){
      if(!actualCusps.containsKey(name)) {
        mismatches.add(KpReferenceMismatch(kind:'cusp',name:name,expected:_num(refCusps[name]),actual:double.nan,deltaArcSeconds:double.infinity));
        continue;
      }
      checked++;
      _compare(mismatches,'cusp',name,_num(refCusps[name]),_num(actualCusps[name]),tolerance.cuspArcSeconds);
    }
    return KpReferenceValidationReport(mismatches.isEmpty,checked,mismatches);
  }

  void _compare(List<KpReferenceMismatch> out,String kind,String name,double e,double a,double tol){
    final delta=_arcsecDistance(e,a);
    if(delta>tol) out.add(KpReferenceMismatch(kind:kind,name:name,expected:e,actual:a,deltaArcSeconds:delta));
  }

  double _num(dynamic v)=> (v as num).toDouble();

  // Longitudes are normalized circularly to avoid 359° vs 0° false failures.
  double _arcsecDistance(double a,double b){
    var d=(a-b).abs()%360.0;
    if(d>180.0) d=360.0-d;
    return d*3600.0;
  }
}
