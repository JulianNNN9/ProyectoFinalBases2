-- Create required sequence
CREATE SEQUENCE SQ_INTENTO_EXAMEN_ID
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;
/

-- Función para verificar elegibilidad del estudiante
CREATE OR REPLACE FUNCTION fn_verificar_elegibilidad(
  p_estudiante_id IN NUMBER,
  p_examen_id IN NUMBER
) RETURN VARCHAR2 IS
  v_grupo_id NUMBER;
  v_inscrito NUMBER := 0;
  v_fecha_actual TIMESTAMP;
  v_fecha_disponible TIMESTAMP;
  v_fecha_limite TIMESTAMP;
  v_intentos_realizados NUMBER := 0;
  v_resultado VARCHAR2(200);
BEGIN
  -- Verificar fechas del examen
  SELECT fecha_disponible, fecha_limite, grupo_id
  INTO v_fecha_disponible, v_fecha_limite, v_grupo_id
  FROM Examenes
  WHERE examen_id = p_examen_id;
  
  -- Verificar inscripción en el grupo
  SELECT COUNT(*)
  INTO v_inscrito
  FROM Inscripciones
  WHERE estudiante_id = p_estudiante_id AND grupo_id = v_grupo_id;
  
  IF v_inscrito = 0 THEN
    RETURN 'ERROR: El estudiante no está inscrito en este curso';
  END IF;
  
  -- Verificar fecha actual
  v_fecha_actual := SYSTIMESTAMP;
  
  IF v_fecha_actual < v_fecha_disponible THEN
    RETURN 'ERROR: El examen aún no está disponible. Disponible desde: ' || TO_CHAR(v_fecha_disponible, 'DD-MM-YYYY HH24:MI');
  END IF;
  
  IF v_fecha_actual > v_fecha_limite THEN
    RETURN 'ERROR: El período para realizar el examen ha terminado. Fecha límite: ' || TO_CHAR(v_fecha_limite, 'DD-MM-YYYY HH24:MI');
  END IF;
  
  -- Verificar intentos previos
  SELECT COUNT(*)
  INTO v_intentos_realizados
  FROM Intentos_Examen
  WHERE estudiante_id = p_estudiante_id AND examen_id = p_examen_id;
  
  -- Múltiples intentos podrían ser controlados con otra tabla de configuración
  
  RETURN 'ELEGIBLE';
END;
/

-- Trigger para validar tiempo durante el examen
CREATE OR REPLACE TRIGGER trg_validar_tiempo_examen
BEFORE INSERT ON Respuestas_Estudiantes
FOR EACH ROW
DECLARE
  v_fecha_inicio TIMESTAMP;
  v_tiempo_limite NUMBER;
  v_tiempo_actual NUMBER;
  v_examen_id NUMBER;
BEGIN
  -- Obtener detalles del intento actual
  SELECT ie.fecha_inicio, e.tiempo_limite, ie.examen_id
  INTO v_fecha_inicio, v_tiempo_limite, v_examen_id
  FROM Intentos_Examen ie
  JOIN Examenes e ON ie.examen_id = e.examen_id
  WHERE ie.intento_examen_id = :NEW.intento_examen_id;
  
  -- Calcular tiempo transcurrido en minutos
  v_tiempo_actual := (EXTRACT(DAY FROM (SYSTIMESTAMP - v_fecha_inicio)) * 24 * 60) +
                     (EXTRACT(HOUR FROM (SYSTIMESTAMP - v_fecha_inicio)) * 60) +
                     EXTRACT(MINUTE FROM (SYSTIMESTAMP - v_fecha_inicio));
  
  -- Verificar si excede el tiempo límite
  IF v_tiempo_actual > v_tiempo_limite THEN
    RAISE_APPLICATION_ERROR(-20001, 'Se ha excedido el tiempo límite para este examen');
  END IF;
END;
/

-- Procedimiento para calificar examen
CREATE OR REPLACE PROCEDURE sp_calificar_examen(
  p_intento_examen_id IN NUMBER
) AS
  v_examen_id NUMBER;
  v_total_peso NUMBER := 0;
  v_puntaje_obtenido NUMBER := 0;
  v_puntaje_final NUMBER;
