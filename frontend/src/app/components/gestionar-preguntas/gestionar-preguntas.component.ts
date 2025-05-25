import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule, Router } from '@angular/router';
import { FormsModule } from '@angular/forms';

interface Pregunta {
  id: number;
  texto: string;
  tipo: string;
  categoria: string;
  fechaCreacion: Date;
  vecesUsada: number;
  ultimoUso?: Date;
  examenes?: string[];
}

@Component({
  selector: 'app-gestionar-preguntas',
  standalone: true,
  imports: [CommonModule, RouterModule, FormsModule],
  templateUrl: './gestionar-preguntas.component.html',
  styleUrls: ['./gestionar-preguntas.component.css']
})
export class GestionarPreguntasComponent implements OnInit {
  preguntas: Pregunta[] = [];
  categorias: string[] = ['Bases de Datos', 'Programación', 'Matemáticas', 'Otra'];
  filtroCategoria: string = '';
  filtroBusqueda: string = '';
  
  constructor(private router: Router) {
    // Datos de ejemplo - En producción vendrían del servicio
    this.preguntas = [
      {
        id: 1,
        texto: '¿Qué es normalización en bases de datos?',
        tipo: 'Selección múltiple',
        categoria: 'Bases de Datos',
        fechaCreacion: new Date('2024-05-20'),
        vecesUsada: 3,
        examenes: ['Parcial 1', 'Final 2023', 'Quiz 2']
      },
      // ... más preguntas de ejemplo
    ];
  }

  ngOnInit(): void {
    this.cargarPreguntas();
  }

  cargarPreguntas(): void {
    // TODO: Implementar llamada al servicio
  }

  filtrarPreguntas(): Pregunta[] {
    return this.preguntas.filter(pregunta => {
      const cumpleFiltroCategoria = !this.filtroCategoria || 
                                   pregunta.categoria === this.filtroCategoria;
      const cumpleBusqueda = !this.filtroBusqueda || 
                            pregunta.texto.toLowerCase()
                                        .includes(this.filtroBusqueda.toLowerCase());
      return cumpleFiltroCategoria && cumpleBusqueda;
    });
  }

  editarPregunta(pregunta: Pregunta): void {
    this.router.navigate(['/editar-pregunta', pregunta.id], {
      state: { pregunta }
    });
  }

  eliminarPregunta(pregunta: Pregunta): void {
    if (pregunta.vecesUsada > 0) {
      alert('No se puede eliminar una pregunta que ya ha sido usada en exámenes.');
      return;
    }

    const mensaje = 
      `¿Está seguro de eliminar esta pregunta?\n\n` +
      `"${pregunta.texto}"\n\n` +
      `Tipo: ${pregunta.tipo}\n` +
      `Categoría: ${pregunta.categoria}`;

    if (confirm(mensaje)) {
      // TODO: Implementar llamada al servicio
      this.preguntas = this.preguntas.filter(p => p.id !== pregunta.id);
    }
  }

  verHistorialUsos(pregunta: Pregunta): void {
    if (pregunta.examenes && pregunta.examenes.length > 0) {
      const historial = pregunta.examenes.map(examen => `- ${examen}`).join('\n');
      alert(`Exámenes donde se ha usado esta pregunta:\n${historial}`);
    } else {
      alert('Esta pregunta aún no ha sido utilizada en ningún examen.');
    }
  }
}