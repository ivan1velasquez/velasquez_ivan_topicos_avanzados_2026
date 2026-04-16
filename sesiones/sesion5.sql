--Sesion 5.1
--Escribe un bloque anónimo que use un cursor explícito para listar 2 atributos de alguna clase, ordenados por uno de los atributos.

SET SERVEROUTPUT ON;

DECLARE
	CURSOR producto_cursor IS
    	SELECT ProductoID, Nombre
    	FROM Productos
    	ORDER BY ProductoID;
	v_id NUMBER;
	v_nombre VARCHAR2(50);
BEGIN
	OPEN producto_cursor;
	LOOP
    	FETCH producto_cursor INTO v_id, v_nombre;
    	EXIT WHEN producto_cursor%NOTFOUND;
    	DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ', Nombre: ' || v_nombre);
	END LOOP;
	CLOSE producto_cursor;
END;
/

--Sesion 5.2
/*Escribe un bloque anónimo que use un cursor explícito con parámetro para aumentar un 10% el total de la suma de algún atributo numérico 
de un elemento de una tabla y muestre los valores originales y actualizados. Usa FOR UPDATE.*/


SET SERVEROUTPUT ON;

DECLARE
    CURSOR precio_producto_cursor IS
    	SELECT ProductoID, Precio
    	FROM Productos
    	FOR UPDATE;
    v_id NUMBER;
    v_precio NUMBER;

BEGIN
    OPEN precio_producto_cursor;
    FETCH precio_producto_cursor INTO v_id, v_precio;
    IF precio_producto_cursor%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Precio original: ' || v_precio);
        v_precio := v_precio * 1.10; -- Aumentar un 10%
        UPDATE Productos SET Precio = v_precio WHERE CURRENT OF precio_producto_cursor;
        DBMS_OUTPUT.PUT_LINE('Precio actualizado: ' || v_precio);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Producto no encontrado.');
    END IF;
    CLOSE precio_producto_cursor;
END;
/