BEGIN
  -- Obtener el examen
  SELECT examen_id INTO v_examen_id
  FROM Intentos_Examen
  WHERE intento_examen_id = p_intento_examen_id;
  
  -- Calcular el peso total de las preguntas
  SELECT SUM(pe.peso)
  INTO v_total_peso
  FROM Preguntas_Examenes pe
  WHERE pe.examen_id = v_examen_id;
  
  -- Calcular puntaje obtenido
  SELECT COALESCE(SUM(re.puntaje_obtenido), 0)
  INTO v_puntaje_obtenido
  FROM Respuestas_Estudiantes re
  JOIN Preguntas_Examenes pe ON re.pregunta_examen_id = pe.pregunta_examen_id
  WHERE re.intento_examen_id = p_intento_examen_id;
  
  -- Calcular puntaje final (regla de tres)
  IF v_total_peso > 0 THEN
    -- Si el peso total es mayor a 100, normalizar
    IF v_total_peso > 100 THEN
      v_puntaje_final := (v_puntaje_obtenido / v_total_peso) * 100;
    ELSE
      v_puntaje_final := v_puntaje_obtenido;
    END IF;
  ELSE
    v_puntaje_final := 0;
  END IF;
  
  -- Actualizar el intento del examen
  UPDATE Intentos_Examen
  SET puntaje_total = v_puntaje_final,
      fecha_fin = SYSTIMESTAMP
  WHERE intento_examen_id = p_intento_examen_id;
  
  COMMIT;
END;
/

-- Procedimiento para verificar si la entrega está dentro del tiempo límite
CREATE OR REPLACE PROCEDURE sp_verificar_tiempo_entrega(
    p_intento_id IN NUMBER,
    p_resultado OUT VARCHAR2
) AS
    v_fecha_inicio TIMESTAMP;
    v_fecha_fin TIMESTAMP;
    v_tiempo_limite NUMBER;
    v_examen_id NUMBER;
BEGIN
    -- Obtener datos del intento
    SELECT ie.fecha_inicio, SYSTIMESTAMP, e.tiempo_limite, ie.examen_id
    INTO v_fecha_inicio, v_fecha_fin, v_tiempo_limite, v_examen_id
    FROM Intentos_Examen ie
    JOIN Examenes e ON ie.examen_id = e.examen_id
    WHERE ie.intento_examen_id = p_intento_id;
    
    -- Calcular tiempo transcurrido en minutos
    IF (EXTRACT(DAY FROM (v_fecha_fin - v_fecha_inicio)) * 24 * 60 +
        EXTRACT(HOUR FROM (v_fecha_fin - v_fecha_inicio)) * 60 +
        EXTRACT(MINUTE FROM (v_fecha_fin - v_fecha_inicio))) > v_tiempo_limite THEN
        
        p_resultado := 'ERROR: Tiempo de entrega excedido';
    ELSE
        p_resultado := 'EXITO: Entrega dentro del tiempo permitido';
    END IF;
END;
/

-- Función para calificar preguntas de opción única
CREATE OR REPLACE FUNCTION fn_calificar_opcion_unica(
    p_respuesta_estudiante_id IN NUMBER
) RETURN NUMBER AS
    v_es_correcta CHAR(1);
    v_peso NUMBER;
    v_pregunta_examen_id NUMBER;
