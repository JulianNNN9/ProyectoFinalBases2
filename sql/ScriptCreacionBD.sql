-- ========================================================
-- 3.2 Script de Creación de Tablespaces y Tablas
-- ========================================================

-- ================================
-- A) Creación de TABLESPACES
-- ================================
-- Tablespace para datos de usuarios
CREATE TABLESPACE TS_USUARIOS
  DATAFILE 'ts_usuarios01.dbf' SIZE 100M
  AUTOEXTEND ON NEXT 20M MAXSIZE 500M
  EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;                	-- Datos de identidad :contentReference[oaicite:0]{index=0}

-- Tablespace para tablas paramétricas
CREATE TABLESPACE TS_PARAM
  DATAFILE 'ts_param01.dbf' SIZE 50M
  AUTOEXTEND ON NEXT 10M MAXSIZE 200M
  EXTENT MANAGEMENT LOCAL UNIFORM SIZE 512K;              	-- Datos estáticos :contentReference[oaicite:1]{index=1}

-- Tablespace para la estructura académica
CREATE TABLESPACE TS_ESTRUCTURA
  DATAFILE 'ts_estructura01.dbf' SIZE 150M
  AUTOEXTEND ON NEXT 30M MAXSIZE 1G
  EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;                	-- Cursos, grupos, temario :contentReference[oaicite:2]{index=2}

-- Tablespace para banco de preguntas
CREATE TABLESPACE TS_PREGUNTAS
  DATAFILE 'ts_preguntas01.dbf' SIZE 300M
  AUTOEXTEND ON NEXT 50M MAXSIZE 2G
  EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;                	-- CLOBs y I/O intensivo :contentReference[oaicite:3]{index=3}

-- Tablespace para exámenes y su relación con preguntas
CREATE TABLESPACE TS_EXAMENES
  DATAFILE 'ts_examenes01.dbf' SIZE 100M
  AUTOEXTEND ON NEXT 20M MAXSIZE 500M
  EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;

-- Tablespace para inscripciones
CREATE TABLESPACE TS_INSCRIPCIONES
  DATAFILE 'ts_inscripciones01.dbf' SIZE 100M
  AUTOEXTEND ON NEXT 20M MAXSIZE 500M
  EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;

-- Tablespace para intentos de examen
CREATE TABLESPACE TS_INTENTOS
  DATAFILE 'ts_intentos01.dbf' SIZE 150M
  AUTOEXTEND ON NEXT 30M MAXSIZE 1G
  EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;

-- Tablespace para respuestas de estudiantes
CREATE TABLESPACE TS_RESPUESTAS
  DATAFILE 'ts_respuestas01.dbf' SIZE 300M
  AUTOEXTEND ON NEXT 50M MAXSIZE 2G
  EXTENT MANAGEMENT LOCAL UNIFORM SIZE 1M;

-- Tablespace para logs de actividad
CREATE TABLESPACE TS_LOGS
  DATAFILE 'ts_logs01.dbf' SIZE 50M
  AUTOEXTEND ON NEXT 10M MAXSIZE 200M
  EXTENT MANAGEMENT LOCAL UNIFORM SIZE 512K;

-- Tablespace dedicado a índices y secuencias
CREATE TABLESPACE TS_IDX
  DATAFILE 'ts_idx01.dbf' SIZE 150M
  AUTOEXTEND ON NEXT 30M MAXSIZE 1G
  EXTENT MANAGEMENT LOCAL UNIFORM SIZE 512K;              	-- Índices PK/FK y secuencias :contentReference[oaicite:4]{index=4}


-- ================================
-- B) Creación de TABLAS con asignación física
-- ================================
-- Se añade TABLESPACE, PCTFREE y PCTUSED según el perfil de uso.

-- 1) Usuarios
CREATE TABLE Usuarios (
  usuario_id  	NUMBER   	NOT NULL,
  nombre      	VARCHAR2(30) NOT NULL,
  apellido    	VARCHAR2(50) NOT NULL,
  email       	VARCHAR2(50) NOT NULL,
  contrasenia 	VARCHAR2(30) NOT NULL,
  fecha_registro  TIMESTAMP	NOT NULL,
  activo      	CHAR(1)  	NOT NULL,
  tipo_usuario_id NUMBER   	NOT NULL
)
TABLESPACE TS_USUARIOS
PCTFREE 10 PCTUSED 40
STORAGE (INITIAL 100K NEXT 50K);  
ALTER TABLE Usuarios ADD CONSTRAINT Usuarios_PK PRIMARY KEY (usuario_id);

