/*==============================================================*/
/* TRIGGERS                                                      */
/*==============================================================*/

-- Trigger para validar asignación de profesor y fechas del examen
CREATE OR REPLACE TRIGGER trg_validar_examen_creacion
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

-- Trigger para asignar ID automáticamente y establecer valores por defecto
CREATE OR REPLACE TRIGGER trg_examenes_before_insert
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

-- Trigger para evitar preguntas duplicadas en examen
CREATE OR REPLACE TRIGGER trg_evitar_preguntas_duplicadas
BEFORE INSERT ON Preguntas_Examenes
FOR EACH ROW
DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_count
  FROM Preguntas_Examenes
  WHERE pregunta_id = :NEW.pregunta_id
  AND examen_id = :NEW.examen_id;
  
  IF v_count > 0 THEN
    RAISE_APPLICATION_ERROR(-20006, 'La pregunta ya existe en este examen');
  END IF;
END;
/

-- Trigger para verificar que no se exceda el límite de preguntas
CREATE OR REPLACE TRIGGER trg_verificar_limite_preguntas
BEFORE INSERT ON Preguntas_Examenes
FOR EACH ROW
DECLARE
    v_total_preguntas NUMBER;
    v_limite_preguntas NUMBER;
BEGIN
    -- Obtener cantidad actual de preguntas
    SELECT COUNT(*)
    INTO v_total_preguntas
    FROM Preguntas_Examenes
    WHERE examen_id = :NEW.examen_id;
    
    -- Obtener límite configurado
    SELECT cantidad_preguntas_mostrar
    INTO v_limite_preguntas
    FROM Examenes
    WHERE examen_id = :NEW.examen_id;
    
    -- Verificar si excede el límite (solo si hay un límite configurado)
    IF v_limite_preguntas IS NOT NULL AND v_total_preguntas >= v_limite_preguntas THEN
        RAISE_APPLICATION_ERROR(-20002, 'No se pueden agregar más preguntas. Límite alcanzado.');
    END IF;
END;
/

-- Trigger para validar que las preguntas pertenezcan al tema del examen
CREATE OR REPLACE TRIGGER trg_validar_pregunta_tema_examen
BEFORE INSERT ON Preguntas_Examenes
FOR EACH ROW
DECLARE
  v_pertenece BOOLEAN;
BEGIN
  -- Verificar que la pregunta pertenezca a los temas del curso del examen
  v_pertenece := fn_pregunta_pertenece_examen(:NEW.pregunta_id, :NEW.examen_id);
  
  IF NOT v_pertenece THEN
    RAISE_APPLICATION_ERROR(-20007, 'La pregunta no pertenece a los temas del curso asociado al examen');
  END IF;
END;
/

-- Trigger para agregar automáticamente subpreguntas
CREATE OR REPLACE TRIGGER trg_agregar_subpreguntas_examen
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

-- Trigger para validar y completar exámenes automáticamente al finalizar edición
CREATE OR REPLACE TRIGGER trg_completar_examen
AFTER UPDATE ON Examenes
FOR EACH ROW
WHEN (NEW.fecha_disponible IS NOT NULL AND OLD.fecha_disponible IS NULL)
BEGIN
    -- Si se está configurando la fecha disponible, asumir que está listo para publicar
    -- y validar/completar el examen
    sp_validar_completar_examen(:NEW.examen_id);
END;
/

-- Validar tiempo durante el examen
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

-- Trigger para prevenir modificaciones de un examen con intentos
CREATE OR REPLACE TRIGGER trg_restringir_modificacion_examen
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

-- Trigger para prevenir modificaciones de preguntas usadas en exámenes
CREATE OR REPLACE TRIGGER trg_restringir_modificacion_pregunta
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

-- Trigger para prevenir la modificación de exámenes activos
CREATE OR REPLACE TRIGGER trg_bloquear_edicion_examen
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
/

create or replace TRIGGER trg_validar_peso_pregunta
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

-- Trigger para validar cambios de visibilidad en preguntas
CREATE OR REPLACE TRIGGER trg_validar_cambio_visibilidad
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