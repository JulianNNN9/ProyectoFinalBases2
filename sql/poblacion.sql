-- Desactivar todos los triggers del esquema
BEGIN
  FOR r IN (SELECT trigger_name FROM user_triggers) LOOP
    EXECUTE IMMEDIATE 'ALTER TRIGGER ' || r.trigger_name || ' DISABLE';
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Todos los triggers han sido desactivados');
END;
/

-- ==================================================
-- POBLACIÓN DE TABLAS FALTANTES
-- ==================================================

-- PREGUNTAS (30 registros)
INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (101, '¿Cuál es el principal componente de un sistema de base de datos relacional?', SYSTIMESTAMP - INTERVAL '100' DAY, 'S', 60, 2, 1, 1, 'El componente principal es el RDBMS que gestiona los datos estructurados en tablas relacionadas.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (102, 'Identifique las propiedades ACID en bases de datos:', SYSTIMESTAMP - INTERVAL '99' DAY, 'S', 120, 1, 2, 2, 'Las propiedades ACID son Atomicidad, Consistencia, Aislamiento y Durabilidad.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (103, '¿Es verdad que los índices siempre mejoran el rendimiento de las consultas?', SYSTIMESTAMP - INTERVAL '98' DAY, 'S', 30, 3, 3, 3, 'No siempre. Para tablas pequeñas o con muchas actualizaciones, los índices pueden reducir el rendimiento.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (104, 'Ordene los siguientes pasos del proceso de normalización:', SYSTIMESTAMP - INTERVAL '97' DAY, 'S', 180, 4, 4, 4, 'El orden correcto es: identificar dependencias funcionales, eliminar dependencias parciales, eliminar dependencias transitivas.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (105, 'Complete la siguiente sentencia SQL: SELECT * FROM empleados WHERE _____ BETWEEN 30000 AND 50000;', SYSTIMESTAMP - INTERVAL '96' DAY, 'S', 45, 5, 5, 5, 'La respuesta correcta es "salario" para completar la consulta de rango salarial.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (106, 'Empareje cada comando SQL con su categoría:', SYSTIMESTAMP - INTERVAL '95' DAY, 'S', 90, 6, 6, 6, 'SELECT pertenece a DQL, INSERT a DML, CREATE a DDL y GRANT a DCL.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (107, '¿Cuáles son las ventajas de utilizar procedimientos almacenados?', SYSTIMESTAMP - INTERVAL '94' DAY, 'S', 120, 1, 7, 7, 'Las ventajas incluyen mejor rendimiento, seguridad, reutilización y consistencia.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (108, '¿Qué arquitectura de base de datos es mejor para sistemas de alta disponibilidad?', SYSTIMESTAMP - INTERVAL '93' DAY, 'S', 60, 2, 8, 8, 'Arquitecturas distribuidas con replicación son ideales para alta disponibilidad.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (109, '¿Es correcto utilizar UNION ALL para combinar resultados duplicados de dos consultas?', SYSTIMESTAMP - INTERVAL '92' DAY, 'S', 30, 3, 9, 9, 'Sí, UNION ALL conserva duplicados mientras que UNION los elimina.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (110, 'Ordene las siguientes operaciones de JOIN según su complejidad computacional:', SYSTIMESTAMP - INTERVAL '91' DAY, 'S', 180, 4, 10, 10, 'INNER JOIN suele ser el más eficiente, seguido por LEFT JOIN, RIGHT JOIN y FULL JOIN.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (111, 'Complete el tipo de constraint: ALTER TABLE empleados ADD CONSTRAINT pk_emp _____ (empleado_id);', SYSTIMESTAMP - INTERVAL '90' DAY, 'S', 45, 5, 11, 11, 'La respuesta correcta es "PRIMARY KEY".');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (112, 'Empareje cada anomalía con su forma normal de resolución:', SYSTIMESTAMP - INTERVAL '89' DAY, 'S', 90, 6, 12, 12, 'Redundancia - 1FN, Dependencia parcial - 2FN, Dependencia transitiva - 3FN.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (113, '¿Qué técnicas pueden mejorar el rendimiento de consultas en bases de datos grandes?', SYSTIMESTAMP - INTERVAL '88' DAY, 'S', 120, 1, 13, 13, 'Particionamiento, indexación, optimización de consultas y cacheo son técnicas efectivas.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (114, '¿Cuál es el mejor tipo de índice para búsquedas por rango?', SYSTIMESTAMP - INTERVAL '87' DAY, 'S', 60, 2, 14, 14, 'Los índices B-tree son generalmente los mejores para búsquedas por rango.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (115, '¿Es recomendable usar transacciones para operaciones de lectura?', SYSTIMESTAMP - INTERVAL '86' DAY, 'S', 30, 3, 15, 15, 'Depende del nivel de aislamiento requerido; para lecturas consistentes, sí es recomendable.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (116, 'Ordene los siguientes pasos de recuperación ante fallos:', SYSTIMESTAMP - INTERVAL '85' DAY, 'S', 180, 4, 16, 16, 'Identificar el problema, aplicar logs de transacciones, restaurar desde backup, verificar integridad.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (117, 'Complete: SELECT COUNT(*) FROM productos GROUP BY _____ HAVING COUNT(*) > 5;', SYSTIMESTAMP - INTERVAL '84' DAY, 'S', 45, 5, 17, 17, 'La respuesta típica sería "categoria_id" para contar productos por categoría.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (118, 'Empareje cada término con su definición:', SYSTIMESTAMP - INTERVAL '83' DAY, 'S', 90, 6, 18, 18, 'Cardinality - número de filas, Selectivity - proporción de filas seleccionadas, Collation - orden de clasificación.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (119, '¿Qué medidas de seguridad son esenciales para proteger una base de datos?', SYSTIMESTAMP - INTERVAL '82' DAY, 'S', 120, 1, 19, 19, 'Autenticación fuerte, cifrado, control de acceso, auditoría y respaldos son esenciales.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (120, '¿Qué modelo de base de datos es más adecuado para datos jerárquicos?', SYSTIMESTAMP - INTERVAL '81' DAY, 'S', 60, 2, 20, 20, 'NoSQL basado en documentos o bases de datos de grafos suelen ser mejores para datos jerárquicos.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (121, '¿Un índice clustered mejora siempre el rendimiento de escritura?', SYSTIMESTAMP - INTERVAL '80' DAY, 'S', 30, 3, 21, 21, 'No, puede ralentizar las escrituras porque requiere reorganizar físicamente la tabla.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (122, 'Ordene las siguientes tecnologías según su aparición histórica:', SYSTIMESTAMP - INTERVAL '79' DAY, 'S', 180, 4, 22, 22, 'Bases de datos jerárquicas, relacionales, objeto-relacionales, NoSQL, NewSQL.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (123, 'Complete: CREATE _____ INDEX idx_nombre ON clientes(nombre);', SYSTIMESTAMP - INTERVAL '78' DAY, 'S', 45, 5, 23, 23, 'La respuesta correcta puede ser "UNIQUE" o "BITMAP" dependiendo del contexto.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (124, 'Empareje cada problema con su solución:', SYSTIMESTAMP - INTERVAL '77' DAY, 'S', 90, 6, 24, 24, 'Deadlock - detección y rollback, Fragmentación - reconstrucción, Corrupción - backup y restore.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (125, '¿Qué estrategias existen para escalar horizontalmente una base de datos?', SYSTIMESTAMP - INTERVAL '76' DAY, 'S', 120, 1, 25, 25, 'Sharding, replicación, federación y clustering son estrategias comunes.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (126, '¿Cuál es la mejor estructura para almacenar datos geoespaciales?', SYSTIMESTAMP - INTERVAL '75' DAY, 'S', 60, 2, 1, 1, 'Índices espaciales como R-tree o tipos de datos geométricos especializados.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (127, '¿Las vistas materializadas necesitan ser refrescadas manualmente?', SYSTIMESTAMP - INTERVAL '74' DAY, 'S', 30, 3, 2, 2, 'Depende de la configuración; pueden refrescarse automáticamente o manualmente.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (128, 'Ordene estos pasos para diseñar un esquema de particionamiento:', SYSTIMESTAMP - INTERVAL '73' DAY, 'S', 180, 4, 3, 3, 'Analizar patrones de acceso, elegir clave de partición, determinar método, implementar y probar.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (129, 'Complete: ALTER TABLE empleados _____ COLUMN direccion VARCHAR(100);', SYSTIMESTAMP - INTERVAL '72' DAY, 'S', 45, 5, 4, 4, 'La respuesta correcta es "ADD" para añadir una nueva columna.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (130, 'Empareje cada tipo de base de datos con su caso de uso ideal:', SYSTIMESTAMP - INTERVAL '71' DAY, 'S', 90, 6, 5, 5, 'Relacional - transacciones, Columnar - análisis, Documental - contenido, Grafos - relaciones complejas.');

-- OPCIONES_PREGUNTAS (Para preguntas de opción múltiple y única)
-- Para pregunta 101 (opción única)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1001, 'Tablas', 'N', 1, 101);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1002, 'Sistema Gestor de Base de Datos (SGBD)', 'S', 2, 101);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1003, 'Índices', 'N', 3, 101);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1004, 'Consultas SQL', 'N', 4, 101);

-- Para pregunta 102 (opción múltiple)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1005, 'Atomicidad', 'S', 1, 102);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1006, 'Consistencia', 'S', 2, 102);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1007, 'Aislamiento', 'S', 3, 102);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1008, 'Durabilidad', 'S', 4, 102);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1009, 'Escalabilidad', 'N', 5, 102);

-- Para pregunta 103 (V/F)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1010, 'Verdadero', 'N', 1, 103);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1011, 'Falso', 'S', 2, 103);

-- Para pregunta 108 (opción única)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1012, 'Arquitectura centralizada monolítica', 'N', 1, 108);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1013, 'Arquitectura distribuida con replicación', 'S', 2, 108);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1014, 'Arquitectura de un solo nodo sin respaldo', 'N', 3, 108);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1015, 'Arquitectura en memoria sin persistencia', 'N', 4, 108);