-- 2) Tipo_Usuario
CREATE TABLE Tipo_Usuario (
  usuario_id  NUMBER   	NOT NULL,
  descripcion VARCHAR2(30) NOT NULL
)
TABLESPACE TS_PARAM
PCTFREE 20 PCTUSED 40;
ALTER TABLE Tipo_Usuario ADD CONSTRAINT Tipo_Usuario_PK PRIMARY KEY (usuario_id);

-- 3) Tipo_Preguntas
CREATE TABLE Tipo_Preguntas (
  tipo_pregunta_id NUMBER   	NOT NULL,
  descripcion  	VARCHAR2(30) NOT NULL
)
TABLESPACE TS_PARAM
PCTFREE 20 PCTUSED 40;
ALTER TABLE Tipo_Preguntas ADD CONSTRAINT Tipo_Preguntas_PK PRIMARY KEY (tipo_pregunta_id);

-- 4) Tipo_Accion
CREATE TABLE Tipo_Accion (
  tipo_accion_id NUMBER   	NOT NULL,
  descripcion	VARCHAR2(30) NOT NULL
)
TABLESPACE TS_PARAM
PCTFREE 20 PCTUSED 40;
ALTER TABLE Tipo_Accion ADD CONSTRAINT Tipo_Accion_PK PRIMARY KEY (tipo_accion_id);

-- 5) Estado_Accion
CREATE TABLE Estado_Accion (
  estado_accion_id NUMBER   	NOT NULL,
  descripcion  	VARCHAR2(30) NOT NULL CHECK (descripcion IN ('EXITOSO','FALLIDO'))
)
TABLESPACE TS_PARAM
PCTFREE 20 PCTUSED 40;
ALTER TABLE Estado_Accion ADD CONSTRAINT Estado_Accion_PK PRIMARY KEY (estado_accion_id);

-- 6) Cursos
CREATE TABLE Cursos (
  curso_id	NUMBER   	NOT NULL,
  nombre  	VARCHAR2(50) NOT NULL,
  descripcion CLOB,
  activo  	CHAR(1)  	NOT NULL
)
TABLESPACE TS_ESTRUCTURA
PCTFREE 10 PCTUSED 50;
ALTER TABLE Cursos ADD CONSTRAINT Cursos_PK PRIMARY KEY (curso_id);

-- 7) Grupos
CREATE TABLE Grupos (
  grupo_id	NUMBER   	NOT NULL,
  nombre  	VARCHAR2(50) NOT NULL,
  lugar   	VARCHAR2(200),
  horario 	VARCHAR2(200),
  profesor_id NUMBER   	NOT NULL,
  curso_id	NUMBER   	NOT NULL
)
TABLESPACE TS_ESTRUCTURA
PCTFREE 10 PCTUSED 50;
ALTER TABLE Grupos ADD CONSTRAINT Grupos_PK PRIMARY KEY (grupo_id);

-- 8) Temas
CREATE TABLE Temas (
  tema_id 	NUMBER   	NOT NULL,
  nombre  	VARCHAR2(50) NOT NULL,
  descripcion CLOB,
  orden   	NUMBER
)
TABLESPACE TS_ESTRUCTURA
PCTFREE 10 PCTUSED 50;
ALTER TABLE Temas ADD CONSTRAINT Temas_PK PRIMARY KEY (tema_id);

-- 9) Unidades
CREATE TABLE Unidades (
  unidad_id   NUMBER   	NOT NULL,
  nombre  	VARCHAR2(50) NOT NULL,
  descripcion CLOB,
  orden   	NUMBER,
  curso_id	NUMBER   	NOT NULL
)
TABLESPACE TS_ESTRUCTURA
PCTFREE 10 PCTUSED 50;
ALTER TABLE Unidades ADD CONSTRAINT Unidades_PK PRIMARY KEY (unidad_id);

-- 10) Unidades_Temas
CREATE TABLE Unidades_Temas (
  unidad_id NUMBER NOT NULL,
  tema_id   NUMBER NOT NULL,
  orden 	NUMBER NOT NULL
)
TABLESPACE TS_ESTRUCTURA
PCTFREE 15 PCTUSED 40;
ALTER TABLE Unidades_Temas ADD CONSTRAINT Unidades_Temas_PK PRIMARY KEY (unidad_id, tema_id);

