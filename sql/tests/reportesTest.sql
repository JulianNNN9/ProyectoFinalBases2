-- sql/tests/reportesTest.sql
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- Test for fn_estadisticas_curso
DECLARE
  l_cursor SYS_REFCURSOR;
  v_curso_nombre Cursos.nombre%TYPE;
  v_grupo_nombre Grupos.nombre%TYPE;
  v_examen_id Examenes.examen_id%TYPE;
  v_total_intentos NUMBER;
  v_promedio NUMBER;
  v_puntaje_minimo NUMBER;
  v_puntaje_maximo NUMBER;
  v_aprobados NUMBER;
  v_reprobados NUMBER;
  v_porcentaje_aprobacion NUMBER;
  v_test_curso_id NUMBER := 1; -- Example Curso ID
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test fn_estadisticas_curso (Curso ID: ' || v_test_curso_id || ') ---');
  l_cursor := fn_estadisticas_curso(p_curso_id => v_test_curso_id);
  LOOP
    FETCH l_cursor INTO 
      v_curso_nombre, 
      v_grupo_nombre, 
      v_examen_id, 
      v_total_intentos, 
      v_promedio, 
      v_puntaje_minimo, 
      v_puntaje_maximo, 
      v_aprobados, 
      v_reprobados, 
      v_porcentaje_aprobacion;
    EXIT WHEN l_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(
      'Curso: ' || v_curso_nombre || 
      ', Grupo: ' || v_grupo_nombre || 
      ', Examen ID: ' || v_examen_id ||
      ', Intentos: ' || v_total_intentos ||
      ', Promedio: ' || ROUND(NVL(v_promedio,0),2) ||
      ', Min: ' || NVL(v_puntaje_minimo,0) ||
      ', Max: ' || NVL(v_puntaje_maximo,0) ||
      ', Aprobados: ' || v_aprobados ||
      ', Reprobados: ' || v_reprobados ||
      ', % Aprob: ' || NVL(v_porcentaje_aprobacion,0)
    );
  END LOOP;
  CLOSE l_cursor;
  DBMS_OUTPUT.PUT_LINE('--- End Test fn_estadisticas_curso ---');
  DBMS_OUTPUT.PUT_LINE('');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in fn_estadisticas_curso test: ' || SQLERRM);
    IF l_cursor%ISOPEN THEN
      CLOSE l_cursor;
    END IF;
END;
/

-- Test for sp_reporte_desempeno_estudiante
DECLARE
  l_cursor SYS_REFCURSOR;
  v_examen_id Examenes.examen_id%TYPE;
  v_intento_examen_id Intentos_Examen.intento_examen_id%TYPE;
  v_fecha_inicio Intentos_Examen.fecha_inicio%TYPE;
  v_fecha_fin Intentos_Examen.fecha_fin%TYPE;
  v_tiempo_minutos NUMBER;
  v_puntaje_total Intentos_Examen.puntaje_total%TYPE;
  v_umbral_aprobacion Examenes.umbral_aprobacion%TYPE;
  v_resultado VARCHAR2(20);
  v_total_preguntas NUMBER;
  v_preguntas_correctas NUMBER;
  v_porcentaje_acierto NUMBER;
  v_test_estudiante_id NUMBER := 101; -- Example Estudiante ID
  v_test_grupo_id NUMBER := 1;       -- Example Grupo ID
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test sp_reporte_desempeno_estudiante (Estudiante ID: ' || v_test_estudiante_id || ', Grupo ID: ' || v_test_grupo_id || ') ---');
  sp_reporte_desempeno_estudiante(
    p_estudiante_id => v_test_estudiante_id,
    p_grupo_id => v_test_grupo_id,
    p_cursor => l_cursor
  );
  LOOP
    FETCH l_cursor INTO
      v_examen_id,
      v_intento_examen_id,
      v_fecha_inicio,
      v_fecha_fin,
      v_tiempo_minutos,
      v_puntaje_total,
      v_umbral_aprobacion,
      v_resultado,
      v_total_preguntas,
      v_preguntas_correctas,
      v_porcentaje_acierto;
    EXIT WHEN l_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(
      'Examen ID: ' || v_examen_id ||
      ', Intento ID: ' || v_intento_examen_id ||
      ', Inicio: ' || TO_CHAR(v_fecha_inicio, 'YYYY-MM-DD HH24:MI:SS') ||
      ', Fin: ' || TO_CHAR(v_fecha_fin, 'YYYY-MM-DD HH24:MI:SS') ||
      ', Tiempo (min): ' || ROUND(NVL(v_tiempo_minutos,0),2) ||
      ', Puntaje: ' || NVL(v_puntaje_total,0) ||
      ', Umbral: ' || NVL(v_umbral_aprobacion,0) ||
      ', Resultado: ' || v_resultado ||
      ', Total Preg: ' || v_total_preguntas ||
      ', Correctas: ' || v_preguntas_correctas ||
      ', % Acierto: ' || NVL(v_porcentaje_acierto,0)
    );
  END LOOP;
  CLOSE l_cursor;
  DBMS_OUTPUT.PUT_LINE('--- End Test sp_reporte_desempeno_estudiante ---');
  DBMS_OUTPUT.PUT_LINE('');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in sp_reporte_desempeno_estudiante test: ' || SQLERRM);
    IF l_cursor%ISOPEN THEN
      CLOSE l_cursor;
    END IF;
