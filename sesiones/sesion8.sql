--Sesion 8.1
/*Escribe un cursor explícito que liste los pedidos con total mayor a 500 y muestre el nombre del cliente asociado, usando un JOIN.*/

SET SERVEROUTPUT ON;

DECLARE
    CURSOR pedido_mayor_500 IS
        SELECT p.PedidoID, c.Nombre, p.Total
        FROM Pedidos p
        JOIN Clientes c ON p.ClienteID = c.ClienteID
        WHERE p.Total > 500;
        v_pedido_id NUMBER;
        v_nombre VARCHAR2(50);
        v_total NUMBER;

BEGIN
    OPEN pedido_mayor_500;
    LOOP
        FETCH pedido_mayor_500 INTO v_pedido_id, v_nombre, v_total;
        EXIT WHEN pedido_mayor_500%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('PedidoID: ' || v_pedido_id || ', Cliente: ' || v_nombre || ', Total: ' || v_total);
    END LOOP;
    CLOSE pedido_mayor_500;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- Sesion 8.2
/*Escribe un cursor explícito que aumente un 15% los precios de productos con precio inferior a 1000 y maneje una excepción si falla.*/

SET SERVEROUTPUT ON;

DECLARE
    CURSOR productos_menor_1000 IS
        SELECT ProductoID, Precio
        FROM Productos
        WHERE Precio < 1000
        FOR UPDATE;
        v_producto_id NUMBER;
        v_precio NUMBER;
BEGIN
    OPEN productos_menor_1000;
    LOOP
        FETCH productos_menor_1000 INTO v_producto_id, v_precio;
        EXIT WHEN productos_menor_1000%NOTFOUND;
        UPDATE Productos
        SET Precio = Precio * 1.15
        WHERE CURRENT OF productos_menor_1000;
        DBMS_OUTPUT.PUT_LINE('ProductoID: ' || v_producto_id || ' de precio: ' || v_precio || ', actualizado a: ' || (v_precio * 1.15));
    END LOOP;
    CLOSE productos_menor_1000;
END;
/

--Sesion 8.3
/*Escribe un bloque PL/SQL con un cursor explícito que liste los clientes cuyo total de pedidos 
(suma de los valores de Total en la tabla Pedidos) sea mayor a 1000, mostrando el nombre del cliente y el total acumulado. 
Usa un JOIN entre Clientes y Pedidos, y agrupa los resultados con GROUP BY.*/

SET SERVEROUTPUT ON;

DECLARE
    CURSOR clientes_con_pedidos IS
        SELECT c.Nombre, SUM(p.Total) AS TotalPedidos
        FROM Clientes c
        JOIN Pedidos p ON c.ClienteID = p.ClienteID
        GROUP BY c.Nombre
        HAVING SUM(p.Total) > 1000;
        v_nombre VARCHAR2(50);
        v_total_pedidos NUMBER;
BEGIN
    OPEN clientes_con_pedidos;
    LOOP
        FETCH clientes_con_pedidos INTO v_nombre, v_total_pedidos;
        EXIT WHEN clientes_con_pedidos%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_nombre || ', Total de Pedidos: ' || v_total_pedidos);
    END LOOP;
    CLOSE clientes_con_pedidos;

END;
/

--Sesion 8.4
/*Escribe un bloque PL/SQL con un cursor explícito que aumente en 1 la cantidad de los detalles de pedidos (DetallesPedidos) 
asociados a pedidos con fecha anterior al 2 de marzo de 2025 (FechaPedido en la tabla Pedidos). 
Usa FOR UPDATE para bloquear las filas y maneja excepciones.*/

SET SERVEROUTPUT ON;

DECLARE
    CURSOR detalles_pedidos IS
        SELECT dp.DetalleID, p.PedidoID, dp.Cantidad
        FROM DetallesPedidos dp
        JOIN Pedidos p ON dp.PedidoID = p.PedidoID
        WHERE p.FechaPedido < TO_DATE('2025-03-02', 'YYYY-MM-DD')
        FOR UPDATE;
        v_detalle_id NUMBER;
        v_pedido_id NUMBER;
        v_cantidad NUMBER;
        v_nueva_cantidad NUMBER;
        v_contador NUMBER := 0;

BEGIN
    OPEN detalles_pedidos;
    LOOP
        FETCH detalles_pedidos INTO v_detalle_id, v_pedido_id, v_cantidad;
        EXIT WHEN detalles_pedidos%NOTFOUND;
        v_nueva_cantidad := v_cantidad + 1;
        UPDATE DetallesPedidos
        SET Cantidad = v_nueva_cantidad
        WHERE CURRENT OF detalles_pedidos;
        DBMS_OUTPUT.PUT_LINE('DetalleID: ' || v_detalle_id || ', PedidoID: ' || v_pedido_id || ' de cantidad: ' || v_cantidad || ', actualizado a cantidad: ' || v_nueva_cantidad);
        v_contador := v_contador + 1;
    END LOOP;
    CLOSE detalles_pedidos;

    IF v_contador = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No se encontraron detalles de pedidos para actualizar.');
    ELSE
            DBMS_OUTPUT.PUT_LINE('Total de detalles de pedidos actualizados: ' || v_contador);
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    IF detalles_pedidos%ISOPEN THEN
        CLOSE detalles_pedidos;
    END IF;
END;
/

--Sesion 8.5
/*Crea un tipo de objeto cliente_obj con los atributos cliente_id, nombre, y un método get_info que devuelva una cadena con la información
 del cliente. Crea una tabla basada en ese tipo, transfiere los datos de la tabla Clientes a esa tabla, y escribe un bloque PL/SQL con 
 un cursor explícito que liste la información de los clientes usando el método get_info.*/

CREATE OR REPLACE TYPE cliente_obj AS OBJECT (
    cliente_id NUMBER,
    nombre VARCHAR2(50),
    MEMBER FUNCTION get_info RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY cliente_obj AS
    MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'ClienteID: ' || cliente_id || ', Nombre: ' || nombre;
    END get_info;
END;
/

CREATE TABLE clientes_obj_tab OF cliente_obj(cliente_id PRIMARY KEY);

INSERT INTO clientes_obj_tab (cliente_id, nombre)
SELECT ClienteID, Nombre FROM Clientes;

SET SERVEROUTPUT ON;

DECLARE
    CURSOR clientes_cursor IS
        SELECT VALUE(c) AS cli_obj FROM clientes_obj_tab c;
        v_cliente_obj cliente_obj;

BEGIN
    OPEN clientes_cursor;
    LOOP
        FETCH clientes_cursor INTO v_cliente_obj;
        EXIT WHEN clientes_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_cliente_obj.get_info);
    END LOOP;
    CLOSE clientes_cursor;

    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('No se encontraron clientes para mostrar.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    IF clientes_cursor%ISOPEN THEN
        CLOSE clientes_cursor;
    END IF;
END;
/