-- 11) Preguntas
CREATE TABLE Preguntas (
  pregunta_id   	NUMBER	NOT NULL,
  texto         	CLOB  	NOT NULL,
  fecha_creacion	TIMESTAMP NOT NULL,
  es_publica    	CHAR(1)   NOT NULL,
  tiempo_maximo 	NUMBER,
  pregunta_padre_id NUMBER,
  tipo_pregunta_id  NUMBER	NOT NULL,
  creador_id    	NUMBER	NOT NULL,
  tema_id       	NUMBER	NOT NULL
)
TABLESPACE TS_PREGUNTAS
PCTFREE 5 PCTUSED 50
STORAGE (INITIAL 200K NEXT 100K);
ALTER TABLE Preguntas ADD CONSTRAINT Preguntas_PK PRIMARY KEY (pregunta_id);

-- 12) Opciones_Preguntas
CREATE TABLE Opciones_Preguntas (
  opcion_pregunta_id NUMBER	NOT NULL,
  texto          	CLOB  	NOT NULL,
  es_correcta    	CHAR(1)   NOT NULL,
  orden          	NUMBER,
  pregunta_id    	NUMBER	NOT NULL
)
TABLESPACE TS_PREGUNTAS
PCTFREE 10 PCTUSED 50;
ALTER TABLE Opciones_Preguntas ADD CONSTRAINT Opciones_Preguntas_PK PRIMARY KEY (opcion_pregunta_id);

-- 13) Emparejamiento_Preguntas
CREATE TABLE Emparejamiento_Preguntas (
  emparejamiento_pregunta_id NUMBER	NOT NULL,
  opcion_a               	VARCHAR2(255) NOT NULL,
  opcion_b               	VARCHAR2(255) NOT NULL,
  pregunta_id            	NUMBER	NOT NULL
)
TABLESPACE TS_PREGUNTAS
PCTFREE 10 PCTUSED 50;
ALTER TABLE Emparejamiento_Preguntas ADD CONSTRAINT emparejamiento_preguntas_PK PRIMARY KEY (emparejamiento_pregunta_id);

-- 14) Orden_Preguntas
CREATE TABLE Orden_Preguntas (
  orden_pregunta_id NUMBER	NOT NULL,
  texto         	VARCHAR2(255) NOT NULL,
  posicion_correcta NUMBER	NOT NULL,
  pregunta_id   	NUMBER	NOT NULL
)
TABLESPACE TS_PREGUNTAS
PCTFREE 10 PCTUSED 50;
ALTER TABLE Orden_Preguntas ADD CONSTRAINT orden_preguntas_PK PRIMARY KEY (orden_pregunta_id);

-- 15) Examenes
CREATE TABLE Examenes (
  examen_id              	NUMBER	NOT NULL,
  descripcion            	CLOB,
  fecha_creacion         	TIMESTAMP NOT NULL,
  fecha_disponible       	TIMESTAMP,
  fecha_limite           	TIMESTAMP,
  tiempo_limite          	NUMBER,
  peso                   	NUMBER(5,2),
  umbral_aprobacion      	NUMBER(5,2),
  cantidad_preguntas_mostrar NUMBER,
  aleatorizar_preguntas  	CHAR(1),
  creador_id             	NUMBER	NOT NULL,
  grupo_id               	NUMBER	NOT NULL
)
TABLESPACE TS_EXAMENES
PCTFREE 10 PCTUSED 50;
ALTER TABLE Examenes ADD CONSTRAINT Examenes_PK PRIMARY KEY (examen_id);

-- 16) Preguntas_Examenes
CREATE TABLE Preguntas_Examenes (
  pregunta_examen_id NUMBER	NOT NULL,
  peso           	NUMBER(5,2),
  orden          	NUMBER,
  pregunta_id    	NUMBER	NOT NULL,
  examen_id      	NUMBER	NOT NULL
)
TABLESPACE TS_EXAMENES
PCTFREE 10 PCTUSED 50;
ALTER TABLE Preguntas_Examenes ADD CONSTRAINT Preguntas_Examenes_PK PRIMARY KEY (pregunta_examen_id);

