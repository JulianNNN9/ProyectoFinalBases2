-- Función para obtener estadísticas de exámenes por curso
CREATE OR REPLACE FUNCTION fn_estadisticas_curso(
  p_curso_id IN NUMBER
) RETURN SYS_REFCURSOR AS
  v_cursor SYS_REFCURSOR;
BEGIN
  OPEN v_cursor FOR
    SELECT 
      c.nombre AS curso,
      g.nombre AS grupo,
      e.examen_id,
      COUNT(ie.intento_examen_id) AS total_intentos,
      AVG(ie.puntaje_total) AS promedio,
      MIN(ie.puntaje_total) AS puntaje_minimo,
      MAX(ie.puntaje_total) AS puntaje_maximo,
      COUNT(CASE WHEN ie.puntaje_total >= e.umbral_aprobacion THEN 1 END) AS aprobados,
      COUNT(CASE WHEN ie.puntaje_total < e.umbral_aprobacion THEN 1 END) AS reprobados,
      ROUND((COUNT(CASE WHEN ie.puntaje_total >= e.umbral_aprobacion THEN 1 END) / 
             COUNT(ie.intento_examen_id)) * 100, 2) AS porcentaje_aprobacion
    FROM Cursos c
    JOIN Grupos g ON c.curso_id = g.curso_id
    JOIN Examenes e ON g.grupo_id = e.grupo_id
    LEFT JOIN Intentos_Examen ie ON e.examen_id = ie.examen_id
    WHERE c.curso_id = p_curso_id
    GROUP BY c.nombre, g.nombre, e.examen_id;
    
  RETURN v_cursor;
END;
/

