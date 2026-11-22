## What and why

<!-- What changes for a report that uses SALVage, and why. Link the issue: "Closes #12". -->

## Tested on

<!-- GitHub checks the syntax (abaplint) and the SAP objects (classic-api). It cannot run ABAP:
     the unit tests and the demo reports run only in your system. -->

- SAP release: <!-- e.g. S/4HANA 2023 FPS03, SAP_BASIS 758 -->
- Front end: <!-- SAP GUI for Windows / SAP GUI for HTML / background job -->
- Unit tests of `ZCL_SALVAGE`: <!-- e.g. 123 run, 0 failed -->

## Checklist

- [ ] Syntax stays at ABAP 7.50; `npx @abaplint/cli@2.120.70 abaplint.json` reports 0 issues
- [ ] Only SAP objects that are classic API; a new exception has its reason in
      `.github/scripts/classic_api_exceptions.txt` and in Limitations of the README
- [ ] Unit tests of `ZCL_SALVAGE` are green in my system, with a test for every new check or setting
- [ ] Every public declaration has ABAP Doc; new texts are messages of class `ZSALVAGE`
- [ ] No new global object (class, interface, program), or it was agreed in an issue first
- [ ] `CHANGELOG.md` has an entry under `[Unreleased]`; README and demo reports follow the change
- [ ] `ZCL_SALVAGE=>VERSION` is unchanged (it changes with a release only)

<!-- Docs or workflow change only? Tick what applies and say so above. -->
