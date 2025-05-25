import { Component, OnInit, Output, EventEmitter, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { SubpreguntasComponent } from '../subpreguntas/subpreguntas.component';
import { PreguntaSeleccionMultipleComponent } from '../pregunta-seleccion-multiple/pregunta-seleccion-multiple.component';
import { PreguntaVerdaderoFalsoComponent } from '../pregunta-verdadero-falso/pregunta-verdadero-falso.component';
import { PreguntaEmparejarComponent } from '../pregunta-emparejar/pregunta-emparejar.component';
import { PreguntaOrdenarComponent } from '../pregunta-ordenar/pregunta-ordenar.component';

interface NuevaPregunta {
  tipo: string;
  texto: string;
  porcentaje: number;
  tiempoMaximo?: number;
  tieneSubpreguntas: boolean;
  subpreguntas?: any[];
}

@Component({
  selector: 'app-crear-pregunta',
  standalone: true,
  imports: [
    CommonModule, 
    ReactiveFormsModule, 
    SubpreguntasComponent,
    PreguntaSeleccionMultipleComponent,
    PreguntaVerdaderoFalsoComponent,
    PreguntaEmparejarComponent,
    PreguntaOrdenarComponent
  ],
  templateUrl: './crear-pregunta.component.html',
  styleUrls: ['./crear-pregunta.component.css']
})
export class CrearPreguntaComponent implements OnInit {
  @Input() porcentajeDisponible: number = 100;
  @Output() preguntaCreada = new EventEmitter<NuevaPregunta>();
  @Output() tipoPreguntaSeleccionado = new EventEmitter<string>();
  
  
  mostrarSubpreguntas: boolean = false;
  subpreguntas: any[] = [];

  preguntaForm: FormGroup;
  tiposPregunta = [
    'Selección múltiple - única respuesta',
    'Selección múltiple - múltiples respuestas',
    'Verdadero/Falso',
    'Emparejar conceptos',
    'Ordenar conceptos'
  ];

  tipoSeleccionado: string = '';
  configuracionEspecifica: any = null;

  constructor(private fb: FormBuilder) {
    this.preguntaForm = this.fb.group({
      tipo: ['', Validators.required],
      texto: ['', Validators.required],
      porcentaje: ['', [Validators.required, Validators.min(1), Validators.max(100)]],
      tiempoMaximo: [''],
      tieneSubpreguntas: [false]
    });
  }

  ngOnInit(): void {
    this.preguntaForm.get('porcentaje')?.setValidators([
      Validators.required,
      Validators.min(1),
      Validators.max(this.porcentajeDisponible)
    ]);

    // Escuchar cambios en el tipo de pregunta
    this.preguntaForm.get('tipo')?.valueChanges.subscribe(tipo => {
      this.tipoSeleccionado = tipo;
      this.configuracionEspecifica = null; // Reset configuración al cambiar tipo
      this.tipoPreguntaSeleccionado.emit(tipo);
    });

    // Escuchar cambios en tieneSubpreguntas
    this.preguntaForm.get('tieneSubpreguntas')?.valueChanges.subscribe(tiene => {
      this.mostrarSubpreguntas = tiene;
      if (!tiene) {
        this.subpreguntas = [];
      }
    });

    // Escuchar cambios en el porcentaje
    this.preguntaForm.get('porcentaje')?.valueChanges.subscribe(valor => {
      this.porcentajeDisponible = valor || 100;
    });
  }

  onSubpreguntasCreadas(subpreguntas: any[]): void {
    this.subpreguntas = subpreguntas;
    this.verificarFormularioValido();
  }

  onConfiguracionEspecifica(config: any) {
    this.configuracionEspecifica = config;
  }

  verificarFormularioValido(): boolean {
    if (!this.preguntaForm.valid) return false;
    
    if (this.mostrarSubpreguntas) {
      if (this.subpreguntas.length === 0) return false;
      
      const sumaPorcentajes = this.subpreguntas.reduce((sum, sub) => 
        sum + (sub.porcentaje || 0), 0);
      return sumaPorcentajes === this.porcentajeDisponible;
    }
    
    return true;
  }

  onSubmit(): void {
    if (this.verificarFormularioValido() && this.configuracionEspecifica) {
      const preguntaData: NuevaPregunta = {
        ...this.preguntaForm.value,
        subpreguntas: this.mostrarSubpreguntas ? this.subpreguntas : undefined,
        configuracionEspecifica: this.configuracionEspecifica
      };
      this.preguntaCreada.emit(preguntaData);
      this.preguntaForm.reset();
      this.subpreguntas = [];
      this.mostrarSubpreguntas = false;
      this.configuracionEspecifica = null;
    }
  }
}