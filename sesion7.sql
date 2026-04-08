-- Sesion 7.1
/*Crea un procedimiento aumentar_precio_producto que reciba un ProductoID y un porcentaje 
de aumento (como parámetros IN), y aumente el precio del producto en ese porcentaje. 
Maneja la excepción si el producto no existe.*/

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE aumentar_precio_producto(p_producto_id IN NUMBER, p_porcentaje IN NUMBER) AS
    v_nuevo_precio NUMBER;  
BEGIN
    IF p_porcentaje < 0 THEN
    	RAISE_APPLICATION_ERROR(-20002, 'El porcentaje de aumento no puede ser negativo.');
	END IF;
	UPDATE Productos
	SET Precio = Precio * (1 + p_porcentaje / 100)
	WHERE ProductoID = p_producto_id;
	IF SQL%ROWCOUNT = 0 THEN
    	RAISE_APPLICATION_ERROR(-20001, 'Producto con ID ' || p_producto_id || ' no encontrado.');
	END IF;
    SELECT Precio INTO v_nuevo_precio FROM Productos 
    WHERE ProductoID = p_producto_id;
	DBMS_OUTPUT.PUT_LINE('Precio del producto ' || p_producto_id || ' aumentado en ' || p_porcentaje || '%.');
    DBMS_OUTPUT.PUT_LINE('Nuevo precio: ' || v_nuevo_precio);
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

EXEC aumentar_precio_producto(2, 20);

-- Sesion 7.2
/*Crea un procedimiento contar_pedidos_cliente que reciba un ClienteID (parámetro IN) y devuelva la cantidad 
de pedidos de ese cliente (parámetro OUT). Si el cliente no tiene pedidos, devuelve 0.*/

CREATE OR REPLACE PROCEDURE contar_pedidos_cliente(p_cliente_id IN NUMBER, p_cantidad OUT NUMBER) AS
BEGIN
    SELECT COUNT(*) INTO p_cantidad FROM Pedidos WHERE ClienteID = p_cliente_id;
    DBMS_OUTPUT.PUT_LINE('El cliente ' || p_cliente_id || ' tiene ' || p_cantidad || ' pedidos.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        p_cantidad := 0;
END;
/

DECLARE
    v_cantidad NUMBER;
BEGIN
    contar_pedidos_cliente(1, v_cantidad);
    DBMS_OUTPUT.PUT_LINE('Cantidad de pedidos del cliente 1: ' || v_cantidad);
END;
/