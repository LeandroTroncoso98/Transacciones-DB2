# Transacciones-DB2
                                     Detalle del programa:
Se requiere un programa encargado de procesar transacciones a través de un archivo VSAM. Su función primordial será verificar la existencia del CBU (Clave Bancaria Uniforme) del emisor y del receptor. Una vez confirmada la existencia de ambos CBUs, se generará un ID único para la transacción.

Además de la validación de los CBUs, el programa deberá considerar la categoría del cliente para aplicar la comisión correspondiente sobre el monto de la transacción. En caso de que el cliente no disponga de fondos suficientes para cubrir dicha comisión, la transacción no será validada.

Una vez validada, la transacción será registrada en la base de datos para su posterior seguimiento y procesamiento.

                                        Diagrama entidad relacion:
![DERDB2](https://github.com/LeandroTroncoso98/Transacciones-DB2/assets/105368488/504b0cde-e228-45a9-b8ec-432d7e548f7b)
