--Sesion 15.1
/*Crea un índice compuesto en la tabla DetallesPedidos para las columnas PedidoID y 
ProductoID. Luego, escribe una consulta que use este índice y analiza su plan de ejecución.*/

-- Crear índice compuesto
CREATE INDEX idx_detalles_pedido_producto ON DetallesPedidos(PedidoID, ProductoID);

-- Consulta que usa el índice
EXPLAIN PLAN FOR
SELECT * FROM DetallesPedidos
WHERE PedidoID = 108 AND ProductoID = 1;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Ejecutar la consulta
SELECT * FROM DetallesPedidos
WHERE PedidoID = 108 AND ProductoID = 1;

--Sesion 15.2
/*Crea una tabla Ventas particionada por hash usando la columna ClienteID (4 particiones). 
Inserta datos de Pedidos y escribe una consulta que muestre el total de ventas por cliente, 
verificando que las particiones se usen.*/

DROP TABLE Ventas;

CREATE TABLE Ventas (
    VentaID NUMBER PRIMARY KEY,
    ClienteID NUMBER,
    Total NUMBER,
    Fecha DATE
)
PARTITION BY HASH (ClienteID) 
PARTITIONS 4;

INSERT INTO Ventas (VentaID, ClienteID, Total)
SELECT 
    PedidoID,
    ClienteID,
    Total
FROM Pedidos
WHERE ClienteID IS NOT NULL;

-- Consulta que muestra el total de ventas por cliente
SELECT ClienteID, SUM(Total) as TotalVentas
FROM Ventas
GROUP BY ClienteID;

