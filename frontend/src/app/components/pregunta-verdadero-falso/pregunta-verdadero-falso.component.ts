import { Component, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';

@Component({
  selector: 'app-pregunta-verdadero-falso',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './pregunta-verdadero-falso.component.html',
  styleUrls: ['./pregunta-verdadero-falso.component.css']
})
export class PreguntaVerdaderoFalsoComponent {
  @Output() configuracionCreada = new EventEmitter<any>();

  vfForm: FormGroup;

  constructor(private fb: FormBuilder) {
    this.vfForm = this.fb.group({
      respuestaCorrecta: ['', Validators.required],
      justificacion: ['', Validators.required]
    });

    // Emitir configuración cuando cambie el formulario
    this.vfForm.valueChanges.subscribe(() => {
      if (this.vfForm.valid) {
        this.configuracionCreada.emit({
          tipo: 'verdadero-falso',
          ...this.vfForm.value
        });
      }
    });
  }
}
