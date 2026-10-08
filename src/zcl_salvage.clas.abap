"! <p>Fluent wrapper around {@link cl_salv_table} for classic ABAP reports.</p>
"! <p>Start with {@link zcl_salvage.METH:create}, describe the list with the configuration
"! methods and finish the chain with {@link zcl_salvage.METH:display}. The configuration
"! methods only record what they are told. {@link zcl_salvage.METH:display} checks the whole
"! configuration, applies it to a new {@link cl_salv_table} and shows the list.</p>
"! <p>The list is for display only: users cannot change its cells.</p>
CLASS zcl_salvage DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    TYPES:
      "! How one column is shown, for {@link zcl_salvage.METH:column}. Initial components keep
      "! what the ABAP Dictionary defines for the column.
      BEGIN OF column_settings,
        "! Header text; used as short, medium and long header, cut to 10, 20 and 40 characters
        text            TYPE string,
        "! Quick info of the column header
        tooltip         TYPE string,
        "! Output width in characters; ignored when {@link zcl_salvage.METH:optimized} is used
        width           TYPE i,
        "! Position from the left, starting at 1
        position        TYPE i,
        "! abap_true: hidden at start; users can show the column again through the layout
        is_hidden       TYPE abap_bool,
        "! abap_true: never shown, not even in the layout dialog
        is_technical    TYPE abap_bool,
        "! abap_true: key column, shown in the key colour
        is_key          TYPE abap_bool,
        "! abap_true: cells are links; a click calls {@link zif_salvage_events.METH:on_link_click}
        is_hotspot      TYPE abap_bool,
        "! abap_true: abap_true and abap_false are shown as a checkbox the user cannot change.
        "! Together with is_hotspot a click calls {@link zif_salvage_events.METH:on_link_click},
        "! where the handler may switch the value in the table and call
        "! {@link zcl_salvage.METH:refresh}.
        is_checkbox     TYPE abap_bool,
        "! abap_true: cells hold icon codes, for example constants of type pool ICON
        is_icon         TYPE abap_bool,
        "! abap_true: cells with the value zero stay empty
        is_zero_hidden  TYPE abap_bool,
        "! Column that holds the unit of this quantity column. Needed when the line type does
        "! not define the unit itself, for example a structure declared in the report.
        unit_column     TYPE lvc_qfname,
        "! Column that holds the currency of this amount column; see unit_column
        currency_column TYPE lvc_cfname,
        "! Output format: ==ALPHA for the conversion exit ALPHA, or a mask such as __:__
        edit_mask       TYPE lvc_edtmsk,
        "! Colour of the whole column, for example VALUE #( col = col_positive ) with the
        "! constants of type pool COL
        color           TYPE lvc_s_colo,
      END OF column_settings.

    TYPES:
      "! One sort criterion, for {@link zcl_salvage.METH:sort_by}.
      BEGIN OF sort_settings,
        "! abap_true: a subtotal line after each group of equal values, for every column
        "! with a total (see {@link zcl_salvage.METH:total})
        has_subtotals TYPE abap_bool,
      END OF sort_settings.

    TYPES:
      "! Layout (variant) handling, for {@link zcl_salvage.METH:layout}.
      BEGIN OF layout_settings,
        "! Layout shown at start; initial: the default layout of the user, if there is one
        name             TYPE slis_vari,
        "! Tells apart several lists of the same program, for example HEAD and ITEM
        handle           TYPE slis_handl,
        "! abap_true: users can choose layouts but cannot save them
        is_save_disabled TYPE abap_bool,
      END OF layout_settings.

    TYPES:
      "! Size of the dialog box, for {@link zcl_salvage.METH:popup}, in screen columns and lines.
      BEGIN OF popup_settings,
        start_column TYPE i,
        end_column   TYPE i,
        start_line   TYPE i,
        end_line     TYPE i,
      END OF popup_settings.

    TYPES:
      "! An own toolbar button, for {@link zcl_salvage.METH:button}.
      BEGIN OF button_settings,
        "! Text on the button
        text    TYPE string,
        "! Icon on the button, for example ICON_RELEASE of type pool ICON
        icon    TYPE icon_d,
        "! Quick info shown when the mouse rests on the button
        tooltip TYPE string,
      END OF button_settings.

    TYPES:
      "! One filter condition, for {@link zcl_salvage.METH:filter_by}: a line of a ranges table
      "! with is_excluded in place of the sign.
      BEGIN OF filter_settings,
        "! abap_true: drops the rows that meet the condition (sign E); initial: keeps them (sign I)
        is_excluded TYPE abap_bool,
        "! Comparison, for example EQ, NE, GT, BT or CP; initial: EQ
        option      TYPE salv_de_selopt_option,
        "! Value in internal format, for example 20261231 for a date
        low         TYPE salv_de_selopt_low,
        "! Upper value, for the comparisons BT and NB
        high        TYPE salv_de_selopt_high,
      END OF filter_settings.

    TYPES:
      "! Lines of text above or below the list, for {@link zcl_salvage.METH:top_of_list} and
      "! {@link zcl_salvage.METH:end_of_list}.
      BEGIN OF text_settings,
        "! First line, in bold
        heading TYPE string,
        "! Further lines, one per entry
        lines   TYPE string_table,
      END OF text_settings.

    "! Selection mode, for {@link zcl_salvage.METH:selection}. The values are the components of
    "! {@link zcl_salvage.DATA:selection_modes}.
    TYPES selection_mode TYPE i.

    "! Indexes of rows in the displayed table.
    TYPES row_indexes TYPE STANDARD TABLE OF i WITH EMPTY KEY.

    TYPES:
      "! Technical type of {@link zcl_salvage.DATA:slot_texts}: one dynamic function text per
      "! button slot of GUI status SALVAGE_FULLSCREEN in program ZSALVAGE_GUI.
      BEGIN OF function_slot_texts,
        f01 TYPE rsfunc_txt,
        f02 TYPE rsfunc_txt,
        f03 TYPE rsfunc_txt,
        f04 TYPE rsfunc_txt,
        f05 TYPE rsfunc_txt,
        f06 TYPE rsfunc_txt,
        f07 TYPE rsfunc_txt,
        f08 TYPE rsfunc_txt,
        f09 TYPE rsfunc_txt,
        f10 TYPE rsfunc_txt,
      END OF function_slot_texts.

    CONSTANTS:
      "! Selection modes for {@link zcl_salvage.METH:selection}.
      BEGIN OF selection_modes,
        "! One row at a time
        single   TYPE selection_mode VALUE 1,
        "! Several rows, through a selection column on the left
        multiple TYPE selection_mode VALUE 2,
        "! Single cells or blocks of cells
        cells    TYPE selection_mode VALUE 3,
      END OF selection_modes.

    "! Technical, not for use in reports: the texts of the own buttons of the fullscreen list
    "! that is shown right now. GUI status SALVAGE_FULLSCREEN of program ZSALVAGE_GUI reads them
    "! as dynamic function texts, which is why the attribute is public.
    CLASS-DATA slot_texts TYPE function_slot_texts READ-ONLY.

    "! Starts the configuration of a list for an internal table.
    "!
    "! @parameter table  | Reference to the rows to show, a standard table, for example
    "!                     REF #( flights ). The list works on this table itself: when the user
    "!                     sorts, the table is sorted. It must stay alive until
    "!                     {@link zcl_salvage.METH:display} has returned, and in a container as
    "!                     long as the list is visible.
    "! @parameter result | The new list, ready for the configuration methods
    CLASS-METHODS create
      IMPORTING table         TYPE REF TO data
      RETURNING VALUE(result) TYPE REF TO zcl_salvage.

    "! Value help for a layout parameter of a selection screen: lists the layouts saved for the
    "! calling program and returns the one the user picks.
    "!
    "! @parameter current | Value of the parameter now; returned unchanged when the user cancels
    "! @parameter handle  | Handle of the list, if the report uses one in {@link zcl_salvage.METH:layout}
    "! @parameter result  | Name of the layout the user picked
    CLASS-METHODS layout_f4
      IMPORTING current       TYPE slis_vari
                handle        TYPE slis_handl OPTIONAL
      RETURNING VALUE(result) TYPE slis_vari.

    "! Sets the header shown above the list.
    "!
    "! @parameter text | Header text; cut after 70 characters
    "! @parameter self | This list, for the next call of the chain
    METHODS title
      IMPORTING text        TYPE csequence
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Shows the rows in alternating colours.
    "!
    "! @parameter self | This list, for the next call of the chain
    METHODS striped
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Fits the width of every column to its content when the list is shown. Takes time on
    "! tables with many rows, because every row is read.
    "!
    "! @parameter self | This list, for the next call of the chain
    METHODS optimized
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Changes how one column is shown. Call it again for the same column to change more:
    "! the settings of all calls are applied in the order of the calls.
    "!
    "! @parameter name     | Name of the column, that is, of the component of the table line
    "! @parameter settings | What to change; initial components keep the dictionary definition
    "! @parameter self     | This list, for the next call of the chain
    METHODS column
      IMPORTING name        TYPE csequence
                settings    TYPE column_settings
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Sorts the rows by a column in ascending order. Call it once per column; the first call
    "! is the first sort criterion.
    "!
    "! @parameter name     | Name of the column
    "! @parameter settings | Subtotals for the criterion; initial: none
    "! @parameter self     | This list, for the next call of the chain
    METHODS sort_by
      IMPORTING name        TYPE csequence
                settings    TYPE sort_settings OPTIONAL
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Adds a total line for a numeric column: the sum, or the average, minimum or maximum.
    "! Amounts and quantities with a currency or unit column are totalled per currency or unit.
    "!
    "! @parameter name | Name of the column
    "! @parameter kind | A constant of {@link if_salv_c_aggregation}: TOTAL (the default),
    "!                   AVERAGE, MINIMUM or MAXIMUM
    "! @parameter self | This list, for the next call of the chain
    METHODS total
      IMPORTING name        TYPE csequence
                kind        TYPE salv_de_aggregation DEFAULT if_salv_c_aggregation=>total
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Filters the rows when the list is shown; users can change or delete the filter. Call it
    "! again for the same column to add a further condition, as in a ranges table.
    "!
    "! @parameter name     | Name of the column
    "! @parameter settings | The condition
    "! @parameter self     | This list, for the next call of the chain
    METHODS filter_by
      IMPORTING name        TYPE csequence
                settings    TYPE filter_settings
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Takes the colours of rows and cells from a column of type LVC_T_SCOL. A line in it with
    "! an empty FNAME colours the whole row, a line with a column name in FNAME only that cell.
    "! The colour column itself is not shown.
    "!
    "! @parameter name | Name of the colour column
    "! @parameter self | This list, for the next call of the chain
    METHODS colors_from
      IMPORTING name        TYPE csequence
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Shows a traffic light in every row, taken from a column of type C length 1: the values
    "! 1, 2 and 3 show a red, yellow and green light instead of the value.
    "!
    "! @parameter name | Name of the column with the light values
    "! @parameter self | This list, for the next call of the chain
    METHODS lights_from
      IMPORTING name        TYPE csequence
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Hides every column that is empty in all rows. Users can show it again through the
    "! layout. Reads the rows once per column when the list is shown; an empty table hides
    "! nothing.
    "!
    "! @parameter self | This list, for the next call of the chain
    METHODS hide_empty_columns
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Sets lines of text above the list. SAP shows them in full screen and on the printout; a
    "! list in a container shows them on the printout only.
    "!
    "! @parameter settings | Heading and further lines
    "! @parameter self     | This list, for the next call of the chain
    METHODS top_of_list
      IMPORTING settings    TYPE text_settings
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Sets lines of text below the list, shown like those of {@link zcl_salvage.METH:top_of_list}.
    "!
    "! @parameter settings | Heading and further lines
    "! @parameter self     | This list, for the next call of the chain
    METHODS end_of_list
      IMPORTING settings    TYPE text_settings
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Changes the layout (variant) handling. Without this call users can save layouts for
    "! themselves and for all users, kept per calling program, and the default layout of the
    "! user is shown at start.
    "!
    "! @parameter settings | Layout at start, handle, and whether saving is allowed
    "! @parameter self     | This list, for the next call of the chain
    METHODS layout
      IMPORTING settings    TYPE layout_settings
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Lets the user select rows or cells; read them with {@link zcl_salvage.METH:selected_rows}.
    "!
    "! @parameter mode | A component of {@link zcl_salvage.DATA:selection_modes}
    "! @parameter self | This list, for the next call of the chain
    METHODS selection
      IMPORTING mode        TYPE selection_mode
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Adds an own button to the toolbar. A click calls
    "! {@link zif_salvage_events.METH:on_button_click} of the handler passed to
    "! {@link zcl_salvage.METH:handled_by}. A fullscreen list offers 10 own buttons, a list in a
    "! container any number, a dialog box ({@link zcl_salvage.METH:popup}) none.
    "!
    "! @parameter name     | Name of the button, passed to the handler on a click
    "! @parameter settings | Text, icon and quick info
    "! @parameter self     | This list, for the next call of the chain
    METHODS button
      IMPORTING name        TYPE salv_de_function
                settings    TYPE button_settings
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Sets the object that reacts to clicks and to own buttons.
    "!
    "! @parameter handler | Implements the events it needs, the others stay empty
    "! @parameter self    | This list, for the next call of the chain
    METHODS handled_by
      IMPORTING handler     TYPE REF TO zif_salvage_events
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Shows the list in a dialog box instead of the full screen.
    "!
    "! @parameter settings | Size of the dialog box; initial: a box of about 155 columns and 22
    "!                        lines. If given, give all four components.
    "! @parameter self     | This list, for the next call of the chain
    METHODS popup
      IMPORTING settings    TYPE popup_settings OPTIONAL
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Shows the list in a GUI container of your screen, for example a docking container,
    "! instead of the full screen. {@link zcl_salvage.METH:display} then returns at once, so keep
    "! a reference to this object as long as the list is visible.
    "!
    "! @parameter container | Container the list fills
    "! @parameter self      | This list, for the next call of the chain
    METHODS in_container
      IMPORTING container   TYPE REF TO cl_gui_container
      RETURNING VALUE(self) TYPE REF TO zcl_salvage.

    "! Checks the configuration, applies it and shows the list. A fullscreen list or a dialog
    "! box returns when the user leaves it; a list in a container returns at once.
    "!
    "! @raising zcx_salvage_error | The configuration names a column the table does not have, or
    "!                              asks for something the display mode does not offer; nothing
    "!                              is shown
    METHODS display
      RAISING zcx_salvage_error.

    "! Rows the user has selected, while the list is shown, for example in an event handler.
    "!
    "! @parameter result | Indexes of the selected rows in the table, in ascending order;
    "!                     empty before {@link zcl_salvage.METH:display}
    METHODS selected_rows
      RETURNING VALUE(result) TYPE row_indexes.

    "! Shows the current content of the table again, for example after an event handler
    "! changed it. The scroll position stays. Does nothing before {@link zcl_salvage.METH:display}.
    METHODS refresh.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF column_change,
        name     TYPE lvc_fname,
        settings TYPE column_settings,
      END OF column_change.
    TYPES column_changes TYPE STANDARD TABLE OF column_change WITH EMPTY KEY.

    TYPES:
      BEGIN OF sort_criterion,
        name     TYPE lvc_fname,
        settings TYPE sort_settings,
      END OF sort_criterion.
    TYPES sort_criteria TYPE STANDARD TABLE OF sort_criterion WITH EMPTY KEY.

    TYPES:
      BEGIN OF column_total,
        name TYPE lvc_fname,
        kind TYPE salv_de_aggregation,
      END OF column_total.
    TYPES column_totals TYPE STANDARD TABLE OF column_total WITH EMPTY KEY.

    TYPES:
      BEGIN OF filter_condition,
        name     TYPE lvc_fname,
        settings TYPE filter_settings,
      END OF filter_condition.
    TYPES filter_conditions TYPE STANDARD TABLE OF filter_condition WITH EMPTY KEY.

    TYPES:
      BEGIN OF own_button,
        name     TYPE salv_de_function,
        settings TYPE button_settings,
      END OF own_button.
    TYPES own_buttons TYPE STANDARD TABLE OF own_button WITH EMPTY KEY.

    TYPES function_names TYPE STANDARD TABLE OF salv_de_function WITH EMPTY KEY.
    TYPES slot_number TYPE n LENGTH 2.
    TYPES output_mode TYPE c LENGTH 1.

    CONSTANTS:
      BEGIN OF output_modes,
        fullscreen TYPE output_mode VALUE 'F',
        popup      TYPE output_mode VALUE 'P',
        container  TYPE output_mode VALUE 'C',
      END OF output_modes.

    " Must match program ZSALVAGE_GUI: its status has one function per slot,
    " SALVAGE01 to SALVAGE10, with the texts of SLOT_TEXTS-F01 to SLOT_TEXTS-F10
    CONSTANTS:
      BEGIN OF gui,
        program     TYPE syrepid VALUE 'ZSALVAGE_GUI',
        status      TYPE sypfkey VALUE 'SALVAGE_FULLSCREEN',
        slot_prefix TYPE string  VALUE `SALVAGE`,
        slots       TYPE i       VALUE 10,
      END OF gui.

    CONSTANTS:
      BEGIN OF default_popup,
        start_column TYPE i VALUE 5,
        end_column   TYPE i VALUE 160,
        start_line   TYPE i VALUE 3,
        end_line     TYPE i VALUE 25,
      END OF default_popup.

    " Signs of a filter condition, and the option of a condition that leaves it initial
    CONSTANTS:
      BEGIN OF filter_values,
        including      TYPE salv_de_selopt_sign   VALUE 'I',
        excluding      TYPE salv_de_selopt_sign   VALUE 'E',
        default_option TYPE salv_de_selopt_option VALUE 'EQ',
      END OF filter_values.

    " Text above and below the list is one column of a form grid, one line per row
    CONSTANTS text_form_column TYPE i VALUE 1.

    DATA table               TYPE REF TO data.
    DATA program             TYPE syrepid.
    DATA output              TYPE output_mode.
    DATA header_text         TYPE string.
    DATA is_striped          TYPE abap_bool.
    DATA is_optimized        TYPE abap_bool.
    DATA hides_empty_columns TYPE abap_bool.
    DATA changed_columns     TYPE column_changes.
    DATA color_column        TYPE lvc_fname.
    DATA light_column        TYPE lvc_fname.
    DATA sorts               TYPE sort_criteria.
    DATA totals              TYPE column_totals.
    DATA filters             TYPE filter_conditions.
    DATA top_text            TYPE text_settings.
    DATA end_text            TYPE text_settings.
    DATA layout_options      TYPE layout_settings.
    DATA row_selection       TYPE selection_mode.
    DATA buttons             TYPE own_buttons.
    DATA handler             TYPE REF TO zif_salvage_events.
    DATA popup_area          TYPE popup_settings.
    DATA container           TYPE REF TO cl_gui_container.
    DATA salv                TYPE REF TO cl_salv_table.
    DATA is_displayed        TYPE abap_bool.

    METHODS check_configuration
      RAISING zcx_salvage_error.

    METHODS is_standard_table
      RETURNING VALUE(result) TYPE abap_bool.

    METHODS check_buttons
      RAISING zcx_salvage_error.

    METHODS new_salv
      RETURNING VALUE(result) TYPE REF TO cl_salv_table
      RAISING   zcx_salvage_error.

    METHODS apply_settings
      RAISING zcx_salvage_error.

    METHODS apply_display_settings.

    METHODS apply_columns
      RAISING zcx_salvage_error.

    METHODS apply_default_texts
      IMPORTING columns TYPE REF TO cl_salv_columns_table.

    METHODS apply_color_column
      IMPORTING columns TYPE REF TO cl_salv_columns_table
      RAISING   zcx_salvage_error.

    METHODS apply_light_column
      IMPORTING columns TYPE REF TO cl_salv_columns_table
      RAISING   zcx_salvage_error.

    METHODS apply_empty_columns
      IMPORTING columns TYPE REF TO cl_salv_columns_table.

    METHODS is_empty_column
      IMPORTING name          TYPE lvc_fname
      RETURNING VALUE(result) TYPE abap_bool.

    METHODS apply_column
      IMPORTING columns TYPE REF TO cl_salv_columns_table
                change  TYPE column_change
      RAISING   zcx_salvage_error.

    METHODS column_of
      IMPORTING columns       TYPE REF TO cl_salv_columns_table
                name          TYPE lvc_fname
      RETURNING VALUE(result) TYPE REF TO cl_salv_column_table
      RAISING   zcx_salvage_error.

    METHODS apply_column_texts
      IMPORTING column   TYPE REF TO cl_salv_column_table
                settings TYPE column_settings.

    METHODS apply_column_visibility
      IMPORTING column   TYPE REF TO cl_salv_column_table
                settings TYPE column_settings.

    METHODS apply_column_kind
      IMPORTING column   TYPE REF TO cl_salv_column_table
                settings TYPE column_settings.

    METHODS cell_type_of
      IMPORTING settings      TYPE column_settings
      RETURNING VALUE(result) TYPE salv_de_celltype.

    METHODS apply_column_format
      IMPORTING column   TYPE REF TO cl_salv_column_table
                settings TYPE column_settings.

    METHODS apply_column_references
      IMPORTING column   TYPE REF TO cl_salv_column_table
                settings TYPE column_settings
      RAISING   zcx_salvage_error.

    METHODS apply_sorts
      RAISING zcx_salvage_error.

    METHODS apply_totals
      RAISING zcx_salvage_error.

    METHODS apply_filters
      RAISING zcx_salvage_error.

    METHODS add_filter_condition
      IMPORTING salv_filters TYPE REF TO cl_salv_filters
                condition    TYPE filter_condition
      RAISING   cx_salv_error.

    METHODS apply_list_texts.

    METHODS form_of
      IMPORTING text          TYPE text_settings
      RETURNING VALUE(result) TYPE REF TO cl_salv_form_layout_grid.

    METHODS raise_unknown_column
      IMPORTING name     TYPE lvc_fname
                previous TYPE REF TO cx_root
      RAISING   zcx_salvage_error.

    METHODS apply_selection
      RAISING zcx_salvage_error.

    METHODS salv_selection_mode
      RETURNING VALUE(result) TYPE i
      RAISING   zcx_salvage_error.

    METHODS apply_layout.

    METHODS apply_functions
      RAISING zcx_salvage_error.

    METHODS add_container_buttons
      IMPORTING functions TYPE REF TO cl_salv_functions_list
      RAISING   zcx_salvage_error.

    METHODS hide_unused_slots
      IMPORTING functions TYPE REF TO cl_salv_functions_list.

    METHODS apply_popup.

    METHODS register_handler.

    METHODS show.

    METHODS show_fullscreen.

    METHODS fullscreen_texts
      RETURNING VALUE(result) TYPE function_slot_texts.

    METHODS slot_text
      IMPORTING slot          TYPE i
      RETURNING VALUE(result) TYPE rsfunc_txt.

    METHODS slot_functions
      RETURNING VALUE(result) TYPE function_names.

    METHODS button_name
      IMPORTING function      TYPE salv_de_function
      RETURNING VALUE(result) TYPE salv_de_function.

    METHODS on_salv_double_click
      FOR EVENT double_click OF cl_salv_events_table
      IMPORTING row column.

    METHODS on_salv_link_click
      FOR EVENT link_click OF cl_salv_events_table
      IMPORTING row column.

    METHODS on_salv_added_function
      FOR EVENT added_function OF cl_salv_events_table
      IMPORTING e_salv_function.
