/*==============================================================*/
/* PROCEDURES                                                    */
/*==============================================================*/

-- Procedimiento para agregar preguntas equilibradas
CREATE OR REPLACE PROCEDURE sp_agregar_preguntas_equilibradas(
  p_examen_id IN NUMBER,
  p_cantidad_preguntas IN NUMBER
) AS
  CURSOR c_temas IS
    SELECT DISTINCT t.tema_id, t.nombre, COUNT(p.pregunta_id) AS num_preguntas
    FROM Examenes e
    JOIN Grupos g ON e.grupo_id = g.grupo_id
    JOIN Cursos c ON g.curso_id = c.curso_id
    JOIN Unidades u ON c.curso_id = u.curso_id
    JOIN Unidades_Temas ut ON u.unidad_id = ut.unidad_id
    JOIN Temas t ON ut.tema_id = t.tema_id
    LEFT JOIN Preguntas p ON t.tema_id = p.tema_id AND p.es_publica = 'S'
    WHERE e.examen_id = p_examen_id
    GROUP BY t.tema_id, t.nombre;
    
  TYPE tema_rec IS RECORD (
    tema_id NUMBER,
    nombre VARCHAR2(50),
    num_preguntas NUMBER
  );
  
  TYPE tema_tab IS TABLE OF tema_rec INDEX BY PLS_INTEGER;
  v_temas tema_tab;
  
  v_total_temas NUMBER := 0;
  v_preguntas_por_tema NUMBER;
  v_siguiente_orden NUMBER;
  v_peso_por_pregunta NUMBER;
  v_preguntas_disponibles NUMBER := 0;
BEGIN
  -- Obtener el siguiente orden
  SELECT NVL(MAX(orden), 0) + 1
  INTO v_siguiente_orden
  FROM Preguntas_Examenes
  WHERE examen_id = p_examen_id;
  
  -- Cargar temas en array
  v_total_temas := 0;
  FOR tema_rec IN c_temas LOOP
    v_total_temas := v_total_temas + 1;
    v_temas(v_total_temas).tema_id := tema_rec.tema_id;
    v_temas(v_total_temas).nombre := tema_rec.nombre;
    v_temas(v_total_temas).num_preguntas := tema_rec.num_preguntas;
    -- Sumar preguntas disponibles
    v_preguntas_disponibles := v_preguntas_disponibles + tema_rec.num_preguntas;
  END LOOP;
  
  -- Si no hay temas, salir
  IF v_total_temas = 0 THEN
    RAISE_APPLICATION_ERROR(-20005, 'No hay temas disponibles para este examen');
    RETURN;
  END IF;
  
  -- Verificar si hay suficientes preguntas disponibles
  IF v_preguntas_disponibles < p_cantidad_preguntas THEN
    RAISE_APPLICATION_ERROR(-20008, 'No hay suficientes preguntas relacionadas con los temas del curso para este examen');
    RETURN;
  END IF;
  
  -- Calcular preguntas por tema
  v_preguntas_por_tema := CEIL(p_cantidad_preguntas / v_total_temas);
  
  -- Calcular peso por pregunta (distribución equitativa)
  v_peso_por_pregunta := 100 / p_cantidad_preguntas;
  
  -- Para cada tema, agregar preguntas aleatorias
  FOR i IN 1..v_total_temas LOOP
    -- Seleccionar preguntas del tema
    IF v_temas(i).num_preguntas > 0 THEN
      INSERT INTO Preguntas_Examenes (
        pregunta_examen_id,
        peso,
        orden,
        pregunta_id,
        examen_id
      )
      SELECT 
        SQ_PREGUNTA_EXAMEN_ID.NEXTVAL,
        v_peso_por_pregunta,
        v_siguiente_orden + ROWNUM - 1,
        pregunta_id,
        p_examen_id
      FROM (
        SELECT p.pregunta_id
        FROM Preguntas p
        WHERE p.tema_id = v_temas(i).tema_id
        AND p.es_publica = 'S'
        AND NOT EXISTS (
          SELECT 1 FROM Preguntas_Examenes pe
          WHERE pe.pregunta_id = p.pregunta_id
          AND pe.examen_id = p_examen_id
        )
        ORDER BY DBMS_RANDOM.VALUE
      )
      WHERE ROWNUM <= v_preguntas_por_tema;
      
      -- Actualizar orden para el siguiente tema
      v_siguiente_orden := v_siguiente_orden + v_preguntas_por_tema;
    END IF;
  END LOOP;
  
  COMMIT;
