-- Script de pruebas para todos los triggers del sistema
SET SERVEROUTPUT ON;

-- ===============================================================
-- 1. Prueba para trg_validar_examen_creacion
-- ===============================================================
DECLARE
    v_examen_id NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Prueba 1: trg_validar_examen_creacion ===');
    
    -- Caso positivo: fechas válidas y profesor del grupo
    BEGIN
        INSERT INTO Examenes (
            examen_id, 
            descripcion, 
            fecha_creacion, 
            fecha_disponible, 
            fecha_limite, 
            tiempo_limite, 
            creador_id, 
            grupo_id
        ) VALUES (
            1001, 
            'Examen de prueba válido', 
            SYSTIMESTAMP, 
            SYSTIMESTAMP + INTERVAL '1' DAY, 
            SYSTIMESTAMP + INTERVAL '7' DAY, 
            60, 
            1, -- Profesor ID 1 
            1  -- Grupo ID 1 (el profesor 1 está asignado a este grupo)
        );
        
        DBMS_OUTPUT.PUT_LINE('Caso positivo: Examen creado correctamente');
        
        -- Limpiar datos de prueba
        DELETE FROM Examenes WHERE examen_id = 1001;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en caso positivo: ' || SQLERRM);
    END;
    
    -- Caso negativo: fecha límite anterior a fecha disponible
    BEGIN
        INSERT INTO Examenes (
            examen_id, 
            descripcion, 
            fecha_creacion, 
            fecha_disponible, 
            fecha_limite, 
            tiempo_limite, 
            creador_id, 
            grupo_id
        ) VALUES (
            1002, 
            'Examen con fechas inválidas', 
            SYSTIMESTAMP, 
            SYSTIMESTAMP + INTERVAL '7' DAY, 
            SYSTIMESTAMP + INTERVAL '1' DAY, -- Fecha límite antes que fecha disponible
            60, 
            1, 
            1
        );
        
        DBMS_OUTPUT.PUT_LINE('ERROR: Se permitió crear un examen con fechas inválidas');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Caso negativo (fechas): Error capturado correctamente: ' || SQLERRM);
    END;
    
    -- Caso negativo: profesor no asignado al grupo
    BEGIN
        INSERT INTO Examenes (
            examen_id, 
            descripcion, 
            fecha_creacion, 
            fecha_disponible, 
            fecha_limite, 
            tiempo_limite, 
            creador_id, 
            grupo_id
        ) VALUES (
            1003, 
            'Examen con profesor inválido', 
            SYSTIMESTAMP, 
            SYSTIMESTAMP + INTERVAL '1' DAY, 
            SYSTIMESTAMP + INTERVAL '7' DAY,
            60, 
            2, -- Profesor ID 2
            3  -- Grupo ID 3 (el profesor 2 no está asignado a este grupo)
        );
        
        DBMS_OUTPUT.PUT_LINE('ERROR: Se permitió crear un examen con profesor no asignado al grupo');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Caso negativo (profesor): Error capturado correctamente: ' || SQLERRM);
    END;
END;
/

