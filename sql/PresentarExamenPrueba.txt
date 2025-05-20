-----------PRESENTAR UN EXAMEN-----------------

CREATE OR REPLACE PACKAGE PK_EXAMEN AS
  PROCEDURE presentar_examen(
    p_estudiante_id IN NUMBER,
    p_examen_id     IN NUMBER,
    p_ip_address    IN VARCHAR2,
    p_resultado     OUT VARCHAR2
  );
END PK_EXAMEN;

CREATE OR REPLACE PACKAGE BODY PK_EXAMEN AS

  -- Función para verificar si el estudiante está inscrito al grupo del examen
  FUNCTION esta_inscrito(p_estudiante_id NUMBER, p_grupo_id NUMBER) RETURN BOOLEAN IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_count
    FROM Inscripciones
    WHERE estudiante_id = p_estudiante_id AND grupo_id = p_grupo_id;
    RETURN v_count > 0;
  END;

  -- Función para contar intentos anteriores
  FUNCTION intentos_previos(p_estudiante_id NUMBER, p_examen_id NUMBER) RETURN NUMBER IS
    v_count NUMBER;
  BEGIN
    SELECT COUNT(*) INTO v_count
    FROM Intentos_Examen
    WHERE estudiante_id = p_estudiante_id AND examen_id = p_examen_id;
    RETURN v_count;
  END;

  -- Procedimiento para asignar preguntas de forma aleatoria y equilibrada
  PROCEDURE asignar_preguntas(
    p_examen_id IN NUMBER,
    p_intento_id IN NUMBER
  ) IS
    CURSOR c_preguntas IS
      SELECT pregunta_examen_id, pregunta_id, peso
      FROM Preguntas_Examenes
      WHERE examen_id = p_examen_id;

    v_id NUMBER;
  BEGIN
    FOR pregunta IN c_preguntas LOOP
      -- Aquí se podría extender con subpreguntas o preguntas compuestas
      -- La respuesta se inicializa como NULL y se considera incorrecta si no se responde
      INSERT INTO Respuestas_Estudiantes (
        respuesta_estudiante_id, es_correcta, puntaje_obtenido,
        intento_examen_id, pregunta_examen_id
      )
      VALUES (
        SEQ_RES_ESTUDIANTES.NEXTVAL, NULL, 0,
        p_intento_id, pregunta.pregunta_examen_id
      );
    END LOOP;
  END;

  -- Procedimiento para calificar el examen
  PROCEDURE calificar_examen(
    p_intento_id IN NUMBER
  ) IS
    CURSOR c_respuestas IS
      SELECT r.puntaje_obtenido, pe.peso
      FROM Respuestas_Estudiantes r
      JOIN Preguntas_Examenes pe ON r.pregunta_examen_id = pe.pregunta_examen_id
      WHERE r.intento_examen_id = p_intento_id;

    v_total_puntaje NUMBER := 0;
    v_total_peso    NUMBER := 0;
    v_puntaje_final NUMBER := 0;
  BEGIN
    FOR respuesta IN c_respuestas LOOP
      v_total_peso    := v_total_peso + respuesta.peso;
      v_total_puntaje := v_total_puntaje + respuesta.puntaje_obtenido;
    END LOOP;

    IF v_total_peso = 0 THEN
      v_puntaje_final := 0;
    ELSE
      -- Aplicar regla de tres si los pesos no suman 100
      v_puntaje_final := ROUND((v_total_puntaje * 100) / v_total_peso, 2);
    END IF;

    -- Actualizar intento con puntaje y tiempo
    UPDATE Intentos_Examen
    SET
      fecha_fin = SYSTIMESTAMP,
      tiempo_utilizado = ROUND((SYSTIMESTAMP - fecha_inicio) * 24 * 60), -- minutos
      puntaje_total = v_puntaje_final
    WHERE intento_examen_id = p_intento_id;
  END;

  -- Procedimiento principal
  PROCEDURE presentar_examen(
    p_estudiante_id IN NUMBER,
    p_examen_id     IN NUMBER,
    p_ip_address    IN VARCHAR2,
    p_resultado     OUT VARCHAR2
  ) IS
    v_fecha_actual      TIMESTAMP := SYSTIMESTAMP;
    v_fecha_disponible  TIMESTAMP;
    v_fecha_limite      TIMESTAMP;
    v_tiempo_limite     NUMBER;
    v_grupo_id          NUMBER;
    v_intentos          NUMBER;
    v_intento_id        NUMBER;
  BEGIN
    -- Obtener datos del examen
    SELECT fecha_disponible, fecha_limite, tiempo_limite, grupo_id
    INTO v_fecha_disponible, v_fecha_limite, v_tiempo_limite, v_grupo_id
    FROM Examenes
    WHERE examen_id = p_examen_id;

    -- Validar inscripción
    IF NOT esta_inscrito(p_estudiante_id, v_grupo_id) THEN
      p_resultado := 'ERROR: El estudiante no está inscrito al grupo.';
      RETURN;
    END IF;

    -- Validar rango de fechas
    IF v_fecha_actual NOT BETWEEN v_fecha_disponible AND v_fecha_limite THEN
      p_resultado := 'ERROR: El examen no está disponible en este momento.';
      RETURN;
    END IF;

    -- Validar intentos
    v_intentos := intentos_previos(p_estudiante_id, p_examen_id);
    IF v_intentos >= 3 THEN
      p_resultado := 'ERROR: Límite de intentos alcanzado.';
      RETURN;
    END IF;

    -- Crear intento
    SELECT NVL(MAX(intento_examen_id), 0) + 1 INTO v_intento_id FROM Intentos_Examen;

    INSERT INTO Intentos_Examen (
      intento_examen_id, fecha_inicio, fecha_fin,
      tiempo_utilizado, puntaje_total, ip_address,
      estudiante_id, examen_id
    )
    VALUES (
      v_intento_id, v_fecha_actual, NULL,
      0, NULL, p_ip_address,
      p_estudiante_id, p_examen_id
    );

    -- Asignar preguntas
    asignar_preguntas(p_examen_id, v_intento_id);

    p_resultado := 'EXITO: Intento creado. ID = ' || v_intento_id;

    -- Aquí, luego de que el estudiante conteste, se invoca la calificación:
    calificar_examen(v_intento_id);

  EXCEPTION
    WHEN OTHERS THEN
      p_resultado := 'ERROR: ' || SQLERRM;
  END;

END PK_EXAMEN;