END;
/

-- Procedimiento para llenar examen con preguntas aleatorias
CREATE OR REPLACE PROCEDURE sp_llenar_examen_aleatorio(
    p_examen_id IN NUMBER,
    p_cantidad_preguntas IN NUMBER
) AS
    v_preguntas_disponibles NUMBER;
    v_siguiente_id NUMBER;
BEGIN
    -- Verificar si hay suficientes preguntas disponibles de los temas del curso
    SELECT COUNT(DISTINCT p.pregunta_id)
    INTO v_preguntas_disponibles
    FROM Examenes e
    JOIN Grupos g ON e.grupo_id = g.grupo_id
    JOIN Cursos c ON g.curso_id = c.curso_id
    JOIN Unidades u ON c.curso_id = u.curso_id
    JOIN Unidades_Temas ut ON u.unidad_id = ut.unidad_id
    JOIN Temas t ON ut.tema_id = t.tema_id
    JOIN Preguntas p ON t.tema_id = p.tema_id
    WHERE e.examen_id = p_examen_id
    AND p.es_publica = 'S'
    AND p.pregunta_id NOT IN (
        SELECT pregunta_id FROM Preguntas_Examenes
        WHERE examen_id = p_examen_id
    );
    
    IF v_preguntas_disponibles < p_cantidad_preguntas THEN
        RAISE_APPLICATION_ERROR(-20001, 'No hay suficientes preguntas relacionadas con los temas del curso para este examen');
        RETURN;
    END IF;
    
    -- Obtener el siguiente ID para pregunta_examen
    SELECT NVL(MAX(pregunta_examen_id), 0) + 1
    INTO v_siguiente_id
    FROM Preguntas_Examenes;
    
    -- Insertar preguntas aleatorias pero solo de los temas relacionados con el curso
    INSERT INTO Preguntas_Examenes (
        pregunta_examen_id,
        peso,
        orden,
        pregunta_id,
        examen_id
    )
    SELECT 
        v_siguiente_id + ROWNUM - 1,
        100 / p_cantidad_preguntas,  -- Distribuir peso equitativamente
        ROWNUM,
        pregunta_id,
        p_examen_id
    FROM (
        SELECT DISTINCT p.pregunta_id
        FROM Examenes e
        JOIN Grupos g ON e.grupo_id = g.grupo_id
        JOIN Cursos c ON g.curso_id = c.curso_id
        JOIN Unidades u ON c.curso_id = u.curso_id
        JOIN Unidades_Temas ut ON u.unidad_id = ut.unidad_id
        JOIN Temas t ON ut.tema_id = t.tema_id
        JOIN Preguntas p ON t.tema_id = p.tema_id
        WHERE e.examen_id = p_examen_id
        AND p.es_publica = 'S'
        AND p.pregunta_id NOT IN (
            SELECT pregunta_id FROM Preguntas_Examenes
            WHERE examen_id = p_examen_id
        )
        ORDER BY DBMS_RANDOM.VALUE
    )
    WHERE ROWNUM <= p_cantidad_preguntas;
    
    COMMIT;
END;
/

-- Procedimiento para actualizar preguntas compuestas
CREATE OR REPLACE PROCEDURE sp_actualizar_preguntas_compuestas(
    p_pregunta_principal_id IN NUMBER,
    p_cantidad_subpreguntas IN NUMBER
) AS
BEGIN
    IF p_cantidad_subpreguntas > 0 THEN
        -- Seleccionar subpreguntas del mismo tema
        UPDATE Preguntas
        SET pregunta_padre_id = p_pregunta_principal_id
        WHERE tema_id = (SELECT tema_id FROM Preguntas WHERE pregunta_id = p_pregunta_principal_id)
        AND pregunta_id <> p_pregunta_principal_id
        AND pregunta_padre_id IS NULL
        AND ROWNUM <= p_cantidad_subpreguntas;
        
        COMMIT;
    END IF;
