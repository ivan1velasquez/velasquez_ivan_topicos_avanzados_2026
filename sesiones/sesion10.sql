--Sesion 10.1
/*Crea un procedimiento actualizar_total_pedidos que reciba un ClienteID (parámetro IN) y un porcentaje de aumento 
(parámetro IN con valor por defecto 10%). Aumenta el total de todos los pedidos del cliente en el porcentaje especificado. 
Usa un bucle para iterar sobre los pedidos.*/

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE actualizar_total_pedidos(p_cliente_id IN NUMBER, p_porcentaje IN NUMBER DEFAULT 10) AS
	CURSOR pedido_cursor IS
    	SELECT PedidoID, Total
    	FROM Pedidos
    	WHERE ClienteID = p_cliente_id
    	FOR UPDATE;
BEGIN
	FOR pedido IN pedido_cursor LOOP
    	UPDATE Pedidos
    	SET Total = pedido.Total * (1 + p_porcentaje / 100)
    	WHERE CURRENT OF pedido_cursor;
    	DBMS_OUTPUT.PUT_LINE('Pedido ' || pedido.PedidoID || ': Nuevo total: ' || (pedido.Total * (1 + p_porcentaje / 100)));
	END LOOP;
	IF SQL%ROWCOUNT = 0 THEN
    	DBMS_OUTPUT.PUT_LINE('Cliente ' || p_cliente_id || ' no tiene pedidos.');
	ELSE
    	COMMIT;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    	ROLLBACK;
END;
/

--prueba
EXEC actualizar_total_pedidos(1, 15);

--Sesion 10.2
/*Crea un procedimiento calcular_costo_detalle que reciba un DetalleID (parámetro IN) y devuelva el costo total del detalle 
(parámetro IN OUT). El costo se calcula como Precio * Cantidad (usando las tablas DetallesPedidos y Productos). 
Maneja excepciones si el detalle no existe.*/

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE calcular_costo_detalle(p_detalle_id IN NUMBER, p_costo OUT NUMBER) AS
BEGIN
    SELECT dp.Cantidad * pr.Precio
    INTO p_costo
    FROM DetallesPedidos dp
    JOIN Productos pr ON dp.ProductoID = pr.ProductoID
    WHERE dp.DetalleID = p_detalle_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('DetalleID ' || p_detalle_id || ' no encontrado.');
        p_costo := NULL;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        p_costo := NULL;
END;
/

--prueba
DECLARE
    v_costo NUMBER;
BEGIN
    calcular_costo_detalle(1, v_costo);
    IF v_costo IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Costo total del detalle: ' || v_costo);
    END IF;
END;
/


