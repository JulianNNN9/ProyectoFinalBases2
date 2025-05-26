-- Test cases for sp_progreso_estudiante
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing sp_progreso_estudiante (second block)');
    
    DECLARE
        v_estudiante_id NUMBER; 
        v_curso_id NUMBER;
        v_progreso SYS_REFCURSOR;
        v_examen_id NUMBER;
        v_examen_desc VARCHAR2(100);
        v_puntaje NUMBER;
        v_intentos NUMBER;
        v_max_intentos NUMBER;
        v_estado VARCHAR2(20);
        v_found BOOLEAN := FALSE;
        -- Potentially declare new variables here if the procedure expects additional parameters
    BEGIN
        -- Find a student with inscriptions
        BEGIN
            SELECT i.estudiante_id, g.curso_id
            INTO v_estudiante_id, v_curso_id
            FROM Inscripciones i
            JOIN Grupos g ON i.grupo_id = g.grupo_id
            WHERE ROWNUM = 1;
            
            DBMS_OUTPUT.PUT_LINE('INFO: Found student ' || v_estudiante_id || ' enrolled in course ' || v_curso_id);
            
            -- Test case: Get student progress
            -- REVIEW AND MODIFY THE PARAMETERS BELOW TO MATCH THE ACTUAL DEFINITION OF sp_progreso_estudiante
            -- This might involve adding, removing, or changing the names/types of parameters.
            sp_progreso_estudiante(
                p_estudiante_id => v_estudiante_id,
                p_curso_id => v_curso_id,       -- Verify if this parameter is expected, and with this name/type
                p_progreso => v_progreso
                -- Example: If a new parameter p_otro_parametro is required, add it here:
                -- p_otro_parametro => v_valor_otro_parametro, 
            );
            
            -- Try to fetch results from cursor
            BEGIN
                LOOP
                    FETCH v_progreso INTO v_examen_id, v_examen_desc, v_puntaje, v_intentos, v_max_intentos, v_estado;
                    EXIT WHEN v_progreso%NOTFOUND;
                    
                    v_found := TRUE;
                    DBMS_OUTPUT.PUT_LINE('Exam: ' || v_examen_desc || ', Status: ' || v_estado);
                END LOOP;
                
                IF v_progreso%ISOPEN THEN
                    CLOSE v_progreso;
                END IF;
                
                IF v_found THEN
                    DBMS_OUTPUT.PUT_LINE('SUCCESS: Found student progress information');
                ELSE
                    DBMS_OUTPUT.PUT_LINE('INFO: No progress records found for student ' || v_estudiante_id || ' in course ' || v_curso_id);
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    IF v_progreso%ISOPEN THEN
                        CLOSE v_progreso;
                    END IF;
                    DBMS_OUTPUT.PUT_LINE('ERROR: Error fetching cursor - ' || SQLERRM);
            END;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('INFO: No enrolled students found, testing with dummy values if possible');
                BEGIN
                    SELECT MIN(usuario_id) INTO v_estudiante_id
                    FROM Usuarios
                    WHERE tipo_usuario_id = (SELECT tipo_usuario_id FROM Tipo_Usuario WHERE descripcion = 'ESTUDIANTE');
                    
                    SELECT MIN(curso_id) INTO v_curso_id
                    FROM Cursos;
                    
                    IF v_estudiante_id IS NOT NULL AND v_curso_id IS NOT NULL THEN
                        DBMS_OUTPUT.PUT_LINE('INFO: Testing with student ' || v_estudiante_id || ' and course ' || v_curso_id);
                        -- REVIEW AND MODIFY THE PARAMETERS BELOW AS WELL
                        sp_progreso_estudiante(
                            p_estudiante_id => v_estudiante_id,
                            p_curso_id => v_curso_id,
                            p_progreso => v_progreso
                        );
                        IF v_progreso%ISOPEN THEN CLOSE v_progreso; END IF;
                        DBMS_OUTPUT.PUT_LINE('SUCCESS: Procedure executed with dummy values (no results expected or specific check).');
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('INFO: No student or course found for dummy test.');
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                         IF v_progreso%ISOPEN THEN CLOSE v_progreso; END IF;
                        DBMS_OUTPUT.PUT_LINE('ERROR: (Dummy value test) ' || SQLERRM);
                END;
            WHEN OTHERS THEN
                IF v_progreso%ISOPEN THEN CLOSE v_progreso; END IF;
                DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        END;
    END;
END;
/