BEGIN
    -- Obtener la pregunta y verificar respuestas
    SELECT pe.peso, pe.pregunta_examen_id
    INTO v_peso, v_pregunta_examen_id
    FROM Respuestas_Estudiantes re
    JOIN Preguntas_Examenes pe ON re.pregunta_examen_id = pe.pregunta_examen_id
    WHERE re.respuesta_estudiante_id = p_respuesta_estudiante_id;
    
    -- Verificar si la respuesta es correcta
    -- Compara opciones marcadas con opciones correctas
    SELECT 
        CASE 
            WHEN COUNT(DISTINCT ro.opcion_pregunta_id) = 
                 (SELECT COUNT(*) FROM Opciones_Preguntas op 
                  WHERE op.pregunta_id = pe.pregunta_id 
                  AND op.es_correcta = 'S')
            THEN 'S'
            ELSE 'N'
        END
    INTO v_es_correcta
    FROM Respuestas_Estudiantes re
    JOIN Preguntas_Examenes pe ON re.pregunta_examen_id = pe.pregunta_examen_id
    JOIN Respuestas_Opciones ro ON re.respuesta_estudiante_id = ro.respuesta_estudiante_id
    JOIN Opciones_Preguntas op ON ro.opcion_pregunta_id = op.opcion_pregunta_id
    WHERE re.respuesta_estudiante_id = p_respuesta_estudiante_id
    AND op.es_correcta = 'S';
    
    -- Actualizar el estado de la respuesta
    UPDATE Respuestas_Estudiantes
    SET es_correcta = v_es_correcta,
        puntaje_obtenido = CASE WHEN v_es_correcta = 'S' THEN v_peso ELSE 0 END
    WHERE respuesta_estudiante_id = p_respuesta_estudiante_id;
    
    -- Retornar el puntaje
    IF v_es_correcta = 'S' THEN
        RETURN v_peso;
    ELSE
        RETURN 0;
    END IF;
END;
/

-- Función para calificar preguntas de opción múltiple
CREATE OR REPLACE FUNCTION fn_calificar_opcion_multiple(
    p_respuesta_estudiante_id IN NUMBER
) RETURN NUMBER AS
    v_es_correcta CHAR(1) := 'S';
    v_peso NUMBER;
    v_pregunta_examen_id NUMBER;
    v_correctas_marcadas NUMBER := 0;
    v_correctas_totales NUMBER := 0;
    v_incorrectas_marcadas NUMBER := 0;
BEGIN
    -- Obtener la pregunta y el peso
    SELECT pe.peso, pe.pregunta_examen_id
    INTO v_peso, v_pregunta_examen_id
    FROM Respuestas_Estudiantes re
    JOIN Preguntas_Examenes pe ON re.pregunta_examen_id = pe.pregunta_examen_id
    WHERE re.respuesta_estudiante_id = p_respuesta_estudiante_id;
    
    -- Contar opciones correctas marcadas
    SELECT COUNT(*)
    INTO v_correctas_marcadas
    FROM Respuestas_Opciones ro
    JOIN Opciones_Preguntas op ON ro.opcion_pregunta_id = op.opcion_pregunta_id
    WHERE ro.respuesta_estudiante_id = p_respuesta_estudiante_id
    AND op.es_correcta = 'S';
    
    -- Contar total de opciones correctas
    SELECT COUNT(*)
    INTO v_correctas_totales
    FROM Opciones_Preguntas op
    JOIN Preguntas_Examenes pe ON op.pregunta_id = pe.pregunta_id
    WHERE pe.pregunta_examen_id = v_pregunta_examen_id
    AND op.es_correcta = 'S';
    
    -- Contar opciones incorrectas marcadas
    SELECT COUNT(*)
    INTO v_incorrectas_marcadas
    FROM Respuestas_Opciones ro
    JOIN Opciones_Preguntas op ON ro.opcion_pregunta_id = op.opcion_pregunta_id
    WHERE ro.respuesta_estudiante_id = p_respuesta_estudiante_id
    AND op.es_correcta = 'N';
    
    -- Verificar si todas las correctas están marcadas y ninguna incorrecta
    IF v_correctas_marcadas = v_correctas_totales AND v_incorrectas_marcadas = 0 THEN
        v_es_correcta := 'S';
    ELSE
        v_es_correcta := 'N';
    END IF;
    
    -- Actualizar estado de la respuesta
    UPDATE Respuestas_Estudiantes
    SET es_correcta = v_es_correcta,
        puntaje_obtenido = CASE WHEN v_es_correcta = 'S' THEN v_peso ELSE 0 END
    WHERE respuesta_estudiante_id = p_respuesta_estudiante_id;
    
    -- Retornar puntaje
    IF v_es_correcta = 'S' THEN
        RETURN v_peso;
    ELSE
        RETURN 0;
    END IF;
END;
/

-- Función para calificar preguntas de verdadero/falso
CREATE OR REPLACE FUNCTION fn_calificar_verdadero_falso(
    p_respuesta_estudiante_id IN NUMBER
) RETURN NUMBER AS
    v_es_correcta CHAR(1);
    v_peso NUMBER;
    v_pregunta_examen_id NUMBER;