END;
/

-- Procedimiento para validar y completar examen
CREATE OR REPLACE PROCEDURE sp_validar_completar_examen(
    p_examen_id IN NUMBER
) AS
    v_total_preguntas NUMBER;
    v_cantidad_esperada NUMBER;
    v_suma_pesos NUMBER;
    v_faltantes NUMBER;
BEGIN
    -- Obtener cantidad esperada de preguntas
    SELECT NVL(cantidad_preguntas_mostrar, 0)
    INTO v_cantidad_esperada
    FROM Examenes
    WHERE examen_id = p_examen_id;
    
    -- Si no hay una cantidad definida, no es necesario completar
    IF v_cantidad_esperada = 0 THEN
        RETURN;
    END IF;
    
    -- Contar preguntas actuales y sumar pesos
    SELECT COUNT(*), NVL(SUM(peso), 0)
    INTO v_total_preguntas, v_suma_pesos
    FROM Preguntas_Examenes
    WHERE examen_id = p_examen_id;
    
    -- Verificar si faltan preguntas
    IF v_total_preguntas < v_cantidad_esperada THEN
        v_faltantes := v_cantidad_esperada - v_total_preguntas;
        
        -- Completar con preguntas aleatorias
        sp_llenar_examen_aleatorio(p_examen_id, v_faltantes);
        
        -- Actualizar conteo después de agregar preguntas
        SELECT COUNT(*)
        INTO v_total_preguntas
        FROM Preguntas_Examenes
        WHERE examen_id = p_examen_id;
    END IF;
    
    -- Validar y ajustar pesos para que sumen 100%
    IF v_suma_pesos != 100 AND v_total_preguntas > 0 THEN
        -- Distribuir pesos equitativamente
        UPDATE Preguntas_Examenes
        SET peso = 100 / v_total_preguntas
        WHERE examen_id = p_examen_id;
    END IF;
    
    COMMIT;
    
    -- Verificación final
    SELECT COUNT(*), SUM(peso)
    INTO v_total_preguntas, v_suma_pesos
    FROM Preguntas_Examenes
    WHERE examen_id = p_examen_id;
    
    -- Registrar resultado en log
    DBMS_OUTPUT.PUT_LINE('Examen ' || p_examen_id || ' validado: ' || 
                         v_total_preguntas || ' preguntas, ' || 
                         'peso total: ' || v_suma_pesos || '%');
END;
/

-- Procedimiento para rebalancear pesos de preguntas
CREATE OR REPLACE PROCEDURE sp_rebalancear_pesos_examen(
    p_examen_id IN NUMBER
) AS
    v_total_preguntas NUMBER;
BEGIN
    -- Contar preguntas en el examen
    SELECT COUNT(*)
    INTO v_total_preguntas
    FROM Preguntas_Examenes
    WHERE examen_id = p_examen_id;
    
    -- Si hay preguntas, distribuir pesos equitativamente
    IF v_total_preguntas > 0 THEN
        UPDATE Preguntas_Examenes
        SET peso = 100 / v_total_preguntas
        WHERE examen_id = p_examen_id;
        
        COMMIT;
    END IF;
END;
/

-- Verificar tiempo de entrega
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

-- Calificar examen completo
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

-- Procedimiento para crear una pregunta nueva
CREATE OR REPLACE PROCEDURE sp_crear_pregunta(
    p_creador_id IN NUMBER,
    p_texto IN CLOB,
    p_tipo_pregunta_id IN NUMBER,
    p_tema_id IN NUMBER,
    p_es_publica IN CHAR DEFAULT 'N',
    p_tiempo_maximo IN NUMBER DEFAULT NULL,
    p_pregunta_padre_id IN NUMBER DEFAULT NULL,
    p_pregunta_id OUT NUMBER
) AS
    v_es_profesor NUMBER;
