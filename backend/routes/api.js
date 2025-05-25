const express = require('express');
const router = express.Router();

// Import controllers
const usuariosController = require('../controllers/usuariosController');
const authController = require('../controllers/authController');
// Otros controladores (estudiantes, exámenes, etc.)

// Rutas públicas
router.post('/auth/login', authController.login);
router.post('/usuarios', usuariosController.insertarUsuario);

// Middleware de autenticación para rutas protegidas
router.use('/profesor', authController.verificarToken, authController.verificarProfesor);
router.use('/estudiante', authController.verificarToken, authController.verificarEstudiante);

// Rutas protegidas de profesor
router.get('/profesor/dashboard', (req, res) => {
  res.json({ message: 'Datos del dashboard de profesor' });
});

// Rutas protegidas de estudiante
router.post('/estudiante/perfil', (req, res) => {
  // Aquí integrarías con el controlador de estudiantes
  res.json({ message: 'Perfil del estudiante' });
});

// Otras rutas protegidas...

module.exports = router;