BEGIN
    -- Obtener la pregunta y su peso
    SELECT pe.peso, pe.pregunta_examen_id
    INTO v_peso, v_pregunta_examen_id
    FROM Respuestas_Estudiantes re
    JOIN Preguntas_Examenes pe ON re.pregunta_examen_id = pe.pregunta_examen_id
    WHERE re.respuesta_estudiante_id = p_respuesta_estudiante_id;
    
    -- Verificar si la respuesta es correcta
    -- Para V/F solo hay una opción correcta (similar a opción única)
    SELECT 
        CASE 
            WHEN COUNT(ro.opcion_pregunta_id) = 1 AND
                 EXISTS (
                    SELECT 1 FROM Respuestas_Opciones ro2
                    JOIN Opciones_Preguntas op ON ro2.opcion_pregunta_id = op.opcion_pregunta_id
                    WHERE ro2.respuesta_estudiante_id = p_respuesta_estudiante_id
                    AND op.es_correcta = 'S'
                 )
            THEN 'S'
            ELSE 'N'
        END
    INTO v_es_correcta
    FROM Respuestas_Opciones ro
    WHERE ro.respuesta_estudiante_id = p_respuesta_estudiante_id;
    
    -- Actualizar el estado de la respuesta
    UPDATE Respuestas_Estudiantes
    SET es_correcta = v_es_correcta,
        puntaje_obtenido = CASE WHEN v_es_correcta = 'S' THEN v_peso ELSE 0 END
    WHERE respuesta_estudiante_id = p_respuesta_estudiante_id;
    
    -- Retornar el puntaje
    IF v_es_correcta = 'S' THEN
        RETURN v_peso;
    ELSE
        RETURN 0;
    END IF;
END;
/

-- Función para calificar preguntas de ordenamiento
CREATE OR REPLACE FUNCTION fn_calificar_ordenamiento(
    p_respuesta_estudiante_id IN NUMBER
) RETURN NUMBER AS
    v_es_correcta CHAR(1) := 'S';
    v_peso NUMBER;
    v_pregunta_examen_id NUMBER;
    v_errores NUMBER := 0;
BEGIN
    -- Obtener la pregunta y su peso
    SELECT pe.peso, pe.pregunta_examen_id
    INTO v_peso, v_pregunta_examen_id
    FROM Respuestas_Estudiantes re
    JOIN Preguntas_Examenes pe ON re.pregunta_examen_id = pe.pregunta_examen_id
    WHERE re.respuesta_estudiante_id = p_respuesta_estudiante_id;
    
    -- Contar cuántas posiciones son incorrectas
    SELECT COUNT(*)
    INTO v_errores
    FROM Respuestas_Orden ro
    JOIN Orden_Preguntas op ON ro.orden_pregunta_id = op.orden_pregunta_id
    WHERE ro.respuesta_estudiante_id = p_respuesta_estudiante_id
    AND ro.posicion_estudiante != op.posicion_correcta;
    
    -- Si hay algún error, la respuesta es incorrecta
    IF v_errores > 0 THEN
        v_es_correcta := 'N';
    END IF;
    
    -- Actualizar el estado de la respuesta
    UPDATE Respuestas_Estudiantes
    SET es_correcta = v_es_correcta,
        puntaje_obtenido = CASE WHEN v_es_correcta = 'S' THEN v_peso ELSE 0 END
    WHERE respuesta_estudiante_id = p_respuesta_estudiante_id;
    
    -- Retornar el puntaje
    IF v_es_correcta = 'S' THEN
        RETURN v_peso;
    ELSE
        RETURN 0;
    END IF;
END;
/

-- Función para calificar preguntas de emparejamiento
CREATE OR REPLACE FUNCTION fn_calificar_emparejamiento(
    p_respuesta_estudiante_id IN NUMBER
) RETURN NUMBER AS
    v_es_correcta CHAR(1) := 'S';
    v_peso NUMBER;
    v_pregunta_examen_id NUMBER;
    v_errores NUMBER := 0;
