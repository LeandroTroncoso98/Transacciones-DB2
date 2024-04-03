# Transacciones-DB2
    Detalle del programa:
Se requiere un programa encargado de procesar transacciones a través de un archivo secuencial. Su función primordial será verificar la existencia del CBU (Clave Bancaria Uniforme) del emisor y del receptor. Una vez confirmada la existencia de ambos CBUs, se generará un ID único para la transacción.

Además de la validación de los CBUs, el programa deberá considerar la categoría del cliente para aplicar la comisión correspondiente sobre el monto de la transacción(Cliente premium tendra una comision del 0.01% mientras que la cateria comun es del 0.03% ). En caso de que el cliente no disponga de fondos suficientes para cubrir dicha comisión, o cualquier otro motivo de invalidez, la transacción no será validada y se generará un reporte en un archivo de salida.

Una vez validada, la transacción será registrada en la base de datos para su posterior seguimiento y procesamiento.
    
    Archivo de entrada:
El archivo secuencial de entrada estara estructurado de la siguiente manera: Hora en la que se realizo la transaccion, monto de la transaccion, CBU del cliente emisor, CBU del cliente receptor.
2024-01-31-12.00.00.00000100000000003561200952460009987698752440078879526549875416549
|---- FECHA -------------||----MONTO ---||----CBU EMI --------||--CBU RECEP --------|

    Proceso:
Una vez que se realice todo el proceso de verificacion y grabacion en el programa las transacciones invalidas por algun motivo seran registradas en un archivo secuencial de reportes de error.
Teniendo el formato: CBU emisor, CBU receptor, causa del error.
![image](https://github.com/LeandroTroncoso98/Transacciones-DB2/assets/105368488/8d5795eb-df9a-4564-9217-c28941c900fd)
Mientras que las transacciones que fueron validas correctamente seran grabadas en la base de datos, en la tabla de transacciones.
![image](https://github.com/LeandroTroncoso98/Transacciones-DB2/assets/105368488/16756c64-6ecb-40b5-8943-2b8e3506d875)

    Diagrama entidad relacion:
![DERDB2](https://github.com/LeandroTroncoso98/Transacciones-DB2/assets/105368488/34994130-8372-40bc-b43f-4210aa69aaff)

    Diagrama de flujo:
![DFDB2](https://github.com/LeandroTroncoso98/Transacciones-DB2/assets/105368488/2f1a6a26-368e-40c4-9acf-d50f577fe3bb)


