# Changelog

All notable changes to SALVage are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versions follow
[Semantic Versioning](https://semver.org/).

## [1.0.0] - 2026-10-08

### Added

- `ZCL_SALVAGE`: fluent configuration of a `CL_SALV_TABLE` list - title, striped rows,
  optimized widths, column settings, sorting with subtotals, totals, layouts, selection modes,
  own buttons, dialog box and container display; `display( )`, `selected_rows( )`,
  `refresh( )` and `layout_f4( )`.
- `ZIF_SALVAGE_EVENTS`: double-click, hotspot click and own-button events, all `DEFAULT IGNORE`.
- `ZCX_SALVAGE_ERROR` with message class `ZSALVAGE`.
- `ZSALVAGE_GUI`: GUI status `SALVAGE_FULLSCREEN` with ten slots for own buttons in full screen.
- Demo reports `ZSALVAGE_DEMO_01` to `ZSALVAGE_DEMO_04`.
