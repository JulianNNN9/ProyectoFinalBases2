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