BEGIN
    -- Obtener la pregunta y su peso
    SELECT pe.peso, pe.pregunta_examen_id
    INTO v_peso, v_pregunta_examen_id
    FROM Respuestas_Estudiantes re
    JOIN Preguntas_Examenes pe ON re.pregunta_examen_id = pe.pregunta_examen_id
    WHERE re.respuesta_estudiante_id = p_respuesta_estudiante_id;
    
    -- Contar emparejamientos incorrectos
    SELECT COUNT(*)
    INTO v_errores
    FROM Respuestas_Emparejamiento re
    JOIN Emparejamiento_Preguntas ep ON re.emparejamiento_pregunta_id = ep.emparejamiento_pregunta_id
    WHERE re.respuesta_estudiante_id = p_respuesta_estudiante_id
    AND (re.opcion_a != ep.opcion_a OR re.opcion_b != ep.opcion_b);
    
    -- Si hay algún error, la respuesta es incorrecta
    IF v_errores > 0 THEN
        v_es_correcta := 'N';
    END IF;
    
    -- Actualizar el estado de la respuesta
    UPDATE Respuestas_Estudiantes
    SET es_correcta = v_es_correcta,
        puntaje_obtenido = CASE WHEN v_es_correcta = 'S' THEN v_peso ELSE 0 END
    WHERE respuesta_estudiante_id = p_respuesta_estudiante_id;
    
    -- Retornar el puntaje
    IF v_es_correcta = 'S' THEN
        RETURN v_peso;
    ELSE
        RETURN 0;
    END IF;
END;
/

-- Función para calificar preguntas de completar
CREATE OR REPLACE FUNCTION fn_calificar_completar(
    p_respuesta_estudiante_id IN NUMBER
) RETURN NUMBER AS
    v_es_correcta CHAR(1) := 'N';
    v_peso NUMBER;
    v_pregunta_examen_id NUMBER;
    v_texto_respuesta CLOB;
    v_texto_esperado CLOB;
BEGIN
    -- Obtener la pregunta y su peso
    SELECT pe.peso, pe.pregunta_examen_id
    INTO v_peso, v_pregunta_examen_id
    FROM Respuestas_Estudiantes re
    JOIN Preguntas_Examenes pe ON re.pregunta_examen_id = pe.pregunta_examen_id
    WHERE re.respuesta_estudiante_id = p_respuesta_estudiante_id;
    
    -- Para preguntas de completar, podríamos tener respuestas en texto libre 
    -- almacenadas en una tabla específica, pero para simplificar usaremos
    -- la tabla de respuestas de orden para almacenar el texto
    SELECT ro.texto
    INTO v_texto_respuesta
    FROM Respuestas_Orden ro
    WHERE ro.respuesta_estudiante_id = p_respuesta_estudiante_id
    AND ro.posicion_estudiante = 1; -- Asumimos que usamos la primera posición
    
    -- Obtener el texto esperado (podría estar en Opciones_Preguntas o en otra tabla)
    -- Asumimos que está en la primera opción marcada como correcta
    SELECT op.texto
    INTO v_texto_esperado
    FROM Opciones_Preguntas op
    JOIN Preguntas_Examenes pe ON op.pregunta_id = pe.pregunta_id
    WHERE pe.pregunta_examen_id = v_pregunta_examen_id
    AND op.es_correcta = 'S'
    AND ROWNUM = 1;
    
    -- Comparar ignorando espacios y mayúsculas/minúsculas
    IF UPPER(TRIM(v_texto_respuesta)) = UPPER(TRIM(v_texto_esperado)) THEN
        v_es_correcta := 'S';
    END IF;
    
    -- Actualizar el estado de la respuesta
    UPDATE Respuestas_Estudiantes
    SET es_correcta = v_es_correcta,
        puntaje_obtenido = CASE WHEN v_es_correcta = 'S' THEN v_peso ELSE 0 END
    WHERE respuesta_estudiante_id = p_respuesta_estudiante_id;
    
    -- Retornar el puntaje
    IF v_es_correcta = 'S' THEN
        RETURN v_peso;
    ELSE
        RETURN 0;
    END IF;
END;
/

