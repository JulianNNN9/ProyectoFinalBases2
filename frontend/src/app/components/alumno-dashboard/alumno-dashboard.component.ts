import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

interface Estudiante {
  id: number;
  nombre: string;
  codigo: string;
  programa: string;
  semestre: number;
  email: string;
}

interface ExamenPendiente {
  id: number;
  nombre: string;
  materia: string;
  profesor: string;
  fecha: string;
  duracion: number;
  estado: 'Programado' | 'Disponible' | 'Expirado';
}

interface ExamenCompletado {
  id: number;
  nombre: string;
  materia: string;
  fechaPresentacion: string;
  nota: number;
  retroalimentacion?: string;
  tiempoUtilizado?: number;
}

@Component({
  selector: 'app-alumno-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './alumno-dashboard.component.html',
  styleUrls: ['./alumno-dashboard.component.css']
})
export class AlumnoDashboardComponent {
  estudiante: Estudiante = {
    id: 1,
    nombre: 'Ana María García',
    codigo: '2024015789',
    programa: 'Ingeniería de Sistemas',
    semestre: 6,
    email: 'ana.garcia@universidad.edu'
  };

  examenesPendientes: ExamenPendiente[] = [
    {
      id: 1,
      nombre: 'Parcial Final',
      materia: 'Bases de Datos II',
      profesor: 'Dr. Juan Pérez',
      fecha: '2024-05-30 14:00',
      duracion: 120,
      estado: 'Programado'
    },
    {
      id: 2,
      nombre: 'Quiz 3',
      materia: 'Programación Web',
      profesor: 'Dra. María López',
      fecha: '2024-06-01 10:00',
      duracion: 30,
      estado: 'Disponible'
    }
  ];

  examenesCompletados: ExamenCompletado[] = [
    {
      id: 3,
      nombre: 'Parcial Medio Término',
      materia: 'Bases de Datos II',
      fechaPresentacion: '2024-05-15',
      nota: 85,
      tiempoUtilizado: 95,
      retroalimentacion: 'Buen manejo de conceptos de normalización'
    },
    {
      id: 4,
      nombre: 'Quiz 2',
      materia: 'Programación Web',
      fechaPresentacion: '2024-05-10',
      nota: 92,
      tiempoUtilizado: 25,
      retroalimentacion: 'Excelente dominio de JavaScript'
    }
  ];

  estadisticas = {
    promedioGeneral: 88.5,
    examenesCompletados: 6,
    examenesPendientes: 2,
    mejorNota: 95
  };
}