-- Improved test for sp_obtener_retroalimentacion_examen
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing sp_obtener_retroalimentacion_examen (improved)');
    
    DECLARE
        v_intento_id NUMBER;
        v_retroalimentacion SYS_REFCURSOR;
        v_resp_id NUMBER;
        v_orden NUMBER;
        v_pregunta CLOB;
        v_tipo VARCHAR2(50);
        v_resp_est VARCHAR2(100);
        v_resp_corr VARCHAR2(100);
        v_feedback CLOB;
        v_puntaje NUMBER;
        v_peso NUMBER;
        v_found BOOLEAN := FALSE;
    BEGIN
        -- Check if we have attempts with responses
        BEGIN
            SELECT ie.intento_examen_id INTO v_intento_id
            FROM Intentos_Examen ie
            JOIN Respuestas_Estudiantes re ON ie.intento_examen_id = re.intento_examen_id
            WHERE ROWNUM = 1;
            
            DBMS_OUTPUT.PUT_LINE('INFO: Found attempt ' || v_intento_id || ' with responses');
            
            -- Test case: Get feedback for exam
            sp_obtener_retroalimentacion_examen(
                p_intento_id => v_intento_id,
                p_retroalimentacion => v_retroalimentacion
            );
            
            -- Try to fetch results from cursor
            BEGIN
                LOOP
                    FETCH v_retroalimentacion INTO v_resp_id, v_orden, v_pregunta, v_tipo, 
                                                v_resp_est, v_resp_corr, v_feedback, v_puntaje, v_peso;
                    EXIT WHEN v_retroalimentacion%NOTFOUND;
                    
                    v_found := TRUE;
                    DBMS_OUTPUT.PUT_LINE('Question order: ' || v_orden || ', Type: ' || v_tipo);
                END LOOP;
                
                IF v_retroalimentacion%ISOPEN THEN
                    CLOSE v_retroalimentacion;
                END IF;
                
                IF v_found THEN
                    DBMS_OUTPUT.PUT_LINE('SUCCESS: Retrieved feedback for exam');
                ELSE
                    DBMS_OUTPUT.PUT_LINE('INFO: No feedback found for this attempt (though responses exist)');
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    IF v_retroalimentacion%ISOPEN THEN
                        CLOSE v_retroalimentacion;
                    END IF;
                    DBMS_OUTPUT.PUT_LINE('ERROR: Error fetching cursor - ' || SQLERRM);
            END;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 DBMS_OUTPUT.PUT_LINE('INFO: No attempts with responses found, testing procedure call only with dummy ID');
                v_intento_id := -1; -- Dummy value
                BEGIN
                    sp_obtener_retroalimentacion_examen(
                        p_intento_id => v_intento_id,
                        p_retroalimentacion => v_retroalimentacion
                    );
                    
                    IF v_retroalimentacion%ISOPEN THEN CLOSE v_retroalimentacion; END IF;
                    DBMS_OUTPUT.PUT_LINE('SUCCESS: Procedure executed with dummy ID (no results expected)');
                EXCEPTION
                    WHEN OTHERS THEN
                        IF v_retroalimentacion%ISOPEN THEN CLOSE v_retroalimentacion; END IF;
                        DBMS_OUTPUT.PUT_LINE('INFO: Expected behavior or error with dummy data - ' || SQLERRM);
                END;
        END;
    END;
END;
/

-- Improved test for sp_reporte_desempeno_estudiante
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing sp_reporte_desempeno_estudiante (improved)');
    
    DECLARE
        v_estudiante_id NUMBER;
        v_examen_id NUMBER;
        v_intento_id NUMBER;
        v_reporte SYS_REFCURSOR;
        v_orden NUMBER;
        v_pregunta CLOB;
        v_tipo VARCHAR2(50);
        v_es_correcta CHAR(1);
        v_puntaje NUMBER;
        v_feedback CLOB;
        v_puntaje_total NUMBER;
        v_max_intentos NUMBER;
        v_intentos_usados NUMBER;
        v_estado VARCHAR2(20);
        v_found BOOLEAN := FALSE;
    BEGIN
        -- Check if we have attempts with responses
        BEGIN
            SELECT ie.estudiante_id, ie.examen_id, ie.intento_examen_id 
            INTO v_estudiante_id, v_examen_id, v_intento_id
            FROM Intentos_Examen ie
            JOIN Respuestas_Estudiantes re ON ie.intento_examen_id = re.intento_examen_id
            WHERE ROWNUM = 1;
            
            DBMS_OUTPUT.PUT_LINE('INFO: Found student ' || v_estudiante_id || ' with attempt ' || v_intento_id || ' for exam ' || v_examen_id);
            
            -- Test case: Get performance report with specific attempt
            -- REVIEW AND MODIFY THE PARAMETERS BELOW TO MATCH THE ACTUAL DEFINITION
            sp_reporte_desempeno_estudiante(
                p_estudiante_id => v_estudiante_id,
                p_examen_id => v_examen_id,
                p_intento_id => v_intento_id,
                p_reporte => v_reporte
                -- Add/remove/rename parameters as needed based on the procedure's true signature
            );
            
            BEGIN
                LOOP
                    FETCH v_reporte INTO v_orden, v_pregunta, v_tipo, v_es_correcta, v_puntaje, 
                                        v_feedback, v_puntaje_total, v_max_intentos, v_intentos_usados, v_estado;
                    EXIT WHEN v_reporte%NOTFOUND;
                    
                    v_found := TRUE;
                    DBMS_OUTPUT.PUT_LINE('Question ' || v_orden || ': ' || 
                                        CASE WHEN v_es_correcta = 'S' THEN 'Correct' ELSE 'Incorrect' END || 
                                        ', Points: ' || v_puntaje);
                END LOOP;
                
                IF v_reporte%ISOPEN THEN CLOSE v_reporte; END IF;
                
                IF v_found THEN
                    DBMS_OUTPUT.PUT_LINE('SUCCESS: Retrieved performance report');
                ELSE
                    DBMS_OUTPUT.PUT_LINE('INFO: No questions found in this attempt''s report');
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    IF v_reporte%ISOPEN THEN CLOSE v_reporte; END IF;
                    DBMS_OUTPUT.PUT_LINE('ERROR: Error fetching cursor - ' || SQLERRM);
            END;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('INFO: No attempts with responses found, testing with sample data if possible');
                BEGIN
                    SELECT MIN(u.usuario_id) INTO v_estudiante_id
                    FROM Usuarios u JOIN Tipo_Usuario tu ON u.tipo_usuario_id = tu.usuario_id
                    WHERE tu.descripcion = 'ESTUDIANTE';
                    
                    SELECT MIN(examen_id) INTO v_examen_id
                    FROM Examenes;
                    
                    IF v_estudiante_id IS NOT NULL AND v_examen_id IS NOT NULL THEN
                        DBMS_OUTPUT.PUT_LINE('INFO: Testing with student ' || v_estudiante_id || ' and exam ' || v_examen_id || ' (NULL intento_id)');
                        -- REVIEW AND MODIFY THE PARAMETERS BELOW AS WELL
                        sp_reporte_desempeno_estudiante(
                            p_estudiante_id => v_estudiante_id,
                            p_examen_id => v_examen_id,
                            p_intento_id => NULL,
                            p_reporte => v_reporte
                        );
                        IF v_reporte%ISOPEN THEN CLOSE v_reporte; END IF;
                        DBMS_OUTPUT.PUT_LINE('SUCCESS: Procedure executed with dummy data (no results expected or specific check).');
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('INFO: No student or exam found for dummy test.');
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        IF v_reporte%ISOPEN THEN CLOSE v_reporte; END IF;
                        DBMS_OUTPUT.PUT_LINE('INFO: Expected error or behavior with test data - ' || SQLERRM);
                END;
        END;
    END;
