--Sesion 28.1
/*Define qué es una transacción en una base de datos y explica cómo las propiedades ACID 
garantizan su integridad. Proporciona un ejemplo de un procedimiento que registre un pedido 
en la tabla Pedidos, usando savepoints para revertir la operación si el cliente no existe.
*/

/*Transacción: Es una unidad lógica de trabajo formada por una o más operaciones que deben 
ejecutarse en su totalidad o no ejecutarse en absoluto.

Garantía de integridad (Propiedades ACID):

- Atomicidad: "Todo o nada". Si una operación falla, la transacción completa se deshace 
(rollback).
- Consistencia: Garantiza que la base de datos pase de un estado válido a otro, respetando 
todas sus reglas y restricciones.
- Aislamiento (Isolation): Evita que transacciones simultáneas interfieran entre sí; los datos 
en proceso son invisibles para otras operaciones hasta que terminan.

- Durabilidad: Una vez completada la transacción (commit), los cambios son permanentes y 
sobreviven a cualquier fallo del sistema.
*/

SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE registrar_pedido (
    p_cliente_id IN NUMBER,
    p_total IN NUMBER,
    p_fecha_pedido IN DATE
) AS
    v_cliente_existe NUMBER;
BEGIN
    SAVEPOINT inicio_pedido;
    -- Validar que el cliente existe
    SELECT COUNT(*) INTO v_cliente_existe
    FROM Clientes
    WHERE ClienteID = p_cliente_id;
    IF v_cliente_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cliente no existe.');
    END IF;
    -- Insertar pedido
    INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
    VALUES ((SELECT NVL(MAX(PedidoID), 0) + 1 FROM Pedidos), p_cliente_id, p_total, p_fecha_pedido);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO inicio_pedido;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM || '. Operación revertida.');
        ROLLBACK;
END;
/

--Sesion 28.2
/*¿Qué es un Data Warehouse y cómo se diferencia de una base de datos operativa en 
términos de propósito y estructura? Diseña una tabla de hechos Fact_Inventario para 
analizar el movimiento de productos (entradas y salidas) en la base de datos, incluyendo 
claves foráneas y medidas adecuadas.*/

/*
Data Warehouse: Es un repositorio centralizado que almacena grandes volúmenes de datos 
históricos e integrados provenientes de múltiples fuentes, diseñado específicamente para 
el análisis y la inteligencia de negocios (BI).

Diferencias con una base de datos operativa:

Propósito:

- Base de datos operativa (OLTP): Gestiona las operaciones del día a día procesando 
transacciones rutinarias en tiempo real (inserciones, actualizaciones y borrados rápidos).

- Data Warehouse (OLAP): Su propósito es analítico. Se utiliza para leer grandes 
volúmenes de datos a largo plazo, generar reportes y apoyar la toma de decisiones 
estratégicas.

Estructura:

- Base de datos operativa: Está normalizada. Se estructura en muchas tablas 
relacionadas para evitar la redundancia de datos y hacer que las escrituras 
sean muy eficientes.

- Data Warehouse: Está desnormalizado. Utiliza estructuras diseñadas para la 
lectura (como el esquema de estrella o copo de nieve), agrupando los datos de 
forma que las consultas complejas y masivas se ejecuten mucho más rápido, aunque 
haya redundancia.
*/

CREATE TABLE Fact_Inventario (
    FactID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ProductoID NUMBER,
    FechaID NUMBER,
    CantidadMovimiento NUMBER,
    TipoMovimiento VARCHAR2(10),
    CONSTRAINT fk_fact_inventario_producto FOREIGN KEY (ProductoID) REFERENCES Dim_Producto(ProductoID),
    CONSTRAINT fk_fact_inventario_tiempo FOREIGN KEY (FechaID) REFERENCES Dim_Tiempo(FechaID)
);
/

--Sesion 28.3
/*Explica cómo se implementa la herencia en Oracle utilizando tipos de objetos y la 
cláusula UNDER. Diseña una jerarquía de tipos para modelar clientes 
(Cliente → ClientePremium) y crea un índice en la tabla Clientes para optimizar 
consultas por Ciudad. Justifica tu elección.*/

/*
La herencia en Oracle se implementa mediante el Modelo Objeto-Relacional utilizando 
CREATE TYPE. Para permitir que un tipo sea heredado, se debe definir explícitamente 
como NOT FINAL. Luego, el subtipo se crea utilizando la cláusula UNDER, lo que le 
permite heredar todos los atributos y métodos del supertipo y añadir los suyos propios.
*/

CREATE TYPE Tipo_Cliente AS OBJECT (
    ClienteID NUMBER,
    Nombre VARCHAR2(50),
    Ciudad VARCHAR2(50),
    MEMBER FUNCTION getDescuento RETURN NUMBER
) NOT FINAL;
/
CREATE TYPE BODY Tipo_Cliente AS
    MEMBER FUNCTION getDescuento RETURN NUMBER IS
    BEGIN RETURN 0; END;
END;
/
CREATE TYPE Tipo_ClientePremium UNDER Tipo_Cliente (
    DescuentoAdicional NUMBER,
    OVERRIDING MEMBER FUNCTION getDescuento RETURN NUMBER
);
/

CREATE TYPE BODY Tipo_ClientePremium AS
    OVERRIDING MEMBER FUNCTION getDescuento RETURN NUMBER IS
    BEGIN RETURN DescuentoAdicional; END;
END;
/
CREATE TABLE Clientes OF Tipo_Cliente;

CREATE INDEX idx_clientes_ciudad ON Clientes (Ciudad);

ALTER TABLE Pedidos ADD PARTITION BY RANGE (FechaPedido) (
    PARTITION p_q1_2025 VALUES LESS THAN (TO_DATE('2025-04-01', 'YYYY-MM-DD')),
    PARTITION p_q2_2025 VALUES LESS THAN (TO_DATE('2025-07-01', 'YYYY-MM-DD')),
    PARTITION p_q3_2025 VALUES LESS THAN (TO_DATE('2025-10-01', 'YYYY-MM-DD')),
    PARTITION p_q4_2025 VALUES LESS THAN (MAXVALUE)
);

CREATE INDEX idx_pedidos_cliente_total ON Pedidos (ClienteID, Total);

--Sesion 28.4
/*Crea un índice compuesto en DetallesPedidos para PedidoID y ProductoID. 
Particiona Pedidos por rango de FechaPedido (mensual para 2025). 
Escribe una consulta que sume Total por ClienteID en enero de 2025.*/

-- Índice compuesto
CREATE INDEX idx_detalles_pedido_prod ON DetallesPedidos (PedidoID, ProductoID);
-- Partición por rango mensual
ALTER TABLE Pedidos ADD PARTITION BY RANGE (FechaPedido) (
    PARTITION p_jan_2025 VALUES LESS THAN (TO_DATE('2025-02-01', 'YYYY-MM-DD')),
    PARTITION p_feb_2025 VALUES LESS THAN (TO_DATE('2025-03-01', 'YYYY-MM-DD')),
    PARTITION p_mar_2025 VALUES LESS THAN (TO_DATE('2025-04-01', 'YYYY-MM-DD')),
    PARTITION p_max VALUES LESS THAN (MAXVALUE)
);
-- Consulta
SELECT 
    ClienteID,
    SUM(Total) AS Total_Mensual
FROM Pedidos
WHERE FechaPedido BETWEEN TO_DATE('2025-01-01', 'YYYY-MM-DD') AND TO_DATE('2025-01-31', 'YYYY-MM-DD')
GROUP BY ClienteID;



