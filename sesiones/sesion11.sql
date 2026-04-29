--Sesion 11.1
/*Crea una función calcular_edad_cliente que reciba un ClienteID (parámetro IN) y devuelva la edad del cliente en años 
(basado en FechaNacimiento). Maneja excepciones si el cliente no existe.*/

SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION calcular_edad_cliente(p_cliente_id IN NUMBER) RETURN NUMBER AS
    v_fecha_nacimiento DATE;
    v_edad NUMBER;
BEGIN
    SELECT FechaNacimiento INTO v_fecha_nacimiento FROM Clientes WHERE ClienteID = p_cliente_id;
    IF v_fecha_nacimiento IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'ClienteID ' || p_cliente_id || ' no encontrado.');
    END IF;
    v_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);
    RETURN v_edad;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ClienteID ' || p_cliente_id || ' no encontrado.');
        RETURN NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RETURN NULL;
END;
/

--prueba
DECLARE
    v_edad NUMBER; 
BEGIN
    v_edad := calcular_edad_cliente(1);
    IF v_edad IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Edad del cliente: ' || v_edad || ' años.');
    END IF;
END;
/

--Sesion 11.2
/*Crea una función obtener_precio_promedio que devuelva el precio promedio de todos los productos. Úsala en una consulta SQL 
para listar los productos cuyo precio está por encima del promedio.*/

SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION obtener_precio_promedio RETURN NUMBER AS
    v_precio_promedio NUMBER;
BEGIN
    SELECT AVG(Precio) INTO v_precio_promedio FROM Productos;
    RETURN v_precio_promedio;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RETURN NULL;
END;
/

--prueba
SELECT ProductoID, Nombre, Precio
FROM Productos
WHERE Precio > obtener_precio_promedio();