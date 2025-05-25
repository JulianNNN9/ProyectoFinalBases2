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