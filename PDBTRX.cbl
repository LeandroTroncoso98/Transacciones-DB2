       IDENTIFICATION DIVISION.
       PROGRAM-ID. PDBTRX.
       AUTHOR. TRONCOSO LEANDRO.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT FICHERO-ENT ASSIGN TO ENTRADA
           ORGANIZATION IS SEQUENTIAL
           ACCESS MODE IS SEQUENTIAL
           FILE STATUS IS FS-ENTRADA.

           SELECT ERROR-FICH ASSIGN TO SALIDA
           ORGANIZATION IS SEQUENTIAL
           ACCESS MODE IS SEQUENTIAL
           FILE STATUS IS FS-ERROR.

       DATA DIVISION.
       FILE SECTION.
      * REGISTRO DE LAS TRANSACCIONES DE ENTRADA.
       FD FICHERO-ENT RECORDING MODE IS F
                      DATA RECORD IS REG-ENTRADA.
       01 REG-ENTRADA.
          05 FECHA-HORA.
             10 FECHA.
                15 FECHA-ANIO     PIC 9(4).
                15 FILLER         PIC X.
                15 FECHA-MES      PIC 9(2).
                15 FILLER         PIC X.
                15 FECHA-DIA      PIC 9(2).
             10 HORA              PIC X(16).
          05 MONTO                PIC 9(13)V99.
          05 CBU-EMISOR           PIC X(22).
          05 CBU-RECEPTOR         PIC X(22).

      *REGISTRO PARA REGISTRAR LOS ERRORES.
       FD ERROR-FICH RECORDING MODE IS F
                     DATA RECORD IS REG-ERROR.
       01 REG-ERROR.
          05 E-CBU-EMISOR         PIC X(22).
          05 E-CBU-RECEPTOR       PIC X(22).
          05 E-RAZON              PIC X(36).
          05 E-PARRAFO            PIC X(4).

       WORKING-STORAGE SECTION.

      * FILE STATUS DE LOS ARCHIVOS I-O.
       77 FS-ENTRADA              PIC 99.
          88 FS-ENTRADA-END       VALUE 10.

       77 FS-ERROR                PIC 99.

      * VARIABLES DEL PROGRAMA.

       77 WS-ERROR                PIC X VALUE 'N'.
          88 WS-ERROR-N           VALUE 'N'.
          88 WS-ERROR-S           VALUE 'S'.

       77 WS-COMISION             PIC 9(8)V99.
       77 WS-MONTO-TOTAL          PIC 9(13)V99.

       77 IND-NULL                PIC S9(4) COMP-5.

       01 WS-ERROR-NCONTROL.
          05 FILLER               PIC X(29)
                     VALUE 'ERROR NO CONTROLADO, CODIGO: '.
          05 WS-ENC-CODE          PIC -999.

      * SQLCA Y DCLGEN DE LAS TABLAS CLIENTES, TRANSACCIONES
           EXEC SQL INCLUDE SQLCA END-EXEC.
           EXEC SQL INCLUDE TRXCLI END-EXEC.
           EXEC SQL INCLUDE TRXTRX END-EXEC.
      * DECLARAMOS VARIABLES HOST.
           EXEC SQL BEGIN DECLARE SECTION
           END-EXEC.
       01 DCLAUXILIAR.
          10 NUMERO-REG            PIC S9(4) USAGE COMP.
           EXEC SQL END DECLARE SECTION
           END-EXEC.

      * VARIABLES SUB-PROG VERFECH
       77 WS-SVERFECH             PIC X(08) VALUE 'VERFECH'.

       01 WS-FECHA-VER.
          05 WS-FV-DIA            PIC 9(2).
          05 WS-FV-MES            PIC 9(2).
          05 WS-FV-ANIO           PIC 9(4).

       77 WS-VALIDAR              PIC X.
          88 WS-VALIDAR-N         VALUE 'N'.
          88 WS-VALIDAR-S         VALUE 'S'.

       PROCEDURE DIVISION.
       0000-MAIN-PROGRAM.
           PERFORM 1000-INIT-PROGRAM
           READ FICHERO-ENT
           PERFORM 2000-PROCESAMIENTO UNTIL FS-ENTRADA-END
           PERFORM 3000-END-PROGRAM.
      ******************************************************************
      * PARRAFO DE APERTURA DE ARCHIVOS E INICIACION DE VARIABLES.     *
      ******************************************************************
       1000-INIT-PROGRAM.
           INITIALIZE WS-COMISION
           PERFORM 1100-OPEN-ENT
           PERFORM 1200-OPEN-ERROR
           PERFORM 1300-LEN-HOST.

       1100-OPEN-ENT.
           OPEN INPUT FICHERO-ENT
           IF FS-ENTRADA NOT = 00
              PERFORM 3300-STOP-PROGRAM
           END-IF.
       1200-OPEN-ERROR.
           OPEN OUTPUT ERROR-FICH
           IF FS-ERROR NOT = 00
              CLOSE FICHERO-ENT
              PERFORM 3300-STOP-PROGRAM
           END-IF.

       1300-LEN-HOST.
      * LONGITUD DE LAS VARIABLES HOST CLIENTE.
           MOVE 22 TO CBU-CLIENTE-LEN OF DCLCLIENTE
           MOVE 50 TO NOMBRE-LEN OF DCLCLIENTE
           MOVE 40 TO DIRECCION-LEN OF DCLCLIENTE
           MOVE 10 TO TELEFONO-LEN OF DCLCLIENTE
      * LONGITUD DE LAS VARIABLES HOST TRANSACCION.
           MOVE 22 TO CBU-EMISOR-LEN OF DCLTRANSACCION
           MOVE 22 TO CBU-RECEPTOR-LEN OF DCLTRANSACCION.

       2000-PROCESAMIENTO.
           MOVE 'N' TO WS-ERROR
           PERFORM 2100-CBU-EXISTEN
           IF WS-ERROR-N
              PERFORM 2200-VALIDAR-FECHA
           END-IF
           IF WS-ERROR-N
              PERFORM 2300-VERIFICAR-CATEGORIA-SALDO
           END-IF
           IF WS-ERROR-N
             PERFORM 2400-GENERAR-ID-TRX
           END-IF
           IF WS-ERROR-N
             PERFORM 2500-DESCONTAR-SALDO-EMISOR
           END-IF
           IF WS-ERROR-N
             PERFORM 2600-CARGAR-TRX
           END-IF
           IF WS-ERROR-N
             PERFORM 2700-AGREGAR-SALDO-RECEPTOR
           END-IF
           READ FICHERO-ENT.
      *****************************************************************
      * VALIDAMOS QUE EL CBU DE AMBAS PARTES EXISTAN.                 *
      *****************************************************************
       2100-CBU-EXISTEN.
           PERFORM 2110-VERF-EMISOR
           IF WS-ERROR-N
              PERFORM 2120-VERF-RECEPTOR
           END-IF
           IF WS-ERROR-S
              PERFORM 2800-CAMBIAR-DATOS-ERROR
              MOVE 'CBU INEXISTENTE.' TO E-RAZON
              WRITE REG-ERROR
           END-IF.
       2110-VERF-EMISOR.
           MOVE CBU-EMISOR OF REG-ENTRADA
                           TO CBU-CLIENTE-TEXT OF DCLCLIENTE
           DISPLAY CBU-CLIENTE OF DCLCLIENTE
           EXEC SQL
                SELECT SALDO
                INTO :DCLCLIENTE.SALDO :IND-NULL
                FROM TRX.CLIENTE
                WHERE CBU_CLIENTE = :DCLCLIENTE.CBU-CLIENTE
           END-EXEC
           IF SQLCODE NOT = 0
              PERFORM 2800-CAMBIAR-DATOS-ERROR
              MOVE SQLCODE TO WS-ENC-CODE
              MOVE WS-ERROR-NCONTROL TO E-RAZON
              MOVE '2110' TO E-PARRAFO
              MOVE 'S' TO WS-ERROR
              WRITE REG-ERROR
           END-IF
           IF IND-NULL = -1
              MOVE 'S' TO WS-ERROR
           END-IF.

       2120-VERF-RECEPTOR.
           MOVE CBU-RECEPTOR OF REG-ENTRADA
                             TO CBU-CLIENTE-TEXT OF DCLCLIENTE
           DISPLAY CBU-CLIENTE OF DCLCLIENTE
           EXEC SQL
                SELECT COUNT(CBU_CLIENTE)
                INTO :DCLAUXILIAR.NUMERO-REG
                FROM TRX.CLIENTE
                WHERE CBU_CLIENTE = :DCLCLIENTE.CBU-CLIENTE
           END-EXEC
           IF SQLCODE NOT = 0
              PERFORM 2800-CAMBIAR-DATOS-ERROR
              MOVE SQLCODE TO WS-ENC-CODE
              MOVE WS-ERROR-NCONTROL TO E-RAZON
              MOVE '2120' TO E-PARRAFO
              WRITE REG-ERROR
           END-IF
           IF NUMERO-REG = 0
              MOVE 'S' TO WS-ERROR
           END-IF.

      ***************************************************************
      * VALIDAMOS LA FECHA DE LA TRANSACCION                        *
      ***************************************************************
       2200-VALIDAR-FECHA.
           MOVE FECHA-ANIO TO WS-FV-ANIO
           MOVE FECHA-MES TO WS-FV-MES
           MOVE FECHA-DIA TO WS-FV-DIA
           CALL WS-SVERFECH USING WS-FECHA-VER, WS-VALIDAR
           IF WS-VALIDAR-N
              DISPLAY 'FECHA INVALIDA'
              PERFORM 2800-CAMBIAR-DATOS-ERROR
              MOVE 'FECHA INVALIDA' TO E-RAZON
              WRITE REG-ERROR
              MOVE 'S' TO WS-ERROR
           END-IF.


      ***************************************************************
      * VERIFICAMOS LA CATEGORIA Y SI POSEE SALDO SUFICIENTE        *
      ***************************************************************
       2300-VERIFICAR-CATEGORIA-SALDO.
           MOVE ZEROS TO WS-COMISION
           MOVE ZEROS TO WS-MONTO-TOTAL
           MOVE CBU-EMISOR OF REG-ENTRADA
                           TO CBU-CLIENTE-TEXT OF DCLCLIENTE
           EXEC SQL
             SELECT SALDO, CATEGORIA
             INTO :DCLCLIENTE.SALDO, :DCLCLIENTE.CATEGORIA
             FROM TRX.CLIENTE
             WHERE CBU_CLIENTE = :DCLCLIENTE.CBU-CLIENTE
           END-EXEC
           IF SQLCODE NOT = 0
              DISPLAY 'ERROR SQLCODE'
              PERFORM 2800-CAMBIAR-DATOS-ERROR
              MOVE SQLCODE TO WS-ENC-CODE
              MOVE WS-ERROR-NCONTROL TO E-RAZON
              MOVE '2300' TO E-PARRAFO
              WRITE REG-ERROR
              MOVE 'S' TO WS-ERROR
           ELSE
      * VERIFICAMOS LA CATEGORIA DEL CLIENTE: PLATINUM 0.01% DE COMISION
      * POR TRANSACCION, COMUN 0.03% POR TRANSACCION
              EVALUATE CATEGORIA OF DCLCLIENTE
               WHEN 'P'
                  COMPUTE
                     WS-COMISION = MONTO OF REG-ENTRADA * 0.01
                  END-COMPUTE
                  COMPUTE
                     WS-MONTO-TOTAL = MONTO OF REG-ENTRADA + WS-COMISION
                  END-COMPUTE
               WHEN 'C'
                  COMPUTE
                     WS-COMISION = MONTO OF REG-ENTRADA * 0.03
                  END-COMPUTE
                  COMPUTE
                     WS-MONTO-TOTAL = MONTO OF REG-ENTRADA + WS-COMISION
                  END-COMPUTE
               WHEN OTHER
                  DISPLAY 'OTHER'
                  PERFORM 2800-CAMBIAR-DATOS-ERROR
                  MOVE 'CATEGORIA INCORRECTA' TO E-RAZON
                  WRITE REG-ERROR
                  MOVE 'S' TO WS-ERROR
               END-EVALUATE
      * CONSERVAMOS LOS VALORES DE WS-COMISION Y WS-MONTO-TOTAL PARA
      * EL INSERT.
      * VERIFICAMOS QUE SI EL MONTO + COMISION DE LA TRX
      * SEA MENOR A LO QUE POSEE EL CLIENTE.
              IF WS-MONTO-TOTAL > SALDO OF DCLCLIENTE
                 DISPLAY 'MONTO INSUFICIENTE'
                 PERFORM 2800-CAMBIAR-DATOS-ERROR
                 MOVE 'SALDO INSUFICIENTE' TO E-RAZON
                 WRITE REG-ERROR
                 MOVE 'S' TO WS-ERROR
              END-IF
           END-IF.

      **********************************************************
      * GENERAMOS UN ID PARA LA TRANSACCION DONDE SI NO        *
      * EXISTE SE INGRESARA COMO ID = 1.                       *
      **********************************************************
       2400-GENERAR-ID-TRX.
           EXEC SQL
             SELECT MAX(ID_TRX)
             INTO :DCLTRANSACCION.ID-TRX :IND-NULL
             FROM TRX.TRANSACCION
           END-EXEC
           IF SQLCODE NOT = 0
              PERFORM 2800-CAMBIAR-DATOS-ERROR
              MOVE SQLCODE TO WS-ENC-CODE
              MOVE WS-ERROR-NCONTROL TO E-RAZON
              MOVE '2400' TO E-PARRAFO
              WRITE REG-ERROR
              MOVE 'S' TO WS-ERROR
           ELSE
              IF IND-NULL = -1
                 MOVE 1 TO ID-TRX OF DCLTRANSACCION
              ELSE
                 ADD 1 TO ID-TRX OF DCLTRANSACCION
              END-IF
           END-IF.
      *********************************************************
      * DESCONTAR EL MONTO TRANSFERIDO + LA COMISION DEL      *
      * USUARIO EMISOR.                                       *
      *********************************************************
       2500-DESCONTAR-SALDO-EMISOR.
           MOVE CBU-EMISOR OF REG-ENTRADA
                     TO CBU-CLIENTE-TEXT  OF DCLCLIENTE
           EXEC SQL
            SELECT SALDO
            INTO :DCLCLIENTE.SALDO
            FROM TRX.CLIENTE
            WHERE CBU_CLIENTE LIKE :DCLCLIENTE.CBU-CLIENTE
           END-EXEC
           IF SQLCODE NOT = 0
              PERFORM 2800-CAMBIAR-DATOS-ERROR
              MOVE SQLCODE TO WS-ENC-CODE
              MOVE WS-ERROR-NCONTROL TO E-RAZON
              MOVE '2500' TO E-PARRAFO
              WRITE REG-ERROR
              MOVE 'S' TO WS-ERROR
           ELSE
              SUBTRACT WS-MONTO-TOTAL FROM SALDO OF DCLCLIENTE
                                    GIVING SALDO OF DCLCLIENTE
              EXEC SQL
                UPDATE TRX.CLIENTE
                SET SALDO = :DCLCLIENTE.SALDO
                WHERE CBU_CLIENTE = :DCLCLIENTE.CBU-CLIENTE
              END-EXEC
              IF SQLCODE NOT = 0
                 PERFORM 2800-CAMBIAR-DATOS-ERROR
                 MOVE SQLCODE TO WS-ENC-CODE
                 MOVE WS-ERROR-NCONTROL TO E-RAZON
                 MOVE '2501' TO E-PARRAFO
                 WRITE REG-ERROR
                 MOVE 'S' TO WS-ERROR
              END-IF
           END-IF.
      *********************************************************
      * SUBIMOS LA TRANSACCION REALIZADA A LA BASE DE DATOS   *
      *********************************************************
       2600-CARGAR-TRX.
           MOVE FECHA-HORA TO DIA-HORA OF DCLTRANSACCION
           MOVE MONTO OF REG-ENTRADA TO MONTO OF DCLTRANSACCION
           MOVE WS-COMISION TO COMISION OF DCLTRANSACCION
           MOVE WS-MONTO-TOTAL TO MONTO-TOTAL OF DCLTRANSACCION
           MOVE CBU-EMISOR OF FICHERO-ENT
                     TO CBU-EMISOR-TEXT OF DCLTRANSACCION
           MOVE CBU-RECEPTOR OF FICHERO-ENT
                     TO CBU-RECEPTOR-TEXT OF DCLTRANSACCION
           EXEC SQL
             INSERT INTO TRX.TRANSACCION(
                    ID_TRX, DIA_HORA,MONTO,COMISION,
                    CBU_EMISOR, CBU_RECEPTOR, MONTO_TOTAL)
             VALUES (:DCLTRANSACCION.ID-TRX,
             :DCLTRANSACCION.DIA-HORA, :DCLTRANSACCION.MONTO,
             :DCLTRANSACCION.COMISION, :DCLTRANSACCION.CBU-EMISOR,
             :DCLTRANSACCION.CBU-RECEPTOR, :DCLTRANSACCION.MONTO-TOTAL)
           END-EXEC
           IF SQLCODE NOT = 0
              PERFORM 2800-CAMBIAR-DATOS-ERROR
              MOVE SQLCODE TO WS-ENC-CODE
              MOVE WS-ERROR-NCONTROL TO E-RAZON
              MOVE '2600' TO E-PARRAFO
              WRITE REG-ERROR
              MOVE 'S' TO WS-ERROR
           END-IF.
      *********************************************************
      * ACTUALIZAR EL SALDO DEL CLIENTE RECEPTOR              *
      *********************************************************
       2700-AGREGAR-SALDO-RECEPTOR.
           MOVE CBU-RECEPTOR OF REG-ENTRADA
                     TO CBU-CLIENTE-TEXT OF DCLCLIENTE
           EXEC SQL
            SELECT SALDO
            INTO :DCLCLIENTE.SALDO
            FROM TRX.CLIENTE
            WHERE CBU_CLIENTE = :DCLCLIENTE.CBU-CLIENTE
           END-EXEC
           IF SQLCODE NOT = 0
              PERFORM 2800-CAMBIAR-DATOS-ERROR
              MOVE SQLCODE TO WS-ENC-CODE
              MOVE WS-ERROR-NCONTROL TO E-RAZON
              MOVE '2701' TO E-PARRAFO
              WRITE REG-ERROR
              MOVE 'S' TO WS-ERROR
           ELSE
              ADD MONTO OF REG-ENTRADA TO SALDO OF DCLCLIENTE
              EXEC SQL
                UPDATE TRX.CLIENTE
                SET SALDO = :DCLCLIENTE.SALDO
                WHERE CBU_CLIENTE = :DCLCLIENTE.CBU-CLIENTE
              END-EXEC
              IF SQLCODE NOT = 0
                 PERFORM 2800-CAMBIAR-DATOS-ERROR
                 MOVE SQLCODE TO WS-ENC-CODE
                 MOVE WS-ERROR-NCONTROL TO E-RAZON
                 MOVE '2702' TO E-PARRAFO
                 WRITE REG-ERROR
                 MOVE 'S' TO WS-ERROR
              END-IF
           END-IF.

      *********************************************************
      * CARGAMOS EL CBU EMISOR Y RECEPTOR AL MENSAJE QUE      *
      * ESCRIBIREMOS EN EL REPORTE DE ERRORES                 *
      *********************************************************
       2800-CAMBIAR-DATOS-ERROR.
           MOVE CBU-EMISOR OF REG-ENTRADA TO E-CBU-EMISOR
           MOVE CBU-RECEPTOR OF REG-ENTRADA TO E-CBU-RECEPTOR.
      ********************************************************
      * PARRAFOS PARA CERRAR EL PROGRAMA                     *
      ********************************************************
       3000-END-PROGRAM.
           CLOSE FICHERO-ENT
           CLOSE ERROR-FICH
           PERFORM 3300-STOP-PROGRAM.

       3300-STOP-PROGRAM.
           STOP RUN.
