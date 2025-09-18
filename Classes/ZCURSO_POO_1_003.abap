REPORT ZCURSO_POO_1_003.

INCLUDE: zcurso_poo_1_heranca,
         zcurso_poo_1_polimorfismo,
         zcurso_poo_1_abstrata.

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