-- Para pregunta 109 (V/F)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1016, 'Verdadero', 'S', 1, 109);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1017, 'Falso', 'N', 2, 109);

-- Para pregunta 114 (opción única)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1018, 'Índice Hash', 'N', 1, 114);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1019, 'Índice B-tree', 'S', 2, 114);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1020, 'Índice Bitmap', 'N', 3, 114);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1021, 'Índice Full-text', 'N', 4, 114);

-- Para pregunta 115 (V/F)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1022, 'Verdadero', 'S', 1, 115);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1023, 'Falso', 'N', 2, 115);

-- Para pregunta 120 (opción única)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1024, 'Modelo relacional tradicional', 'N', 1, 120);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1025, 'NoSQL basado en documentos', 'S', 2, 120);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1026, 'Base de datos columnar', 'N', 3, 120);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1027, 'Base de datos de objetos', 'N', 4, 120);

-- Para pregunta 121 (V/F)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1028, 'Verdadero', 'N', 1, 121);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1029, 'Falso', 'S', 2, 121);

-- Para pregunta 126 (opción única)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1030, 'Índices B-tree estándar', 'N', 1, 126);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1031, 'Índices espaciales R-tree', 'S', 2, 126);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1032, 'Tablas de hash', 'N', 3, 126);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1033, 'Listas enlazadas', 'N', 4, 126);

-- Para pregunta 127 (V/F)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1034, 'Verdadero', 'N', 1, 127);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1035, 'Falso', 'S', 2, 127);

-- ORDEN_PREGUNTAS (Para preguntas de ordenar)
-- Para pregunta 104
INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2001, 'Identificar dependencias funcionales', 1, 104);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2002, 'Eliminar dependencias parciales', 2, 104);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2003, 'Eliminar dependencias transitivas', 3, 104);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2004, 'Aplicar forma normal de Boyce-Codd', 4, 104);

-- Para pregunta 110
INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2005, 'INNER JOIN', 1, 110);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2006, 'LEFT JOIN', 2, 110);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2007, 'RIGHT JOIN', 3, 110);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2008, 'FULL OUTER JOIN', 4, 110);

-- Para pregunta 116
INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2009, 'Identificar el problema y evaluar el impacto', 1, 116);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2010, 'Restaurar desde el último backup válido', 2, 116);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2011, 'Aplicar logs de transacciones hasta el punto de fallo', 3, 116);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2012, 'Verificar integridad y consistencia de los datos', 4, 116);

-- Para pregunta 122
INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2013, 'Bases de datos jerárquicas', 1, 122);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2014, 'Bases de datos relacionales', 2, 122);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2015, 'Bases de datos objeto-relacionales', 3, 122);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2016, 'Bases de datos NoSQL', 4, 122);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2017, 'Bases de datos NewSQL', 5, 122);

-- Para pregunta 128
INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2018, 'Analizar patrones de acceso a los datos', 1, 128);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2019, 'Elegir la clave de partición apropiada', 2, 128);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2020, 'Determinar el método de particionamiento', 3, 128);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2021, 'Implementar la estrategia de particionamiento', 4, 128);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2022, 'Probar y ajustar el rendimiento', 5, 128);

-- EMPAREJAMIENTO_PREGUNTAS (Para preguntas de emparejar)
-- Para pregunta 106
INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3001, 'SELECT', 'DQL (Data Query Language)', 106);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3002, 'INSERT', 'DML (Data Manipulation Language)', 106);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3003, 'CREATE', 'DDL (Data Definition Language)', 106);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3004, 'GRANT', 'DCL (Data Control Language)', 106);

-- Para pregunta 112
INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3005, 'Redundancia de datos', 'Primera Forma Normal (1FN)', 112);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3006, 'Dependencia parcial', 'Segunda Forma Normal (2FN)', 112);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3007, 'Dependencia transitiva', 'Tercera Forma Normal (3FN)', 112);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3008, 'Dependencia multivaluada', 'Cuarta Forma Normal (4FN)', 112);

-- Para pregunta 118
INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3009, 'Cardinalidad', 'Número de filas en una tabla', 118);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3010, 'Selectividad', 'Proporción de filas que cumplen un criterio', 118);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3011, 'Collation', 'Reglas de ordenación y comparación', 118);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3012, 'Clustering factor', 'Orden físico de filas en relación con un índice', 118);

-- Para pregunta 124
INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3013, 'Deadlock', 'Detección y rollback automático', 124);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3014, 'Fragmentación de índices', 'Reconstrucción o reorganización', 124);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3015, 'Corrupción de datos', 'Restauración desde backup', 124);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3016, 'Bloqueo prolongado', 'Timeout y cancelación', 124);

-- Para pregunta 130
INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3017, 'Base de datos relacional', 'Aplicaciones transaccionales (OLTP)', 130);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3018, 'Base de datos columnar', 'Análisis y reportes (OLAP)', 130);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3019, 'Base de datos documental', 'Gestión de contenidos y catálogos', 130);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3020, 'Base de datos de grafos', 'Redes sociales y relaciones complejas', 130);

