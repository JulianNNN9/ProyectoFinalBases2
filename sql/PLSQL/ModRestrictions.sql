-- Trigger para prevenir modificaciones de un examen con intentos
CREATE OR REPLACE TRIGGER trg_restringir_modificacion_examen
BEFORE UPDATE ON Examenes
FOR EACH ROW
DECLARE
  v_intentos NUMBER;
BEGIN
  -- Verificar si el examen tiene intentos
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
  -- Verificar si la pregunta está en algún examen con intentos
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