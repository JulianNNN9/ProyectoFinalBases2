-- Función para verificar elegibilidad del estudiante
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

-- Trigger para validar tiempo durante el examen
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

-- Procedimiento para calificar examen
CREATE OR REPLACE PROCEDURE sp_calificar_examen(
  p_intento_examen_id IN NUMBER
) AS
  v_examen_id NUMBER;
  v_total_peso NUMBER := 0;
  v_puntaje_obtenido NUMBER := 0;
  v_puntaje_final NUMBER;
BEGIN
  -- Obtener el examen
  SELECT examen_id INTO v_examen_id
  FROM Intentos_Examen
  WHERE intento_examen_id = p_intento_examen_id;
  
  -- Calcular el peso total de las preguntas
  SELECT SUM(pe.peso)
  INTO v_total_peso
  FROM Preguntas_Examenes pe
  WHERE pe.examen_id = v_examen_id;
  
  -- Calcular puntaje obtenido
  SELECT COALESCE(SUM(re.puntaje_obtenido), 0)
  INTO v_puntaje_obtenido
  FROM Respuestas_Estudiantes re
  JOIN Preguntas_Examenes pe ON re.pregunta_examen_id = pe.pregunta_examen_id
  WHERE re.intento_examen_id = p_intento_examen_id;
  
  -- Calcular puntaje final (regla de tres)
  IF v_total_peso > 0 THEN
    -- Si el peso total es mayor a 100, normalizar
    IF v_total_peso > 100 THEN
      v_puntaje_final := (v_puntaje_obtenido / v_total_peso) * 100;
    ELSE
      v_puntaje_final := v_puntaje_obtenido;
    END IF;
  ELSE
    v_puntaje_final := 0;
  END IF;
  
  -- Actualizar el intento del examen
  UPDATE Intentos_Examen
  SET puntaje_total = v_puntaje_final,
      fecha_fin = SYSTIMESTAMP
  WHERE intento_examen_id = p_intento_examen_id;
  
  COMMIT;
END;
/