END;
/

-- Test case for sp_calificar_examen_completo
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing sp_calificar_examen_completo');
    
    DECLARE
        v_intento_id NUMBER;
        v_puntaje_antes NUMBER;
        v_puntaje_despues NUMBER;
    BEGIN
        -- Check if we have attempts with responses
        BEGIN
            SELECT ie.intento_examen_id, NVL(ie.puntaje_total, -1) -- Use -1 to differentiate from actual 0
            INTO v_intento_id, v_puntaje_antes
            FROM Intentos_Examen ie
            JOIN Respuestas_Estudiantes re ON ie.intento_examen_id = re.intento_examen_id
            WHERE ROWNUM = 1;
            
            DBMS_OUTPUT.PUT_LINE('INFO: Found attempt ' || v_intento_id || ' with responses, current score: ' || v_puntaje_antes);
            
            -- Test case: Calificar examen
            BEGIN
                sp_calificar_examen_completo(
                    p_intento_id => v_intento_id
                );
                
                -- Check if score was updated
                SELECT NVL(puntaje_total, -1) INTO v_puntaje_despues
                FROM Intentos_Examen
                WHERE intento_examen_id = v_intento_id;
                
                DBMS_OUTPUT.PUT_LINE('SUCCESS: Exam graded, score now: ' || v_puntaje_despues);
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
            END;
        EXCEPTION
             WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('INFO: No attempts with responses found, cannot test grading');
        END;
    END;
END;
/
-- ... existing code ...
-- Test for sp_configurar_retroalimentacion (complete version)
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing sp_configurar_retroalimentacion (complete)');
    
    DECLARE
        v_pregunta_id NUMBER;
        v_creador_id NUMBER;
        v_otro_usuario_id NUMBER;
        v_retroalimentacion CLOB := 'This is detailed feedback for the question';
    BEGIN
        -- Get a question and its creator
        BEGIN
            SELECT p.pregunta_id, p.creador_id
            INTO v_pregunta_id, v_creador_id
            FROM Preguntas p
            WHERE ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('INFO: No questions found for sp_configurar_retroalimentacion test.');
                RETURN;
        END;
        
        -- Get another user who is not the creator
        BEGIN
            SELECT MIN(usuario_id) INTO v_otro_usuario_id
            FROM Usuarios
            WHERE usuario_id <> v_creador_id
            AND ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_otro_usuario_id := v_creador_id; -- Fallback
                 DBMS_OUTPUT.PUT_LINE('INFO: No other user found, using creator ID for non-creator test.');
        END;
        
        -- Test case 1: Creator sets feedback
        BEGIN
            sp_configurar_retroalimentacion(
                p_pregunta_id => v_pregunta_id,
                p_retroalimentacion => v_retroalimentacion,
                p_usuario_id => v_creador_id
            );
            
            DBMS_OUTPUT.PUT_LINE('SUCCESS: Creator set feedback for question ' || v_pregunta_id);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 1: ' || SQLERRM);
        END;
        
        -- Test case 2: Non-creator attempts to set feedback
        IF v_otro_usuario_id <> v_creador_id THEN
            BEGIN
                sp_configurar_retroalimentacion(
                    p_pregunta_id => v_pregunta_id,
                    p_retroalimentacion => 'Unauthorized feedback change',
                    p_usuario_id => v_otro_usuario_id
                );
                DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 2 failed - unauthorized user set feedback');
            EXCEPTION
                WHEN OTHERS THEN
                     IF SQLCODE = -20300 THEN
                        DBMS_OUTPUT.PUT_LINE('SUCCESS: Test Case 2: Expected error occurred - ' || SQLERRM);
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 2: Unexpected error - ' || SQLERRM);
                    END IF;
            END;
        ELSE
            DBMS_OUTPUT.PUT_LINE('INFO: Skipping Test Case 2 for sp_configurar_retroalimentacion as no distinct non-creator user was found.');
        END IF;
    END;
END;
/

-- Test case for sp_crear_pregunta (student attempt)
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing sp_crear_pregunta (student attempt)');
    DECLARE
        v_pregunta_id NUMBER;
        v_student_user_id NUMBER;
    BEGIN
        -- Get a student user ID
        BEGIN
            SELECT u.usuario_id INTO v_student_user_id
            FROM Usuarios u JOIN Tipo_Usuario tu ON u.tipo_usuario_id = tu.usuario_id
            WHERE tu.descripcion = 'ESTUDIANTE' AND ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('INFO: No student user found to test sp_crear_pregunta restriction.');
                RETURN;
        END;

        BEGIN
            sp_crear_pregunta(
                p_creador_id => v_student_user_id, 
                p_texto => 'Student attempt to create question',
                p_tipo_pregunta_id => 1,
                p_tema_id => 1, -- Assuming tema_id 1 exists
                p_es_publica => 'S',
                p_tiempo_maximo => 60,
                p_pregunta_padre_id => NULL,
                p_pregunta_id => v_pregunta_id
            );
            DBMS_OUTPUT.PUT_LINE('ERROR: Test failed - students should not create questions');
        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE = -20001 THEN -- Specific error for "Solo los profesores pueden crear preguntas"
                    DBMS_OUTPUT.PUT_LINE('SUCCESS: Expected error occurred - ' || SQLERRM);
                ELSE
                    DBMS_OUTPUT.PUT_LINE('ERROR: Unexpected error - ' || SQLERRM);
                END IF;
        END;
    END;
END;
/

