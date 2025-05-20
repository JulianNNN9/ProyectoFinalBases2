--==========1. Tablas Paramétricas===========

-- Tipo de Usuario
INSERT INTO Tipo_Usuario (usuario_id, descripcion) VALUES (1, 'ESTUDIANTE');
INSERT INTO Tipo_Usuario (usuario_id, descripcion) VALUES (2, 'PROFESOR');

-- Tipo de Preguntas
INSERT INTO Tipo_Preguntas (tipo_pregunta_id, descripcion) VALUES (1, 'OPCION_MULTIPLE');
INSERT INTO Tipo_Preguntas (tipo_pregunta_id, descripcion) VALUES (2, 'OPCION_UNICA');
INSERT INTO Tipo_Preguntas (tipo_pregunta_id, descripcion) VALUES (3, 'VERDADERO_FALSO');
INSERT INTO Tipo_Preguntas (tipo_pregunta_id, descripcion) VALUES (4, 'ORDENAR');
INSERT INTO Tipo_Preguntas (tipo_pregunta_id, descripcion) VALUES (5, 'COMPLETAR');
INSERT INTO Tipo_Preguntas (tipo_pregunta_id, descripcion) VALUES (6, 'EMPAREJAR');

-- Estado Acción
INSERT INTO Estado_Accion (estado_accion_id, descripcion) VALUES (1, 'EXITOSO');
INSERT INTO Estado_Accion (estado_accion_id, descripcion) VALUES (2, 'FALLIDO');

-- Tipo Acción
INSERT INTO Tipo_Accion (tipo_accion_id, descripcion) VALUES (1, 'ENTRADA');
INSERT INTO Tipo_Accion (tipo_accion_id, descripcion) VALUES (2, 'SALIDA');

--==========2. Entidades principales (25+ registros)============

--Usuarios (25 profesores + 50 estudiantes)
BEGIN
  FOR i IN 1..50 LOOP
    INSERT INTO Usuarios (usuario_id, nombre, apellido, email, contrasenia, fecha_registro, activo, tipo_usuario_id)
    VALUES (i, 'Nombre'||i, 'Apellido'||i, 'user'||i||'@correo.com', 'clave'||i, SYSTIMESTAMP, 'S',
            CASE WHEN i <= 25 THEN 2 ELSE 1 END); -- 1: estudiante, 2: profesor
  END LOOP;
END;

--Cursos (25 registros)
BEGIN
  FOR i IN 1..25 LOOP
    INSERT INTO Cursos (curso_id, nombre, descripcion, activo)
    VALUES (i, 'Curso '||i, 'Descripción del curso '||i, 'S');
  END LOOP;
END;

--Grupos (25 registros)
BEGIN
  FOR i IN 1..25 LOOP
    INSERT INTO Grupos (grupo_id, nombre, lugar, horario, profesor_id, curso_id)
    VALUES (i, 'Grupo '||i, 'Aula '||i, 'Lunes 8-10AM', i, i);
  END LOOP;
END;

--Temas (25 registros)
BEGIN
  FOR i IN 1..25 LOOP
    INSERT INTO Temas (tema_id, nombre, descripcion, orden)
    VALUES (i, 'Tema '||i, 'Contenido del tema '||i, i);
  END LOOP;
END;

--Unidades (25 registros)
BEGIN
  FOR i IN 1..25 LOOP
    INSERT INTO Unidades (unidad_id, nombre, descripcion, orden, curso_id)
    VALUES (i, 'Unidad '||i, 'Descripción unidad '||i, i, i);
  END LOOP;
END;

--==========3. Tablas Intermedias (mínimo 40 registros)============

--Unidades_Temas (40 registros) MALAAAAAA
BEGIN
  FOR i IN 1..40 LOOP
    INSERT INTO Unidades_Temas (unidad_id, tema_id, orden)
    VALUES (MOD(i, 25) + 1, MOD(i, 25) + 1, i);
  END LOOP;
END;
