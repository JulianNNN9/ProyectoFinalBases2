import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule } from '@angular/forms';
import { ResumenPorcentajesComponent } from '../resumen-porcentajes/resumen-porcentajes.component';
import { CrearPreguntaComponent } from '../crear-pregunta/crear-pregunta.component';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

interface ResumenItem {
  nombre: string;
  porcentaje: number;
  tipo: string;
}

interface Pregunta {
  texto: string;
  porcentaje: number;
  tipo: string;
  configuracion?: any;
}

interface PreguntaBanco {
  id: number;
  texto: string;
  tipo: string;
  categoria: string;
  porcentaje: number;
}

@Component({
  selector: 'app-crear-examen',
  standalone: true,
  imports: [
    CommonModule, 
    ReactiveFormsModule,
    FormsModule,
    RouterModule,
    ResumenPorcentajesComponent
  ],
  templateUrl: './crear-examen.component.html',
  styleUrls: ['./crear-examen.component.css']
})
export class CrearExamenComponent implements OnInit {
  quizForm: FormGroup;
  categorias: string[] = ['Matemáticas', 'Ciencias', 'Historia', 'Lenguaje', 'Programación'];
  sinLimiteTiempo: boolean = false;
  resumenItems: ResumenItem[] = [];

  preguntasDisponibles: PreguntaBanco[] = [];
  preguntasSeleccionadas: PreguntaBanco[] = [];

  preguntas: { texto: string; porcentaje: number; tipo: string }[] = [];
  mostrarCreacionPreguntas: boolean = false;

  constructor(private fb: FormBuilder) {
    this.quizForm = this.fb.group({
      nombre: ['', Validators.required],
      descripcion: ['', Validators.required],
      categoria: ['', Validators.required],
      peso: ['', [Validators.required, Validators.min(0), Validators.max(100)]],
      umbralAprobacion: ['', [Validators.required, Validators.min(0), Validators.max(100)]],
      totalPreguntas: ['', [Validators.required, Validators.min(1)]],
      preguntasMostrar: ['', [Validators.required, Validators.min(1)]],
      tiempo: ['', [Validators.min(1)]],
      sinLimiteTiempo: [false],
      fechaProgramada: ['', Validators.required],
      horaProgramada: ['', Validators.required],
      seleccionAutomatica: [false],
      tipoSeleccionPreguntas: ['automatica', Validators.required] // 'automatica' o 'manual'
    });
  }

  ngOnInit(): void {
    // Aquí cargarías las preguntas disponibles del banco
    this.cargarPreguntasDelBanco();
    
    // Escuchar cambios en sinLimiteTiempo
    this.quizForm.get('sinLimiteTiempo')?.valueChanges.subscribe(sinLimite => {
      const tiempoControl = this.quizForm.get('tiempo');
      if (sinLimite) {
        tiempoControl?.disable();
        tiempoControl?.clearValidators();
      } else {
        tiempoControl?.enable();
        tiempoControl?.setValidators([Validators.required, Validators.min(1)]);
      }
      tiempoControl?.updateValueAndValidity();
    });

    // Agregar listener para tipoSeleccionPreguntas
    this.quizForm.get('tipoSeleccionPreguntas')?.valueChanges.subscribe(tipo => {
      this.mostrarCreacionPreguntas = tipo === 'manual';
      if (tipo === 'automatica') {
        this.preguntas = [];
        this.actualizarResumen();
      }
    });
  }

  cargarPreguntasDelBanco() {
    // TODO: Implementar llamada al servicio
    // Por ahora usamos datos de ejemplo
    this.preguntasDisponibles = [
      { id: 1, texto: '¿Qué es normalización?', tipo: 'Selección múltiple', categoria: 'Bases de datos', porcentaje: 0 },
      { id: 2, texto: '¿Qué es una transacción?', tipo: 'Verdadero/Falso', categoria: 'Bases de datos', porcentaje: 0 }
    ];
  }

  onSubmit() {
    if (this.quizForm.valid) {
      const tipoSeleccion = this.quizForm.get('tipoSeleccionPreguntas')?.value;
      
      if (tipoSeleccion === 'manual' && this.getPorcentajeFaltante() !== 0) {
        console.error('El porcentaje total de las preguntas debe ser 100%');
        return;
      }

      const examenData = {
        ...this.quizForm.value,
        preguntas: tipoSeleccion === 'manual' ? this.preguntas : []
      };

      console.log('Datos del examen:', examenData);
      // Aquí iría la lógica para guardar el examen
    }
  }

  validatePreguntasMostrar() {
    const total = this.quizForm.get('totalPreguntas')?.value;
    const mostrar = this.quizForm.get('preguntasMostrar')?.value;
    
    if (mostrar > total) {
      this.quizForm.get('preguntasMostrar')?.setErrors({ excedeTotal: true });
    }
  }

  getPreguntasParaResumen(): ResumenItem[] {
    return this.preguntas.map(p => ({
      nombre: p.texto,
      porcentaje: p.porcentaje,
      tipo: p.tipo
    }));
  }

  // Add this method if you need to update the resumen items
  actualizarResumen(): void {
    this.resumenItems = this.getPreguntasParaResumen();
  }

  validarPorcentajeTotal(): boolean {
    const porcentajeTotal = this.preguntas.reduce((sum, p) => sum + p.porcentaje, 0);
    return porcentajeTotal <= 100;
  }

  getPorcentajeFaltante(): number {
    const porcentajeTotal = this.preguntas.reduce((sum, p) => sum + p.porcentaje, 0);
    return 100 - porcentajeTotal;
  }

  onPreguntaCreada(pregunta: Pregunta): void {
    if (this.validarPorcentajeTotal()) {
      this.preguntas.push(pregunta);
      this.actualizarResumen();
    } else {
      // Mostrar error - el porcentaje excede 100%
      console.error('El porcentaje total excede el 100%');
    }
  }

  onPreguntaSeleccionada(pregunta: PreguntaBanco) {
    const index = this.preguntasSeleccionadas.findIndex(p => p.id === pregunta.id);
    if (index === -1) {
      this.preguntasSeleccionadas.push(pregunta);
    } else {
      this.preguntasSeleccionadas.splice(index, 1);
    }
    this.actualizarPorcentajes();
  }

  isPreguntaSeleccionada(pregunta: PreguntaBanco): boolean {
    return this.preguntasSeleccionadas.some(p => p.id === pregunta.id);
  }

  actualizarPorcentajes() {
    this.resumenItems = this.preguntasSeleccionadas.map(p => ({
      nombre: p.texto,
      porcentaje: p.porcentaje,
      tipo: p.tipo
    }));
  }
}
