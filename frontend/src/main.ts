import { bootstrapApplication } from '@angular/platform-browser';
import { appConfig } from './app/app.config';
import { AppComponent } from './app/app.component';

/**
 * Punto de entrada principal para la aplicación Angular
 * 
 * Esta instrucción inicializa la aplicación en el navegador del cliente,
 * cargando el componente raíz (AppComponent) con la configuración definida.
 * En caso de error durante el arranque, se muestra un mensaje en la consola.
 */
bootstrapApplication(AppComponent, appConfig).catch((err) => console.error(err));