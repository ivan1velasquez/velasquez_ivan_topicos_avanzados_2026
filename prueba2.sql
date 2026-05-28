--Prueba 2 Iván Velásquez

--Pregunta 1

/*La principal diferencia entre ambas es que una función almacenada está obligada a 
devolver un único valor (usa RETURN) y se puede usar directamente dentro de consultas SQL, 
como por ejemplo; una función que calcule los días que lleva abierto un incidente para 
mostrarlo en un reporte. Mientras que un procedimiento ejecuta una secuencia de acciones en 
la base de datos, donde no está obligado a devolver nada y no se puede usar en un SELECT. Un 
ejemplo seria un procedimiento que ejecute el cierre mensual de todos los incidentes y 
archive los datos.*/


-- Pregunta 2

/* Yo utilizaría un parámetro IN OUT entrando al procedimiento con un valor inicial, 
que después la lógica interna lo modifique, para que devuelva el valor modificado 
en esa misma variable. Por lo tanto, el procedimiento no requiere retornar un valor por 
medio de la sentencia RETURN. Un ejemplo sería:

Procedimiento ajustar_horas_asignacion(id_asignacion: Entero, IN OUT horas_ajuste: Decimal)
Inicio
    // 1. Buscar las horas que ya tiene la asignación en la base de datos
    horas_actuales = ConsultarHorasDeAsignacion(id_asignacion)
    
    // 2. Calcular el nuevo total sumando el ajuste recibido
    nuevo_total = horas_actuales + horas_ajuste
    
    // 3. Modificar el registro en la base de datos con el nuevo valor
    ActualizarHorasEnBaseDatos(id_asignacion, nuevo_total)
    
    // 4. Guardar el nuevo total en la variable original para devolverlo
    horas_ajuste = nuevo_total
FinProcedimiento
*/

-- Pregunta 3

/*Para usar una función almacenada en una consulta, esta no debe realizar cambios en la 
base de datos. Se puede usar como cualquier función nativa de Oracle. Por lo tanto, se 
puede usar dentro de un SELECT. Un ejemplo sería:

Función total_horas_incidente(id_incidente: Entero) Devuelve Decimal
Inicio
    // Calcular la suma de todas las horas de este incidente
    suma = SumarHorasDeAsignacionesDonde(id_incidente)
    
    Si suma es Nulo Entonces
        suma = 0
    FinSi
    
    Retornar suma
FinFunción

--ejemplo consulta
SELECCIONAR id_incidente, descripcion, total_horas_incidente(id_incidente) AS horas_totales
DESDE TABLA Incidentes;
*/

--Pregunta 4

/*Un trigger es un bloque de código que se ejecuta automáticamente cuando ocurre un 
evento en una tabla. Para esto existen dos tipos de eventos: Eventos DML (INSERT, UPDATE, 
DELETE) y los eventos DDL (CREATE, ALTER). Un ejemplo de esto sería:

trigger trg_activar_incidente
CUANDO: DESPUÉS DE INSERTAR EN TABLA Asignaciones
PARA CADA FILA NUEVA
Inicio
    // Obtener el ID del incidente que se acaba de asociar
    id_reg = FILA_NUEVA.id_incidente
    
    // Si el incidente está 'Abierto', se cambia a 'En Proceso'
    Si ConsultarEstadoIncidente(id_reg) == "Abierto" Entonces
        ActualizarEstadoIncidente(id_reg, "En Proceso")
    FinSi
FinDisparador
*/

--Ejercicio 1

/*Escribe un procedimiento registrar_asignacion que reciba un AgenteID, IncidenteID, Horas y 
Rol (parámetros IN). El procedimiento debe: Insertar una nueva asignación en la tabla 
Asignaciones (usa el próximo AsignacionID disponible). Actualizar el estado del incidente 
a 'En Proceso' si estaba en 'Abierto'. Manejar excepciones si el agente o incidente no 
existen, o si el agente ya está asignado a ese incidente.
*/

CREATE OR REPLACE PROCEDURE registrar_asignacion (
    p_AgenteID    IN NUMBER,
    p_IncidenteID IN NUMBER,
    p_Horas       IN NUMBER,
    p_Rol         IN VARCHAR2
) IS
    v_existe_agente     NUMBER;
    v_existe_incidente  NUMBER;
    v_ya_asignado       NUMBER;
    v_estado_incidente  VARCHAR2(20);
    v_next_asignacionID NUMBER;

    ex_agente_no_existe     EXCEPTION;
    ex_incidente_no_existe  EXCEPTION;
    ex_ya_asignado          EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_existe_agente 
    FROM Agentes 
    WHERE AgenteID = p_AgenteID;
    
    IF v_existe_agente = 0 THEN
        RAISE ex_agente_no_existe;
    END IF;

    SELECT COUNT(*) INTO v_existe_incidente 
    FROM Incidentes 
    WHERE IncidenteID = p_IncidenteID;
    
    IF v_existe_incidente = 0 THEN
        RAISE ex_incidente_no_existe;
    ELSE
        SELECT Estado INTO v_estado_incidente 
        FROM Incidentes 
        WHERE IncidenteID = p_IncidenteID;
    END IF;

    SELECT COUNT(*) INTO v_ya_asignado 
    FROM Asignaciones 
    WHERE AgenteID = p_AgenteID AND IncidenteID = p_IncidenteID;
    
    IF v_ya_asignado > 0 THEN
        RAISE ex_ya_asignado;
    END IF;

    SELECT NVL(MAX(AsignacionID), 0) + 1 INTO v_next_asignacionID 
    FROM Asignaciones;

    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (v_next_asignacionID, p_AgenteID, p_IncidenteID, p_Horas, p_Rol);

    IF v_estado_incidente = 'Abierto' THEN
        UPDATE Incidentes
        SET Estado = 'En Proceso'
        WHERE IncidenteID = p_IncidenteID;
        DBMS_OUTPUT.PUT_LINE('Éxito: Asignación creada con ID ' || v_next_asignacionID || ' y estado del incidente actualizado a En Proceso.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Éxito: Asignación creada con ID ' || v_next_asignacionID || '. El estado del incidente no se modificó (' || v_estado_incidente || ').');
    END IF;

    COMMIT;

