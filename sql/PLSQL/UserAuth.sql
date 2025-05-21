-- Procedimiento para autenticar usuarios
CREATE OR REPLACE PROCEDURE sp_validar_usuario(
  p_email IN VARCHAR2,
  p_contrasenia IN VARCHAR2,
  p_usuario_id OUT NUMBER,
  p_tipo_usuario OUT NUMBER,
  p_autenticado OUT BOOLEAN
) AS
BEGIN
  p_autenticado := FALSE;
  
  SELECT usuario_id, tipo_usuario_id INTO p_usuario_id, p_tipo_usuario
  FROM Usuarios
  WHERE email = p_email AND contrasenia = p_contrasenia AND activo = 'S';
  
  p_autenticado := TRUE;
  
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    p_usuario_id := NULL;
    p_tipo_usuario := NULL;
    p_autenticado := FALSE;
END;
/