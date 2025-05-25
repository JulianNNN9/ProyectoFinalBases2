import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';

interface Profesor {
  id: number;
  nombre: string;
  departamento: string;
  email: string;
}

interface ExamenResumen {
  id: number;
  nombre: string;
  materia: string;
  fecha: string;
  estado: 'Borrador' | 'Publicado' | 'En Curso' | 'Finalizado';
  calificados?: number;
  totalEstudiantes?: number;
  promedioNotas?: number;
}

@Component({
  selector: 'app-profesor-dashboard',
  standalone: true,
  imports: [CommonModule, RouterModule],
  templateUrl: './profesor-dashboard.component.html',
  styleUrls: ['./profesor-dashboard.component.css']
})
export class ProfesorDashboardComponent {
  profesor: Profesor = {
    id: 1,
    nombre: 'Dr. Juan Pérez',
    departamento: 'Ingeniería de Sistemas',
    email: 'juan.perez@universidad.edu'
  };

  examenes: ExamenResumen[] = [
    {
      id: 1,
      nombre: 'Parcial Final',
      materia: 'Bases de Datos II',
      fecha: '2024-05-30',
      estado: 'Borrador'
    },
    {
      id: 2,
      nombre: 'Quiz 3',
      materia: 'Programación Web',
      fecha: '2024-06-01',
      estado: 'Publicado',
      totalEstudiantes: 35
    },
    {
      id: 3,
      nombre: 'Examen Medio Término',
      materia: 'Bases de Datos II',
      fecha: '2024-05-15',
      estado: 'Finalizado',
      calificados: 28,
      totalEstudiantes: 30,
      promedioNotas: 78.5
    }
  ];

  estadisticasGenerales = {
    examenesActivos: 2,
    examenesFinalizados: 5,
    estudiantesTotales: 120,
    promedioGeneral: 82.3
  };

  public publicarExamen(examenId: number): void {
  // TODO: Implement the logic to publish the exam, e.g., call a service
  console.log('Publicar examen con ID:', examenId);
  }

  eliminarExamen(id: number): void {
  // Aquí puedes agregar la lógica para eliminar el examen, por ejemplo:
  // this.examenes = this.examenes.filter(examen => examen.id !== id);
  // También puedes llamar a un servicio para eliminarlo en el backend.
  console.log('Eliminar examen con id:', id);
  }
}