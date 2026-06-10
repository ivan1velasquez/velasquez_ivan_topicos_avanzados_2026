--Sesion 22.1
/*Diseña (sin script) una estrategia de alta disponibilidad para el esquema curso_topicos:
Número de nodos y su ubicación geográfica.
Tipo de replicación (síncrona o asíncrona).
Uso de los nodos secundarios (por ejemplo, para reportes).
Mecanismo de failover.*/

/*
Estrategia de Alta Disponibilidad para curso_topicos
 - Nodos:
   * Nodo principal: Santiago, Chile
   * Nodo standby: Valparaíso, Chile
 - Replicación: Asíncrona con Oracle Data Guard
   * Motivo: Menor latencia en el nodo principal, aceptable para este sistema
 - Uso del nodo standby:
   * Consultas de solo lectura (reportes de ventas) usando Active Data Guard
 - Failover:
   * Configurar Fast-Start Failover para cambio automático al nodo standby
   * MTTR objetivo: 5 minutos
 - Consideraciones:
   * Respaldo completo semanal y archivelogs diarios (integrado con la estrategia de 
   Sesión 22)
   * Monitoreo: Usar Oracle Enterprise Manager para alertas de fallos
*/

--Sesion 22.1
/*Escribe una consulta de solo lectura que podría ejecutarse en el nodo standby para generar 
un reporte de ventas por cliente. Explica cómo aprovecharías Active Data Guard.*/

SELECT c.ClienteID, c.Nombre, SUM(p.Total) AS TotalVentas
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE p.FechaPedido BETWEEN TO_DATE('2025-01-01', 'YYYY-MM-DD') AND TO_DATE('2025-06-30', 'YYYY-MM-DD')
GROUP BY c.ClienteID, c.Nombre
ORDER BY TotalVentas DESC;
