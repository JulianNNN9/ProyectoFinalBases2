create or replace NONEDITIONABLE TRIGGER trg_agregar_subpreguntas_examen
AFTER INSERT ON Preguntas_Examenes
FOR EACH ROW
DECLARE
    v_siguiente_orden NUMBER;
    v_peso_subpregunta NUMBER;
    v_count NUMBER := 0;
BEGIN
    -- Verificar si la pregunta insertada tiene subpreguntas
    SELECT COUNT(*)
    INTO v_count
    FROM Preguntas
    WHERE pregunta_padre_id = :NEW.pregunta_id;

    -- Si tiene subpreguntas, agregarlas al examen
    IF v_count > 0 THEN
        -- Obtener el siguiente orden (después de la pregunta principal)
        v_siguiente_orden := :NEW.orden + 1;

        -- Calcular peso para distribuir entre subpreguntas (50% del peso original)
        -- La pregunta principal mantendrá el otro 50%
        v_peso_subpregunta := :NEW.peso / 2 / v_count;

        -- Actualizar el peso de la pregunta principal
        UPDATE Preguntas_Examenes
        SET peso = :NEW.peso / 2
        WHERE pregunta_examen_id = :NEW.pregunta_examen_id;

        -- Insertar todas las subpreguntas
        INSERT INTO Preguntas_Examenes (
            pregunta_examen_id,
            peso,
            orden,
            pregunta_id,
            examen_id
        )
        SELECT 
            SQ_PREGUNTA_EXAMEN_ID.NEXTVAL,
            v_peso_subpregunta,
            v_siguiente_orden + ROWNUM - 1,
            pregunta_id,
            :NEW.examen_id
        FROM (
            SELECT p.pregunta_id
            FROM Preguntas p
            WHERE p.pregunta_padre_id = :NEW.pregunta_id
            AND NOT EXISTS (
                -- Evitar duplicados (aunque el trigger trg_evitar_preguntas_duplicadas también lo maneja)
                SELECT 1 FROM Preguntas_Examenes pe
                WHERE pe.pregunta_id = p.pregunta_id
                AND pe.examen_id = :NEW.examen_id
            )
            ORDER BY p.pregunta_id  -- Orden consistente
        );

        -- Actualizar orden para las preguntas que vengan después
        UPDATE Preguntas_Examenes
        SET orden = orden + v_count
        WHERE examen_id = :NEW.examen_id
        AND orden > :NEW.orden
        AND pregunta_examen_id != :NEW.pregunta_examen_id;
    END IF;
END;



/


create or replace NONEDITIONABLE TRIGGER trg_completar_examen
AFTER UPDATE ON Examenes
FOR EACH ROW
WHEN (NEW.fecha_disponible IS NOT NULL AND 
     (OLD.fecha_disponible IS NULL OR NEW.max_intentos != OLD.max_intentos))
BEGIN
    -- Si se está configurando la fecha disponible o cambiando max_intentos,
    -- asumir que está listo para publicar y validar/completar el examen
    sp_validar_completar_examen(:NEW.examen_id);
END;

/

create or replace NONEDITIONABLE TRIGGER trg_evitar_preguntas_duplicadas
FOR INSERT ON Preguntas_Examenes
COMPOUND TRIGGER

-- Variables a nivel del trigger
v_duplicado NUMBER;

-- Antes del statement
BEFORE STATEMENT IS
BEGIN
    -- Limpiar tabla temporal
    DELETE FROM temp_preguntas_examen;

    -- Insertar preguntas existentes
    INSERT INTO temp_preguntas_examen (examen_id, pregunta_id)
    SELECT examen_id, pregunta_id
    FROM Preguntas_Examenes;
END BEFORE STATEMENT;

-- Antes de cada row
BEFORE EACH ROW IS
BEGIN
    -- Verificar si la pregunta ya existe usando la tabla temporal
    SELECT COUNT(*)
    INTO v_duplicado
    FROM temp_preguntas_examen 
    WHERE examen_id = :NEW.examen_id 
    AND pregunta_id = :NEW.pregunta_id;

    IF v_duplicado > 0 THEN
        raise_application_error(-20001, 'La pregunta ya existe en este examen');
    END IF;

    -- Insertar la nueva pregunta en la tabla temporal
    INSERT INTO temp_preguntas_examen (examen_id, pregunta_id)
    VALUES (:NEW.examen_id, :NEW.pregunta_id);
END BEFORE EACH ROW;

END trg_evitar_preguntas_duplicadas;