-- ===============================================================
-- 2. Prueba para trg_examenes_before_insert
-- ===============================================================
DECLARE
    v_examen_id NUMBER;
    v_fecha_creacion TIMESTAMP;
    v_umbral_aprobacion NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Prueba 2: trg_examenes_before_insert ===');
    
    -- Caso: Insertar examen sin especificar ID, fecha de creación ni umbral
    INSERT INTO Examenes (
        descripcion,
        fecha_disponible,
        fecha_limite,
        tiempo_limite,
        creador_id,
        grupo_id
    ) VALUES (
        'Examen para probar valores por defecto',
        SYSTIMESTAMP + INTERVAL '1' DAY,
        SYSTIMESTAMP + INTERVAL '7' DAY,
        60,
        1,
        1
    ) RETURNING examen_id, fecha_creacion, umbral_aprobacion INTO v_examen_id, v_fecha_creacion, v_umbral_aprobacion;
    
    -- Verificar que se asignaron valores automáticamente
    DBMS_OUTPUT.PUT_LINE('Examen ID asignado: ' || v_examen_id);
    DBMS_OUTPUT.PUT_LINE('Fecha creación asignada: ' || TO_CHAR(v_fecha_creacion, 'YYYY-MM-DD HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('Umbral aprobación por defecto: ' || v_umbral_aprobacion);
    
    -- Limpiar datos de prueba
    DELETE FROM Examenes WHERE examen_id = v_examen_id;
    
    DBMS_OUTPUT.PUT_LINE('Trigger de valores por defecto funciona correctamente');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al probar valores por defecto: ' || SQLERRM);
END;
/

-- ===============================================================
-- 3. Prueba para trg_evitar_preguntas_duplicadas
-- ===============================================================
DECLARE
    v_examen_id NUMBER := 2001;
    v_pregunta_id NUMBER := 101;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Prueba 3: trg_evitar_preguntas_duplicadas ===');
    
    -- Crear examen de prueba
    BEGIN
        INSERT INTO Examenes (
            examen_id, descripcion, fecha_creacion, fecha_disponible, 
            fecha_limite, tiempo_limite, creador_id, grupo_id
        ) VALUES (
            v_examen_id, 'Examen para prueba de duplicados', SYSTIMESTAMP, 
            SYSTIMESTAMP + INTERVAL '1' DAY, SYSTIMESTAMP + INTERVAL '7' DAY, 
            60, 1, 1
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Crear pregunta de prueba si no existe
    BEGIN
        INSERT INTO Preguntas (
            pregunta_id, texto, fecha_creacion, es_publica,
            tipo_pregunta_id, creador_id, tema_id
        ) VALUES (
            v_pregunta_id, 'Pregunta de prueba', SYSTIMESTAMP, 'S',
            1, 1, 1
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Caso positivo: Agregar pregunta por primera vez
    BEGIN
        -- Eliminar si existe (para asegurar que la prueba funciona)
        DELETE FROM Preguntas_Examenes 
        WHERE examen_id = v_examen_id AND pregunta_id = v_pregunta_id;
        
        -- Insertar pregunta al examen
        INSERT INTO Preguntas_Examenes (
            pregunta_examen_id, peso, orden, pregunta_id, examen_id
        ) VALUES (
            201, 10, 1, v_pregunta_id, v_examen_id
        );
        
        DBMS_OUTPUT.PUT_LINE('Caso positivo: Pregunta agregada correctamente al examen');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en caso positivo: ' || SQLERRM);
    END;
    
    -- Caso negativo: Intentar agregar la misma pregunta nuevamente
    BEGIN
        INSERT INTO Preguntas_Examenes (
            pregunta_examen_id, peso, orden, pregunta_id, examen_id
        ) VALUES (
            202, 15, 2, v_pregunta_id, v_examen_id
        );
        
        DBMS_OUTPUT.PUT_LINE('ERROR: Se permitió agregar pregunta duplicada');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Caso negativo: Error capturado correctamente: ' || SQLERRM);
    END;
    
    -- Limpiar datos de prueba
    DELETE FROM Preguntas_Examenes WHERE examen_id = v_examen_id;
    DELETE FROM Preguntas WHERE pregunta_id = v_pregunta_id;
    DELETE FROM Examenes WHERE examen_id = v_examen_id;
END;
/

-- ===============================================================
-- 4. Prueba para trg_verificar_limite_preguntas
-- ===============================================================
DECLARE
    v_examen_id NUMBER := 3001;
    v_base_pregunta_id NUMBER := 301;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Prueba 4: trg_verificar_limite_preguntas ===');
    
    -- Crear examen de prueba con límite de 2 preguntas
    BEGIN
        INSERT INTO Examenes (
            examen_id, descripcion, fecha_creacion, fecha_disponible, 
            fecha_limite, tiempo_limite, cantidad_preguntas_mostrar, 
            creador_id, grupo_id
        ) VALUES (
            v_examen_id, 'Examen con límite de preguntas', SYSTIMESTAMP, 
            SYSTIMESTAMP + INTERVAL '1' DAY, SYSTIMESTAMP + INTERVAL '7' DAY, 
            60, 2, 1, 1
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            UPDATE Examenes SET cantidad_preguntas_mostrar = 2
            WHERE examen_id = v_examen_id;
    END;
    
    -- Crear preguntas de prueba
    FOR i IN 1..3 LOOP
        BEGIN
            INSERT INTO Preguntas (
                pregunta_id, texto, fecha_creacion, es_publica,
                tipo_pregunta_id, creador_id, tema_id
            ) VALUES (
                v_base_pregunta_id + i, 'Pregunta de prueba ' || i, 
                SYSTIMESTAMP, 'S', 1, 1, 1
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL; -- Ignorar si ya existe
        END;
    END LOOP;
    
    -- Limpiar cualquier pregunta previa
    DELETE FROM Preguntas_Examenes WHERE examen_id = v_examen_id;
    
    -- Caso positivo: Agregar primera pregunta
    BEGIN
        INSERT INTO Preguntas_Examenes (
            pregunta_examen_id, peso, orden, pregunta_id, examen_id
        ) VALUES (
            301, 50, 1, v_base_pregunta_id + 1, v_examen_id
        );
        
        DBMS_OUTPUT.PUT_LINE('Primera pregunta agregada correctamente');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al agregar primera pregunta: ' || SQLERRM);
    END;
    
    -- Caso positivo: Agregar segunda pregunta (límite permitido)
    BEGIN
        INSERT INTO Preguntas_Examenes (
            pregunta_examen_id, peso, orden, pregunta_id, examen_id
        ) VALUES (
            302, 50, 2, v_base_pregunta_id + 2, v_examen_id
        );
        
        DBMS_OUTPUT.PUT_LINE('Segunda pregunta agregada correctamente');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al agregar segunda pregunta: ' || SQLERRM);
    END;
    
    -- Caso negativo: Intentar agregar tercera pregunta (excede límite)
    BEGIN
        INSERT INTO Preguntas_Examenes (
            pregunta_examen_id, peso, orden, pregunta_id, examen_id
        ) VALUES (
            303, 50, 3, v_base_pregunta_id + 3, v_examen_id
        );
        
        DBMS_OUTPUT.PUT_LINE('ERROR: Se permitió exceder el límite de preguntas');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Caso negativo: Error capturado correctamente: ' || SQLERRM);
    END;
    
    -- Limpiar datos de prueba
    DELETE FROM Preguntas_Examenes WHERE examen_id = v_examen_id;
    FOR i IN 1..3 LOOP
        DELETE FROM Preguntas WHERE pregunta_id = v_base_pregunta_id + i;
    END LOOP;
    DELETE FROM Examenes WHERE examen_id = v_examen_id;
END;
/

-- ===============================================================
-- 5. Prueba para trg_validar_pregunta_tema_examen
-- ===============================================================
DECLARE
    v_examen_id NUMBER := 4001;
    v_pregunta_correcta_id NUMBER := 401;
    v_pregunta_incorrecta_id NUMBER := 402;
    v_tema_correcto_id NUMBER := 1;
    v_tema_incorrecto_id NUMBER := 25; -- Tema que no está relacionado con el curso
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Prueba 5: trg_validar_pregunta_tema_examen ===');
    
    -- Crear examen de prueba
    BEGIN
        INSERT INTO Examenes (
            examen_id, descripcion, fecha_creacion, fecha_disponible, 
            fecha_limite, tiempo_limite, creador_id, grupo_id
        ) VALUES (
            v_examen_id, 'Examen para prueba de temas', SYSTIMESTAMP, 
            SYSTIMESTAMP + INTERVAL '1' DAY, SYSTIMESTAMP + INTERVAL '7' DAY, 
            60, 1, 1
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Crear pregunta con tema correcto
    BEGIN
        INSERT INTO Preguntas (
            pregunta_id, texto, fecha_creacion, es_publica,
            tipo_pregunta_id, creador_id, tema_id, retroalimentacion
        ) VALUES (
            v_pregunta_correcta_id, 'Pregunta con tema correcto', 
            SYSTIMESTAMP, 'S', 1, 1, v_tema_correcto_id,
            'Esta es una retroalimentación de prueba'
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Crear pregunta con tema incorrecto
    BEGIN
        INSERT INTO Preguntas (
            pregunta_id, texto, fecha_creacion, es_publica,
            tipo_pregunta_id, creador_id, tema_id
        ) VALUES (
            v_pregunta_incorrecta_id, 'Pregunta con tema incorrecto', 
            SYSTIMESTAMP, 'S', 1, 1, v_tema_incorrecto_id
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Caso positivo: Agregar pregunta con tema correcto
    BEGIN
        INSERT INTO Preguntas_Examenes (
            pregunta_examen_id, peso, orden, pregunta_id, examen_id
        ) VALUES (
            401, 100, 1, v_pregunta_correcta_id, v_examen_id
        );
        
        DBMS_OUTPUT.PUT_LINE('Caso positivo: Pregunta con tema correcto agregada');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en caso positivo: ' || SQLERRM);
    END;
    
    -- Caso negativo: Agregar pregunta con tema incorrecto
    BEGIN
        INSERT INTO Preguntas_Examenes (
            pregunta_examen_id, peso, orden, pregunta_id, examen_id
        ) VALUES (
            402, 100, 2, v_pregunta_incorrecta_id, v_examen_id
        );
        
        DBMS_OUTPUT.PUT_LINE('ERROR: Se permitió agregar pregunta con tema incorrecto');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Caso negativo: Error capturado correctamente: ' || SQLERRM);
    END;
    
    -- Limpiar datos de prueba
    DELETE FROM Preguntas_Examenes WHERE examen_id = v_examen_id;
    DELETE FROM Preguntas WHERE pregunta_id IN (v_pregunta_correcta_id, v_pregunta_incorrecta_id);
    DELETE FROM Examenes WHERE examen_id = v_examen_id;
END;
/

-- ===============================================================
-- 6. Prueba para trg_agregar_subpreguntas_examen
-- ===============================================================
DECLARE
    v_examen_id NUMBER := 5001;
    v_pregunta_principal_id NUMBER := 501;
    v_subpregunta1_id NUMBER := 502;
    v_subpregunta2_id NUMBER := 503;
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Prueba 6: trg_agregar_subpreguntas_examen ===');
    
    -- Crear examen de prueba
    BEGIN
        INSERT INTO Examenes (
            examen_id, descripcion, fecha_creacion, fecha_disponible, 
            fecha_limite, tiempo_limite, creador_id, grupo_id
        ) VALUES (
            v_examen_id, 'Examen para prueba de subpreguntas', SYSTIMESTAMP, 
            SYSTIMESTAMP + INTERVAL '1' DAY, SYSTIMESTAMP + INTERVAL '7' DAY, 
            60, 1, 1
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Crear pregunta principal
    BEGIN
        INSERT INTO Preguntas (
            pregunta_id, texto, fecha_creacion, es_publica,
            tipo_pregunta_id, creador_id, tema_id
        ) VALUES (
            v_pregunta_principal_id, 'Pregunta principal', 
            SYSTIMESTAMP, 'S', 1, 1, 1
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Crear subpreguntas
    BEGIN
        INSERT INTO Preguntas (
            pregunta_id, texto, fecha_creacion, es_publica,
            tipo_pregunta_id, creador_id, tema_id, pregunta_padre_id
        ) VALUES (
            v_subpregunta1_id, 'Subpregunta 1', 
            SYSTIMESTAMP, 'S', 1, 1, 1, v_pregunta_principal_id
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            UPDATE Preguntas SET pregunta_padre_id = v_pregunta_principal_id
            WHERE pregunta_id = v_subpregunta1_id;
    END;
    
    BEGIN
        INSERT INTO Preguntas (
            pregunta_id, texto, fecha_creacion, es_publica,
            tipo_pregunta_id, creador_id, tema_id, pregunta_padre_id
        ) VALUES (
            v_subpregunta2_id, 'Subpregunta 2', 
            SYSTIMESTAMP, 'S', 1, 1, 1, v_pregunta_principal_id
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            UPDATE Preguntas SET pregunta_padre_id = v_pregunta_principal_id
            WHERE pregunta_id = v_subpregunta2_id;
    END;
    
    -- Limpiar cualquier pregunta previa
    DELETE FROM Preguntas_Examenes WHERE examen_id = v_examen_id;
    
    -- Agregar pregunta principal al examen (debe disparar el trigger)
    BEGIN
        INSERT INTO Preguntas_Examenes (
            pregunta_examen_id, peso, orden, pregunta_id, examen_id
        ) VALUES (
            501, 100, 1, v_pregunta_principal_id, v_examen_id
        );
        
        -- Verificar que se agregaron las subpreguntas automáticamente
        SELECT COUNT(*) INTO v_count
        FROM Preguntas_Examenes
        WHERE examen_id = v_examen_id
        AND pregunta_id IN (v_subpregunta1_id, v_subpregunta2_id);
        
        IF v_count = 2 THEN
            DBMS_OUTPUT.PUT_LINE('Trigger funcionó correctamente: ' || v_count || ' subpreguntas agregadas automáticamente');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR: No se agregaron todas las subpreguntas (' || v_count || ' de 2)');
        END IF;
        
        -- Verificar redistribución de pesos
        SELECT peso INTO v_count 
        FROM Preguntas_Examenes
        WHERE examen_id = v_examen_id
        AND pregunta_id = v_pregunta_principal_id;
        
        DBMS_OUTPUT.PUT_LINE('Peso de pregunta principal ajustado a: ' || v_count);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al agregar pregunta principal: ' || SQLERRM);
    END;
    
    -- Limpiar datos de prueba
    DELETE FROM Preguntas_Examenes WHERE examen_id = v_examen_id;
    DELETE FROM Preguntas WHERE pregunta_id IN (v_pregunta_principal_id, v_subpregunta1_id, v_subpregunta2_id);
    DELETE FROM Examenes WHERE examen_id = v_examen_id;
END;
/

-- ===============================================================
-- 7. Prueba para trg_completar_examen
-- ===============================================================
DECLARE
    v_examen_id NUMBER := 6001;
    v_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Prueba 7: trg_completar_examen ===');
    
    -- Crear examen de prueba sin fecha disponible
    BEGIN
        INSERT INTO Examenes (
            examen_id, descripcion, fecha_creacion, 
            tiempo_limite, cantidad_preguntas_mostrar,
            creador_id, grupo_id, max_intentos
        ) VALUES (
            v_examen_id, 'Examen para prueba de auto-completado', SYSTIMESTAMP, 
            60, 5, 1, 1, 1
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            UPDATE Examenes SET
                fecha_disponible = NULL,
                cantidad_preguntas_mostrar = 5
            WHERE examen_id = v_examen_id;
    END;
    
    -- Agregar algunas preguntas al examen
    FOR i IN 1..3 LOOP
        -- Crear pregunta
        BEGIN
            INSERT INTO Preguntas (
                pregunta_id, texto, fecha_creacion, es_publica,
                tipo_pregunta_id, creador_id, tema_id
            ) VALUES (
                600 + i, 'Pregunta ' || i || ' para auto-completado', 
                SYSTIMESTAMP, 'S', 1, 1, 1
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL; -- Ignorar si ya existe
        END;
        
        -- Agregar pregunta al examen
        BEGIN
            INSERT INTO Preguntas_Examenes (
                pregunta_examen_id, peso, orden, pregunta_id, examen_id
            ) VALUES (
                600 + i, 100/3, i, 600 + i, v_examen_id
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL; -- Ignorar si ya existe
        END;
    END LOOP;
    
    -- Verificar número de preguntas antes de activar trigger
    SELECT COUNT(*) INTO v_count
    FROM Preguntas_Examenes
    WHERE examen_id = v_examen_id;
    
    DBMS_OUTPUT.PUT_LINE('Preguntas antes de activar trigger: ' || v_count);
    
    -- Activar el trigger actualizando fecha_disponible
    UPDATE Examenes 
    SET fecha_disponible = SYSTIMESTAMP + INTERVAL '1' DAY,
        fecha_limite = SYSTIMESTAMP + INTERVAL '7' DAY
    WHERE examen_id = v_examen_id;
    
    -- Verificar que el trigger haya completado el examen
    SELECT COUNT(*) INTO v_count
    FROM Preguntas_Examenes
    WHERE examen_id = v_examen_id;
    
    IF v_count >= 5 THEN
        DBMS_OUTPUT.PUT_LINE('Trigger funcionó correctamente: Examen completado con ' || v_count || ' preguntas');
    ELSE
        DBMS_OUTPUT.PUT_LINE('ERROR: El examen no se completó automáticamente (' || v_count || ' de 5 preguntas)');
    END IF;
    
    -- Limpiar datos de prueba
    DELETE FROM Preguntas_Examenes WHERE examen_id = v_examen_id;
    FOR i IN 1..5 LOOP
        DELETE FROM Preguntas WHERE pregunta_id = 600 + i;
    END LOOP;
    DELETE FROM Examenes WHERE examen_id = v_examen_id;
END;
/

-- ===============================================================
-- 8. Prueba para trg_validar_tiempo_examen
-- ===============================================================
DECLARE
    v_examen_id NUMBER := 7001;
    v_intento_id NUMBER := 7001;
    v_pregunta_id NUMBER := 701;
    v_pregunta_examen_id NUMBER := 701;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Prueba 8: trg_validar_tiempo_examen ===');
    
    -- Crear examen de prueba con tiempo límite de 30 minutos
    BEGIN
        INSERT INTO Examenes (
            examen_id, descripcion, fecha_creacion, fecha_disponible, 
            fecha_limite, tiempo_limite, creador_id, grupo_id
        ) VALUES (
            v_examen_id, 'Examen para prueba de tiempo', SYSTIMESTAMP, 
            SYSTIMESTAMP - INTERVAL '1' DAY, SYSTIMESTAMP + INTERVAL '7' DAY, 
            30, 1, 1
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Crear pregunta de prueba
    BEGIN
        INSERT INTO Preguntas (
            pregunta_id, texto, fecha_creacion, es_publica,
            tipo_pregunta_id, creador_id, tema_id
        ) VALUES (
            v_pregunta_id, 'Pregunta para prueba de tiempo', 
            SYSTIMESTAMP, 'S', 1, 1, 1
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Asociar pregunta al examen
    BEGIN
        INSERT INTO Preguntas_Examenes (
            pregunta_examen_id, peso, orden, pregunta_id, examen_id
        ) VALUES (
            v_pregunta_examen_id, 100, 1, v_pregunta_id, v_examen_id
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Caso positivo: Intento dentro del tiempo límite
    BEGIN
        -- Crear intento reciente
        INSERT INTO Intentos_Examen (
            intento_examen_id, estudiante_id, examen_id, 
            fecha_inicio, fecha_fin, tiempo_utilizado, ip_address
        ) VALUES (
            v_intento_id, 26, v_examen_id, 
            SYSTIMESTAMP - INTERVAL '5' MINUTE, 
            SYSTIMESTAMP, 5, '192.168.1.1'
        );
        
        -- Intentar agregar respuesta (debería funcionar)
        INSERT INTO Respuestas_Estudiantes (
            respuesta_estudiante_id, intento_examen_id, pregunta_examen_id
        ) VALUES (
            701, v_intento_id, v_pregunta_examen_id
        );
        
        DBMS_OUTPUT.PUT_LINE('Caso positivo: Respuesta agregada dentro del tiempo límite');
        
        -- Limpiar respuesta
        DELETE FROM Respuestas_Estudiantes 
        WHERE respuesta_estudiante_id = 701;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en caso positivo: ' || SQLERRM);
    END;
    
    -- Caso negativo: Intento fuera del tiempo límite
    BEGIN
        -- Actualizar intento para que parezca iniciado hace mucho
        UPDATE Intentos_Examen
        SET fecha_inicio = SYSTIMESTAMP - INTERVAL '60' MINUTE
        WHERE intento_examen_id = v_intento_id;
        
        -- Intentar agregar respuesta (debería fallar)
        INSERT INTO Respuestas_Estudiantes (
            respuesta_estudiante_id, intento_examen_id, pregunta_examen_id
        ) VALUES (
            702, v_intento_id, v_pregunta_examen_id
        );
        
        DBMS_OUTPUT.PUT_LINE('ERROR: Se permitió agregar respuesta fuera del tiempo límite');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Caso negativo: Error capturado correctamente: ' || SQLERRM);
    END;
    
    -- Limpiar datos de prueba
    DELETE FROM Intentos_Examen WHERE intento_examen_id = v_intento_id;
    DELETE FROM Preguntas_Examenes WHERE pregunta_examen_id = v_pregunta_examen_id;
    DELETE FROM Preguntas WHERE pregunta_id = v_pregunta_id;
    DELETE FROM Examenes WHERE examen_id = v_examen_id;
END;
/

-- ===============================================================
-- 9. Prueba para trg_restringir_modificacion_examen
-- ===============================================================
DECLARE
    v_examen_id NUMBER := 8001;
    v_intento_id NUMBER := 8001;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Prueba 9: trg_restringir_modificacion_examen ===');
    
    -- Crear examen de prueba
    BEGIN
        INSERT INTO Examenes (
            examen_id, descripcion, fecha_creacion, fecha_disponible, 
            fecha_limite, tiempo_limite, creador_id, grupo_id
        ) VALUES (
            v_examen_id, 'Examen para prueba de modificación', SYSTIMESTAMP, 
            SYSTIMESTAMP + INTERVAL '1' DAY, SYSTIMESTAMP + INTERVAL '7' DAY, 
            60, 1, 1
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Caso positivo: Modificar examen sin intentos
    BEGIN
        UPDATE Examenes
        SET descripcion = 'Descripción modificada'
        WHERE examen_id = v_examen_id;
        
        DBMS_OUTPUT.PUT_LINE('Caso positivo: Examen modificado correctamente');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en caso positivo: ' || SQLERRM);
    END;
    
    -- Crear un intento para el examen
    BEGIN
        INSERT INTO Intentos_Examen (
            intento_examen_id, estudiante_id, examen_id, 
            fecha_inicio, fecha_fin, tiempo_utilizado, ip_address
        ) VALUES (
            v_intento_id, 26, v_examen_id, 
            SYSTIMESTAMP - INTERVAL '30' MINUTE, 
            SYSTIMESTAMP, 30, '192.168.1.1'
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Caso negativo: Intentar modificar examen con intentos
    BEGIN
        UPDATE Examenes
        SET tiempo_limite = 90
        WHERE examen_id = v_examen_id;
        
        DBMS_OUTPUT.PUT_LINE('ERROR: Se permitió modificar un examen con intentos');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Caso negativo: Error capturado correctamente: ' || SQLERRM);
    END;
    
    -- Limpiar datos de prueba
    DELETE FROM Intentos_Examen WHERE intento_examen_id = v_intento_id;
    DELETE FROM Examenes WHERE examen_id = v_examen_id;
END;
/

-- ===============================================================
-- 10. Prueba para trg_restringir_modificacion_pregunta
-- ===============================================================
DECLARE
    v_examen_id NUMBER := 9001;
    v_intento_id NUMBER := 9001;
    v_pregunta_id NUMBER := 901;
    v_pregunta_examen_id NUMBER := 901;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Prueba 10: trg_restringir_modificacion_pregunta ===');
    
    -- Crear pregunta de prueba
    BEGIN
        INSERT INTO Preguntas (
            pregunta_id, texto, fecha_creacion, es_publica,
            tipo_pregunta_id, creador_id, tema_id
        ) VALUES (
            v_pregunta_id, 'Pregunta para prueba de modificación', 
            SYSTIMESTAMP, 'S', 1, 1, 1
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Crear examen de prueba
    BEGIN
        INSERT INTO Examenes (
            examen_id, descripcion, fecha_creacion, fecha_disponible, 
            fecha_limite, tiempo_limite, creador_id, grupo_id
        ) VALUES (
            v_examen_id, 'Examen para prueba de modificación de pregunta', SYSTIMESTAMP, 
            SYSTIMESTAMP - INTERVAL '1' DAY, SYSTIMESTAMP + INTERVAL '7' DAY, 
            60, 1, 1
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Asociar pregunta al examen
    BEGIN
        INSERT INTO Preguntas_Examenes (
            pregunta_examen_id, peso, orden, pregunta_id, examen_id
        ) VALUES (
            v_pregunta_examen_id, 100, 1, v_pregunta_id, v_examen_id
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Caso positivo: Modificar pregunta sin intentos
    BEGIN
        UPDATE Preguntas
        SET texto = 'Texto modificado de la pregunta'
        WHERE pregunta_id = v_pregunta_id;
        
        DBMS_OUTPUT.PUT_LINE('Caso positivo: Pregunta modificada correctamente');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en caso positivo: ' || SQLERRM);
    END;
    
    -- Crear un intento para el examen
    BEGIN
        INSERT INTO Intentos_Examen (
            intento_examen_id, estudiante_id, examen_id, 
            fecha_inicio, fecha_fin, tiempo_utilizado, ip_address
        ) VALUES (
            v_intento_id, 26, v_examen_id, 
            SYSTIMESTAMP - INTERVAL '30' MINUTE, 
            SYSTIMESTAMP, 30, '192.168.1.1'
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Caso negativo: Intentar modificar pregunta en examen con intentos
    BEGIN
        UPDATE Preguntas
        SET texto = 'Texto modificado nuevamente'
        WHERE pregunta_id = v_pregunta_id;
        
        DBMS_OUTPUT.PUT_LINE('ERROR: Se permitió modificar una pregunta en examen con intentos');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Caso negativo: Error capturado correctamente: ' || SQLERRM);
    END;
    
    -- Limpiar datos de prueba
    DELETE FROM Intentos_Examen WHERE intento_examen_id = v_intento_id;
    DELETE FROM Preguntas_Examenes WHERE pregunta_examen_id = v_pregunta_examen_id;
    DELETE FROM Preguntas WHERE pregunta_id = v_pregunta_id;
    DELETE FROM Examenes WHERE examen_id = v_examen_id;
END;
/

-- ===============================================================
-- 11. Prueba para trg_bloquear_edicion_examen
-- ===============================================================
DECLARE
    v_examen_id NUMBER := 10001;
    v_intento_id NUMBER := 10001;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Prueba 11: trg_bloquear_edicion_examen ===');
    
    -- Crear examen de prueba
    BEGIN
        INSERT INTO Examenes (
            examen_id, descripcion, fecha_creacion, fecha_disponible, 
            fecha_limite, tiempo_limite, cantidad_preguntas_mostrar,
            creador_id, grupo_id
        ) VALUES (
            v_examen_id, 'Examen para prueba de bloqueo de edición', SYSTIMESTAMP, 
            SYSTIMESTAMP + INTERVAL '1' DAY, SYSTIMESTAMP + INTERVAL '7' DAY, 
            60, 10, 1, 1
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Caso positivo: Modificar examen sin intentos
    BEGIN
        UPDATE Examenes
        SET tiempo_limite = 90,
            cantidad_preguntas_mostrar = 15
        WHERE examen_id = v_examen_id;
        
        DBMS_OUTPUT.PUT_LINE('Caso positivo: Examen modificado correctamente');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en caso positivo: ' || SQLERRM);
    END;
    
    -- Crear un intento para el examen
    BEGIN
        INSERT INTO Intentos_Examen (
            intento_examen_id, estudiante_id, examen_id, 
            fecha_inicio, fecha_fin, tiempo_utilizado, ip_address
        ) VALUES (
            v_intento_id, 26, v_examen_id, 
            SYSTIMESTAMP - INTERVAL '30' MINUTE, 
            SYSTIMESTAMP, 30, '192.168.1.1'
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Caso negativo: Intentar modificar examen con intentos
    BEGIN
        UPDATE Examenes
        SET tiempo_limite = 120,
            cantidad_preguntas_mostrar = 20
        WHERE examen_id = v_examen_id;
        
        DBMS_OUTPUT.PUT_LINE('ERROR: Se permitió modificar un examen con intentos');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Caso negativo: Error capturado correctamente: ' || SQLERRM);
    END;
    
    -- Caso positivo: Actualizar descripción (no bloqueada por el trigger)
    BEGIN
        UPDATE Examenes
        SET descripcion = 'Descripción actualizada'
        WHERE examen_id = v_examen_id;
        
        DBMS_OUTPUT.PUT_LINE('Se permitió actualizar la descripción (campo no restringido)');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al actualizar descripción: ' || SQLERRM);
    END;
    
    -- Limpiar datos de prueba
    DELETE FROM Intentos_Examen WHERE intento_examen_id = v_intento_id;
    DELETE FROM Examenes WHERE examen_id = v_examen_id;
END;
/

-- ===============================================================
-- 12. Prueba para trg_validar_peso_pregunta
-- ===============================================================
DECLARE
    v_examen_id NUMBER := 11001;
    v_pregunta_id NUMBER := 1101;
    v_pregunta_examen_id NUMBER := 1101;
    v_peso_asignado NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Prueba 12: trg_validar_peso_pregunta ===');
    
    -- Crear examen de prueba
    BEGIN
        INSERT INTO Examenes (
            examen_id, descripcion, fecha_creacion, fecha_disponible, 
            fecha_limite, tiempo_limite, creador_id, grupo_id
        ) VALUES (
            v_examen_id, 'Examen para prueba de peso de pregunta', SYSTIMESTAMP, 
            SYSTIMESTAMP + INTERVAL '1' DAY, SYSTIMESTAMP + INTERVAL '7' DAY, 
            60, 1, 1
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Crear pregunta de prueba
    BEGIN
        INSERT INTO Preguntas (
            pregunta_id, texto, fecha_creacion, es_publica,
            tipo_pregunta_id, creador_id, tema_id
        ) VALUES (
            v_pregunta_id, 'Pregunta para prueba de peso', 
            SYSTIMESTAMP, 'S', 1, 1, 1
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Caso: Agregar pregunta sin especificar peso
    BEGIN
        INSERT INTO Preguntas_Examenes (
            pregunta_examen_id, orden, pregunta_id, examen_id
        ) VALUES (
            v_pregunta_examen_id, 1, v_pregunta_id, v_examen_id
        );
        
        -- Verificar peso asignado
        SELECT peso INTO v_peso_asignado
        FROM Preguntas_Examenes
        WHERE pregunta_examen_id = v_pregunta_examen_id;
        
        DBMS_OUTPUT.PUT_LINE('Pregunta agregada sin peso explícito. Peso asignado: ' || v_peso_asignado);
        
        -- Verificar que sea un valor válido
        IF v_peso_asignado > 0 AND v_peso_asignado <= 100 THEN
            DBMS_OUTPUT.PUT_LINE('Peso asignado automáticamente correcto');
        ELSE
            DBMS_OUTPUT.PUT_LINE('ERROR: Peso asignado incorrecto');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error al agregar pregunta sin peso: ' || SQLERRM);
    END;
    
    -- Limpiar datos de prueba
    DELETE FROM Preguntas_Examenes WHERE pregunta_examen_id = v_pregunta_examen_id;
    DELETE FROM Preguntas WHERE pregunta_id = v_pregunta_id;
    DELETE FROM Examenes WHERE examen_id = v_examen_id;
END;
/

-- ===============================================================
-- 13. Prueba para trg_validar_cambio_visibilidad
-- ===============================================================
DECLARE
    v_examen_id NUMBER := 12001;
    v_pregunta_id NUMBER := 1201;
    v_pregunta_examen_id NUMBER := 1201;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Prueba 13: trg_validar_cambio_visibilidad ===');
    
    -- Crear pregunta pública
    BEGIN
        INSERT INTO Preguntas (
            pregunta_id, texto, fecha_creacion, es_publica,
            tipo_pregunta_id, creador_id, tema_id
        ) VALUES (
            v_pregunta_id, 'Pregunta para prueba de visibilidad', 
            SYSTIMESTAMP, 'S', 1, 1, 1
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            UPDATE Preguntas SET es_publica = 'S'
            WHERE pregunta_id = v_pregunta_id;
    END;
    
    -- Caso positivo: Cambiar a privada cuando no está en exámenes
    BEGIN
        UPDATE Preguntas
        SET es_publica = 'N'
        WHERE pregunta_id = v_pregunta_id;
        
        DBMS_OUTPUT.PUT_LINE('Caso positivo: Pregunta cambiada a privada correctamente');
        
        -- Revertir para pruebas siguientes
        UPDATE Preguntas
        SET es_publica = 'S'
        WHERE pregunta_id = v_pregunta_id;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error en caso positivo: ' || SQLERRM);
    END;
    
    -- Crear examen activo y agregar pregunta
    BEGIN
        INSERT INTO Examenes (
            examen_id, descripcion, fecha_creacion, fecha_disponible, 
            fecha_limite, tiempo_limite, creador_id, grupo_id
        ) VALUES (
            v_examen_id, 'Examen para prueba de visibilidad', SYSTIMESTAMP, 
            SYSTIMESTAMP - INTERVAL '1' DAY, SYSTIMESTAMP + INTERVAL '7' DAY, 
            60, 1, 1
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            UPDATE Examenes 
            SET fecha_disponible = SYSTIMESTAMP - INTERVAL '1' DAY,
                fecha_limite = SYSTIMESTAMP + INTERVAL '7' DAY
            WHERE examen_id = v_examen_id;
    END;
    
    -- Asociar pregunta al examen
    BEGIN
        INSERT INTO Preguntas_Examenes (
            pregunta_examen_id, peso, orden, pregunta_id, examen_id
        ) VALUES (
            v_pregunta_examen_id, 100, 1, v_pregunta_id, v_examen_id
        );
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            NULL; -- Ignorar si ya existe
    END;
    
    -- Caso negativo: Intentar cambiar a privada cuando está en un examen activo
    BEGIN
        UPDATE Preguntas
        SET es_publica = 'N'
        WHERE pregunta_id = v_pregunta_id;
        
        DBMS_OUTPUT.PUT_LINE('ERROR: Se permitió cambiar a privada una pregunta en examen activo');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Caso negativo: Error capturado correctamente: ' || SQLERRM);
    END;
    
    -- Limpiar datos de prueba
    DELETE FROM Preguntas_Examenes WHERE pregunta_examen_id = v_pregunta_examen_id;
    DELETE FROM Examenes WHERE examen_id = v_examen_id;
    DELETE FROM Preguntas WHERE pregunta_id = v_pregunta_id;
END;
/

COMMIT;
DBMS_OUTPUT.PUT_LINE('Todas las pruebas de triggers completadas.');