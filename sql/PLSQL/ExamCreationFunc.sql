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

-- Función para validar que una pregunta pertenece a los temas del curso del examen
CREATE OR REPLACE FUNCTION fn_pregunta_pertenece_examen(
  p_pregunta_id IN NUMBER,
  p_examen_id IN NUMBER
) RETURN BOOLEAN IS
  v_count NUMBER;
BEGIN
  -- Verificar si la pregunta pertenece a algún tema del curso asociado al examen
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

-- Trigger para agregar automáticamente subpreguntas cuando se agrega una pregunta compuesta
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

-- Modificar la función fn_pregunta_pertenece_examen para considerar preguntas compuestas
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

-- Trigger para prevenir preguntas sin peso definido
CREATE OR REPLACE TRIGGER trg_validar_peso_pregunta
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

-- Procedimiento para rebalancear pesos de preguntas en un examen
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