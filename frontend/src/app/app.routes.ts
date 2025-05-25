import { Routes } from '@angular/router';
import { LoginComponent } from './components/login/login.component';
import { CrearExamenComponent } from './components/crear-examen/crear-examen.component';
import { GestionarPreguntasComponent } from './components/gestionar-preguntas/gestionar-preguntas.component';
import { BancoPreguntasComponent } from './components/banco-preguntas/banco-preguntas.component';
import { CrearPreguntaComponent } from './components/crear-pregunta/crear-pregunta.component';
import { PreguntaEmparejarComponent } from './components/pregunta-emparejar/pregunta-emparejar.component';
import { PreguntaOrdenarComponent } from './components/pregunta-ordenar/pregunta-ordenar.component';
import { PreguntaSeleccionMultipleComponent } from './components/pregunta-seleccion-multiple/pregunta-seleccion-multiple.component';
import { PreguntaVerdaderoFalsoComponent } from './components/pregunta-verdadero-falso/pregunta-verdadero-falso.component';
import { PresentarExamenComponent } from './components/presentar-examen/presentar-examen.component';
import { ReportesComponent } from './components/reportes/reportes.component';
import { ResumenPorcentajesComponent } from './components/resumen-porcentajes/resumen-porcentajes.component';
import { SubpreguntasComponent } from './components/subpreguntas/subpreguntas.component';
import { ProfesorDashboardComponent } from './components/profesor-dashboard/profesor-dashboard.component';
import { AlumnoDashboardComponent } from './components/alumno-dashboard/alumno-dashboard.component';

export const routes: Routes = [
    // Auth routes
    { path: 'login', component: LoginComponent },
    { path: '', redirectTo: '/login', pathMatch: 'full' },

    // Professor routes
    { path: 'profesor-dashboard', component: ProfesorDashboardComponent },
    { path: 'crear-examen', component: CrearExamenComponent },
    { path: 'gestionar-preguntas', component: GestionarPreguntasComponent },
    { path: 'banco-preguntas', component: BancoPreguntasComponent },
    { path: 'crear-pregunta', component: CrearPreguntaComponent },
    { path: 'reportes', component: ReportesComponent },

    // Student routes
    { path: 'alumno-dashboard', component: AlumnoDashboardComponent },
    { path: 'presentar-examen/:id', component: PresentarExamenComponent },

    // Component routes (for internal use)
    { path: 'pregunta-emparejar', component: PreguntaEmparejarComponent },
    { path: 'pregunta-ordenar', component: PreguntaOrdenarComponent },
    { path: 'pregunta-seleccion-multiple', component: PreguntaSeleccionMultipleComponent },
    { path: 'pregunta-verdadero-falso', component: PreguntaVerdaderoFalsoComponent },
    { path: 'resumen-porcentajes', component: ResumenPorcentajesComponent },
    { path: 'subpreguntas', component: SubpreguntasComponent },

    // Wildcard route for 404
    { path: '**', redirectTo: '/login' }
];