BEGIN
    -- Validar que el usuario sea profesor
    SELECT COUNT(*) INTO v_es_profesor
    FROM Usuarios u
    WHERE u.usuario_id = p_creador_id
    AND u.tipo_usuario_id = (SELECT usuario_id FROM Tipo_Usuario WHERE descripcion = 'PROFESOR');
    
    IF v_es_profesor = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Solo los profesores pueden crear preguntas');
    END IF;
    
    -- Generar ID para la nueva pregunta
    SELECT NVL(MAX(pregunta_id), 0) + 1 INTO p_pregunta_id FROM Preguntas;
    
    -- Insertar la pregunta
    INSERT INTO Preguntas (
        pregunta_id, texto, fecha_creacion, es_publica, 
        tiempo_maximo, pregunta_padre_id, tipo_pregunta_id, 
        creador_id, tema_id
    ) VALUES (
        p_pregunta_id, p_texto, SYSTIMESTAMP, p_es_publica,
        p_tiempo_maximo, p_pregunta_padre_id, p_tipo_pregunta_id,
        p_creador_id, p_tema_id
    );
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END sp_crear_pregunta;
/

-- Procedimiento para agregar opciones a preguntas de selección
CREATE OR REPLACE PROCEDURE sp_agregar_opcion_pregunta(
    p_pregunta_id IN NUMBER,
    p_texto IN CLOB,
    p_es_correcta IN CHAR,
    p_orden IN NUMBER DEFAULT NULL,
    p_opcion_id OUT NUMBER
) AS
    v_tipo_pregunta NUMBER;
BEGIN
    -- Verificar que la pregunta sea de tipo opción múltiple o única
    SELECT tipo_pregunta_id INTO v_tipo_pregunta 
    FROM Preguntas
    WHERE pregunta_id = p_pregunta_id;
    
    IF v_tipo_pregunta NOT IN (1, 2) THEN -- Asumiendo que 1=opción múltiple, 2=opción única
        RAISE_APPLICATION_ERROR(-20002, 'Esta función solo aplica a preguntas de selección');
    END IF;
    
    -- Generar ID para la nueva opción
    SELECT NVL(MAX(opcion_pregunta_id), 0) + 1 INTO p_opcion_id FROM Opciones_Preguntas;
    
    -- Insertar la opción
    INSERT INTO Opciones_Preguntas (
        opcion_pregunta_id, texto, es_correcta, orden, pregunta_id
    ) VALUES (
        p_opcion_id, p_texto, p_es_correcta, p_orden, p_pregunta_id
    );
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END sp_agregar_opcion_pregunta;
/

-- Procedimiento para agregar una pregunta existente a un examen
CREATE OR REPLACE PROCEDURE sp_agregar_pregunta_examen(
    p_profesor_id IN NUMBER,
    p_pregunta_id IN NUMBER,
    p_examen_id IN NUMBER,
    p_peso IN NUMBER DEFAULT NULL,
    p_orden IN NUMBER DEFAULT NULL
) AS
    v_es_profesor_curso NUMBER;
    v_max_orden NUMBER;
    v_peso_default NUMBER;
    v_pregunta_examen_id NUMBER;
BEGIN
    -- Verificar que el profesor pertenezca al curso del examen
    SELECT COUNT(*) INTO v_es_profesor_curso
    FROM Examenes e
    JOIN Grupos g ON e.grupo_id = g.grupo_id
    WHERE e.examen_id = p_examen_id
    AND g.profesor_id = p_profesor_id;
    
    IF v_es_profesor_curso = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'El profesor no está asignado al curso de este examen');
    END IF;
    
    -- Obtener el siguiente orden si no se especifica
    IF p_orden IS NULL THEN
        SELECT NVL(MAX(orden), 0) + 1 INTO v_max_orden
        FROM Preguntas_Examenes
        WHERE examen_id = p_examen_id;
    ELSE
        v_max_orden := p_orden;
    END IF;
    
    -- Calcular peso por defecto si no se especifica
    IF p_peso IS NULL THEN
        SELECT 100 / NULLIF(COUNT(*) + 1, 0) INTO v_peso_default
        FROM Preguntas_Examenes
        WHERE examen_id = p_examen_id;
    ELSE
        v_peso_default := p_peso;
    END IF;
    
    -- Generar ID para la nueva relación pregunta-examen
    SELECT NVL(MAX(pregunta_examen_id), 0) + 1 INTO v_pregunta_examen_id 
    FROM Preguntas_Examenes;
    
    -- Insertar la relación pregunta-examen
    INSERT INTO Preguntas_Examenes (
        pregunta_examen_id, peso, orden, pregunta_id, examen_id
    ) VALUES (
        v_pregunta_examen_id, v_peso_default, v_max_orden, p_pregunta_id, p_examen_id
    );
    
    -- Ajustar pesos si es necesario
    UPDATE Preguntas_Examenes
    SET peso = (
        SELECT 100 / COUNT(*) 
        FROM Preguntas_Examenes 
        WHERE examen_id = p_examen_id
    )
    WHERE examen_id = p_examen_id
    AND peso IS NULL;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END sp_agregar_pregunta_examen;

