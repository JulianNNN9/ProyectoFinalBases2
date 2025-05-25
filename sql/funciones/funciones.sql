/*==============================================================*/
/* FUNCTIONS                                                     */
/*==============================================================*/

-- Función para validar asignación del profesor al curso
CREATE OR REPLACE FUNCTION fn_profesor_pertenece_curso(
  p_profesor_id IN NUMBER,
  p_grupo_id IN NUMBER
) RETURN BOOLEAN IS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM Grupos
  WHERE grupo_id = p_grupo_id AND profesor_id = p_profesor_id;
  
  RETURN v_count > 0;
END;
/

-- Función para validar que una pregunta pertenece a los temas del curso del examen
CREATE OR REPLACE FUNCTION fn_pregunta_pertenece_examen(
  p_pregunta_id IN NUMBER,
  p_examen_id IN NUMBER
) RETURN BOOLEAN IS
  v_count NUMBER;
  v_padre_id NUMBER;
  v_padre_pertenece BOOLEAN := FALSE;
BEGIN
  -- Primero verificar si es una subpregunta
  SELECT pregunta_padre_id
  INTO v_padre_id
  FROM Preguntas
  WHERE pregunta_id = p_pregunta_id
  AND pregunta_padre_id IS NOT NULL;
  
  -- Si tiene padre, verificar si el padre pertenece al examen
  IF v_padre_id IS NOT NULL THEN
    -- Verificar si el padre pertenece a los temas del curso
    SELECT COUNT(*)
    INTO v_count
    FROM Preguntas p
    JOIN Temas t ON p.tema_id = t.tema_id
    JOIN Unidades_Temas ut ON t.tema_id = ut.tema_id
    JOIN Unidades u ON ut.unidad_id = u.unidad_id
    JOIN Cursos c ON u.curso_id = c.curso_id
    JOIN Grupos g ON c.curso_id = g.curso_id
    JOIN Examenes e ON g.grupo_id = e.grupo_id
    WHERE p.pregunta_id = v_padre_id
    AND e.examen_id = p_examen_id;
    
    v_padre_pertenece := (v_count > 0);
    
    -- Si el padre pertenece, la subpregunta también pertenece
    IF v_padre_pertenece THEN
      RETURN TRUE;
    END IF;
  END IF;
  
  -- Verificar si la pregunta pertenece directamente a algún tema del curso
  SELECT COUNT(*)
  INTO v_count
  FROM Preguntas p
  JOIN Temas t ON p.tema_id = t.tema_id
  JOIN Unidades_Temas ut ON t.tema_id = ut.tema_id
  JOIN Unidades u ON ut.unidad_id = u.unidad_id
  JOIN Cursos c ON u.curso_id = c.curso_id
  JOIN Grupos g ON c.curso_id = g.curso_id
  JOIN Examenes e ON g.grupo_id = e.grupo_id
  WHERE p.pregunta_id = p_pregunta_id
  AND e.examen_id = p_examen_id;
  
  RETURN v_count > 0;
END;
/

-- Verificar elegibilidad del estudiante
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

-- Calificar preguntas de opción única
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

-- Calificar preguntas de opción múltiple
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

-- Calificar preguntas de verdadero/falso
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

-- Calificar preguntas de ordenamiento
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

-- Calificar preguntas de emparejamiento
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

-- Calificar preguntas de completar
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

-- Calcular puntaje para preguntas compuestas
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

-- Procedimiento para autenticar usuario (corregido para usar email)
CREATE OR REPLACE FUNCTION autenticar_usuario(
  p_email IN VARCHAR2,
  p_password IN VARCHAR2
) RETURN SYS_REFCURSOR IS
  v_cursor SYS_REFCURSOR;
  v_password VARCHAR2(100);
  v_count NUMBER;
BEGIN
  -- Verificar si el usuario existe
  SELECT COUNT(*) INTO v_count 
  FROM USUARIOS 
  WHERE EMAIL = p_email;
  
  IF v_count = 0 THEN
    -- Usuario no existe, devolver cursor vacío
    OPEN v_cursor FOR 
      SELECT NULL, NULL, NULL, NULL, NULL, NULL FROM dual WHERE 1=0;
    RETURN v_cursor;
  END IF;
  
  -- Obtener contraseña almacenada
  SELECT CONTRASENIA INTO v_password 
  FROM USUARIOS 
  WHERE EMAIL = p_email;
  
  -- Verificar si la contraseña coincide
  IF v_password = p_password THEN
    -- Credenciales válidas, devolver datos del usuario
    OPEN v_cursor FOR 
      SELECT 
        u.USUARIO_ID, 
        u.EMAIL as username, 
        u.NOMBRE, 
        u.APELLIDO, 
        u.EMAIL,
        CASE 
          WHEN EXISTS (SELECT 1 FROM GRUPOS g WHERE g.PROFESOR_ID = u.USUARIO_ID) THEN 'professor'
          ELSE 'student'
        END as role
      FROM USUARIOS u
      WHERE u.EMAIL = p_email;
  ELSE
    -- Contraseña inválida, devolver cursor vacío
    OPEN v_cursor FOR 
      SELECT NULL, NULL, NULL, NULL, NULL, NULL FROM dual WHERE 1=0;
  END IF;
  
  RETURN v_cursor;
END;
/

-- Función para verificar si una pregunta es elegible para un examen
CREATE OR REPLACE FUNCTION fn_verificar_elegibilidad_pregunta(
    p_pregunta_id IN NUMBER,
    p_examen_id IN NUMBER
) RETURN BOOLEAN AS
    v_tema_id NUMBER;
    v_curso_id NUMBER;
    v_es_elegible NUMBER := 0;
BEGIN
    -- Obtener el tema de la pregunta
    SELECT tema_id INTO v_tema_id 
    FROM Preguntas 
    WHERE pregunta_id = p_pregunta_id;
    
    -- Obtener el curso del examen
    SELECT c.curso_id INTO v_curso_id
    FROM Examenes e
    JOIN Grupos g ON e.grupo_id = g.grupo_id
    JOIN Cursos c ON g.curso_id = c.curso_id
    WHERE e.examen_id = p_examen_id;
    
    -- Verificar si el tema está en el curso
    SELECT COUNT(*) INTO v_es_elegible
    FROM Unidades u
    JOIN Unidades_Temas ut ON u.unidad_id = ut.unidad_id
    WHERE u.curso_id = v_curso_id
    AND ut.tema_id = v_tema_id;
    
    RETURN v_es_elegible > 0;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END fn_verificar_elegibilidad_pregunta;

/