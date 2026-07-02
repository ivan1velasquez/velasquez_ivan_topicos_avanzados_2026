--Prueba 3 Iván Velásquez

/*
PREGUNTA 1
Explica qué es una transacción en una base de datos y describe las propiedades ACID. 
Luego, muestra a través de un ejemplo cómo usarías múltiples savepoints para manejar 
errores parciales en un procedimiento que asigna un agente a un incidente y actualiza 
simultáneamente el estado del incidente. ¿Qué ocurre si falla solo la actualización del estado?

Respuesta:
Una transacción es una unidad lógica de trabajo compuesta por una o más sentencias SQL. 
O se ejecutan todas (commit) o no se ejecuta ninguna (rollback), garantizando la integridad de los datos.

Propiedades ACID:
- A (Atomicidad): "Todo o nada". Las operaciones se ejecutan completas o fallan por completo.
- C (Consistencia): La base de datos pasa de un estado válido a otro válido, respetando constraints y reglas.
- I (Aislamiento/Isolation): Las transacciones concurrentes no se interfieren entre sí.
- D (Durabilidad): Una vez confirmados los cambios (commit), son permanentes frente a fallas.

Ejemplo de múltiples savepoints:
BEGIN
  SAVEPOINT sp_inicio;
  INSERT INTO Asignaciones (agente_id, incidente_id) VALUES (1, 100);
  
  SAVEPOINT sp_antes_estado;
  UPDATE Incidentes SET estado = 'Asignado' WHERE id = 100;
  
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    -- Si falla la actualización del estado, deshacemos solo hasta el savepoint anterior
    ROLLBACK TO sp_antes_estado;
    -- Aquí podríamos decidir si hacer COMMIT para mantener la asignación a pesar del fallo
    -- en la actualización de estado, o lanzar un error.
END;

¿Qué ocurre si falla solo la actualización del estado? 
Gracias al 'ROLLBACK TO sp_antes_estado', se deshace únicamente el UPDATE. El INSERT previo (la asignación) 
se mantiene activo en la transacción. Dependiendo de la lógica de negocio, se puede confirmar (COMMIT) 
para guardar solo la asignación, o deshacer todo haciendo un ROLLBACK general.
*/


/*
PREGUNTA 2
¿Qué es un Data Warehouse y cómo se diferencia de una base de datos transaccional? 
Describe cómo diseñarías un modelo dimensional (tabla de hechos y al menos dos dimensiones) 
para analizar las horas trabajadas por agente y por severidad de incidente. 
¿Qué ventajas tiene este modelo para consultas analíticas versus consultar directamente las tablas transaccionales?

Respuesta:
- Base de datos transaccional (OLTP): Está optimizada para alta concurrencia, escrituras rápidas y procesos del día a día. Sus tablas están altamente normalizadas para evitar la redundancia.
- Data Warehouse (OLAP): Está diseñado para el análisis histórico y lectura masiva de datos. Su estructura está desnormalizada (como el esquema de estrella).

Modelo Dimensional propuesto (Esquema de Estrella):
1. Tabla de Hechos (Fact_Horas): Contiene la métrica principal. Sus columnas clave son IdAgente, IdSeveridad, e IdFecha. La métrica (medida) es "horas_trabajadas".
2. Dimensión 1 (Dim_Agente): Contiene datos descriptivos del agente (IdAgente, Nombre, Especialidad).
3. Dimensión 2 (Dim_Severidad): Contiene datos de la severidad (IdSeveridad, Nivel, Descripcion).

Ventajas para consultas analíticas:
Al estar desnormalizado, se reducen enormemente las operaciones complejas (JOINs masivos). Esto permite agrupar y sumar millones de registros históricos (como las horas trabajadas) de forma muchísimo más rápida y eficiente que si se consultara el modelo relacional transaccional.
*/