END;
/

-- Test for fn_analisis_dificultad_preguntas
DECLARE
  l_cursor SYS_REFCURSOR;
  v_pregunta_examen_id Preguntas_Examenes.pregunta_examen_id%TYPE;
  v_pregunta_texto VARCHAR2(4000); -- DBMS_LOB.SUBSTR returns VARCHAR2
  v_tipo_pregunta Tipo_Preguntas.descripcion%TYPE;
  v_total_intentos_q NUMBER;
  v_respuestas_correctas_q NUMBER;
  v_porcentaje_acierto_q NUMBER;
  v_dificultad VARCHAR2(20);
  v_test_examen_id NUMBER := 1; -- Example Examen ID
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test fn_analisis_dificultad_preguntas (Examen ID: ' || v_test_examen_id || ') ---');
  l_cursor := fn_analisis_dificultad_preguntas(p_examen_id => v_test_examen_id);
  LOOP
    FETCH l_cursor INTO
      v_pregunta_examen_id,
      v_pregunta_texto,
      v_tipo_pregunta,
      v_total_intentos_q,
      v_respuestas_correctas_q,
      v_porcentaje_acierto_q,
      v_dificultad;
    EXIT WHEN l_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(
      'Pregunta Examen ID: ' || v_pregunta_examen_id ||
      ', Pregunta: "' || SUBSTR(v_pregunta_texto, 1, 50) || '..."' || -- Displaying first 50 chars
      ', Tipo: ' || v_tipo_pregunta ||
      ', Intentos: ' || v_total_intentos_q ||
      ', Correctas: ' || v_respuestas_correctas_q ||
      ', % Acierto: ' || NVL(v_porcentaje_acierto_q,0) ||
      ', Dificultad: ' || v_dificultad
    );
  END LOOP;
  CLOSE l_cursor;
  DBMS_OUTPUT.PUT_LINE('--- End Test fn_analisis_dificultad_preguntas ---');
  DBMS_OUTPUT.PUT_LINE('');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in fn_analisis_dificultad_preguntas test: ' || SQLERRM);
    IF l_cursor%ISOPEN THEN
      CLOSE l_cursor;
    END IF;
END;
/