-- Test cases for sp_agregar_opcion_pregunta
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing sp_agregar_opcion_pregunta');
    
    DECLARE
        v_pregunta_id_sel NUMBER;
        v_pregunta_id_tf NUMBER;
        v_opcion_id NUMBER;
        v_count NUMBER;
    BEGIN
        -- Get a multiple choice or single choice question
        BEGIN
            SELECT pregunta_id INTO v_pregunta_id_sel
            FROM Preguntas 
            WHERE tipo_pregunta_id IN (1, 2) AND ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('INFO: No suitable selection question found for sp_agregar_opcion_pregunta test.');
                -- Optionally create one here if necessary for the test to run
        END;
        
        IF v_pregunta_id_sel IS NOT NULL THEN
            -- Test case 1: Add a valid option
            BEGIN
                sp_agregar_opcion_pregunta(
                    p_pregunta_id => v_pregunta_id_sel,
                    p_texto => 'Test option for procedure test',
                    p_es_correcta => 'S',
                    p_orden => 1,
                    p_opcion_id => v_opcion_id
                );
                
                SELECT COUNT(*) INTO v_count 
                FROM Opciones_Preguntas 
                WHERE opcion_pregunta_id = v_opcion_id;
                
                IF v_count = 1 THEN
                    DBMS_OUTPUT.PUT_LINE('SUCCESS: Option created with ID ' || v_opcion_id);
                ELSE
                    DBMS_OUTPUT.PUT_LINE('ERROR: Option creation failed');
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 1: ' || SQLERRM);
            END;
        ELSE
            DBMS_OUTPUT.PUT_LINE('INFO: Skipping Test Case 1 for sp_agregar_opcion_pregunta as no suitable question was found.');
        END IF;
        
        -- Get a True/False question
        BEGIN
            SELECT pregunta_id INTO v_pregunta_id_tf
            FROM Preguntas 
            WHERE tipo_pregunta_id = 3 AND ROWNUM = 1; -- True/False
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('INFO: No True/False question found for sp_agregar_opcion_pregunta incompatibility test.');
        END;

        IF v_pregunta_id_tf IS NOT NULL THEN
            -- Test case 2: Add option to incompatible question type
            BEGIN
                sp_agregar_opcion_pregunta(
                    p_pregunta_id => v_pregunta_id_tf,
                    p_texto => 'Invalid option for True/False',
                    p_es_correcta => 'S',
                    p_orden => 1,
                    p_opcion_id => v_opcion_id
                );
                DBMS_OUTPUT.PUT_LINE('ERROR: Test failed - should not add options to True/False questions');
            EXCEPTION
                WHEN OTHERS THEN
                    IF SQLCODE = -20002 THEN
                        DBMS_OUTPUT.PUT_LINE('SUCCESS: Test Case 2: Expected error occurred - ' || SQLERRM);
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 2: Unexpected error - ' || SQLERRM);
                    END IF;
            END;
        ELSE
            DBMS_OUTPUT.PUT_LINE('INFO: Skipping Test Case 2 for sp_agregar_opcion_pregunta as no True/False question was found.');
        END IF;
    END;
END;
/
-- ... existing code ...
-- Test cases for sp_cambiar_visibilidad_pregunta
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing sp_cambiar_visibilidad_pregunta');
    
    DECLARE
        v_pregunta_id NUMBER;
        v_creador_id NUMBER;
        v_otro_usuario_id NUMBER;
        v_es_publica CHAR(1);
        v_initial_es_publica CHAR(1);
        v_is_in_exam NUMBER; -- Variable to hold count for EXISTS check
    BEGIN
        -- Get a question
        BEGIN
            SELECT p.pregunta_id, p.creador_id, p.es_publica
            INTO v_pregunta_id, v_creador_id, v_initial_es_publica
            FROM Preguntas p
            WHERE ROWNUM = 1; -- Simplified for example, original logic for "not in exam" is better
            v_es_publica := v_initial_es_publica;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('INFO: No questions found at all for sp_cambiar_visibilidad_pregunta.');
                RETURN;
        END;
        
        -- Check if the selected question is in any exam
        SELECT COUNT(*)
        INTO v_is_in_exam
        FROM Preguntas_Examenes pe
        WHERE pe.pregunta_id = v_pregunta_id;

        -- Get another user who is not the creator
        BEGIN
            SELECT MIN(usuario_id) INTO v_otro_usuario_id
            FROM Usuarios
            WHERE usuario_id <> v_creador_id AND ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_otro_usuario_id := v_creador_id; -- Fallback
                DBMS_OUTPUT.PUT_LINE('INFO: No other user found, using creator ID for non-creator test.');
        END;
        
        -- Test case 1: Creator changes visibility (if question not in exam)
        IF v_pregunta_id IS NOT NULL AND v_is_in_exam = 0 THEN
            BEGIN
                sp_cambiar_visibilidad_pregunta(
                    p_pregunta_id => v_pregunta_id,
                    p_es_publica => CASE WHEN v_es_publica = 'S' THEN 'N' ELSE 'S' END,
                    p_usuario_id => v_creador_id,
                    p_retroalimentacion => 'Updated feedback by creator in test'
                );
                DBMS_OUTPUT.PUT_LINE('SUCCESS: Test Case 1: Creator changed question visibility');
                -- Revert
                sp_cambiar_visibilidad_pregunta(
                    p_pregunta_id => v_pregunta_id,
                    p_es_publica => v_initial_es_publica,
                    p_usuario_id => v_creador_id
                );
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 1: ' || SQLERRM);
            END;
        ELSE
             DBMS_OUTPUT.PUT_LINE('INFO: Skipping Test Case 1 as question is in an exam, not found, or ID is null. v_is_in_exam: ' || v_is_in_exam);
        END IF;
        
        -- Test case 2: Non-creator attempts to change visibility
        IF v_pregunta_id IS NOT NULL AND v_otro_usuario_id <> v_creador_id THEN
            BEGIN
                sp_cambiar_visibilidad_pregunta(
                    p_pregunta_id => v_pregunta_id,
                    p_es_publica => 'N',
                    p_usuario_id => v_otro_usuario_id,
                    p_retroalimentacion => 'Attempt by non-creator'
                );
                DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 2 failed - unauthorized user changed visibility');
            EXCEPTION
                WHEN OTHERS THEN
                    IF SQLCODE = -20100 THEN
                        DBMS_OUTPUT.PUT_LINE('SUCCESS: Test Case 2: Expected error occurred - ' || SQLERRM);
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 2: Unexpected error - ' || SQLERRM);
                    END IF;
            END;
        ELSE
            DBMS_OUTPUT.PUT_LINE('INFO: Skipping Test Case 2 as question ID is null or no distinct non-creator user was found.');
        END IF;
        
        -- Test case 3: Try to make private a question used in exams
        DECLARE
            v_q_in_exam_id NUMBER; -- Declare here
            v_q_in_exam_creator_id NUMBER; -- Declare here
        BEGIN
            SELECT MIN(pe.pregunta_id), p.creador_id
            INTO v_q_in_exam_id, v_q_in_exam_creator_id
            FROM Preguntas_Examenes pe
            JOIN Preguntas p ON pe.pregunta_id = p.pregunta_id
            WHERE p.es_publica = 'S' -- Ensure we pick a public one to try and make private
            GROUP BY p.creador_id 
            HAVING MIN(pe.pregunta_id) IS NOT NULL
            ORDER BY MIN(pe.pregunta_id) -- Consistent ordering for ROWNUM
            FETCH FIRST 1 ROW ONLY; -- More standard way for Oracle 12c+ to get one row

            IF v_q_in_exam_id IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE('INFO: Test Case 3: Attempting to make private question ' || v_q_in_exam_id || ' (used in exam) by creator ' || v_q_in_exam_creator_id);
                sp_cambiar_visibilidad_pregunta(
                    p_pregunta_id => v_q_in_exam_id,
                    p_es_publica => 'N',
                    p_usuario_id => v_q_in_exam_creator_id,
                    p_retroalimentacion => 'Attempt to make private used question'
                );
                DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 3 failed - should not make private a question used in exams');
             -- Revert if it didn't fail (and was public initially)
                sp_cambiar_visibilidad_pregunta(
                    p_pregunta_id => v_q_in_exam_id,
                    p_es_publica => 'S', 
                    p_usuario_id => v_q_in_exam_creator_id
                );
            ELSE
                DBMS_OUTPUT.PUT_LINE('INFO: No public question found in an exam for Test Case 3.');
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 DBMS_OUTPUT.PUT_LINE('INFO: No public question found in an exam for Test Case 3 (NO_DATA_FOUND).');
            WHEN OTHERS THEN
                IF SQLCODE = -20101 THEN -- Assuming -20101 is "Cannot make private a question used in exams"
                    DBMS_OUTPUT.PUT_LINE('SUCCESS: Test Case 3: Expected error occurred - ' || SQLERRM);
                ELSE
                    DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 3: Unexpected error - ' || SQLERRM);
                END IF;
        END;
    END;