-- EXAMENES (30 registros)
INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (201, 'Parcial 1: Fundamentos de Bases de Datos', SYSTIMESTAMP - INTERVAL '60' DAY, SYSTIMESTAMP - INTERVAL '50' DAY, SYSTIMESTAMP - INTERVAL '45' DAY, 120, 70, 10, 'S', 1, 1, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (202, 'Parcial 2: Normalización y Diseño', SYSTIMESTAMP - INTERVAL '40' DAY, SYSTIMESTAMP - INTERVAL '30' DAY, SYSTIMESTAMP - INTERVAL '25' DAY, 90, 65, 8, 'S', 2, 2, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (203, 'Quiz: SQL Básico', SYSTIMESTAMP - INTERVAL '35' DAY, SYSTIMESTAMP - INTERVAL '30' DAY, SYSTIMESTAMP - INTERVAL '29' DAY, 30, 60, 5, 'N', 3, 3, 2);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (204, 'Examen Final: Administración de BD', SYSTIMESTAMP - INTERVAL '20' DAY, SYSTIMESTAMP - INTERVAL '15' DAY, SYSTIMESTAMP - INTERVAL '14' DAY, 180, 75, 15, 'N', 4, 4, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (205, 'Práctica: Optimización de Consultas', SYSTIMESTAMP - INTERVAL '25' DAY, SYSTIMESTAMP - INTERVAL '20' DAY, SYSTIMESTAMP - INTERVAL '15' DAY, 120, 50, 10, 'S', 5, 5, 3);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (206, 'Evaluación: Transacciones y Concurrencia', SYSTIMESTAMP - INTERVAL '30' DAY, SYSTIMESTAMP - INTERVAL '28' DAY, SYSTIMESTAMP - INTERVAL '25' DAY, 90, 65, 8, 'S', 6, 6, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (207, 'Quiz: Índices y Rendimiento', SYSTIMESTAMP - INTERVAL '45' DAY, SYSTIMESTAMP - INTERVAL '43' DAY, SYSTIMESTAMP - INTERVAL '42' DAY, 20, 70, 5, 'N', 7, 7, 2);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (208, 'Parcial: Arquitectura de BD', SYSTIMESTAMP - INTERVAL '55' DAY, SYSTIMESTAMP - INTERVAL '50' DAY, SYSTIMESTAMP - INTERVAL '48' DAY, 75, 60, 7, 'S', 8, 8, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (209, 'Evaluación: Recuperación y Backup', SYSTIMESTAMP - INTERVAL '38' DAY, SYSTIMESTAMP - INTERVAL '35' DAY, SYSTIMESTAMP - INTERVAL '34' DAY, 60, 70, 6, 'N', 9, 9, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (210, 'Quiz Sorpresa: Seguridad en BD', SYSTIMESTAMP - INTERVAL '15' DAY, SYSTIMESTAMP - INTERVAL '15' DAY, SYSTIMESTAMP - INTERVAL '15' DAY, 15, 60, 3, 'S', 10, 10, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (211, 'Examen Parcial: BD NoSQL', SYSTIMESTAMP - INTERVAL '70' DAY, SYSTIMESTAMP - INTERVAL '65' DAY, SYSTIMESTAMP - INTERVAL '64' DAY, 90, 65, 8, 'N', 11, 11, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (212, 'Evaluación: Modelado de Datos', SYSTIMESTAMP - INTERVAL '80' DAY, SYSTIMESTAMP - INTERVAL '75' DAY, SYSTIMESTAMP - INTERVAL '73' DAY, 120, 70, 10, 'S', 12, 12, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (213, 'Quiz: Lenguajes de Consulta', SYSTIMESTAMP - INTERVAL '90' DAY, SYSTIMESTAMP - INTERVAL '88' DAY, SYSTIMESTAMP - INTERVAL '87' DAY, 30, 60, 5, 'N', 13, 13, 2);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (214, 'Parcial: Programación en BD', SYSTIMESTAMP - INTERVAL '65' DAY, SYSTIMESTAMP - INTERVAL '60' DAY, SYSTIMESTAMP - INTERVAL '58' DAY, 150, 75, 12, 'S', 14, 14, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (215, 'Evaluación: Replicación y Distribución', SYSTIMESTAMP - INTERVAL '75' DAY, SYSTIMESTAMP - INTERVAL '72' DAY, SYSTIMESTAMP - INTERVAL '70' DAY, 100, 65, 9, 'N', 15, 15, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (216, 'Quiz: Tendencias en BD', SYSTIMESTAMP - INTERVAL '50' DAY, SYSTIMESTAMP - INTERVAL '48' DAY, SYSTIMESTAMP - INTERVAL '47' DAY, 20, 50, 4, 'S', 16, 16, 2);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (217, 'Examen Final: Integración de Conceptos', SYSTIMESTAMP - INTERVAL '25' DAY, SYSTIMESTAMP - INTERVAL '20' DAY, SYSTIMESTAMP - INTERVAL '19' DAY, 180, 70, 15, 'S', 17, 17, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (218, 'Evaluación Diagnóstica', SYSTIMESTAMP - INTERVAL '100' DAY, SYSTIMESTAMP - INTERVAL '98' DAY, SYSTIMESTAMP - INTERVAL '97' DAY, 60, 0, 10, 'N', 18, 18, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (219, 'Quiz: Herramientas de Administración', SYSTIMESTAMP - INTERVAL '110' DAY, SYSTIMESTAMP - INTERVAL '108' DAY, SYSTIMESTAMP - INTERVAL '107' DAY, 30, 60, 5, 'S', 19, 19, 2);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (220, 'Parcial: Modelado Dimensional', SYSTIMESTAMP - INTERVAL '85' DAY, SYSTIMESTAMP - INTERVAL '80' DAY, SYSTIMESTAMP - INTERVAL '78' DAY, 90, 65, 8, 'N', 20, 20, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (221, 'Evaluación: Procedimientos Almacenados', SYSTIMESTAMP - INTERVAL '95' DAY, SYSTIMESTAMP - INTERVAL '92' DAY, SYSTIMESTAMP - INTERVAL '90' DAY, 120, 70, 10, 'S', 21, 21, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (222, 'Quiz: Triggers y Eventos', SYSTIMESTAMP - INTERVAL '105' DAY, SYSTIMESTAMP - INTERVAL '103' DAY, SYSTIMESTAMP - INTERVAL '102' DAY, 25, 60, 5, 'N', 22, 22, 2);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (223, 'Parcial: Optimización Avanzada', SYSTIMESTAMP - INTERVAL '115' DAY, SYSTIMESTAMP - INTERVAL '110' DAY, SYSTIMESTAMP - INTERVAL '108' DAY, 150, 75, 12, 'S', 23, 23, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (224, 'Evaluación: Tablespaces y Almacenamiento', SYSTIMESTAMP - INTERVAL '125' DAY, SYSTIMESTAMP - INTERVAL '122' DAY, SYSTIMESTAMP - INTERVAL '120' DAY, 100, 65, 9, 'N', 24, 24, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (225, 'Quiz: Particionamiento', SYSTIMESTAMP - INTERVAL '135' DAY, SYSTIMESTAMP - INTERVAL '133' DAY, SYSTIMESTAMP - INTERVAL '132' DAY, 20, 50, 4, 'S', 25, 25, 2);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (226, 'Recuperación Paralelo 1', SYSTIMESTAMP - INTERVAL '140' DAY, SYSTIMESTAMP - INTERVAL '138' DAY, SYSTIMESTAMP - INTERVAL '137' DAY, 90, 60, 8, 'N', 1, 1, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (227, 'Recuperación Paralelo 2', SYSTIMESTAMP - INTERVAL '130' DAY, SYSTIMESTAMP - INTERVAL '128' DAY, SYSTIMESTAMP - INTERVAL '127' DAY, 90, 60, 8, 'S', 2, 2, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (228, 'Examen Especial: Proyectos BD', SYSTIMESTAMP - INTERVAL '120' DAY, SYSTIMESTAMP - INTERVAL '118' DAY, SYSTIMESTAMP - INTERVAL '117' DAY, 120, 70, 10, 'N', 3, 3, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (229, 'Quiz Express: Conceptos Clave', SYSTIMESTAMP - INTERVAL '110' DAY, SYSTIMESTAMP - INTERVAL '109' DAY, SYSTIMESTAMP - INTERVAL '109' DAY, 10, 60, 3, 'S', 4, 4, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (230, 'Evaluación Final de Curso', SYSTIMESTAMP - INTERVAL '10' DAY, SYSTIMESTAMP - INTERVAL '5' DAY, SYSTIMESTAMP - INTERVAL '2' DAY, 180, 75, 20, 'S', 5, 5, 1);

-- PREGUNTAS_EXAMEN (30 registros)
INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (301, 10, 1, 101, 201);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (302, 15, 2, 102, 201);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (303, 10, 3, 103, 201);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (304, 20, 1, 104, 202);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (305, 20, 2, 105, 202);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (306, 20, 1, 106, 203);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (307, 20, 2, 107, 203);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (308, 10, 1, 108, 204);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (309, 10, 2, 109, 204);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (310, 15, 1, 110, 205);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (311, 15, 2, 111, 205);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (312, 20, 1, 112, 206);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (313, 20, 2, 113, 206);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (314, 25, 1, 114, 207);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (315, 25, 2, 115, 207);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (316, 20, 1, 116, 208);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (317, 20, 2, 117, 208);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (318, 15, 1, 118, 209);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (319, 15, 2, 119, 209);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (320, 30, 1, 120, 210);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (321, 30, 2, 121, 210);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (322, 25, 1, 122, 211);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (323, 25, 2, 123, 211);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (324, 20, 1, 124, 212);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (325, 20, 2, 125, 212);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (326, 25, 1, 126, 213);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (327, 25, 2, 127, 213);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (328, 15, 1, 128, 214);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (329, 15, 2, 129, 214);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (330, 20, 1, 130, 215);

-- INSCRIPCIONES (30 registros)
INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (401, SYSTIMESTAMP - INTERVAL '120' DAY, 1, 26);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (402, SYSTIMESTAMP - INTERVAL '119' DAY, 2, 27);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (403, SYSTIMESTAMP - INTERVAL '118' DAY, 3, 28);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (404, SYSTIMESTAMP - INTERVAL '117' DAY, 4, 29);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (405, SYSTIMESTAMP - INTERVAL '116' DAY, 5, 30);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (406, SYSTIMESTAMP - INTERVAL '115' DAY, 6, 31);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (407, SYSTIMESTAMP - INTERVAL '114' DAY, 7, 32);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (408, SYSTIMESTAMP - INTERVAL '113' DAY, 8, 33);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (409, SYSTIMESTAMP - INTERVAL '112' DAY, 9, 34);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (410, SYSTIMESTAMP - INTERVAL '111' DAY, 10, 35);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (411, SYSTIMESTAMP - INTERVAL '110' DAY, 11, 36);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (412, SYSTIMESTAMP - INTERVAL '109' DAY, 12, 37);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (413, SYSTIMESTAMP - INTERVAL '108' DAY, 13, 38);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (414, SYSTIMESTAMP - INTERVAL '107' DAY, 14, 39);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (415, SYSTIMESTAMP - INTERVAL '106' DAY, 15, 40);



-- Desactivar todos los triggers del esquema
BEGIN
  FOR r IN (SELECT trigger_name FROM user_triggers) LOOP
    EXECUTE IMMEDIATE 'ALTER TRIGGER ' || r.trigger_name || ' DISABLE';
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Todos los triggers han sido desactivados');
END;
/

-- ==================================================
-- POBLACIÓN DE TABLAS FALTANTES
-- ==================================================

-- PREGUNTAS (30 registros)
INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (101, '¿Cuál es el principal componente de un sistema de base de datos relacional?', SYSTIMESTAMP - INTERVAL '100' DAY, 'S', 60, 2, 1, 1, 'El componente principal es el RDBMS que gestiona los datos estructurados en tablas relacionadas.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (102, 'Identifique las propiedades ACID en bases de datos:', SYSTIMESTAMP - INTERVAL '99' DAY, 'S', 120, 1, 2, 2, 'Las propiedades ACID son Atomicidad, Consistencia, Aislamiento y Durabilidad.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (103, '¿Es verdad que los índices siempre mejoran el rendimiento de las consultas?', SYSTIMESTAMP - INTERVAL '98' DAY, 'S', 30, 3, 3, 3, 'No siempre. Para tablas pequeñas o con muchas actualizaciones, los índices pueden reducir el rendimiento.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (104, 'Ordene los siguientes pasos del proceso de normalización:', SYSTIMESTAMP - INTERVAL '97' DAY, 'S', 180, 4, 4, 4, 'El orden correcto es: identificar dependencias funcionales, eliminar dependencias parciales, eliminar dependencias transitivas.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (105, 'Complete la siguiente sentencia SQL: SELECT * FROM empleados WHERE _____ BETWEEN 30000 AND 50000;', SYSTIMESTAMP - INTERVAL '96' DAY, 'S', 45, 5, 5, 5, 'La respuesta correcta es "salario" para completar la consulta de rango salarial.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (106, 'Empareje cada comando SQL con su categoría:', SYSTIMESTAMP - INTERVAL '95' DAY, 'S', 90, 6, 6, 6, 'SELECT pertenece a DQL, INSERT a DML, CREATE a DDL y GRANT a DCL.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (107, '¿Cuáles son las ventajas de utilizar procedimientos almacenados?', SYSTIMESTAMP - INTERVAL '94' DAY, 'S', 120, 1, 7, 7, 'Las ventajas incluyen mejor rendimiento, seguridad, reutilización y consistencia.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (108, '¿Qué arquitectura de base de datos es mejor para sistemas de alta disponibilidad?', SYSTIMESTAMP - INTERVAL '93' DAY, 'S', 60, 2, 8, 8, 'Arquitecturas distribuidas con replicación son ideales para alta disponibilidad.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (109, '¿Es correcto utilizar UNION ALL para combinar resultados duplicados de dos consultas?', SYSTIMESTAMP - INTERVAL '92' DAY, 'S', 30, 3, 9, 9, 'Sí, UNION ALL conserva duplicados mientras que UNION los elimina.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (110, 'Ordene las siguientes operaciones de JOIN según su complejidad computacional:', SYSTIMESTAMP - INTERVAL '91' DAY, 'S', 180, 4, 10, 10, 'INNER JOIN suele ser el más eficiente, seguido por LEFT JOIN, RIGHT JOIN y FULL JOIN.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (111, 'Complete el tipo de constraint: ALTER TABLE empleados ADD CONSTRAINT pk_emp _____ (empleado_id);', SYSTIMESTAMP - INTERVAL '90' DAY, 'S', 45, 5, 11, 11, 'La respuesta correcta es "PRIMARY KEY".');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (112, 'Empareje cada anomalía con su forma normal de resolución:', SYSTIMESTAMP - INTERVAL '89' DAY, 'S', 90, 6, 12, 12, 'Redundancia - 1FN, Dependencia parcial - 2FN, Dependencia transitiva - 3FN.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (113, '¿Qué técnicas pueden mejorar el rendimiento de consultas en bases de datos grandes?', SYSTIMESTAMP - INTERVAL '88' DAY, 'S', 120, 1, 13, 13, 'Particionamiento, indexación, optimización de consultas y cacheo son técnicas efectivas.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (114, '¿Cuál es el mejor tipo de índice para búsquedas por rango?', SYSTIMESTAMP - INTERVAL '87' DAY, 'S', 60, 2, 14, 14, 'Los índices B-tree son generalmente los mejores para búsquedas por rango.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (115, '¿Es recomendable usar transacciones para operaciones de lectura?', SYSTIMESTAMP - INTERVAL '86' DAY, 'S', 30, 3, 15, 15, 'Depende del nivel de aislamiento requerido; para lecturas consistentes, sí es recomendable.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (116, 'Ordene los siguientes pasos de recuperación ante fallos:', SYSTIMESTAMP - INTERVAL '85' DAY, 'S', 180, 4, 16, 16, 'Identificar el problema, aplicar logs de transacciones, restaurar desde backup, verificar integridad.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (117, 'Complete: SELECT COUNT(*) FROM productos GROUP BY _____ HAVING COUNT(*) > 5;', SYSTIMESTAMP - INTERVAL '84' DAY, 'S', 45, 5, 17, 17, 'La respuesta típica sería "categoria_id" para contar productos por categoría.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (118, 'Empareje cada término con su definición:', SYSTIMESTAMP - INTERVAL '83' DAY, 'S', 90, 6, 18, 18, 'Cardinality - número de filas, Selectivity - proporción de filas seleccionadas, Collation - orden de clasificación.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (119, '¿Qué medidas de seguridad son esenciales para proteger una base de datos?', SYSTIMESTAMP - INTERVAL '82' DAY, 'S', 120, 1, 19, 19, 'Autenticación fuerte, cifrado, control de acceso, auditoría y respaldos son esenciales.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (120, '¿Qué modelo de base de datos es más adecuado para datos jerárquicos?', SYSTIMESTAMP - INTERVAL '81' DAY, 'S', 60, 2, 20, 20, 'NoSQL basado en documentos o bases de datos de grafos suelen ser mejores para datos jerárquicos.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (121, '¿Un índice clustered mejora siempre el rendimiento de escritura?', SYSTIMESTAMP - INTERVAL '80' DAY, 'S', 30, 3, 21, 21, 'No, puede ralentizar las escrituras porque requiere reorganizar físicamente la tabla.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (122, 'Ordene las siguientes tecnologías según su aparición histórica:', SYSTIMESTAMP - INTERVAL '79' DAY, 'S', 180, 4, 22, 22, 'Bases de datos jerárquicas, relacionales, objeto-relacionales, NoSQL, NewSQL.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (123, 'Complete: CREATE _____ INDEX idx_nombre ON clientes(nombre);', SYSTIMESTAMP - INTERVAL '78' DAY, 'S', 45, 5, 23, 23, 'La respuesta correcta puede ser "UNIQUE" o "BITMAP" dependiendo del contexto.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (124, 'Empareje cada problema con su solución:', SYSTIMESTAMP - INTERVAL '77' DAY, 'S', 90, 6, 24, 24, 'Deadlock - detección y rollback, Fragmentación - reconstrucción, Corrupción - backup y restore.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (125, '¿Qué estrategias existen para escalar horizontalmente una base de datos?', SYSTIMESTAMP - INTERVAL '76' DAY, 'S', 120, 1, 25, 25, 'Sharding, replicación, federación y clustering son estrategias comunes.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (126, '¿Cuál es la mejor estructura para almacenar datos geoespaciales?', SYSTIMESTAMP - INTERVAL '75' DAY, 'S', 60, 2, 1, 1, 'Índices espaciales como R-tree o tipos de datos geométricos especializados.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (127, '¿Las vistas materializadas necesitan ser refrescadas manualmente?', SYSTIMESTAMP - INTERVAL '74' DAY, 'S', 30, 3, 2, 2, 'Depende de la configuración; pueden refrescarse automáticamente o manualmente.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (128, 'Ordene estos pasos para diseñar un esquema de particionamiento:', SYSTIMESTAMP - INTERVAL '73' DAY, 'S', 180, 4, 3, 3, 'Analizar patrones de acceso, elegir clave de partición, determinar método, implementar y probar.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (129, 'Complete: ALTER TABLE empleados _____ COLUMN direccion VARCHAR(100);', SYSTIMESTAMP - INTERVAL '72' DAY, 'S', 45, 5, 4, 4, 'La respuesta correcta es "ADD" para añadir una nueva columna.');

INSERT INTO Preguntas (pregunta_id, texto, fecha_creacion, es_publica, tiempo_maximo, tipo_pregunta_id, creador_id, tema_id, retroalimentacion)
VALUES (130, 'Empareje cada tipo de base de datos con su caso de uso ideal:', SYSTIMESTAMP - INTERVAL '71' DAY, 'S', 90, 6, 5, 5, 'Relacional - transacciones, Columnar - análisis, Documental - contenido, Grafos - relaciones complejas.');

-- OPCIONES_PREGUNTAS (Para preguntas de opción múltiple y única)
-- Para pregunta 101 (opción única)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1001, 'Tablas', 'N', 1, 101);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1002, 'Sistema Gestor de Base de Datos (SGBD)', 'S', 2, 101);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1003, 'Índices', 'N', 3, 101);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1004, 'Consultas SQL', 'N', 4, 101);

-- Para pregunta 102 (opción múltiple)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1005, 'Atomicidad', 'S', 1, 102);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1006, 'Consistencia', 'S', 2, 102);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1007, 'Aislamiento', 'S', 3, 102);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1008, 'Durabilidad', 'S', 4, 102);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1009, 'Escalabilidad', 'N', 5, 102);

-- Para pregunta 103 (V/F)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1010, 'Verdadero', 'N', 1, 103);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1011, 'Falso', 'S', 2, 103);

-- Para pregunta 108 (opción única)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1012, 'Arquitectura centralizada monolítica', 'N', 1, 108);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1013, 'Arquitectura distribuida con replicación', 'S', 2, 108);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1014, 'Arquitectura de un solo nodo sin respaldo', 'N', 3, 108);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1015, 'Arquitectura en memoria sin persistencia', 'N', 4, 108);

-- Para pregunta 109 (V/F)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1016, 'Verdadero', 'S', 1, 109);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1017, 'Falso', 'N', 2, 109);

-- Para pregunta 114 (opción única)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1018, 'Índice Hash', 'N', 1, 114);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1019, 'Índice B-tree', 'S', 2, 114);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1020, 'Índice Bitmap', 'N', 3, 114);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1021, 'Índice Full-text', 'N', 4, 114);

-- Para pregunta 115 (V/F)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1022, 'Verdadero', 'S', 1, 115);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1023, 'Falso', 'N', 2, 115);

-- Para pregunta 120 (opción única)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1024, 'Modelo relacional tradicional', 'N', 1, 120);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1025, 'NoSQL basado en documentos', 'S', 2, 120);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1026, 'Base de datos columnar', 'N', 3, 120);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1027, 'Base de datos de objetos', 'N', 4, 120);

-- Para pregunta 121 (V/F)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1028, 'Verdadero', 'N', 1, 121);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1029, 'Falso', 'S', 2, 121);

-- Para pregunta 126 (opción única)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1030, 'Índices B-tree estándar', 'N', 1, 126);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1031, 'Índices espaciales R-tree', 'S', 2, 126);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1032, 'Tablas de hash', 'N', 3, 126);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1033, 'Listas enlazadas', 'N', 4, 126);

-- Para pregunta 127 (V/F)
INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1034, 'Verdadero', 'N', 1, 127);

INSERT INTO Opciones_Preguntas (opcion_pregunta_id, texto, es_correcta, orden, pregunta_id)
VALUES (1035, 'Falso', 'S', 2, 127);

-- ORDEN_PREGUNTAS (Para preguntas de ordenar)
-- Para pregunta 104
INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2001, 'Identificar dependencias funcionales', 1, 104);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2002, 'Eliminar dependencias parciales', 2, 104);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2003, 'Eliminar dependencias transitivas', 3, 104);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2004, 'Aplicar forma normal de Boyce-Codd', 4, 104);

