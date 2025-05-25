import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';
import { config } from './app/app.config.server';

/**
 * Función de inicialización para la renderización del lado del servidor (SSR)
 * Arranca la aplicación Angular con el componente principal y la configuración específica del servidor
 * @returns Función que inicializa la aplicación
 */
const bootstrap = () => bootstrapApplication(AppComponent, config);

/**
 * Exportación por defecto de la función bootstrap
 * Esta función es utilizada por el servidor para renderizar la aplicación
 * en el entorno de Server Side Rendering (SSR)
 */
export default bootstrap;