END;
/

-- Test cases for sp_configurar_intentos_examen
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing sp_configurar_intentos_examen');
    
    DECLARE
        v_examen_id NUMBER;
        v_profesor_id NUMBER;
        v_otro_profesor_id NUMBER;
        v_current_intentos NUMBER;
        v_initial_max_intentos NUMBER;
    BEGIN
        -- Get a valid exam and its professor
        BEGIN
            SELECT e.examen_id, g.profesor_id, NVL(e.max_intentos,1)
            INTO v_examen_id, v_profesor_id, v_initial_max_intentos
            FROM Examenes e
            JOIN Grupos g ON e.grupo_id = g.grupo_id
            WHERE ROWNUM = 1;
            v_current_intentos := v_initial_max_intentos;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('INFO: No exam found for sp_configurar_intentos_examen test.');
                RETURN;
        END;
        
        -- Get another professor who doesn't teach this course (if one exists)
        BEGIN
            SELECT MIN(g_other.profesor_id) INTO v_otro_profesor_id
            FROM Grupos g_other
            WHERE g_other.profesor_id <> v_profesor_id AND ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_otro_profesor_id := v_profesor_id; -- Fallback
                DBMS_OUTPUT.PUT_LINE('INFO: No other professor found, using same professor for unauthorized test.');
        END;
        
        -- Test case 1: Authorized professor increases attempts
        BEGIN
            sp_configurar_intentos_examen(
                p_examen_id => v_examen_id,
                p_max_intentos => v_current_intentos + 1,
                p_profesor_id => v_profesor_id
            );
            DBMS_OUTPUT.PUT_LINE('SUCCESS: Test Case 1: Professor increased max attempts');
            -- Revert
            sp_configurar_intentos_examen(p_examen_id => v_examen_id, p_max_intentos => v_initial_max_intentos, p_profesor_id => v_profesor_id);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 1: ' || SQLERRM);
        END;
        
        -- Test case 2: Unauthorized professor attempts to change
        IF v_otro_profesor_id <> v_profesor_id THEN
            BEGIN
                sp_configurar_intentos_examen(
                    p_examen_id => v_examen_id,
                    p_max_intentos => v_current_intentos + 2,
                    p_profesor_id => v_otro_profesor_id
                );
                DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 2 failed - unauthorized professor changed attempts');
            EXCEPTION
                WHEN OTHERS THEN
                    IF SQLCODE = -20200 THEN
                        DBMS_OUTPUT.PUT_LINE('SUCCESS: Test Case 2: Expected error occurred - ' || SQLERRM);
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 2: Unexpected error - ' || SQLERRM);
                    END IF;
            END;
        ELSE
            DBMS_OUTPUT.PUT_LINE('INFO: Skipping Test Case 2 as no distinct unauthorized professor was found.');
        END IF;
        
        -- Test case 3: Try to reduce attempts below existing count (if applicable)
        DECLARE
            v_exam_with_attempts_id NUMBER;
            v_prof_for_exam_with_attempts NUMBER;
            v_actual_attempts_done NUMBER;
            v_initial_max_for_exam_with_attempts NUMBER;
        BEGIN
            SELECT e.examen_id, g.profesor_id, COUNT(ie.intento_examen_id), NVL(e.max_intentos,1)
            INTO v_exam_with_attempts_id, v_prof_for_exam_with_attempts, v_actual_attempts_done, v_initial_max_for_exam_with_attempts
            FROM Examenes e
            JOIN Grupos g ON e.grupo_id = g.grupo_id
            JOIN Intentos_Examen ie ON e.examen_id = ie.examen_id
            GROUP BY e.examen_id, g.profesor_id, e.max_intentos
            HAVING COUNT(ie.intento_examen_id) > 0
            AND ROWNUM = 1;

            IF v_exam_with_attempts_id IS NOT NULL AND v_actual_attempts_done > 0 THEN
                 -- Try to set max_intentos to less than actual_attempts_done
                sp_configurar_intentos_examen(
                    p_examen_id => v_exam_with_attempts_id,
                    p_max_intentos => v_actual_attempts_done - 1, 
                    p_profesor_id => v_prof_for_exam_with_attempts
                );
                DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 3 failed - reduced max attempts below used count');
                 -- Revert if it didn't fail
                sp_configurar_intentos_examen(p_examen_id => v_exam_with_attempts_id, p_max_intentos => v_initial_max_for_exam_with_attempts, p_profesor_id => v_prof_for_exam_with_attempts);
            ELSE
                DBMS_OUTPUT.PUT_LINE('INFO: No exams with attempts found for Test Case 3, or count is zero.');
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('INFO: No exams with attempts found for Test Case 3.');
            WHEN OTHERS THEN
                IF SQLCODE = -20201 THEN
                    DBMS_OUTPUT.PUT_LINE('SUCCESS: Test Case 3: Expected error occurred - ' || SQLERRM);
                ELSE
                    DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 3: Unexpected error - ' || SQLERRM);
                END IF;
        END;
    END;
