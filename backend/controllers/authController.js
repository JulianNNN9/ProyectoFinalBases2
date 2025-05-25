const oracledb = require('oracledb');
const dbConfig = require('../config/db');
const jwt = require('jsonwebtoken');

// Clave secreta para JWT
const JWT_SECRET = process.env.JWT_SECRET || 'examen_platform_secret_key';

/**
 * Autenticar usuario mediante credenciales (email y contraseña)
 */
async function login(req, res) {
  const { username, password } = req.body;
  
  // Validar que se hayan proporcionado las credenciales
  if (!username || !password) {
    return res.status(400).json({ 
      error: "Usuario y contraseña son requeridos" 
    });
  }

  let connection;
  try {
    connection = await oracledb.getConnection(dbConfig);
    
    // Llamar al procedimiento PL/SQL para autenticar usuario
    // Nota: username es en realidad el email en nuestra implementación
    const result = await connection.execute(
      `BEGIN 
         :resultado := autenticar_usuario(:email, :password); 
       END;`,
      { 
        email: username, // Usamos el campo username para el email
        password: password,
        resultado: { type: oracledb.CURSOR, dir: oracledb.BIND_OUT }
      }
    );
    
    const resultSet = result.outBinds.resultado;
    const rows = await resultSet.getRows(1); // Solo esperamos un registro
    await resultSet.close();
    
    // Si no hay filas, las credenciales son inválidas
    if (!rows || rows.length === 0) {
      return res.status(401).json({ 
        error: "Credenciales inválidas" 
      });
    }
    
    // Mapear resultados de la BD a objeto de usuario
    const usuario = {
      id: rows[0][0],
      username: rows[0][1], // Email usado como username
      nombre: rows[0][2],
      apellido: rows[0][3],
      email: rows[0][4],
      role: rows[0][5] // 'professor' o 'student'
    };
    
    // Generar token JWT
    const token = jwt.sign(
      { 
        id: usuario.id, 
        username: usuario.username, 
        role: usuario.role 
      },
      JWT_SECRET,
      { expiresIn: '8h' }
    );
    
    // Responder con datos de usuario y token
    res.status(200).json({
      id: usuario.id,
      username: usuario.username,
      nombre: usuario.nombre,
      apellido: usuario.apellido,
      email: usuario.email,
      role: usuario.role,
      token: token
    });
    
  } catch (err) {
    console.error('Error en autenticación:', err);
    res.status(500).json({ error: "Error en el servidor", details: err.message });
  } finally {
    if (connection) {
      try {
        await connection.close();
      } catch (err) {
        console.error('Error al cerrar la conexión:', err);
      }
    }
  }
}

/**
 * Verificar token JWT para rutas protegidas
 */
function verificarToken(req, res, next) {
  const bearerHeader = req.headers['authorization'];
  
  if (!bearerHeader) {
    return res.status(401).json({ error: 'Acceso denegado. Token no proporcionado.' });
  }
  
  try {
    // Obtener token de Bearer header
    const bearer = bearerHeader.split(' ');
    const token = bearer[1];
    
    // Verificar token
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    console.error('Error al verificar token:', err);
    res.status(401).json({ error: 'Token inválido o expirado' });
  }
}

/**
 * Middleware para verificar rol de profesor
 */
function verificarProfesor(req, res, next) {
  if (req.user && req.user.role === 'professor') {
    next();
  } else {
    res.status(403).json({ error: 'Acceso denegado. Se requiere rol de profesor.' });
  }
}

/**
 * Middleware para verificar rol de estudiante
 */
function verificarEstudiante(req, res, next) {
  if (req.user && req.user.role === 'student') {
    next();
  } else {
    res.status(403).json({ error: 'Acceso denegado. Se requiere rol de estudiante.' });
  }
}

module.exports = { 
  login, 
  verificarToken, 
  verificarProfesor, 
  verificarEstudiante 
};