/*
PREGUNTA 3
Explica cómo se implementa la herencia en Oracle usando tipos de objetos. Da un ejemplo de 
una jerarquía de dos niveles: Agente → AgenteEspecialista → AgentePentester, donde cada 
nivel agrega atributos y sobreescribe un método calcular_costo(). ¿Qué implicancias tiene 
declarar un tipo como NOT INSTANTIABLE?

Respuesta:
En Oracle, la herencia se logra utilizando la cláusula NOT FINAL en el tipo padre y la 
cláusula UNDER para indicar de qué tipo se hereda.

Ejemplo:
-- Nivel 1 (Base)
CREATE TYPE Agente AS OBJECT (
  id NUMBER,
  nombre VARCHAR2(100),
  MEMBER FUNCTION calcular_costo RETURN NUMBER
) NOT INSTANTIABLE NOT FINAL;

-- Nivel 2 (Primer subtipo)
CREATE TYPE AgenteEspecialista UNDER Agente (
  especialidad VARCHAR2(50),
  OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER
) NOT FINAL;

-- Nivel 3 (Segundo subtipo)
CREATE TYPE AgentePentester UNDER AgenteEspecialista (
  certificacion VARCHAR2(50),
  OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER
);

Implicancias de NOT INSTANTIABLE:
Funciona como una clase "abstracta" en lenguajes orientados a objetos. No se pueden crear 
objetos directamente del tipo "Agente". Solo se permite instanciar objetos de sus subtipos 
(AgenteEspecialista o AgentePentester).
*/


/*
PREGUNTA 4
Describe las ventajas y desventajas de usar índices y particiones en una base de datos. 
¿Cómo usarías un índice compuesto y una partición por rango para mejorar el rendimiento 
de consultas en la tabla Incidentes filtradas por Severidad y FechaDeteccion? 
Explica qué es el partition pruning y cómo impacta en el plan de ejecución.

Respuesta:
Índices:
- Ventajas: Aceleran drásticamente las búsquedas, agrupaciones y ordenamientos.
- Desventajas: Ocupan espacio extra en disco y ralentizan las escrituras (INSERT/UPDATE/DELETE) ya que deben actualizarse.

Particiones:
- Ventajas: Permite dividir una tabla gigante en trozos pequeños manejables. Facilita la administración (ej. archivado de datos viejos) y mejora consultas al ignorar particiones irrelevantes.
- Desventajas: Añade complejidad al diseño de la BD. Si las consultas no filtran por la clave de partición, el rendimiento puede ser peor.

Uso Combinado (Incidentes):
Implementaría una partición por rango (Range Partition) sobre FechaDeteccion (por ejemplo, una partición por mes o trimestre). Además, crearía un índice compuesto LOCAL en las columnas (Severidad, FechaDeteccion).

Partition Pruning (Poda de particiones):
Es la capacidad del optimizador de descartar automáticamente las particiones que no contienen datos útiles para la consulta. 
Impacto en el plan de ejecución: Al filtrar por FechaDeteccion, en lugar de realizar un escaneo completo de una tabla de 10 años ("Full Table Scan"), el motor solo leerá los bloques de la partición correspondiente al rango de fechas solicitado ("Partition Range Single"), multiplicando la velocidad de respuesta.
*/

-- EJERCICIO 1
/*
Escribe un procedimiento registrar_asignacion que reciba un AgenteID, IncidenteID, Horas y Rol. 
Validaciones: agente no supera 100 hrs en incidentes abiertos, incidente no tiene 3 o más agentes. 
Usar savepoints independientes para cada validación.
*/

CREATE OR REPLACE PROCEDURE registrar_asignacion (
    p_AgenteID    IN NUMBER,
    p_IncidenteID IN NUMBER,
    p_Horas       IN NUMBER,
    p_Rol         IN VARCHAR2
) IS
    v_next_id      NUMBER;
    v_total_horas  NUMBER;
    v_cant_agentes NUMBER;
BEGIN
    -- Validacion 1: Límite de 3 agentes por incidente
    SAVEPOINT sp_val_agentes;
    SELECT COUNT(DISTINCT AgenteID) INTO v_cant_agentes
    FROM Asignaciones
    WHERE IncidenteID = p_IncidenteID;
    
    IF v_cant_agentes >= 3 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El incidente ya tiene 3 o más agentes asignados.');
    END IF;

    -- Validacion 2: Límite de 100 horas totales por agente en incidentes abiertos
    SAVEPOINT sp_val_horas;
    SELECT NVL(SUM(a.Horas), 0) + p_Horas INTO v_total_horas
    FROM Asignaciones a
    JOIN Incidentes i ON a.IncidenteID = i.IncidenteID
    WHERE a.AgenteID = p_AgenteID 
      AND i.Estado = 'Abierto';
      
    IF v_total_horas > 100 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El agente supera las 100 horas en incidentes abiertos.');
    END IF;

    -- Inserción
    SAVEPOINT sp_insert_asig;
    SELECT NVL(MAX(AsignacionID), 0) + 1 INTO v_next_id FROM Asignaciones;
    
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (v_next_id, p_AgenteID, p_IncidenteID, p_Horas, p_Rol);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Asignación registrada exitosamente con ID ' || v_next_id);
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        -- Un fallo no deshace validaciones/operaciones previas. 
        -- Hacemos rollback solo hasta el punto en que falló la validación o inserción.
        IF SQLCODE = -20001 THEN
            ROLLBACK TO sp_val_agentes;
        ELSIF SQLCODE = -20002 THEN
            ROLLBACK TO sp_val_horas;
        ELSE
            ROLLBACK;
        END IF;