/

create or replace PROCEDURE sp_presentar_examen_estudiante (
    p_estudiante_id     IN NUMBER,
    p_examen_id         IN NUMBER,
    p_respuestas        IN SYS_REFCURSOR, -- Cursor con las respuestas del estudiante
    p_resultado         OUT VARCHAR2
) IS
    v_elegibilidad     VARCHAR2(200);
    v_intento_id       NUMBER;
    v_fecha_inicio     TIMESTAMP := SYSTIMESTAMP;
    v_fecha_fin        TIMESTAMP;
    v_msg_tiempo       VARCHAR2(200);
    v_examen_valido    BOOLEAN := FALSE;
BEGIN
    -- 1. Validar elegibilidad
    v_elegibilidad := fn_verificar_elegibilidad(p_estudiante_id, p_examen_id);

    IF v_elegibilidad <> 'ELEGIBLE' THEN
        p_resultado := v_elegibilidad;
        RETURN;
    END IF;

    -- 2. Registrar intento del examen
    SELECT SQ_INTENTO_EXAMEN_ID.NEXTVAL INTO v_intento_id FROM DUAL;

    INSERT INTO Intentos_Examen (intento_examen_id, estudiante_id, examen_id, fecha_inicio)
    VALUES (v_intento_id, p_estudiante_id, p_examen_id, v_fecha_inicio);

    -- 3. Procesar respuestas desde el cursor
    LOOP
        DECLARE
            v_pregunta_examen_id NUMBER;
            v_tipo_pregunta_id   NUMBER;
            v_dato_respuesta     CLOB;
        BEGIN
            FETCH p_respuestas INTO v_pregunta_examen_id, v_tipo_pregunta_id, v_dato_respuesta;
            EXIT WHEN p_respuestas%NOTFOUND;

            -- Registrar respuesta del estudiante
            INSERT INTO Respuestas_Estudiantes (respuesta_estudiante_id, pregunta_examen_id, intento_examen_id)
            VALUES (SQ_RESPUESTA_ESTUDIANTE_ID.NEXTVAL, v_pregunta_examen_id, v_intento_id);

            -- Insertar detalles de la respuesta según tipo (simplificado)
            IF v_tipo_pregunta_id = 1 THEN -- OPCION_MULTIPLE
                NULL; -- Implementar según estructura de tabla
            ELSIF v_tipo_pregunta_id = 2 THEN -- OPCION_UNICA
                NULL;
            ELSIF v_tipo_pregunta_id = 3 THEN -- VERDADERO_FALSO
                NULL;
            ELSIF v_tipo_pregunta_id = 4 THEN -- ORDENAR
                NULL;
            ELSIF v_tipo_pregunta_id = 5 THEN -- EMPAREJAR
                NULL;
            ELSIF v_tipo_pregunta_id = 6 THEN -- COMPLETAR
                NULL;
            END IF;
        END;
    END LOOP;

    CLOSE p_respuestas;

    -- 4. Verificar tiempo de entrega
    sp_verificar_tiempo_entrega(v_intento_id, v_msg_tiempo);

    IF v_msg_tiempo LIKE 'ERROR%' THEN
        p_resultado := v_msg_tiempo;
        RETURN;
    END IF;

    -- 5. Calificar el examen completo
    sp_calificar_examen_completo(v_intento_id);

    -- 6. Notificar resultado al estudiante
    p_resultado := 'EXAMEN FINALIZADO Y CALIFICADO CORRECTAMENTE.';

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_resultado := 'ERROR DURANTE LA PRESENTACIÓN DEL EXAMEN: ' || SQLERRM;
END;

