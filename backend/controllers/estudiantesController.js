const oracledb = require('oracledb');
const dbConfig = require('../config/db');

/**
 * Obtiene el perfil de un estudiante
 */
async function obtenerPerfilEstudiante(req, res) {
  const { usuarioId } = req.body;
  
  let connection;
  try {
    connection = await oracledb.getConnection(dbConfig);
    
    // Configurar para recibir objetos JSON en la respuesta
    const result = await connection.execute(
      `BEGIN 
         :resultado := obtener_perfil_estudiante(:usuario_id); 
       END;`,
      { 
        usuario_id: usuarioId,
        resultado: { type: oracledb.CURSOR, dir: oracledb.BIND_OUT }
      }
    );
    
    // Procesar el cursor de salida
    const resultSet = result.outBinds.resultado;
    const rows = await resultSet.getRows(1); // Solo esperamos un registro
    await resultSet.close();
    
    if (rows && rows.length > 0) {
      // Mapear columnas a propiedades
      const estudiante = {
        usuario_id: rows[0][0],
        nombre: rows[0][1],
        apellido: rows[0][2],
        email: rows[0][3]
      };
      
      res.status(200).json(estudiante);
    } else {
      res.status(404).json({ error: "Estudiante no encontrado" });
    }
    
  } catch (err) {
    console.error('Error al obtener perfil de estudiante:', err);
    res.status(500).json({ error: "Error interno del servidor" });
  } finally {
    if (connection) {
      await connection.close();
    }
  }
}

/**
 * Obtiene estadísticas del estudiante
 */
async function obtenerEstadisticas(req, res) {
  const { usuarioId } = req.body;
  
  let connection;
  try {
    connection = await oracledb.getConnection(dbConfig);
    
    const result = await connection.execute(
      `BEGIN 
         :resultado := obtener_estadisticas_estudiante(:usuario_id); 
       END;`,
      { 
        usuario_id: usuarioId,
        resultado: { type: oracledb.CURSOR, dir: oracledb.BIND_OUT }
      }
    );
    
    const resultSet = result.outBinds.resultado;
    const rows = await resultSet.getRows(1);
    await resultSet.close();
    
    if (rows && rows.length > 0) {
      const estadisticas = {
        promedio_general: rows[0][0],
        examenes_completados: rows[0][1],
        examenes_pendientes: rows[0][2],
        mejor_nota: rows[0][3]
      };
      
      res.status(200).json(estadisticas);
    } else {
      res.status(404).json({ error: "Estadísticas no encontradas" });
    }
    
  } catch (err) {
    console.error('Error al obtener estadísticas:', err);
    res.status(500).json({ error: "Error interno del servidor" });
  } finally {
    if (connection) {
      await connection.close();
    }
  }
}

module.exports = { 
  obtenerPerfilEstudiante,
  obtenerEstadisticas
};