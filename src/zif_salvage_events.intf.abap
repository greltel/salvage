"! <p>Reacts to what the user does in a list of {@link zcl_salvage}.</p>
"! <p>Pass the handler with {@link zcl_salvage.METH:handled_by} and implement only the methods
"! you need. Every method is declared DEFAULT IGNORE, so methods you leave out do nothing, and
"! new events can be added to this interface without breaking existing handlers.</p>
INTERFACE zif_salvage_events
  PUBLIC.

  "! The user double-clicked a cell.
  "!
  "! @parameter row    | Index of the row in your table. The list sorts your table itself, so
  "!                     table[ row ] is the row the user sees, also after sorting.
  "! @parameter column | Name of the column the user double-clicked
  METHODS on_double_click DEFAULT IGNORE
    IMPORTING row    TYPE i
              column TYPE lvc_fname.

  "! The user clicked a cell of a hotspot column (see {@link zcl_salvage.METH:column}).
  "!
  "! @parameter row    | Index of the row in your table, as for {@link zif_salvage_events.METH:on_double_click}
  "! @parameter column | Name of the column the user clicked
  METHODS on_link_click DEFAULT IGNORE
    IMPORTING row    TYPE i
              column TYPE lvc_fname.

  "! The user clicked an own button (see {@link zcl_salvage.METH:button}). Read the selected rows
  "! with {@link zcl_salvage.METH:selected_rows}; call {@link zcl_salvage.METH:refresh} after
  "! changing the table.
  "!
  "! @parameter button | Name the button was added with
  METHODS on_button_click DEFAULT IGNORE
    IMPORTING button TYPE salv_de_function.
ENDINTERFACE.
