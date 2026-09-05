#!/usr/bin/env python3
import json, math, sys
from pathlib import Path

def delta(a,b):
    d=abs(float(a)-float(b))%360.0
    return min(d,360.0-d)*3600.0

def main(actual_path, reference_path, planet_tol=2.0, cusp_tol=5.0):
    actual=json.loads(Path(actual_path).read_text(encoding="utf-8"))
    ref=json.loads(Path(reference_path).read_text(encoding="utf-8"))
    mismatches=[]; checked=0
    for name,expected in ref["planets"].items():
        if name not in actual.get("planets",{}):
            mismatches.append(("planet",name,"missing",expected)); continue
        checked+=1
        d=delta(expected,actual["planets"][name])
        if d>planet_tol: mismatches.append(("planet",name,d,expected,actual["planets"][name]))
    for name,expected in ref["cusps"].items():
        if name not in actual.get("cusps",{}):
            mismatches.append(("cusp",name,"missing",expected)); continue
        checked+=1
        d=delta(expected,actual["cusps"][name])
        if d>cusp_tol: mismatches.append(("cusp",name,d,expected,actual["cusps"][name]))
    report={"passed":not mismatches,"checked":checked,"planetToleranceArcsec":planet_tol,
            "cuspToleranceArcsec":cusp_tol,"mismatches":mismatches}
    print(json.dumps(report,indent=2))
    return 0 if not mismatches else 1

if __name__=="__main__":
    if len(sys.argv)<3:
        print("Usage: validate_reference.py ACTUAL_JSON REFERENCE_JSON [planet_arcsec] [cusp_arcsec]")
        raise SystemExit(2)
    raise SystemExit(main(sys.argv[1],sys.argv[2],
                          float(sys.argv[3]) if len(sys.argv)>3 else 2.0,
                          float(sys.argv[4]) if len(sys.argv)>4 else 5.0))