-- Test for sp_progreso_estudiante
DECLARE
  l_cursor SYS_REFCURSOR;
  v_curso_nombre_prog Cursos.nombre%TYPE;
  v_grupo_nombre_prog Grupos.nombre%TYPE;
  v_examen_id_prog Examenes.examen_id%TYPE;
  v_examen_desc VARCHAR2(50);
  v_fecha_inicio_prog Intentos_Examen.fecha_inicio%TYPE;
  v_puntaje_total_prog Intentos_Examen.puntaje_total%TYPE;
  v_umbral_aprobacion_prog Examenes.umbral_aprobacion%TYPE;
  v_resultado_prog VARCHAR2(20);
  v_intento_numero NUMBER;
  v_promedio_acumulado NUMBER;
  v_test_estudiante_id_prog NUMBER := 101; -- Example Estudiante ID
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test sp_progreso_estudiante (Estudiante ID: ' || v_test_estudiante_id_prog || ') ---');
  sp_progreso_estudiante(
    p_estudiante_id => v_test_estudiante_id_prog,
    p_cursor => l_cursor
  );
  LOOP
    FETCH l_cursor INTO
      v_curso_nombre_prog,
      v_grupo_nombre_prog,
      v_examen_id_prog,
      v_examen_desc,
      v_fecha_inicio_prog,
      v_puntaje_total_prog,
      v_umbral_aprobacion_prog,
      v_resultado_prog,
      v_intento_numero,
      v_promedio_acumulado;
    EXIT WHEN l_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(
      'Curso: ' || v_curso_nombre_prog ||
      ', Grupo: ' || v_grupo_nombre_prog ||
      ', Examen ID: ' || v_examen_id_prog ||
      ', Examen Desc: "' || v_examen_desc || '"' ||
      ', Fecha: ' || TO_CHAR(v_fecha_inicio_prog, 'YYYY-MM-DD HH24:MI:SS') ||
      ', Puntaje: ' || NVL(v_puntaje_total_prog,0) ||
      ', Umbral: ' || NVL(v_umbral_aprobacion_prog,0) ||
      ', Resultado: ' || v_resultado_prog ||
      ', Intento #: ' || v_intento_numero ||
      ', Prom Acum: ' || ROUND(NVL(v_promedio_acumulado,0),2)
    );
  END LOOP;
  CLOSE l_cursor;
  DBMS_OUTPUT.PUT_LINE('--- End Test sp_progreso_estudiante ---');
  DBMS_OUTPUT.PUT_LINE('');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in sp_progreso_estudiante test: ' || SQLERRM);
    IF l_cursor%ISOPEN THEN
      CLOSE l_cursor;
    END IF;
END;
/

-- Test for fn_rendimiento_grupos
DECLARE
  l_cursor SYS_REFCURSOR;
  v_grupo_id_rend Grupos.grupo_id%TYPE;
  v_grupo_nombre_rend Grupos.nombre%TYPE;
  v_profesor VARCHAR2(201); -- u.nombre || ' ' || u.apellido
  v_total_estudiantes NUMBER;
  v_total_examenes NUMBER;
  v_total_intentos_g NUMBER;
  v_promedio_general NUMBER;
  v_desviacion_estandar NUMBER;
  v_intentos_aprobados_g NUMBER;
  v_porcentaje_aprobacion_g NUMBER;
  v_puntaje_minimo_g NUMBER;
  v_puntaje_maximo_g NUMBER;
  v_mediana NUMBER;
  v_test_curso_id_rend NUMBER := 1; -- Example Curso ID
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Test fn_rendimiento_grupos (Curso ID: ' || v_test_curso_id_rend || ') ---');
  l_cursor := fn_rendimiento_grupos(p_curso_id => v_test_curso_id_rend);
  LOOP
    FETCH l_cursor INTO
      v_grupo_id_rend,
      v_grupo_nombre_rend,
      v_profesor,
      v_total_estudiantes,
      v_total_examenes,
      v_total_intentos_g,
      v_promedio_general,
      v_desviacion_estandar,
      v_intentos_aprobados_g,
      v_porcentaje_aprobacion_g,
      v_puntaje_minimo_g,
      v_puntaje_maximo_g,
      v_mediana;
    EXIT WHEN l_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(
      'Grupo ID: ' || v_grupo_id_rend ||
      ', Grupo: ' || v_grupo_nombre_rend ||
      ', Profesor: ' || v_profesor ||
      ', Estudiantes: ' || v_total_estudiantes ||
      ', Examenes: ' || v_total_examenes ||
      ', Total Intentos: ' || v_total_intentos_g ||
      ', Promedio Gen: ' || ROUND(NVL(v_promedio_general,0),2) ||
      ', StdDev: ' || ROUND(NVL(v_desviacion_estandar,0),2) ||
      ', Aprobados: ' || v_intentos_aprobados_g ||
      ', % Aprob: ' || NVL(v_porcentaje_aprobacion_g,0) ||
      ', Min Puntaje: ' || NVL(v_puntaje_minimo_g,0) ||
      ', Max Puntaje: ' || NVL(v_puntaje_maximo_g,0) ||
      ', Mediana: ' || NVL(v_mediana,0)
    );
  END LOOP;
  CLOSE l_cursor;
  DBMS_OUTPUT.PUT_LINE('--- End Test fn_rendimiento_grupos ---');
  DBMS_OUTPUT.PUT_LINE('');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error in fn_rendimiento_grupos test: ' || SQLERRM);
    IF l_cursor%ISOPEN THEN
      CLOSE l_cursor;
    END IF;
END;
/