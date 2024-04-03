      ******************************************************************
      * Author: Troncoso Leandro
      * Date: 15/03/23
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. VERFECH.
       AUTHOR. TRONCOSO LEANDRO.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       77 WS-AUX                  PIC 9(5).
       77 WS-RESTO                PIC 9(5)V99.
       77 WS-BISIESTO             PIC X.

       LINKAGE SECTION.
       01 LN-FECHA.
          05 LN-DIA               PIC 99.
          05 LN-MES               PIC 99.
          05 LN-ANIO              PIC 9(4).

       01 LN-VALIDAR              PIC X.

       PROCEDURE DIVISION USING LN-FECHA, LN-VALIDAR.

       0100-VALIDAR-FECHA.
           PERFORM 0200-VALIDAR-ANIO
           PERFORM 0300-VALIDAR-BISIESTO
           PERFORM 0400-VALIDAR-MES-DIA.

       0200-VALIDAR-ANIO.
           IF LN-ANIO >= 1900 AND LN-ANIO <= 2030
              NEXT SENTENCE
           ELSE
              PERFORM 0600-VALIDAR-FALLIDO
           END-IF.

       0300-VALIDAR-BISIESTO.
           DIVIDE LN-ANIO BY 4 GIVING WS-AUX REMAINDER WS-RESTO
           IF WS-RESTO = 0 THEN
            DIVIDE LN-ANIO BY 100 GIVING WS-AUX REMAINDER WS-RESTO
            IF WS-RESTO = 0 THEN
             DIVIDE LN-ANIO BY 400 GIVING WS-AUX REMAINDER WS-RESTO
             IF WS-RESTO = 0 THEN
              MOVE 'S' TO WS-BISIESTO
             ELSE
              MOVE 'N' TO WS-BISIESTO
             END-IF
            ELSE
             MOVE 'S' TO WS-BISIESTO
           ELSE
            MOVE 'N' TO WS-BISIESTO
           END-IF.


       0400-VALIDAR-MES-DIA.
           EVALUATE LN-MES
           WHEN 1
            IF LN-DIA <= 31 THEN
               PERFORM 0500-VALIDAR-OK
            END-IF
           WHEN 2
            IF WS-BISIESTO = "S" THEN
               IF LN-DIA <= 29 THEN
                  PERFORM 0500-VALIDAR-OK
               END-IF
            ELSE
               IF LN-DIA <= 28 THEN
                  PERFORM 0500-VALIDAR-OK
               END-IF
            END-IF
           WHEN 3
            IF LN-DIA <= 31 THEN
               PERFORM 0500-VALIDAR-OK
            END-IF
           WHEN 4
            IF LN-DIA <= 30 THEN
               PERFORM 0500-VALIDAR-OK
            END-IF
           WHEN 5
            IF LN-DIA <= 31 THEN
               PERFORM 0500-VALIDAR-OK
            END-IF
           WHEN 6
            IF LN-DIA <= 30 THEN
               PERFORM 0500-VALIDAR-OK
            END-IF
           WHEN 7
            IF LN-DIA <= 31 THEN
               PERFORM 0500-VALIDAR-OK
            END-IF
           WHEN 8
            IF LN-DIA <= 31 THEN
               PERFORM 0500-VALIDAR-OK
            END-IF
           WHEN 9
            IF LN-DIA <= 30 THEN
               PERFORM 0500-VALIDAR-OK
            END-IF
           WHEN 10
            IF LN-DIA <= 31 THEN
               PERFORM 0500-VALIDAR-OK
            END-IF
           WHEN 11
            IF LN-DIA <= 30 THEN
               PERFORM 0500-VALIDAR-OK
            END-IF
           WHEN 12
            IF LN-DIA <= 31 THEN
               PERFORM 0500-VALIDAR-OK
            END-IF
           WHEN OTHER
            PERFORM 0600-VALIDAR-FALLIDO
           END-EVALUATE.

       0500-VALIDAR-OK.
           MOVE 'S' TO LN-VALIDAR
           PERFORM 0700-RETURN-MPGM.

       0600-VALIDAR-FALLIDO.
           MOVE 'N' TO LN-VALIDAR
           PERFORM 0700-RETURN-MPGM.

       0700-RETURN-MPGM.
           EXIT PROGRAM.