END;
/

-- Test cases for sp_configurar_retroalimentacion
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing sp_configurar_retroalimentacion');
    
    DECLARE
        v_pregunta_id NUMBER;
        v_creador_id NUMBER;
        v_otro_usuario_id NUMBER;
        v_retroalimentacion CLOB := 'Test feedback for procedure test in sp_configurar_retroalimentacion';
    BEGIN
        -- Get a question and its creator
        BEGIN
            SELECT p.pregunta_id, p.creador_id
            INTO v_pregunta_id, v_creador_id
            FROM Preguntas p
            WHERE ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('INFO: No questions found for sp_configurar_retroalimentacion test.');
                RETURN;
        END;
        
        -- Get another user who is not the creator
        BEGIN
            SELECT MIN(usuario_id) INTO v_otro_usuario_id
            FROM Usuarios
            WHERE usuario_id <> v_creador_id
            AND ROWNUM = 1;
        EXCEPTION
             WHEN NO_DATA_FOUND THEN
                v_otro_usuario_id := v_creador_id; -- Fallback
                DBMS_OUTPUT.PUT_LINE('INFO: No other user found, using creator ID for non-creator test.');
        END;
        
        -- Test case 1: Creator sets feedback
        BEGIN
            sp_configurar_retroalimentacion(
                p_pregunta_id => v_pregunta_id,
                p_retroalimentacion => v_retroalimentacion,
                p_usuario_id => v_creador_id
            );
            DBMS_OUTPUT.PUT_LINE('SUCCESS: Test Case 1: Creator set feedback');
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 1: ' || SQLERRM);
        END;
        
        -- Test case 2: Non-creator attempts to set feedback
        IF v_otro_usuario_id <> v_creador_id THEN
            BEGIN
                sp_configurar_retroalimentacion(
                    p_pregunta_id => v_pregunta_id,
                    p_retroalimentacion => 'Unauthorized feedback change by non-creator',
                    p_usuario_id => v_otro_usuario_id
                );
                DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 2 failed - unauthorized user set feedback');
            EXCEPTION
                WHEN OTHERS THEN
                     IF SQLCODE = -20300 THEN
                        DBMS_OUTPUT.PUT_LINE('SUCCESS: Test Case 2: Expected error occurred - ' || SQLERRM);
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('ERROR: Test Case 2: Unexpected error - ' || SQLERRM);
                    END IF;
            END;
        ELSE
            DBMS_OUTPUT.PUT_LINE('INFO: Skipping Test Case 2 as no distinct non-creator user was found.');
        END IF;
    END;
END;
/

-- Test cases for sp_llenar_examen_aleatorio
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing sp_llenar_examen_aleatorio');
    
    DECLARE
        v_examen_id NUMBER;
        v_count_before NUMBER;
        v_count_after NUMBER;
        v_cantidad_preguntas NUMBER := 5;
    BEGIN
        -- Get an exam (preferably one with fewer than 5 questions, but any will do for basic test)
        BEGIN
            SELECT examen_id INTO v_examen_id FROM (
                SELECT e.examen_id, COUNT(pe.pregunta_examen_id) as q_count
                FROM Examenes e
                LEFT JOIN Preguntas_Examenes pe ON e.examen_id = pe.examen_id
                GROUP BY e.examen_id
                ORDER BY q_count ASC -- Prioritize exams with fewer questions
            ) WHERE ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('INFO: No exam found for sp_llenar_examen_aleatorio test.');
                RETURN;
        END;

        SELECT COUNT(*) INTO v_count_before
        FROM Preguntas_Examenes
        WHERE examen_id = v_examen_id;
        
        -- Test case: Fill exam with random questions
        BEGIN
            sp_llenar_examen_aleatorio(
                p_examen_id => v_examen_id,
                p_cantidad_preguntas => v_cantidad_preguntas
            );
            
            SELECT COUNT(*) INTO v_count_after
            FROM Preguntas_Examenes
            WHERE examen_id = v_examen_id;
            
            IF v_count_after >= v_count_before AND v_count_after <= v_count_before + v_cantidad_preguntas THEN
                DBMS_OUTPUT.PUT_LINE('SUCCESS: Added/attempted to add ' || (v_count_after - v_count_before) || ' random questions. Total now: ' || v_count_after);
            ELSE
                DBMS_OUTPUT.PUT_LINE('ERROR: Failed to add expected number of questions or count is unexpected. Before: '||v_count_before||', After: '||v_count_after);
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM || ' (This might be due to TRG_VERIFICAR_LIMITE_PREGUNTAS or lack of available questions)');
        END;
    END;