END;
/


-- EJERCICIO 2
/* 
Diseña las tablas Fact_Asignaciones, Dim_Agente y Dim_Incidente para un Data Warehouse. 
Luego escribe una consulta analítica.
*/

-- 1. Diseño del Data Warehouse
CREATE TABLE Dim_Agente_DW (
    AgenteKey    NUMBER PRIMARY KEY,
    AgenteID     NUMBER,
    Nombre       VARCHAR2(50),
    Especialidad VARCHAR2(50)
);

CREATE TABLE Dim_Incidente_DW (
    IncidenteKey NUMBER PRIMARY KEY,
    IncidenteID  NUMBER,
    Severidad    VARCHAR2(20),
    Estado       VARCHAR2(20)
);

CREATE TABLE Fact_Asignaciones_DW (
    AsignacionKey NUMBER PRIMARY KEY,
    AgenteKey     NUMBER,
    IncidenteKey  NUMBER,
    Horas         NUMBER,
    FOREIGN KEY (AgenteKey) REFERENCES Dim_Agente_DW(AgenteKey),
    FOREIGN KEY (IncidenteKey) REFERENCES Dim_Incidente_DW(IncidenteKey)
);

-- 2. Consulta analítica sobre tablas transaccionales
SELECT 
    ag.Nombre, 
    SUM(a.Horas) AS Total_Horas, 
    COUNT(DISTINCT a.IncidenteID) AS Numero_Incidentes
FROM Agentes ag
JOIN Asignaciones a ON ag.AgenteID = a.AgenteID
GROUP BY ag.Nombre
ORDER BY Total_Horas DESC;


-- EJERCICIO 3
/*
Crea índice compuesto, tabla particionada, consulta con EXPLAIN PLAN y ventaja de la partición.
*/

-- 1. Índice compuesto en Incidentes
CREATE INDEX idx_inc_sev_fec ON Incidentes(Severidad, FechaDeteccion);

-- 2. Creación de la tabla Incidentes particionada por rango (Se llama Incidentes_Part_P3 para el ejercicio)
CREATE TABLE Incidentes_Part_P3 (
    IncidenteID    NUMBER PRIMARY KEY,
    Descripcion    VARCHAR2(100),
    Severidad      VARCHAR2(20),
    Estado         VARCHAR2(20),
    FechaDeteccion DATE
)
PARTITION BY RANGE (FechaDeteccion) (
    PARTITION p_2026_q1 VALUES LESS THAN (TO_DATE('2026-04-01', 'YYYY-MM-DD')),
    PARTITION p_2026_q2 VALUES LESS THAN (TO_DATE('2026-07-01', 'YYYY-MM-DD')),
    PARTITION p_2026_q3 VALUES LESS THAN (TO_DATE('2026-10-01', 'YYYY-MM-DD')),
    PARTITION p_2026_q4 VALUES LESS THAN (TO_DATE('2027-01-01', 'YYYY-MM-DD'))
);

-- 3. Consulta y Plan de Ejecución
EXPLAIN PLAN FOR
SELECT i.IncidenteID, SUM(a.Horas) AS Total_Horas
FROM Incidentes_Part_P3 i
JOIN Asignaciones a ON i.IncidenteID = a.IncidenteID
WHERE i.Severidad = 'Critical'
  AND i.FechaDeteccion >= TO_DATE('2026-01-01', 'YYYY-MM-DD')
  AND i.FechaDeteccion < TO_DATE('2026-04-01', 'YYYY-MM-DD')
GROUP BY i.IncidenteID;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

/*
Ventaja que aporta la partición (Partition Pruning): 
Al buscar incidentes de 'Critical' únicamente para el primer trimestre de 2026 (Q1), 
el motor de la base de datos detecta automáticamente que solo necesita acceder a la 
partición "p_2026_q1". Todas las particiones del resto del año son ignoradas (podadas), 
lo que reduce radicalmente las operaciones de lectura de disco ("I/O") y acelera de 
manera drástica el rendimiento de la consulta.
*/