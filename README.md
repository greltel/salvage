# SALVage

**A fluent wrapper around `CL_SALV_TABLE` for classic ABAP reports.**

![ABAP 7.50+](https://img.shields.io/badge/ABAP-7.50%2B-blue)
![Standard ABAP](https://img.shields.io/badge/language-Standard%20ABAP-blue)
![License: MIT](https://img.shields.io/badge/license-MIT-green)
[![abaplint](https://github.com/greltel/salvage/actions/workflows/abaplint.yml/badge.svg)](https://github.com/greltel/salvage/actions/workflows/abaplint.yml)
[![Release](https://img.shields.io/github/v/release/greltel/salvage)](https://github.com/greltel/salvage/releases)

SALVage turns the twenty lines of `CL_SALV_TABLE` boilerplate that every report repeats into
one readable chain:

```abap
zcl_salvage=>create( REF #( flights )
           )->title( `Flights`
           )->optimized(
           )->column( name     = 'SEATSOCC'
                      settings = VALUE #( text = `Booked` )
           )->sort_by( name     = 'CARRID'
                       settings = VALUE #( has_subtotals = abap_true )
           )->total( 'SEATSOCC'
           )->display( ).
```

All ALV toolbar functions are on and users can save layouts, without a line of code for it. A
fullscreen list with own buttons keeps the functions most lists use; see
[Limitations](#limitations).

---

## Contents

- [Why](#why)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Usage](#usage)
- [API reference](#api-reference)
- [How it works](#how-it-works)
- [Extending SALVage](#extending-salvage)
- [Limitations](#limitations)
- [Troubleshooting](#troubleshooting)
- [Demo reports](#demo-reports)
- [Contributing](#contributing)
- [License](#license)

## Why

The same list with plain SALV:

```abap
TRY.
    cl_salv_table=>factory( IMPORTING r_salv_table = DATA(alv)
                            CHANGING  t_table      = flights ).
    alv->get_display_settings( )->set_list_header( 'Flights' ).
    alv->get_functions( )->set_all( ).
    alv->get_columns( )->set_optimize( ).
    DATA(column) = CAST cl_salv_column_table( alv->get_columns( )->get_column( 'SEATSOCC' ) ).
    column->set_short_text( 'Booked' ).
    column->set_medium_text( 'Booked' ).
    column->set_long_text( 'Booked' ).
    alv->get_sorts( )->add_sort( columnname = 'CARRID'
                                 subtotal   = abap_true ).
    alv->get_aggregations( )->add_aggregation( 'SEATSOCC' ).
    DATA(layout) = alv->get_layout( ).
    layout->set_key( VALUE #( report = sy-repid ) ).
    layout->set_save_restriction( ).
    layout->set_default( abap_true ).
    alv->display( ).
  CATCH cx_salv_msg cx_salv_not_found cx_salv_existing cx_salv_data_error INTO DATA(error).
    MESSAGE error TYPE 'S' DISPLAY LIKE 'E'.
ENDTRY.
```

SALVage keeps what SALV does well and removes the ceremony:

- one object, one chain, from the internal table to the screen;
- sensible defaults: all toolbar functions, layout saving, the user's default layout;
- one exception class with readable messages instead of five SALV exceptions;
- own toolbar buttons also in fullscreen mode, where SALV alone needs a copied GUI status;
- one handler interface for clicks and buttons, instead of event registration code.

## Features

| Area | What you get |
|---|---|
| Display | Full screen, dialog box (popup) or any GUI container (docking, custom, splitter...) |
| Columns | Header text and quick info, width, position, hidden, technical, key, hotspot, checkbox, icon, colour, edit mask (conversion exit), hidden zeros, unit and currency column; the component name as header where no data element gives one |
| Rows | Sorting with subtotals, totals (sum, average, minimum, maximum), filters, row and cell colours, traffic lights, striped pattern, optimized column widths, empty columns hidden |
| Texts | Title, lines of text above and below the list |
| Layouts | Saving on by default, per program and handle, initial layout, F4 help for a selection-screen parameter |
| Interaction | Row or cell selection, own toolbar buttons, double-click, hotspot click |
| Errors | `ZCX_SALVAGE_ERROR` with texts from message class `ZSALVAGE` |
| Portability | ABAP 7.50 and later; uses only SALV objects SAP classifies as classic API, with one exception (see [Limitations](#limitations)) |

## Requirements

- SAP NetWeaver AS ABAP or ABAP Platform with **ABAP 7.50 or later** (S/4HANA on-premise and
  private cloud included).
- **Standard ABAP** (classic ABAP). SALV is a SAP GUI technology and is not released for
  ABAP Cloud.
- SAP GUI for Windows or SAP GUI for HTML (WebGUI) for the users of the reports; background
  jobs write the list to the spool.
- [abapGit](https://abapgit.org) to install.

### Tested on

SAP S/4HANA 2023 FPS03 (ABAP 7.58), with the demo reports. abaplint checks every change
against the syntax of ABAP 7.50, but SALVage has not yet run on a release older than 7.58; a
report from such a system is welcome as an issue.

| Front end or output | Checked |
|---|---|
| SAP GUI for Windows | All demos: full screen with own buttons, dialog box, docking container; the unit tests and ATC |
| SAP GUI for HTML (WebGUI) | Own buttons and hotspots in full screen, docking container, dialog box opened from a button, traffic lights, colours, text above and below the list |
| Background job | List in the spool with title, text above and below, traffic lights, colours, and totals per currency; a dialog box (`popup( )`) goes to the spool like a full screen list; the user's default layout applies |
| Spreadsheet export (XLSX) | Own column headers, text above and below, totals per currency, amounts with the decimals of their currency, hidden columns left out |
| Large table | 300,000 rows of 11 columns shown in full screen in about 5 seconds; `optimized( )` and `hide_empty_columns( )` add no noticeable time |

## Installation

1. Create package `Z_SALVAGE` (or let abapGit create it).
2. In abapGit, clone this repository into `Z_SALVAGE` (online), or download it as a zip and
   import it as an offline repository.
3. Pull. abapGit creates:

| Object | Type | Package | Purpose |
|---|---|---|---|
| `ZCL_SALVAGE` | Class | `Z_SALVAGE` | The library: the one public class |
| `ZIF_SALVAGE_EVENTS` | Interface | `Z_SALVAGE` | Handler for clicks and own buttons |
| `ZCX_SALVAGE_ERROR` | Exception class | `Z_SALVAGE` | Configuration errors |
| `ZSALVAGE` | Message class | `Z_SALVAGE` | Texts of the errors |
| `ZSALVAGE_GUI` | Program | `Z_SALVAGE` | GUI status for own buttons in fullscreen lists |
| `ZSALVAGE_DEMO_01` ... `_06` | Programs | `Z_SALVAGE_DEMOS` | Demo reports on `SCARR` / `SFLIGHT` |

The demo package is a subpackage. If you do not want the demos in a system, delete
`Z_SALVAGE_DEMOS` after the pull; the library does not use them.

Install with abapGit in the development system only. From there the objects of `Z_SALVAGE`
travel to quality assurance and production with ordinary transport requests; keep the demos in
a request of their own that does not go to production.

The demos read the flight data model (`SCARR`, `SFLIGHT`). If its tables are empty, fill them
with report `SAPBC_DATA_GENERATOR`.

The constant `ZCL_SALVAGE=>VERSION` tells which version a system has, for example `1.2.0`: the
[release](https://github.com/greltel/salvage/releases) tag without the `v`. For a production
system, install a release rather than the latest commit of `main`: switch the abapGit repository
to the release tag before the pull.

## Quick start

```abap
REPORT zmy_airlines.

START-OF-SELECTION.
  SELECT FROM scarr FIELDS carrid, carrname, currcode ORDER BY carrid INTO TABLE @DATA(carriers).
  zcl_salvage=>create( REF #( carriers ) )->title( `Airlines` )->display( ).
```

`create( )` takes a **reference** to your table. The ALV works on the table itself: when the user
sorts the list, your table is sorted, and the row index of every event points into your table.
Keep the table alive until `display( )` returns (for a container: as long as the list is visible).
Because the list changes the order of its rows, the table must be changeable: a reference to an
`IMPORTING` parameter or a constant ends in runtime error `MOVE_TO_LIT_NOTALLOWED_NODATA` as soon
as the list sorts. In a method that receives the rows, pass a variable or a copy:

```abap
METHOD show.                                   " IMPORTING flights TYPE flight_rows
  DATA(rows) = flights.                        " a copy the list may sort
  zcl_salvage=>create( REF #( rows ) )->display( ).
ENDMETHOD.
```

## Usage

### Columns

```abap
zcl_salvage=>create( REF #( flights )
           )->column( name     = 'CARRID'
                      settings = VALUE #( is_key = abap_true )
           )->column( name     = 'SEATSOCC'
                      settings = VALUE #( text = `Booked` tooltip = `Seats booked` width = 8 )
           )->column( name     = 'PLANETYPE'
                      settings = VALUE #( is_hidden = abap_true )
           )->display( ).
```

Initial components of the settings change nothing, so each call names only what it changes.
Column names are not case-sensitive. A name the table does not have raises `ZCX_SALVAGE_ERROR`
with message `ZSALVAGE 001` when `display( )` runs.

A column whose component has no data element, for example `TYPE p LENGTH 8 DECIMALS 2`, gets its
component name as header, unless you give it a `text`, and a width that fits its content, unless
you give it a `width`. Without that SALV cuts signs, separators and dates of such columns.

More column settings:

```abap
)->column( name     = 'REVENUE'
           settings = VALUE #( currency_column = 'CURRENCY'          " amount with its currency
                               color           = VALUE #( col = col_total )
                               is_zero_hidden  = abap_true )
)->column( name     = 'QUANTITY'
           settings = VALUE #( unit_column = 'UNIT' )                " quantity with its unit
)->column( name     = 'MATNR'
           settings = VALUE #( edit_mask = '==MATN1' )               " conversion exit
```

`unit_column` and `currency_column` are needed when the line type does not tell SALV which
column holds the unit or currency, typically for a structure declared in the report.

### Colours and traffic lights

```abap
TYPES:
  BEGIN OF flight,
    light    TYPE c LENGTH 1,      " 1 red, 2 yellow, 3 green
    carrid   TYPE sflight-carrid,
    seatsocc TYPE sflight-seatsocc,
    colors   TYPE lvc_t_scol,
  END OF flight.

" a line with an empty FNAME colours the row, a line with a column name only that cell
INSERT VALUE #( fname = 'SEATSOCC' color = VALUE #( col = col_negative ) ) INTO TABLE flight-colors.

zcl_salvage=>create( REF #( flights )
           )->lights_from( 'LIGHT'
           )->colors_from( 'COLORS'
           )->display( ).
```

### Filters

```abap
)->filter_by( name     = 'SEATSOCC'
              settings = VALUE #( option = 'GT' low = '0' ) )
)->filter_by( name     = 'CARRID'
              settings = VALUE #( low = 'LH' ) )      " option EQ when left initial
)->filter_by( name     = 'CARRID'
              settings = VALUE #( low = 'UA' ) )      " a second condition for the same column
)->filter_by( name     = 'CURRENCY'
              settings = VALUE #( is_excluded = abap_true low = 'EUR' ) )   " sign E
```

The rows are filtered when the list is shown; users see the filter in the toolbar and can change
or delete it. The conditions work like the lines of a ranges table, with `is_excluded` in place
of the sign: a structure with the components `SIGN`, `OPTION`, `LOW` and `HIGH` would make the
syntax check warn about every condition without a sign. Values are in internal format
(`20261231` for a date). The comparison must be one of `EQ NE GT GE LT LE BT NB CP NP`, in any
case; `display( )` rejects any other with message 016, because SALV would accept it and dump when
it shows the list.

### Text above and below the list

```abap
)->top_of_list( VALUE #( heading = `Occupancy of flights`
                         lines   = VALUE #( ( |Shown on { sy-datum DATE = USER }| ) ) ) )
)->end_of_list( VALUE #( lines = VALUE #( ( `Red: more than 90 % of the seats occupied` ) ) ) )
```

The heading is bold, every entry of `lines` is one line. The texts show in full screen, in a
dialog box and on the printout; a list in a container shows them on the printout only. In a small
dialog box they take room from the rows, so give it enough lines.

### Empty columns

`hide_empty_columns( )` hides every column that has no value in any row, for example optional
fields of a generic table. Users can show them again through the layout. An empty table hides
nothing.

### Sorting and totals

```abap
)->sort_by( name     = 'CARRID'
            settings = VALUE #( has_subtotals = abap_true )
)->sort_by( 'CONNID'
)->total( 'SEATSOCC'
)->total( name = 'PRICE'
          kind = if_salv_c_aggregation=>average )   " or minimum, maximum
```

The first `sort_by( )` is the first criterion. Subtotals appear for every column with a total.
Amounts and quantities with a currency or unit column are totalled per currency or unit.

### Layouts

Without any call users can save layouts for themselves and for everybody, kept per program, and
their default layout is shown at start. To change that:

```abap
)->layout( VALUE #( handle = 'HEAD'      " tells apart several lists of one program
                    name   = layout ) )  " layout shown at start, e.g. from the selection screen
```

`is_save_disabled = abap_true` lets users choose layouts, their default layout included, but not
save them.

Give every list of a program its own `handle` when the program shows more than one list, for
example a list and a dialog box opened from it. Lists with the same handle share their layouts:
a default layout saved in the dialog box would otherwise be applied to the main list too.

F4 help for a layout parameter on the selection screen:

```abap
PARAMETERS layout TYPE slis_vari.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR layout.
  layout = zcl_salvage=>layout_f4( layout ).
```

### Selection, own buttons and events

```abap
CLASS lcl_report DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_salvage_events.
    METHODS run.
  PRIVATE SECTION.
    DATA flights TYPE STANDARD TABLE OF sflight WITH EMPTY KEY.
    DATA alv     TYPE REF TO zcl_salvage.
ENDCLASS.

CLASS lcl_report IMPLEMENTATION.
  METHOD run.
    alv = zcl_salvage=>create( REF #( flights )
                     )->selection( zcl_salvage=>selection_modes-multiple
                     )->button( name     = 'CANCEL_FLIGHT'
                                settings = VALUE #( text = `Cancel flight` icon = icon_cancel )
                     )->column( name     = 'CONNID'
                                settings = VALUE #( is_hotspot = abap_true )
                     )->handled_by( me ).
    alv->display( ).
  ENDMETHOD.

  METHOD zif_salvage_events~on_button_click.
    DATA(rows) = alv->selected_rows( ).
    LOOP AT rows INTO DATA(row).
      " ... work with flights[ row ] ...
    ENDLOOP.
    alv->refresh( ).
  ENDMETHOD.

  METHOD zif_salvage_events~on_link_click.
    " ... flights[ row ], column ...
  ENDMETHOD.
ENDCLASS.
```

Every method of `ZIF_SALVAGE_EVENTS` is declared `DEFAULT IGNORE`: implement only the events
you need. New events can be added to the interface later without breaking your handlers.

| Event | Raised when |
|---|---|
| `on_double_click( row column )` | The user double-clicks a cell; not for total and subtotal lines |
| `on_link_click( row column )` | The user clicks a cell of a hotspot column; not for total and subtotal lines |
| `on_button_click( button )` | The user clicks an own button |

Own buttons per display mode:

| Display mode | Own buttons |
|---|---|
| Full screen (default) | Up to 10, through the GUI status of `ZSALVAGE_GUI` |
| Container (`in_container( )`) | Any number, in the toolbar of the list |
| Dialog box (`popup( )`) | None |

### Display modes

```abap
)->display( ).                                     " full screen
)->popup( )->display( ).                           " dialog box, default size
)->popup( VALUE #( start_column = 10 end_column = 120
                   start_line   = 5  end_line   = 20 ) )->display( ).
)->in_container( docking_container )->display( ).  " returns at once
```

A list in a container stays on the screen after `display( )` returned. Keep the reference to the
`ZCL_SALVAGE` object (an attribute, not a local variable) as long as the list is visible, so that
its events still reach your handler. Demo 04 shows a list in a docking container on the
selection screen.

Create one list per container and call `display( )` once; to show new data, change the table and
call `refresh( )`. Calling `display( )` again raises message 009. A container needs SAP GUI: a
report that may run in a background job shows its list in full screen there (`sy-batch`), which
writes it to the spool.

### Errors

`display( )` checks the whole configuration first and raises `ZCX_SALVAGE_ERROR` when something
does not fit: a column the table does not have, a total on a text column, a button in a dialog
box, more than 10 buttons in full screen, a table that is not a standard table with structured
lines, a filter comparison or total kind that does not exist, a colour or light column of the
wrong type, a dialog box with impossible coordinates. Several of these make SALV itself dump or
silently ignore the setting; SALVage stops them with a message instead. These are mistakes in
the calling program, so the class inherits from `CX_DYNAMIC_CHECK`: a report does not have to
catch it, and a mistake shows up at the first test. To show the text instead:

```abap
TRY.
    zcl_salvage=>create( REF #( flights ) )->total( 'CARRNAME' )->display( ).
  CATCH zcx_salvage_error INTO DATA(error).
    MESSAGE error TYPE 'S' DISPLAY LIKE 'E'.   " Column CARRNAME cannot be totaled: ...
ENDTRY.
```

Where SALV reported the problem, its exception is in `error->previous`.

## API reference

The ABAP Doc of every public declaration is the full reference (F2 in ADT).

### `ZCL_SALVAGE` - configuration (each returns the object for the next call)

| Method | Parameters | Purpose |
|---|---|---|
| `create` (static) | `table` | Starts a list for a reference to a standard table with structured lines |
| `title` | `text` | Header above the list |
| `striped` | - | Rows in alternating colours |
| `optimized` | - | Column widths fitted to the content |
| `column` | `name`, `settings` | How one column is shown |
| `sort_by` | `name`, `settings` (optional) | Ascending sort, optionally with subtotals |
| `total` | `name`, `kind` (optional) | Total line for a numeric column: sum, average, minimum or maximum |
| `filter_by` | `name`, `settings` | Filter condition applied at start |
| `colors_from` | `name` | Row and cell colours from a column of type `LVC_T_SCOL` |
| `lights_from` | `name` | Traffic lights from a column of type `C` length 1 |
| `hide_empty_columns` | - | Hides the columns without any value |
| `top_of_list` | `settings` | Lines of text above the list |
| `end_of_list` | `settings` | Lines of text below the list |
| `layout` | `settings` | Layout handling (default: saving allowed) |
| `selection` | `mode` | Row or cell selection |
| `button` | `name`, `settings` | Own toolbar button |
| `handled_by` | `handler` | Object implementing `ZIF_SALVAGE_EVENTS` |
| `popup` | `settings` (optional) | Show in a dialog box |
| `in_container` | `container` | Show in a GUI container |

### `ZCL_SALVAGE` - display and runtime

| Method | Purpose |
|---|---|
| `display` | Checks the configuration, applies it, shows the list; raises `ZCX_SALVAGE_ERROR` |
| `selected_rows` | Indexes of the selected rows, while the list is shown |
| `selected_cells` | Row index and column name of the selected cells, in selection mode `cells`; whole rows come from `selected_rows` |
| `refresh` | Shows the current content of the table again, also after rows were deleted or added; sorting, filters and totals are applied again, the user's sort order, filters and scroll position stay |
| `layout_f4` (static) | F4 help for a layout parameter of a selection screen |

### Settings structures

| Type | Components |
|---|---|
| `column_settings` | `text`, `tooltip`, `width`, `position`, `is_hidden`, `is_technical`, `is_key`, `is_hotspot`, `is_checkbox`, `is_icon`, `is_zero_hidden`, `unit_column`, `currency_column`, `edit_mask`, `color` |
| `filter_settings` | `is_excluded`, `option`, `low`, `high` |
| `text_settings` | `heading`, `lines` |
| `sort_settings` | `has_subtotals` |
| `layout_settings` | `name`, `handle`, `is_save_disabled` |
| `button_settings` | `text`, `icon`, `tooltip` |
| `popup_settings` | `start_column`, `end_column`, `start_line`, `end_line` |

Result types: `row_indexes` (row indexes, from `selected_rows( )`) and `cell_positions`
(`row`, `column`, from `selected_cells( )`).

Selection modes: `zcl_salvage=>selection_modes-single`, `-multiple` (several rows through a
selection column), `-cells` (single cells or blocks, read with `selected_cells( )`). In mode
`cells` users can also select whole rows with the row selector on the left; those rows come from
`selected_rows( )`, not from `selected_cells( )`, so read both.

Version: `zcl_salvage=>version`, the installed version as `major.minor.patch`, for example `1.2.0`.

### Messages of class `ZSALVAGE`

| No. | Text |
|---|---|
| 001 | Column &1 does not exist in the displayed table |
| 002 | The ALV for the table could not be created |
| 003 | Sorting by column &1 is not possible or defined twice |
| 004 | Column &1 cannot be totaled: not numeric or totaled twice |
| 005 | Button &1 could not be added to the toolbar |
| 006 | A fullscreen list offers at most &1 own buttons |
| 007 | A dialog box (popup) cannot show own buttons |
| 008 | Button &1 is defined more than once |
| 009 | The list is already displayed; use REFRESH to show changed data |
| 010 | Selection mode &1 is not supported |
| 011 | CREATE needs a reference to a standard table with structured lines |
| 012 | Filter on column &1 is not possible |
| 013 | Column &1 cannot hold the colours: it must be of type LVC_T_SCOL |
| 014 | Column &1 cannot take its unit or currency from column &2 |
| 015 | Column &1 cannot hold traffic lights: it must be of type C length 1 |
| 016 | Comparison &1 is not supported in the filter on column &2 |
| 017 | IN_CONTAINER needs a container; the reference passed is initial |
| 018 | Total kind &1 of column &2 is not supported; see IF_SALV_C_AGGREGATION |
| 019 | Dialog box columns &1-&2, lines &3-&4: start from 1, end after start |

## How it works

`ZCL_SALVAGE` is a builder with three stages, each in its own group of private methods:

```text
 configuration methods          display( )                              runtime
 title, column, sort_by, ...    check_configuration                     selected_rows, selected_cells
 record into private      ----> new_salv (CL_SALV_TABLE=>FACTORY) ----> refresh
 attributes; no SALV call,      apply_display_settings, apply_columns,  on_salv_* event methods
 no exception                   apply_sorts, apply_totals,              -> ZIF_SALVAGE_EVENTS
                                apply_filters, apply_selection,
                                apply_layout, apply_functions,
                                apply_list_texts, apply_popup
                                register_handler, show
```

- **Configuration only records.** No configuration method talks to SALV or raises an exception,
  so the chain reads like a description of the list. Calls can come in any order.
- **`display( )` is the one place that checks and applies.** It checks the configuration as a
  whole, creates the `CL_SALV_TABLE`, and applies one area after the other, each in its own
  `apply_*` method. SALV exceptions are turned into `ZCX_SALVAGE_ERROR` at this boundary.
- **Options travel in settings structures.** A method takes at most three parameters; options go
  into one structure filled with `VALUE #( )`. A new option is a new component, so existing
  calls keep compiling.
- **Events by composition.** SALV events are received by private methods and passed to the
  `ZIF_SALVAGE_EVENTS` handler. Its methods are `DEFAULT IGNORE`, so the interface can grow.
- **Own buttons in full screen.** SALV accepts own buttons in full screen only through an own
  GUI status. Program `ZSALVAGE_GUI` holds status `SALVAGE_FULLSCREEN`: the ALV functions most
  lists use, on the keys of SAP's status `SALV_TABLE_STANDARD` (details, select and deselect all,
  sort, set and delete filter, total, subtotals, print preview, spreadsheet, local file, send,
  graphic, ABC analysis, the layout functions, find and find next), plus ten slots,
  `SALVAGE01` to `SALVAGE10`, whose texts are dynamic function texts
  read from the static attribute `ZCL_SALVAGE=>SLOT_TEXTS`. `display( )` fills the slots from
  your `button( )` calls, hides the unused ones, and maps a click on a slot back to your button
  name. When a handler opens another fullscreen list, the texts of the first list are restored
  when the user comes back to it. The status also has a menu bar - List, Edit, Goto, Settings,
  and Extras with the own buttons - as the GUI usability check of the ATC asks. Its texts are in
  English only.
- **Testable without a screen.** `display( )` runs the private method `prepare( )` - check the
  configuration, create the `CL_SALV_TABLE`, apply the settings - and only then shows the list. The
  unit tests in the class (`ltc_salvage`, about 60 tests) call `prepare( )` directly and check
  the configuration errors, the settings handed to SALV, the button slots of the GUI status and
  the events passed on to the handler.
- **No copies.** The ALV gets your table by reference, so even large tables cost no extra memory
  and row indexes in events point into your table.

## Extending SALVage

New features go into the existing objects; the object list stays as short as it is.

| You want | Do this |
|---|---|
| A new option of an existing area (for example a column property) | Add a component with ABAP Doc to the settings structure and handle it in that area's `apply_*` method |
| A new area (for example print settings) | Add a configuration method that records into a private attribute, an `apply_<area>` method called from `apply_settings`, messages in `ZSALVAGE` for what can go wrong |
| A new event | Add a method with `DEFAULT IGNORE` to `ZIF_SALVAGE_EVENTS`, a private `on_salv_<event>` handler, and register it in `register_handler` |
| A new kind of output (for example a spreadsheet download) | Add a final method next to `display( )` that reuses `check_configuration`, `new_salv` and `apply_settings` |

Every change keeps ABAP 7.50 syntax, ABAP Doc on every public declaration, methods of at most
three parameters and about 20 statements, and a clean abaplint run. A new global object is
discussed in an issue first.

## Limitations

- **Display only.** Cells cannot be edited; for an editable grid use `CL_GUI_ALV_GRID` directly.
- **Classic API only.** SALVage uses only SALV objects that SAP lists as classic API in the
  [Cloudification Repository](https://github.com/SAP/abap-atc-cr-cv-s4hc). Some useful SALV
  options need objects that are not in that list, so SALVage does not offer them yet:
  - descending sort as an initial setting (`IF_SALV_C_SORT`) - users can still sort descending
    with the toolbar;
  - column alignment (`IF_SALV_C_ALIGNMENT`);
  - quick info for cell values (`CL_SALV_TOOLTIPS`);
  - column groups for the layout dialog (`CL_SALV_SPECIFIC_GROUPS`).

  One exception: `refresh( )` passes the constant `IF_SALV_C_REFRESH=>FULL`, which is not in
  that list. The default soft refresh keeps the filter and the groups of the old rows, so after
  a row was deleted or added, filtered rows show again and subtotals go; no classic object
  chooses the refresh mode.
- **Own buttons:** at most 10 in full screen, none in a dialog box. A fullscreen list with own
  buttons uses the status of `ZSALVAGE_GUI`, which leaves out a few functions of SAP's standard
  status to make room for the ten slots: the views SAP List Viewer, Microsoft Excel, Lotus 1-2-3
  and Crystal Reports, word processing, the report-report interface, information, refresh and
  the column navigation keys. A list without own buttons has them all. The status texts are in
  English; translate program `ZSALVAGE_GUI` in transaction SE63 where users log on in other
  languages.
- **Standard tables with structured lines only**, as `CL_SALV_TABLE` itself; `display( )` rejects
  a sorted or hashed table and a table of strings or numbers with message 011. The table must be
  changeable, see [Quick start](#quick-start).
- **Background jobs:** full screen lists and dialog boxes go to the spool. A container needs
  SAP GUI, so a report that may run in a background job shows its list in full screen there.
- SALV methods that `CL_SALV_TABLE` inherits from `CL_SALV_MODEL_LIST` and `CL_SALV_MODEL_BASE`
  (for example `SET_SCREEN_STATUS`, `GET_LAYOUT`) are called through `CL_SALV_TABLE`, which is
  classified as classic API.

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Dump `CX_SALV_OBJECT_NOT_FOUND`, "Object ZSALVAGE_GUI-SALVAGE_FULLSCREEN STATUS not found", for a full screen list with own buttons | Program `ZSALVAGE_GUI` exists without its GUI status, for example because it was created by hand | Pull `ZSALVAGE_GUI` again with abapGit; transaction SE41 must then show status `SALVAGE_FULLSCREEN` with the functions `SALVAGE01` to `SALVAGE10` |
| Runtime error `MOVE_TO_LIT_NOTALLOWED_NODATA` when the list sorts | The table passed to `create( )` is write-protected, for example an `IMPORTING` parameter or a constant | Pass a reference to a variable, for example a copy of the parameter (see [Quick start](#quick-start)) |
| The main list opens with columns hidden that the user never hid there | Two lists of the program share their layouts, and a default layout saved in the other list is applied | Give each list its own `handle` in `layout( )` |
| Message `ZSALVAGE 0nn` shows `amp;` in its text | The text was copied from `zsalvage.msag.xml`, where `&` is written `&amp;` | Correct the text in SE91, or pull the message class with abapGit |

## Demo reports

| Report | Shows |
|---|---|
| `ZSALVAGE_DEMO_01` | The smallest report: one table, one title |
| `ZSALVAGE_DEMO_02` | Selection screen, column settings, sorting with subtotals, totals, layouts with F4 help, error handling |
| `ZSALVAGE_DEMO_03` | Own buttons in full screen, row selection, hotspot click, a dialog box opened from a handler, `refresh( )` |
| `ZSALVAGE_DEMO_04` | A list with an own button in a docking container on the selection screen |
| `ZSALVAGE_DEMO_05` | Traffic lights, row and cell colours, a filter, text above and below the list, average and maximum, a currency column, hidden empty columns |
| `ZSALVAGE_DEMO_06` | Cell selection: a button adds up the selected cells and whole rows with `selected_cells( )` and `selected_rows( )` |

## Contributing

Report bugs and propose features through the
[issue forms](https://github.com/greltel/salvage/issues/new/choose). The bug report asks for what a
fix needs: `ZCL_SALVAGE=>VERSION`, the SAP release, the steps, the code and the message or dump.

Pull requests are welcome. Branch `main` is protected: changes reach it only through a pull
request, and only when the abaplint check of the pull request is green. Before you open one:

1. Keep the syntax at ABAP 7.50: `abaplint.json` checks against release 7.50 and rejects newer
   statements such as `RAISE EXCEPTION NEW` (7.52) or `ENUM` (7.51).
2. Run abaplint: `npx @abaplint/cli@2.120.70 abaplint.json`, the version the GitHub workflow runs on
   every push (older releases do not know `DEFAULT IGNORE` and report the demos).
3. Run the unit tests of `ZCL_SALVAGE` (Ctrl+Shift+F10 in ADT) and add a test for every new check
   or setting. The tests call the private method `prepare( )`, so they need no screen.
4. Document every public declaration with ABAP Doc.
5. Add or adjust a demo report when you add a feature.

`abaplint.json` enables all abaplint rules, with these changes and the reason for each:

| Rule | Change | Why |
|---|---|---|
| `types_naming`, `method_parameter_names`, `local_variable_names`, `class_attribute_names`, `selection_screen_naming` | off | They demand Hungarian prefixes (`TY_`, `IV_`, `LV_`, `MV_`, `P_`); SALVage follows Clean ABAP names |
| `no_inline_in_optional_branches` | off | It also reports `LOOP AT ... INTO DATA( )`, the form this code base uses |
| `check_subrc` | `selectTable` off | An empty result of `SELECT ... INTO TABLE` is a valid result |
| `no_yoda_conditions` | `onlyConstants` | Reports literals on the left only |
| `no_public_attributes` | `allowReadOnly` | `ZCL_SALVAGE=>SLOT_TEXTS` must be public for the GUI status |
| `abapdoc` | class and interface definitions too | ABAP Doc is the documentation of the library |
| `method_length` | 20 statements | Short methods |
| `use_message_class` | demos excluded | The demos show exception texts with `MESSAGE error TYPE ...`, which the rule cannot tell from a text message |
| `local_class_naming` | test classes `LTC_`, `LTD_`, `LTH_` | The unit test classes follow the `ltc_` / `ltd_` / `lth_` naming of the project instead of abaplint's default `LTCL_` |
| `no_dynamic_stuff` | `assign` off | `hide_empty_columns( )` reads the cells of the generic table with `ASSIGN COMPONENT`; the component names come from SALV, not from user input |
| `unused_variables` | skips `previous` | abaplint's stub of `CX_ROOT` has no constructor, so the `previous` parameter of the exception constructor looks unused |

### Releases

1. Set `ZCL_SALVAGE=>VERSION` to the new version: the patch number for fixes, the minor number for
   new options or methods, the major number for changes that break existing calls.
2. Move the entries under `[Unreleased]` in `CHANGELOG.md` to a section for the new version.
3. Merge into `main`, pull into a test system, run the unit tests and ATC.
4. Publish a release with the tag `v` plus the version, for example `v1.2.0`, on that commit.
   Release tags are never moved or deleted.

## License

[MIT](LICENSE)
