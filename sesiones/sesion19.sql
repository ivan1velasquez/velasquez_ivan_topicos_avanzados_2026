--Sesion 19.1
/*Diseña una estrategia de respaldo para el esquema curso_topicos. Documenta la estrategia en 
comentarios y escribe un script RMAN para un respaldo completo y un respaldo incremental*/

-- Estrategia de Respaldo
-- - Respaldo completo: Cada domingo a las 23:00
-- - Respaldo incremental (nivel 1): Diariamente a las 23:00
-- - Retención: Mantener respaldos de las últimas 2 semanas
-- - Ubicación: Disco local (/u01/backup) y copia en la nube (AWS S3)

-- Script RMAN para respaldo completo
rman target /

CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 14 DAYS;
CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '/u01/backup/%U';

RUN {
	BACKUP DATABASE PLUS ARCHIVELOG;
	DELETE OBSOLETE;
}

-- Script RMAN para respaldo incremental
RUN {
	BACKUP INCREMENTAL LEVEL 1 DATABASE;
	BACKUP ARCHIVELOG ALL;
}

LIST BACKUP;

--Sesion 19.2
/*Simula un fallo eliminando la tabla Productos y recupera los datos usando Flashback 
(si está habilitado) o RMAN. Documenta el proceso.*/

-- Simular fallo
DROP TABLE Productos;

-- Verificar
SELECT COUNT(*) FROM Productos; -- Error: tabla no existe

-- Recuperar con Flashback (si está habilitado)
FLASHBACK TABLE Productos TO BEFORE DROP;

-- Si Flashback no está habilitado, usar RMAN
rman target /

SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
RUN {
	RESTORE TABLE curso_topicos.Productos;
	RECOVER TABLE curso_topicos.Productos;
}
ALTER DATABASE OPEN;

-- Verificar
SELECT COUNT(*) FROM Productos; -- Debería mostrar 2 filas

