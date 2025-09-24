REPORT ZCURSO_POO_1_003.

*&----------------------------------------------------------------
*& Classe com herança
*&----------------------------------------------------------------

CLASS pai DEFINITION.
  PUBLIC SECTION.
    METHODS: metodo_pai.
ENDCLASS.

CLASS filho DEFINITION INHERITING FROM pai.
ENDCLASS.

CLASS pai IMPLEMENTATION.
  METHOD metodo_pai.
    WRITE: /'Esse é um metodo do pai!'.
  ENDMETHOD.
ENDCLASS.

*&----------------------------------------------------------------
*& Polimorfismo
*&----------------------------------------------------------------

CLASS mae DEFINITION.
  PUBLIC SECTION.
    METHODS: comprimento.
ENDCLASS.
CLASS filha DEFINITION INHERITING FROM mae.
  PUBLIC SECTION.
    METHODS: comprimento REDEFINITION.
ENDCLASS.

CLASS mae IMPLEMENTATION.
  METHOD: comprimento.
    WRITE: /'Olá pessoal'.
  ENDMETHOD.
ENDCLASS.
CLASS filha IMPLEMENTATION.
  METHOD: comprimento.
    WRITE: /'Iae pessoal.'.
  ENDMETHOD.
ENDCLASS.

*&----------------------------------------------------------------
*& Classe abstrata
*&----------------------------------------------------------------

CLASS trabalhar DEFINITION ABSTRACT.
  PUBLIC SECTION.
    METHODS: trabalhar ABSTRACT.
ENDCLASS.

*&----------------------------------------------------------------
*& Classes usando o methoods da classe abstrata
*&----------------------------------------------------------------

CLASS engenheiro DEFINITION INHERITING FROM trabalhar.
  PUBLIC SECTION.
    METHODS: trabalhar REDEFINITION.
ENDCLASS.
CLASS medico DEFINITION INHERITING FROM trabalhar.
  PUBLIC SECTION.
    METHODS: trabalhar REDEFINITION.
ENDCLASS.

CLASS engenheiro IMPLEMENTATION.
  METHOD: trabalhar.
    WRITE: /'Engenheiro: Planejar a construção da casa.'.
  ENDMETHOD.
ENDCLASS.

CLASS medico IMPLEMENTATION.
  METHOD: trabalhar.
    WRITE: /'Medico: Atende pascente no escritorio'.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.

  DATA: lo_filho      TYPE REF TO filho,
        lo_medico     TYPE REF TO medico,
        lo_engenheiro TYPE REF TO engenheiro,
        lo_mae        TYPE REF TO mae,
        lo_filha      TYPE REF TO filha.

  lo_filho      = new filho( ).
  lo_medico     = new medico( ).
  lo_engenheiro = new engenheiro( ).
  lo_mae        = new mae( ).
  lo_filha      = new filha( ).

  lo_filho->metodo_pai( ).
  lo_medico->trabalhar( ).
  lo_engenheiro->trabalhar( ).
  lo_mae->comprimento( ).
  lo_filha->comprimento( ).