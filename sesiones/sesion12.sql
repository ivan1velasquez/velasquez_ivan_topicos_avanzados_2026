--Sesion 12.1
/*Crea una función calcular_total_con_descuento que reciba un PedidoID (parámetro IN) y devuelva el total del pedido con un 
descuento del 10% si el total supera 1000. Usa la función en un procedimiento aplicar_descuento_pedido que actualice el total 
del pedido.*/

CREATE OR REPLACE FUNCTION calcular_total_con_descuento(p_pedido_id IN NUMBER) 
RETURN NUMBER AS
    v_total NUMBER;
BEGIN

    SELECT Total INTO v_total
    FROM Pedidos
    WHERE PedidoID = p_pedido_id;

    IF v_total > 1000 THEN
        v_total := v_total * 0.9; 
    END IF;

    RETURN v_total;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20004, 'Pedido con ID ' || p_pedido_id || ' no encontrado.');
END;
/

CREATE OR REPLACE PROCEDURE aplicar_descuento_pedido(p_pedido_id IN NUMBER) AS
    v_nuevo_total NUMBER;
BEGIN
    v_nuevo_total := calcular_total_con_descuento(p_pedido_id);

    UPDATE Pedidos
    SET Total = v_nuevo_total
    WHERE PedidoID = p_pedido_id;

    DBMS_OUTPUT.PUT_LINE('Total del pedido ' || p_pedido_id || ' actualizado a: ' || v_nuevo_total);
    
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/

-- prueba
SET SERVEROUTPUT ON;
EXEC aplicar_descuento_pedido(101);

--Sesion 12.2
/*Crea un trigger validar_cantidad_detalle que se dispare antes de insertar o actualizar en DetallesPedidos y verifique que 
la Cantidad sea mayor a 0. Si no, lanza un error.*/

SET SERVEROUTPUT ON;

CREATE OR REPLACE TRIGGER validar_cantidad_detalle
BEFORE INSERT OR UPDATE ON DetallesPedidos
FOR EACH ROW
BEGIN
    IF :NEW.Cantidad <= 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'La cantidad debe ser mayor a 0.');
    END IF;
END;
/

--prueba
BEGIN
    DBMS_OUTPUT.PUT_LINE('Intentando insertar un detalle con cantidad negativa...');
    INSERT INTO DetallesPedidos VALUES (3, 102, 1, -1);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('Intentando insertar un detalle con cantidad válida...');
    INSERT INTO DetallesPedidos VALUES (4, 102, 1, 3); 
    DBMS_OUTPUT.PUT_LINE('Detalle insertado correctamente.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/



