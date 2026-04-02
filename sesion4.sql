--Ejercicio Sesion 4.1
--Escribe un bloque PL/SQL que verifique el valor numérico de una tabla

SET SERVEROUTPUT ON;

DECLARE
	cant_producto NUMBER;
	cant_error EXCEPTION;
BEGIN
	SELECT Cantidad INTO cant_producto
	FROM DetallesPedidos
	WHERE ProductoID = 1;
    
	IF cant_producto < 3 THEN
    	RAISE cant_error;
	END IF;
    
	DBMS_OUTPUT.PUT_LINE('Cantidad del producto: ' || cant_producto);

EXCEPTION
	WHEN cant_error THEN
    	DBMS_OUTPUT.PUT_LINE('Error: La cantidad no puede ser menor a 3.');
	WHEN NO_DATA_FOUND THEN
    	DBMS_OUTPUT.PUT_LINE('Error: Producto no encontrado.');
END;
/

--Ejercicio Sesion 4.2
--Escribe un bloque PL/SQL que intente insertar una tupla con ID duplicado

SET SERVEROUTPUT ON;
DECLARE
    v_id_cliente       NUMBER := 1; 
    v_nombre_cliente   VARCHAR2(50) := 'Carlos Sanchez';
    v_ciudad_cliente   VARCHAR2(50) := 'Concepcion';
    v_fecha_nacimiento DATE := TO_DATE('1988-07-22', 'YYYY-MM-DD');
    v_existe           NUMBER;
    dup_error          EXCEPTION;
BEGIN

    SELECT COUNT(*) INTO v_existe 
    FROM Clientes 
    WHERE ClienteID = v_id_cliente;

    IF v_existe > 0 THEN
        RAISE dup_error;
    END IF;

    INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento) 
    VALUES (v_id_cliente, v_nombre_cliente, v_ciudad_cliente, v_fecha_nacimiento);
    
    DBMS_OUTPUT.PUT_LINE('Cliente insertado correctamente.');

EXCEPTION
    WHEN dup_error THEN
        DBMS_OUTPUT.PUT_LINE('Error: El ID de cliente ' || v_id_cliente || ' ya está en la base de datos.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/
