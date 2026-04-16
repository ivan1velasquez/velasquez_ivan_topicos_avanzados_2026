-- Sesion 6.1
/*Escribe un bloque anónimo que use un cursor explícito basado en un objeto para 
listar 2 atributos de alguna clase, ordenados por uno de los atributos.*/

SET SERVEROUTPUT ON;

CREATE OR REPLACE TYPE jugador_obj AS OBJECT (
	id NUMBER,
	nombre VARCHAR2(50),
	MEMBER FUNCTION get_info RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY jugador_obj AS
	MEMBER FUNCTION get_info RETURN VARCHAR2 IS
	BEGIN
    	RETURN 'ID: ' || id || ', Nombre: ' || nombre;
	END;
END;
/

CREATE TABLE jugadores_obj OF jugador_obj (
	id PRIMARY KEY
);
INSERT INTO jugadores_obj
VALUES (9, 'Juan Pérez');
INSERT INTO jugadores_obj
VALUES (11, 'Romero Gómez');
/

DECLARE
    CURSOR jugador_cursor IS
    	SELECT VALUE(j) from jugadores_obj j
        ORDER by j.id ASC;
    v_jugador jugador_obj;
BEGIN
    OPEN jugador_cursor;
    LOOP
    	FETCH jugador_cursor INTO v_jugador;
    	EXIT WHEN jugador_cursor%NOTFOUND;
    	DBMS_OUTPUT.PUT_LINE(v_jugador.get_info);
    END LOOP;
    CLOSE jugador_cursor;
END;
/

-- Sesion 6.2
/*Escribe un bloque anónimo que use un cursor explícito con parámetro basado en un 
objeto para aumentar un 10% el total de la suma de algún atributo numérico de un 
elemento de una tabla y muestre los valores originales y actualizados. 
Usa FOR UPDATE o usa función dentro del objeto*/

SET SERVEROUTPUT ON;

CREATE OR REPLACE TYPE producto_obj AS OBJECT (
    id NUMBER,
    precio NUMBER,
    MEMBER FUNCTION aumentar_precio RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY producto_obj AS
    MEMBER FUNCTION aumentar_precio RETURN NUMBER IS
    BEGIN
        RETURN precio * 1.10;
    END;
END;
/

CREATE TABLE productos_obj OF producto_obj (
    id PRIMARY KEY
);
INSERT INTO productos_obj
VALUES (1, 100);
INSERT INTO productos_obj
VALUES (2, 200);
/

DECLARE
    CURSOR producto_cursor IS
    	SELECT VALUE(p) FROM productos_obj p
        FOR UPDATE;
    v_producto producto_obj;
BEGIN
    OPEN producto_cursor;
    LOOP
    FETCH producto_cursor INTO v_producto;
    EXIT WHEN producto_cursor%NOTFOUND;
    IF v_producto.precio < 200 THEN
        DBMS_OUTPUT.PUT_LINE('Precio original: ' || v_producto.precio);
        UPDATE productos_obj SET precio = v_producto.aumentar_precio() WHERE CURRENT OF producto_cursor;
        DBMS_OUTPUT.PUT_LINE('Precio actualizado: ' || v_producto.aumentar_precio());
    END IF;
    END LOOP;
    CLOSE producto_cursor;
END;
/