-- Procedimiento para calificar un examen completo
CREATE OR REPLACE PROCEDURE sp_calificar_examen_completo(
    p_intento_id IN NUMBER
) AS
    v_total_puntos NUMBER := 0;
    v_puntos_posibles NUMBER := 0;
    v_puntaje_final NUMBER;
    v_examen_id NUMBER;
    v_total_preguntas NUMBER := 0;
    v_preguntas_respondidas NUMBER := 0;
    v_next_id NUMBER;
    v_es_subpregunta BOOLEAN;
    v_pregunta_padre_id NUMBER;
BEGIN
    -- Obtener el ID del examen
    SELECT examen_id 
    INTO v_examen_id
    FROM Intentos_Examen
    WHERE intento_examen_id = p_intento_id;
    
    -- Obtener número total de preguntas en el examen
    SELECT COUNT(*)
    INTO v_total_preguntas
    FROM Preguntas_Examenes
    WHERE examen_id = v_examen_id;
    
    -- Obtener número de preguntas respondidas
    SELECT COUNT(DISTINCT pe.pregunta_examen_id)
    INTO v_preguntas_respondidas
    FROM Respuestas_Estudiantes re
    JOIN Preguntas_Examenes pe ON re.pregunta_examen_id = pe.pregunta_examen_id
    WHERE re.intento_examen_id = p_intento_id;
    
    -- Calificar cada respuesta según el tipo de pregunta
    FOR respuesta IN (
        SELECT 
            re.respuesta_estudiante_id,
            p.tipo_pregunta_id,
            p.pregunta_id,
            p.pregunta_padre_id,
            pe.pregunta_examen_id
        FROM Respuestas_Estudiantes re
        JOIN Preguntas_Examenes pe ON re.pregunta_examen_id = pe.pregunta_examen_id
        JOIN Preguntas p ON pe.pregunta_id = p.pregunta_id
        WHERE re.intento_examen_id = p_intento_id
        ORDER BY pe.orden -- Ordenar para procesar preguntas en el orden correcto
    ) LOOP
        -- Verificar si es una subpregunta
        v_es_subpregunta := (respuesta.pregunta_padre_id IS NOT NULL);
        
        -- Calificar según el tipo de pregunta (independientemente si es subpregunta)
        IF respuesta.tipo_pregunta_id = 1 THEN -- Opción múltiple
            v_total_puntos := v_total_puntos + fn_calificar_opcion_multiple(respuesta.respuesta_estudiante_id);
        ELSIF respuesta.tipo_pregunta_id = 2 THEN -- Opción única
            v_total_puntos := v_total_puntos + fn_calificar_opcion_unica(respuesta.respuesta_estudiante_id);
        ELSIF respuesta.tipo_pregunta_id = 3 THEN -- Verdadero/Falso
            v_total_puntos := v_total_puntos + fn_calificar_verdadero_falso(respuesta.respuesta_estudiante_id);
        ELSIF respuesta.tipo_pregunta_id = 4 THEN -- Ordenamiento
            v_total_puntos := v_total_puntos + fn_calificar_ordenamiento(respuesta.respuesta_estudiante_id);
        ELSIF respuesta.tipo_pregunta_id = 5 THEN -- Emparejamiento
            v_total_puntos := v_total_puntos + fn_calificar_emparejamiento(respuesta.respuesta_estudiante_id);
        ELSIF respuesta.tipo_pregunta_id = 6 THEN -- Completar
            v_total_puntos := v_total_puntos + fn_calificar_completar(respuesta.respuesta_estudiante_id);
        END IF;
    END LOOP;
    
    -- Insertar respuestas en blanco para preguntas no contestadas
    FOR pregunta_sin_respuesta IN (
        SELECT 
            pe.pregunta_examen_id, 
            pe.peso, 
            p.tipo_pregunta_id,
            p.pregunta_padre_id
        FROM Preguntas_Examenes pe
        JOIN Preguntas p ON pe.pregunta_id = p.pregunta_id
        WHERE pe.examen_id = v_examen_id
        AND NOT EXISTS (
            SELECT 1
            FROM Respuestas_Estudiantes re
            WHERE re.pregunta_examen_id = pe.pregunta_examen_id
            AND re.intento_examen_id = p_intento_id
        )
    ) LOOP
        -- Obtener el siguiente ID para respuestas
        SELECT NVL(MAX(respuesta_estudiante_id), 0) + 1
        INTO v_next_id
        FROM Respuestas_Estudiantes;
        
        -- Insertar una respuesta vacía para poder calificarla con cero
        INSERT INTO Respuestas_Estudiantes (
            respuesta_estudiante_id,
            intento_examen_id,
            pregunta_examen_id,
            es_correcta,
            puntaje_obtenido
        ) VALUES (
            v_next_id,
            p_intento_id,
            pregunta_sin_respuesta.pregunta_examen_id,
            'N',
            0
        );
    END LOOP;
    
    -- Calcular total de puntos posibles (ahora incluye todas las preguntas)
    SELECT SUM(pe.peso)
    INTO v_puntos_posibles
    FROM Preguntas_Examenes pe
    WHERE pe.examen_id = v_examen_id;
    
    -- Calcular puntaje final (regla de tres)
    IF v_puntos_posibles > 0 THEN
        v_puntaje_final := (v_total_puntos / v_puntos_posibles) * 100;
    ELSE
        v_puntaje_final := 0;
    END IF;
    
    -- Actualizar intento con el puntaje final
    UPDATE Intentos_Examen
    SET puntaje_total = v_puntaje_final,
        fecha_fin = SYSTIMESTAMP,
        tiempo_utilizado = EXTRACT(DAY FROM (SYSTIMESTAMP - fecha_inicio)) * 24 * 60 +
                          EXTRACT(HOUR FROM (SYSTIMESTAMP - fecha_inicio)) * 60 +
                          EXTRACT(MINUTE FROM (SYSTIMESTAMP - fecha_inicio))
    WHERE intento_examen_id = p_intento_id;
    
    COMMIT;
