--Ejercicio Sesion 3
--Riesgo de temperaturas en 3 ciudades distintas
-- Tempertura alta = 25 grados o más
-- Temperatura media = entre 15 y 25 grados
-- Temperatura baja = menos de 15 grados

DECLARE
    v_temperatura_ciudadA NUMBER := 28;
    v_temperatura_ciudadB NUMBER := 20;
    v_temperatura_ciudadC NUMBER := 15;
BEGIN
    IF v_temperatura_ciudadA >= 25 THEN
        DBMS_OUTPUT.PUT_LINE('Ciudad A: Temperatura alta');
    ELSIF v_temperatura_ciudadA >= 15 THEN
        DBMS_OUTPUT.PUT_LINE('Ciudad A: Temperatura media');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Ciudad A: Temperatura baja');
    END IF;

    IF v_temperatura_ciudadB >= 25 THEN
        DBMS_OUTPUT.PUT_LINE('Ciudad B: Temperatura alta');
    ELSIF v_temperatura_ciudadB >= 15 THEN
        DBMS_OUTPUT.PUT_LINE('Ciudad B: Temperatura media');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Ciudad B: Temperatura baja');
    END IF;

    IF v_temperatura_ciudadC >= 25 THEN
        DBMS_OUTPUT.PUT_LINE('Ciudad C: Temperatura alta');
    ELSIF v_temperatura_ciudadC >= 15 THEN
        DBMS_OUTPUT.PUT_LINE('Ciudad C: Temperatura media');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Ciudad C: Temperatura baja');
    END IF;
END;
/