-- Para pregunta 110
INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2005, 'INNER JOIN', 1, 110);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2006, 'LEFT JOIN', 2, 110);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2007, 'RIGHT JOIN', 3, 110);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2008, 'FULL OUTER JOIN', 4, 110);

-- Para pregunta 116
INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2009, 'Identificar el problema y evaluar el impacto', 1, 116);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2010, 'Restaurar desde el último backup válido', 2, 116);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2011, 'Aplicar logs de transacciones hasta el punto de fallo', 3, 116);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2012, 'Verificar integridad y consistencia de los datos', 4, 116);

-- Para pregunta 122
INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2013, 'Bases de datos jerárquicas', 1, 122);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2014, 'Bases de datos relacionales', 2, 122);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2015, 'Bases de datos objeto-relacionales', 3, 122);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2016, 'Bases de datos NoSQL', 4, 122);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2017, 'Bases de datos NewSQL', 5, 122);

-- Para pregunta 128
INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2018, 'Analizar patrones de acceso a los datos', 1, 128);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2019, 'Elegir la clave de partición apropiada', 2, 128);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2020, 'Determinar el método de particionamiento', 3, 128);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2021, 'Implementar la estrategia de particionamiento', 4, 128);

INSERT INTO Orden_Preguntas (orden_pregunta_id, texto, posicion_correcta, pregunta_id)
VALUES (2022, 'Probar y ajustar el rendimiento', 5, 128);

