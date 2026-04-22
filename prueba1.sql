-- PRUEBA 1 IVÁN VELÁSQUEZ CAMPOS

--Pregunta 1
/*Una relación de muchos a muchos consiste en como dos entitades se relacionan entre 
sí, donde por ejemplo N elementos de una tabla 1 tiene M elementos de una tabla 2,
o viceversa, donde para poder realizar esta relacion se necesita de una tabla
intermedia para realizarla. Un ejemplo aplicado a esta prueba se ve en la tabla final
de Asignaciones, que es la tabla intermedia entre la tabla Agentes y la tabla
Incidentes, donde más de un agente puede estar asignado a más de un incidente. Como 
por ejemplo el agente 101 esta asignado tanto al incidente 201 como a 204, y a su
vez el incidente 201 tiene asignado a los agentes 101, 102 y 104.*/

--Pregunta 2
/*Una vista es un tipo de tabla que se crea en base a consultas/subconsultas de tablas
ya existentes, pudiendo visualizar y seleccionar elementos filtrados de una tabla, como
también poder relacionarlos con elementos de otras tablas. Como se pide en la pregunta
, un ejemplo de esto sería poder visualizar las horas totales dedicadas a cada
incidente, su descripción y severidad. Que sería lo siguiente:

CREATE OR REPLACE VIEW Vista_Horas_Incidentes AS
SELECT i.IncidenteID, i.Descripcion, i.Severidad, SUM(a.Horas) AS TotalHoras
FROM Incidentes i
JOIN Asignaciones a ON i.IncidenteID = a.IncidenteID
GROUP BY i.IncidenteID, i.Descripcion, i.Severidad;
*/

--Pregunta 3
/*Las excepciones predefinidas son funciones encargadas de señalar errores comunes ya instanciadas en PL/SQL. En el caso de NO_DATA_FOUND
, esta se encarga de señalar que no se encontro una tabla o dato señalado o solicitado por una consulta, generalmente por que no existe.*/

--Pregunta 4
/*Un cursor explicito es un tipo de puntero encargado de buscar y recorrer tablas de manera dinámica, donde para poder comenzar un cursor
primero hay que declarlo con DECLARE, luego se utiliza LOOP, para recorrerlo hasta y rescatar elementos con FETCH hasta 
no encontrar datos con %NOTFOUND, para finalmente cerrarlo con CLOSE.*/

--Ejercicio 1
/*Escribe un bloque PL/SQL con un cursor explícito que liste las especialidades de agentes cuyo promedio de horas asignadas a 
incidentes sea mayor a 30, mostrando la especialidad y el promedio de horas. Usa un JOIN entre Agentes y Asignaciones.*/
SET SERVEROUTPUT ON;

DECLARE 
    CURSOR agentes_cursor IS
        SELECT a.Especialidad, AVG(asig.Horas) AS PromedioHoras
        FROM Agentes a
        JOIN Asignaciones asig ON a.AgenteID = asig.AgenteID
        GROUP BY a.Especialidad
        HAVING AVG(asig.Horas) > 30;
        
    v_especialidad Agentes.Especialidad%TYPE;
    v_promedio_horas NUMBER;
BEGIN
    OPEN agentes_cursor;
    LOOP
        FETCH agentes_cursor INTO v_especialidad, v_promedio_horas;
        EXIT WHEN agentes_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Especialidad: ' || v_especialidad || ', Promedio de Horas: ' || v_promedio_horas);
    END LOOP;
    CLOSE agentes_cursor;

    IF agentes_cursor%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('No se encontraron agentes con promedio de horas mayor a 30.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    IF agentes_cursor%ISOPEN THEN
        CLOSE agentes_cursor;
    END IF;
END;
/

--Ejercicio 2
/*Escribe un bloque PL/SQL con un cursor explícito que aumente en 10 las horas de todas las asignaciones asociadas a incidentes 
con severidad 'Critical'. Usa FOR UPDATE y maneja excepciones.*/
SET SERVEROUTPUT ON;

DECLARE 
    CURSOR asignaciones_cursor IS
        SELECT a.Horas
        FROM Asignaciones a
        JOIN Incidentes i ON a.IncidenteID = i.IncidenteID
        WHERE i.Severidad = 'Critical'
        FOR UPDATE;
        v_horas NUMBER;
BEGIN
    OPEN asignaciones_cursor;
    LOOP
        FETCH asignaciones_cursor INTO v_horas;
        EXIT WHEN asignaciones_cursor%NOTFOUND;
        UPDATE Asignaciones
        SET Horas = v_horas + 10
        WHERE CURRENT OF asignaciones_cursor;
    END LOOP;
    CLOSE asignaciones_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        IF asignaciones_cursor%ISOPEN THEN
            CLOSE asignaciones_cursor;
        END IF;
END;
/

--Respuesta 3
/*Tipo de Objeto (20 pts) Crea un tipo de objeto incidente_obj con atributos incidente_id, descripcion, y un método get_reporte. 
Luego, crea una tabla basada en ese tipo y transfiere los datos de Incidentes a esa tabla. Finalmente, escribe un cursor explícito 
que liste la información de los incidentes usando el método get_reporte.*/
SET SERVEROUTPUT ON;

CREATE OR REPLACE TYPE incidente_obj AS OBJECT (
  incidente_id NUMBER,
  descripcion   VARCHAR2(100),
  MEMBER FUNCTION get_reporte RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY incidente_obj AS
  MEMBER FUNCTION get_reporte RETURN VARCHAR2 IS
  BEGIN
    RETURN 'IncidenteID: ' || incidente_id || ', Descripcion: ' || descripcion;
  END;
END;
/
CREATE TABLE incidentes_obj_tab OF incidente_obj(incidente_id PRIMARY KEY);
INSERT INTO incidentes_obj_tab (incidente_id, descripcion)
SELECT IncidenteID, Descripcion FROM Incidentes;

DECLARE
    CURSOR incidentes_cursor IS
        SELECT VALUE(i) AS inc_obj FROM incidentes_obj_tab i;
    v_incidente_obj incidente_obj;
BEGIN
    OPEN incidentes_cursor;
    LOOP
        FETCH incidentes_cursor INTO v_incidente_obj;
        EXIT WHEN incidentes_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_incidente_obj.get_reporte);
    END LOOP;
    CLOSE incidentes_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    IF incidentes_cursor%ISOPEN THEN
        CLOSE incidentes_cursor;
    END IF;
END;
/







