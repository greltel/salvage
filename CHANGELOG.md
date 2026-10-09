# Changelog

All notable changes to SALVage are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.2.0] - 2026-10-09

Minor release: a new method reads the cells the user selected. Existing calls do not change.

### Added

- `ZCL_SALVAGE->SELECTED_CELLS( )` with the type `CELL_POSITIONS` (row index and column name of
  every selected cell). Selection mode `cells` offered cell selection before, but the selected
  cells could not be read.
- Demo report `ZSALVAGE_DEMO_06`: cell selection, with a button that adds up the selected cells.
- 23 unit tests (63 in all): `selected_cells( )` before `display( )`, cell types, column
  formats, position, technical columns, title,
  striped rows, optimized widths, layout key and initial layout, text below the list, filter
  sign and default comparison, hidden empty columns, the content of the exception, the button
  slots of the GUI status, events passed on to the handler, and the fixes below. The local test
  double `ltd_handler` records what the handler receives; abaplint accepts `LTD_` and `LTH_`
  test classes next to `LTC_`.

### Fixed

- `selected_rows( )` returns the rows in ascending order, as documented.
- `refresh( )`, `selected_rows( )` and `selected_cells( )` do nothing when `display( )` raised:
  they acted on a list that was never shown.
- `colors_from( )` and `lights_from( )` with a column the table does not have raise message 001
  (column does not exist) instead of 013 and 015 (wrong type).
- A click after the handler was cleared with `handled_by( )` no longer dumps.
- `layout( )` with `is_save_disabled`: the user's default layout is loaded at start again; before,
  switching off saving also switched off the default layout.
- A click or double-click on a total or subtotal line no longer reaches the handler. SALV
  reports it as row 0, so a handler reading `table[ row ]` dumped with
  `CX_SY_ITAB_LINE_NOT_FOUND`.
- The GUI status texts are filled for every slot of the status, and restored when the list ends
  with an exception.

### Changed

- Documentation (ABAP Doc and README): the table passed to `create( )` must be changeable, a
  write-protected table ends in `MOVE_TO_LIT_NOTALLOWED_NODATA` when the list sorts; every list
  of a program needs its own layout handle; one list per container, new data through
  `refresh( )`; a container needs SAP GUI, background jobs show the list in full screen; the
  `@raising` text of `display( )` names all kinds of configuration errors. Two new rows in
  Troubleshooting.
- Demo report `ZSALVAGE_DEMO_03`: the airline list and the flights in the dialog box have layout
  handles of their own.
- GitHub workflow: abaplint runs on Node.js 22.
- `button( )` stores the name in upper case, like column names. The handler receives it in upper
  case also in a container, and a name given twice in different case is rejected (message 008).

## [1.1.1] - 2026-10-09

Patch release: `refresh( )` shows deleted and added rows correctly. Existing calls do not change.

### Fixed

- `ZCL_SALVAGE`: `refresh( )` did a soft refresh, which keeps the filter and the groups of the
  rows the list showed before. After a handler deleted or added rows, rows the filter had
  hidden showed again, new rows were not sorted or filtered, and subtotals went missing.
  `refresh( )` now does a full refresh: sorting, filters and totals are applied again to the
  new content, and the user's sort order, filters and scroll position stay. Tested on SAP
  S/4HANA 2023 FPS03 with changed, deleted and added rows.
- Demo reports `ZSALVAGE_DEMO_02`, `_03` and `_04`: the airfare column takes its currency from
  column `CURRENCY`. Their line types are declared in the report, so SALV did not know the
  currency and showed amounts in currencies without two decimals wrong, for example JPY
  amounts 100 times too small.

### Changed

- `refresh( )` uses the constant `IF_SALV_C_REFRESH=>FULL`, which SAP does not list as classic
  API. It is the one such object in SALVage; see Limitations in the README.

## [1.1.0] - 2026-10-08

Minor release: the new public constant `ZCL_SALVAGE=>VERSION` extends the API. Existing calls do
not change.

### Added

- `ZCL_SALVAGE=>VERSION`: the installed version, `1.1.0` in this release, so that a system shows
  which release it runs.
- Issue forms on GitHub for bug reports and feature requests; the bug report asks for the
  version, the SAP release, the steps, the code and the message or short dump.
- ABAP Unit tests for `ZCL_SALVAGE` (local test class `ltc_salvage`, 40 tests): every
  configuration error, the settings handed to `CL_SALV_TABLE`, the mapping of the full screen
  button slots, and the format of `VERSION`. They run without a screen and read no business data from the database.

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
