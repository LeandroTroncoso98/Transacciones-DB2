# Transacciones-DB2
    Detalle del programa PDBTRX:
Se requiere un programa encargado de procesar transacciones a través de un archivo secuencial. Su función primordial será verificar la existencia del CBU (Clave Bancaria Uniforme) del emisor y del receptor. Una vez confirmada la existencia de ambos CBUs, se generará un ID único para la transacción.

Además de la validación de los CBUs, el programa deberá considerar la categoría del cliente para aplicar la comisión correspondiente sobre el monto de la transacción(Cliente premium tendra una comision del 0.01% mientras que la cateria comun es del 0.03% ). En caso de que el cliente no disponga de fondos suficientes para cubrir dicha comisión, o cualquier otro motivo de invalidez, la transacción no será validada y se generará un reporte en un archivo de salida.

Una vez validada, la transacción será registrada en la base de datos para su posterior seguimiento y procesamiento.
    
    Archivo de entrada de programa PDBTRX:
El archivo secuencial de entrada estara estructurado de la siguiente manera: Hora en la que se realizo la transaccion, monto de la transaccion, CBU del cliente emisor, CBU del cliente receptor. <br />
Por ejemplo: <br />
2024-01-31-12.00.00.00000100000000003561200952460009987698752440078879526549875416549 <br />

    Final del proceso de PDBTRX:
Una vez que se realice todo el proceso de verificacion y grabacion en el programa las transacciones invalidas por algun motivo seran registradas en un archivo secuencial de reportes de error.
Teniendo el formato: CBU emisor, CBU receptor, causa del error.<br />
![image](https://github.com/LeandroTroncoso98/Transacciones-DB2/assets/105368488/8d5795eb-df9a-4564-9217-c28941c900fd)
<br /> Mientras que las transacciones que fueron validas correctamente seran grabadas en la base de datos, en la tabla de transacciones.
![image](https://github.com/LeandroTroncoso98/Transacciones-DB2/assets/105368488/16756c64-6ecb-40b5-8943-2b8e3506d875)

    Diagrama de flujo del programa PDBTRX:
![DFDB2](https://github.com/LeandroTroncoso98/Transacciones-DB2/assets/105368488/2f1a6a26-368e-40c4-9acf-d50f577fe3bb)

    Diagrama entidad relacion de la base de datos:
![DERDB2](https://github.com/LeandroTroncoso98/Transacciones-DB2/assets/105368488/b3efb5be-0c15-4b6e-88d3-ea4ce691d5e8)

    Detalle del programa PTRXCLI:
El programa recibe un CBU, el cual será evaluado para determinar si corresponde al formato correcto de un CBU. Una vez validado, buscará en la base de datos todas las transacciones en las que dicho CBU haya participado, ya sea como emisor o receptor.
Después de haber leído todas las transacciones en las que el CBU haya participado, el programa imprimirá un reporte que contendrá las últimas 10 transacciones de su historial.

    Diagrama de flujo del programa PTRXCLI:
![DFPTRXCLI](https://github.com/LeandroTroncoso98/Transacciones-DB2/assets/105368488/32fb70bf-dfd4-4cb5-9648-de982a9c2a53)

    Resultado de la ejecucion del programa PTRXCLI:
![image](https://github.com/LeandroTroncoso98/Transacciones-DB2/assets/105368488/9ce8e3f6-b9e5-433e-8438-002ecc6cc884)
