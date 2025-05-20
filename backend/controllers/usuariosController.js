const oracledb = require('oracledb');
const dbConfig = require('../config/db');

/**
 * METODO DE EJEMPLO PARA INSERTAR UN USUARIO
*/
async function insertarUsuario(req, res) {
  const { nombre, email } = req.body;

  let connection;
  try {
    connection = await oracledb.getConnection(dbConfig);

    await connection.execute(
      `BEGIN insertar_usuario(:nombre, :email); END;`,
      { nombre, email }
    );

    res.status(200).json({ mensaje: "Usuario insertado correctamente" });

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Error al insertar usuario" });
  } finally {
    if (connection) {
      await connection.close();
    }
  }
}

module.exports = { insertarUsuario };