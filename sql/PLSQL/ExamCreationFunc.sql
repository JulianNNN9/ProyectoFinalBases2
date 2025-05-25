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

-- Procedimiento para agregar preguntas al examen de forma equilibrada
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
  END LOOP;
  
  -- Si no hay temas, salir
  IF v_total_temas = 0 THEN
    RAISE_APPLICATION_ERROR(-20005, 'No hay temas disponibles para este examen');
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

-- Trigger para verificar que no se exceda el límite de preguntas en un examen
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

-- Procedimiento para llenar un examen con preguntas aleatorias
CREATE OR REPLACE PROCEDURE sp_llenar_examen_aleatorio(
    p_examen_id IN NUMBER,
    p_cantidad_preguntas IN NUMBER
) AS
    v_preguntas_disponibles NUMBER;
    v_tema_id NUMBER;
    v_siguiente_id NUMBER;
BEGIN
    -- Obtener el tema del curso asociado al examen
    SELECT t.tema_id INTO v_tema_id
    FROM Examenes e
    JOIN Grupos g ON e.grupo_id = g.grupo_id
    JOIN Cursos c ON g.curso_id = c.curso_id
    JOIN Unidades u ON c.curso_id = u.curso_id
    JOIN Unidades_Temas ut ON u.unidad_id = ut.unidad_id
    JOIN Temas t ON ut.tema_id = t.tema_id
    WHERE e.examen_id = p_examen_id
    AND ROWNUM = 1;
    
    -- Verificar si hay suficientes preguntas disponibles
    SELECT COUNT(*)
    INTO v_preguntas_disponibles
    FROM Preguntas
    WHERE tema_id = v_tema_id
    AND es_publica = 'S';
    
    IF v_preguntas_disponibles < p_cantidad_preguntas THEN
        RAISE_APPLICATION_ERROR(-20001, 'No hay suficientes preguntas disponibles para el examen');
        RETURN;
    END IF;
    
    -- Obtener el siguiente ID para pregunta_examen
    SELECT NVL(MAX(pregunta_examen_id), 0) + 1
    INTO v_siguiente_id
    FROM Preguntas_Examenes;
    
    -- Insertar preguntas aleatorias
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
        SELECT pregunta_id
        FROM Preguntas
        WHERE tema_id = v_tema_id
        AND es_publica = 'S'
        AND pregunta_id NOT IN (
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