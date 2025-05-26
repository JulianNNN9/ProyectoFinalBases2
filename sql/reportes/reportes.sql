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
      CASE
        WHEN COUNT(ie.intento_examen_id) = 0 THEN NULL -- Or 0 if 0% is preferred for no attempts
        ELSE ROUND((COUNT(CASE WHEN ie.puntaje_total >= e.umbral_aprobacion THEN 1 END) * 100.0) / COUNT(ie.intento_examen_id), 2)
      END AS porcentaje_aprobacion
    FROM Cursos c
    JOIN Grupos g ON c.curso_id = g.curso_id
    JOIN Examenes e ON g.grupo_id = e.grupo_id
    LEFT JOIN Intentos_Examen ie ON e.examen_id = ie.examen_id
    WHERE c.curso_id = p_curso_id
    GROUP BY c.nombre, g.nombre, e.examen_id, e.umbral_aprobacion;

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
    WITH Preguntas_Texto_CTE AS (
      SELECT
        p.pregunta_id,
        DBMS_LOB.SUBSTR(p.texto, 4000, 1) AS pregunta_texto_varchar,
        p.tipo_pregunta_id -- Include other necessary columns from Preguntas
      FROM Preguntas p
    )
    SELECT
      pe.pregunta_examen_id,
      pt_cte.pregunta_texto_varchar AS pregunta,
      tp.descripcion AS tipo_pregunta,
      COUNT(re.respuesta_estudiante_id) AS total_intentos,
      COUNT(CASE WHEN re.es_correcta = 'S' THEN 1 END) AS respuestas_correctas,
      ROUND((COUNT(CASE WHEN re.es_correcta = 'S' THEN 1 END) * 100.0 /
             NULLIF(COUNT(re.respuesta_estudiante_id), 0)), 2) AS porcentaje_acierto,
      CASE
        WHEN (COUNT(CASE WHEN re.es_correcta = 'S' THEN 1 END) * 100.0 /
              NULLIF(COUNT(re.respuesta_estudiante_id), 0)) < 30 THEN 'DIFÍCIL'
        WHEN (COUNT(CASE WHEN re.es_correcta = 'S' THEN 1 END) * 100.0 /
              NULLIF(COUNT(re.respuesta_estudiante_id), 0)) > 70 THEN 'FÁCIL'
        ELSE 'MEDIA'
      END AS dificultad
    FROM Preguntas_Examenes pe
    JOIN Preguntas_Texto_CTE pt_cte ON pe.pregunta_id = pt_cte.pregunta_id
    JOIN Tipo_Preguntas tp ON pt_cte.tipo_pregunta_id = tp.tipo_pregunta_id
    LEFT JOIN Respuestas_Estudiantes re ON pe.pregunta_examen_id = re.pregunta_examen_id
    WHERE pe.examen_id = p_examen_id
    GROUP BY pe.pregunta_examen_id, pt_cte.pregunta_texto_varchar, tp.descripcion
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