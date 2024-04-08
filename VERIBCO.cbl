       IDENTIFICATION DIVISION.
       PROGRAM-ID. VERIBCO.
       AUTHOR. TRONCOSO LEANDRO.
      **********************************************************
      * Subprograma que verifica si el cbu existe y retorna el *
      * el nombre de la entidad bancaria a la que pertenece.   *
      **********************************************************
       DATA DIVISION.
       WORKING-STORAGE SECTION.
      * VARIABLES DE TRABAJO.
       77 IND-NULL                PIC S9(4) COMP-5.
      * HABILITAMOS VARIABLES DE DB2.
           EXEC SQL INCLUDE SQLCA END-EXEC.
           EXEC SQL INCLUDE TRXBCO END-EXEC.

       LINKAGE SECTION.
       01 LN-CBU.
          05 LN-COD-BCO           PIC 9(3).
          05 FILLER               PIC X(17).

       77 LN-VERIFICAR            PIC X.
          88 LN-VERIFICAR-N       VALUE 'N'.
          88 LN-VERIFICAR-S       VALUE 'S'.

       77 LN-DESC-BCO             PIC X(50).

       PROCEDURE DIVISION USING LN-CBU, LN-VERIFICAR, LN-DESC-BCO.
       0100-PROGRAMA-PRINCIPAL.
           MOVE 'S' TO LN-VERIFICAR
           MOVE 50 TO DESCRIPCION-LEN OF DCLBANCO
           PERFORM 0200-V-FORMATO-NUMERICO
           IF LN-VERIFICAR-S
              PERFORM 0300-V-EXISTENCIA
           END-IF
           PERFORM 0400-RETORNAR-PROGRAMA.

       0200-V-FORMATO-NUMERICO.
           IF LN-CBU IS NOT NUMERIC
              MOVE 'N' TO LN-VERIFICAR
           END-IF.

       0300-V-EXISTENCIA.
           MOVE LN-COD-BCO TO ID-BANCO OF DCLBANCO
           EXEC SQL
                SELECT DESCRIPCION
                INTO :DCLBANCO.DESCRIPCION :IND-NULL
                FROM TRX.BANCO
                WHERE ID_BANCO = :DCLBANCO.ID-BANCO
           END-EXEC.
           IF SQLCODE NOT = 0
              DISPLAY 'ERROR AL BUSCAR EL BANCO, CODESQL: ' SQLCODE
              MOVE 'N' TO LN-VERIFICAR
           END-IF
           IF IND-NULL = -1
              DISPLAY 'BANCO INEXISTENTE'
              MOVE 'N' TO LN-VERIFICAR
           END-IF
           IF LN-VERIFICAR-S
              MOVE DESCRIPCION OF DCLBANCO TO LN-DESC-BCO
           END-IF.

       0400-RETORNAR-PROGRAMA.
           EXIT PROGRAM.