/
create or replace NONEDITIONABLE TRIGGER trg_examenes_before_insert
BEFORE INSERT ON Examenes
FOR EACH ROW
BEGIN
    -- Asignar ID automáticamente si es NULL
    IF :NEW.examen_id IS NULL THEN
        SELECT seq_examenes.NEXTVAL INTO :NEW.examen_id FROM dual;
    END IF;

    -- Establecer fecha de creación automáticamente
    IF :NEW.fecha_creacion IS NULL THEN
        :NEW.fecha_creacion := SYSTIMESTAMP;
    END IF;

    -- Valores por defecto para umbral de aprobación
    IF :NEW.umbral_aprobacion IS NULL THEN
        :NEW.umbral_aprobacion := 60;
    END IF;
END;



/

create or replace NONEDITIONABLE TRIGGER trg_restringir_modificacion_examen
BEFORE UPDATE ON Examenes
FOR EACH ROW
DECLARE
  v_intentos NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_intentos
  FROM Intentos_Examen
  WHERE examen_id = :OLD.examen_id;

  IF v_intentos > 0 THEN
    RAISE_APPLICATION_ERROR(-20007, 'No se puede modificar un examen que ya tiene presentaciones');
  END IF;
END;


/

create or replace NONEDITIONABLE TRIGGER trg_restringir_modificacion_pregunta
BEFORE UPDATE ON Preguntas
FOR EACH ROW
DECLARE
  v_examen_count NUMBER;
  v_intentos_count NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_intentos_count
  FROM Preguntas_Examenes pe
  JOIN Intentos_Examen ie ON pe.examen_id = ie.examen_id
  WHERE pe.pregunta_id = :OLD.pregunta_id;

  IF v_intentos_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20008, 'No se puede modificar una pregunta usada en exámenes ya presentados');
  END IF;
END;



/

create or replace NONEDITIONABLE TRIGGER trg_validar_cambio_visibilidad
BEFORE UPDATE OF es_publica ON Preguntas
FOR EACH ROW
DECLARE
    v_examenes_publicos NUMBER;
BEGIN
    -- Si se está cambiando de pública a privada
    IF :OLD.es_publica = 'S' AND :NEW.es_publica = 'N' THEN
        -- Verificar si está siendo usada en exámenes activos
        SELECT COUNT(*) INTO v_examenes_publicos
        FROM Preguntas_Examenes pe
        JOIN Examenes e ON pe.examen_id = e.examen_id
        WHERE pe.pregunta_id = :OLD.pregunta_id
        AND e.fecha_disponible <= SYSTIMESTAMP
        AND (e.fecha_limite >= SYSTIMESTAMP OR e.fecha_limite IS NULL);

        -- No permitir cambiar a privada si está siendo usada en exámenes activos
        IF v_examenes_publicos > 0 THEN
            RAISE_APPLICATION_ERROR(-20102, 'No se puede cambiar a privada una pregunta en uso en exámenes activos');
        END IF;
    END IF;
END;



/

create or replace NONEDITIONABLE TRIGGER trg_validar_examen_creacion
BEFORE INSERT OR UPDATE ON Examenes
FOR EACH ROW
DECLARE
  v_profesor_valido BOOLEAN;
BEGIN
  -- Validar que la fecha límite no sea anterior a la fecha disponible
  IF :NEW.fecha_limite < :NEW.fecha_disponible THEN
    RAISE_APPLICATION_ERROR(-20002, 'La fecha límite no puede ser anterior a la fecha disponible');
  END IF;

  -- Validar que la fecha disponible no sea anterior a la fecha actual
  IF :NEW.fecha_disponible < SYSTIMESTAMP THEN
    RAISE_APPLICATION_ERROR(-20003, 'La fecha disponible no puede ser anterior a la fecha actual');
  END IF;

  -- Validar que el profesor pertenezca al grupo
  v_profesor_valido := fn_profesor_pertenece_curso(:NEW.creador_id, :NEW.grupo_id);

  IF NOT v_profesor_valido THEN
    RAISE_APPLICATION_ERROR(-20004, 'El profesor no está asignado a este grupo');
  END IF;
END;

/

create or replace NONEDITIONABLE TRIGGER trg_validar_peso_pregunta
BEFORE INSERT OR UPDATE ON Preguntas_Examenes
FOR EACH ROW
DECLARE
    v_total_preguntas NUMBER;
BEGIN
    -- Si el peso es NULL o 0, asignar un valor por defecto
    IF :NEW.peso IS NULL OR :NEW.peso = 0 THEN
        -- Contar preguntas actuales en el examen
        SELECT COUNT(*) + 1 -- +1 para incluir esta nueva pregunta
        INTO v_total_preguntas
        FROM Preguntas_Examenes
        WHERE examen_id = :NEW.examen_id;
        -- Asignar peso equitativo
        :NEW.peso := 100 / v_total_preguntas;
    END IF;
