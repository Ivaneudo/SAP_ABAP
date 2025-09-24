REPORT ZALV_003_1.

DATA: lt_alvdados   TYPE STANDARD TABLE OF ZVENDAS_ALV_003, " Tabela criado com o TYPE de uma estrutura global
      wa_alvdados   TYPE ZVENDAS_ALV_003.          " Work area para peencher

DATA: lt_fieldcat   TYPE slis_t_fieldcat_alv, " Tabela interna do fieldcat
      wa_fieldcat   TYPE slis_fieldcat_alv,   " Work area para preencher
      gs_layout     TYPE slis_layout_alv.

INCLUDE: <icon>.

TABLES: ZVENDAS_003, ZPRODUTOS_003.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text1.
   SELECT-OPTIONS: l_cvenda FOR ZVENDAS_003-venda,
                   l_prod   FOR ZPRODUTOS_003-produto,
                   l_data   FOR SY-DATUM,
                   l_quant  FOR ZVENDAS_003-quantidade.
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text2.
   PARAMETERS: p_list RADIOBUTTON GROUP rb2 DEFAULT 'X',
               p_grid RADIOBUTTON GROUP rb2.
SELECTION-SCREEN END OF BLOCK b2.

FORM ALV_SELECT.
    SELECT
      v~venda,
      v~data,
      v~hora,
      v~item,
      v~produto,
      p~desc_produto,
      v~quantidade,
      v~unidade,
      v~preco            AS preco_vendas,
      p~preco            AS preco_produto,
      v~moeda
      FROM ZVENDAS_003 AS v INNER JOIN ZPRODUTOS_003 AS p
      ON v~produto = p~produto
      INTO CORRESPONDING FIELDS OF TABLE @lt_alvdados
      WHERE
        venda       IN @l_cvenda AND
        v~produto   IN @l_prod   AND
        v~data      IN @l_data   AND
        quantidade  IN @l_quant.


     SORT lt_alvdados BY venda.
     IF lt_alvdados IS NOT INITIAL.
       FIELD-SYMBOLS <fs_alvdados> TYPE ZVENDAS_ALV_003.
       LOOP AT lt_alvdados ASSIGNING <fs_alvdados>.

         <fs_alvdados>-preco_tvendas = <fs_alvdados>-quantidade * <fs_alvdados>-preco_vendas.

         IF <fs_alvdados>-preco_vendas > <fs_alvdados>-preco_produto.
           <fs_alvdados>-icon = ICON_GREEN_LIGHT.
         ELSEIF <fs_alvdados>-preco_vendas = <fs_alvdados>-preco_produto.
           <fs_alvdados>-icon = ICON_YELLOW_LIGHT.
         ELSE.
           <fs_alvdados>-icon = ICON_RED_LIGHT.
         ENDIF.
       ENDLOOP.
     ENDIF.
