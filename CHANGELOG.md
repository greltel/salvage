# Changelog

All notable changes to SALVage are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), versions follow
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.5.0] - 2026-10-11

Minor release: a list without export or printing, the columns a user selected as a whole, and a
check for a layout name typed on the selection screen. Existing calls do not change.

### Added

- `toolbar( )` with the new structure `toolbar_settings`: `is_export_disabled` hides the export
  to a spreadsheet, a local file, a word processor, HTML, XML, mail, send and folder, and the
  views in Excel, Lotus and Crystal Reports; `is_print_disabled` hides printing and the print
  preview. Works in full screen, in a dialog box and in a container, through the `SET_EXPORT_*`,
  `SET_VIEW_*`, `SET_PRINT` and `SET_PRINT_PREVIEW` methods of `CL_SALV_FUNCTIONS_LIST`. Users
  can still copy cells, so this does not protect the data. Demo report `ZSALVAGE_DEMO_04` shows
  its flights without export.
- `selected_columns( )` with the new type `column_names`: the columns the user selected as a
  whole by clicking their header, which `selected_cells( )` does not return
  (`GET_SELECTED_COLUMNS` of `CL_SALV_SELECTIONS`). Demo report `ZSALVAGE_DEMO_06` adds them up
  with the selected cells and rows, each cell once.
- `layout_exists( )` (static): whether a layout of a name is saved for the calling program, to
  check a layout parameter of a selection screen (`GET_LAYOUTS` of `CL_SALV_LAYOUT_SERVICE`).
  The new message `ZSALVAGE 021` "Layout &1 does not exist" is for the report to send. Demo
  report `ZSALVAGE_DEMO_02` checks its layout parameter with it.
- 6 unit tests (85 in all): export and print preview hidden, the other functions and the own buttons
  kept, no selected columns before `display( )`, `layout_exists( )` for a name never saved and
  for an initial name. The tests take function codes from `IF_SALV_C_FUNCTION`, which is not
  classic API; this concerns the test class only.

## [1.4.0] - 2026-10-11

Bug-fix release: cell types from separate `column( )` calls, own buttons with an icon only in the
menu, and documentation checked against SAP S/4HANA 2023 FPS03. Existing calls do not change.

### Fixed

- `column( )`: checkbox and hotspot given in two calls for the same column add up to a clickable
  checkbox. Before, the later call replaced the cell type of the earlier one, so the column lost
  its hotspot (no `on_link_click`) or its checkbox, although the settings of all calls of
  `column( )` add up.
- Unit test `when_total_click_then_ignored` could not fail for a double-click: the test handler
  did not implement `on_double_click`. It does now, and the new test
  `when_double_click_then_handler` checks that a double-click reaches the handler.
- Fullscreen list: an own button with an icon but no text was missing from the menu Extras. It
  is listed there with its quick info, or with its name when it has no quick info either; the
  toolbar still shows the icon alone.

### Changed

- Documentation: of `popup( )` and `in_container( )`, the one called last decides how the list is
  shown; in full screen the toolbar shows the first 40 characters of a button text and the first
  60 of its quick info; a list for a container in a background job, checked on SAP S/4HANA 2023
  FPS03, goes to the spool in full screen. Also checked on that release and now documented: a
  fixed `unit` or `currency` replaces the unit or currency column of the ABAP Dictionary; a
  layout name without a saved layout shows the list without message; whole columns selected by
  their header are returned neither by `selected_cells( )` nor by `selected_rows( )` (also noted
  in demo report `ZSALVAGE_DEMO_06`).
- 5 unit tests (79 in all): checkbox and hotspot from separate calls in both orders, a
  double-click passed on to the handler, and the menu text of a button without text.

## [1.3.0] - 2026-10-11

Minor release: fixed units and currencies, fixed key columns, container lists in background
jobs, and no total lines in the selected cells. Existing calls do not change.

### Added

- `column_settings`: components `unit` and `currency` for a column whose rows all have the same
  unit or currency, through `SET_QUANTITY` and `SET_CURRENCY` of `CL_SALV_COLUMN`. A fixed value
  next to a `unit_column` or `currency_column` of the same column, also from another `column( )`
  call, raises the new message `ZSALVAGE 020`.
