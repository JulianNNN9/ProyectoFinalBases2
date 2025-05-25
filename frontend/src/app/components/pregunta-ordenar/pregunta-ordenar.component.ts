import { Component, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, FormArray, ReactiveFormsModule, Validators } from '@angular/forms';
import { CdkDragDrop, moveItemInArray, DragDropModule } from '@angular/cdk/drag-drop';

interface Concepto {
  texto: string;
  orden: number;
}

@Component({
  selector: 'app-pregunta-ordenar',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, DragDropModule],
  templateUrl: './pregunta-ordenar.component.html',
  styleUrls: ['./pregunta-ordenar.component.css']
})
export class PreguntaOrdenarComponent {
  @Output() configuracionCreada = new EventEmitter<any>();

  ordenForm: FormGroup;

  constructor(private fb: FormBuilder) {
    this.ordenForm = this.fb.group({
      conceptos: this.fb.array([])
    });

    // Agregar conceptos iniciales
    this.agregarConcepto();
    this.agregarConcepto();

    // Suscribirse a cambios
    this.ordenForm.valueChanges.subscribe(() => {
      if (this.validarConceptos()) {
        this.actualizarOrden();
        this.emitirConfiguracion();
      }
    });
  }

  get conceptos() {
    return this.ordenForm.get('conceptos') as FormArray;
  }

  agregarConcepto() {
    const conceptoGroup = this.fb.group({
      texto: ['', Validators.required],
      orden: [this.conceptos.length + 1]
    });
    this.conceptos.push(conceptoGroup);
  }

  eliminarConcepto(index: number) {
    if (this.conceptos.length > 2) {
      this.conceptos.removeAt(index);
      this.actualizarOrden();
    }
  }

  drop(event: CdkDragDrop<string[]>) {
    moveItemInArray(this.conceptos.controls, event.previousIndex, event.currentIndex);
    this.actualizarOrden();
  }

  private actualizarOrden() {
    this.conceptos.controls.forEach((control, index) => {
      control.patchValue({ orden: index + 1 }, { emitEvent: false });
    });
  }

  validarConceptos(): boolean {
    if (this.conceptos.length < 2) return false;
    return this.conceptos.valid;
  }

  private emitirConfiguracion() {
    if (this.validarConceptos()) {
      this.configuracionCreada.emit({
        tipo: 'ordenar',
        conceptos: this.conceptos.value
      });
    }
  }
}
