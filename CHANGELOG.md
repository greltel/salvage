# Changelog

All notable changes to SALVage are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- ABAP Unit tests for `ZCL_SALVAGE` (local test class `ltc_salvage`, 39 tests): every
  configuration error, the settings handed to `CL_SALV_TABLE`, and the mapping of the full screen
  button slots. They run without a screen and read no business data from the database.

### Changed

- `ZCL_SALVAGE`: `display( )` runs its checks and settings in the new private method `prepare( )`,
  which the unit tests call. No change for callers.
- `ZSALVAGE_GUI`: status `SALVAGE_FULLSCREEN` has a menu bar (List, Edit, Goto, Settings, and
  Extras with the own buttons), as the GUI usability check of the ATC asks.
- Demo reports: the selects of all airlines carry the pseudo comment `CI_NOWHERE`; ATC reported
  them as selects without a WHERE condition.

## [1.0.0] - 2026-10-08

First release. Tested on SAP S/4HANA 2023 (ABAP 7.58); the syntax is checked against ABAP 7.50.

### Added

- `ZCL_SALVAGE`: fluent configuration of a `CL_SALV_TABLE` list - title, striped rows,
  optimized widths, column settings, sorting with subtotals, totals, filters, layouts, selection
  modes, own buttons, text above and below the list, full screen, dialog box and container
  display; `display( )`, `selected_rows( )`, `refresh( )` and `layout_f4( )`.
- Column settings: header text and quick info, width, position, hidden, technical, key, hotspot,
  checkbox, icon, hidden zeros, unit and currency columns, edit masks and column colours.
- `total( )` with sum, average, minimum and maximum; `filter_by( )`, `colors_from( )`,
  `lights_from( )`, `hide_empty_columns( )`, `top_of_list( )` and `end_of_list( )`.
- Columns without dictionary texts get the component name as header and a width that fits
  their content.
- `display( )` checks the whole configuration before SALV sees it and raises
  `ZCX_SALVAGE_ERROR` where SALV would dump or silently ignore the setting:
  - a table that is not a standard table or whose lines are not structures (message 011);
  - a filter comparison that does not exist (016);
  - `in_container( )` without a container (017);
  - a total kind that is not a constant of `IF_SALV_C_AGGREGATION` (018);
  - a dialog box with missing or inverted coordinates (019);
  - a colour or traffic light column of the wrong type (013, 015) - SALV rejects these with
    `CX_SALV_INVALID_INPUT`, which is neither classic API nor declared.
- `ZIF_SALVAGE_EVENTS`: double-click, hotspot click and own-button events, all `DEFAULT IGNORE`.
- `ZCX_SALVAGE_ERROR` with message class `ZSALVAGE` (messages 001 to 019).
- `ZSALVAGE_GUI`: GUI status `SALVAGE_FULLSCREEN` with ten slots for own buttons in full screen.
- Demo reports `ZSALVAGE_DEMO_01` to `ZSALVAGE_DEMO_05`.
