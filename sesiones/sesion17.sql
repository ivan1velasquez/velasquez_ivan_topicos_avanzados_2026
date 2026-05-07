--Sesion 17.1
/*Crea un usuario user_analista y un rol rol_analista. El rol debe tener permisos para 
consultar (SELECT) todas las tablas de curso_topicos y para insertar (INSERT) en la tabla 
Pedidos. Asigna el rol al usuario y prueba los permisos.*/

-- PASO 1: Conectar como sysdba
-- sqlplus sys/oracle@//localhost:1521/XEPDB1 as sysdba

-- Limpiar objetos previos si ya existen
DROP USER user_analista CASCADE;
DROP ROLE rol_analista;

-- Crear usuario
CREATE USER user_analista IDENTIFIED BY analista123;
GRANT CONNECT TO user_analista;

-- Crear rol y asignar permisos
CREATE ROLE rol_analista;
GRANT SELECT ON curso_topicos.Clientes TO rol_analista;
GRANT SELECT ON curso_topicos.Pedidos TO rol_analista;
GRANT SELECT ON curso_topicos.Productos TO rol_analista;
GRANT SELECT ON curso_topicos.DetallesPedidos TO rol_analista;
GRANT INSERT ON curso_topicos.Pedidos TO rol_analista;

-- Asignar rol al usuario
GRANT rol_analista TO user_analista;

-- PASO 2: Abrir nueva sesion como user_analista
-- sqlplus user_analista/analista123@//localhost:1521/XEPDB1

-- Probar permisos
SELECT * FROM curso_topicos.Clientes;
INSERT INTO curso_topicos.Pedidos (PedidoID, ClienteID, Total, FechaPedido)
VALUES (110, 1, 1500, TO_DATE('2025-06-01', 'YYYY-MM-DD'));
UPDATE curso_topicos.Clientes SET Nombre = 'Juan Pérez Modificado' WHERE ClienteID = 1;


--Sesion 17.2
/*Configura auditoría para monitorear las acciones de user_analista al consultar la tabla 
Clientes y al insertar en la tabla Pedidos. Realiza algunas acciones y verifica los 
registros de auditoría.*/

-- PASO 1: Conectar como sysdba
-- sqlplus sys/oracle@//localhost:1521/XEPDB1 as sysdba

-- Crear politica de auditoria
CREATE AUDIT POLICY pol_auditoria_analista
    ACTIONS SELECT ON curso_topicos.Clientes,
             INSERT ON curso_topicos.Pedidos;

-- Habilitar la politica para user_analista
AUDIT POLICY pol_auditoria_analista BY user_analista;

-- PASO 2: Conectar como user_analista y realizar acciones
-- sqlplus user_analista/analista123@//localhost:1521/XEPDB1

SELECT * FROM curso_topicos.Clientes;
INSERT INTO curso_topicos.Pedidos (PedidoID, ClienteID, Total, FechaPedido)
VALUES (111, 2, 2000, TO_DATE('2025-06-15', 'YYYY-MM-DD'));

-- PASO 3: Verificar registros de auditoria como sysdba
-- sqlplus sys/oracle@//localhost:1521/XEPDB1 as sysdba

SELECT event_timestamp, dbusername, action_name, object_name, return_code
FROM unified_audit_trail
WHERE dbusername = 'USER_ANALISTA'
ORDER BY event_timestamp DESC;