-- 17) Inscripciones
CREATE TABLE Inscripciones (
  inscripcion_id	NUMBER	NOT NULL,
  fecha_inscripcion TIMESTAMP NOT NULL,
  grupo_id      	NUMBER	NOT NULL,
  estudiante_id 	NUMBER	NOT NULL
)
TABLESPACE TS_INSCRIPCIONES
PCTFREE 10 PCTUSED 50;
ALTER TABLE Inscripciones ADD CONSTRAINT Inscripciones_PK PRIMARY KEY (inscripcion_id);

-- 18) Intentos_Examen
CREATE TABLE Intentos_Examen (
  intento_examen_id NUMBER	NOT NULL,
  fecha_inicio  	TIMESTAMP NOT NULL,
  fecha_fin     	TIMESTAMP NOT NULL,
  tiempo_utilizado  NUMBER	NOT NULL,
  puntaje_total 	NUMBER(5,2),
  ip_address    	VARCHAR2(30) NOT NULL,
  estudiante_id 	NUMBER	NOT NULL,
  examen_id     	NUMBER	NOT NULL
)
TABLESPACE TS_INTENTOS
PCTFREE 10 PCTUSED 50;
ALTER TABLE Intentos_Examen ADD CONSTRAINT Intentos_Examen_PK PRIMARY KEY (intento_examen_id);
ALTER TABLE Intentos_Examen ADD direccion_ip VARCHAR2(50);


-- 19) Respuestas_Estudiantes
CREATE TABLE Respuestas_Estudiantes (
  respuesta_estudiante_id NUMBER	NOT NULL,
  es_correcta         	CHAR(1),
  puntaje_obtenido    	NUMBER(5,2),
  intento_examen_id   	NUMBER	NOT NULL,
  pregunta_examen_id  	NUMBER	NOT NULL
)
TABLESPACE TS_RESPUESTAS
PCTFREE 5 PCTUSED 50;
ALTER TABLE Respuestas_Estudiantes ADD CONSTRAINT Respuestas_Estudiantes_PK PRIMARY KEY (respuesta_estudiante_id);

-- 20) Respuestas_Opciones
CREATE TABLE Respuestas_Opciones (
  respuesta_opcion_id 	NUMBER	NOT NULL,
  respuesta_estudiante_id NUMBER	NOT NULL,
  opcion_pregunta_id  	NUMBER	NOT NULL
)
TABLESPACE TS_RESPUESTAS
PCTFREE 10 PCTUSED 50;
ALTER TABLE Respuestas_Opciones ADD CONSTRAINT Respuestas_Opciones_PK PRIMARY KEY (respuesta_opcion_id);

-- 21) Respuestas_Emparejamiento
CREATE TABLE Respuestas_Emparejamiento (
  respuesta_emparejamiento_id NUMBER	NOT NULL,
  opcion_a                	VARCHAR2(255) NOT NULL,
  opcion_b                	VARCHAR2(255) NOT NULL,
  respuesta_estudiante_id 	NUMBER	NOT NULL,
  emparejamiento_pregunta_id  NUMBER	NOT NULL
)
TABLESPACE TS_RESPUESTAS
PCTFREE 10 PCTUSED 50;
ALTER TABLE Respuestas_Emparejamiento ADD CONSTRAINT Respuestas_Emparejamiento_PK PRIMARY KEY (respuesta_emparejamiento_id);

-- 22) Respuestas_Orden
CREATE TABLE Respuestas_Orden (
  respuesta_orden_id  	NUMBER	NOT NULL,
  texto               	CLOB  	NOT NULL,
  posicion_estudiante 	NUMBER	NOT NULL,
  orden_pregunta_id   	NUMBER	NOT NULL,
  respuesta_estudiante_id NUMBER	NOT NULL
)
TABLESPACE TS_RESPUESTAS
PCTFREE 10 PCTUSED 50;
ALTER TABLE Respuestas_Orden ADD CONSTRAINT Respuestas_Orden_PK PRIMARY KEY (respuesta_orden_id);

-- ================================
-- C) Índices en TS_IDX
-- ================================
-- Se crean índices en el tablespace de índices (TS_IDX)
-- Índice adicional para búsquedas por email
CREATE INDEX idx_usuarios_email
  ON Usuarios(email)
  TABLESPACE TS_IDX;

-- ================================
-- Creación de VIEWS
-- ================================

