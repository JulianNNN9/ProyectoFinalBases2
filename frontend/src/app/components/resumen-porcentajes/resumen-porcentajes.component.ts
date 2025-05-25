import { Component, Input, OnChanges, SimpleChanges } from '@angular/core';
import { CommonModule } from '@angular/common';

interface ResumenPorcentaje {
  nombre: string;
  porcentaje: number;
  tipo?: string;
}

@Component({
  selector: 'app-resumen-porcentajes',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './resumen-porcentajes.component.html',
  styleUrls: ['./resumen-porcentajes.component.css']
})
export class ResumenPorcentajesComponent implements OnChanges {
  @Input() items: ResumenPorcentaje[] = [];
  @Input() totalEsperado: number = 100;

  porcentajeTotal: number = 0;
  porcentajeFaltante: number = 0;
  excedePorcentaje: boolean = false;

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['items']) {
      this.calcularPorcentajes();
    }
  }

  private calcularPorcentajes(): void {
    this.porcentajeTotal = this.items.reduce((sum, item) => sum + item.porcentaje, 0);
    this.porcentajeFaltante = this.totalEsperado - this.porcentajeTotal;
    this.excedePorcentaje = this.porcentajeTotal > this.totalEsperado;
  }

  getEstadoClase(item: ResumenPorcentaje): string {
    if (this.excedePorcentaje) {
      return 'porcentaje-excedido';
    }
    return this.porcentajeTotal === this.totalEsperado ? 'porcentaje-completo' : '';
  }

  getProgressBarClass(): string {
    if (this.excedePorcentaje) {
      return 'bg-danger';
    }
    return this.porcentajeTotal === this.totalEsperado ? 'bg-success' : 'bg-warning';
  }
}
