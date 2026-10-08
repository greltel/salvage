" SALVage demo 01: the smallest report - one table, one title, all defaults.
REPORT zsalvage_demo_01.

CLASS lcl_demo DEFINITION FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS run
      RAISING zcx_salvage_error.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF carrier,
        carrid   TYPE scarr-carrid,
        carrname TYPE scarr-carrname,
        currcode TYPE scarr-currcode,
        url      TYPE scarr-url,
      END OF carrier.
    TYPES carrier_rows TYPE STANDARD TABLE OF carrier WITH EMPTY KEY.

    METHODS read_carriers
      RETURNING VALUE(result) TYPE carrier_rows.
ENDCLASS.


CLASS lcl_demo IMPLEMENTATION.
  METHOD run.
    DATA(carriers) = read_carriers( ).
    zcl_salvage=>create( REF #( carriers ) )->title( TEXT-t01 )->display( ).
  ENDMETHOD.

  METHOD read_carriers.
    " All airlines are wanted; SCARR holds a few dozen rows
    SELECT FROM scarr
      FIELDS carrid, carrname, currcode, url
      ORDER BY carrid
      INTO TABLE @result.                               "#EC CI_NOWHERE
  ENDMETHOD.
ENDCLASS.


START-OF-SELECTION.
  NEW lcl_demo( )->run( ).
