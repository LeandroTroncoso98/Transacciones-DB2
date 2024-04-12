       IDENTIFICATION DIVISION.
       PROGRAM-ID. PTRXCLI.
       AUTHOR. TRONCOSO LEANDRO.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.

           SELECT FICHERO-ENT ASSIGN TO ENTRADA
           ORGANIZATION IS SEQUENTIAL
           ACCESS IS SEQUENTIAL
           FILE STATUS IS FS-ENTRADA.

           SELECT FICHERO-SAL ASSIGN TO SALIDA
           ORGANIZATION IS SEQUENTIAL
           ACCESS IS SEQUENTIAL
           FILE STATUS IS FS-SALIDA.

       DATA DIVISION.
       FILE SECTION.
       FD FICHERO-SAL RECORDING MODE IS F
                      DATA RECORD IS REG-SALIDA.
       01 REG-SALIDA              PIC X(80).

       FD FICHERO-ENT RECORDING MODE IS F
                      DATA RECORD IS REG-ENTRADA.
       01 REG-ENTRADA.
          05 REG-CBU.
             10 REG-ID-BCO        PIC 9(3).
             10 FILLER            PIC X(19).
       WORKING-STORAGE SECTION.

      * VARIABLE FILE STATUS
       77 FS-SALIDA               PIC 99.
          88 FS-SALIDA-OK         VALUE 00.

       77 FS-ENTRADA              PIC 99.
          88 FS-ENTRADA-OK        VALUE 00.

      * SQL
           EXEC SQL INCLUDE SQLCA END-EXEC.
           EXEC SQL INCLUDE TRXCLI END-EXEC.
           EXEC SQL INCLUDE TRXTRX END-EXEC.
           EXEC SQL INCLUDE TRXBCO END-EXEC.
           EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01 DCLAUX.
          10 CBU-REPORTE          PIC X(22).
           EXEC SQL END DECLARE SECTION
           END-EXEC.

      * MAPEAR REPORTE.
       01 WS-GUIONES.
          05 FILLER               PIC X VALUE SPACE.
          05 FILLER               PIC X(68) VALUE ALL '-'.
          05 FILLER               PIC X VALUE SPACE.

       01 WS-CLIENTE.
          05 FILLER               PIC X VALUE '|'.
          05 FILLER               PIC X VALUE SPACE.
          05 FILLER               PIC X(9) VALUE 'CLIENTE: '.
          05 WS-C-NOMBRE          PIC X(50).
          05 FILLER               PIC X(08) VALUE SPACES.
          05 FILLER               PIC X VALUE '|'.

       01 WS-BANCO.
          05 FILLER               PIC X VALUE '|'.
          05 FILLER               PIC X VALUE SPACE.
          05 FILLER               PIC X(7) VALUE 'BANCO: '.
          05 WS-B-DESCRIPCION     PIC X(50).
          05 FILLER               PIC X(10) VALUE SPACES.
          05 FILLER               PIC X VALUE '|'.

       01 WS-CBU.
          05 FILLER               PIC X VALUE '|'.
          05 FILLER               PIC X VALUE SPACE.
          05 FILLER               PIC X(5) VALUE 'CBU: '.
          05 WS-C-CBU             PIC X(22).
          05 FILLER               PIC X(40) VALUE SPACE.
          05 FILLER               PIC X VALUE '|'.

       01 WS-TITULOS-DATA.
          05 FILLER               PIC X VALUE '|'.
          05 FILLER               PIC X VALUE SPACE.
          05 FILLER               PIC X(6) VALUE 'FECHA:'.
          05 FILLER               PIC X(7) VALUE SPACES.
          05 FILLER               PIC X(6) VALUE 'MONTO:'.
          05 FILLER               PIC X(13) VALUE SPACE.
          05 FILLER               PIC X(7) VALUE 'ACCION:'.
          05 FILLER               PIC X(5) VALUE SPACES.
          05 FILLER               PIC X(10) VALUE 'POR/A CBU:'.
          05 FILLER               PIC X(13) VALUE SPACES.
          05 FILLER               PIC X VALUE '|'.

       01 WS-GUIONES-DATA.
          05 FILLER               PIC X VALUE '|'.
          05 FILLER               PIC X VALUE SPACE.
          05 FILLER               PIC X(10) VALUE ALL '-'.
          05 FILLER               PIC X(3) VALUE SPACES.
          05 FILLER               PIC X(16) VALUE ALL '-'.
          05 FILLER               PIC X(3) VALUE SPACES.
          05 FILLER               PIC X(8) VALUE ALL '-'.
          05 FILLER               PIC X(4) VALUE SPACES.
          05 FILLER               PIC X(22) VALUE ALL '-'.
          05 FILLER               PIC X(1) VALUE SPACES.
          05 FILLER               PIC X VALUE '|'.

       01 WS-DATOS.
          05 FILLER               PIC X VALUE '|'.
          05 FILLER               PIC X VALUE SPACE.
          05 WS-FECHA-TRX.
             10 WS-DIA            PIC 99.
             10 FILLER            PIC X VALUE '-'.
             10 WS-MES            PIC 99.
             10 FILLER            PIC X VALUE '-'.
             10 WS-ANIO           PIC 9999.
          05 FILLER               PIC X(3) VALUE SPACES.
          05 WS-MONTO-TRX         PIC $$$$$$$$$$$$9,99.
          05 FILLER               PIC X(3) VALUE SPACES.
          05 WS-ACCION            PIC X(8).
          05 FILLER               PIC X(4) VALUE SPACES.
          05 WS-CBU-TRX           PIC X(22).
          05 FILLER               PIC X(1) VALUE SPACES.
          05 FILLER               PIC X VALUE '|'.

       01 WS-NOPOSEE-DATOS.
          05 FILLER               PIC X VALUE '|'.
          05 FILLER               PIC X(15) VALUE ALL '*'.
          05 FILLER               PIC X VALUE SPACE.
          05 FILLER               PIC X(35)
                         VALUE 'ESTE CLIENTE NO POSEE TRANSACCIONES'.
          05 FILLER               PIC X VALUE SPACES.
          05 FILLER               PIC X(16) VALUE ALL '*'.
          05 FILLER               PIC X VALUE '|'.

       01 WS-FOOTER.
          05 FILLER               PIC X VALUE '|'.
          05 FILLER               PIC X(22) VALUE SPACES.
          05 FILLER               PIC X(24)
                                  VALUE 'ULTIMAS 10 TRANSACCIONES'.
          05 FILLER               PIC X(22) VALUE SPACES.
          05 FILLER               PIC X VALUE '|'.

      * VARIABLES DE TRABAJO.
       01 WS-FECHA-FORMATO.
          05 WS-FF-FECHA.
             10 WS-FF-ANIO        PIC 9999.
             10 FILLER            PIC X.
             10 WS-FF-MES         PIC 99.
             10 FILLER            PIC X.
             10 WS-FF-DIA         PIC 99.
          05 FILLER               PIC X(16).

      *DECLARAMOS UN CURSOR
           EXEC SQL DECLARE CUR_DB CURSOR FOR
                SELECT DIA_HORA, MONTO, MONTO_TOTAL,
                CBU_EMISOR, CBU_RECEPTOR
                FROM TRX.TRANSACCION
                WHERE CBU_EMISOR = :DCLAUX.CBU-REPORTE
                OR CBU_RECEPTOR = :DCLAUX.CBU-REPORTE
                ORDER BY DIA_HORA DESC
                FETCH FIRST 10 ROWS ONLY
           END-EXEC.

       PROCEDURE DIVISION.
       0100-PROGRAMA-PRINCIPAL.
           PERFORM 0200-INICIAR-PROGRAMA
           READ FICHERO-ENT
           MOVE 22 TO CBU-EMISOR-LEN
           MOVE REG-CBU OF REG-ENTRADA TO CBU-REPORTE OF DCLAUX
           DISPLAY REG-CBU
           PERFORM 0300-VERIFICAR-CBU
           PERFORM 0400-VERIFICAR-CLIENTE
           EXEC SQL OPEN CUR_DB END-EXEC
           EXEC SQL FETCH CUR_DB INTO
                :DCLTRANSACCION.DIA-HORA, :DCLTRANSACCION.MONTO,
                :DCLTRANSACCION.MONTO-TOTAL,
                :DCLTRANSACCION.CBU-EMISOR,
                :DCLTRANSACCION.CBU-RECEPTOR
           END-EXEC
           EVALUATE SQLCODE
           WHEN 0
             PERFORM 0500-ESCRIBIR-TITULO
             PERFORM 0600-PROCESO-PROGRAMA UNTIL SQLCODE = 100
             WRITE REG-SALIDA FROM WS-GUIONES
             WRITE REG-SALIDA FROM WS-FOOTER
             WRITE REG-SALIDA FROM WS-GUIONES
           WHEN 100
             PERFORM 0500-ESCRIBIR-TITULO
             PERFORM 0700-NO-HAY-TRX
           WHEN OTHER
             DISPLAY 'ERROR AL CONSULTAR TRANSACCION, SQLCODE ' SQLCODE
           END-EVALUATE
           PERFORM 0800-CERRAR-ARCHIVOS
           PERFORM 0900-CERRAR-PROGRAMA.

      ***************************************************************
      * ABRIMOS LOS ARCHIVOS DEL PROGRAMA.                          *
      ***************************************************************
       0200-INICIAR-PROGRAMA.
           OPEN INPUT FICHERO-ENT
           DISPLAY 'LEE ENTRADA'
           IF FS-ENTRADA NOT = 0
              DISPLAY 'ERROR ENTRADA'
              PERFORM 0900-CERRAR-PROGRAMA
           END-IF
           OPEN OUTPUT FICHERO-SAL
           DISPLAY 'LEE SALIDA'
           IF FS-SALIDA NOT = 0
              DISPLAY 'ERROR FICH SALIDA'
              CLOSE FICHERO-ENT
              PERFORM 0900-CERRAR-PROGRAMA
           END-IF.


      ***************************************************************
      * VERIFICAMOS SI EL CBU CORRESPONDE A UN BANCO EXISTENTE      *
      * Y RECUPERAMOS EL NOMBRE DE LA ENTIDAD.                      *
      ***************************************************************
       0300-VERIFICAR-CBU.
           IF REG-CBU IS NUMERIC
              MOVE REG-ID-BCO TO ID-BANCO OF DCLBANCO
              EXEC SQL
                   SELECT DESCRIPCION
                   INTO :DCLBANCO.DESCRIPCION
                   FROM TRX.BANCO
                   WHERE ID_BANCO = :DCLBANCO.ID-BANCO
              END-EXEC.
           IF SQLCODE NOT = 0
              DISPLAY 'ERROR AL BUSCAR EL BANCO, SQLCODE:' SQLCODE
              PERFORM 0800-CERRAR-ARCHIVOS
              PERFORM 0900-CERRAR-PROGRAMA
           END-IF
           MOVE DESCRIPCION-TEXT OF DCLBANCO TO WS-B-DESCRIPCION
           DISPLAY WS-B-DESCRIPCION.

      ***************************************************************
      * BUSCAMOS EL CLIENTE EN LA BASE DE DATOS. SI EXISTE,         *
      * LO GUARDAMOS                                                *
      ***************************************************************
       0400-VERIFICAR-CLIENTE.
           DISPLAY 'CBU:' REG-CBU
           MOVE 50 TO NOMBRE-LEN OF DCLCLIENTE
           DISPLAY CBU-REPORTE OF DCLAUX
           EXEC SQL
                SELECT NOMBRE
                INTO :DCLCLIENTE.NOMBRE
                FROM TRX.CLIENTE
                WHERE CBU_CLIENTE = :DCLAUX.CBU-REPORTE
           END-EXEC
           DISPLAY NOMBRE OF DCLCLIENTE
           IF SQLCODE NOT = 0
              DISPLAY 'ERROR BUSCAR CLIENTE, SQLCODE: ' SQLCODE
              PERFORM 0800-CERRAR-ARCHIVOS
              PERFORM 0900-CERRAR-PROGRAMA
           END-IF
           MOVE NOMBRE-TEXT OF DCLCLIENTE TO WS-C-NOMBRE
           MOVE CBU-REPORTE OF DCLAUX TO WS-C-CBU.

      ***************************************************************
      * ESCRIBIMOS EL TITULO DEL REPORTE, QUE POSEE NOMBRE DEL      *
      * CLIENTE, SU BANCO CORRESPONDIENTE Y SU CBU. INCLUIDAS       *
      * LAS CABECERAS DE LOS DATOS.                                 *
      ***************************************************************
       0500-ESCRIBIR-TITULO.
           WRITE REG-SALIDA FROM WS-GUIONES
           WRITE REG-SALIDA FROM WS-CLIENTE
           WRITE REG-SALIDA FROM WS-BANCO
           WRITE REG-SALIDA FROM WS-CBU
           WRITE REG-SALIDA FROM WS-GUIONES
           WRITE REG-SALIDA FROM WS-TITULOS-DATA
           WRITE REG-SALIDA FROM WS-GUIONES-DATA.

      ***************************************************************
      * MOVEMOS LOS DATOS A LAS VARIABLES PARA ESCRIBIRLAS EN EL    *
      * REPORTE, POSTERIORMENTE LEEMOS EL SIGUIENTE REGISTRO DE     *
      * LA BASE DE DATOS.                                           *
      ***************************************************************
       0600-PROCESO-PROGRAMA.
           MOVE DIA-HORA OF DCLTRANSACCION TO WS-FECHA-FORMATO
           MOVE WS-FF-ANIO TO WS-ANIO
           MOVE WS-FF-MES TO WS-MES
           MOVE WS-FF-DIA TO WS-DIA
      * SI EL CBU-EMISOR ES IGUAL A EL CBU SELECCIONADO 
      * SIGNIFICA QUE EL MONTO DE LA TRANSACCION FUE DEBITADA.
      * DE SU CUENTA, POR LO QUE MOSTRAREMOS EL MONTO CON LA COMISION
           IF CBU-EMISOR-TEXT OF DCLTRANSACCION = CBU-REPORTE OF DCLAUX
              MOVE MONTO-TOTAL OF DCLTRANSACCION TO WS-MONTO-TRX
              MOVE 'DEBITA' TO WS-ACCION
              MOVE CBU-RECEPTOR-TEXT OF DCLTRANSACCION TO WS-CBU-TRX
           ELSE
      * SI NO LO ES SIGNIFICA QUE EL MONTO DE LA TRANSACCION
      * FUE ACREDITADA A LA CUENTA DEL CLIENTE POR LO QUE 
      * MOSTRAREMOS UNICAMENTE EL MONTO SIN LA COMISION.
              MOVE MONTO OF DCLTRANSACCION TO WS-MONTO-TRX
              MOVE 'ACREDITA' TO WS-ACCION
              MOVE CBU-EMISOR-TEXT OF DCLTRANSACCION TO WS-CBU-TRX
           END-IF
           WRITE REG-SALIDA FROM WS-DATOS
           EXEC SQL FETCH CUR_DB INTO
                :DCLTRANSACCION.DIA-HORA, :DCLTRANSACCION.MONTO,
                :DCLTRANSACCION.MONTO-TOTAL,
                :DCLTRANSACCION.CBU-EMISOR,
                :DCLTRANSACCION.CBU-RECEPTOR
           END-EXEC.
      ***************************************************************
      * SI EL USUARIO NO POSEE TRANSACCIONES GENERAMOS EL REPORTE   *
      * CON UN MENSAJE INCLUIDO.                                    *
      ***************************************************************
       0700-NO-HAY-TRX.
           WRITE REG-SALIDA FROM WS-NOPOSEE-DATOS
           WRITE REG-SALIDA FROM WS-GUIONES.

       0800-CERRAR-ARCHIVOS.
           EXEC SQL CLOSE CUR_DB END-EXEC
           CLOSE FICHERO-SAL
           CLOSE FICHERO-ENT.
       0900-CERRAR-PROGRAMA.
           STOP RUN.