-- EMPAREJAMIENTO_PREGUNTAS (Para preguntas de emparejar)
-- Para pregunta 106
INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3001, 'SELECT', 'DQL (Data Query Language)', 106);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3002, 'INSERT', 'DML (Data Manipulation Language)', 106);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3003, 'CREATE', 'DDL (Data Definition Language)', 106);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3004, 'GRANT', 'DCL (Data Control Language)', 106);

-- Para pregunta 112
INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3005, 'Redundancia de datos', 'Primera Forma Normal (1FN)', 112);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3006, 'Dependencia parcial', 'Segunda Forma Normal (2FN)', 112);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3007, 'Dependencia transitiva', 'Tercera Forma Normal (3FN)', 112);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3008, 'Dependencia multivaluada', 'Cuarta Forma Normal (4FN)', 112);

-- Para pregunta 118
INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3009, 'Cardinalidad', 'Número de filas en una tabla', 118);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3010, 'Selectividad', 'Proporción de filas que cumplen un criterio', 118);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3011, 'Collation', 'Reglas de ordenación y comparación', 118);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3012, 'Clustering factor', 'Orden físico de filas en relación con un índice', 118);

-- Para pregunta 124
INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3013, 'Deadlock', 'Detección y rollback automático', 124);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3014, 'Fragmentación de índices', 'Reconstrucción o reorganización', 124);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3015, 'Corrupción de datos', 'Restauración desde backup', 124);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3016, 'Bloqueo prolongado', 'Timeout y cancelación', 124);

-- Para pregunta 130
INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3017, 'Base de datos relacional', 'Aplicaciones transaccionales (OLTP)', 130);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3018, 'Base de datos columnar', 'Análisis y reportes (OLAP)', 130);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3019, 'Base de datos documental', 'Gestión de contenidos y catálogos', 130);

INSERT INTO Emparejamiento_Preguntas (emparejamiento_pregunta_id, opcion_a, opcion_b, pregunta_id)
VALUES (3020, 'Base de datos de grafos', 'Redes sociales y relaciones complejas', 130);