END;
/

-- Función auxiliar para calificar preguntas compuestas
CREATE OR REPLACE FUNCTION fn_calcular_puntaje_compuesto(
    p_pregunta_id IN NUMBER,
    p_intento_id IN NUMBER
) RETURN NUMBER AS
    v_puntaje_padre NUMBER := 0;
    v_puntaje_subpreguntas NUMBER := 0;
    v_total_subpreguntas NUMBER := 0;
    v_subpreguntas_correctas NUMBER := 0;
    v_peso_pregunta_padre NUMBER;
    v_pregunta_examen_id NUMBER;
BEGIN
    -- Obtener el peso y ID de la pregunta compuesta
    SELECT pe.peso, pe.pregunta_examen_id
    INTO v_peso_pregunta_padre, v_pregunta_examen_id
    FROM Preguntas_Examenes pe
    WHERE pe.pregunta_id = p_pregunta_id
    AND pe.examen_id = (SELECT examen_id FROM Intentos_Examen WHERE intento_examen_id = p_intento_id);
    
    -- Contar subpreguntas y cuántas están correctas
    SELECT COUNT(*), SUM(CASE WHEN re.es_correcta = 'S' THEN 1 ELSE 0 END)
    INTO v_total_subpreguntas, v_subpreguntas_correctas
    FROM Preguntas p
    JOIN Preguntas_Examenes pe ON p.pregunta_id = pe.pregunta_id
    LEFT JOIN Respuestas_Estudiantes re ON pe.pregunta_examen_id = re.pregunta_examen_id AND re.intento_examen_id = p_intento_id
    WHERE p.pregunta_padre_id = p_pregunta_id;
    
    -- Si no hay subpreguntas, retornar 0 (no debería ocurrir)
    IF v_total_subpreguntas = 0 THEN
        RETURN 0;
    END IF;
    
    -- Calcular puntaje proporcional basado en subpreguntas correctas
    v_puntaje_subpreguntas := (v_subpreguntas_correctas / v_total_subpreguntas) * v_peso_pregunta_padre * 0.5;
    
    -- Verificar si la pregunta padre fue respondida y si es correcta
    SELECT CASE WHEN es_correcta = 'S' THEN v_peso_pregunta_padre * 0.5 ELSE 0 END
    INTO v_puntaje_padre
    FROM Respuestas_Estudiantes
    WHERE pregunta_examen_id = v_pregunta_examen_id
    AND intento_examen_id = p_intento_id;
    
    -- Retornar la suma del puntaje de la pregunta padre y sus subpreguntas
    RETURN v_puntaje_padre + v_puntaje_subpreguntas;
END;
/