CREATE OR REPLACE VIEW V_Usuarios_Publica AS
SELECT 
  usuario_id,
  nombre,
  apellido,
  email,
  tipo_usuario_id
FROM Usuarios;

CREATE OR REPLACE VIEW V_Usuarios_Por_Tipo AS
SELECT 
  tu.descripcion AS tipo_usuario,
  COUNT(u.usuario_id)      AS total
FROM Usuarios u
JOIN Tipo_Usuario tu ON u.tipo_usuario_id = tu.usuario_id
GROUP BY tu.descripcion;

CREATE OR REPLACE VIEW V_Cursos_Activos AS
SELECT 
  curso_id,
  nombre,
  descripcion
FROM Cursos
WHERE activo = 'S';

CREATE OR REPLACE VIEW V_Cursos_Con_Grupos AS
SELECT
  c.curso_id,
  c.nombre    AS curso,
  g.grupo_id,
  g.nombre    AS grupo,
  u.usuario_id               AS profesor_id,
  u.nombre || ' ' || u.apellido AS profesor
FROM Cursos c
JOIN Grupos g   ON c.curso_id = g.curso_id
JOIN Usuarios u ON g.profesor_id = u.usuario_id;

CREATE OR REPLACE VIEW V_Inscripciones_Activas AS
SELECT
  inscripcion_id,
  fecha_inscripcion,
  grupo_id,
  estudiante_id
FROM Inscripciones
WHERE fecha_inscripcion >= SYSTIMESTAMP - INTERVAL '30' DAY;

CREATE OR REPLACE VIEW V_Preguntas_Por_Tema AS
SELECT
  t.tema_id,
  t.nombre AS tema,
  COUNT(p.pregunta_id) AS num_preguntas
FROM Temas t
LEFT JOIN Preguntas p ON t.tema_id = p.tema_id
GROUP BY t.tema_id, t.nombre;

CREATE OR REPLACE VIEW V_Preguntas_Examen_Detalle AS
SELECT
  pe.examen_id,
  pe.pregunta_examen_id,
  pe.peso,
  pe.orden,
  p.texto AS pregunta
FROM Preguntas_Examenes pe
JOIN Preguntas p ON pe.pregunta_id = p.pregunta_id;

CREATE OR REPLACE VIEW V_Intentos_Detalle AS
SELECT
  intento_examen_id,
  estudiante_id,
  examen_id,
  fecha_inicio,
  fecha_fin,
  tiempo_utilizado,
  puntaje_total
FROM Intentos_Examen;

CREATE OR REPLACE VIEW V_Respuesta_Puntaje AS
SELECT
  respuesta_estudiante_id,
  intento_examen_id,
  pregunta_examen_id,
  puntaje_obtenido
FROM Respuestas_Estudiantes;

CREATE OR REPLACE VIEW V_Resultados_Estudiante AS
SELECT
  u.usuario_id,
  u.nombre || ' ' || u.apellido AS estudiante,
  e.examen_id,
  e.descripcion             AS examen,
  ie.puntaje_total,
  CASE
    WHEN ie.puntaje_total >= e.umbral_aprobacion THEN 'APROBADO'
    ELSE 'REPROBADO'
  END AS estado
FROM Intentos_Examen ie
JOIN Usuarios u  ON ie.estudiante_id = u.usuario_id
JOIN Examenes e ON ie.examen_id     = e.examen_id;

CREATE OR REPLACE VIEW V_Estadisticas_Curso AS
SELECT
  c.curso_id,
  c.nombre AS curso,
  AVG(ie.puntaje_total) AS promedio,
  MIN(ie.puntaje_total) AS minimo,
  MAX(ie.puntaje_total) AS maximo
FROM Examenes e
JOIN Grupos g           ON e.grupo_id   = g.grupo_id
JOIN Cursos c           ON g.curso_id   = c.curso_id
JOIN Intentos_Examen ie ON e.examen_id  = ie.examen_id
GROUP BY c.curso_id, c.nombre;

-- Agregar columna max_intentos a la tabla Examenes (ejecutar este ALTER TABLE)
ALTER TABLE Examenes ADD (max_intentos NUMBER DEFAULT 1);

-- Agregar columna retroalimentacion a la tabla Preguntas (ejecutar este ALTER TABLE)
ALTER TABLE Preguntas ADD (retroalimentacion CLOB);