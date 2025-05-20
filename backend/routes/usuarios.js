const express = require('express');
const router = express.Router();
const { insertarUsuario } = require('../controllers/usuariosController');

router.post('/insertar', insertarUsuario);

module.exports = router;
