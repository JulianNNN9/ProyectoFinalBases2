import { Component, Input, Output, EventEmitter, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, FormArray, ReactiveFormsModule, Validators } from '@angular/forms';
import { ResumenPorcentajesComponent } from '../resumen-porcentajes/resumen-porcentajes.component';

interface Subpregunta {
  texto: string;
  porcentaje: number;
  tipo: string;
}

interface ResumenItem {
  nombre: string;
  porcentaje: number;
  tipo: string;
}

@Component({
  selector: 'app-subpreguntas',
  standalone: true,
  imports: [
    CommonModule, 
    ReactiveFormsModule,
    ResumenPorcentajesComponent
  ],
  templateUrl: './subpreguntas.component.html',
  styleUrls: ['./subpreguntas.component.css']
})
export class SubpreguntasComponent implements OnInit {
  @Input() porcentajeDisponible: number = 100;
  @Output() subpreguntasCreadas = new EventEmitter<Subpregunta[]>();

  subpreguntasForm: FormGroup;
  porcentajeRestante: number;
  tiposPregunta = [
    'Selección múltiple - única respuesta',
    'Selección múltiple - múltiples respuestas',
    'Verdadero/Falso',
    'Emparejar conceptos',
    'Ordenar conceptos'
  ];

  resumenSubpreguntas: ResumenItem[] = [];

  constructor(private fb: FormBuilder) {
    this.subpreguntasForm = this.fb.group({
      subpreguntas: this.fb.array([])
    });
    this.porcentajeRestante = this.porcentajeDisponible;

    // Subscribe to form changes to update resumen
    this.subpreguntasForm.valueChanges.subscribe(() => {
      this.actualizarResumenSubpreguntas();
    });
  }

  ngOnInit(): void {
    this.agregarSubpregunta();
  }

  get subpreguntas() {
    return this.subpreguntasForm.get('subpreguntas') as FormArray;
  }

  agregarSubpregunta() {
    const subpregunta = this.fb.group({
      texto: ['', Validators.required],
      porcentaje: ['', [Validators.required, Validators.min(1), Validators.max(this.porcentajeRestante)]],
      tipo: ['', Validators.required]
    });

    this.subpreguntas.push(subpregunta);
  }

  eliminarSubpregunta(index: number) {
    const porcentajeEliminado = this.subpreguntas.at(index).get('porcentaje')?.value || 0;
    this.porcentajeRestante += porcentajeEliminado;
    this.subpreguntas.removeAt(index);
    this.actualizarSubpreguntas();
  }

  actualizarPorcentaje(index: number) {
    let totalPorcentaje = 0;
    this.subpreguntas.controls.forEach((control, i) => {
      if (i !== index) {
        totalPorcentaje += Number(control.get('porcentaje')?.value || 0);
      }
    });

    const nuevoPorcentaje = Number(this.subpreguntas.at(index).get('porcentaje')?.value || 0);
    if (totalPorcentaje + nuevoPorcentaje > this.porcentajeDisponible) {
      this.subpreguntas.at(index).get('porcentaje')?.setErrors({ excedePorcentaje: true });
    }

    this.porcentajeRestante = this.porcentajeDisponible - (totalPorcentaje + nuevoPorcentaje);
    this.actualizarSubpreguntas();
  }

  actualizarSubpreguntas() {
    if (this.subpreguntasForm.valid) {
      this.subpreguntasCreadas.emit(this.subpreguntas.value);
    }
  }

  private actualizarResumenSubpreguntas(): void {
    const subpreguntasValue = this.subpreguntas.value;
    this.resumenSubpreguntas = subpreguntasValue.map((s: any) => ({
      nombre: s.texto,
      porcentaje: s.porcentaje,
      tipo: s.tipo
    }));
  }
}