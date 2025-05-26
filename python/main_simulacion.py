import sys
import os
import random # Added for question randomization
from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QFormLayout,
    QLabel, QLineEdit, QTextEdit, QPushButton, QComboBox, QCheckBox,
    QDateTimeEdit, QSpinBox, QDoubleSpinBox, QMessageBox, QStackedWidget,
    QAction, QScrollArea, QRadioButton, QGroupBox, QSpacerItem, QSizePolicy,
    QListWidget, QListWidgetItem, QAbstractItemView, QDialog, QDialogButtonBox,
    QTableWidget, QTableWidgetItem, QHeaderView
)
from PyQt5.QtCore import QDateTime, Qt, QSize, pyqtSignal
from PyQt5.QtGui import QIcon

# --- Configuración Global ---
STYLESHEET_PATH = os.path.join(os.path.dirname(__file__), "styles.css")
current_user = None # Se establecerá después del login

# --- Funciones de Simulación de Base de Datos (DEBES REEMPLAZARLAS) ---
# ... (funciones existentes de simulación de DB sin cambios) ...
def obtener_grupos_db():
    print("Simulando obtención de grupos...")
    return [(1, "Grupo A - Cálculo I"), (2, "Grupo B - Programación Orientada a Objetos"), (3, "Grupo C - Bases de Datos")]

def obtener_temas_db():
    print("Simulando obtención de temas...")
    return [(1, "Límites y Continuidad"), (2, "Derivadas"), (3, "Integrales Simples"), (4, "Clases y Objetos"), (5, "Herencia y Polimorfismo"), (6, "Geometría"), (7, "Cultura General"), (8, "POO"), (9, "Ing. Software")]

def obtener_tipos_pregunta_db():
    print("Simulando obtención de tipos de pregunta...")
    return [
         (1, "OPCION_UNICA"),
         (2, "OPCION_MULTIPLE"),
         (3, "VERDADERO_FALSO"),
         (4, "COMPLETAR"),
         (5, "EMPAREJAR"),
         (6, "ORDENAR")
    ]

def obtener_examenes_disponibles_db(estudiante_id):
    print(f"Simulando obtención de exámenes para estudiante {estudiante_id}...")
    return [(101, "Parcial 1 - Cálculo I", QDateTime.currentDateTime().addDays(1)),
            (102, "Quiz de POO - Clases", QDateTime.currentDateTime().addDays(2)),
            (103, "Examen Final - Bases de Datos", QDateTime.currentDateTime().addDays(3))]


def obtener_info_examen_db(examen_id):
    print(f"Simulando obtención de info para el examen {examen_id}...")
    # Simulación de datos de la tabla EXAMENES [cite: 12]
    if examen_id == 101:
        return {'id': 101, 'descripcion': 'Parcial 1 de Cálculo I', 'tiempo_limite': 60, 'cantidad_preguntas_mostrar': 5, 'aleatorizar_preguntas': 'S'}
    elif examen_id == 102:
        return {'id': 102, 'descripcion': 'Quiz de POO - Clases', 'tiempo_limite': 30, 'cantidad_preguntas_mostrar': 3, 'aleatorizar_preguntas': 'N'}
    return {'id': examen_id, 'descripcion': f'Examen Desconocido {examen_id}', 'tiempo_limite': 45, 'cantidad_preguntas_mostrar': 10, 'aleatorizar_preguntas': 'S'}


def obtener_preguntas_examen_db(examen_id):
    print(f"Simulando obtención de preguntas para el examen {examen_id}...")
    # Simulación de datos de PREGUNTAS_EXAMENES y PREGUNTAS [cite: 31, 28]
    base_preguntas = [
        {'pregunta_examen_id': 1, 'pregunta_id': 10, 'texto': '¿Cuál es la derivada de x^n?', 'tipo_pregunta': 'OPCION_UNICA',
          'opciones': [
             {'opcion_pregunta_id': 101, 'texto': 'n*x^(n-1)', 'es_correcta': 'S'},
             {'opcion_pregunta_id': 102, 'texto': 'x^n / n', 'es_correcta': 'N'},
             {'opcion_pregunta_id': 103, 'texto': 'n*x^n', 'es_correcta': 'N'}], 'peso': 20, 'orden': 1, 'tema_id_simulado': 2},
        {'pregunta_examen_id': 2, 'pregunta_id': 11, 'texto': 'Marque las afirmaciones verdaderas sobre POO:', 'tipo_pregunta': 'OPCION_MULTIPLE',
          'opciones': [
             {'opcion_pregunta_id': 201, 'texto': 'La herencia permite reutilizar código.', 'es_correcta': 'S'},
             {'opcion_pregunta_id': 202, 'texto': 'El encapsulamiento oculta la implementación.', 'es_correcta': 'S'},
             {'opcion_pregunta_id': 203, 'texto': 'Java no es un lenguaje orientado a objetos.', 'es_correcta': 'N'}], 'peso': 25, 'orden': 2, 'tema_id_simulado': 4},
        {'pregunta_examen_id': 3, 'pregunta_id': 12, 'texto': 'Un círculo es una elipse.', 'tipo_pregunta': 'VERDADERO_FALSO', 'peso': 10, 'orden': 3, 'tema_id_simulado': 6},
        {'pregunta_examen_id': 4, 'pregunta_id': 13, 'texto_con_espacios': 'La capital de Colombia es [Bogota] y la de Francia es [Paris].', 'tipo_pregunta': 'COMPLETAR',
          'espacios': [
             {'numero_espacio': 1, 'texto_correcto': 'Bogota'},
             {'numero_espacio': 2, 'texto_correcto': 'Paris'}], 'peso': 15, 'orden': 4, 'tema_id_simulado': 7},
        {'pregunta_examen_id': 5, 'pregunta_id': 14, 'texto': 'Empareje el concepto con su definición:', 'tipo_pregunta': 'EMPAREJAR',
          'pares': [
             {'emparejamiento_pregunta_id': 301, 'opcion_a': 'Clase', 'opcion_b': 'Plantilla para crear objetos'},
             {'emparejamiento_pregunta_id': 302, 'opcion_a': 'Objeto', 'opcion_b': 'Instancia de una clase'},
             {'emparejamiento_pregunta_id': 303, 'opcion_a': 'Método', 'opcion_b': 'Función dentro de una clase'}], 'peso': 15, 'orden': 5, 'tema_id_simulado': 8},
        {'pregunta_examen_id': 6, 'pregunta_id': 15, 'texto': 'Ordene los pasos del ciclo de vida del software:', 'tipo_pregunta': 'ORDENAR',
          'elementos': [
             {'orden_pregunta_id': 401, 'texto': 'Análisis', 'posicion_correcta': 1},
             {'orden_pregunta_id': 402, 'texto': 'Diseño', 'posicion_correcta': 2},
             {'orden_pregunta_id': 403, 'texto': 'Implementación', 'posicion_correcta': 3},
             {'orden_pregunta_id': 404, 'texto': 'Pruebas', 'posicion_correcta': 4},
             {'orden_pregunta_id': 405, 'texto': 'Mantenimiento', 'posicion_correcta': 5}], 'peso': 15, 'orden': 6, 'tema_id_simulado': 9}
    ]
    if examen_id == 101: return base_preguntas[:3]
    if examen_id == 102: return [base_preguntas[1], base_preguntas[4]]
    return base_preguntas

# --- Nuevas Funciones de Simulación DB para Gestión ---
def obtener_todas_las_preguntas_db():
    print("Simulando obtención de TODAS las preguntas del banco...")
    # Esto debería venir de la tabla PREGUNTAS y sus relacionadas
    # (TEMAS, TIPO_PREGUNTAS, USUARIOS para creador) [cite: 28, 43, 48, 58]
    # Añadido tema_id_simulado y tipo_id_simulado para filtros
    return [
        {'id': 10, 'texto': '¿Cuál es la derivada de x^n?', 'tipo': 'OPCION_UNICA', 'tipo_id_simulado': 1, 'tema': 'Derivadas', 'tema_id_simulado': 2, 'creador': 'Profesor X'},
        {'id': 11, 'texto': 'Marque las afirmaciones verdaderas sobre POO:', 'tipo': 'OPCION_MULTIPLE', 'tipo_id_simulado': 2, 'tema': 'Clases y Objetos', 'tema_id_simulado': 4, 'creador': 'Profesor Y'},
        {'id': 12, 'texto': 'Un círculo es una elipse.', 'tipo': 'VERDADERO_FALSO', 'tipo_id_simulado': 3, 'tema': 'Geometría', 'tema_id_simulado': 6, 'creador': 'Profesor X'},
        {'id': 13, 'texto': 'La capital de Colombia es [Bogota]...', 'tipo': 'COMPLETAR', 'tipo_id_simulado': 4, 'tema': 'Cultura General', 'tema_id_simulado': 7, 'creador': 'Profesor Z'},
        {'id': 14, 'texto': 'Empareje el concepto con su definición...', 'tipo': 'EMPAREJAR', 'tipo_id_simulado': 5, 'tema': 'POO', 'tema_id_simulado': 8, 'creador': 'Profesor Y'},
        {'id': 15, 'texto': 'Ordene los pasos del ciclo de vida del software:', 'tipo': 'ORDENAR', 'tipo_id_simulado': 6, 'tema': 'Ing. Software', 'tema_id_simulado': 9, 'creador': 'Profesor Z'},
        {'id': 16, 'texto': '¿Qué es una integral definida?', 'tipo': 'OPCION_UNICA', 'tipo_id_simulado': 1, 'tema': 'Integrales Simples', 'tema_id_simulado': 3, 'creador': 'Profesor X'},
        {'id': 17, 'texto': 'Defina Polimorfismo en POO.', 'tipo': 'COMPLETAR', 'tipo_id_simulado': 4, 'tema': 'Herencia y Polimorfismo', 'tema_id_simulado': 5, 'creador': 'Profesor Y'},
        {'id': 18, 'texto': 'El concepto de límite es fundamental en cálculo.', 'tipo': 'VERDADERO_FALSO', 'tipo_id_simulado': 3, 'tema': 'Límites y Continuidad', 'tema_id_simulado': 1, 'creador': 'Profesor X'},
    ]

def obtener_examenes_profesor_db(profesor_id):
    print(f"Simulando obtención de exámenes para profesor {profesor_id}...")
    # Debería filtrar exámenes por creador_id o grupo_id asociado al profesor [cite: 12, 16]
    return [
        {'id': 101, 'descripcion': 'Parcial 1 - Cálculo I'},
        {'id': 102, 'descripcion': 'Quiz de POO - Clases'},
        {'id': 201, 'descripcion': 'Examen de Prueba - Lógica'},
        {'id': 202, 'descripcion': 'Examen Vacío para Configurar Manualmente'},
    ]

def obtener_preguntas_asociadas_examen_db(examen_id):
    print(f"Simulando obtención de preguntas ASOCIADAS al examen {examen_id}...")
    # De la tabla PREGUNTAS_EXAMENES [cite: 31] y un JOIN a PREGUNTAS [cite: 28]
    if examen_id == 101:
        return [
            {'id': 10, 'texto': '¿Cuál es la derivada de x^n?', 'peso': 20, 'orden': 1},
            {'id': 12, 'texto': 'Un círculo es una elipse.', 'peso': 10, 'orden': 2},
        ]
    elif examen_id == 102:
        return [
            {'id': 11, 'texto': 'Marque las afirmaciones verdaderas sobre POO:', 'peso': 30, 'orden': 1},
        ]
    return []

def guardar_asociacion_preguntas_examen_db(examen_id, preguntas_asociadas_data):
    # preguntas_asociadas_data es una lista de dicts: [{'pregunta_id': PID, 'peso': P, 'orden': O}, ...]
    # Lógica: DELETE de PREGUNTAS_EXAMENES donde examen_id = X [cite: 31]
    #         Luego INSERT para cada pregunta en preguntas_asociadas_data [cite: 31]
    print(f"Simulando guardado de asociación para examen {examen_id}: {preguntas_asociadas_data}")
    return True

def simular_guardar_examen_db(examen_data, preguntas_aleatorias_asociadas=None):
    # Simula la creación de un examen en la tabla EXAMENES [cite: 12]
    # y opcionalmente la asociación de preguntas en PREGUNTAS_EXAMENES [cite: 31]
    print(f"--- Guardando Examen en DB (Simulación) ---")
    print(f"Datos del Examen: {examen_data}")
    examen_id_simulado = random.randint(1000, 9999) # Simular un nuevo ID de examen
    print(f"Examen ID Simulado: {examen_id_simulado}")
    if preguntas_aleatorias_asociadas:
        print(f"Preguntas Aleatorias Asociadas (para PREGUNTAS_EXAMENES):")
        for preg_asoc_data in preguntas_aleatorias_asociadas:
            print(f"  - Pregunta ID: {preg_asoc_data['pregunta_id']}, Peso: {preg_asoc_data['peso']}, Orden: {preg_asoc_data['orden']}")
        # Aquí iría la lógica de INSERT en PREGUNTAS_EXAMENES
        guardar_asociacion_preguntas_examen_db(examen_id_simulado, preguntas_aleatorias_asociadas)
    else:
        print("No se asociaron preguntas aleatorias en la creación.")
    print(f"--- Fin Simulación Guardado Examen ---")
    return True # Simular éxito


def eliminar_pregunta_db(pregunta_id):
    print(f"Simulando eliminación de pregunta ID: {pregunta_id}")
    # Verificar dependencias (si está en exámenes, etc.) antes de DELETE en PREGUNTAS [cite: 28]
    return True
# --- Fin Nuevas Funciones de Simulación DB ---


def load_stylesheet():
    try:
        with open(STYLESHEET_PATH, "r", encoding="utf-8") as f:
            return f.read()
    except FileNotFoundError:
        print(f"Advertencia: No se encontró el archivo de estilos en {STYLESHEET_PATH}")
        return ""
    except Exception as e:
        print(f"Error cargando stylesheet: {e}")
        return ""

class VistaBaseWidget(QWidget):
    vista_cerrada = pyqtSignal()

    def __init__(self, parent=None):
        super().__init__(parent)

    def cerrar_vista(self):
        self.vista_cerrada.emit()
        if self.parentWidget() and hasattr(self.parentWidget(), 'mostrar_bienvenida'):
             self.parentWidget().mostrar_bienvenida()
        else:
            self.close()


