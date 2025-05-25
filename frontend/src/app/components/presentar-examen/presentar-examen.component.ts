import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';

interface Pregunta {
  id: number;
  texto: string;
  tipo: string;
  porcentaje: number;
  opciones?: any[];
  subpreguntas?: Pregunta[];
  respuestaSeleccionada?: any;
  tiempoMaximo?: number;
}

interface ExamenEnCurso {
  id: number;
  titulo: string;
  tiempoRestante: number;
  tiempoTotal: number;
  preguntas: Pregunta[];
}

@Component({
  selector: 'app-presentar-examen',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './presentar-examen.component.html',
  styleUrls: ['./presentar-examen.component.css']
})
export class PresentarExamenComponent implements OnInit {
  examen: ExamenEnCurso = {
    id: 1,
    titulo: 'Examen Final - Bases de Datos II',
    tiempoRestante: 7200, // en segundos
    tiempoTotal: 7200,
    preguntas: []
  };

  preguntaActual?: Pregunta;
  tiempoFormateado: string = '';
  intervalId: any;

  constructor(
    private route: ActivatedRoute,
    private router: Router
  ) {
    // Datos de ejemplo - En producción vendrían del backend
    this.examen.preguntas = [
      {
        id: 1,
        texto: '¿Cuál es el propósito principal de la normalización en bases de datos?',
        tipo: 'Selección múltiple - única respuesta',
        porcentaje: 20,
        opciones: [
          { id: 1, texto: 'Reducir la redundancia de datos' },
          { id: 2, texto: 'Aumentar el rendimiento de las consultas' },
          { id: 3, texto: 'Facilitar el backup de datos' },
          { id: 4, texto: 'Incrementar el espacio de almacenamiento' }
        ]
      },
      {
        id: 2,
        texto: 'Identifique los conceptos correctos sobre transacciones:',
        tipo: 'Selección múltiple - múltiples respuestas',
        porcentaje: 30,
        opciones: [
          { id: 1, texto: 'ACID significa Atomicity, Consistency, Isolation, Durability' },
          { id: 2, texto: 'Una transacción puede ser parcialmente completada' },
          { id: 3, texto: 'El rollback deshace los cambios de una transacción' },
          { id: 4, texto: 'La consistencia garantiza la integridad de los datos' }
        ]
      },
      {
        id: 3,
        tipo: 'Verdadero/Falso',
        texto: 'NoSQL significa "No SQL" y no puede manejar datos relacionales.',
        porcentaje: 10
      }
    ];
  }

  ngOnInit() {
    this.iniciarTemporizador();
  }

  ngOnDestroy() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
    }
  }

  private iniciarTemporizador() {
    this.actualizarTiempoFormateado();
    this.intervalId = setInterval(() => {
      this.examen.tiempoRestante--;
      this.actualizarTiempoFormateado();
      
      if (this.examen.tiempoRestante <= 0) {
        this.entregarExamen();
      }
    }, 1000);
  }

  private actualizarTiempoFormateado() {
    const horas = Math.floor(this.examen.tiempoRestante / 3600);
    const minutos = Math.floor((this.examen.tiempoRestante % 3600) / 60);
    const segundos = this.examen.tiempoRestante % 60;
    
    this.tiempoFormateado = 
      `${horas.toString().padStart(2, '0')}:${minutos.toString().padStart(2, '0')}:${segundos.toString().padStart(2, '0')}`;
  }

  guardarRespuesta(pregunta: Pregunta, respuesta: any) {
    pregunta.respuestaSeleccionada = respuesta;
  }

  guardarRespuestaMultiple(pregunta: Pregunta, opcion: any): void {
    // Initialize respuestaSeleccionada as array if undefined
    if (!pregunta.respuestaSeleccionada) {
      pregunta.respuestaSeleccionada = [];
    }

    if (opcion.seleccionada) {
      // Add to selected answers if not already present
      if (!pregunta.respuestaSeleccionada.includes(opcion.id)) {
        pregunta.respuestaSeleccionada.push(opcion.id);
      }
    } else {
      // Remove from selected answers
      pregunta.respuestaSeleccionada = pregunta.respuestaSeleccionada.filter(
        (id: number) => id !== opcion.id
      );
    }
  }

  entregarExamen() {
    // Aquí iría la lógica para enviar las respuestas al backend
    if (confirm('¿Está seguro de entregar el examen?')) {
      // Procesar respuestas
      const respuestas = this.examen.preguntas.map(p => ({
        preguntaId: p.id,
        respuesta: p.respuestaSeleccionada
      }));
      
      console.log('Respuestas enviadas:', respuestas);
      this.router.navigate(['/alumno']);
    }
  }

  getPorcentajeCompletado(): number {
    const preguntasRespondidas = this.examen.preguntas.filter(p => 
      p.respuestaSeleccionada !== undefined).length;
    return (preguntasRespondidas / this.examen.preguntas.length) * 100;
  }
}
