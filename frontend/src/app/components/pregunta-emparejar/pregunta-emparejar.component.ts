import { Component, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, FormArray, ReactiveFormsModule, Validators } from '@angular/forms';

interface ParConcepto {
  concepto: string;
  definicion: string;
}

@Component({
  selector: 'app-pregunta-emparejar',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './pregunta-emparejar.component.html',
  styleUrls: ['./pregunta-emparejar.component.css']
})
export class PreguntaEmparejarComponent {
  @Output() configuracionCreada = new EventEmitter<any>();

  emparejamientoForm: FormGroup;

  constructor(private fb: FormBuilder) {
    this.emparejamientoForm = this.fb.group({
      pares: this.fb.array([])
    });

    // Agregar dos pares iniciales
    this.agregarPar();
    this.agregarPar();

    // Suscribirse a cambios en el formulario
    this.emparejamientoForm.valueChanges.subscribe(() => {
      if (this.validarPares()) {
        this.configuracionCreada.emit({
          tipo: 'emparejar',
          pares: this.pares.value
        });
      }
    });
  }

  get pares() {
    return this.emparejamientoForm.get('pares') as FormArray;
  }

  agregarPar() {
    const parGroup = this.fb.group({
      concepto: ['', Validators.required],
      definicion: ['', Validators.required]
    });
    this.pares.push(parGroup);
  }

  eliminarPar(index: number) {
    if (this.pares.length > 2) {
      this.pares.removeAt(index);
    }
  }

  validarPares(): boolean {
    if (this.pares.length < 2) return false;
    return this.pares.valid;
  }
}