class VentanaCrearExamen(VistaBaseWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Crear Nuevo Examen")
        self.setObjectName("createExamWindow")
        self._lista_combos_temas_aleatorizar = []
        self.init_ui()

    def init_ui(self):
        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(20, 20, 20, 20)
        main_layout.setSpacing(15)

        # Scroll Area para Detalles Generales
        scroll_area_details = QScrollArea(self)
        scroll_area_details.setWidgetResizable(True)
        scroll_area_details.setObjectName("formSectionScrollArea") # Puedes usar esta clase para estilizar si es necesario

        self.group_details = QGroupBox("Detalles Generales del Examen")
        # ... (contenido de layout_details y los widgets dentro de group_details se mantiene igual)
        layout_details = QFormLayout(self.group_details)
        layout_details.setSpacing(10)
        layout_details.setContentsMargins(15, 20, 15, 15) # Margen superior reducido un poco
        layout_details.setRowWrapPolicy(QFormLayout.WrapAllRows)

        self.txt_descripcion = QTextEdit()
        self.txt_descripcion.setObjectName("examDescription")
        self.txt_descripcion.setPlaceholderText("Ej: Primer Parcial de Cálculo Diferencial, Unidad 1 y 2")
        layout_details.addRow(QLabel("Descripción del Examen:"), self.txt_descripcion)

        self.dte_fecha_disponible = QDateTimeEdit(QDateTime.currentDateTime())
        self.dte_fecha_disponible.setCalendarPopup(True)
        self.dte_fecha_disponible.setMinimumDateTime(QDateTime.currentDateTime())
        layout_details.addRow(QLabel("Fecha Disponible Desde:"), self.dte_fecha_disponible)

        self.dte_fecha_limite = QDateTimeEdit(QDateTime.currentDateTime().addDays(7))
        self.dte_fecha_limite.setCalendarPopup(True)
        self.dte_fecha_limite.setMinimumDateTime(self.dte_fecha_disponible.dateTime())
        layout_details.addRow(QLabel("Fecha Límite Hasta:"), self.dte_fecha_limite)
        self.dte_fecha_disponible.dateTimeChanged.connect(lambda dt: self.dte_fecha_limite.setMinimumDateTime(dt))


        self.spn_tiempo_limite = QSpinBox()
        self.spn_tiempo_limite.setRange(10, 240)
        self.spn_tiempo_limite.setValue(60)
        self.spn_tiempo_limite.setSuffix(" minutos")
        layout_details.addRow(QLabel("Tiempo Límite:"), self.spn_tiempo_limite)

        self.dsp_peso_examen = QDoubleSpinBox()
        self.dsp_peso_examen.setRange(0.0, 100.0)
        self.dsp_peso_examen.setValue(20.0)
        self.dsp_peso_examen.setSuffix(" %")
        layout_details.addRow(QLabel("Peso del Examen (Ponderación):"), self.dsp_peso_examen)


        self.dsp_umbral_aprobacion = QDoubleSpinBox()
        self.dsp_umbral_aprobacion.setRange(0.0, 100.0)
        self.dsp_umbral_aprobacion.setValue(60.0)
        self.dsp_umbral_aprobacion.setSuffix(" %")
        layout_details.addRow(QLabel("Umbral de Aprobación:"), self.dsp_umbral_aprobacion)

        self.cmb_grupo = QComboBox()
        layout_details.addRow(QLabel("Asignar al Grupo:"), self.cmb_grupo)
        
        scroll_area_details.setWidget(self.group_details) # group_details ahora es el widget del scroll_area_details
        main_layout.addWidget(scroll_area_details, 1) # Stretch factor 1 para que ocupe espacio


        # Scroll Area para Configuración de Preguntas
        scroll_area_config = QScrollArea(self)
        scroll_area_config.setWidgetResizable(True)
        scroll_area_config.setObjectName("formSectionScrollArea") # Puedes usar esta clase para estilizar

        self.group_questions_config = QGroupBox("Configuración de Preguntas del Examen")
        # ... (contenido de layout_questions_config y los widgets dentro de group_questions_config se mantiene igual)
        layout_questions_config = QVBoxLayout(self.group_questions_config) 
        layout_questions_config.setSpacing(10)
        layout_questions_config.setContentsMargins(15, 20, 15, 15) # Margen superior reducido

        self.chk_aleatorizar = QCheckBox("Permitir aleatorizar preguntas al crear examen")
        self.chk_aleatorizar.setChecked(False) 
        layout_questions_config.addWidget(self.chk_aleatorizar)

        self.widget_config_aleatoria = QWidget()
        layout_config_aleatoria = QFormLayout(self.widget_config_aleatoria) 
        layout_config_aleatoria.setSpacing(10)
        layout_config_aleatoria.setContentsMargins(0, 10, 0, 0) 

        self.lbl_cantidad_preguntas = QLabel("Cantidad de Preguntas a Mostrar:")
        self.spn_cantidad_preguntas = QSpinBox()
        self.spn_cantidad_preguntas.setRange(1, 200)
        self.spn_cantidad_preguntas.setValue(10)
        layout_config_aleatoria.addRow(self.lbl_cantidad_preguntas, self.spn_cantidad_preguntas)

        lbl_temas_aleatorizar = QLabel("Seleccionar Temas para Preguntas Aleatorias:")
        layout_config_aleatoria.addRow(lbl_temas_aleatorizar)

        self.temas_aleatorizar_container_widget = QWidget()
        self.temas_aleatorizar_layout = QVBoxLayout(self.temas_aleatorizar_container_widget)
        self.temas_aleatorizar_layout.setContentsMargins(0,0,0,0)
        self.temas_aleatorizar_layout.setSpacing(5)
        layout_config_aleatoria.addRow(self.temas_aleatorizar_container_widget)

        self.btn_anadir_tema_aleatorizar = QPushButton("Añadir Tema para Aleatorización")
        self.btn_anadir_tema_aleatorizar.clicked.connect(self.anadir_combo_tema_aleatorizar)
        btn_anadir_tema_layout = QHBoxLayout()
        btn_anadir_tema_layout.addStretch()
        btn_anadir_tema_layout.addWidget(self.btn_anadir_tema_aleatorizar)
        layout_config_aleatoria.addRow(btn_anadir_tema_layout)

        layout_questions_config.addWidget(self.widget_config_aleatoria)
        self.chk_aleatorizar.toggled.connect(self.toggle_config_aleatoria_visibility)
        self.toggle_config_aleatoria_visibility(self.chk_aleatorizar.isChecked()) 

        scroll_area_config.setWidget(self.group_questions_config) # group_questions_config ahora es el widget del scroll_area_config
        main_layout.addWidget(scroll_area_config, 1) # Stretch factor 1 para que ocupe espacio


        # Botones de Guardar y Cancelar (se mantienen igual, fuera de los scrolls)
        buttons_layout = QHBoxLayout()
        buttons_layout.setSpacing(10)
        buttons_layout.addStretch(1)
        self.btn_guardar = QPushButton("Guardar Examen")
        self.btn_guardar.clicked.connect(self.guardar_examen)

        self.btn_cancelar = QPushButton("Cancelar")
        self.btn_cancelar.clicked.connect(self.cerrar_vista)

        buttons_layout.addWidget(self.btn_cancelar)
        buttons_layout.addWidget(self.btn_guardar)
        main_layout.addLayout(buttons_layout, 0) # Sin stretch para los botones

        self.cargar_combos()
        if not self._lista_combos_temas_aleatorizar: 
            self.anadir_combo_tema_aleatorizar()


    def toggle_config_aleatoria_visibility(self, checked):
        self.widget_config_aleatoria.setVisible(checked)

    def anadir_combo_tema_aleatorizar(self):
        combo_container_widget = QWidget()
        combo_layout = QHBoxLayout(combo_container_widget)
        combo_layout.setContentsMargins(0,0,0,0)
        combo_layout.setSpacing(5) # Espacio entre combo y botón X

        cmb_tema_select = QComboBox()
        cmb_tema_select.addItem("-- Seleccione Tema --", None)
        temas = obtener_temas_db()
        for tema_id, nombre_tema in temas:
            cmb_tema_select.addItem(nombre_tema, tema_id)

        btn_quitar_tema = QPushButton("X") # CAMBIO: Texto del botón a "X"
        btn_quitar_tema.setProperty("class", "small-action-button") # CAMBIO: Aplicar clase de estilo
        btn_quitar_tema.setFixedSize(24, 24) # CAMBIO: Tamaño fijo como otros botones "X"
        btn_quitar_tema.setToolTip("Eliminar este tema de la aleatorización") # Tooltip útil
        btn_quitar_tema.clicked.connect(lambda: self.quitar_combo_tema_aleatorizar(combo_container_widget, cmb_tema_select))

        combo_layout.addWidget(cmb_tema_select, 1) # Darle stretch al combo
        combo_layout.addWidget(btn_quitar_tema)

        self.temas_aleatorizar_layout.addWidget(combo_container_widget)
        self._lista_combos_temas_aleatorizar.append(cmb_tema_select)

    def quitar_combo_tema_aleatorizar(self, widget_to_remove, combo_to_remove):
        widget_to_remove.deleteLater()
        if combo_to_remove in self._lista_combos_temas_aleatorizar:
            self._lista_combos_temas_aleatorizar.remove(combo_to_remove)


    def cargar_combos(self):
        self.cmb_grupo.clear()
        self.cmb_grupo.addItem("-- Seleccione un Grupo --", None)
        grupos = obtener_grupos_db() # Simulación de tabla GRUPOS [cite: 16]
        for grupo_id, nombre_grupo in grupos:
            self.cmb_grupo.addItem(nombre_grupo, grupo_id)

    def guardar_examen(self):
        descripcion = self.txt_descripcion.toPlainText().strip()
        fecha_disponible = self.dte_fecha_disponible.dateTime().toString(Qt.ISODate)
        fecha_limite = self.dte_fecha_limite.dateTime().toString(Qt.ISODate)
        tiempo_limite = self.spn_tiempo_limite.value()
        peso = self.dsp_peso_examen.value()
        umbral = self.dsp_umbral_aprobacion.value()
        grupo_id = self.cmb_grupo.currentData()
        creador_id = current_user['id'] if current_user else -1

        aleatorizar_preguntas_creacion = 'S' if self.chk_aleatorizar.isChecked() else 'N'
        cantidad_preguntas_a_mostrar = self.spn_cantidad_preguntas.value() if aleatorizar_preguntas_creacion == 'S' else 0

        if not descripcion:
            QMessageBox.warning(self, "Datos Incompletos", "La descripción del examen es obligatoria.")
            self.txt_descripcion.setFocus()
            return
        if grupo_id is None:
            QMessageBox.warning(self, "Datos Incompletos", "Debe seleccionar un grupo para el examen.")
            self.cmb_grupo.setFocus()
            return
        if self.dte_fecha_limite.dateTime() <= self.dte_fecha_disponible.dateTime():
            QMessageBox.warning(self, "Fechas Inválidas", "La fecha límite debe ser posterior a la fecha disponible.")
            self.dte_fecha_limite.setFocus()
            return

        examen_data = {
            'descripcion': descripcion, 'fecha_creacion': QDateTime.currentDateTime().toString(Qt.ISODate),
            'fecha_disponible': fecha_disponible, 'fecha_limite': fecha_limite,
            'tiempo_limite': tiempo_limite, 'peso': peso, 'umbral_aprobacion': umbral,
            'cantidad_preguntas_mostrar': cantidad_preguntas_a_mostrar, # Guardar esto también
            'aleatorizar_preguntas': aleatorizar_preguntas_creacion, # Si se aleatoriza en la toma del examen
            'creador_id': creador_id, 'grupo_id': grupo_id
        }
        print(f"Datos base del examen a guardar: {examen_data}")

        preguntas_aleatorias_para_asociar = []

        if aleatorizar_preguntas_creacion == 'S':
            temas_seleccionados_ids = []
            for cmb_tema in self._lista_combos_temas_aleatorizar:
                if cmb_tema.currentData() is not None:
                    temas_seleccionados_ids.append(cmb_tema.currentData())

            if not temas_seleccionados_ids:
                QMessageBox.warning(self, "Datos Incompletos", "Si aleatoriza preguntas, debe seleccionar al menos un tema.")
                return
            if cantidad_preguntas_a_mostrar <= 0:
                QMessageBox.warning(self, "Datos Incompletos", "La cantidad de preguntas a mostrar debe ser mayor que cero si se aleatoriza.")
                self.spn_cantidad_preguntas.setFocus()
                return

            print(f"Aleatorización activada. Temas IDs: {temas_seleccionados_ids}, Cantidad: {cantidad_preguntas_a_mostrar}")

            todas_las_preguntas_banco = obtener_todas_las_preguntas_db() # PREGUNTAS[cite: 28], TEMAS [cite: 43]
            preguntas_candidatas = [
                p for p in todas_las_preguntas_banco
                if p.get('tema_id_simulado') in temas_seleccionados_ids # Usar el ID del tema
            ]

            if len(preguntas_candidatas) < cantidad_preguntas_a_mostrar:
                QMessageBox.warning(self, "Preguntas Insuficientes",
                                    f"No hay suficientes preguntas ({len(preguntas_candidatas)}) en los temas seleccionados "
                                    f"para cubrir la cantidad solicitada ({cantidad_preguntas_a_mostrar}).")
                return

            preguntas_seleccionadas_aleatoriamente = random.sample(preguntas_candidatas, cantidad_preguntas_a_mostrar)

            peso_por_pregunta = round(100.0 / cantidad_preguntas_a_mostrar, 2) if cantidad_preguntas_a_mostrar > 0 else 0

            for i, preg_data in enumerate(preguntas_seleccionadas_aleatoriamente):
                preguntas_aleatorias_para_asociar.append({
                    'pregunta_id': preg_data['id'],
                    'peso': peso_por_pregunta, # Distribuir peso equitativamente
                    'orden': i + 1 # Orden secuencial
                })
            print(f"Preguntas seleccionadas aleatoriamente para asociar: {preguntas_aleatorias_para_asociar}")

        # Simular guardado del examen y, si aplica, sus preguntas asociadas
        if simular_guardar_examen_db(examen_data, preguntas_aleatorias_para_asociar if aleatorizar_preguntas_creacion == 'S' else None):
            QMessageBox.information(self, "Éxito", "Examen guardado (simulación).")
            self.cerrar_vista()
        else:
            QMessageBox.critical(self, "Error", "No se pudo guardar el examen (simulación).")


class VentanaCrearPregunta(VistaBaseWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Crear Nueva Pregunta")
        self.setObjectName("createQuestionWindow")
        self.setMinimumSize(700, 500)
        self.resize(800, 650)

        self._dynamic_option_widgets = []
        self._dynamic_pair_widgets = []
        self._dynamic_order_widgets = []
        self._dynamic_fill_widgets = []
        self.init_ui()

    def init_ui(self):
        self.main_layout = QVBoxLayout(self)
        self.main_layout.setContentsMargins(20, 20, 20, 20)
        self.main_layout.setSpacing(15)

        self.scroll_area_general_info = QScrollArea()
        self.scroll_area_general_info.setWidgetResizable(True)
        self.scroll_area_general_info.setVerticalScrollBarPolicy(Qt.ScrollBarAsNeeded)
        self.scroll_area_general_info.setHorizontalScrollBarPolicy(Qt.ScrollBarAsNeeded)

        group_general_info = QGroupBox("Información General de la Pregunta")
        layout_general_info = QFormLayout(group_general_info)
        layout_general_info.setSpacing(10)
        layout_general_info.setContentsMargins(15, 15, 15, 15)

        self.txt_texto_pregunta = QTextEdit()
        self.txt_texto_pregunta.setObjectName("questionCreationText")
        self.txt_texto_pregunta.setPlaceholderText("Escriba el enunciado principal de la pregunta aquí...")
        layout_general_info.addRow(QLabel("Texto de la Pregunta:"), self.txt_texto_pregunta)

        self.chk_es_publica = QCheckBox("Esta pregunta es pública (disponible para otros profesores)")
        layout_general_info.addRow(self.chk_es_publica)

        self.spn_tiempo_maximo = QSpinBox()
        self.spn_tiempo_maximo.setRange(0, 3600)
        self.spn_tiempo_maximo.setSuffix(" segundos")
        self.spn_tiempo_maximo.setToolTip("0 significa sin límite de tiempo para esta pregunta.")
        layout_general_info.addRow(QLabel("Tiempo Máximo (opcional):"), self.spn_tiempo_maximo)

        self.cmb_tema = QComboBox()
        layout_general_info.addRow(QLabel("Tema de la Pregunta:"), self.cmb_tema)

        self.cmb_tipo_pregunta = QComboBox()
        layout_general_info.addRow(QLabel("Tipo de Pregunta:"), self.cmb_tipo_pregunta)

        self.scroll_area_general_info.setWidget(group_general_info)
        self.main_layout.addWidget(self.scroll_area_general_info, 0)

        self.group_specific_details = QGroupBox("Detalles Específicos del Tipo de Pregunta")
        layout_specific_details = QVBoxLayout(self.group_specific_details)
        layout_specific_details.setContentsMargins(15, 15, 15, 15)
        layout_specific_details.setSpacing(10)

        self.stacked_widget_tipo_pregunta = QStackedWidget()
        layout_specific_details.addWidget(self.stacked_widget_tipo_pregunta)

        self.main_layout.addWidget(self.group_specific_details, 1)

        self.setup_widgets_tipos_pregunta()

        buttons_layout = QHBoxLayout()
        buttons_layout.addStretch(1)
        self.btn_guardar_pregunta = QPushButton("Guardar Pregunta")
        self.btn_guardar_pregunta.clicked.connect(self.guardar_pregunta)

        self.btn_cancelar_pregunta = QPushButton("Cancelar")
        self.btn_cancelar_pregunta.clicked.connect(self.cerrar_vista)

        buttons_layout.addWidget(self.btn_cancelar_pregunta)
        buttons_layout.addWidget(self.btn_guardar_pregunta)
        self.main_layout.addLayout(buttons_layout)

        self.cargar_combos()
        self.cmb_tipo_pregunta.currentIndexChanged.connect(self.actualizar_ui_tipo_pregunta)
        self.actualizar_ui_tipo_pregunta()

    def _crear_layout_dinamico_scrollable(self):
        scroll_area = QScrollArea()
        scroll_area.setWidgetResizable(True)
        scroll_area.setObjectName("dynamicContentScrollArea")
        container_widget = QWidget()
        dynamic_item_layout = QVBoxLayout(container_widget)
        dynamic_item_layout.setSpacing(8)
        dynamic_item_layout.addStretch(1)
        scroll_area.setWidget(container_widget)
        return scroll_area, dynamic_item_layout

    def setup_widgets_tipos_pregunta(self):
        default_widget = QWidget()
        default_layout = QVBoxLayout(default_widget)
        lbl_info = QLabel("Seleccione un tipo de pregunta para configurar sus detalles.")
        lbl_info.setAlignment(Qt.AlignCenter)
        default_layout.addWidget(lbl_info)
        self.stacked_widget_tipo_pregunta.addWidget(default_widget)

        self.widget_opciones = QWidget()
        opciones_main_layout = QVBoxLayout(self.widget_opciones)
        opciones_scroll_area, self.opciones_items_layout = self._crear_layout_dinamico_scrollable()
        opciones_main_layout.addWidget(opciones_scroll_area, 1)
        self.btn_add_opcion = QPushButton("Añadir Opción")
        self.btn_add_opcion.setObjectName("addOptionButton")
        self.btn_add_opcion.clicked.connect(lambda: self.anadir_opcion_input_dinamico())
        opciones_main_layout.addWidget(self.btn_add_opcion, 0, Qt.AlignRight)
        self.stacked_widget_tipo_pregunta.addWidget(self.widget_opciones)

        self.widget_completar = QWidget()
        completar_main_layout = QVBoxLayout(self.widget_completar)
        completar_main_layout.setContentsMargins(0,0,0,0)
        completar_main_layout.setSpacing(8)
        completar_main_layout.addWidget(QLabel("Texto base (use [N] para espacios, ej: La casa es [1] y el perro [2])."))
        self.txt_texto_con_espacios_completar = QTextEdit()
        self.txt_texto_con_espacios_completar.setObjectName("questionCreationText")
        self.txt_texto_con_espacios_completar.setPlaceholderText("Ej: El sol es [amarillo] y el cielo es [azul].")
        self.txt_texto_con_espacios_completar.setMinimumHeight(60)
        completar_main_layout.addWidget(self.txt_texto_con_espacios_completar)
        completar_main_layout.addWidget(QLabel("Respuestas para los espacios (en orden):"))
        completar_scroll_area, self.completar_espacios_items_layout = self._crear_layout_dinamico_scrollable()
        completar_main_layout.addWidget(completar_scroll_area, 1)
        self.btn_add_espacio_completar = QPushButton("Añadir Espacio de Respuesta")
        self.btn_add_espacio_completar.setObjectName("addFillBlankButton")
        self.btn_add_espacio_completar.clicked.connect(lambda: self.anadir_espacio_completar_input())
        completar_main_layout.addWidget(self.btn_add_espacio_completar, 0, Qt.AlignRight)
        self.stacked_widget_tipo_pregunta.addWidget(self.widget_completar)

        self.widget_emparejar = QWidget()
        emparejar_main_layout = QVBoxLayout(self.widget_emparejar)
        emparejar_scroll_area, self.emparejar_items_layout = self._crear_layout_dinamico_scrollable()
        emparejar_main_layout.addWidget(emparejar_scroll_area, 1)
        self.btn_add_par = QPushButton("Añadir Par a Emparejar")
        self.btn_add_par.setObjectName("addPairButton")
        self.btn_add_par.clicked.connect(lambda: self.anadir_par_input_dinamico())
        emparejar_main_layout.addWidget(self.btn_add_par, 0, Qt.AlignRight)
        self.stacked_widget_tipo_pregunta.addWidget(self.widget_emparejar)

        self.widget_ordenar = QWidget()
        ordenar_main_layout = QVBoxLayout(self.widget_ordenar)
        ordenar_scroll_area, self.ordenar_items_layout = self._crear_layout_dinamico_scrollable()
        ordenar_main_layout.addWidget(ordenar_scroll_area, 1)
        self.btn_add_elemento_ordenar = QPushButton("Añadir Elemento a Ordenar")
        self.btn_add_elemento_ordenar.setObjectName("addElementButton")
        self.btn_add_elemento_ordenar.clicked.connect(lambda: self.anadir_elemento_ordenar_input_dinamico())
        ordenar_main_layout.addWidget(self.btn_add_elemento_ordenar, 0, Qt.AlignRight)
        self.stacked_widget_tipo_pregunta.addWidget(self.widget_ordenar)

    def _limpiar_layout_dinamico(self, layout_ref, widget_list_ref):
        if layout_ref is None: return
        # Iterar para eliminar widgets, excepto el stretch item al final
        for i in range(layout_ref.count() - 2, -1, -1): # Stop before the stretch
            child = layout_ref.itemAt(i)
            if child and child.widget():
                child.widget().deleteLater()
        widget_list_ref.clear()


    def anadir_opcion_input_dinamico(self, texto="", es_correcta_val=False):
        widget_opcion = QWidget()
        layout_opcion = QHBoxLayout(widget_opcion)
        layout_opcion.setContentsMargins(0,0,0,0)

        tipo_actual_txt = self.cmb_tipo_pregunta.currentText()
        if tipo_actual_txt == "OPCION_UNICA" or tipo_actual_txt == "VERDADERO_FALSO":
            chk_correcta = QRadioButton()
        else:
            chk_correcta = QCheckBox()

        chk_correcta.setChecked(es_correcta_val)
        txt_opcion = QLineEdit(texto)
        txt_opcion.setPlaceholderText(f"Opción {len(self._dynamic_option_widgets) + 1}")

        btn_del_opcion = QPushButton("X")
        btn_del_opcion.setProperty("class", "small-action-button")
        btn_del_opcion.setToolTip("Eliminar esta opción")
        btn_del_opcion.setFixedSize(24, 24)
        btn_del_opcion.clicked.connect(lambda: self._remove_dynamic_widget(widget_opcion, self.opciones_items_layout, self._dynamic_option_widgets))

        layout_opcion.addWidget(chk_correcta)
        layout_opcion.addWidget(txt_opcion, 1)
        layout_opcion.addWidget(btn_del_opcion)

        self.opciones_items_layout.insertWidget(self.opciones_items_layout.count() -1, widget_opcion)
        self._dynamic_option_widgets.append(widget_opcion)
        txt_opcion.setFocus()

    def anadir_espacio_completar_input(self, texto_val=""):
        widget_espacio = QWidget()
        layout_espacio = QHBoxLayout(widget_espacio)
        layout_espacio.setContentsMargins(0,0,0,0)

        n_espacio = len(self._dynamic_fill_widgets) + 1
        lbl_espacio = QLabel(f"Espacio [{n_espacio}]:")
        txt_respuesta_espacio = QLineEdit(texto_val)
        txt_respuesta_espacio.setPlaceholderText(f"Respuesta para espacio {n_espacio}")

        btn_del_espacio = QPushButton("X")
        btn_del_espacio.setProperty("class", "small-action-button")
        btn_del_espacio.setToolTip("Eliminar este espacio")
        btn_del_espacio.setFixedSize(24, 24)
        btn_del_espacio.clicked.connect(lambda: self._remove_dynamic_widget(widget_espacio, self.completar_espacios_items_layout, self._dynamic_fill_widgets))

        layout_espacio.addWidget(lbl_espacio)
        layout_espacio.addWidget(txt_respuesta_espacio, 1)
        layout_espacio.addWidget(btn_del_espacio)

        self.completar_espacios_items_layout.insertWidget(self.completar_espacios_items_layout.count() -1, widget_espacio)
        self._dynamic_fill_widgets.append(widget_espacio)
        txt_respuesta_espacio.setFocus()

    def anadir_par_input_dinamico(self, opcion_a_val="", opcion_b_val=""):
        widget_par_container = QWidget()
        main_par_layout = QHBoxLayout(widget_par_container)
        main_par_layout.setContentsMargins(0,0,0,0)

        widget_par_form = QWidget()
        layout_par_form = QFormLayout(widget_par_form)
        layout_par_form.setContentsMargins(0,5,0,5)
        layout_par_form.setSpacing(5)

        txt_opcion_a = QLineEdit(opcion_a_val)
        txt_opcion_a.setPlaceholderText(f"Elemento A{len(self._dynamic_pair_widgets) + 1}")
        txt_opcion_b = QLineEdit(opcion_b_val)
        txt_opcion_b.setPlaceholderText(f"Elemento B{len(self._dynamic_pair_widgets) + 1}")
        layout_par_form.addRow("Elemento A:", txt_opcion_a)
        layout_par_form.addRow("Elemento B:", txt_opcion_b)

        main_par_layout.addWidget(widget_par_form, 1)

        btn_del_par = QPushButton("X")
        btn_del_par.setProperty("class", "small-action-button")
        btn_del_par.setToolTip("Eliminar este par")
        btn_del_par.setFixedSize(24, 24)
        btn_del_par.clicked.connect(lambda: self._remove_dynamic_widget(widget_par_container, self.emparejar_items_layout, self._dynamic_pair_widgets))
        main_par_layout.addWidget(btn_del_par)

        self.emparejar_items_layout.insertWidget(self.emparejar_items_layout.count()-1, widget_par_container)
        self._dynamic_pair_widgets.append(widget_par_container)
        txt_opcion_a.setFocus()

    def anadir_elemento_ordenar_input_dinamico(self, texto_val=""):
        widget_elemento = QWidget()
        layout_elemento = QHBoxLayout(widget_elemento)
        layout_elemento.setContentsMargins(0,0,0,0)

        n_elemento = len(self._dynamic_order_widgets) + 1
        lbl_orden = QLabel(f"{n_elemento}.")
        txt_elemento = QLineEdit(texto_val)
        txt_elemento.setPlaceholderText(f"Elemento {n_elemento}")

        btn_del_elemento = QPushButton("X")
        btn_del_elemento.setProperty("class", "small-action-button")
        btn_del_elemento.setToolTip("Eliminar este elemento")
        btn_del_elemento.setFixedSize(24, 24)
        btn_del_elemento.clicked.connect(lambda checked=False, w=widget_elemento: self._remove_dynamic_widget(w, self.ordenar_items_layout, self._dynamic_order_widgets, self.actualizar_numeros_ordenar))


        layout_elemento.addWidget(lbl_orden)
        layout_elemento.addWidget(txt_elemento, 1)
        layout_elemento.addWidget(btn_del_elemento)

        self.ordenar_items_layout.insertWidget(self.ordenar_items_layout.count()-1, widget_elemento)
        self._dynamic_order_widgets.append(widget_elemento)
        txt_elemento.setFocus()
        self.actualizar_numeros_ordenar()

    def _remove_dynamic_widget(self, widget_to_remove, layout_ref, widget_list_ref, callback_after_remove=None):
        if widget_to_remove in widget_list_ref:
            widget_to_remove.hide()
            widget_to_remove.deleteLater()
            widget_list_ref.remove(widget_to_remove)
            if callback_after_remove:
                callback_after_remove()

    def actualizar_numeros_ordenar(self):
        for i, widget in enumerate(self._dynamic_order_widgets):
            if not widget.isVisible(): continue
            layout = widget.layout()
            if layout and layout.count() > 0:
                first_item_widget = layout.itemAt(0).widget()
                if isinstance(first_item_widget, QLabel):
                    first_item_widget.setText(f"{i+1}.")

    def actualizar_ui_tipo_pregunta(self):
        tipo_seleccionado_texto = self.cmb_tipo_pregunta.currentText()
        tipo_seleccionado_data = self.cmb_tipo_pregunta.currentData()

        self.group_specific_details.setTitle(f"Detalles para Pregunta de Tipo: {tipo_seleccionado_texto if tipo_seleccionado_data is not None else 'Ninguno'}")

        self._limpiar_layout_dinamico(self.opciones_items_layout, self._dynamic_option_widgets)
        self._limpiar_layout_dinamico(self.completar_espacios_items_layout, self._dynamic_fill_widgets)
        self._limpiar_layout_dinamico(self.emparejar_items_layout, self._dynamic_pair_widgets)
        self._limpiar_layout_dinamico(self.ordenar_items_layout, self._dynamic_order_widgets)
        self.txt_texto_con_espacios_completar.clear()

        if tipo_seleccionado_data is None:
            self.stacked_widget_tipo_pregunta.setCurrentIndex(0)
            return

        if tipo_seleccionado_texto in ["OPCION_UNICA", "OPCION_MULTIPLE"]:
            self.stacked_widget_tipo_pregunta.setCurrentIndex(1) # widget_opciones
            self.btn_add_opcion.show()
            if not self._dynamic_option_widgets:
                 for _ in range(2): self.anadir_opcion_input_dinamico()
        elif tipo_seleccionado_texto == "VERDADERO_FALSO":
            self.stacked_widget_tipo_pregunta.setCurrentIndex(1) # widget_opciones
            self.btn_add_opcion.hide()
            if not self._dynamic_option_widgets:
                self.anadir_opcion_input_dinamico("Verdadero", False)
                self.anadir_opcion_input_dinamico("Falso", False)
        elif tipo_seleccionado_texto == "COMPLETAR":
            self.stacked_widget_tipo_pregunta.setCurrentIndex(2) # widget_completar
            if not self._dynamic_fill_widgets:
                self.anadir_espacio_completar_input()
        elif tipo_seleccionado_texto == "EMPAREJAR":
            self.stacked_widget_tipo_pregunta.setCurrentIndex(3) # widget_emparejar
            if not self._dynamic_pair_widgets:
                for _ in range(2): self.anadir_par_input_dinamico()
        elif tipo_seleccionado_texto == "ORDENAR":
            self.stacked_widget_tipo_pregunta.setCurrentIndex(4) # widget_ordenar
            if not self._dynamic_order_widgets:
                for _ in range(3): self.anadir_elemento_ordenar_input_dinamico()
        else:
            self.stacked_widget_tipo_pregunta.setCurrentIndex(0) # default_widget

    def cargar_combos(self):
        self.cmb_tema.clear()
        self.cmb_tema.addItem("-- Seleccione un Tema --", None)
        temas = obtener_temas_db() # Simulación de TEMAS [cite: 43]
        for tema_id, nombre_tema in temas:
            self.cmb_tema.addItem(nombre_tema, tema_id)

        self.cmb_tipo_pregunta.clear()
        self.cmb_tipo_pregunta.addItem("-- Seleccione un Tipo --", None)
        tipos = obtener_tipos_pregunta_db() # Simulación de TIPO_PREGUNTAS [cite: 48]
        for tipo_id, desc_tipo in tipos:
            self.cmb_tipo_pregunta.addItem(desc_tipo, tipo_id)

    def guardar_pregunta(self):
        texto_pregunta = self.txt_texto_pregunta.toPlainText().strip()
        es_publica = 'S' if self.chk_es_publica.isChecked() else 'N'
        tiempo_maximo = self.spn_tiempo_maximo.value()
        tema_id = self.cmb_tema.currentData()
        tipo_pregunta_id = self.cmb_tipo_pregunta.currentData()
        tipo_pregunta_texto = self.cmb_tipo_pregunta.currentText()
        creador_id = current_user['id'] if current_user else -1 # De USUARIOS [cite: 58]

        if not texto_pregunta:
            QMessageBox.warning(self, "Datos Incompletos", "El texto de la pregunta es obligatorio.")
            self.txt_texto_pregunta.setFocus()
            return
        if tema_id is None:
            QMessageBox.warning(self, "Datos Incompletos", "Debe seleccionar un tema.")
            self.cmb_tema.setFocus()
            return
        if tipo_pregunta_id is None:
            QMessageBox.warning(self, "Datos Incompletos", "Debe seleccionar un tipo de pregunta.")
            self.cmb_tipo_pregunta.setFocus()
            return

        # Simulación de inserción en PREGUNTAS [cite: 28]
        print(f"Guardando Pregunta (Simulación): Texto='{texto_pregunta}', Publica='{es_publica}', Tiempo='{tiempo_maximo}', "
              f"TemaID='{tema_id}', TipoID='{tipo_pregunta_id}', TipoTXT='{tipo_pregunta_texto}', CreadorID='{creador_id}'")
        simulated_pregunta_id = random.randint(100,999) # Nuevo ID simulado para la pregunta

        if tipo_pregunta_texto in ["OPCION_UNICA", "OPCION_MULTIPLE", "VERDADERO_FALSO"]:
            opciones_data = []
            num_correctas = 0
            if not self._dynamic_option_widgets:
                QMessageBox.warning(self, "Datos Incompletos", "Debe añadir al menos una opción para este tipo de pregunta.")
                return
            for i, opcion_widget in enumerate(self._dynamic_option_widgets):
                radio_o_check = opcion_widget.findChild(QRadioButton) or opcion_widget.findChild(QCheckBox)
                texto_opcion_widget = opcion_widget.findChild(QLineEdit)
                if texto_opcion_widget and radio_o_check:
                    texto_opcion = texto_opcion_widget.text().strip()
                    es_correcta_opcion = 'S' if radio_o_check.isChecked() else 'N'
                    if es_correcta_opcion == 'S': num_correctas +=1
                    if not texto_opcion:
                        QMessageBox.warning(self, "Datos Incompletos", f"El texto de la opción {i+1} no puede estar vacío.")
                        texto_opcion_widget.setFocus()
                        return
                    opciones_data.append({'texto': texto_opcion, 'es_correcta': es_correcta_opcion, 'orden': i + 1, 'pregunta_id': simulated_pregunta_id})

            if tipo_pregunta_texto == "OPCION_UNICA" and num_correctas != 1:
                 QMessageBox.warning(self, "Validación Fallida", "Para preguntas de opción única, debe haber exactamente una respuesta correcta.")
                 return
            if tipo_pregunta_texto == "OPCION_MULTIPLE" and num_correctas < 1:
                 QMessageBox.warning(self, "Validación Fallida", "Para preguntas de opción múltiple, debe haber al menos una respuesta correcta.")
                 return
            if tipo_pregunta_texto == "VERDADERO_FALSO" and num_correctas != 1:
                 QMessageBox.warning(self, "Validación Fallida", "Para preguntas de Verdadero/Falso, debe seleccionar una opción como correcta.")
                 return
            # Simulación de inserción en OPCIONES_PREGUNTAS [cite: 24]
            print(f"  Opciones a guardar (para OPCIONES_PREGUNTAS): {opciones_data}")

        elif tipo_pregunta_texto == "COMPLETAR":
            texto_con_espacios = self.txt_texto_con_espacios_completar.toPlainText().strip()
            if not texto_con_espacios:
                QMessageBox.warning(self, "Datos Incompletos", "El texto base con espacios es obligatorio para preguntas de completar.")
                self.txt_texto_con_espacios_completar.setFocus()
                return

            espacios_data = []
            if not self._dynamic_fill_widgets:
                QMessageBox.warning(self, "Datos Incompletos", "Debe añadir al menos un espacio de respuesta para preguntas de completar.")
                return
            # Simulación de inserción en COMPLETAR_PREGUNTAS [cite: 3]
            simulated_completar_pregunta_id = random.randint(1000,1999)
            print(f"  Texto con espacios (para COMPLETAR_PREGUNTAS.texto_con_espacios): {texto_con_espacios}, completar_pregunta_id (simulada): {simulated_completar_pregunta_id}, pregunta_id: {simulated_pregunta_id}")

            for i, espacio_widget in enumerate(self._dynamic_fill_widgets):
                txt_respuesta_widget = espacio_widget.findChild(QLineEdit)
                if txt_respuesta_widget:
                    texto_correcto_espacio = txt_respuesta_widget.text().strip()
                    if not texto_correcto_espacio:
                        QMessageBox.warning(self, "Datos Incompletos", f"El texto de respuesta para el espacio {i+1} no puede estar vacío.")
                        txt_respuesta_widget.setFocus()
                        return
                    espacios_data.append({'numero_espacio': i + 1, 'texto_correcto': texto_correcto_espacio, 'completar_pregunta_id': simulated_completar_pregunta_id})
            # Simulación de inserción en COMPLETAR_ESPACIOS [cite: 1]
            print(f"  Espacios a completar (para COMPLETAR_ESPACIOS): {espacios_data}")

        elif tipo_pregunta_texto == "EMPAREJAR":
            pares_data = []
            if not self._dynamic_pair_widgets or len(self._dynamic_pair_widgets) < 2:
                QMessageBox.warning(self, "Datos Incompletos", "Debe añadir al menos dos pares para preguntas de emparejar.")
                return
            for i, par_widget_container in enumerate(self._dynamic_pair_widgets):
                form_widget = par_widget_container.layout().itemAt(0).widget()
                inputs = form_widget.findChildren(QLineEdit)
                if len(inputs) == 2:
                    opcion_a = inputs[0].text().strip()
                    opcion_b = inputs[1].text().strip()
                    if not opcion_a or not opcion_b:
                        QMessageBox.warning(self, "Datos Incompletos", f"Ambos elementos del par {i+1} deben tener texto.")
                        if not opcion_a: inputs[0].setFocus()
                        else: inputs[1].setFocus()
                        return
                    pares_data.append({'opcion_a': opcion_a, 'opcion_b': opcion_b, 'pregunta_id': simulated_pregunta_id})
            # Simulación de inserción en EMPAREJAMIENTO_PREGUNTAS [cite: 7]
            print(f"  Pares a emparejar (para EMPAREJAMIENTO_PREGUNTAS): {pares_data}")

        elif tipo_pregunta_texto == "ORDENAR":
            elementos_data = []
            if not self._dynamic_order_widgets or len(self._dynamic_order_widgets) < 2:
                QMessageBox.warning(self, "Datos Incompletos", "Debe añadir al menos dos elementos para preguntas de ordenar.")
                return
            for i, elemento_widget in enumerate(self._dynamic_order_widgets):
                texto_elemento_widget = elemento_widget.findChild(QLineEdit)
                if texto_elemento_widget:
                    texto_elemento = texto_elemento_widget.text().strip()
                    if not texto_elemento:
                        QMessageBox.warning(self, "Datos Incompletos", f"El texto del elemento {i+1} a ordenar no puede estar vacío.")
                        texto_elemento_widget.setFocus()
                        return
                    elementos_data.append({'texto': texto_elemento, 'posicion_correcta': i + 1, 'pregunta_id': simulated_pregunta_id})
            # Simulación de inserción en ORDEN_PREGUNTAS [cite: 26]
            print(f"  Elementos a ordenar (para ORDEN_PREGUNTAS): {elementos_data}")

        QMessageBox.information(self, "Éxito", "Pregunta guardada (simulación).")
        self.cerrar_vista()

# --- Ventana Gestionar Preguntas (NUEVA) ---
class VentanaGestionarPreguntas(VistaBaseWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Gestionar Preguntas del Banco")
        self.setObjectName("manageQuestionsWindow")
        self.setMinimumSize(800, 600)
        self._todas_las_preguntas_cache = [] # Cache para no llamar a DB en cada filtro
        self.init_ui()
        self.cargar_y_mostrar_preguntas_iniciales()


    def init_ui(self):
        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(20, 20, 20, 20)
        main_layout.setSpacing(15)

        filter_group = QGroupBox("Filtros de Búsqueda")
        filter_layout = QHBoxLayout(filter_group) # Layout principal para el grupo de filtros
        filter_layout.setSpacing(10)

        filter_layout.addWidget(QLabel("Filtrar por Tema:"))
        self.cmb_filtro_tema = QComboBox()
        filter_layout.addWidget(self.cmb_filtro_tema)

        filter_layout.addWidget(QLabel("Filtrar por Tipo:"))
        self.cmb_filtro_tipo = QComboBox()
        filter_layout.addWidget(self.cmb_filtro_tipo)

        filter_layout.addStretch(1)
        self.btn_aplicar_filtros = QPushButton("Aplicar Filtros")
        self.btn_aplicar_filtros.clicked.connect(self.aplicar_filtros_tabla)
        filter_layout.addWidget(self.btn_aplicar_filtros)
        
        self.btn_limpiar_filtros = QPushButton("Limpiar Filtros")
        self.btn_limpiar_filtros.clicked.connect(self.limpiar_filtros_y_recargar)
        filter_layout.addWidget(self.btn_limpiar_filtros)

        main_layout.addWidget(filter_group)

        self.cmb_filtro_tema.addItem("Todos los Temas", None)
        for tema_id, nombre_tema in obtener_temas_db(): self.cmb_filtro_tema.addItem(nombre_tema, tema_id)
        self.cmb_filtro_tipo.addItem("Todos los Tipos", None)
        for tipo_id, desc_tipo in obtener_tipos_pregunta_db(): self.cmb_filtro_tipo.addItem(desc_tipo, tipo_id)


        self.tabla_preguntas = QTableWidget()
        self.tabla_preguntas.setColumnCount(5) # ID, Texto, Tipo, Tema, Creador
        self.tabla_preguntas.setHorizontalHeaderLabels(["ID", "Texto de Pregunta", "Tipo", "Tema", "Creador"])
        self.tabla_preguntas.setSelectionBehavior(QAbstractItemView.SelectRows)
        self.tabla_preguntas.setEditTriggers(QAbstractItemView.NoEditTriggers)
        self.tabla_preguntas.verticalHeader().setVisible(False)
        self.tabla_preguntas.horizontalHeader().setSectionResizeMode(1, QHeaderView.Stretch) # Texto de pregunta
        self.tabla_preguntas.horizontalHeader().setSectionResizeMode(0, QHeaderView.ResizeToContents)
        self.tabla_preguntas.horizontalHeader().setSectionResizeMode(2, QHeaderView.ResizeToContents)
        self.tabla_preguntas.horizontalHeader().setSectionResizeMode(3, QHeaderView.ResizeToContents)
        self.tabla_preguntas.horizontalHeader().setSectionResizeMode(4, QHeaderView.ResizeToContents)
        main_layout.addWidget(self.tabla_preguntas)

        action_buttons_layout = QHBoxLayout()
        action_buttons_layout.addStretch(1)

        btn_eliminar = QPushButton("Eliminar Pregunta Seleccionada")
        btn_eliminar.clicked.connect(self.eliminar_pregunta_seleccionada)
        action_buttons_layout.addWidget(btn_eliminar)
        main_layout.addLayout(action_buttons_layout)

        btn_volver = QPushButton("Volver al Menú Principal")
        btn_volver.clicked.connect(self.cerrar_vista)
        main_layout.addWidget(btn_volver, 0, Qt.AlignRight)

    def cargar_y_mostrar_preguntas_iniciales(self):
        self._todas_las_preguntas_cache = obtener_todas_las_preguntas_db() # Cargar todas una vez [cite: 28]
        self.popular_tabla_preguntas(self._todas_las_preguntas_cache)


    def popular_tabla_preguntas(self, preguntas_a_mostrar):
        self.tabla_preguntas.setRowCount(0) # Limpiar tabla
        self.tabla_preguntas.setRowCount(len(preguntas_a_mostrar))
        for row, preg in enumerate(preguntas_a_mostrar):
            self.tabla_preguntas.setItem(row, 0, QTableWidgetItem(str(preg.get('id'))))
            self.tabla_preguntas.setItem(row, 1, QTableWidgetItem(preg.get('texto')))
            self.tabla_preguntas.setItem(row, 2, QTableWidgetItem(preg.get('tipo')))
            self.tabla_preguntas.setItem(row, 3, QTableWidgetItem(preg.get('tema')))
            self.tabla_preguntas.setItem(row, 4, QTableWidgetItem(preg.get('creador')))
            self.tabla_preguntas.item(row,0).setData(Qt.UserRole, preg.get('id'))


    def aplicar_filtros_tabla(self):
        filtro_tema_id = self.cmb_filtro_tema.currentData()
        filtro_tipo_id = self.cmb_filtro_tipo.currentData() # Usaremos el ID para filtrar

        preguntas_filtradas = self._todas_las_preguntas_cache

        if filtro_tema_id is not None:
            preguntas_filtradas = [p for p in preguntas_filtradas if p.get('tema_id_simulado') == filtro_tema_id]

        if filtro_tipo_id is not None:
            preguntas_filtradas = [p for p in preguntas_filtradas if p.get('tipo_id_simulado') == filtro_tipo_id] # Asumiendo que tienes 'tipo_id_simulado'

        self.popular_tabla_preguntas(preguntas_filtradas)
        if not preguntas_filtradas:
            QMessageBox.information(self, "Sin Resultados", "No se encontraron preguntas que coincidan con los filtros seleccionados.")

    def limpiar_filtros_y_recargar(self):
        self.cmb_filtro_tema.setCurrentIndex(0)
        self.cmb_filtro_tipo.setCurrentIndex(0)
        self.popular_tabla_preguntas(self._todas_las_preguntas_cache)


    def eliminar_pregunta_seleccionada(self):
        selected_rows = self.tabla_preguntas.selectionModel().selectedRows()
        if not selected_rows:
            QMessageBox.warning(self, "Sin Selección", "Por favor, seleccione una pregunta de la lista para eliminar.")
            return

        pregunta_id = self.tabla_preguntas.item(selected_rows[0].row(), 0).data(Qt.UserRole)
        pregunta_texto = self.tabla_preguntas.item(selected_rows[0].row(), 1).text()

        reply = QMessageBox.question(self, "Confirmar Eliminación",
                                     f"¿Está seguro de que desea eliminar la pregunta:\n'{pregunta_texto}' (ID: {pregunta_id})?",
                                     QMessageBox.Yes | QMessageBox.No, QMessageBox.No)
        if reply == QMessageBox.Yes:
            if eliminar_pregunta_db(pregunta_id): # Simulación
                # Recargar el caché y luego aplicar filtros actuales o mostrar todo
                self._todas_las_preguntas_cache = obtener_todas_las_preguntas_db()
                self.aplicar_filtros_tabla() # Reaplica filtros o muestra todo si no hay filtros
                QMessageBox.information(self, "Eliminación Exitosa", f"Pregunta ID {pregunta_id} eliminada (simulación).")
            else:
                QMessageBox.critical(self, "Error de Eliminación", f"No se pudo eliminar la pregunta ID {pregunta_id} (simulación).")


# --- Ventana Configurar Preguntas de Examen (MODIFICADA) ---
class VentanaConfigurarPreguntasExamen(VistaBaseWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Configurar Preguntas de Examen")
        self.setObjectName("configureExamQuestionsWindow")
        self.setMinimumSize(950, 700) # Aumentado un poco el ancho
        self._preguntas_banco_cache = [] # Cache para las preguntas disponibles
        self.init_ui()
        self.cargar_examenes_profesor()

    def init_ui(self):
        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(20,20,20,20)
        main_layout.setSpacing(15)

        select_exam_layout = QHBoxLayout()
        select_exam_layout.addWidget(QLabel("Seleccionar Examen a Configurar:"))
        self.cmb_examenes_profesor = QComboBox()
        self.cmb_examenes_profesor.currentIndexChanged.connect(self.examen_seleccionado_cambiado)
        select_exam_layout.addWidget(self.cmb_examenes_profesor, 1)
        main_layout.addLayout(select_exam_layout)

        listas_layout = QHBoxLayout()
        listas_layout.setSpacing(10)

        # --- Grupo Preguntas Disponibles con Filtros ---
        group_disponibles = QGroupBox("Preguntas Disponibles en el Banco")
        layout_disponibles_main = QVBoxLayout(group_disponibles) # Layout principal para este grupo

        # Layout para filtros dentro de group_disponibles
        filter_preg_disp_layout = QHBoxLayout()
        filter_preg_disp_layout.addWidget(QLabel("Tema:"))
        self.cmb_filtro_tema_disp = QComboBox()
        filter_preg_disp_layout.addWidget(self.cmb_filtro_tema_disp, 1)

        filter_preg_disp_layout.addWidget(QLabel("Tipo:"))
        self.cmb_filtro_tipo_disp = QComboBox()
        filter_preg_disp_layout.addWidget(self.cmb_filtro_tipo_disp, 1)

        self.btn_aplicar_filtros_disp = QPushButton("Filtrar")
        self.btn_aplicar_filtros_disp.clicked.connect(self.aplicar_filtros_preguntas_disponibles)
        filter_preg_disp_layout.addWidget(self.btn_aplicar_filtros_disp)
        layout_disponibles_main.addLayout(filter_preg_disp_layout)

        # Cargar combos de filtro
        self.cmb_filtro_tema_disp.addItem("Todos los Temas", None)
        for tema_id, nombre_tema in obtener_temas_db(): self.cmb_filtro_tema_disp.addItem(nombre_tema, tema_id)
        self.cmb_filtro_tipo_disp.addItem("Todos los Tipos", None)
        for tipo_id, desc_tipo in obtener_tipos_pregunta_db(): self.cmb_filtro_tipo_disp.addItem(desc_tipo, tipo_id)


        self.tabla_preguntas_disponibles = QTableWidget()
        self.tabla_preguntas_disponibles.setColumnCount(3) # ID, Texto, Tipo
        self.tabla_preguntas_disponibles.setHorizontalHeaderLabels(["ID", "Texto", "Tipo"])
        self.tabla_preguntas_disponibles.setSelectionBehavior(QAbstractItemView.SelectRows)
        self.tabla_preguntas_disponibles.setEditTriggers(QAbstractItemView.NoEditTriggers)
        self.tabla_preguntas_disponibles.horizontalHeader().setSectionResizeMode(1, QHeaderView.Stretch)
        self.tabla_preguntas_disponibles.horizontalHeader().setSectionResizeMode(0, QHeaderView.ResizeToContents)
        self.tabla_preguntas_disponibles.horizontalHeader().setSectionResizeMode(2, QHeaderView.ResizeToContents)
        layout_disponibles_main.addWidget(self.tabla_preguntas_disponibles)
        listas_layout.addWidget(group_disponibles, 1)
        # --- Fin Grupo Preguntas Disponibles ---


        move_buttons_layout = QVBoxLayout()
        move_buttons_layout.addStretch()
        self.btn_agregar_pregunta = QPushButton(">>")
        self.btn_agregar_pregunta.setToolTip("Añadir pregunta seleccionada al examen")
        self.btn_agregar_pregunta.clicked.connect(self.agregar_pregunta_a_examen)
        move_buttons_layout.addWidget(self.btn_agregar_pregunta)
        self.btn_quitar_pregunta = QPushButton("<<")
        self.btn_quitar_pregunta.setToolTip("Quitar pregunta seleccionada del examen")
        self.btn_quitar_pregunta.clicked.connect(self.quitar_pregunta_de_examen)
        move_buttons_layout.addWidget(self.btn_quitar_pregunta)
        move_buttons_layout.addStretch()
        listas_layout.addLayout(move_buttons_layout)

        group_en_examen = QGroupBox("Preguntas en el Examen Actual")
        layout_en_examen = QVBoxLayout(group_en_examen)
        self.tabla_preguntas_en_examen = QTableWidget()
        self.tabla_preguntas_en_examen.setColumnCount(4) # ID, Texto, Peso, Orden
        self.tabla_preguntas_en_examen.setHorizontalHeaderLabels(["ID", "Texto", "Peso", "Orden"])
        self.tabla_preguntas_en_examen.setSelectionBehavior(QAbstractItemView.SelectRows)
        self.tabla_preguntas_en_examen.horizontalHeader().setSectionResizeMode(1, QHeaderView.Stretch)
        self.tabla_preguntas_en_examen.horizontalHeader().setSectionResizeMode(0, QHeaderView.ResizeToContents)
        self.tabla_preguntas_en_examen.horizontalHeader().setSectionResizeMode(2, QHeaderView.ResizeToContents)
        self.tabla_preguntas_en_examen.horizontalHeader().setSectionResizeMode(3, QHeaderView.ResizeToContents)
        layout_en_examen.addWidget(self.tabla_preguntas_en_examen)
        listas_layout.addWidget(group_en_examen, 1)
        main_layout.addLayout(listas_layout, 1)

        action_buttons_layout = QHBoxLayout()
        action_buttons_layout.addStretch(1)
        self.btn_guardar_configuracion = QPushButton("Guardar Configuración del Examen")
        self.btn_guardar_configuracion.clicked.connect(self.guardar_configuracion_examen)
        action_buttons_layout.addWidget(self.btn_guardar_configuracion)
        self.btn_volver = QPushButton("Volver")
        self.btn_volver.clicked.connect(self.cerrar_vista)
        action_buttons_layout.addWidget(self.btn_volver)
        main_layout.addLayout(action_buttons_layout)

    def cargar_examenes_profesor(self):
        self.cmb_examenes_profesor.clear()
        self.cmb_examenes_profesor.addItem("-- Seleccione un Examen --", None)
        examenes = obtener_examenes_profesor_db(current_user.get('id') if current_user else -1) # EXAMENES [cite: 12]
        for ex_data in examenes:
            self.cmb_examenes_profesor.addItem(ex_data['descripcion'], ex_data['id'])

        self.habilitar_controles(bool(examenes))
        if not examenes:
            self.cmb_examenes_profesor.addItem("No hay exámenes creados por usted.")


    def habilitar_controles(self, habilitar):
        self.tabla_preguntas_disponibles.setEnabled(habilitar)
        self.tabla_preguntas_en_examen.setEnabled(habilitar)
        self.btn_agregar_pregunta.setEnabled(habilitar)
        self.btn_quitar_pregunta.setEnabled(habilitar)
        self.btn_guardar_configuracion.setEnabled(habilitar)
        self.cmb_filtro_tema_disp.setEnabled(habilitar)
        self.cmb_filtro_tipo_disp.setEnabled(habilitar)
        self.btn_aplicar_filtros_disp.setEnabled(habilitar)


    def examen_seleccionado_cambiado(self):
        examen_id = self.cmb_examenes_profesor.currentData()
        self.tabla_preguntas_en_examen.setRowCount(0) # Limpiar tabla de examen

        if examen_id is not None:
            self._preguntas_banco_cache = obtener_todas_las_preguntas_db() # Cargar todas las preguntas del banco [cite: 28]
            self.cargar_preguntas_asociadas(examen_id) # Carga primero las asociadas para saber cuáles excluir
            self.aplicar_filtros_preguntas_disponibles() # Luego carga y filtra disponibles
            self.habilitar_controles(True)
        else:
            self.tabla_preguntas_disponibles.setRowCount(0)
            self.habilitar_controles(False)


    def aplicar_filtros_preguntas_disponibles(self):
        examen_id_actual = self.cmb_examenes_profesor.currentData()
        if examen_id_actual is None and self.cmb_examenes_profesor.count() > 1 : # Evitar error si no hay examen o solo está el placeholder
             # Podria no haber examen seleccionado todavia
             pass
        
        filtro_tema_id = self.cmb_filtro_tema_disp.currentData()
        filtro_tipo_id = self.cmb_filtro_tipo_disp.currentData()

        # IDs de preguntas ya en el examen actual
        preguntas_ya_en_examen_ids = {self.tabla_preguntas_en_examen.item(row, 0).data(Qt.UserRole)
                                      for row in range(self.tabla_preguntas_en_examen.rowCount())}

        preguntas_filtradas = self._preguntas_banco_cache

        if filtro_tema_id is not None:
            preguntas_filtradas = [p for p in preguntas_filtradas if p.get('tema_id_simulado') == filtro_tema_id]
        if filtro_tipo_id is not None:
            preguntas_filtradas = [p for p in preguntas_filtradas if p.get('tipo_id_simulado') == filtro_tipo_id]

        # Excluir las que ya están en el examen
        preguntas_finales_disponibles = [p for p in preguntas_filtradas if p['id'] not in preguntas_ya_en_examen_ids]

        self.popular_tabla_preguntas_disponibles(preguntas_finales_disponibles)


    def popular_tabla_preguntas_disponibles(self, preguntas_a_mostrar):
        self.tabla_preguntas_disponibles.setRowCount(0)
        self.tabla_preguntas_disponibles.setRowCount(len(preguntas_a_mostrar))
        for row, preg in enumerate(preguntas_a_mostrar):
            item_id = QTableWidgetItem(str(preg.get('id')))
            item_id.setData(Qt.UserRole, preg.get('id'))
            self.tabla_preguntas_disponibles.setItem(row, 0, item_id)
            self.tabla_preguntas_disponibles.setItem(row, 1, QTableWidgetItem(preg.get('texto')))
            self.tabla_preguntas_disponibles.setItem(row, 2, QTableWidgetItem(preg.get('tipo')))


    def cargar_preguntas_asociadas(self, examen_id):
        # PREGUNTAS_EXAMENES [cite: 31]
        preguntas_asociadas = obtener_preguntas_asociadas_examen_db(examen_id)
        self.tabla_preguntas_en_examen.setRowCount(len(preguntas_asociadas))
        for row, preg in enumerate(preguntas_asociadas):
            item_id = QTableWidgetItem(str(preg.get('id')))
            item_id.setData(Qt.UserRole, preg.get('id'))
            self.tabla_preguntas_en_examen.setItem(row, 0, item_id)
            self.tabla_preguntas_en_examen.setItem(row, 1, QTableWidgetItem(preg.get('texto')))
            self.tabla_preguntas_en_examen.setItem(row, 2, QTableWidgetItem(str(preg.get('peso', 10))))
            self.tabla_preguntas_en_examen.setItem(row, 3, QTableWidgetItem(str(preg.get('orden', row + 1))))

    def agregar_pregunta_a_examen(self):
        selected_rows = self.tabla_preguntas_disponibles.selectionModel().selectedRows()
        if not selected_rows:
            QMessageBox.warning(self, "Sin Selección", "Seleccione una pregunta de la lista de disponibles.")
            return

        selected_row_index = selected_rows[0].row()
        pregunta_id = self.tabla_preguntas_disponibles.item(selected_row_index, 0).data(Qt.UserRole)
        pregunta_texto = self.tabla_preguntas_disponibles.item(selected_row_index, 1).text()

        current_row_count = self.tabla_preguntas_en_examen.rowCount()
        self.tabla_preguntas_en_examen.insertRow(current_row_count)
        item_id = QTableWidgetItem(str(pregunta_id))
        item_id.setData(Qt.UserRole, pregunta_id)
        self.tabla_preguntas_en_examen.setItem(current_row_count, 0, item_id)
        self.tabla_preguntas_en_examen.setItem(current_row_count, 1, QTableWidgetItem(pregunta_texto))
        self.tabla_preguntas_en_examen.setItem(current_row_count, 2, QTableWidgetItem("10")) # Peso default
        self.tabla_preguntas_en_examen.setItem(current_row_count, 3, QTableWidgetItem(str(current_row_count + 1))) # Orden default

        self.tabla_preguntas_disponibles.removeRow(selected_row_index) # Quitar de disponibles visualmente
                                                                        # No es necesario recargar filtros aquí, solo si se quita del examen


    def quitar_pregunta_de_examen(self):
        selected_rows = self.tabla_preguntas_en_examen.selectionModel().selectedRows()
        if not selected_rows:
            QMessageBox.warning(self, "Sin Selección", "Seleccione una pregunta de la lista del examen actual.")
            return

        selected_row_index = selected_rows[0].row()
        # No es necesario añadirla de nuevo a 'disponibles' aquí,
        # la tabla de disponibles se repopulará con filtros al cambiar selección o al aplicar filtros.
        self.tabla_preguntas_en_examen.removeRow(selected_row_index)
        self.aplicar_filtros_preguntas_disponibles() # Actualizar la tabla de disponibles


    def guardar_configuracion_examen(self):
        examen_id = self.cmb_examenes_profesor.currentData()
        if examen_id is None:
            QMessageBox.warning(self, "Error", "No hay un examen seleccionado.")
            return

        preguntas_asociadas_data = []
        for row in range(self.tabla_preguntas_en_examen.rowCount()):
            pregunta_id = self.tabla_preguntas_en_examen.item(row, 0).data(Qt.UserRole)
            try:
                peso_str = self.tabla_preguntas_en_examen.item(row, 2).text()
                orden_str = self.tabla_preguntas_en_examen.item(row, 3).text()
                if not peso_str or not orden_str: # Check for empty strings
                    raise ValueError("Peso u orden no pueden estar vacíos.")
                peso = float(peso_str)
                orden = int(orden_str)
                if peso < 0 or orden <= 0:
                    raise ValueError("Peso debe ser >= 0 y Orden debe ser > 0.")
            except ValueError as e:
                QMessageBox.critical(self, "Error de Datos", f"Para la pregunta ID {pregunta_id}, el peso y el orden deben ser números válidos y no vacíos. Orden > 0, Peso >=0.\nError: {e}")
                # Enfocar la celda problemática sería ideal, pero es más complejo.
                # self.tabla_preguntas_en_examen.editItem(self.tabla_preguntas_en_examen.item(row,2 if "peso" in str(e).lower() else 3))
                return
            preguntas_asociadas_data.append({'pregunta_id': pregunta_id, 'peso': peso, 'orden': orden})

        if guardar_asociacion_preguntas_examen_db(examen_id, preguntas_asociadas_data): # Simulación PREGUNTAS_EXAMENES [cite: 31]
            QMessageBox.information(self, "Éxito", f"Configuración de preguntas para el examen '{self.cmb_examenes_profesor.currentText()}' guardada (simulación).")
            self.cerrar_vista()
        else:
            QMessageBox.critical(self, "Error", "No se pudo guardar la configuración de preguntas (simulación).")


class VentanaResponderExamen(VistaBaseWidget):
    def __init__(self, examen_id, parent=None):
        super().__init__(parent)
        self.examen_id = examen_id
        self.examen_info = {}
        self.preguntas_examen = []
        self.respuestas_usuario = {}
        self.pregunta_actual_idx = 0
        self.tiempo_restante = 0
        self.timer_examen = None
        self.intento_id_simulado = None

        self.setObjectName("examTakingWindow")
        self.setWindowTitle(f"Respondiendo Examen")
        self.init_ui()
        self.cargar_examen()

    def init_ui(self):
        self.main_layout = QVBoxLayout(self)
        self.main_layout.setContentsMargins(20, 20, 20, 20)
        self.main_layout.setSpacing(15)

        group_info_examen = QGroupBox("Información del Examen")
        self.layout_info_examen = QHBoxLayout(group_info_examen)
        self.layout_info_examen.setContentsMargins(15, 30, 15, 15)

        self.lbl_nombre_examen = QLabel("Examen: Cargando...")
        self.lbl_nombre_examen.setObjectName("examNameLabel")
        self.lbl_tiempo_restante = QLabel("Tiempo: --:--")
        self.lbl_tiempo_restante.setObjectName("timeLeftLabel")
        self.layout_info_examen.addWidget(self.lbl_nombre_examen, 1)
        self.layout_info_examen.addStretch(1)
        self.layout_info_examen.addWidget(self.lbl_tiempo_restante)
        self.main_layout.addWidget(group_info_examen)

        self.group_pregunta_actual = QGroupBox("Pregunta Actual")
        self.layout_pregunta_actual = QVBoxLayout(self.group_pregunta_actual)
        self.layout_pregunta_actual.setContentsMargins(15, 30, 15, 15)
        self.layout_pregunta_actual.setSpacing(10)
        self.main_layout.addWidget(self.group_pregunta_actual, 1)

        nav_buttons_layout = QHBoxLayout()
        nav_buttons_layout.setSpacing(10)
        self.btn_anterior = QPushButton("<< Anterior")
        self.btn_anterior.setProperty("class", "navigation")
        self.btn_siguiente = QPushButton("Siguiente >>")
        self.btn_siguiente.setProperty("class", "navigation")
        self.lbl_progreso = QLabel("Pregunta X de Y")
        self.lbl_progreso.setObjectName("questionNumberLabel")
        self.lbl_progreso.setAlignment(Qt.AlignCenter)

        self.btn_anterior.clicked.connect(self.mostrar_pregunta_anterior)
        self.btn_siguiente.clicked.connect(self.mostrar_pregunta_siguiente)

        nav_buttons_layout.addWidget(self.btn_anterior)
        nav_buttons_layout.addStretch(1)
        nav_buttons_layout.addWidget(self.lbl_progreso)
        nav_buttons_layout.addStretch(1)
        nav_buttons_layout.addWidget(self.btn_siguiente)
        self.main_layout.addLayout(nav_buttons_layout)

        self.btn_terminar = QPushButton("Terminar Intento")
        self.btn_terminar.setObjectName("submitExamButton")
        self.btn_terminar.clicked.connect(self.confirmar_terminar_intento)
        btn_terminar_layout = QHBoxLayout()
        btn_terminar_layout.addStretch(1)
        btn_terminar_layout.addWidget(self.btn_terminar)
        self.main_layout.addLayout(btn_terminar_layout)

    def cargar_examen(self):
        self.examen_info = obtener_info_examen_db(self.examen_id) # EXAMENES [cite: 12]
        self.lbl_nombre_examen.setText(f"Examen: {self.examen_info.get('descripcion', 'N/A')}")
        self.tiempo_restante = self.examen_info.get('tiempo_limite', 0) * 60
        self.actualizar_display_tiempo()

        self.intento_id_simulado = random.randint(900,9999) # Simulación de INTENTOS_EXAMEN.intento_examen_id [cite: 20]
        print(f"Simulando inicio de Intento de Examen ID: {self.intento_id_simulado} para Examen ID: {self.examen_id}")

        todas_las_preguntas_del_examen_config = obtener_preguntas_examen_db(self.examen_id) # PREGUNTAS_EXAMENES [cite: 31]

        # Aleatorización si está configurado en el examen
        if self.examen_info.get('aleatorizar_preguntas', 'N') == 'S':
            random.shuffle(todas_las_preguntas_del_examen_config)

        # Limitar cantidad de preguntas a mostrar si está configurado
        num_a_mostrar = self.examen_info.get('cantidad_preguntas_mostrar', len(todas_las_preguntas_del_examen_config))
        self.preguntas_examen = todas_las_preguntas_del_examen_config[:num_a_mostrar]


        if not self.preguntas_examen:
            QMessageBox.critical(self, "Error", "No se pudieron cargar las preguntas para este examen.")
            self.cerrar_vista()
            return

        if self.tiempo_restante > 0:
             self.timer_examen = self.startTimer(1000)

        self.pregunta_actual_idx = 0
        self.mostrar_pregunta_actual()

    def _limpiar_pregunta_actual(self):
        while self.layout_pregunta_actual.count():
            child = self.layout_pregunta_actual.takeAt(0)
            if child.widget():
                child.widget().deleteLater()
            elif child.layout():
                # Properly delete layouts and their sub-widgets
                while child.layout().count():
                    sub_child = child.layout().takeAt(0)
                    if sub_child.widget():
                        sub_child.widget().deleteLater()
                child.layout().deleteLater()


    def mostrar_pregunta_actual(self):
        self._limpiar_pregunta_actual()

        if not self.preguntas_examen or not (0 <= self.pregunta_actual_idx < len(self.preguntas_examen)):
            return

        pregunta = self.preguntas_examen[self.pregunta_actual_idx]
        pregunta_examen_id = pregunta['pregunta_examen_id'] # ID de PREGUNTAS_EXAMENES [cite: 31]
        self.group_pregunta_actual.setTitle(f"Pregunta {self.pregunta_actual_idx + 1} de {len(self.preguntas_examen)} (Peso: {pregunta.get('peso', 'N/A')})")

        txt_display_pregunta = QTextEdit(pregunta.get('texto', 'Texto de pregunta no disponible'))
        txt_display_pregunta.setReadOnly(True)
        txt_display_pregunta.setObjectName("examQuestionTextDisplay")
        self.layout_pregunta_actual.addWidget(txt_display_pregunta)

        opciones_respuestas_widget = QWidget()
        opciones_respuestas_widget.setObjectName("optionsContainerWidget")
        layout_opciones_respuestas = QVBoxLayout(opciones_respuestas_widget)
        layout_opciones_respuestas.setContentsMargins(10, 10, 10, 10)
        layout_opciones_respuestas.setSpacing(8)

        tipo_pregunta = pregunta.get('tipo_pregunta') # De TIPO_PREGUNTAS [cite: 48]
        respuesta_guardada = self.respuestas_usuario.get(pregunta_examen_id)

        if tipo_pregunta == "OPCION_UNICA" or tipo_pregunta == "VERDADERO_FALSO":
            opciones_q = pregunta.get('opciones', []) # De OPCIONES_PREGUNTAS [cite: 24]
            if tipo_pregunta == "VERDADERO_FALSO": # Simular opciones si es V/F
                opciones_q = [{'opcion_pregunta_id': -1, 'texto': 'Verdadero'}, {'opcion_pregunta_id': -2, 'texto': 'Falso'}]

            for op_data in opciones_q:
                rb = QRadioButton(op_data['texto'])
                rb.setProperty("opcion_id", op_data['opcion_pregunta_id'])
                if respuesta_guardada and respuesta_guardada.get('opcion_seleccionada_id') == op_data['opcion_pregunta_id']:
                    rb.setChecked(True)
                rb.toggled.connect(lambda checked, pid=pregunta_examen_id, op_id=op_data['opcion_pregunta_id']:
                                   self.guardar_respuesta_opcion_unica(pid, op_id, checked))
                layout_opciones_respuestas.addWidget(rb)

        elif tipo_pregunta == "OPCION_MULTIPLE":
            for op_data in pregunta.get('opciones', []): # De OPCIONES_PREGUNTAS [cite: 24]
                cb = QCheckBox(op_data['texto'])
                cb.setProperty("opcion_id", op_data['opcion_pregunta_id'])
                if respuesta_guardada and op_data['opcion_pregunta_id'] in respuesta_guardada.get('opciones_seleccionadas_ids', []):
                    cb.setChecked(True)
                cb.toggled.connect(lambda checked, pid=pregunta_examen_id, op_id=op_data['opcion_pregunta_id']:
                                   self.guardar_respuesta_opcion_multiple(pid, op_id, checked))
                layout_opciones_respuestas.addWidget(cb)

        elif tipo_pregunta == "COMPLETAR":
            # Para COMPLETAR, el texto con espacios está en COMPLETAR_PREGUNTAS.texto_con_espacios [cite: 3]
            # Y los espacios individuales en COMPLETAR_ESPACIOS [cite: 1]
            num_espacios_esperados = len(pregunta.get('espacios', []))
            if num_espacios_esperados == 0 and 'texto_con_espacios' in pregunta: # Fallback si 'espacios' no está, contamos los placeholders
                num_espacios_esperados = pregunta.get('texto_con_espacios','').count('[') # Asumiendo placeholders como [algo]
            if num_espacios_esperados == 0 : num_espacios_esperados = 1 # Al menos un campo si no se puede determinar

            texto_con_placeholders = pregunta.get('texto_con_espacios', pregunta.get('texto'))
            # Para la UI, es mejor mostrar el texto con los QLineEdits incrustados o referenciados
            # Aquí, por simplicidad, solo listamos los QLineEdits debajo del texto general

            for i in range(num_espacios_esperados):
                le = QLineEdit()
                # El ID del espacio original sería COMPLETAR_ESPACIOS.completar_espacio_id [cite: 1]
                espacio_data_original = pregunta.get('espacios', [])[i] if i < len(pregunta.get('espacios', [])) else None
                espacio_id_original = espacio_data_original.get('completar_espacio_id_simulado', i+1) if espacio_data_original else i+1 # Simular ID de espacio

                le.setPlaceholderText(f"Respuesta para espacio {i+1}")
                le.setProperty("numero_espacio", i + 1) # Referencia lógica
                le.setProperty("espacio_id_original", espacio_id_original)

                if respuesta_guardada and respuesta_guardada.get(f'espacio_{espacio_id_original}'):
                    le.setText(respuesta_guardada.get(f'espacio_{espacio_id_original}'))
                le.textChanged.connect(lambda texto, pid=pregunta_examen_id, espacio_id=espacio_id_original:
                                       self.guardar_respuesta_completar(pid, espacio_id, texto))
                layout_opciones_respuestas.addWidget(QLabel(f"Respuesta para espacio {i+1}:"))
                layout_opciones_respuestas.addWidget(le)

        elif tipo_pregunta == "EMPAREJAR":
            # Pares originales de EMPAREJAMIENTO_PREGUNTAS [cite: 7]
            pares_originales = pregunta.get('pares', [])
            columna_a_items = [] # Contendrá {'texto': texto_a, 'id': emparejamiento_pregunta_id}
            columna_b_items_textos = []

            for p_orig in pares_originales:
                columna_a_items.append({'texto': p_orig['opcion_a'], 'id': p_orig['emparejamiento_pregunta_id']})
                columna_b_items_textos.append(p_orig['opcion_b'])

            random.shuffle(columna_b_items_textos) # Desordenar solo la columna B para la UI

            form_emparejar = QFormLayout()
            for item_a_data in columna_a_items:
                item_a_texto = item_a_data['texto']
                id_par_original = item_a_data['id'] # emparejamiento_pregunta_id

                cmb_pareja = QComboBox()
                cmb_pareja.addItem("-- Seleccione Pareja --", None)
                for item_b_texto in columna_b_items_textos:
                    cmb_pareja.addItem(item_b_texto) # Solo texto para la selección del usuario

                cmb_pareja.setProperty("id_par_original", id_par_original) # Guardar el ID del par original

                if respuesta_guardada and respuesta_guardada.get(str(id_par_original)): # Usar ID como clave
                    seleccion_b_guardada = respuesta_guardada.get(str(id_par_original)).get('seleccion_b')
                    idx = cmb_pareja.findText(seleccion_b_guardada)
                    if idx >=0: cmb_pareja.setCurrentIndex(idx)

                cmb_pareja.currentTextChanged.connect(
                    lambda texto_b_seleccionado, pid=pregunta_examen_id, par_id=id_par_original:
                    self.guardar_respuesta_emparejar(pid, par_id, texto_b_seleccionado)
                )
                form_emparejar.addRow(QLabel(f"{item_a_texto}:"), cmb_pareja)
            layout_opciones_respuestas.addLayout(form_emparejar)


        elif tipo_pregunta == "ORDENAR":
            # Elementos originales de ORDEN_PREGUNTAS [cite: 26]
            self.list_widget_ordenar = QListWidget()
            self.list_widget_ordenar.setDragDropMode(QAbstractItemView.InternalMove)
            elementos_originales = pregunta.get('elementos', []) # Cada elem tiene 'texto' y 'orden_pregunta_id'

            elementos_para_mostrar_temp = [] # Lista de {'texto': texto, 'id': orden_pregunta_id}
            if respuesta_guardada and respuesta_guardada.get('orden_seleccionado_ids'):
                # Reconstruir el orden guardado por el usuario
                ids_guardados = respuesta_guardada.get('orden_seleccionado_ids')
                textos_guardados = respuesta_guardada.get('orden_seleccionado_textos', []) # Fallback
                if len(ids_guardados) == len(textos_guardados):
                     for id_elem, txt_elem in zip(ids_guardados, textos_guardados):
                        elementos_para_mostrar_temp.append({'texto': txt_elem, 'id': id_elem})
                else: # Si hay discrepancia, reconstruir desde originales y desordenar
                    for e_orig in elementos_originales:
                        elementos_para_mostrar_temp.append({'texto': e_orig['texto'], 'id': e_orig['orden_pregunta_id']})
                    random.shuffle(elementos_para_mostrar_temp)
            else: # No hay respuesta guardada, tomar de originales y desordenar
                for e_orig in elementos_originales:
                    elementos_para_mostrar_temp.append({'texto': e_orig['texto'], 'id': e_orig['orden_pregunta_id']})
                random.shuffle(elementos_para_mostrar_temp)

            for elem_data in elementos_para_mostrar_temp:
                item_lista = QListWidgetItem(elem_data['texto'])
                item_lista.setData(Qt.UserRole, elem_data['id']) # Guardar el orden_pregunta_id original
                self.list_widget_ordenar.addItem(item_lista)

            self.list_widget_ordenar.model().rowsMoved.connect(
                lambda: self.guardar_respuesta_ordenar(pregunta_examen_id)
            )
            layout_opciones_respuestas.addWidget(QLabel("Reordene los elementos en la secuencia correcta:"))
            layout_opciones_respuestas.addWidget(self.list_widget_ordenar)

        else:
            layout_opciones_respuestas.addWidget(QLabel(f"Tipo de pregunta '{tipo_pregunta}' no implementado para responder."))

        self.layout_pregunta_actual.addWidget(opciones_respuestas_widget)
        self.layout_pregunta_actual.addStretch(1)
        self.actualizar_navegacion()

    def guardar_respuesta_opcion_unica(self, pregunta_examen_id, opcion_seleccionada_id, checked):
        if checked:
            # RESPUESTAS_ESTUDIANTES[cite: 37], RESPUESTAS_OPCIONES [cite: 39]
            self.respuestas_usuario[pregunta_examen_id] = {'opcion_seleccionada_id': opcion_seleccionada_id} # opcion_pregunta_id
        print(f"Rpta ÚNICA P_Examen_ID {pregunta_examen_id}: {self.respuestas_usuario.get(pregunta_examen_id)}")

    def guardar_respuesta_opcion_multiple(self, pregunta_examen_id, opcion_id, checked):
        # RESPUESTAS_ESTUDIANTES[cite: 37], RESPUESTAS_OPCIONES [cite: 39]
        if pregunta_examen_id not in self.respuestas_usuario or \
           not isinstance(self.respuestas_usuario[pregunta_examen_id].get('opciones_seleccionadas_ids'), list):
            self.respuestas_usuario[pregunta_examen_id] = {'opciones_seleccionadas_ids': []}

        if checked and opcion_id not in self.respuestas_usuario[pregunta_examen_id]['opciones_seleccionadas_ids']:
            self.respuestas_usuario[pregunta_examen_id]['opciones_seleccionadas_ids'].append(opcion_id)
        elif not checked and opcion_id in self.respuestas_usuario[pregunta_examen_id]['opciones_seleccionadas_ids']:
            self.respuestas_usuario[pregunta_examen_id]['opciones_seleccionadas_ids'].remove(opcion_id)
        print(f"Rpta MÚLTIPLE P_Examen_ID {pregunta_examen_id}: {self.respuestas_usuario.get(pregunta_examen_id)}")


    def guardar_respuesta_completar(self, pregunta_examen_id, espacio_id_original, texto_ingresado):
        # RESPUESTAS_ESTUDIANTES[cite: 37], RESPUESTAS_COMPLETAR [cite: 33]
        # 'espacio_id_original' es el completar_espacio_id
        if pregunta_examen_id not in self.respuestas_usuario:
            self.respuestas_usuario[pregunta_examen_id] = {}
        # Usar el espacio_id_original (que es completar_espacio_id) como clave
        self.respuestas_usuario[pregunta_examen_id][str(espacio_id_original)] = texto_ingresado.strip()
        print(f"Rpta COMPLETAR P_Examen_ID {pregunta_examen_id}: {self.respuestas_usuario.get(pregunta_examen_id)}")


    def guardar_respuesta_emparejar(self, pregunta_examen_id, par_id_original, seleccion_b_texto):
        # RESPUESTAS_ESTUDIANTES[cite: 37], RESPUESTAS_EMPAREJAMIENTO [cite: 35]
        # 'par_id_original' es el emparejamiento_pregunta_id
        if pregunta_examen_id not in self.respuestas_usuario:
            self.respuestas_usuario[pregunta_examen_id] = {}
        # El emparejamiento_pregunta_id es la clave
        self.respuestas_usuario[pregunta_examen_id][str(par_id_original)] = {
            'seleccion_b': seleccion_b_texto # Solo guardamos la selección del usuario para la parte B
        }
        print(f"Rpta EMPAREJAR P_Examen_ID {pregunta_examen_id}: {self.respuestas_usuario.get(pregunta_examen_id)}")


    def guardar_respuesta_ordenar(self, pregunta_examen_id):
        # RESPUESTAS_ESTUDIANTES[cite: 37], RESPUESTAS_ORDEN [cite: 41]
        orden_seleccionado_ids = [] # Lista de orden_pregunta_id
        orden_seleccionado_textos = []
        for i in range(self.list_widget_ordenar.count()):
            item = self.list_widget_ordenar.item(i)
            orden_seleccionado_ids.append(item.data(Qt.UserRole)) # orden_pregunta_id
            orden_seleccionado_textos.append(item.text())
        self.respuestas_usuario[pregunta_examen_id] = {
            'orden_seleccionado_ids': orden_seleccionado_ids,
            'orden_seleccionado_textos': orden_seleccionado_textos # Para reconstrucción de UI si es necesario
        }
        print(f"Rpta ORDENAR P_Examen_ID {pregunta_examen_id}: {self.respuestas_usuario.get(pregunta_examen_id)}")


    def actualizar_navegacion(self):
        total_preguntas = len(self.preguntas_examen)
        if total_preguntas == 0:
            self.lbl_progreso.setText("No hay preguntas.")
            self.btn_anterior.setEnabled(False)
            self.btn_siguiente.setEnabled(False)
            return

        self.lbl_progreso.setText(f"Pregunta {self.pregunta_actual_idx + 1} de {total_preguntas}")
        self.btn_anterior.setEnabled(self.pregunta_actual_idx > 0)
        self.btn_siguiente.setEnabled(self.pregunta_actual_idx < total_preguntas - 1)

    def mostrar_pregunta_siguiente(self):
        if self.pregunta_actual_idx < len(self.preguntas_examen) - 1:
            self.pregunta_actual_idx += 1
            self.mostrar_pregunta_actual()

    def mostrar_pregunta_anterior(self):
        if self.pregunta_actual_idx > 0:
            self.pregunta_actual_idx -= 1
            self.mostrar_pregunta_actual()

    def timerEvent(self, event):
        if self.tiempo_restante > 0:
            self.tiempo_restante -= 1
            self.actualizar_display_tiempo()
        else:
            if self.timer_examen:
                self.killTimer(self.timer_examen)
                self.timer_examen = None
            QMessageBox.warning(self, "Tiempo Terminado", "El tiempo para completar el examen ha finalizado. Tus respuestas serán enviadas.")
            self.terminar_intento(forzado_por_tiempo=True)

    def actualizar_display_tiempo(self):
        minutos = self.tiempo_restante // 60
        segundos = self.tiempo_restante % 60
        self.lbl_tiempo_restante.setText(f"Tiempo: {minutos:02d}:{segundos:02d}")

    def confirmar_terminar_intento(self):
        reply = QMessageBox.question(self, "Confirmar Envío",
                                     "¿Estás seguro de que deseas terminar y enviar tus respuestas?",
                                     QMessageBox.Yes | QMessageBox.No, QMessageBox.No)
        if reply == QMessageBox.Yes:
            self.terminar_intento()

    def terminar_intento(self, forzado_por_tiempo=False):
        if self.timer_examen:
            self.killTimer(self.timer_examen)
            self.timer_examen = None

        # Simulación de guardado en INTENTOS_EXAMEN [cite: 20] y tablas de respuestas relacionadas
        print(f"Terminando intento (Simulación) ID: {self.intento_id_simulado}. Respuestas del usuario:")
        for pregunta_examen_id, data_respuesta in self.respuestas_usuario.items():
            print(f"  Pregunta Examen ID {pregunta_examen_id} (de PREGUNTAS_EXAMENES): {data_respuesta}")
            # Aquí se harían los INSERTs en RESPUESTAS_ESTUDIANTES [cite: 37] y luego en las tablas específicas
            # como RESPUESTAS_OPCIONES, RESPUESTAS_COMPLETAR, etc. [cite: 39, 33, 35, 41]

        if not forzado_por_tiempo:
            QMessageBox.information(self, "Intento Terminado", "Tu examen ha sido enviado (simulación).")
        self.cerrar_vista()


class VentanaSeleccionExamen(VistaBaseWidget):
    def __init__(self, parent_main_app, parent=None):
        super().__init__(parent)
        self.parent_main_app = parent_main_app
        self.setObjectName("examSelectionWindow")
        self.setWindowTitle("Seleccionar Examen para Rendir")
        self.setMinimumSize(600, 300)
        self.init_ui()

    def init_ui(self):
        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(30, 30, 30, 30)
        main_layout.setSpacing(20)

        title_label = QLabel("Exámenes Disponibles")
        title_label.setProperty("class", "section-title")
        title_label.setAlignment(Qt.AlignCenter)
        main_layout.addWidget(title_label)

        self.cmb_examenes_disponibles = QComboBox()
        self.cmb_examenes_disponibles.setMinimumHeight(30)
        main_layout.addWidget(self.cmb_examenes_disponibles)

        self.lbl_fecha_limite = QLabel("Fecha límite para rendir:")
        self.lbl_fecha_limite.setVisible(False) # Oculto hasta que se seleccione un examen
        main_layout.addWidget(self.lbl_fecha_limite)

        main_layout.addSpacerItem(QSpacerItem(20, 30, QSizePolicy.Minimum, QSizePolicy.Expanding))

        self.btn_iniciar_examen = QPushButton("Iniciar Examen Seleccionado")
        self.btn_iniciar_examen.setMinimumHeight(40)
        self.btn_iniciar_examen.clicked.connect(self.iniciar_examen)

        self.btn_volver = QPushButton("Volver al Menú Principal")
        self.btn_volver.clicked.connect(self.cerrar_vista)


        button_layout = QHBoxLayout()
        button_layout.addStretch()
        button_layout.addWidget(self.btn_volver)
        button_layout.addWidget(self.btn_iniciar_examen)
        button_layout.addStretch()

        main_layout.addLayout(button_layout)
        main_layout.addStretch(1)
        self.cargar_examenes()
        self.cmb_examenes_disponibles.currentIndexChanged.connect(self.actualizar_info_examen_seleccionado)


    def cargar_examenes(self):
        self.cmb_examenes_disponibles.clear()
        self.cmb_examenes_disponibles.addItem("-- Seleccione un Examen --", None)
        if current_user and current_user.get('tipo') == 'ESTUDIANTE':
             # Simulación de EXAMENES.fecha_limite [cite: 13]
            examenes = obtener_examenes_disponibles_db(current_user['id'])
            if not examenes:
                self.cmb_examenes_disponibles.addItem("No hay exámenes disponibles actualmente.")
                self.btn_iniciar_examen.setEnabled(False)
            else:
                for ex_id, ex_nombre, ex_fecha_limite in examenes:
                    self.cmb_examenes_disponibles.addItem(ex_nombre, {'id': ex_id, 'fecha_limite': ex_fecha_limite})
                self.btn_iniciar_examen.setEnabled(True)
        else:
            self.cmb_examenes_disponibles.addItem("No disponible (requiere ser estudiante).")
            self.btn_iniciar_examen.setEnabled(False)
        self.actualizar_info_examen_seleccionado()


    def actualizar_info_examen_seleccionado(self):
        current_data = self.cmb_examenes_disponibles.currentData()
        if current_data and isinstance(current_data, dict) and 'fecha_limite' in current_data:
            fecha_limite = current_data['fecha_limite'] # EXAMENES.fecha_limite [cite: 13]
            if isinstance(fecha_limite, QDateTime) and fecha_limite.isValid():
                 self.lbl_fecha_limite.setText(f"Fecha límite para rendir: {fecha_limite.toString('dd/MM/yyyy hh:mm AP')}")
                 self.lbl_fecha_limite.setVisible(True)
                 if QDateTime.currentDateTime() > fecha_limite:
                     self.btn_iniciar_examen.setEnabled(False)
                     self.btn_iniciar_examen.setToolTip("La fecha límite para este examen ha pasado.")
                     self.lbl_fecha_limite.setStyleSheet("color: red; font-weight: bold;")
                 else:
                     self.btn_iniciar_examen.setEnabled(True)
                     self.btn_iniciar_examen.setToolTip("")
                     self.lbl_fecha_limite.setStyleSheet("")
            else:
                self.lbl_fecha_limite.setVisible(False)
        else:
            self.lbl_fecha_limite.setVisible(False)
            if self.cmb_examenes_disponibles.currentIndex() > 0 :
                self.btn_iniciar_examen.setEnabled(True)
            else:
                self.btn_iniciar_examen.setEnabled(False)


    def iniciar_examen(self):
        examen_data_seleccionado = self.cmb_examenes_disponibles.currentData()
        if examen_data_seleccionado and isinstance(examen_data_seleccionado, dict):
            examen_id = examen_data_seleccionado.get('id')
            fecha_limite = examen_data_seleccionado.get('fecha_limite') # EXAMENES.fecha_limite [cite: 13]

            if fecha_limite and isinstance(fecha_limite, QDateTime) and QDateTime.currentDateTime() > fecha_limite:
                QMessageBox.warning(self, "Examen Expirado", "La fecha límite para rendir este examen ha pasado.")
                return

            self.parent_main_app.mostrar_responder_examen(examen_id)
        elif examen_data_seleccionado:
             self.parent_main_app.mostrar_responder_examen(examen_data_seleccionado)
        else:
            QMessageBox.warning(self, "Sin Selección", "Por favor, selecciona un examen de la lista.")


class ExamApp(QMainWindow):
    def __init__(self, usuario_info):
        super().__init__()
        global current_user
        current_user = usuario_info # USUARIOS[cite: 58], TIPO_USUARIO [cite: 51]

        self.setWindowTitle(f"Sistema de Exámenes Interactivo - Usuario: {current_user.get('nombre', 'N/A')} ({current_user.get('tipo', 'N/A')})")
        self.setGeometry(50, 50, 1100, 750)
        self.central_widget_stack = QStackedWidget()
        self.setCentralWidget(self.central_widget_stack)

        self.init_vistas()
        self.create_menu()
        self.mostrar_bienvenida()


    def init_vistas(self):
        self.vista_bienvenida = QLabel(f"¡Bienvenido, {current_user.get('nombre', '')}!\n\nSelecciona una opción del menú para comenzar.")
        self.vista_bienvenida.setObjectName("welcomeLabel")
        self.vista_bienvenida.setAlignment(Qt.AlignCenter)
        self.central_widget_stack.addWidget(self.vista_bienvenida)


    def create_menu(self):
        menu_bar = self.menuBar()

        menu_archivo = menu_bar.addMenu("Archivo")
        accion_logout = QAction("Cerrar Sesión", self)
        accion_logout.triggered.connect(self.cerrar_sesion) # LOGS_ACTIVIDAD tipo 'SALIDA' [cite: 22, 46]
        menu_archivo.addAction(accion_logout)
        menu_archivo.addSeparator()
        accion_salir_app = QAction("Salir de la Aplicación", self)
        accion_salir_app.triggered.connect(self.close)
        menu_archivo.addAction(accion_salir_app)

        if current_user and current_user.get('tipo') == 'PROFESOR':
            menu_gestion_examenes = menu_bar.addMenu("Gestión de Exámenes")
            accion_crear_examen = QAction("Crear Nuevo Examen", self)
            accion_crear_examen.triggered.connect(self.mostrar_crear_examen)
            menu_gestion_examenes.addAction(accion_crear_examen)

            accion_config_preg_examen = QAction("Configurar Preguntas de Examen", self)
            accion_config_preg_examen.triggered.connect(self.mostrar_configurar_preguntas_examen)
            menu_gestion_examenes.addAction(accion_config_preg_examen)


            menu_gestion_preguntas = menu_bar.addMenu("Gestión de Preguntas")
            accion_crear_pregunta = QAction("Crear Nueva Pregunta", self)
            accion_crear_pregunta.triggered.connect(self.mostrar_crear_pregunta)
            menu_gestion_preguntas.addAction(accion_crear_pregunta)

            accion_gestionar_preguntas = QAction("Gestionar Preguntas Creadas", self)
            accion_gestionar_preguntas.triggered.connect(self.mostrar_gestionar_preguntas)
            menu_gestion_preguntas.addAction(accion_gestionar_preguntas)


        if current_user and current_user.get('tipo') == 'ESTUDIANTE':
            menu_rendir_examen = menu_bar.addMenu("Exámenes")
            accion_seleccionar_examen = QAction("Rendir Examen", self)
            accion_seleccionar_examen.triggered.connect(self.mostrar_seleccion_examen)
            menu_rendir_examen.addAction(accion_seleccionar_examen)

    def _cambiar_vista_central(self, widget_instance_creator_func):
        # Limpiar vistas anteriores que no sean la de bienvenida
        widgets_a_remover = []
        for i in range(self.central_widget_stack.count()):
            widget = self.central_widget_stack.widget(i)
            if widget != self.vista_bienvenida:
                widgets_a_remover.append(widget)

        for widget in widgets_a_remover:
            if isinstance(widget, VistaBaseWidget):
                try:
                    widget.vista_cerrada.disconnect()
                except TypeError: pass # No connections
            self.central_widget_stack.removeWidget(widget)
            widget.deleteLater()

        nueva_vista = widget_instance_creator_func(self) # El 'parent' es ExamApp
        if isinstance(nueva_vista, VistaBaseWidget):
             nueva_vista.vista_cerrada.connect(self.mostrar_bienvenida_y_limpiar_emisor)

        if self.central_widget_stack.indexOf(nueva_vista) == -1: # Evitar añadir duplicados si ya existe por alguna razón
            self.central_widget_stack.addWidget(nueva_vista)
        self.central_widget_stack.setCurrentWidget(nueva_vista)

    def mostrar_bienvenida_y_limpiar_emisor(self):
        emisor = self.sender()
        self.mostrar_bienvenida() # Muestra la bienvenida
        if emisor and emisor != self.vista_bienvenida and isinstance(emisor, VistaBaseWidget):
            if self.central_widget_stack.indexOf(emisor) != -1: # Asegurarse que todavía está en el stack
                self.central_widget_stack.removeWidget(emisor)
            emisor.deleteLater()


    def mostrar_bienvenida(self):
        # Asegurar que solo la vista de bienvenida quede si otras se cerraron
        widgets_a_remover = []
        for i in range(self.central_widget_stack.count()):
            widget = self.central_widget_stack.widget(i)
            if widget != self.vista_bienvenida and widget is not None:
                 widgets_a_remover.append(widget)
        
        for widget in widgets_a_remover:
            if isinstance(widget, VistaBaseWidget):
                try: widget.vista_cerrada.disconnect()
                except: pass
            self.central_widget_stack.removeWidget(widget)
            widget.deleteLater()
            
        self.central_widget_stack.setCurrentWidget(self.vista_bienvenida)


    def mostrar_crear_examen(self):
        self._cambiar_vista_central(VentanaCrearExamen)

    def mostrar_crear_pregunta(self):
        self._cambiar_vista_central(VentanaCrearPregunta)

    def mostrar_seleccion_examen(self):
        self._cambiar_vista_central(lambda parent: VentanaSeleccionExamen(parent_main_app=self, parent=parent))


    def mostrar_responder_examen(self, examen_id):
        # Limpiar la vista actual (que sería VentanaSeleccionExamen) antes de mostrar VentanaResponderExamen
        current_idx = self.central_widget_stack.currentIndex()
        if current_idx != -1:
            current_widget = self.central_widget_stack.widget(current_idx)
            if current_widget != self.vista_bienvenida and isinstance(current_widget, VistaBaseWidget):
                try: current_widget.vista_cerrada.disconnect()
                except TypeError: pass
                self.central_widget_stack.removeWidget(current_widget)
                current_widget.deleteLater()

        ventana_responder = VentanaResponderExamen(examen_id, self)
        # Al cerrar VentanaResponderExamen, queremos volver a la selección de examen.
        ventana_responder.vista_cerrada.connect(lambda: self._cambiar_vista_central(lambda p: VentanaSeleccionExamen(self, p)))

        if self.central_widget_stack.indexOf(ventana_responder) == -1:
            self.central_widget_stack.addWidget(ventana_responder)
        self.central_widget_stack.setCurrentWidget(ventana_responder)


    def mostrar_gestionar_preguntas(self):
        self._cambiar_vista_central(VentanaGestionarPreguntas)

    def mostrar_configurar_preguntas_examen(self):
        self._cambiar_vista_central(VentanaConfigurarPreguntasExamen)


    def cerrar_sesion(self):
        # LOGS_ACTIVIDAD tipo 'SALIDA' [cite: 22, 46]
        print(f"Cerrando sesión para usuario {current_user.get('id') if current_user else 'N/A'}")
        self.close() # Esto cerrará ExamApp. MainApplicationController debería manejar el reinicio del login.
        # Emitir una señal para que MainApplicationController sepa que debe reiniciar el login
        if hasattr(self, 'sesion_cerrada_signal'): # Si se define esta señal
            self.sesion_cerrada_signal.emit()


class LoginWindow(QWidget):
    login_exitoso = pyqtSignal(dict)

    def __init__(self):
        super().__init__()
        self.setObjectName("loginWindow")
        self.init_ui()

    def init_ui(self):
        self.setWindowTitle("Login - Sistema de Exámenes")
        self.setFixedSize(400, 320)

        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(35, 35, 35, 35)
        main_layout.setSpacing(20)
        main_layout.setAlignment(Qt.AlignCenter)

        title_label = QLabel("Sistema de Exámenes")
        title_label.setObjectName("loginTitleLabel")
        title_label.setAlignment(Qt.AlignCenter)
        main_layout.addWidget(title_label)

        form_layout = QFormLayout()
        form_layout.setSpacing(12)
        form_layout.setLabelAlignment(Qt.AlignRight)

        self.username_input = QLineEdit()
        self.username_input.setPlaceholderText("usuario@dominio.com")
        form_layout.addRow(QLabel("Email:"), self.username_input)

        self.password_input = QLineEdit()
        self.password_input.setPlaceholderText("Contraseña")
        self.password_input.setEchoMode(QLineEdit.Password)
        form_layout.addRow(QLabel("Contraseña:"), self.password_input)
        main_layout.addLayout(form_layout)

        main_layout.addSpacerItem(QSpacerItem(20, 15, QSizePolicy.Minimum, QSizePolicy.Fixed))

        self.login_button = QPushButton("Iniciar Sesión")
        self.login_button.clicked.connect(self.verify_login)
        self.login_button.setFixedHeight(35)
        main_layout.addWidget(self.login_button)

        self.status_label = QLabel("")
        self.status_label.setAlignment(Qt.AlignCenter)
        self.status_label.setStyleSheet("color: red;")
        main_layout.addWidget(self.status_label)

        main_layout.addStretch(1)

    def verify_login(self):
        email = self.username_input.text().strip()
        password = self.password_input.text()

        # Simulación de la tabla USUARIOS [cite: 58] y TIPO_USUARIO [cite: 51]
        usuario_simulado = None
        if email == "profesor" and password == "123":
            # LOGS_ACTIVIDAD tipo 'ENTRADA' [cite: 22, 46]
            usuario_simulado = {'id': 1, 'nombre': 'Ana María', 'apellido': 'Pérez', 'email': email, 'tipo_usuario_id': 2, 'tipo': 'PROFESOR'}
        elif email == "estudiante" and password == "123":
            # LOGS_ACTIVIDAD tipo 'ENTRADA' [cite: 22, 46]
            usuario_simulado = {'id': 5, 'nombre': 'Carlos José', 'apellido': 'López', 'email': email, 'tipo_usuario_id': 1, 'tipo': 'ESTUDIANTE'}

        if usuario_simulado:
            print(f"Login exitoso para: {usuario_simulado['email']}, Tipo: {usuario_simulado['tipo']}")
            self.status_label.setText("")
            self.login_exitoso.emit(usuario_simulado)
            self.close()
        else:
            self.status_label.setText("Email o contraseña incorrectos.")
            print(f"Login fallido para: {email}")


class MainApplicationController:
    def __init__(self):
        self.login_window = None
        self.main_app_window = None
        self.start_login()

    def start_login(self):
        if self.main_app_window:
            self.main_app_window.close() # Asegurarse de cerrar la ventana anterior
            self.main_app_window.deleteLater()
            self.main_app_window = None

        self.login_window = LoginWindow()
        self.login_window.login_exitoso.connect(self.show_main_application)
        self.login_window.show()

    def show_main_application(self, usuario_info):
        if self.login_window:
            self.login_window.deleteLater()
            self.login_window = None

        self.main_app_window = ExamApp(usuario_info)
        # Conectar la señal de cierre de sesión de ExamApp a handle_logout
        # ExamApp necesita definir `sesion_cerrada_signal = pyqtSignal()`
        # self.main_app_window.sesion_cerrada_signal.connect(self.handle_logout)
        # Por ahora, si ExamApp se cierra (incluso por logout), la app termina.
        # Para un verdadero ciclo, ExamApp.close() en cerrar_sesion
        # debería ser reemplazado por la emisión de una señal que MainApplicationController capture.
        # Y el MainApplicationController no debería dejar que app.exec_() termine hasta que realmente se quiera salir de todo.
        self.main_app_window.showMaximized()

    def handle_logout(self): # Llamado cuando ExamApp emite la señal de logout
        print("MainApplicationController: Logout detectado, reiniciando login.")
        self.start_login()


if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setApplicationName("Sistema Interactivo de Exámenes")

    stylesheet = load_stylesheet()
    if stylesheet:
        app.setStyleSheet(stylesheet)

    # Para un ciclo de login-app-logout-login más robusto:
    # ExamApp.cerrar_sesion() debería emitir una señal.
    # MainApplicationController.show_main_application() conectaría esa señal a MainApplicationController.handle_logout().
    # ExamApp.close() en cerrar_sesion() debería evitarse si se quiere volver al login sin cerrar la aplicación.

    # Esta es una forma de manejar el reinicio al login si ExamApp se cierra.
    # Es un poco básico porque no distingue entre un cierre de sesión y un cierre de ventana.
    # Para el ejercicio actual, `ExamApp.close()` en `cerrar_sesion` terminará `app.exec_()`
    # si `controller` no mantiene viva la aplicación de alguna manera.

    controller = MainApplicationController() # Inicia el login

    # Si queremos que la aplicación vuelva al login después de que ExamApp se cierre (por logout):
    # Esto es un hack simple. Una mejor manera es usar señales entre ExamApp y MainApplicationController.
    # El problema es que `app.exec_()` bloqueará. Necesitamos una manera de reentrar al bucle de login.

    # La lógica actual:
    # 1. Controller crea LoginWindow.
    # 2. LoginWindow emite login_exitoso.
    # 3. Controller crea ExamApp, LoginWindow se cierra.
    # 4. Si ExamApp.cerrar_sesion() llama a self.close(), y es la última ventana, app.exec_() termina.

    # Para el ciclo login->app->login:
    # En ExamApp:
    #   sesion_cerrada = pyqtSignal()
    #   def cerrar_sesion(self): ... self.sesion_cerrada.emit(); self.hide() # O self.close() si el controller lo maneja
    # En MainApplicationController:
    #   def show_main_application(self, usuario_info):
    #       ...
    #       self.main_app_window.sesion_cerrada.connect(self.start_login) # o self.handle_logout
    #       self.main_app_window.showMaximized()
    #
    #   def handle_logout(self): # Esta función se conecta a la señal de logout
    #       if self.main_app_window:
    #           self.main_app_window.deleteLater() # Elimina la ventana de la app
    #           self.main_app_window = None
    #       self.start_login() # Muestra la ventana de login de nuevo

    original_excepthook = sys.excepthook
    def new_excepthook(type, value, traceback):
        print(f"Excepción no controlada: {type}, {value}")
        QMessageBox.critical(None, "Error Inesperado", f"Ha ocurrido un error:\n{type.__name__}: {value}\nConsulte la consola para más detalles.")
        original_excepthook(type, value, traceback)
    sys.excepthook = new_excepthook

    sys.exit(app.exec_())