import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class EstudianteService {
  private apiUrl = 'http://localhost:3000/api';

  constructor(private http: HttpClient) {}

  /**
   * Obtiene el perfil del estudiante desde la base de datos
   */
  obtenerPerfilEstudiante(usuarioId: number): Observable<any> {
    return this.http.post(`${this.apiUrl}/estudiantes/perfil`, { usuarioId });
  }

  /**
   * Obtiene la lista de exámenes pendientes para el estudiante
   */
  obtenerExamenesPendientes(usuarioId: number): Observable<any[]> {
    return this.http.post<any[]>(`${this.apiUrl}/examenes/pendientes`, { usuarioId });
  }

  /**
   * Obtiene la lista de exámenes completados por el estudiante
   */
  obtenerExamenesCompletados(usuarioId: number): Observable<any[]> {
    return this.http.post<any[]>(`${this.apiUrl}/examenes/completados`, { usuarioId });
  }

  /**
   * Obtiene las estadísticas académicas del estudiante
   */
  obtenerEstadisticas(usuarioId: number): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/estudiantes/estadisticas`, { usuarioId });
  }

  /**
   * Inicia un nuevo intento de examen
   */
  iniciarExamen(examenId: number, usuarioId: number): Observable<any> {
    return this.http.post<any>(`${this.apiUrl}/examenes/iniciar`, { 
      examenId, 
      usuarioId 
    });
  }
}