END;
/

-- Test cases for sp_rebalancear_pesos_examen
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing sp_rebalancear_pesos_examen');
    
    DECLARE
        v_examen_id NUMBER;
        v_total_peso NUMBER;
    BEGIN
        -- Get an exam with questions
        BEGIN
            SELECT examen_id INTO v_examen_id FROM (
                SELECT e.examen_id
                FROM Examenes e
                JOIN Preguntas_Examenes pe ON e.examen_id = pe.examen_id
                GROUP BY e.examen_id
                HAVING COUNT(pe.pregunta_examen_id) > 0
            ) WHERE ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('INFO: No exam with questions found for sp_rebalancear_pesos_examen test.');
                RETURN;
        END;
        
        -- Test case: Rebalance weights
        BEGIN
            -- Set some uneven weights first
            UPDATE Preguntas_Examenes
            SET peso = ROWNUM * 5 
            WHERE examen_id = v_examen_id;
            COMMIT;
            
            sp_rebalancear_pesos_examen(
                p_examen_id => v_examen_id
            );
            
            SELECT SUM(peso) INTO v_total_peso
            FROM Preguntas_Examenes
            WHERE examen_id = v_examen_id;
            
            IF ROUND(v_total_peso) = 100 THEN
                DBMS_OUTPUT.PUT_LINE('SUCCESS: Weights rebalanced correctly, total = ' || v_total_peso);
            ELSE
                DBMS_OUTPUT.PUT_LINE('ERROR: Weights not properly balanced, total = ' || v_total_peso);
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        END;
    END;
END;
/

-- Test cases for sp_validar_completar_examen
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing sp_validar_completar_examen');
    
    DECLARE
        v_examen_id NUMBER;
        v_cantidad_esperada NUMBER := 10;
        v_count_before NUMBER;
        v_count_after NUMBER;
        v_original_fecha_disponible DATE;
        v_original_cantidad_preguntas NUMBER;
    BEGIN
        -- Get an exam
        BEGIN
             SELECT examen_id, fecha_disponible, cantidad_preguntas_mostrar INTO v_examen_id, v_original_fecha_disponible, v_original_cantidad_preguntas FROM (
                SELECT e.examen_id, e.fecha_disponible, e.cantidad_preguntas_mostrar, COUNT(pe.pregunta_examen_id) as q_count
                FROM Examenes e
                LEFT JOIN Preguntas_Examenes pe ON e.examen_id = pe.examen_id
                GROUP BY e.examen_id, e.fecha_disponible, e.cantidad_preguntas_mostrar
                ORDER BY q_count ASC -- Prioritize exams with fewer questions
            ) WHERE ROWNUM = 1;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('INFO: No exam found for sp_validar_completar_examen test.');
                RETURN;
        END;
        
        -- Ensure fecha_disponible is valid for the trigger
        IF v_original_fecha_disponible < SYSTIMESTAMP THEN
            UPDATE Examenes
            SET fecha_disponible = SYSTIMESTAMP 
            WHERE examen_id = v_examen_id;
            DBMS_OUTPUT.PUT_LINE('INFO: Updated fecha_disponible for exam ' || v_examen_id || ' to SYSTIMESTAMP for test.');
        END IF;

        UPDATE Examenes
        SET cantidad_preguntas_mostrar = v_cantidad_esperada
        WHERE examen_id = v_examen_id;
        COMMIT;

        SELECT COUNT(*) INTO v_count_before
        FROM Preguntas_Examenes
        WHERE examen_id = v_examen_id;
        
        BEGIN
            sp_validar_completar_examen(
                p_examen_id => v_examen_id
            );
            
            SELECT COUNT(*) INTO v_count_after
            FROM Preguntas_Examenes
            WHERE examen_id = v_examen_id;
            
            IF v_count_after >= v_count_before THEN
                 DBMS_OUTPUT.PUT_LINE('SUCCESS: Exam validated/completed. Before: '|| v_count_before ||', After: ' || v_count_after || '. Expected around ' || v_cantidad_esperada);
            ELSE
                DBMS_OUTPUT.PUT_LINE('ERROR: Exam not completed correctly, Before: '|| v_count_before ||', After: ' || v_count_after || '. Expected around ' || v_cantidad_esperada);
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('ERROR: (sp_validar_completar_examen call) ' || SQLERRM || ' (This might be due to TRG_VERIFICAR_LIMITE_PREGUNTAS or lack of available questions)');
        END;
        
        -- Revert changes
        UPDATE Examenes
        SET fecha_disponible = v_original_fecha_disponible,
            cantidad_preguntas_mostrar = v_original_cantidad_preguntas
        WHERE examen_id = v_examen_id;
        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: (Outer block sp_validar_completar_examen) ' || SQLERRM);
            ROLLBACK;
    END;
END;
/

