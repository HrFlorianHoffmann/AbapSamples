CLASS zcl_compare_make_range_variant DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF runtime_comparison,
        duration_1 TYPE i,
        duration_2 TYPE i,
        difference TYPE i,
      END OF runtime_comparison.

    CLASS-METHODS compare_range_making
      RETURNING
        VALUE(result) TYPE runtime_comparison.

  PRIVATE SECTION.

    TYPES:
      BEGIN OF structure_type,
        c1  TYPE char32,
        c2  TYPE char32,
        c3  TYPE char32,
        c4  TYPE char32,
        c5  TYPE char32,
        c6  TYPE char32,
        c7  TYPE char32,
        c8  TYPE char32,
        c9  TYPE char32,
        c10 TYPE char32,
        c11  TYPE char32,
        c12  TYPE char32,
        c13  TYPE char32,
        c14  TYPE char32,
        c15  TYPE char32,
        c16  TYPE char32,
        c17  TYPE char32,
        c18  TYPE char32,
        c19  TYPE char32,
        c20 TYPE char32,
      END OF structure_type.

    TYPES table_type TYPE STANDARD TABLE OF structure_type WITH EMPTY KEY.

    TYPES range_type TYPE RANGE OF char32.

    CLASS-METHODS make_range_variant_1
      IMPORTING
        sample        TYPE table_type
        column        TYPE string
      RETURNING
        VALUE(result) TYPE range_type.

    CLASS-METHODS make_range_variant_2
      IMPORTING
        sample        TYPE table_type
        column        TYPE string
      RETURNING
        VALUE(result) TYPE range_type.

ENDCLASS.

CLASS zcl_compare_make_range_variant IMPLEMENTATION.

  METHOD compare_range_making.

    DATA sample TYPE table_type.

    DO 1000000 TIMES.
      INSERT INITIAL LINE INTO TABLE sample.
    ENDDO.

    GET RUN TIME FIELD DATA(start).
    DATA(range_1) =
      make_range_variant_1(
        sample = sample
        column = 'C7' ).
    GET RUN TIME FIELD DATA(end).
    result-duration_1 = end - start.

    GET RUN TIME FIELD start.
    DATA(range_2) =
      make_range_variant_2(
        sample = sample
        column = 'C7' ).
    GET RUN TIME FIELD end.
    result-duration_2 = end - start.

    result-difference = result-duration_2 - result-duration_1.

  ENDMETHOD.

  METHOD make_range_variant_1.

    LOOP AT sample ASSIGNING FIELD-SYMBOL(<row>).

      ASSIGN COMPONENT column
        OF STRUCTURE <row>
        TO FIELD-SYMBOL(<cell>).

      INSERT VALUE #(
          sign = 'I'
          option = 'EQ'
          low = <cell> )
        INTO TABLE result.

    ENDLOOP.

  ENDMETHOD.

  METHOD make_range_variant_2.

    TYPES:
      BEGIN OF narrow_structure_type,
        content TYPE char32,
      END OF narrow_structure_type.

    TYPES narrow_table_type TYPE STANDARD TABLE OF narrow_structure_type WITH EMPTY KEY.

    DATA narrow_table TYPE narrow_table_type.

    DATA(mapping) =
      VALUE cl_abap_corresponding=>mapping_table_value(
        ( kind = cl_abap_corresponding=>mapping_component srcname = column dstname = 'CONTENT' ) ).

    DATA(mover) =
      cl_abap_corresponding=>create_with_value(
        source      = sample
        destination = narrow_table
        mapping     = mapping ).

    mover->execute(
      EXPORTING
        source      = sample
      CHANGING
        destination = narrow_table ).

    LOOP AT narrow_table ASSIGNING FIELD-SYMBOL(<row>).

      INSERT VALUE #(
          sign = 'I'
          option = 'EQ'
          low = <row>-content )
        INTO TABLE result.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