-- Cambiar visibilidad de pregunta
CREATE OR REPLACE PROCEDURE sp_cambiar_visibilidad_pregunta(
    p_pregunta_id IN NUMBER,
    p_es_publica IN CHAR,
    p_usuario_id IN NUMBER
) AS
    v_es_creador NUMBER;
    v_es_admin NUMBER;
    v_tiene_examenes NUMBER;
BEGIN
    -- Verificar si el usuario es el creador de la pregunta o un administrador
    SELECT COUNT(*) INTO v_es_creador
    FROM Preguntas
    WHERE pregunta_id = p_pregunta_id
    AND creador_id = p_usuario_id;
    
    SELECT COUNT(*) INTO v_es_admin
    FROM Usuarios
    WHERE usuario_id = p_usuario_id
    AND tipo_usuario_id = (SELECT tipo_usuario_id FROM Tipo_Usuario WHERE descripcion = 'ADMINISTRADOR');
    
    -- Verificar si la pregunta está siendo usada en algún examen
    SELECT COUNT(*) INTO v_tiene_examenes
    FROM Preguntas_Examenes pe
    JOIN Examenes e ON pe.examen_id = e.examen_id
    WHERE pe.pregunta_id = p_pregunta_id;
    
    -- Solo permitir cambios si es el creador o un administrador
    IF v_es_creador = 0 AND v_es_admin = 0 THEN
        RAISE_APPLICATION_ERROR(-20100, 'No tienes permisos para cambiar la visibilidad de esta pregunta');
    END IF;
    
    -- Si se quiere hacer privada una pregunta usada en exámenes, no permitirlo
    IF p_es_publica = 'N' AND v_tiene_examenes > 0 THEN
        RAISE_APPLICATION_ERROR(-20101, 'No se puede cambiar a privada una pregunta usada en exámenes');
    END IF;
    
    -- Actualizar la visibilidad
    UPDATE Preguntas
    SET es_publica = p_es_publica
    WHERE pregunta_id = p_pregunta_id;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
-- Procedimiento para configurar el número máximo de intentos de un examen
CREATE OR REPLACE PROCEDURE sp_configurar_intentos_examen(
    p_examen_id IN NUMBER,
    p_max_intentos IN NUMBER,
    p_profesor_id IN NUMBER
) AS
    v_es_profesor_curso NUMBER;
    v_tiene_intentos NUMBER;
BEGIN
    -- Verificar que el profesor pertenezca al curso del examen
    SELECT COUNT(*) INTO v_es_profesor_curso
    FROM Examenes e
    JOIN Grupos g ON e.grupo_id = g.grupo_id
    WHERE e.examen_id = p_examen_id
    AND g.profesor_id = p_profesor_id;
    
    IF v_es_profesor_curso = 0 THEN
        RAISE_APPLICATION_ERROR(-20200, 'El profesor no está asignado al curso de este examen');
    END IF;
    
    -- Verificar si el examen ya tiene intentos registrados
    SELECT COUNT(*) INTO v_tiene_intentos
    FROM Intentos_Examen
    WHERE examen_id = p_examen_id;
    
    -- Si ya hay intentos, no permitir reducir el máximo por debajo de los ya realizados
    IF v_tiene_intentos > 0 AND p_max_intentos < v_tiene_intentos THEN
        RAISE_APPLICATION_ERROR(-20201, 'No se puede reducir el número máximo de intentos por debajo de los ya realizados');
    END IF;
    
    -- Actualizar el número máximo de intentos
    UPDATE Examenes
    SET max_intentos = p_max_intentos
    WHERE examen_id = p_examen_id;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

