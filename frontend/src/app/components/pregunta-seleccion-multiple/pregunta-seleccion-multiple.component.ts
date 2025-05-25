import { Component, Input, Output, EventEmitter, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, FormArray, ReactiveFormsModule, Validators } from '@angular/forms';

interface OpcionMultiple {
  texto: string;
  esCorrecta: boolean;
}

@Component({
  selector: 'app-pregunta-seleccion-multiple',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './pregunta-seleccion-multiple.component.html',
  styleUrls: ['./pregunta-seleccion-multiple.component.css']
})
export class PreguntaSeleccionMultipleComponent implements OnInit {
  @Input() esRespuestaUnica: boolean = true;
  @Output() configuracionCreada = new EventEmitter<any>();

  opcionesForm: FormGroup;
  opcionesCorrectas: number[] = [];

  constructor(private fb: FormBuilder) {
    this.opcionesForm = this.fb.group({
      opciones: this.fb.array([])
    });
  }

  ngOnInit() {
    // Agregar al menos dos opciones al inicio
    this.agregarOpcion();
    this.agregarOpcion();

    // Suscribirse a cambios en el formulario
    this.opcionesForm.valueChanges.subscribe(() => {
      this.emitirConfiguracion();
    });
  }

  get opciones() {
    return this.opcionesForm.get('opciones') as FormArray;
  }

  agregarOpcion() {
    const opcionGroup = this.fb.group({
      texto: ['', Validators.required],
      esCorrecta: [false]
    });
    this.opciones.push(opcionGroup);
  }

  eliminarOpcion(index: number) {
    if (this.opciones.length > 2) {
      if (this.opcionesCorrectas.includes(index)) {
        this.opcionesCorrectas = this.opcionesCorrectas.filter(i => i !== index);
      }
      this.opciones.removeAt(index);
      this.emitirConfiguracion();
    }
  }

  toggleCorrecta(index: number) {
    const opcion = this.opciones.at(index);
    const nuevoValor = !opcion.get('esCorrecta')?.value;

    if (this.esRespuestaUnica) {
      // Para respuesta única, desmarcar las demás
      this.opciones.controls.forEach((control, i) => {
        control.patchValue({ esCorrecta: i === index ? nuevoValor : false });
      });
    } else {
      // Para múltiples respuestas, solo toggle la seleccionada
      opcion.patchValue({ esCorrecta: nuevoValor });
    }
    
    this.emitirConfiguracion();
  }

  validarOpciones(): boolean {
    if (this.opciones.length < 2) return false;
    
    const opcionesValidas = this.opciones.controls.every(control => 
      control.get('texto')?.valid
    );
    
    const tieneCorrecta = this.opciones.controls.some(control => 
      control.get('esCorrecta')?.value
    );

    return opcionesValidas && tieneCorrecta;
  }

  private emitirConfiguracion() {
    if (this.validarOpciones()) {
      const configuracion = {
        tipo: this.esRespuestaUnica ? 'unica' : 'multiple',
        opciones: this.opciones.value
      };
      this.configuracionCreada.emit(configuracion);
    }
  }
}