END;



/

create or replace NONEDITIONABLE TRIGGER trg_validar_pregunta_tema_examen
BEFORE INSERT ON Preguntas_Examenes
FOR EACH ROW
DECLARE
  v_pertenece BOOLEAN;
  v_retroalimentacion CLOB;
BEGIN
  -- Verificar que la pregunta pertenezca a los temas del curso del examen
  v_pertenece := fn_pregunta_pertenece_examen(:NEW.pregunta_id, :NEW.examen_id);

  IF NOT v_pertenece THEN
    RAISE_APPLICATION_ERROR(-20007, 'La pregunta no pertenece a los temas del curso asociado al examen');
  END IF;

  -- Verificar si la pregunta tiene retroalimentación
  BEGIN
    SELECT retroalimentacion
    INTO v_retroalimentacion
    FROM Preguntas
    WHERE pregunta_id = :NEW.pregunta_id;

    -- Advertencia si no hay retroalimentación (podría usar un log en lugar de dbms_output)
    IF v_retroalimentacion IS NULL THEN
      dbms_output.put_line('Advertencia: La pregunta ' || :NEW.pregunta_id || 
                           ' no tiene retroalimentación definida');
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20009, 'La pregunta especificada no existe');
  END;
END;

/

create or replace NONEDITIONABLE TRIGGER trg_validar_tiempo_examen
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

create or replace NONEDITIONABLE TRIGGER trg_verificar_limite_preguntas_row
BEFORE INSERT ON Preguntas_Examenes
FOR EACH ROW
DECLARE
    v_total_preguntas NUMBER;
    v_limite_preguntas NUMBER;
BEGIN
    -- Obtener valores de la tabla temporal
    SELECT total_preguntas, limite_preguntas
    INTO v_total_preguntas, v_limite_preguntas
    FROM temp_pregunta_count
    WHERE examen_id = :NEW.examen_id;

    -- Si no existe en la tabla temporal, obtener valores directamente
    IF v_total_preguntas IS NULL THEN
        SELECT COUNT(*), e.cantidad_preguntas_mostrar
        INTO v_total_preguntas, v_limite_preguntas
        FROM Examenes e
        LEFT JOIN Preguntas_Examenes pe ON e.examen_id = pe.examen_id
        WHERE e.examen_id = :NEW.examen_id
        GROUP BY e.cantidad_preguntas_mostrar;
    END IF;

    -- Verificar si excede el límite
    IF v_limite_preguntas IS NOT NULL AND v_total_preguntas >= v_limite_preguntas THEN
        RAISE_APPLICATION_ERROR(-20002, 
            'No se pueden agregar más preguntas. Límite alcanzado (' || 
            v_total_preguntas || '/' || v_limite_preguntas || ').');
    END IF;
END;

/

create or replace NONEDITIONABLE TRIGGER trg_verificar_limite_preguntas_stmt
BEFORE INSERT ON Preguntas_Examenes
DECLARE
    CURSOR c_examenes IS
        SELECT e.examen_id, 
               COUNT(pe.pregunta_examen_id) as total_preguntas,
               e.cantidad_preguntas_mostrar as limite_preguntas
        FROM Examenes e
        LEFT JOIN Preguntas_Examenes pe ON e.examen_id = pe.examen_id
        GROUP BY e.examen_id, e.cantidad_preguntas_mostrar;
BEGIN
    -- Limpiar tabla temporal
    DELETE FROM temp_pregunta_count;

    -- Insertar conteos actuales
    FOR r IN c_examenes LOOP
        INSERT INTO temp_pregunta_count (examen_id, total_preguntas, limite_preguntas)
        VALUES (r.examen_id, r.total_preguntas, r.limite_preguntas);
    END LOOP;
END;

/

create or replace NONEDITIONABLE TRIGGER trg_bloquear_edicion_examen
BEFORE UPDATE ON Examenes
FOR EACH ROW
DECLARE
    v_intentos_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_intentos_count
    FROM Intentos_Examen
    WHERE examen_id = :OLD.examen_id;

    IF v_intentos_count > 0 AND (
        :NEW.fecha_disponible <> :OLD.fecha_disponible OR
        :NEW.fecha_limite <> :OLD.fecha_limite OR
        :NEW.tiempo_limite <> :OLD.tiempo_limite OR
        :NEW.cantidad_preguntas_mostrar <> :OLD.cantidad_preguntas_mostrar
    ) THEN
        RAISE_APPLICATION_ERROR(-20001, 'No se puede modificar un examen que ya tiene intentos registrados');
    END IF;
END;
