import { Component, OnInit, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

interface PreguntaBanco {
  id: number;
  tipo: string;
  texto: string;
  categoria: string;
  porcentaje?: number;
}

@Component({
  selector: 'app-banco-preguntas',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './banco-preguntas.component.html',
  styleUrls: ['./banco-preguntas.component.css']
})
export class BancoPreguntasComponent implements OnInit {
  @Output() preguntaSeleccionada = new EventEmitter<PreguntaBanco>();
  
  preguntas: PreguntaBanco[] = [];
  categoriasFiltro: string[] = [];
  categoriaSeleccionada: string = '';
  
  // Datos de ejemplo - En producción vendrían de un servicio
  preguntasEjemplo: PreguntaBanco[] = [
    { id: 1, tipo: 'Selección múltiple', texto: '¿Cuál es la capital de Francia?', categoria: 'Geografía' },
    { id: 2, tipo: 'Verdadero/Falso', texto: 'La Tierra es plana', categoria: 'Ciencias' },
    { id: 3, tipo: 'Emparejar', texto: 'Emparejar países con capitales', categoria: 'Geografía' }
  ];

  constructor() {
    this.preguntas = this.preguntasEjemplo;
    this.categoriasFiltro = [...new Set(this.preguntas.map(p => p.categoria))];
  }

  ngOnInit(): void {}

  filtrarPorCategoria(): void {
    if (this.categoriaSeleccionada) {
      this.preguntas = this.preguntasEjemplo.filter(
        p => p.categoria === this.categoriaSeleccionada
      );
    } else {
      this.preguntas = this.preguntasEjemplo;
    }
  }

  seleccionarPregunta(pregunta: PreguntaBanco): void {
    const porcentaje = prompt('Ingrese el porcentaje para esta pregunta (1-100):');
    if (porcentaje && !isNaN(Number(porcentaje))) {
      pregunta.porcentaje = Number(porcentaje);
      this.preguntaSeleccionada.emit(pregunta);
    }
  }
}