-- Corrección del procedimiento para obtener retroalimentación detallada
CREATE OR REPLACE PROCEDURE sp_obtener_retroalimentacion_examen(
    p_intento_id IN NUMBER,
    p_retroalimentacion OUT SYS_REFCURSOR
) AS
BEGIN
    -- Abrir cursor con la retroalimentación de preguntas incorrectas
    OPEN p_retroalimentacion FOR
    SELECT 
        re.respuesta_estudiante_id,
        pe.orden,
        p.texto AS pregunta,
        tp.descripcion AS tipo_pregunta,
        -- Respuesta del estudiante (simplificada para evitar errores)
        CASE 
            WHEN p.tipo_pregunta_id IN (1, 2) THEN -- Opciones múltiple/única
                'Ver detalle de opciones seleccionadas'
            WHEN p.tipo_pregunta_id = 3 THEN -- Verdadero/Falso
                'Ver respuesta V/F'
            WHEN p.tipo_pregunta_id = 4 THEN -- Ordenamiento
                'Ver orden seleccionado'
            WHEN p.tipo_pregunta_id = 5 THEN -- Emparejamiento
                'Ver emparejamientos realizados'
            WHEN p.tipo_pregunta_id = 6 THEN -- Completar
                'Ver texto ingresado'
            ELSE
                'No disponible'
        END AS respuesta_estudiante,
        -- Descripción general de la respuesta correcta
        CASE 
            WHEN p.tipo_pregunta_id IN (1, 2) THEN 
                'Ver opciones correctas'
            WHEN p.tipo_pregunta_id = 3 THEN
                'Verdadero o Falso'
            WHEN p.tipo_pregunta_id = 4 THEN
                'Ver orden correcto'
            WHEN p.tipo_pregunta_id = 5 THEN
                'Ver emparejamientos correctos'
            WHEN p.tipo_pregunta_id = 6 THEN
                'Ver texto correcto'
            ELSE
                'No disponible'
        END AS respuesta_correcta,
        -- Convertir CLOB a VARCHAR2 para evitar errores de tipo
        DBMS_LOB.SUBSTR(p.retroalimentacion, 4000, 1) AS retroalimentacion,
        re.puntaje_obtenido,
        pe.peso AS puntaje_maximo
    FROM Respuestas_Estudiantes re
    JOIN Preguntas_Examenes pe ON re.pregunta_examen_id = pe.pregunta_examen_id
    JOIN Preguntas p ON pe.pregunta_id = p.pregunta_id
    JOIN Tipo_Preguntas tp ON p.tipo_pregunta_id = tp.tipo_pregunta_id
    WHERE re.intento_examen_id = p_intento_id
    AND re.es_correcta = 'N'
    ORDER BY pe.orden;
    
EXCEPTION
    WHEN OTHERS THEN
        IF p_retroalimentacion%ISOPEN THEN
            CLOSE p_retroalimentacion;
        END IF;
        RAISE;
END;
/

-- Procedimiento corregido para configurar retroalimentación de una pregunta
CREATE OR REPLACE PROCEDURE sp_configurar_retroalimentacion(
    p_pregunta_id IN NUMBER,
    p_retroalimentacion IN CLOB,
    p_usuario_id IN NUMBER
) AS
    v_es_creador NUMBER;
    v_es_admin NUMBER;
BEGIN
    -- Verificar si el usuario es el creador de la pregunta o un administrador
    SELECT COUNT(*) INTO v_es_creador
    FROM Preguntas
    WHERE pregunta_id = p_pregunta_id
    AND creador_id = p_usuario_id;
    
    SELECT COUNT(*) INTO v_es_admin
    FROM Usuarios
    WHERE usuario_id = p_usuario_id
    AND tipo_usuario_id = (SELECT tipo_usuario_id FROM Tipo_Usuario WHERE descripcion = 'ADMINISTRADOR');
    
    -- Solo permitir cambios si es el creador o un administrador
    IF v_es_creador = 0 AND v_es_admin = 0 THEN
        RAISE_APPLICATION_ERROR(-20300, 'No tienes permisos para modificar esta pregunta');
    END IF;
    
    -- Actualizar la retroalimentación (eliminada la columna fecha_modificacion)
    UPDATE Preguntas
    SET retroalimentacion = p_retroalimentacion
    WHERE pregunta_id = p_pregunta_id;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/