ENDFORM.

 FORM alv_type.
   PERFORM alv_fildcat.

   IF lt_alvdados IS INITIAL.
     MESSAGE 'Nenhum dado encontrado!' TYPE 'S' DISPLAY LIKE 'E'.
     EXIT.
   ENDIF.

   IF p_list = 'X'.
     CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
       EXPORTING
         i_callback_program       = sy-repid
         i_callback_user_command  = 'ALV_USER_COMMAND'
         i_callback_pf_status_set = 'ALV_PF_STATUS_SET'
         it_fieldcat              = lt_fieldcat
         i_save                   = 'A'
         is_layout                = gs_layout
       TABLES
         t_outtab                 = lt_alvdados
       EXCEPTIONS
         program_error            = 1
         OTHERS                   = 2.

     IF sy-subrc <> 0.
       MESSAGE 'Erro ao exibir ALV' TYPE 'S' DISPLAY LIKE 'E'.
     ENDIF.
   ENDIF.

   IF p_grid = 'X'.
     CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
       EXPORTING
         i_callback_program       = sy-repid
         i_callback_user_command  = 'ALV_USER_COMMAND'
         i_callback_pf_status_set = 'ALV_PF_STATUS_SET'
         it_fieldcat              = lt_fieldcat
         i_save                   = 'A'
         is_layout                = gs_layout
       TABLES
         t_outtab                 = lt_alvdados
       EXCEPTIONS
         program_error            = 1
         OTHERS                   = 2.

     IF sy-subrc <> 0.
       MESSAGE 'Erro ao exibir ALV' TYPE 'S' DISPLAY LIKE 'E'.
     ELSE.
       MESSAGE 'Selecione o tipo de ALV você deseja visualizar.' TYPE 'S' DISPLAY LIKE 'E'.
     ENDIF.
   ENDIF.
 ENDFORM.

 FORM alv_PF_STATUS_SET USING extab TYPE slis_t_extab.
   CLEAR extab[].
   SET PF-STATUS 'ZALV_003_1'.
 ENDFORM.



 FORM alv_user_command USING r_ucomm LIKE sy-ucomm rs_selfield TYPE slis_selfield.

   CASE r_ucomm.
     WHEN '&DEL'.
       DATA : resposta TYPE c.
       CLEAR resposta.
       CALL FUNCTION 'POPUP_TO_CONFIRM'
         EXPORTING
           titlebar              = 'Confirmar'
           text_question         = 'Deseja confirmar a alteração?'
           text_button_1         = 'Sim'
           text_button_2         = 'Não'
           default_button        = '2'
           display_cancel_button = ''
         IMPORTING
           answer                = resposta
         EXCEPTIONS
           text_not_found        = 1
           OTHERS                = 2.
       IF resposta = '2'.
         EXIT.
       ENDIF.

       LOOP AT lt_alvdados INTO wa_alvdados.

         IF wa_alvdados-sel =  'X'.
           DATA l_delete TYPE zvendas_alv_003.

           DELETE FROM zvendas_003 WHERE venda = wa_alvdados-venda AND produto = wa_alvdados-produto.
           DELETE lt_alvdados WHERE venda = wa_alvdados-venda AND produto = wa_alvdados-produto.
           MESSAGE 'Linha excluída com sucesso!' TYPE 'S'.

           IF sy-subrc = 0.
           ELSE.
             MESSAGE 'Erro ao excluir do banco de dados.' TYPE 'E'.
           ENDIF.
         ENDIF.


       ENDLOOP.

       rs_selfield-refresh = 'X'.

   ENDCASE.
 ENDFORM.

 FORM alv_fildcat.

   gs_layout-box_fieldname = 'sel'.

   CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
     EXPORTING
       i_program_name         = sy-repid
       i_internal_tabname     = 'LT_ALVDADOS'
       i_structure_name       = 'ZVENDAS_ALV_003'
       i_inclname             = sy-repid
     CHANGING
       ct_fieldcat            = lt_fieldcat
     EXCEPTIONS
       inconsistent_interface = 1
       program_error          = 2
       OTHERS                 = 3.

   LOOP AT lt_fieldcat ASSIGNING FIELD-SYMBOL(<wa_fieldcat>).
     CASE <wa_fieldcat>-col_pos.
       WHEN 1.
         <wa_fieldcat>-outputlen = 12.
         <wa_fieldcat>-seltext_s = 'Status'.
         <wa_fieldcat>-seltext_m = 'Status'.
         <wa_fieldcat>-seltext_l = 'Status'.

       WHEN 2.
         <wa_fieldcat>-outputlen = 12.
         <wa_fieldcat>-seltext_s = 'Cód. Venda'.
         <wa_fieldcat>-seltext_m = 'Código da Venda'.
         <wa_fieldcat>-seltext_l = 'Código da Venda'.

       WHEN 3.
         <wa_fieldcat>-outputlen = 15.
         <wa_fieldcat>-seltext_s = 'Item'.
         <wa_fieldcat>-seltext_m = 'Item'.
         <wa_fieldcat>-seltext_l = 'Item'.

       WHEN 12.
         <wa_fieldcat>-outputlen = 20.
         <wa_fieldcat>-seltext_s = 'P. Vendas'.
         <wa_fieldcat>-seltext_m = 'Preço das Vendas'.
         <wa_fieldcat>-seltext_l = 'Preço das Vendas'.

       WHEN 13.
         <wa_fieldcat>-outputlen = 20.
         <wa_fieldcat>-seltext_s = 'P. Produto'.
         <wa_fieldcat>-seltext_m = 'Preço do Produto'.
         <wa_fieldcat>-seltext_l = 'Preço do Produto'.

       WHEN 14.
         <wa_fieldcat>-outputlen = 15.
         <wa_fieldcat>-seltext_s = 'P. Total'.
         <wa_fieldcat>-seltext_m = 'Preço do Total'.
         <wa_fieldcat>-seltext_l = 'Preço do Total'.
     ENDCASE.
   ENDLOOP.
 ENDFORM.

 START-OF-SELECTION.
  PERFORM: ALV_SELECT,
           ALV_TYPE.