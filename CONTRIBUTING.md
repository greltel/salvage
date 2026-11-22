# Contributing to SALVage

Thank you for helping. SALVage stays small on purpose: one public class, display only, ABAP
7.50 syntax, and only SAP objects that are classic API.

## Bugs and ideas

Use the [issue forms](https://github.com/greltel/salvage/issues/new/choose). Look at
[Troubleshooting](README.md#troubleshooting) and [Limitations](README.md#limitations) first, and
replace business data in code, screenshots and dumps: issues are public.

**Reports from ABAP 7.50 to 7.57 are the most useful contribution right now.** SALVage is
checked against the syntax of 7.50 but has run on 7.58 only. If you installed it on an older
release, open an issue with the release, the result of the unit tests and what the demo reports
show - also when everything works.

## Pull requests

Branch `main` takes changes through pull requests only, and only when the checks `abaplint` and
`classic-api` are green and the branch is up to date with `main`.

1. For anything larger than a fix, open an issue first, so the API is agreed before you write it.
2. Follow the rules in [Contributing](README.md#contributing) of the README: syntax, abaplint,
   classic API, unit tests, ABAP Doc, demo reports.
3. Fill in the pull request template. GitHub cannot run ABAP, so the release you tested on and
   the result of the unit tests are part of the review.
4. Add your change to `[Unreleased]` in `CHANGELOG.md`. Leave `ZCL_SALVAGE=>VERSION` alone; it
   changes with a [release](README.md#releases).

By contributing you agree that your work is published under the [MIT License](LICENSE).