-- EXAMENES (30 registros)
INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (201, 'Parcial 1: Fundamentos de Bases de Datos', SYSTIMESTAMP - INTERVAL '60' DAY, SYSTIMESTAMP - INTERVAL '50' DAY, SYSTIMESTAMP - INTERVAL '45' DAY, 120, 70, 10, 'S', 1, 1, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (202, 'Parcial 2: Normalización y Diseño', SYSTIMESTAMP - INTERVAL '40' DAY, SYSTIMESTAMP - INTERVAL '30' DAY, SYSTIMESTAMP - INTERVAL '25' DAY, 90, 65, 8, 'S', 2, 2, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (203, 'Quiz: SQL Básico', SYSTIMESTAMP - INTERVAL '35' DAY, SYSTIMESTAMP - INTERVAL '30' DAY, SYSTIMESTAMP - INTERVAL '29' DAY, 30, 60, 5, 'N', 3, 3, 2);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (204, 'Examen Final: Administración de BD', SYSTIMESTAMP - INTERVAL '20' DAY, SYSTIMESTAMP - INTERVAL '15' DAY, SYSTIMESTAMP - INTERVAL '14' DAY, 180, 75, 15, 'N', 4, 4, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (205, 'Práctica: Optimización de Consultas', SYSTIMESTAMP - INTERVAL '25' DAY, SYSTIMESTAMP - INTERVAL '20' DAY, SYSTIMESTAMP - INTERVAL '15' DAY, 120, 50, 10, 'S', 5, 5, 3);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (206, 'Evaluación: Transacciones y Concurrencia', SYSTIMESTAMP - INTERVAL '30' DAY, SYSTIMESTAMP - INTERVAL '28' DAY, SYSTIMESTAMP - INTERVAL '25' DAY, 90, 65, 8, 'S', 6, 6, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (207, 'Quiz: Índices y Rendimiento', SYSTIMESTAMP - INTERVAL '45' DAY, SYSTIMESTAMP - INTERVAL '43' DAY, SYSTIMESTAMP - INTERVAL '42' DAY, 20, 70, 5, 'N', 7, 7, 2);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (208, 'Parcial: Arquitectura de BD', SYSTIMESTAMP - INTERVAL '55' DAY, SYSTIMESTAMP - INTERVAL '50' DAY, SYSTIMESTAMP - INTERVAL '48' DAY, 75, 60, 7, 'S', 8, 8, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (209, 'Evaluación: Recuperación y Backup', SYSTIMESTAMP - INTERVAL '38' DAY, SYSTIMESTAMP - INTERVAL '35' DAY, SYSTIMESTAMP - INTERVAL '34' DAY, 60, 70, 6, 'N', 9, 9, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (210, 'Quiz Sorpresa: Seguridad en BD', SYSTIMESTAMP - INTERVAL '15' DAY, SYSTIMESTAMP - INTERVAL '15' DAY, SYSTIMESTAMP - INTERVAL '15' DAY, 15, 60, 3, 'S', 10, 10, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (211, 'Examen Parcial: BD NoSQL', SYSTIMESTAMP - INTERVAL '70' DAY, SYSTIMESTAMP - INTERVAL '65' DAY, SYSTIMESTAMP - INTERVAL '64' DAY, 90, 65, 8, 'N', 11, 11, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (212, 'Evaluación: Modelado de Datos', SYSTIMESTAMP - INTERVAL '80' DAY, SYSTIMESTAMP - INTERVAL '75' DAY, SYSTIMESTAMP - INTERVAL '73' DAY, 120, 70, 10, 'S', 12, 12, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (213, 'Quiz: Lenguajes de Consulta', SYSTIMESTAMP - INTERVAL '90' DAY, SYSTIMESTAMP - INTERVAL '88' DAY, SYSTIMESTAMP - INTERVAL '87' DAY, 30, 60, 5, 'N', 13, 13, 2);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (214, 'Parcial: Programación en BD', SYSTIMESTAMP - INTERVAL '65' DAY, SYSTIMESTAMP - INTERVAL '60' DAY, SYSTIMESTAMP - INTERVAL '58' DAY, 150, 75, 12, 'S', 14, 14, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (215, 'Evaluación: Replicación y Distribución', SYSTIMESTAMP - INTERVAL '75' DAY, SYSTIMESTAMP - INTERVAL '72' DAY, SYSTIMESTAMP - INTERVAL '70' DAY, 100, 65, 9, 'N', 15, 15, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (216, 'Quiz: Tendencias en BD', SYSTIMESTAMP - INTERVAL '50' DAY, SYSTIMESTAMP - INTERVAL '48' DAY, SYSTIMESTAMP - INTERVAL '47' DAY, 20, 50, 4, 'S', 16, 16, 2);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (217, 'Examen Final: Integración de Conceptos', SYSTIMESTAMP - INTERVAL '25' DAY, SYSTIMESTAMP - INTERVAL '20' DAY, SYSTIMESTAMP - INTERVAL '19' DAY, 180, 70, 15, 'S', 17, 17, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (218, 'Evaluación Diagnóstica', SYSTIMESTAMP - INTERVAL '100' DAY, SYSTIMESTAMP - INTERVAL '98' DAY, SYSTIMESTAMP - INTERVAL '97' DAY, 60, 0, 10, 'N', 18, 18, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (219, 'Quiz: Herramientas de Administración', SYSTIMESTAMP - INTERVAL '110' DAY, SYSTIMESTAMP - INTERVAL '108' DAY, SYSTIMESTAMP - INTERVAL '107' DAY, 30, 60, 5, 'S', 19, 19, 2);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (220, 'Parcial: Modelado Dimensional', SYSTIMESTAMP - INTERVAL '85' DAY, SYSTIMESTAMP - INTERVAL '80' DAY, SYSTIMESTAMP - INTERVAL '78' DAY, 90, 65, 8, 'N', 20, 20, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (221, 'Evaluación: Procedimientos Almacenados', SYSTIMESTAMP - INTERVAL '95' DAY, SYSTIMESTAMP - INTERVAL '92' DAY, SYSTIMESTAMP - INTERVAL '90' DAY, 120, 70, 10, 'S', 21, 21, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (222, 'Quiz: Triggers y Eventos', SYSTIMESTAMP - INTERVAL '105' DAY, SYSTIMESTAMP - INTERVAL '103' DAY, SYSTIMESTAMP - INTERVAL '102' DAY, 25, 60, 5, 'N', 22, 22, 2);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (223, 'Parcial: Optimización Avanzada', SYSTIMESTAMP - INTERVAL '115' DAY, SYSTIMESTAMP - INTERVAL '110' DAY, SYSTIMESTAMP - INTERVAL '108' DAY, 150, 75, 12, 'S', 23, 23, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (224, 'Evaluación: Tablespaces y Almacenamiento', SYSTIMESTAMP - INTERVAL '125' DAY, SYSTIMESTAMP - INTERVAL '122' DAY, SYSTIMESTAMP - INTERVAL '120' DAY, 100, 65, 9, 'N', 24, 24, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (225, 'Quiz: Particionamiento', SYSTIMESTAMP - INTERVAL '135' DAY, SYSTIMESTAMP - INTERVAL '133' DAY, SYSTIMESTAMP - INTERVAL '132' DAY, 20, 50, 4, 'S', 25, 25, 2);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (226, 'Recuperación Paralelo 1', SYSTIMESTAMP - INTERVAL '140' DAY, SYSTIMESTAMP - INTERVAL '138' DAY, SYSTIMESTAMP - INTERVAL '137' DAY, 90, 60, 8, 'N', 1, 1, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (227, 'Recuperación Paralelo 2', SYSTIMESTAMP - INTERVAL '130' DAY, SYSTIMESTAMP - INTERVAL '128' DAY, SYSTIMESTAMP - INTERVAL '127' DAY, 90, 60, 8, 'S', 2, 2, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (228, 'Examen Especial: Proyectos BD', SYSTIMESTAMP - INTERVAL '120' DAY, SYSTIMESTAMP - INTERVAL '118' DAY, SYSTIMESTAMP - INTERVAL '117' DAY, 120, 70, 10, 'N', 3, 3, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (229, 'Quiz Express: Conceptos Clave', SYSTIMESTAMP - INTERVAL '110' DAY, SYSTIMESTAMP - INTERVAL '109' DAY, SYSTIMESTAMP - INTERVAL '109' DAY, 10, 60, 3, 'S', 4, 4, 1);

INSERT INTO Examenes (examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite, tiempo_limite, umbral_aprobacion, cantidad_preguntas_mostrar, aleatorizar_preguntas, creador_id, grupo_id, max_intentos)
VALUES (230, 'Evaluación Final de Curso', SYSTIMESTAMP - INTERVAL '10' DAY, SYSTIMESTAMP - INTERVAL '5' DAY, SYSTIMESTAMP - INTERVAL '2' DAY, 180, 75, 20, 'S', 5, 5, 1);

-- PREGUNTAS_EXAMEN (30 registros)
INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (301, 10, 1, 101, 201);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (302, 15, 2, 102, 201);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (303, 10, 3, 103, 201);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (304, 20, 1, 104, 202);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (305, 20, 2, 105, 202);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (306, 20, 1, 106, 203);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (307, 20, 2, 107, 203);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (308, 10, 1, 108, 204);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (309, 10, 2, 109, 204);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (310, 15, 1, 110, 205);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (311, 15, 2, 111, 205);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (312, 20, 1, 112, 206);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (313, 20, 2, 113, 206);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (314, 25, 1, 114, 207);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (315, 25, 2, 115, 207);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (316, 20, 1, 116, 208);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (317, 20, 2, 117, 208);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (318, 15, 1, 118, 209);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (319, 15, 2, 119, 209);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (320, 30, 1, 120, 210);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (321, 30, 2, 121, 210);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (322, 25, 1, 122, 211);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (323, 25, 2, 123, 211);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (324, 20, 1, 124, 212);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (325, 20, 2, 125, 212);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (326, 25, 1, 126, 213);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (327, 25, 2, 127, 213);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (328, 15, 1, 128, 214);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (329, 15, 2, 129, 214);

INSERT INTO Preguntas_Examenes (pregunta_examen_id, peso, orden, pregunta_id, examen_id)
VALUES (330, 20, 1, 130, 215);

-- INSCRIPCIONES (30 registros)
INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (401, SYSTIMESTAMP - INTERVAL '120' DAY, 1, 26);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (402, SYSTIMESTAMP - INTERVAL '119' DAY, 2, 27);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (403, SYSTIMESTAMP - INTERVAL '118' DAY, 3, 28);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (404, SYSTIMESTAMP - INTERVAL '117' DAY, 4, 29);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (405, SYSTIMESTAMP - INTERVAL '116' DAY, 5, 30);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (406, SYSTIMESTAMP - INTERVAL '115' DAY, 6, 31);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (407, SYSTIMESTAMP - INTERVAL '114' DAY, 7, 32);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (408, SYSTIMESTAMP - INTERVAL '113' DAY, 8, 33);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (409, SYSTIMESTAMP - INTERVAL '112' DAY, 9, 34);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (410, SYSTIMESTAMP - INTERVAL '111' DAY, 10, 35);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (411, SYSTIMESTAMP - INTERVAL '110' DAY, 11, 36);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (412, SYSTIMESTAMP - INTERVAL '109' DAY, 12, 37);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (413, SYSTIMESTAMP - INTERVAL '108' DAY, 13, 38);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (414, SYSTIMESTAMP - INTERVAL '107' DAY, 14, 39);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (415, SYSTIMESTAMP - INTERVAL '106' DAY, 15, 40);

-- Continuación de INSCRIPCIONES
INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (416, SYSTIMESTAMP - INTERVAL '105' DAY, 16, 41);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (417, SYSTIMESTAMP - INTERVAL '104' DAY, 17, 42);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (418, SYSTIMESTAMP - INTERVAL '103' DAY, 18, 43);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (419, SYSTIMESTAMP - INTERVAL '102' DAY, 19, 44);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (420, SYSTIMESTAMP - INTERVAL '101' DAY, 20, 45);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (421, SYSTIMESTAMP - INTERVAL '100' DAY, 21, 46);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (422, SYSTIMESTAMP - INTERVAL '99' DAY, 22, 47);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (423, SYSTIMESTAMP - INTERVAL '98' DAY, 23, 48);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (424, SYSTIMESTAMP - INTERVAL '97' DAY, 24, 49);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (425, SYSTIMESTAMP - INTERVAL '96' DAY, 25, 50);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (426, SYSTIMESTAMP - INTERVAL '95' DAY, 1, 27);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (427, SYSTIMESTAMP - INTERVAL '94' DAY, 2, 28);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (428, SYSTIMESTAMP - INTERVAL '93' DAY, 3, 29);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (429, SYSTIMESTAMP - INTERVAL '92' DAY, 4, 30);

INSERT INTO Inscripciones (inscripcion_id, fecha_inscripcion, grupo_id, estudiante_id)
VALUES (430, SYSTIMESTAMP - INTERVAL '91' DAY, 5, 31);

-- INTENTOS_EXAMEN (30 registros)
INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (501, SYSTIMESTAMP - INTERVAL '49' DAY, SYSTIMESTAMP - INTERVAL '49' DAY + INTERVAL '110' MINUTE, 85, 26, 201, '192.168.1.101');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (502, SYSTIMESTAMP - INTERVAL '29' DAY, SYSTIMESTAMP - INTERVAL '29' DAY + INTERVAL '75' MINUTE, 78, 27, 202, '192.168.1.102');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (503, SYSTIMESTAMP - INTERVAL '29' DAY, SYSTIMESTAMP - INTERVAL '29' DAY + INTERVAL '25' MINUTE, 65, 28, 203, '192.168.1.103');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (504, SYSTIMESTAMP - INTERVAL '14' DAY, SYSTIMESTAMP - INTERVAL '14' DAY + INTERVAL '170' MINUTE, 92, 29, 204, '192.168.1.104');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (505, SYSTIMESTAMP - INTERVAL '18' DAY, SYSTIMESTAMP - INTERVAL '18' DAY + INTERVAL '115' MINUTE, 70, 30, 205, '192.168.1.105');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (506, SYSTIMESTAMP - INTERVAL '27' DAY, SYSTIMESTAMP - INTERVAL '27' DAY + INTERVAL '85' MINUTE, 81, 31, 206, '192.168.1.106');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (507, SYSTIMESTAMP - INTERVAL '42' DAY, SYSTIMESTAMP - INTERVAL '42' DAY + INTERVAL '18' MINUTE, 75, 32, 207, '192.168.1.107');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (508, SYSTIMESTAMP - INTERVAL '49' DAY, SYSTIMESTAMP - INTERVAL '49' DAY + INTERVAL '68' MINUTE, 63, 33, 208, '192.168.1.108');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (509, SYSTIMESTAMP - INTERVAL '34' DAY, SYSTIMESTAMP - INTERVAL '34' DAY + INTERVAL '57' MINUTE, 79, 34, 209, '192.168.1.109');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (510, SYSTIMESTAMP - INTERVAL '15' DAY, SYSTIMESTAMP - INTERVAL '15' DAY + INTERVAL '14' MINUTE, 45, 35, 210, '192.168.1.110');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (511, SYSTIMESTAMP - INTERVAL '64' DAY, SYSTIMESTAMP - INTERVAL '64' DAY + INTERVAL '84' MINUTE, 72, 36, 211, '192.168.1.111');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (512, SYSTIMESTAMP - INTERVAL '72' DAY, SYSTIMESTAMP - INTERVAL '72' DAY + INTERVAL '115' MINUTE, 88, 37, 212, '192.168.1.112');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (513, SYSTIMESTAMP - INTERVAL '87' DAY, SYSTIMESTAMP - INTERVAL '87' DAY + INTERVAL '29' MINUTE, 93, 38, 213, '192.168.1.113');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (514, SYSTIMESTAMP - INTERVAL '58' DAY, SYSTIMESTAMP - INTERVAL '58' DAY + INTERVAL '142' MINUTE, 76, 39, 214, '192.168.1.114');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (515, SYSTIMESTAMP - INTERVAL '71' DAY, SYSTIMESTAMP - INTERVAL '71' DAY + INTERVAL '95' MINUTE, 84, 40, 215, '192.168.1.115');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (516, SYSTIMESTAMP - INTERVAL '47' DAY, SYSTIMESTAMP - INTERVAL '47' DAY + INTERVAL '18' MINUTE, 68, 41, 216, '192.168.1.116');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (517, SYSTIMESTAMP - INTERVAL '19' DAY, SYSTIMESTAMP - INTERVAL '19' DAY + INTERVAL '176' MINUTE, 91, 42, 217, '192.168.1.117');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (518, SYSTIMESTAMP - INTERVAL '97' DAY, SYSTIMESTAMP - INTERVAL '97' DAY + INTERVAL '56' MINUTE, 45, 43, 218, '192.168.1.118');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (519, SYSTIMESTAMP - INTERVAL '107' DAY, SYSTIMESTAMP - INTERVAL '107' DAY + INTERVAL '28' MINUTE, 82, 44, 219, '192.168.1.119');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (520, SYSTIMESTAMP - INTERVAL '78' DAY, SYSTIMESTAMP - INTERVAL '78' DAY + INTERVAL '87' MINUTE, 77, 45, 220, '192.168.1.120');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (521, SYSTIMESTAMP - INTERVAL '90' DAY, SYSTIMESTAMP - INTERVAL '90' DAY + INTERVAL '116' MINUTE, 69, 46, 221, '192.168.1.121');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (522, SYSTIMESTAMP - INTERVAL '102' DAY, SYSTIMESTAMP - INTERVAL '102' DAY + INTERVAL '23' MINUTE, 71, 47, 222, '192.168.1.122');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (523, SYSTIMESTAMP - INTERVAL '108' DAY, SYSTIMESTAMP - INTERVAL '108' DAY + INTERVAL '147' MINUTE, 88, 48, 223, '192.168.1.123');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (524, SYSTIMESTAMP - INTERVAL '120' DAY, SYSTIMESTAMP - INTERVAL '120' DAY + INTERVAL '98' MINUTE, 75, 49, 224, '192.168.1.124');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (525, SYSTIMESTAMP - INTERVAL '132' DAY, SYSTIMESTAMP - INTERVAL '132' DAY + INTERVAL '19' MINUTE, 94, 50, 225, '192.168.1.125');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (526, SYSTIMESTAMP - INTERVAL '137' DAY, SYSTIMESTAMP - INTERVAL '137' DAY + INTERVAL '86' MINUTE, 65, 26, 226, '192.168.1.126');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (527, SYSTIMESTAMP - INTERVAL '127' DAY, SYSTIMESTAMP - INTERVAL '127' DAY + INTERVAL '88' MINUTE, 72, 27, 227, '192.168.1.127');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (528, SYSTIMESTAMP - INTERVAL '117' DAY, SYSTIMESTAMP - INTERVAL '117' DAY + INTERVAL '117' MINUTE, 81, 28, 228, '192.168.1.128');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (529, SYSTIMESTAMP - INTERVAL '109' DAY, SYSTIMESTAMP - INTERVAL '109' DAY + INTERVAL '9' MINUTE, 68, 29, 229, '192.168.1.129');

INSERT INTO Intentos_Examen (intento_examen_id, fecha_inicio, fecha_fin, calificacion, estudiante_id, examen_id, direccion_ip)
VALUES (530, SYSTIMESTAMP - INTERVAL '3' DAY, SYSTIMESTAMP - INTERVAL '3' DAY + INTERVAL '175' MINUTE, 89, 30, 230, '192.168.1.130');

-- RESPUESTAS_ESTUDIANTES (30 registros)
INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (601, NULL, 'S', 501, 301);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (602, NULL, 'S', 501, 302);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (603, NULL, 'N', 501, 303);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (604, NULL, 'S', 502, 304);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (605, 'salario', 'S', 502, 305);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (606, NULL, 'S', 503, 306);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (607, NULL, 'N', 503, 307);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (608, NULL, 'S', 504, 308);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (609, NULL, 'S', 504, 309);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (610, NULL, 'S', 505, 310);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (611, 'PRIMARY KEY', 'S', 505, 311);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (612, NULL, 'S', 506, 312);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (613, NULL, 'N', 506, 313);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (614, NULL, 'S', 507, 314);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (615, NULL, 'N', 507, 315);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (616, NULL, 'S', 508, 316);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (617, 'categoria_id', 'S', 508, 317);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (618, NULL, 'S', 509, 318);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (619, NULL, 'N', 509, 319);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (620, NULL, 'N', 510, 320);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (621, NULL, 'S', 510, 321);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (622, NULL, 'S', 511, 322);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (623, 'UNIQUE', 'S', 511, 323);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (624, NULL, 'S', 512, 324);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (625, NULL, 'S', 512, 325);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (626, NULL, 'S', 513, 326);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (627, NULL, 'S', 513, 327);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (628, NULL, 'N', 514, 328);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (629, 'ADD', 'S', 514, 329);

INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, texto_respuesta, es_correcta, intento_examen_id, pregunta_examen_id)
VALUES (630, NULL, 'S', 515, 330);

-- RESPUESTAS_OPCIONES (30 registros - para preguntas de opción múltiple/única/V-F)
INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (701, 601, 1002);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (702, 602, 1005);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (703, 602, 1006);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (704, 602, 1007);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (705, 602, 1008);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (706, 603, 1010);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (707, 608, 1013);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (708, 609, 1016);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (709, 614, 1019);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (710, 615, 1023);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (711, 620, 1024);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (712, 621, 1029);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (713, 626, 1031);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (714, 627, 1035);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (715, 601, 1002);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (716, 608, 1013);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (717, 609, 1016);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (718, 614, 1019);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (719, 620, 1025);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (720, 621, 1029);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (721, 626, 1031);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (722, 627, 1035);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (723, 602, 1005);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (724, 602, 1006);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (725, 602, 1007);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (726, 602, 1008);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (727, 603, 1010);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (728, 609, 1016);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (729, 614, 1019);

INSERT INTO Respuestas_Opciones (respuesta_opcion_id, respuesta_estudiante_id, opcion_pregunta_id)
VALUES (730, 621, 1029);

-- RESPUESTAS_ORDEN (30 registros - para preguntas de ordenar)
INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (801, 604, 2001, 1);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (802, 604, 2002, 2);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (803, 604, 2003, 3);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (804, 604, 2004, 4);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (805, 610, 2005, 1);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (806, 610, 2006, 2);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (807, 610, 2007, 3);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (808, 610, 2008, 4);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (809, 616, 2009, 1);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (810, 616, 2010, 2);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (811, 616, 2011, 3);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (812, 616, 2012, 4);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (813, 622, 2013, 1);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (814, 622, 2014, 2);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (815, 622, 2015, 3);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (816, 622, 2016, 4);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (817, 622, 2017, 5);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (818, 628, 2018, 2);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (819, 628, 2019, 1);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (820, 628, 2020, 3);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (821, 628, 2021, 4);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (822, 628, 2022, 5);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (823, 604, 2001, 1);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (824, 604, 2002, 2);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (825, 610, 2005, 1);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (826, 610, 2006, 2);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (827, 616, 2009, 1);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (828, 616, 2010, 2);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (829, 622, 2013, 1);

INSERT INTO Respuestas_Orden (respuesta_orden_id, respuesta_estudiante_id, orden_pregunta_id, posicion_respuesta)
VALUES (830, 622, 2014, 2);

-- RESPUESTAS_EMPAREJAMIENTO (30 registros - para preguntas de emparejar)
INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (901, 606, 3001, 'DQL (Data Query Language)');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (902, 606, 3002, 'DML (Data Manipulation Language)');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (903, 606, 3003, 'DDL (Data Definition Language)');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (904, 606, 3004, 'DCL (Data Control Language)');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (905, 612, 3005, 'Primera Forma Normal (1FN)');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (906, 612, 3006, 'Segunda Forma Normal (2FN)');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (907, 612, 3007, 'Tercera Forma Normal (3FN)');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (908, 612, 3008, 'Cuarta Forma Normal (4FN)');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (909, 618, 3009, 'Número de filas en una tabla');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (910, 618, 3010, 'Proporción de filas que cumplen un criterio');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (911, 618, 3011, 'Reglas de ordenación y comparación');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (912, 618, 3012, 'Orden físico de filas en relación con un índice');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (913, 624, 3013, 'Detección y rollback automático');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (914, 624, 3014, 'Reconstrucción o reorganización');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (915, 624, 3015, 'Restauración desde backup');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (916, 624, 3016, 'Timeout y cancelación');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (917, 630, 3017, 'Aplicaciones transaccionales (OLTP)');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (918, 630, 3018, 'Análisis y reportes (OLAP)');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (919, 630, 3019, 'Gestión de contenidos y catálogos');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (920, 630, 3020, 'Redes sociales y relaciones complejas');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (921, 606, 3001, 'DQL (Data Query Language)');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (922, 606, 3002, 'DML (Data Manipulation Language)');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (923, 612, 3005, 'Primera Forma Normal (1FN)');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (924, 612, 3006, 'Segunda Forma Normal (2FN)');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (925, 618, 3009, 'Número de filas en una tabla');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (926, 618, 3010, 'Proporción de filas que cumplen un criterio');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (927, 624, 3013, 'Detección y rollback automático');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (928, 624, 3014, 'Reconstrucción o reorganización');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (929, 630, 3017, 'Aplicaciones transaccionales (OLTP)');

INSERT INTO Respuestas_Emparejamiento (respuesta_emparejamiento_id, respuesta_estudiante_id, emparejamiento_pregunta_id, opcion_b_respuesta)
VALUES (930, 630, 3018, 'Análisis y reportes (OLAP)');

-- Volver a activar todos los triggers del esquema
BEGIN
  FOR r IN (SELECT trigger_name FROM user_triggers) LOOP
    EXECUTE IMMEDIATE 'ALTER TRIGGER ' || r.trigger_name || ' ENABLE';
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Todos los triggers han sido reactivados');
END;
/

COMMIT;