-- Procedimiento para generar reporte de desempeño por estudiante
CREATE OR REPLACE PROCEDURE sp_reporte_desempeno_estudiante(
  p_estudiante_id IN NUMBER,
  p_grupo_id IN NUMBER,
  p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
  OPEN p_cursor FOR
    SELECT 
      e.examen_id,
      ie.intento_examen_id,
      ie.fecha_inicio,
      ie.fecha_fin,
      ROUND((EXTRACT(DAY FROM (ie.fecha_fin - ie.fecha_inicio)) * 24 * 60) +
            (EXTRACT(HOUR FROM (ie.fecha_fin - ie.fecha_inicio)) * 60) +
             EXTRACT(MINUTE FROM (ie.fecha_fin - ie.fecha_inicio)), 2) AS tiempo_minutos,
      ie.puntaje_total,
      e.umbral_aprobacion,
      CASE 
        WHEN ie.puntaje_total >= e.umbral_aprobacion THEN 'APROBADO'
        ELSE 'REPROBADO'
      END AS resultado,
      COUNT(re.respuesta_estudiante_id) AS total_preguntas,
      COUNT(CASE WHEN re.es_correcta = 'S' THEN 1 END) AS preguntas_correctas,
      ROUND((COUNT(CASE WHEN re.es_correcta = 'S' THEN 1 END) / 
             COUNT(re.respuesta_estudiante_id)) * 100, 2) AS porcentaje_acierto
    FROM Intentos_Examen ie
    JOIN Examenes e ON ie.examen_id = e.examen_id
    LEFT JOIN Respuestas_Estudiantes re ON ie.intento_examen_id = re.intento_examen_id
    WHERE ie.estudiante_id = p_estudiante_id
    AND e.grupo_id = p_grupo_id
    GROUP BY e.examen_id, ie.intento_examen_id, ie.fecha_inicio, ie.fecha_fin, 
             ie.puntaje_total, e.umbral_aprobacion;
END;
/

-- Función para analizar la dificultad de las preguntas de un examen
CREATE OR REPLACE FUNCTION fn_analisis_dificultad_preguntas(
  p_examen_id IN NUMBER
) RETURN SYS_REFCURSOR AS
  v_cursor SYS_REFCURSOR;
BEGIN
  OPEN v_cursor FOR
    SELECT 
      pe.pregunta_examen_id,
      p.texto AS pregunta,
      tp.descripcion AS tipo_pregunta,
      COUNT(re.respuesta_estudiante_id) AS total_intentos,
      COUNT(CASE WHEN re.es_correcta = 'S' THEN 1 END) AS respuestas_correctas,
      ROUND((COUNT(CASE WHEN re.es_correcta = 'S' THEN 1 END) / 
             NULLIF(COUNT(re.respuesta_estudiante_id), 0)) * 100, 2) AS porcentaje_acierto,
      CASE 
        WHEN (COUNT(CASE WHEN re.es_correcta = 'S' THEN 1 END) / 
              NULLIF(COUNT(re.respuesta_estudiante_id), 0)) * 100 < 30 THEN 'DIFÍCIL'
        WHEN (COUNT(CASE WHEN re.es_correcta = 'S' THEN 1 END) / 
              NULLIF(COUNT(re.respuesta_estudiante_id), 0)) * 100 > 70 THEN 'FÁCIL'
        ELSE 'MEDIA'
      END AS dificultad
    FROM Preguntas_Examenes pe
    JOIN Preguntas p ON pe.pregunta_id = p.pregunta_id
    JOIN Tipo_Preguntas tp ON p.tipo_pregunta_id = tp.tipo_pregunta_id
    LEFT JOIN Respuestas_Estudiantes re ON pe.pregunta_examen_id = re.pregunta_examen_id
    WHERE pe.examen_id = p_examen_id
    GROUP BY pe.pregunta_examen_id, p.texto, tp.descripcion
    ORDER BY porcentaje_acierto ASC;
    
  RETURN v_cursor;
END;
/

-- Procedimiento para obtener el progreso histórico de un estudiante
CREATE OR REPLACE PROCEDURE sp_progreso_estudiante(
  p_estudiante_id IN NUMBER,
  p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
  OPEN p_cursor FOR
    SELECT 
      c.nombre AS curso,
      g.nombre AS grupo,
      e.examen_id,
      SUBSTR(e.descripcion, 1, 50) AS examen,
      ie.fecha_inicio,
      ie.puntaje_total,
      e.umbral_aprobacion,
      CASE 
        WHEN ie.puntaje_total >= e.umbral_aprobacion THEN 'APROBADO'
        ELSE 'REPROBADO'
      END AS resultado,
      ROW_NUMBER() OVER (PARTITION BY g.grupo_id ORDER BY ie.fecha_inicio) AS intento_numero,
      AVG(ie.puntaje_total) OVER (PARTITION BY g.grupo_id ORDER BY ie.fecha_inicio 
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS promedio_acumulado
    FROM Intentos_Examen ie
    JOIN Examenes e ON ie.examen_id = e.examen_id
    JOIN Grupos g ON e.grupo_id = g.grupo_id
    JOIN Cursos c ON g.curso_id = c.curso_id
    WHERE ie.estudiante_id = p_estudiante_id
    ORDER BY ie.fecha_inicio;
END;
/

-- Función para analizar el rendimiento comparativo de los grupos
CREATE OR REPLACE FUNCTION fn_rendimiento_grupos(
  p_curso_id IN NUMBER
) RETURN SYS_REFCURSOR AS
  v_cursor SYS_REFCURSOR;
BEGIN
  OPEN v_cursor FOR
    SELECT 
      g.grupo_id,
      g.nombre AS grupo,
      u.nombre || ' ' || u.apellido AS profesor,
      COUNT(DISTINCT ie.estudiante_id) AS total_estudiantes,
      COUNT(DISTINCT ie.examen_id) AS total_examenes,
      COUNT(ie.intento_examen_id) AS total_intentos,
      ROUND(AVG(ie.puntaje_total), 2) AS promedio_general,
      ROUND(STDDEV(ie.puntaje_total), 2) AS desviacion_estandar,
      COUNT(CASE WHEN ie.puntaje_total >= e.umbral_aprobacion THEN 1 END) AS intentos_aprobados,
      ROUND((COUNT(CASE WHEN ie.puntaje_total >= e.umbral_aprobacion THEN 1 END) / 
             NULLIF(COUNT(ie.intento_examen_id), 0)) * 100, 2) AS porcentaje_aprobacion,
      MIN(ie.puntaje_total) AS puntaje_minimo,
      MAX(ie.puntaje_total) AS puntaje_maximo,
      PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ie.puntaje_total) AS mediana
    FROM Grupos g
    JOIN Usuarios u ON g.profesor_id = u.usuario_id
    JOIN Examenes e ON g.grupo_id = e.grupo_id
    JOIN Intentos_Examen ie ON e.examen_id = ie.examen_id
    WHERE g.curso_id = p_curso_id
    GROUP BY g.grupo_id, g.nombre, u.nombre || ' ' || u.apellido
    ORDER BY promedio_general DESC;
    
  RETURN v_cursor;
END;
/

-- Procedimiento para generar reporte detallado de intentos de examen
CREATE OR REPLACE PROCEDURE sp_reporte_detalle_intentos(
  p_examen_id IN NUMBER DEFAULT NULL,
  p_grupo_id IN NUMBER DEFAULT NULL,
  p_fecha_inicio IN DATE DEFAULT NULL,
  p_fecha_fin IN DATE DEFAULT NULL,
  p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
  OPEN p_cursor FOR
    SELECT 
      ie.intento_examen_id,
      ie.fecha_inicio AS fecha_intento,
      ie.fecha_fin AS fecha_finalizacion,
      -- Datos del estudiante
      u.usuario_id,
      u.nombre || ' ' || u.apellido AS nombre_completo,
      u.email,
      u.nombre_usuario,
      -- Datos del examen
      e.examen_id,
      e.titulo AS titulo_examen,
      SUBSTR(e.descripcion, 1, 50) AS descripcion_examen,
      c.nombre AS curso,
      g.nombre AS grupo,
      -- Puntaje y estado
      ie.puntaje_total,
      e.umbral_aprobacion,
      CASE 
        WHEN ie.puntaje_total >= e.umbral_aprobacion THEN 'APROBADO'
        ELSE 'REPROBADO'
      END AS resultado,
      -- Tiempo utilizado
      ie.tiempo_utilizado AS tiempo_minutos,
      FLOOR(ie.tiempo_utilizado / 60) || 'h ' || 
      MOD(ie.tiempo_utilizado, 60) || 'm' AS tiempo_formato,
      -- Información de acceso
      ie.ip_acceso,
      ie.dispositivo,
      ie.navegador,
      -- Datos de localización basados en IP (si están disponibles)
      ie.ubicacion_ciudad,
      ie.ubicacion_pais,
      -- Estadísticas del intento
      (SELECT COUNT(*) 
       FROM Respuestas_Estudiantes re 
       WHERE re.intento_examen_id = ie.intento_examen_id) AS total_preguntas_respondidas,
      (SELECT COUNT(*) 
       FROM Respuestas_Estudiantes re 
       WHERE re.intento_examen_id = ie.intento_examen_id 
       AND re.es_correcta = 'S') AS preguntas_correctas
    FROM Intentos_Examen ie
    JOIN Examenes e ON ie.examen_id = e.examen_id
    JOIN Grupos g ON e.grupo_id = g.grupo_id
    JOIN Cursos c ON g.curso_id = c.curso_id
    JOIN Usuarios u ON ie.estudiante_id = u.usuario_id
    WHERE (p_examen_id IS NULL OR ie.examen_id = p_examen_id)
    AND (p_grupo_id IS NULL OR g.grupo_id = p_grupo_id)
    AND (p_fecha_inicio IS NULL OR TRUNC(ie.fecha_inicio) >= TRUNC(p_fecha_inicio))
    AND (p_fecha_fin IS NULL OR TRUNC(ie.fecha_inicio) <= TRUNC(p_fecha_fin))
    ORDER BY ie.fecha_inicio DESC;
END;
/

-- Procedimiento para generar reporte de intentos por estudiante específico
CREATE OR REPLACE PROCEDURE sp_reporte_intentos_estudiante(
  p_estudiante_id IN NUMBER,
  p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
  OPEN p_cursor FOR
    SELECT 
      ie.intento_examen_id,
      TO_CHAR(ie.fecha_inicio, 'DD/MM/YYYY HH24:MI:SS') AS fecha_intento,
      TO_CHAR(ie.fecha_fin, 'DD/MM/YYYY HH24:MI:SS') AS fecha_finalizacion,
      e.titulo AS titulo_examen,
      c.nombre AS curso,
      g.nombre AS grupo,
      ie.puntaje_total,
      CASE 
        WHEN ie.puntaje_total >= e.umbral_aprobacion THEN 'APROBADO'
        ELSE 'REPROBADO'
      END AS resultado,
      ie.tiempo_utilizado AS tiempo_minutos,
      FLOOR(ie.tiempo_utilizado / 60) || 'h ' || 
      MOD(ie.tiempo_utilizado, 60) || 'm' AS tiempo_formato,
      ie.ip_acceso,
      ie.ubicacion_ciudad || ', ' || ie.ubicacion_pais AS ubicacion,
      (SELECT COUNT(*) 
       FROM Respuestas_Estudiantes re 
       WHERE re.intento_examen_id = ie.intento_examen_id) AS preguntas_respondidas,
      (SELECT COUNT(*) 
       FROM Respuestas_Estudiantes re 
       WHERE re.intento_examen_id = ie.intento_examen_id 
       AND re.es_correcta = 'S') AS preguntas_correctas
    FROM Intentos_Examen ie
    JOIN Examenes e ON ie.examen_id = e.examen_id
    JOIN Grupos g ON e.grupo_id = g.grupo_id
    JOIN Cursos c ON g.curso_id = c.curso_id
    WHERE ie.estudiante_id = p_estudiante_id
    ORDER BY ie.fecha_inicio DESC;
END;
/