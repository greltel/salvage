" SALVage demo 06: cell selection. Select cells of the columns Capacity and Occupied, whole rows
" with the row selector or whole columns with their header, then the button Sum adds up
" Capacity and Occupied of the selection. A cell selected in several ways counts once.
REPORT zsalvage_demo_06.

DATA carrier_id TYPE s_carr_id.

SELECT-OPTIONS carriers FOR carrier_id.


CLASS lcl_demo DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_salvage_events.

    TYPES carrier_range TYPE RANGE OF s_carr_id.

    METHODS run
      IMPORTING carriers TYPE carrier_range.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF flight,
        carrid   TYPE sflight-carrid,
        connid   TYPE sflight-connid,
        fldate   TYPE sflight-fldate,
        seatsmax TYPE sflight-seatsmax,
        seatsocc TYPE sflight-seatsocc,
      END OF flight.
    TYPES flight_rows TYPE STANDARD TABLE OF flight WITH EMPTY KEY.

    TYPES:
      BEGIN OF seat_sums,
        maximum  TYPE i,
        occupied TYPE i,
      END OF seat_sums.

    TYPES counted_cells TYPE SORTED TABLE OF zcl_salvage=>cell_position WITH UNIQUE KEY row column.

    CONSTANTS sum_button TYPE salv_de_function VALUE 'SUM'.

    CONSTANTS:
      BEGIN OF column,
        seats_maximum  TYPE lvc_fname VALUE 'SEATSMAX',
        seats_occupied TYPE lvc_fname VALUE 'SEATSOCC',
      END OF column.

    CONSTANTS:
      BEGIN OF message_type,
        status TYPE sy-msgty VALUE 'S',
        error  TYPE sy-msgty VALUE 'E',
      END OF message_type.

    DATA flights TYPE flight_rows.
    DATA alv     TYPE REF TO zcl_salvage.

    METHODS read_flights
      IMPORTING carriers TYPE carrier_range.

    METHODS cells_to_count
      IMPORTING cells         TYPE zcl_salvage=>cell_positions
                rows          TYPE zcl_salvage=>row_indexes
                columns       TYPE zcl_salvage=>column_names
      RETURNING VALUE(result) TYPE counted_cells.

    METHODS sum_of
      IMPORTING cells         TYPE counted_cells
      RETURNING VALUE(result) TYPE seat_sums.
ENDCLASS.


CLASS lcl_demo IMPLEMENTATION.
  METHOD run.
    read_flights( carriers ).
    alv = zcl_salvage=>create( REF #( flights )
                     )->title( TEXT-t01
                     )->selection( zcl_salvage=>selection_modes-cells
                     )->button( name     = sum_button
                                settings = VALUE #( text    = TEXT-b01
                                                    icon    = icon_sum
                                                    tooltip = TEXT-q01 )
                     )->handled_by( me ).
    TRY.
        alv->display( ).
      CATCH zcx_salvage_error INTO DATA(error).
        MESSAGE error TYPE message_type-status DISPLAY LIKE message_type-error.
    ENDTRY.
  ENDMETHOD.

  METHOD zif_salvage_events~on_button_click.
    IF button = sum_button.
      DATA(sums) = sum_of( cells_to_count( cells   = alv->selected_cells( )
                                           rows    = alv->selected_rows( )
                                           columns = alv->selected_columns( ) ) ).
      MESSAGE |{ TEXT-m01 } { sums-maximum }, { TEXT-m02 } { sums-occupied }| TYPE message_type-status.
    ENDIF.
  ENDMETHOD.

  METHOD read_flights.
    SELECT FROM sflight
      FIELDS carrid, connid, fldate, seatsmax, seatsocc
      WHERE carrid IN @carriers
      ORDER BY carrid, connid, fldate
      INTO TABLE @flights.
  ENDMETHOD.

  METHOD cells_to_count.
    " The unique key drops a cell that is selected again with its row or its column
    LOOP AT cells INTO DATA(cell) WHERE column = column-seats_maximum
                                     OR column = column-seats_occupied.
      INSERT cell INTO TABLE result.
    ENDLOOP.
    " A row selected as a whole counts with both columns
    LOOP AT rows INTO DATA(row).
      INSERT VALUE #( row = row column = column-seats_maximum ) INTO TABLE result.
      INSERT VALUE #( row = row column = column-seats_occupied ) INTO TABLE result.
    ENDLOOP.
    " A column selected as a whole counts with all rows of the table
    LOOP AT columns INTO DATA(name) WHERE table_line = column-seats_maximum
                                       OR table_line = column-seats_occupied.
      DO lines( flights ) TIMES.
        INSERT VALUE #( row = sy-index column = name ) INTO TABLE result.
      ENDDO.
    ENDLOOP.
  ENDMETHOD.

  METHOD sum_of.
    LOOP AT cells INTO DATA(cell).
      CASE cell-column.
        WHEN column-seats_maximum.
          result-maximum = result-maximum + flights[ cell-row ]-seatsmax.
        WHEN column-seats_occupied.
          result-occupied = result-occupied + flights[ cell-row ]-seatsocc.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.
  NEW lcl_demo( )->run( carriers[] ).
