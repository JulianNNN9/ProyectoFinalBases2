import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { HttpClientModule } from '@angular/common/http';
import { EstudianteService } from '../../services/estudiante.service';
import { AuthService } from '../../services/auth.service';

// Interfaces alineadas con el esquema de la base de datos Oracle
interface Estudiante {
  usuario_id: number;
  nombre: string;
  apellido: string;
  email: string;
  codigo?: string; 
}

interface ExamenPendiente {
  examen_id: number;
  descripcion: string;
  curso_nombre: string;
  profesor_nombre: string;
  fecha_disponible: string;
  fecha_limite: string;
  tiempo_limite: number;
  estado?: 'Programado' | 'Disponible' | 'Expirado';
}

interface ExamenCompletado {
  examen_id: number;
  descripcion: string;
  curso_nombre: string;
  fecha_fin: string;
  puntaje_total: number;
  tiempo_utilizado: number;
  retroalimentacion?: string;
}

interface Estadisticas {
  promedio_general: number;
  examenes_completados: number;
  examenes_pendientes: number;
  mejor_nota: number;
}

@Component({
  selector: 'app-alumno-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule, HttpClientModule],
  templateUrl: './alumno-dashboard.component.html',
  styleUrls: ['./alumno-dashboard.component.css']
})
export class AlumnoDashboardComponent implements OnInit {
  usuarioId: number = 0;
  estudiante: Estudiante | null = null;
  examenesPendientes: ExamenPendiente[] = [];
  examenesCompletados: ExamenCompletado[] = [];
  estadisticas: Estadisticas = {
    promedio_general: 0,
    examenes_completados: 0,
    examenes_pendientes: 0,
    mejor_nota: 0
  };
  
  isLoading = true;
  error = '';

  constructor(
    private estudianteService: EstudianteService,
    private authService: AuthService
  ) {}

  ngOnInit(): void {
    // Obtener ID del usuario actual desde el servicio de autenticación
    const usuario = this.authService.getCurrentUser();
    if (usuario) {
      this.usuarioId = usuario.id;
      this.cargarDatosEstudiante();
    } else {
      this.error = 'No se pudo obtener la información del usuario autenticado';
      this.isLoading = false;
    }
  }

  cargarDatosEstudiante(): void {
    this.isLoading = true;
    this.error = '';
    
    // Obtener información del estudiante
    this.estudianteService.obtenerPerfilEstudiante(this.usuarioId).subscribe({
      next: (data) => {
        this.estudiante = data;
        this.cargarExamenesPendientes();
      },
      error: (err) => {
        console.error('Error al obtener perfil del estudiante', err);
        this.error = 'Error al cargar datos del estudiante. Por favor, intente nuevamente.';
        this.isLoading = false;
      }
    });
  }

  cargarExamenesPendientes(): void {
    this.estudianteService.obtenerExamenesPendientes(this.usuarioId).subscribe({
      next: (data) => {
        // Procesar cada examen para determinar su estado
        this.examenesPendientes = data.map(examen => ({
          ...examen,
          estado: this.determinarEstadoExamen(examen)
        }));
        this.cargarExamenesCompletados();
      },
      error: (err) => {
        console.error('Error al obtener exámenes pendientes', err);
        this.error = 'Error al cargar exámenes pendientes. Por favor, intente nuevamente.';
        this.isLoading = false;
      }
    });
  }

  cargarExamenesCompletados(): void {
    this.estudianteService.obtenerExamenesCompletados(this.usuarioId).subscribe({
      next: (data) => {
        // Asegurar que cada examen completado tenga la propiedad retroalimentacion
        this.examenesCompletados = data.map(examen => ({
          ...examen,
          retroalimentacion: examen.retroalimentacion || null
        }));
        this.cargarEstadisticas();
      },
      error: (err) => {
        console.error('Error al obtener exámenes completados', err);
        this.error = 'Error al cargar exámenes completados. Por favor, intente nuevamente.';
        this.isLoading = false;
      }
    });
  }

  cargarEstadisticas(): void {
    this.estudianteService.obtenerEstadisticas(this.usuarioId).subscribe({
      next: (data) => {
        this.estadisticas = data;
        this.isLoading = false;
      },
      error: (err) => {
        console.error('Error al obtener estadísticas', err);
        this.error = 'Error al cargar estadísticas. Por favor, intente nuevamente.';
        this.isLoading = false;
      }
    });
  }

  determinarEstadoExamen(examen: ExamenPendiente): 'Programado' | 'Disponible' | 'Expirado' {
    const ahora = new Date();
    const disponible = new Date(examen.fecha_disponible);
    const limite = new Date(examen.fecha_limite);

    if (ahora < disponible) {
      return 'Programado';
    } else if (ahora > limite) {
      return 'Expirado';
    } else {
      return 'Disponible';
    }
  }

  // Método para iniciar un examen
  iniciarExamen(examenId: number): void {
    if (confirm('¿Está seguro que desea iniciar este examen? Una vez iniciado, el tiempo comenzará a correr.')) {
      this.estudianteService.iniciarExamen(examenId, this.usuarioId).subscribe({
        next: (response) => {
          if (response && response.intento_id) {
            // Redireccionar a la página de presentación del examen
            window.location.href = `/presentar-examen/${response.intento_id}`;
          } else {
            alert('Error al iniciar el examen: respuesta inválida del servidor');
          }
        },
        error: (err) => {
          console.error('Error al iniciar examen', err);
          alert('Error al iniciar el examen. Por favor intente nuevamente.');
        }
      });
    }
  }
}