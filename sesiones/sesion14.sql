--Sesion 14.1
/*Crea un supertipo Vehiculo con atributos Marca y Año, y un método obtener_antiguedad. 
Luego, crea un subtipo Automovil que herede de Vehiculo, con un atributo adicional 
NumeroPuertas y un método descripcion que devuelva una cadena con los detalles del 
automóvil.*/
SET SERVEROUTPUT ON;

CREATE OR REPLACE TYPE Vehiculo AS OBJECT (
    Marca VARCHAR2(50),
    Año NUMBER,
    MEMBER FUNCTION obtener_antiguedad RETURN NUMBER
) NOT FINAL;
/
CREATE OR REPLACE TYPE BODY Vehiculo AS 
    MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
    BEGIN
        RETURN EXTRACT(YEAR FROM SYSDATE) - Año;
    END;
END;
/
CREATE OR REPLACE TYPE Automovil UNDER Vehiculo (
    NumeroPuertas NUMBER,
    MEMBER FUNCTION descripcion RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY Automovil AS 
    MEMBER FUNCTION descripcion RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Automóvil: ' || Marca || ', Año: ' || Año || ', Puertas: ' || NumeroPuertas;
    END;
END;
/
CREATE OR REPLACE TYPE Camion UNDER Vehiculo (
    CargaMaxima NUMBER,
    MEMBER FUNCTION descripcion RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY Camion AS 
    MEMBER FUNCTION descripcion RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Camión: ' || Marca || ', Año: ' || Año || ', Carga: ' || CargaMaxima || ' kg';
    END;
END;
/
--prueba

CREATE TABLE Vehiculos OF Vehiculo;
INSERT INTO Vehiculos VALUES (Automovil('Toyota', 2020, 4));
INSERT INTO Vehiculos VALUES (Camion('Volvo', 2018, 12000));

SELECT v.Marca,
       v.obtener_antiguedad() AS Antiguedad,
       CASE
           WHEN VALUE(v) IS OF (Automovil) THEN TREAT(VALUE(v) AS Automovil).descripcion()
           WHEN VALUE(v) IS OF (Camion) THEN TREAT(VALUE(v) AS Camion).descripcion()
           ELSE 'Otro tipo de vehículo'
       END AS Descripcion
FROM Vehiculos v;

--Sesion 14.2
/*Crea un subtipo Camion que herede de Vehiculo, con un atributo adicional CapacidadCarga 
(en toneladas) y sobrescriba el método obtener_antiguedad para sumar 2 años adicionales 
(los camiones envejecen más rápido). Inserta un camión en la tabla Vehiculos y consulta 
su antigüedad y descripción.*/

CREATE OR REPLACE TYPE Camion UNDER Vehiculo (
    CapacidadCarga NUMBER,
    OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER
);
/
CREATE OR REPLACE TYPE BODY Camion AS
    OVERRIDING MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
    BEGIN
        RETURN (2025 - Año) + 2; 
END;
/

INSERT INTO Vehiculos VALUES (Camion('Volvo', 2018, 10));
SELECT v.Marca, v.obtener_antiguedad() AS Antiguedad
FROM Vehiculos v
WHERE VALUE(v) IS OF (Camion);