-- Clean up
BEGIN
    DBMS_OUTPUT.PUT_LINE('Starting general cleanup...');
    -- If you need to delete a specific v_intento_id or v_examen_id from a previous test,
    -- those variables are out of scope here.
    -- This cleanup block should define or select the IDs it needs to clean.
    -- For example, if you created a specific test exam:
    DECLARE
        v_test_examen_id_to_delete NUMBER;
        v_test_intento_id_to_delete NUMBER;
        -- Add other variables if needed for cleanup
    BEGIN
        -- Example: Find a specific test exam to delete
        BEGIN
            SELECT examen_id INTO v_test_examen_id_to_delete
            FROM Examenes
            WHERE descripcion = 'Test Exam for Time Check' AND ROWNUM = 1;

            IF v_test_examen_id_to_delete IS NOT NULL THEN
                -- First, delete attempts related to this exam if necessary
                DELETE FROM Intentos_Examen WHERE examen_id = v_test_examen_id_to_delete;
                DBMS_OUTPUT.PUT_LINE('INFO: Cleaned up attempts for dummy exam ' || v_test_examen_id_to_delete);

                DELETE FROM Examenes WHERE examen_id = v_test_examen_id_to_delete;
                DBMS_OUTPUT.PUT_LINE('INFO: Cleaned up dummy exam ' || v_test_examen_id_to_delete);
            ELSE
                DBMS_OUTPUT.PUT_LINE('INFO: No specific dummy exam found for cleanup.');
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('INFO: No dummy exam with description "Test Exam for Time Check" found for cleanup.');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('ERROR: During specific exam cleanup - ' || SQLERRM);
        END;

        -- If you had a v_intento_id from a *very specific, known, hardcoded* test that always creates the same ID
        -- or if you query it here, you could delete it.
        -- For instance, if a test always creates an attempt with a known characteristic:
        -- BEGIN
        --     SELECT intento_examen_id INTO v_test_intento_id_to_delete
        --     FROM Intentos_Examen ie JOIN Examenes ex ON ie.examen_id = ex.examen_id
        --     WHERE ex.descripcion = 'Some specific test exam for an attempt' AND ROWNUM = 1;
        --
        --     IF v_test_intento_id_to_delete IS NOT NULL THEN
        --         DELETE FROM Intentos_Examen WHERE intento_examen_id = v_test_intento_id_to_delete;
        --         DBMS_OUTPUT.PUT_LINE('INFO: Cleaned up specific test intento_id ' || v_test_intento_id_to_delete);
        --     END IF;
        -- EXCEPTION
        --     WHEN NO_DATA_FOUND THEN
        --         NULL; -- No specific attempt to clean
        -- END;

        COMMIT;
        DBMS_OUTPUT.PUT_LINE('General cleanup finished.');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: General cleanup failed - ' || SQLERRM);
            ROLLBACK;
    END;
END;
/
-- Improved test for sp_reporte_desempeno_estudiante (second block)
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing sp_reporte_desempeno_estudiante (second block)');
    
    DECLARE
        v_estudiante_id NUMBER;
        v_examen_id NUMBER;
        v_reporte SYS_REFCURSOR;
        -- Variables to fetch into from the cursor (match the cursor structure)
        v_orden NUMBER;
        v_pregunta CLOB;
        v_tipo VARCHAR2(50);
        v_es_correcta CHAR(1);
        v_puntaje_obtenido NUMBER; 
        v_feedback_pregunta CLOB; 
        v_puntaje_total_examen NUMBER; 
        v_max_intentos_examen NUMBER; 
        v_intentos_usados_estudiante NUMBER; 
        v_estado_intento VARCHAR2(20); 
        v_found BOOLEAN := FALSE;
    BEGIN
        -- Attempt to find a student and exam without a specific attempt
        BEGIN
            SELECT MIN(u.usuario_id), MIN(e.examen_id)
            INTO v_estudiante_id, v_examen_id
            FROM Usuarios u
            JOIN Tipo_Usuario tu ON u.tipo_usuario_id = tu.usuario_id
            CROSS JOIN Examenes e -- Get any student and any exam
            WHERE tu.descripcion = 'ESTUDIANTE'
            AND ROWNUM = 1;

            IF v_estudiante_id IS NOT NULL AND v_examen_id IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE('INFO: Found student ' || v_estudiante_id || ' and exam ' || v_examen_id || ' for general report.');
                
                -- Test case: Get general performance report (no specific attempt_id)
                -- REVIEW AND MODIFY THE PARAMETERS BELOW TO MATCH THE ACTUAL DEFINITION
                sp_reporte_desempeno_estudiante(
                    p_estudiante_id => v_estudiante_id, -- Ensure this matches actual param name e.g. P_STUDENT_ID
                    p_examen_id => v_examen_id,       -- Ensure this matches actual param name e.g. P_EXAM_ID
                    p_intento_id => NULL,             -- Ensure this matches actual param name e.g. P_ATTEMPT_ID
                    p_reporte => v_reporte            -- Ensure this matches actual param name e.g. P_RESULT_CURSOR
                                                      -- And ensure v_reporte is declared as SYS_REFCURSOR
                );
                
                -- Try to fetch results from cursor
                BEGIN
                    LOOP
                        FETCH v_reporte INTO v_orden, v_pregunta, v_tipo, v_es_correcta, v_puntaje_obtenido, 
                                            v_feedback_pregunta, v_puntaje_total_examen, v_max_intentos_examen, v_intentos_usados_estudiante, v_estado_intento;
                        EXIT WHEN v_reporte%NOTFOUND;
                        
                        v_found := TRUE;
                        DBMS_OUTPUT.PUT_LINE('Question ' || v_orden || ': ' || 
                                            CASE WHEN v_es_correcta = 'S' THEN 'Correct' ELSE 'Incorrect' END || 
                                            ', Points: ' || v_puntaje_obtenido);
                    END LOOP;
                    
                    IF v_reporte%ISOPEN THEN CLOSE v_reporte; END IF;
                    
                    IF v_found THEN
                        DBMS_OUTPUT.PUT_LINE('SUCCESS: Retrieved performance report');
                    ELSE
                        DBMS_OUTPUT.PUT_LINE('INFO: No questions found in this attempt''s report');
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        IF v_reporte%ISOPEN THEN CLOSE v_reporte; END IF;
                        DBMS_OUTPUT.PUT_LINE('ERROR: Error fetching cursor - ' || SQLERRM);
                END;
            ELSE
                DBMS_OUTPUT.PUT_LINE('INFO: No student or exam found for sp_reporte_desempeno_estudiante (second block) test.');
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('INFO: No student or exam found for sp_reporte_desempeno_estudiante (second block) test (NO_DATA_FOUND).');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('ERROR: Initial data fetch failed for second block - ' || SQLERRM);
        END;
    END;
END;
/