EXCEPTION
    WHEN ex_agente_no_existe THEN
        DBMS_OUTPUT.PUT_LINE('Error: El AgenteID ' || p_AgenteID || ' no existe en la base de datos.');
    WHEN ex_incidente_no_existe THEN
        DBMS_OUTPUT.PUT_LINE('Error: El IncidenteID ' || p_IncidenteID || ' no existe en la base de datos.');
    WHEN ex_ya_asignado THEN
        DBMS_OUTPUT.PUT_LINE('Error: El Agente ' || p_AgenteID || ' ya está asignado al Incidente ' || p_IncidenteID || '.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END
/

--prueba ejercicio 1
SET SERVEROUTPUT ON;

BEGIN
    DBMS_OUTPUT.PUT_LINE('PRUEBA 1: Caso de Éxito');
    registrar_asignacion(105, 202, 15, 'Apoyo');
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'PRUEBA 2: Error - Agente no existe');
    registrar_asignacion(999, 201, 10, 'Lider');

    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'PRUEBA 3: Error - Incidente no existe');
    registrar_asignacion(101, 999, 20, 'Apoyo');

    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'PRUEBA 4: Error - Ya asignado');
    registrar_asignacion(101, 201, 10, 'Investigador');
END;
/

--Ejercicio 2

/*Escribe una función calcular_horas_agente que reciba un AgenteID (parámetro IN) y 
devuelva el total de horas asignadas a ese agente en todos los incidentes. Luego, 
usa la función en un procedimiento mostrar_carga_agentes que muestre el total de horas 
por agente para todos los agentes, indicando su nombre y especialidad.*/

CREATE OR REPLACE FUNCTION calcular_horas_agente (
    p_AgenteID IN NUMBER
) RETURN NUMBER IS
    v_total_horas NUMBER := 0;
BEGIN
    SELECT NVL(SUM(Horas), 0) INTO v_total_horas
    FROM Asignaciones
    WHERE AgenteID = p_AgenteID;

    RETURN v_total_horas;
END;
/

CREATE OR REPLACE PROCEDURE mostrar_carga_agentes IS
    CURSOR c_agentes IS
        SELECT AgenteID, Nombre, Especialidad 
        FROM Agentes;
        
    v_horas_totales NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('REPORTES DE CARGA DE HORAS POR AGENTE:');
    FOR r_agente IN c_agentes LOOP
        v_horas_totales := calcular_horas_agente(r_agente.AgenteID);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || RPAD(r_agente.Nombre, 18) || 
                             ' | Especialidad: ' || RPAD(r_agente.Especialidad, 16) || 
                             ' | Total Horas: ' || v_horas_totales);
    END LOOP;    
END;
/

--prueba ejercicio 2
SET SERVEROUTPUT ON;

BEGIN
    DBMS_OUTPUT.PUT_LINE('PRUEBA 1: Uso individual de la función');
    DBMS_OUTPUT.PUT_LINE('Horas calculadas para Agente 101: ' || calcular_horas_agente(101));
    
    DBMS_OUTPUT.PUT_LINE(CHR(10) || 'PRUEBA 2: Ejecución del Procedimiento General');
    mostrar_carga_agentes;
END;
/

--Ejercicio 3

/*Implementa un sistema de auditoría manual usando un trigger. Para esto, primero crea una 
tabla llamada AuditoriaAsignaciones con las columnas necesarias. Luego, crea un trigger 
auditar_asignaciones que se dispare después de insertar o eliminar una asignación en la 
tabla Asignaciones. El trigger debe registrar en la tabla de auditoría el AsignacionID, 
AgenteID, IncidenteID, Horas, la acción realizada ('INSERT' o 'DELETE') y la fecha del 
registro.*/

CREATE TABLE AuditoriaAsignaciones (
    AuditoriaID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    AsignacionID NUMBER,
    AgenteID NUMBER,
    IncidenteID NUMBER,
    Horas NUMBER,
    Accion VARCHAR2(10),
    Fecha DATE
);

CREATE OR REPLACE TRIGGER auditar_asignaciones
AFTER INSERT OR DELETE ON Asignaciones
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO AuditoriaAsignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Accion, Fecha)
        VALUES (:NEW.AsignacionID, :NEW.AgenteID, :NEW.IncidenteID, :NEW.Horas, 'INSERT', SYSDATE);
    ELSIF DELETING THEN
        INSERT INTO AuditoriaAsignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Accion, Fecha)
        VALUES (:OLD.AsignacionID, :OLD.AgenteID, :OLD.IncidenteID, :OLD.Horas, 'DELETE', SYSDATE);
    END IF;
END;
/

--prueba ejercicio 3

SET SERVEROUTPUT ON;

BEGIN
    DBMS_OUTPUT.PUT_LINE('EJECUTANDO PRUEBAS DEL TRIGGER');
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (999, 101, 203, 10, 'Prueba Auditoria');
    DBMS_OUTPUT.PUT_LINE('Registro 999 insertado.');
    DELETE FROM Asignaciones WHERE AsignacionID = 999;
    DBMS_OUTPUT.PUT_LINE('Registro 999 eliminado.');
END;
/