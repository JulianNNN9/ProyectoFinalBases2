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