ENDCLASS.


CLASS zcl_salvage IMPLEMENTATION.
  METHOD create.
    result = NEW #( ).
    result->table   = table.
    result->program = sy-cprog.
    result->output  = output_modes-fullscreen.
  ENDMETHOD.

  METHOD layout_f4.
    DATA(layout_key) = VALUE salv_s_layout_key( report = sy-cprog
                                                handle = handle ).
    DATA(picked) = cl_salv_layout_service=>f4_layouts( s_key  = layout_key
                                                       layout = current ).
    result = COND #( WHEN picked-layout IS INITIAL THEN current ELSE picked-layout ).
  ENDMETHOD.

  METHOD title.
    header_text = text.
    self = me.
  ENDMETHOD.

  METHOD striped.
    is_striped = abap_true.
    self = me.
  ENDMETHOD.

  METHOD optimized.
    is_optimized = abap_true.
    self = me.
  ENDMETHOD.

  METHOD column.
    INSERT VALUE #( name     = to_upper( name )
                    settings = settings ) INTO TABLE changed_columns.
    self = me.
  ENDMETHOD.

  METHOD sort_by.
    INSERT VALUE #( name     = to_upper( name )
                    settings = settings ) INTO TABLE sorts.
    self = me.
  ENDMETHOD.

  METHOD total.
    INSERT VALUE #( name = to_upper( name )
                    kind = kind ) INTO TABLE totals.
    self = me.
  ENDMETHOD.

  METHOD filter_by.
    INSERT VALUE #( name     = to_upper( name )
                    settings = settings ) INTO TABLE filters.
    self = me.
  ENDMETHOD.

  METHOD colors_from.
    color_column = to_upper( name ).
    self = me.
  ENDMETHOD.

  METHOD lights_from.
    light_column = to_upper( name ).
    self = me.
  ENDMETHOD.

  METHOD hide_empty_columns.
    hides_empty_columns = abap_true.
    self = me.
  ENDMETHOD.

  METHOD top_of_list.
    top_text = settings.
    self = me.
  ENDMETHOD.

  METHOD end_of_list.
    end_text = settings.
    self = me.
  ENDMETHOD.

  METHOD layout.
    layout_options = settings.
    self = me.
  ENDMETHOD.

  METHOD selection.
    row_selection = mode.
    self = me.
  ENDMETHOD.

  METHOD button.
    INSERT VALUE #( name     = name
                    settings = settings ) INTO TABLE buttons.
    self = me.
  ENDMETHOD.

  METHOD handled_by.
    me->handler = handler.
    self = me.
  ENDMETHOD.

  METHOD popup.
    output = output_modes-popup.
    popup_area = COND #( WHEN settings IS INITIAL THEN default_popup ELSE settings ).
    self = me.
  ENDMETHOD.

  METHOD in_container.
    output = output_modes-container.
    me->container = container.
    self = me.
  ENDMETHOD.

  METHOD display.
    check_configuration( ).
    salv = new_salv( ).
    apply_settings( ).
    register_handler( ).
    is_displayed = abap_true.
    show( ).
  ENDMETHOD.

  METHOD selected_rows.
    IF salv IS BOUND.
      result = salv->get_selections( )->get_selected_rows( ).
    ENDIF.
  ENDMETHOD.

  METHOD refresh.
    IF salv IS BOUND.
      salv->refresh( s_stable = VALUE #( row = abap_true
                                         col = abap_true ) ).
    ENDIF.
  ENDMETHOD.

  METHOD check_configuration.
    IF is_displayed = abap_true.
      RAISE EXCEPTION TYPE zcx_salvage_error MESSAGE e009(zsalvage).
    ENDIF.
    IF is_standard_table( ) = abap_false.
      RAISE EXCEPTION TYPE zcx_salvage_error MESSAGE e011(zsalvage).
    ENDIF.
    check_buttons( ).
  ENDMETHOD.

  METHOD is_standard_table.
    IF table IS NOT BOUND.
      RETURN.
    ENDIF.
    DATA(description) = cl_abap_typedescr=>describe_by_data_ref( table ).
    IF description IS INSTANCE OF cl_abap_tabledescr.
      result = xsdbool( CAST cl_abap_tabledescr( description )->table_kind = cl_abap_tabledescr=>tablekind_std ).
    ENDIF.
  ENDMETHOD.

  METHOD check_buttons.
    DATA names TYPE HASHED TABLE OF salv_de_function WITH UNIQUE KEY table_line.

    IF buttons IS NOT INITIAL AND output = output_modes-popup.
      RAISE EXCEPTION TYPE zcx_salvage_error MESSAGE e007(zsalvage).
    ENDIF.
    IF lines( buttons ) > gui-slots AND output = output_modes-fullscreen.
      RAISE EXCEPTION TYPE zcx_salvage_error MESSAGE e006(zsalvage) WITH gui-slots.
    ENDIF.
    LOOP AT buttons INTO DATA(entry).
      INSERT entry-name INTO TABLE names.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_salvage_error MESSAGE e008(zsalvage) WITH entry-name.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD new_salv.
    " The ALV sorts the rows of the table itself, so it gets the caller's table, not a copy
    FIELD-SYMBOLS <rows> TYPE STANDARD TABLE.

    ASSIGN table->* TO <rows>.
    ASSERT sy-subrc = 0.
    TRY.
        IF output = output_modes-container.
          cl_salv_table=>factory( EXPORTING r_container  = container
                                  IMPORTING r_salv_table = result
                                  CHANGING  t_table      = <rows> ).
        ELSE.
          cl_salv_table=>factory( IMPORTING r_salv_table = result
                                  CHANGING  t_table      = <rows> ).
        ENDIF.
      CATCH cx_salv_msg INTO DATA(error).
        RAISE EXCEPTION TYPE zcx_salvage_error MESSAGE e002(zsalvage) EXPORTING previous = error.
    ENDTRY.
  ENDMETHOD.

  METHOD apply_settings.
    apply_display_settings( ).
    apply_columns( ).
    apply_sorts( ).
    apply_totals( ).
    apply_filters( ).
    apply_selection( ).
    apply_layout( ).
    apply_functions( ).
    apply_list_texts( ).
    apply_popup( ).
  ENDMETHOD.

  METHOD apply_display_settings.
    DATA(display_settings) = salv->get_display_settings( ).
    IF header_text IS NOT INITIAL.
      display_settings->set_list_header( CONV #( header_text ) ).
    ENDIF.
    IF is_striped = abap_true.
      display_settings->set_striped_pattern( abap_true ).
    ENDIF.
  ENDMETHOD.

  METHOD apply_columns.
    DATA(salv_columns) = salv->get_columns( ).
    IF is_optimized = abap_true.
      salv_columns->set_optimize( ).
    ENDIF.
    apply_default_texts( salv_columns ).
    apply_color_column( salv_columns ).
    apply_light_column( salv_columns ).
    apply_empty_columns( salv_columns ).
    LOOP AT changed_columns INTO DATA(change).
      apply_column( columns = salv_columns
                    change  = change ).
    ENDLOOP.
  ENDMETHOD.

  METHOD apply_default_texts.
    " A component typed without a data element has no header; its name is better than none
    LOOP AT columns->get( ) INTO DATA(entry).
      IF entry-r_column->get_short_text( ) IS INITIAL
          AND entry-r_column->get_medium_text( ) IS INITIAL
          AND entry-r_column->get_long_text( ) IS INITIAL.
        entry-r_column->set_short_text( CONV #( entry-columnname ) ).
        entry-r_column->set_medium_text( CONV #( entry-columnname ) ).
        entry-r_column->set_long_text( CONV #( entry-columnname ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD apply_color_column.
    IF color_column IS INITIAL.
      RETURN.
    ENDIF.
    TRY.
        columns->set_color_column( color_column ).
      CATCH cx_salv_data_error INTO DATA(color_error).
        RAISE EXCEPTION TYPE zcx_salvage_error MESSAGE e013(zsalvage) WITH color_column
          EXPORTING previous = color_error.
    ENDTRY.
  ENDMETHOD.

  METHOD apply_light_column.
    IF light_column IS INITIAL.
      RETURN.
    ENDIF.
    TRY.
        columns->set_exception_column( light_column ).
      CATCH cx_salv_data_error INTO DATA(light_error).
        RAISE EXCEPTION TYPE zcx_salvage_error MESSAGE e015(zsalvage) WITH light_column
          EXPORTING previous = light_error.
    ENDTRY.
  ENDMETHOD.

  METHOD apply_empty_columns.
    IF hides_empty_columns = abap_false.
      RETURN.
    ENDIF.
    LOOP AT columns->get( ) INTO DATA(entry).
      IF is_empty_column( entry-columnname ) = abap_true.
        entry-r_column->set_visible( abap_false ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_empty_column.
    FIELD-SYMBOLS <rows> TYPE STANDARD TABLE.

    ASSIGN table->* TO <rows>.
    ASSERT sy-subrc = 0.
    " Without rows every column would count as empty, and the list would have none left
    result = xsdbool( <rows> IS NOT INITIAL ).
    LOOP AT <rows> ASSIGNING FIELD-SYMBOL(<row>).
      ASSIGN COMPONENT name OF STRUCTURE <row> TO FIELD-SYMBOL(<value>).
      IF sy-subrc <> 0 OR <value> IS NOT INITIAL.
        result = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD apply_column.
    DATA(salv_column) = column_of( columns = columns
                                   name    = change-name ).
    apply_column_texts( column   = salv_column
                        settings = change-settings ).
    apply_column_visibility( column   = salv_column
                             settings = change-settings ).
    apply_column_kind( column   = salv_column
                       settings = change-settings ).
    apply_column_format( column   = salv_column
                         settings = change-settings ).
    apply_column_references( column   = salv_column
                             settings = change-settings ).
    IF change-settings-position > 0.
      columns->set_column_position( columnname = change-name
                                    position   = change-settings-position ).
    ENDIF.
  ENDMETHOD.

  METHOD column_of.
    TRY.
        result = CAST #( columns->get_column( name ) ).
      CATCH cx_salv_not_found INTO DATA(not_found).
        raise_unknown_column( name     = name
                              previous = not_found ).
    ENDTRY.
  ENDMETHOD.

  METHOD apply_column_texts.
    IF settings-text IS NOT INITIAL.
      column->set_short_text( CONV #( settings-text ) ).
      column->set_medium_text( CONV #( settings-text ) ).
      column->set_long_text( CONV #( settings-text ) ).
    ENDIF.
    IF settings-tooltip IS NOT INITIAL.
      column->set_tooltip( CONV #( settings-tooltip ) ).
    ENDIF.
  ENDMETHOD.

  METHOD apply_column_visibility.
    IF settings-width > 0.
      column->set_output_length( CONV #( settings-width ) ).
    ENDIF.
    IF settings-is_hidden = abap_true.
      column->set_visible( abap_false ).
    ENDIF.
    IF settings-is_technical = abap_true.
      column->set_technical( abap_true ).
    ENDIF.
  ENDMETHOD.

  METHOD apply_column_kind.
    IF settings-is_key = abap_true.
      column->set_key( ).
    ENDIF.
    IF settings-is_icon = abap_true.
      column->set_icon( ).
    ENDIF.
    DATA(cell_type) = cell_type_of( settings ).
    IF cell_type <> if_salv_c_cell_type=>text.
      column->set_cell_type( cell_type ).
    ENDIF.
  ENDMETHOD.

  METHOD cell_type_of.
    result = COND #( WHEN settings-is_checkbox = abap_true AND settings-is_hotspot = abap_true
                     THEN if_salv_c_cell_type=>checkbox_hotspot
                     WHEN settings-is_checkbox = abap_true
                     THEN if_salv_c_cell_type=>checkbox
                     WHEN settings-is_hotspot = abap_true
                     THEN if_salv_c_cell_type=>hotspot
                     ELSE if_salv_c_cell_type=>text ).
  ENDMETHOD.

  METHOD apply_column_format.
    IF settings-is_zero_hidden = abap_true.
      column->set_zero( abap_false ).
    ENDIF.
    IF settings-edit_mask IS NOT INITIAL.
      column->set_edit_mask( settings-edit_mask ).
    ENDIF.
    IF settings-color IS NOT INITIAL.
      column->set_color( settings-color ).
    ENDIF.
  ENDMETHOD.

  METHOD apply_column_references.
    DATA reference TYPE lvc_fname.

    TRY.
        IF settings-unit_column IS NOT INITIAL.
          reference = to_upper( settings-unit_column ).
          column->set_quantity_column( reference ).
        ENDIF.
        IF settings-currency_column IS NOT INITIAL.
          reference = to_upper( settings-currency_column ).
          column->set_currency_column( reference ).
        ENDIF.
      CATCH cx_salv_not_found cx_salv_data_error INTO DATA(reference_error).
        RAISE EXCEPTION TYPE zcx_salvage_error MESSAGE e014(zsalvage)
          WITH column->get_columnname( ) reference
          EXPORTING previous = reference_error.
    ENDTRY.
  ENDMETHOD.

  METHOD apply_sorts.
    DATA(salv_sorts) = salv->get_sorts( ).
    LOOP AT sorts INTO DATA(criterion).
      TRY.
          salv_sorts->add_sort( columnname = criterion-name
                                subtotal   = criterion-settings-has_subtotals ).
        CATCH cx_salv_not_found INTO DATA(not_found).
          raise_unknown_column( name     = criterion-name
                                previous = not_found ).
        CATCH cx_salv_existing cx_salv_data_error INTO DATA(sort_error).
          RAISE EXCEPTION TYPE zcx_salvage_error MESSAGE e003(zsalvage) WITH criterion-name
            EXPORTING previous = sort_error.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD apply_totals.
    DATA(aggregations) = salv->get_aggregations( ).
    LOOP AT totals INTO DATA(column_total).
      TRY.
          aggregations->add_aggregation( columnname  = column_total-name
                                         aggregation = column_total-kind ).
        CATCH cx_salv_not_found INTO DATA(not_found).
          raise_unknown_column( name     = column_total-name
                                previous = not_found ).
        CATCH cx_salv_data_error cx_salv_existing INTO DATA(total_error).
          RAISE EXCEPTION TYPE zcx_salvage_error MESSAGE e004(zsalvage) WITH column_total-name
            EXPORTING previous = total_error.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD apply_filters.
    DATA(salv_filters) = salv->get_filters( ).
    LOOP AT filters INTO DATA(condition).
      TRY.
          add_filter_condition( salv_filters = salv_filters
                                condition    = condition ).
        CATCH cx_salv_not_found INTO DATA(not_found).
          raise_unknown_column( name     = condition-name
                                previous = not_found ).
        CATCH cx_salv_error INTO DATA(filter_error).
          RAISE EXCEPTION TYPE zcx_salvage_error MESSAGE e012(zsalvage) WITH condition-name
            EXPORTING previous = filter_error.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD add_filter_condition.
    DATA(sign) = COND salv_de_selopt_sign( WHEN condition-settings-is_excluded = abap_true
                                           THEN filter_values-excluding
                                           ELSE filter_values-including ).
    DATA(option) = COND salv_de_selopt_option( WHEN condition-settings-option IS INITIAL
                                               THEN filter_values-default_option
                                               ELSE condition-settings-option ).
    TRY.
        salv_filters->add_filter( columnname = condition-name
                                  sign       = sign
                                  option     = option
                                  low        = condition-settings-low
                                  high       = condition-settings-high ).
      CATCH cx_salv_existing.
        " A further condition for the same column joins its filter, as in a ranges table
        salv_filters->get_filter( condition-name )->add_selopt( sign   = sign
                                                                option = option
                                                                low    = condition-settings-low
                                                                high   = condition-settings-high ).
    ENDTRY.
  ENDMETHOD.

  METHOD apply_list_texts.
    IF top_text IS NOT INITIAL.
      salv->set_top_of_list( form_of( top_text ) ).
    ENDIF.
    IF end_text IS NOT INITIAL.
      salv->set_end_of_list( form_of( end_text ) ).
    ENDIF.
  ENDMETHOD.

  METHOD form_of.
    DATA(row) = 0.

    result = NEW #( ).
    IF text-heading IS NOT INITIAL.
      row = row + 1.
      result->create_label( row    = row
                            column = text_form_column
                            text   = text-heading ).
    ENDIF.
    LOOP AT text-lines INTO DATA(line).
      row = row + 1.
      result->create_text( row    = row
                           column = text_form_column
                           text   = line ).
    ENDLOOP.
  ENDMETHOD.

  METHOD raise_unknown_column.
    RAISE EXCEPTION TYPE zcx_salvage_error MESSAGE e001(zsalvage) WITH name
      EXPORTING previous = previous.
  ENDMETHOD.

  METHOD apply_selection.
    IF row_selection IS NOT INITIAL.
      salv->get_selections( )->set_selection_mode( salv_selection_mode( ) ).
    ENDIF.
  ENDMETHOD.

  METHOD salv_selection_mode.
    CASE row_selection.
      WHEN selection_modes-single.
        result = if_salv_c_selection_mode=>single.
      WHEN selection_modes-multiple.
        result = if_salv_c_selection_mode=>row_column.
      WHEN selection_modes-cells.
        result = if_salv_c_selection_mode=>cell.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_salvage_error MESSAGE e010(zsalvage) WITH row_selection.
    ENDCASE.
  ENDMETHOD.

  METHOD apply_layout.
    DATA(salv_layout) = salv->get_layout( ).
    salv_layout->set_key( VALUE #( report = program
                                   handle = layout_options-handle ) ).
    IF layout_options-is_save_disabled = abap_false.
      " The default of SET_SAVE_RESTRICTION allows user-specific and global layouts
      salv_layout->set_save_restriction( ).
      salv_layout->set_default( abap_true ).
    ENDIF.
    IF layout_options-name IS NOT INITIAL.
      salv_layout->set_initial_layout( layout_options-name ).
    ENDIF.
  ENDMETHOD.

  METHOD apply_functions.
    IF buttons IS NOT INITIAL AND output = output_modes-fullscreen.
      salv->set_screen_status( report   = gui-program
                               pfstatus = gui-status ).
    ENDIF.
    " Switched on here instead of through SET_SCREEN_STATUS: its constants for this are not
    " classified as classic API
    DATA(functions) = salv->get_functions( ).
    functions->set_all( ).
    CASE output.
      WHEN output_modes-fullscreen.
        hide_unused_slots( functions ).
      WHEN output_modes-container.
        add_container_buttons( functions ).
    ENDCASE.
  ENDMETHOD.

  METHOD add_container_buttons.
    LOOP AT buttons INTO DATA(entry).
      TRY.
          functions->add_function( name     = entry-name
                                   icon     = CONV #( entry-settings-icon )
                                   text     = entry-settings-text
                                   tooltip  = entry-settings-tooltip
                                   position = if_salv_c_function_position=>right_of_salv_functions ).
        CATCH cx_salv_existing cx_salv_wrong_call INTO DATA(function_error).
          RAISE EXCEPTION TYPE zcx_salvage_error MESSAGE e005(zsalvage) WITH entry-name
            EXPORTING previous = function_error.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD hide_unused_slots.
    IF buttons IS INITIAL.
      RETURN.
    ENDIF.
    DATA(all_slots) = slot_functions( ).
    DATA(salv_functions) = functions->get_functions( ).
    LOOP AT salv_functions INTO DATA(entry).
      DATA(name) = CONV salv_de_function( entry-r_function->get_name( ) ).
      IF line_index( all_slots[ table_line = name ] ) > lines( buttons ).
        entry-r_function->set_visible( abap_false ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD apply_popup.
    IF output = output_modes-popup.
      salv->set_screen_popup( start_column = popup_area-start_column
                              end_column   = popup_area-end_column
                              start_line   = popup_area-start_line
                              end_line     = popup_area-end_line ).
    ENDIF.
  ENDMETHOD.

  METHOD register_handler.
    IF handler IS BOUND.
      SET HANDLER on_salv_double_click on_salv_link_click on_salv_added_function FOR salv->get_event( ).
    ENDIF.
  ENDMETHOD.

  METHOD show.
    IF output = output_modes-fullscreen.
      show_fullscreen( ).
    ELSE.
      salv->display( ).
    ENDIF.
  ENDMETHOD.

  METHOD show_fullscreen.
    " An event handler may show another fullscreen list while this one is open; its button
    " texts must not stay when the user comes back here
    DATA(texts_of_outer_list) = slot_texts.
    slot_texts = fullscreen_texts( ).
    salv->display( ).
    slot_texts = texts_of_outer_list.
  ENDMETHOD.

  METHOD fullscreen_texts.
    result = VALUE #( f01 = slot_text( 1 )
                      f02 = slot_text( 2 )
                      f03 = slot_text( 3 )
                      f04 = slot_text( 4 )
                      f05 = slot_text( 5 )
                      f06 = slot_text( 6 )
                      f07 = slot_text( 7 )
                      f08 = slot_text( 8 )
                      f09 = slot_text( 9 )
                      f10 = slot_text( 10 ) ).
  ENDMETHOD.

  METHOD slot_text.
    IF slot > lines( buttons ).
      RETURN.
    ENDIF.
    DATA(settings) = buttons[ slot ]-settings.
    DATA(dynamic_text) = VALUE smp_dyntxt( text      = settings-text
                                           icon_id   = settings-icon
                                           icon_text = settings-text
                                           quickinfo = settings-tooltip ).
    " Dynamic function texts are character fields laid out like SMP_DYNTXT
    result = dynamic_text.
  ENDMETHOD.

  METHOD slot_functions.
    result = VALUE #( FOR slot = 1 UNTIL slot > gui-slots
                      ( |{ gui-slot_prefix }{ CONV slot_number( slot ) }| ) ).
  ENDMETHOD.

  METHOD button_name.
    " A fullscreen list reports its own buttons by slot, SALVAGE01 to SALVAGE10
    DATA(all_slots) = slot_functions( ).
    DATA(slot) = line_index( all_slots[ table_line = function ] ).
    result = COND #( WHEN output = output_modes-fullscreen AND slot > 0 AND slot <= lines( buttons )
                     THEN buttons[ slot ]-name
                     ELSE function ).
  ENDMETHOD.

  METHOD on_salv_double_click.
    handler->on_double_click( row    = row
                              column = column ).
  ENDMETHOD.

  METHOD on_salv_link_click.
    handler->on_link_click( row    = row
                            column = column ).
  ENDMETHOD.

  METHOD on_salv_added_function.
    handler->on_button_click( button_name( e_salv_function ) ).
  ENDMETHOD.
ENDCLASS.