- `fixed_key_columns( )`: the key columns stay in place when users scroll to the right
  (`SET_KEY_FIXATION` of `CL_SALV_COLUMNS_LIST`). Demo report `ZSALVAGE_DEMO_02` uses it.
- 11 unit tests (74 in all): fixed unit and currency and their conflicts, fixed key columns, a
  container list in a background job, the default layout when saving is off, subtotals of a
  sort criterion, selection modes `single` and `cells`, the upper value of a filter.

### Fixed

- `selected_cells( )` returned cells of total and subtotal lines, with row 0 for the total and a
  negative row for a subtotal; a handler reading `table[ cell-row ]` dumped with
  `CX_SY_ITAB_LINE_NOT_FOUND`. Such cells are left out now. `selected_rows( )` leaves out rows
  below 1 too; SALV returned none in the tests on SAP S/4HANA 2023 FPS03.

### Changed

- A list for a container in a background job (`sy-batch`) is shown in full screen and written to
  the spool, without its own buttons. Before, `display( )` raised message 017 when the container
  was initial, as it is for a container created on the selection screen, and message 006 for
  more than 10 own buttons.
- Documentation: `selected_rows( )` and `selected_cells( )` also work outside the events, for
  example at `START-OF-SELECTION` for a list on the selection screen, and `refresh( )` from the
  selection screen keeps the user's sort order and filters (checked on SAP S/4HANA 2023 FPS03);
  amounts without currency in Troubleshooting; ABAP Doc links and releases 7.50 and 7.51 in
  Requirements.

## [1.2.1] - 2026-10-11

Patch release: a handler set after `display( )` is registered, and the GUI status loses three
stray functions. Existing calls do not change.

### Fixed

- `handled_by( )` after `display( )` registers the handler. Before, a list in a container whose
  handler was set after `display( )` returned passed no clicks and no own buttons to it.
- `ZSALVAGE_GUI`, status `SALVAGE_FULLSCREEN`: removed the functions `&ABCAB`, `&ETADE` and
  `&GRAPHGR` that release 1.2.0 added by mistake. They were active without menu entry, key or
  button, carried the texts " Analysis", "Ails" and "Phic", and a code typed into the command
  field could reach the handler as an own button.
- Message `ZSALVAGE 011` also covers a reference that is no longer valid, for example to a local
  table of a method that has ended: "CREATE needs a valid reference to a standard table with
  structured lines".

### Changed

- `.abapgit.xml`: abapGit checks that `SAP_BASIS` is release 750 or later before the pull, and
  shows the installed version from `ZCL_SALVAGE=>VERSION`.
- Documentation (ABAP Doc and README): a report that may run in a background job leaves out
  `in_container( )` when `sy-batch` is set, and full screen then allows at most 10 own buttons;
  `hide_empty_columns( )` also hides number columns that are zero in every row and is not
  repeated by `refresh( )`; how to install under other names; the unit tests use
  `CL_SALV_SELOPT`, which is not classic API; a new kind of output must check that its SALV
  objects are classic API. The bug report form suggests the current version.

## [1.2.0] - 2026-10-09

Minor release: a new method reads the cells the user selected. Existing calls do not change.

### Added

- `ZCL_SALVAGE->SELECTED_CELLS( )` with the type `CELL_POSITIONS` (row index and column name of
  every selected cell). Selection mode `cells` offered cell selection before, but the selected
  cells could not be read.
- Demo report `ZSALVAGE_DEMO_06`: cell selection, with a button that adds up the selected cells
  and the rows selected as a whole. In mode `cells`, whole rows come from `selected_rows( )`, as
  the ABAP Doc of `selected_cells( )` says.
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
- `ZSALVAGE_GUI`: own button 9 was on key combination Shift+Ctrl+0, which SAP GUI no longer
  supports; it is on Shift+F12 now.

### Changed

- `ZSALVAGE_GUI`, status `SALVAGE_FULLSCREEN`: new functions select all and deselect all (F5,
  F6), delete filter, find next, graphic and ABC analysis, and choose on F2, on the keys of SAP's
  `SALV_TABLE_STANDARD`; details moved to Ctrl+Shift+F3. The Edit and Goto menus list them.
  Fullscreen lists with own buttons now offer the same everyday functions as lists without.
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
