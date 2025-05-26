import sys
import os
import random
import hashlib # For password hashing
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
from database import get_connection


from dao import (
    GrupoDAO, TemaDAO, TipoPreguntaDAO, ExamenDAO, PreguntaDAO,
    PreguntasExamenesDAO, OpcionesPreguntasDAO, CompletarPreguntasDAO,
    CompletarEspaciosDAO, EmparejamientoPreguntasDAO, OrdenPreguntasDAO,
    UsuarioDAO, LogActividadDAO, IntentoExamenDAO,
    RespuestasEstudiantesDAO, RespuestasOpcionesDAO, RespuestasCompletarDAO,
    RespuestasEmparejamientoDAO, RespuestasOrdenDAO, TipoUsuarioDAO, InscripcionDAO
)
from dto import (
    ExamenesDTO, PreguntasDTO, PreguntasExamenesDTO, OpcionesPreguntasDTO, # etc.
    LogsActividadDTO, IntentosExamenDTO, RespuestasEstudiantesDTO, OrdenPreguntasDTO, CompletarEspaciosDTO,
    CompletarPreguntasDTO, EmparejamientoPreguntasDTO, UsuariosDTO # etc.
)


# --- Configuración Global ---
STYLESHEET_PATH = os.path.join(os.path.dirname(__file__), "styles.css")
current_user = None # Se establecerá después del login (esperado como UsuarioDTO)

# --- Funciones de Interacción con Base de Datos (Reemplazadas) ---

def obtener_grupos_db():
    """
    Obtiene los grupos disponibles para el profesor actual.
    Debería obtener datos de la tabla GRUPOS. [cite: 16]
    """
    print("Obteniendo grupos desde la BD...")
    try:
        conn = get_connection()
        grupo_dao = GrupoDAO(conn)
        grupos = grupo_dao.obtener_por_profesor_id(current_user.usuario_id) # Ajustar método según DAO
        conn.close() # O manejar conexión de forma centralizada
        return grupos

    except Exception as e:
        print(f"Error en obtener_grupos_db: {e}")
        QMessageBox.critical(None, "Error de Base de Datos", f"No se pudieron cargar los grupos: {e}")
        return []

def obtener_temas_db():
    """
    Obtiene todos los temas de la base de datos.
    De la tabla TEMAS. [cite: 43]
    """
    print("Obteniendo temas desde la BD...")
    try:
        conn = get_connection()
        tema_dao = TemaDAO(conn)
        temas = tema_dao.obtener_todos()
        conn.close()
        return temas
    except Exception as e:
        print(f"Error en obtener_temas_db: {e}")
        QMessageBox.critical(None, "Error de Base de Datos", f"No se pudieron cargar los temas: {e}")
        return []


def obtener_tipos_pregunta_db():
    """
    Obtiene los tipos de pregunta de la base de datos.
    De la tabla TIPO_PREGUNTAS. [cite: 48]
    """
    print("Obteniendo tipos de pregunta desde la BD...")
    try:
        conn = get_connection()
        tipo_pregunta_dao = TipoPreguntaDAO(conn)
        tipos = tipo_pregunta_dao.obtener_todos()
        conn.close()
        return tipos
    except Exception as e:
        print(f"Error en obtener_tipos_pregunta_db: {e}")
        QMessageBox.critical(None, "Error de Base de Datos", f"No se pudieron cargar los tipos de pregunta: {e}")
        return []

def obtener_examenes_disponibles_db(estudiante_id):
    """
    Obtiene los exámenes disponibles para un estudiante.
    Involucra INSCRIPCIONES[cite: 18], GRUPOS[cite: 16], EXAMENES[cite: 12].
    Filtra por fechas de disponibilidad y límite. [cite: 13]
    """
    print(f"Obteniendo exámenes para estudiante {estudiante_id} desde la BD...")
    try:
        conn = get_connection()
        examen_dao = ExamenDAO(conn) # Asumiendo un método que maneja la lógica compleja
        examenes = examen_dao.obtener_examenes_disponibles_para_estudiante(estudiante_id)
        conn.close()
        return examenes
    except Exception as e:
        print(f"Error en obtener_examenes_disponibles_db: {e}")
        QMessageBox.critical(None, "Error de Base de Datos", f"No se pudieron cargar los exámenes disponibles: {e}")
        return []


def obtener_info_examen_db(examen_id):
    """
    Obtiene la información detallada de un examen.
    De la tabla EXAMENES. [cite: 12]
    """
    print(f"Obteniendo info para el examen {examen_id} desde la BD...")
    try:
        conn = get_connection()
        examen_dao = ExamenDAO(conn)
        ex_dto = examen_dao.obtener_por_id(examen_id)
        conn.close()
        if ex_dto:
            return {
                'id': ex_dto.examen_id,
                'descripcion': ex_dto.descripcion,
                'tiempo_limite': ex_dto.tiempo_limite,
                'cantidad_preguntas_mostrar': ex_dto.cantidad_preguntas_mostrar,
                'aleatorizar_preguntas': ex_dto.aleatorizar_preguntas # Asumiendo 'S' o 'N'
            }
        return None
    except Exception as e:
        print(f"Error en obtener_info_examen_db: {e}")
        QMessageBox.critical(None, "Error de Base de Datos", f"No se pudo cargar la información del examen: {e}")
        return None


def obtener_preguntas_examen_db(examen_id):
    """
    Obtiene las preguntas configuradas para un examen específico, listas para ser respondidas.
    Esto implica obtener datos de PREGUNTAS_EXAMENES[cite: 31], PREGUNTAS[cite: 28], y sus tablas relacionadas
    (OPCIONES_PREGUNTAS[cite: 24], COMPLETAR_PREGUNTAS [cite: 3] -> COMPLETAR_ESPACIOS[cite: 1], etc.).
    La estructura de retorno debe ser una lista de diccionarios, cada uno representando
    una pregunta completamente formada con sus opciones/partes.
    """

    print(f"Obteniendo preguntas para el examen {examen_id} desde la BD...")
    try:
        conn = get_connection()
        pregunta_examen_dao = PreguntasExamenesDAO(conn)
        preguntas_dto_completas = pregunta_examen_dao.obtener_preguntas_formateadas_para_rendir(examen_id)
        conn.close()
        return preguntas_dto_completas # Asumiendo que el DAO devuelve la estructura ya formateada
    except Exception as e:
        print(f"Error en obtener_preguntas_examen_db: {e}")
        QMessageBox.critical(None, "Error de Base de Datos", f"No se pudieron cargar las preguntas del examen: {e}")
        return []


def obtener_todas_las_preguntas_db():
    """
    Obtiene todas las preguntas del banco para la gestión de preguntas.
    De PREGUNTAS[cite: 28], uniendo con TEMAS[cite: 43], TIPO_PREGUNTAS[cite: 48], USUARIOS (creador)[cite: 58].
    """
    print("Obteniendo TODAS las preguntas del banco desde la BD...")
    try:
        conn = get_connection()
        pregunta_dao = PreguntaDAO(conn)
        preguntas_dto = pregunta_dao.obtener_todas_con_detalles_completos()
        conn.close()
        resultado = []
        for p in preguntas_dto:
            resultado.append({
                'id': p['id'],
                'texto': p['texto'],
                'tipo': p['tipo'],
                'tipo_id_simulado': p['tipo_id_simulado'],
                'tema': p['tema'],
                'tema_id_simulado': p['tema_id_simulado'],
                'creador': p['creador'],
            })
        return resultado
    except Exception as e:
        print(f"Error en obtener_todas_las_preguntas_db: {e}")
        QMessageBox.critical(None, "Error de Base de Datos", f"No se pudieron cargar todas las preguntas: {e}")
        return []

def obtener_examenes_profesor_db(profesor_id):
    """
    Obtiene los exámenes creados por un profesor específico.
    De EXAMENES[cite: 12], filtrando por creador_id.
    """
    print(f"Obteniendo exámenes para profesor {profesor_id} desde la BD...")
    try:
        conn = get_connection()
        examen_dao = ExamenDAO(conn)
        examenes = examen_dao.obtener_por_creador_id(profesor_id)
        conn.close()
        return examenes
    except Exception as e:
        print(f"Error en obtener_examenes_profesor_db: {e}")
        QMessageBox.critical(None, "Error de Base de Datos", f"No se pudieron cargar los exámenes del profesor: {e}")
        return []

def obtener_preguntas_asociadas_examen_db(examen_id):
    """
    Obtiene las preguntas asociadas a un examen con su peso y orden.
    De PREGUNTAS_EXAMENES [cite: 31] uniendo con PREGUNTAS [cite: 28] para el texto.
    """

    print(f"Obteniendo preguntas ASOCIADAS al examen {examen_id} desde la BD...")
    try:
        conn = get_connection()
        pe_dao = PreguntasExamenesDAO(conn)
        preguntas_asociadas_dto = pe_dao.obtener_detalles_por_examen_id(examen_id)
        conn.close()
        return [{
            'id': pa['id'], # ID de la pregunta original
            'texto': pa['texto'], # Texto de la pregunta
            'peso': pa['peso'],
            'orden': pa['orden']
        } for pa in preguntas_asociadas_dto]
    except Exception as e:
        print(f"Error en obtener_preguntas_asociadas_examen_db: {e}")
        QMessageBox.critical(None, "Error de Base de Datos", f"No se pudieron cargar las preguntas asociadas al examen: {e}")
        return []


def guardar_asociacion_preguntas_examen_db(examen_id, preguntas_asociadas_data):
    """
    Guarda (o reemplaza) las asociaciones de preguntas para un examen.
    Implica eliminar las asociaciones existentes para el examen_id en PREGUNTAS_EXAMENES [cite: 31]
    y luego insertar las nuevas.
    preguntas_asociadas_data es una lista de dicts: [{'pregunta_id': PID, 'peso': P, 'orden': O}, ...]
    """

    print(f"Guardando asociación para examen {examen_id} en BD: {preguntas_asociadas_data}")
    try:
        conn = get_connection()
        pe_dao = PreguntasExamenesDAO(conn)
        dtos_a_guardar = []
        for data_item in preguntas_asociadas_data:
            dto = PreguntasExamenesDTO(
                pregunta_examen_id=None, # Autogenerado o no necesario para inserción
                examen_id=examen_id,
                pregunta_id=data_item['pregunta_id'],
                peso=data_item['peso'],
                orden=data_item['orden']
            )
            dtos_a_guardar.append(dto)
        
        success = pe_dao.reemplazar_asociaciones_por_examen_id(examen_id, dtos_a_guardar)
        conn.close() # O manejar transacciones
        return success
    except Exception as e:
        print(f"Error en guardar_asociacion_preguntas_examen_db: {e}")
        QMessageBox.critical(None, "Error de Base de Datos", f"No se pudo guardar la asociación de preguntas: {e}")
        return False

def guardar_examen_db(examen_data_dict, preguntas_aleatorias_asociadas_data=None):
    """
    Guarda un nuevo examen en la tabla EXAMENES [cite: 12] y opcionalmente
    asocia preguntas en PREGUNTAS_EXAMENES. [cite: 31]
    """

    print(f"--- Guardando Examen en BD ---")
    print(f"Datos del Examen: {examen_data_dict}")
    try:
        conn = get_connection()
        examen_dao = ExamenDAO(conn)
        examen_dto = ExamenesDTO(
            examen_id=None, # Autogenerado
            descripcion=examen_data_dict['descripcion'],
            fecha_creacion=QDateTime.fromString(examen_data_dict['fecha_creacion'], Qt.ISODate).toString('yyyy-MM-dd HH:mm:ss'), # Ajustar formato para Oracle TIMESTAMP
            fecha_disponible=QDateTime.fromString(examen_data_dict['fecha_disponible'], Qt.ISODate).toString('yyyy-MM-dd HH:mm:ss'),
            fecha_limite=QDateTime.fromString(examen_data_dict['fecha_limite'], Qt.ISODate).toString('yyyy-MM-dd HH:mm:ss'),
            tiempo_limite=examen_data_dict['tiempo_limite'],
            peso=examen_data_dict['peso'],
            umbral_aprobacion=examen_data_dict['umbral_aprobacion'],
            cantidad_preguntas_mostrar=examen_data_dict['cantidad_preguntas_mostrar'],
            aleatorizar_preguntas=examen_data_dict['aleatorizar_preguntas'],
            creador_id=examen_data_dict['creador_id'],
            grupo_id=examen_data_dict['grupo_id']
        )
        nuevo_examen_id = examen_dao.insertar(examen_dto) # DAO debe retornar el ID del nuevo examen
        
        if nuevo_examen_id and preguntas_aleatorias_asociadas_data:
            print(f"Examen ID Creado: {nuevo_examen_id}")
            print(f"Asociando preguntas aleatorias (para PREGUNTAS_EXAMENES):")
            dtos_preg_examen = []
            for preg_asoc_data in preguntas_aleatorias_asociadas_data:
                dtos_preg_examen.append(PreguntasExamenesDTO(
                    pregunta_examen_id=None,
                    examen_id=nuevo_examen_id,
                    pregunta_id=preg_asoc_data['pregunta_id'],
                    peso=preg_asoc_data['peso'],
                    orden=preg_asoc_data['orden']
                ))
            pe_dao = PreguntasExamenesDAO(conn)
            pe_dao.insertar_batch(dtos_preg_examen) # Asumiendo un método para inserción múltiple
        elif not nuevo_examen_id:
            raise Exception("No se pudo obtener el ID del nuevo examen.")
        
        conn.close() # O manejar transacciones
        print(f"--- Fin Guardado Examen BD ---")
        return True
    except Exception as e:
        print(f"Error en guardar_examen_db: {e}")
        QMessageBox.critical(None, "Error de Base de Datos", f"No se pudo guardar el examen: {e}")
        return False


def guardar_pregunta_completa_db(pregunta_general_data, detalles_tipo_data):
    """
    Guarda una nueva pregunta y sus detalles específicos según el tipo.
    PREGUNTAS[cite: 28], OPCIONES_PREGUNTAS[cite: 24], COMPLETAR_PREGUNTAS[cite: 3], COMPLETAR_ESPACIOS[cite: 1],
    EMPAREJAMIENTO_PREGUNTAS[cite: 7], ORDEN_PREGUNTAS[cite: 26].
    """
    print(f"Guardando Pregunta Completa en BD: General={pregunta_general_data}, Detalles={detalles_tipo_data}")
    try:
        conn = get_connection()
        pregunta_dao = PreguntaDAO(conn)
        
        # # 1. Guardar en PREGUNTAS
        pregunta_dto = PreguntasDTO(
            pregunta_id=None, # Autogenerado
            texto=pregunta_general_data['texto_pregunta'],
            fecha_creacion=QDateTime.currentDateTime().toString('yyyy-MM-dd HH:mm:ss'), # Ajustar formato
            es_publica=pregunta_general_data['es_publica'],
            tiempo_maximo=pregunta_general_data['tiempo_maximo'],
            pregunta_padre_id=None, # No implementado en UI
            tipo_pregunta_id=pregunta_general_data['tipo_pregunta_id'],
            creador_id=pregunta_general_data['creador_id'],
            tema_id=pregunta_general_data['tema_id']
        )
        nueva_pregunta_id = pregunta_dao.insertar(pregunta_dto) # DAO debe retornar el ID
        
        if not nueva_pregunta_id:
            raise Exception("No se pudo obtener el ID de la nueva pregunta.")
        
        tipo_pregunta_texto = pregunta_general_data['tipo_pregunta_texto']
        
        # # 2. Guardar detalles específicos del tipo
        if tipo_pregunta_texto in ["OPCION_UNICA", "OPCION_MULTIPLE", "VERDADERO_FALSO"]:
            op_dao = OpcionesPreguntasDAO(conn)
            opciones_dtos = []
            for op_data in detalles_tipo_data.get('opciones', []):
                opciones_dtos.append(OpcionesPreguntasDTO(
                    opcion_pregunta_id=None,
                    pregunta_id=nueva_pregunta_id,
                    texto=op_data['texto'],
                    es_correcta=op_data['es_correcta'],
                    orden=op_data['orden']
                ))
            if opciones_dtos: op_dao.insertar_batch(opciones_dtos)
        
        elif tipo_pregunta_texto == "COMPLETAR":
            cp_dao = CompletarPreguntasDAO(conn)
            ce_dao = CompletarEspaciosDAO(conn)
            # Insertar en COMPLETAR_PREGUNTAS
            completar_pregunta_dto = CompletarPreguntasDTO( # Asumiendo DTO
                completar_pregunta_id=None,
                pregunta_id=nueva_pregunta_id,
                texto_con_espacios=detalles_tipo_data.get('texto_con_espacios')
            )
            nuevo_completar_pregunta_id = cp_dao.insertar(completar_pregunta_dto)
            if not nuevo_completar_pregunta_id:
                raise Exception("No se pudo guardar en COMPLETAR_PREGUNTAS.")
        
            espacios_dtos = []
            for esp_data in detalles_tipo_data.get('espacios', []):
                espacios_dtos.append(CompletarEspaciosDTO( # Asumiendo DTO
                    completar_espacio_id=None,
                    completar_pregunta_id=nuevo_completar_pregunta_id,
                    numero_espacio=esp_data['numero_espacio'],
                    texto_correcto=esp_data['texto_correcto']
                ))
            if espacios_dtos: ce_dao.insertar_batch(espacios_dtos)
        
        elif tipo_pregunta_texto == "EMPAREJAR":
            ep_dao = EmparejamientoPreguntasDAO(conn)
            pares_dtos = []
            for par_data in detalles_tipo_data.get('pares', []):
                pares_dtos.append(EmparejamientoPreguntasDTO( # Asumiendo DTO
                    emparejamiento_pregunta_id=None,
                    pregunta_id=nueva_pregunta_id,
                    opcion_a=par_data['opcion_a'],
                    opcion_b=par_data['opcion_b']
                ))
            if pares_dtos: ep_dao.insertar_batch(pares_dtos)
        
        elif tipo_pregunta_texto == "ORDENAR":
            op_dao = OrdenPreguntasDAO(conn)
            elementos_dtos = []
            for elem_data in detalles_tipo_data.get('elementos', []):
                elementos_dtos.append(OrdenPreguntasDTO( # Asumiendo DTO
                    orden_pregunta_id=None,
                    pregunta_id=nueva_pregunta_id,
                    texto=elem_data['texto'],
                    posicion_correcta=elem_data['posicion_correcta']
                ))
            if elementos_dtos: op_dao.insertar_batch(elementos_dtos)
        
        conn.close() # O manejar transacciones
        print("DEV_NOTE: Simulación exitosa de guardar_pregunta_completa_db")
        return True
    except Exception as e:
        print(f"Error en guardar_pregunta_completa_db: {e}")
        QMessageBox.critical(None, "Error de Base de Datos", f"No se pudo guardar la pregunta: {e}")
        return False

def eliminar_pregunta_db(pregunta_id):
    """
    Elimina una pregunta de la tabla PREGUNTAS [cite: 28] y sus datos asociados
    en tablas específicas de tipo (OPCIONES_PREGUNTAS, COMPLETAR_PREGUNTAS, etc.).
    Debe manejar dependencias, ej. si está en PREGUNTAS_EXAMENES. [cite: 31]
    """

    print(f"Eliminando pregunta ID: {pregunta_id} desde la BD...")
    try:
        conn = get_connection()
        pregunta_dao = PreguntaDAO(conn) # El DAO debería manejar la eliminación en cascada o verificar dependencias
        
        # # Antes de eliminar, verificar si la pregunta está asociada a algún examen
        pe_dao = PreguntasExamenesDAO(conn)
        if pe_dao.existe_asociacion_con_pregunta(pregunta_id):
            conn.close()
            QMessageBox.warning(None, "Eliminación Bloqueada",
                                f"La pregunta ID {pregunta_id} está siendo utilizada en uno o más exámenes y no puede ser eliminada.")
            return False
        
        # # Si no hay asociaciones, proceder a eliminar (el DAO de Pregunta debe manejar sus tablas hijas como OPCIONES_PREGUNTAS, etc.)
        success = pregunta_dao.eliminar_completa(pregunta_id) # Asume que este método borra de PREGUNTAS y tablas relacionadas
        conn.close()
        return success
    except Exception as e:
        print(f"Error en eliminar_pregunta_db: {e}")
        QMessageBox.critical(None, "Error de Base de Datos", f"No se pudo eliminar la pregunta: {e}")
        return False

# --- Fin Funciones de Interacción con Base de Datos ---

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
        # En una app real, el main_app (ExamApp) podría pasar la conexión
        # o cada vista podría obtener una nueva conexión si es necesario.
        # self.db_connection = parent.db_connection if hasattr(parent, 'db_connection') else get_db_connection()


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
        self.db_connection = get_connection()  # Obtener conexión a la BD
        self.examen_dao = ExamenDAO(self.db_connection)
        self.grupo_dao = GrupoDAO(self.db_connection)
        self.tema_dao = TemaDAO(self.db_connection)
        self.pregunta_dao = PreguntaDAO(self.db_connection)
        self.preguntas_examen_dao = PreguntasExamenesDAO(self.db_connection)
        self.init_ui()

    def init_ui(self):
        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(20, 20, 20, 20)
        main_layout.setSpacing(15)

        scroll_area_details = QScrollArea(self)
        scroll_area_details.setWidgetResizable(True)
        scroll_area_details.setObjectName("formSectionScrollArea")

        self.group_details = QGroupBox("Detalles Generales del Examen")
        layout_details = QFormLayout(self.group_details)
        layout_details.setSpacing(10)
        layout_details.setContentsMargins(15, 20, 15, 15)
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
        
        scroll_area_details.setWidget(self.group_details)
        main_layout.addWidget(scroll_area_details, 1)


        scroll_area_config = QScrollArea(self)
        scroll_area_config.setWidgetResizable(True)
        scroll_area_config.setObjectName("formSectionScrollArea")

        self.group_questions_config = QGroupBox("Configuración de Preguntas del Examen")
        layout_questions_config = QVBoxLayout(self.group_questions_config) 
        layout_questions_config.setSpacing(10)
        layout_questions_config.setContentsMargins(15, 20, 15, 15)

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

        scroll_area_config.setWidget(self.group_questions_config)
        main_layout.addWidget(scroll_area_config, 1)


        buttons_layout = QHBoxLayout()
        buttons_layout.setSpacing(10)
        buttons_layout.addStretch(1)
        self.btn_guardar = QPushButton("Guardar Examen")
        self.btn_guardar.clicked.connect(self.guardar_examen)

        self.btn_cancelar = QPushButton("Cancelar")
        self.btn_cancelar.clicked.connect(self.cerrar_vista)

        buttons_layout.addWidget(self.btn_cancelar)
        buttons_layout.addWidget(self.btn_guardar)
        main_layout.addLayout(buttons_layout, 0)

        self.cargar_combos()
        if not self._lista_combos_temas_aleatorizar: 
            self.anadir_combo_tema_aleatorizar()


    def toggle_config_aleatoria_visibility(self, checked):
        self.widget_config_aleatoria.setVisible(checked)

    def anadir_combo_tema_aleatorizar(self):
        combo_container_widget = QWidget()
        combo_layout = QHBoxLayout(combo_container_widget)
        combo_layout.setContentsMargins(0,0,0,0)
        combo_layout.setSpacing(5)

        cmb_tema_select = QComboBox()
        cmb_tema_select.addItem("-- Seleccione Tema --", None)
        temas = obtener_temas_db() # USA LA FUNCIÓN REEMPLAZADA
        for tema_id, nombre_tema in temas:
            cmb_tema_select.addItem(nombre_tema, tema_id) # tema_id es el ID real de la BD

        btn_quitar_tema = QPushButton("X")
        btn_quitar_tema.setProperty("class", "small-action-button")
        btn_quitar_tema.setFixedSize(24, 24)
        btn_quitar_tema.setToolTip("Eliminar este tema de la aleatorización")
        btn_quitar_tema.clicked.connect(lambda: self.quitar_combo_tema_aleatorizar(combo_container_widget, cmb_tema_select))

        combo_layout.addWidget(cmb_tema_select, 1)
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
        grupos = obtener_grupos_db() # USA LA FUNCIÓN REEMPLAZADA [cite: 16]
        for grupo_id, nombre_grupo in grupos:
            self.cmb_grupo.addItem(nombre_grupo, grupo_id) # grupo_id es el ID real

    def guardar_examen(self):
        descripcion = self.txt_descripcion.toPlainText().strip()
        # Para Oracle, las fechas/timestamps deben ser formateadas como strings 'YYYY-MM-DD HH24:MI:SS'
        # o pasadas como objetos datetime de Python si el driver lo maneja.
        # Qt.ISODate es 'YYYY-MM-DDTHH:MM:SS'. Necesitará ajuste para Oracle o usar objetos datetime.
        fecha_disponible_str = self.dte_fecha_disponible.dateTime().toString("yyyy-MM-dd HH:mm:ss")
        fecha_limite_str = self.dte_fecha_limite.dateTime().toString("yyyy-MM-dd HH:mm:ss")
        tiempo_limite = self.spn_tiempo_limite.value()
        peso = self.dsp_peso_examen.value()
        umbral = self.dsp_umbral_aprobacion.value()
        grupo_id = self.cmb_grupo.currentData()
        # Asumiendo que current_user es un DTO con atributo 'usuario_id'
        creador_id = current_user.usuario_id if current_user else -1


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

        examen_data_dict = {
            'descripcion': descripcion,
            'fecha_creacion': QDateTime.currentDateTime().toString("yyyy-MM-dd HH:mm:ss"),
            'fecha_disponible': fecha_disponible_str,
            'fecha_limite': fecha_limite_str,
            'tiempo_limite': tiempo_limite,
            'peso': peso,
            'umbral_aprobacion': umbral,
            'cantidad_preguntas_mostrar': cantidad_preguntas_a_mostrar,
            'aleatorizar_preguntas': aleatorizar_preguntas_creacion,
            'creador_id': creador_id,
            'grupo_id': grupo_id
        }
        print(f"Datos base del examen a guardar (para DTO): {examen_data_dict}")

        preguntas_aleatorias_para_asociar_data = []

        if aleatorizar_preguntas_creacion == 'S':
            temas_seleccionados_ids = []
            for cmb_tema in self._lista_combos_temas_aleatorizar:
                if cmb_tema.currentData() is not None:
                    temas_seleccionados_ids.append(cmb_tema.currentData()) # ID real del tema

            if not temas_seleccionados_ids:
                QMessageBox.warning(self, "Datos Incompletos", "Si aleatoriza preguntas, debe seleccionar al menos un tema.")
                return
            if cantidad_preguntas_a_mostrar <= 0:
                QMessageBox.warning(self, "Datos Incompletos", "La cantidad de preguntas a mostrar debe ser mayor que cero si se aleatoriza.")
                self.spn_cantidad_preguntas.setFocus()
                return

            print(f"Aleatorización activada. Temas IDs: {temas_seleccionados_ids}, Cantidad: {cantidad_preguntas_a_mostrar}")

            # En lugar de obtener_todas_las_preguntas_db() y filtrar cliente:
            # Se debe llamar a un DAO que filtre por temas en la BD.
            preguntas_candidatas_dto = self.pregunta_dao.obtener_por_tema_ids(temas_seleccionados_ids)
            preguntas_candidatas = [
                p for p in preguntas_candidatas_dto
                if p['tema_id'] in temas_seleccionados_ids
            ]


            if len(preguntas_candidatas) < cantidad_preguntas_a_mostrar:
                QMessageBox.warning(self, "Preguntas Insuficientes",
                                    f"No hay suficientes preguntas ({len(preguntas_candidatas)}) en los temas seleccionados "
                                    f"para cubrir la cantidad solicitada ({cantidad_preguntas_a_mostrar}).")
                return

            preguntas_seleccionadas_aleatoriamente = random.sample(preguntas_candidatas, cantidad_preguntas_a_mostrar)
            peso_por_pregunta = round(100.0 / cantidad_preguntas_a_mostrar, 2) if cantidad_preguntas_a_mostrar > 0 else 0

            for i, preg_data in enumerate(preguntas_seleccionadas_aleatoriamente):
                preguntas_aleatorias_para_asociar_data.append({
                    'pregunta_id': preg_data['id'], # ID real de la pregunta
                    'peso': peso_por_pregunta,
                    'orden': i + 1
                })
            print(f"Preguntas seleccionadas aleatoriamente para asociar (datos para DTO): {preguntas_aleatorias_para_asociar_data}")

        # Guardar examen y, si aplica, sus preguntas asociadas
        # La función guardar_examen_db ahora tomaría los dicts y los convertiría a DTOs internamente o esperaría DTOs.
        if guardar_examen_db(examen_data_dict, preguntas_aleatorias_para_asociar_data if aleatorizar_preguntas_creacion == 'S' else None):
            QMessageBox.information(self, "Éxito", "Examen guardado en la base de datos.")
            self.cerrar_vista()
        else:
            QMessageBox.critical(self, "Error", "No se pudo guardar el examen en la base de datos.")


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

        self.db_connection = get_connection()  # Obtener conexión a la BD
        self.pregunta_dao = PreguntaDAO(self.db_connection)
        self.opciones_preguntas_dao = OpcionesPreguntasDAO(self.db_connection)
        self.completar_preguntas_dao = CompletarPreguntasDAO(self.db_connection)
        self.completar_espacios_dao = CompletarEspaciosDAO(self.db_connection)
        self.emparejamiento_preguntas_dao = EmparejamientoPreguntasDAO(self.db_connection)
        self.orden_preguntas_dao = OrdenPreguntasDAO(self.db_connection)
        self.tema_dao = TemaDAO(self.db_connection)
        self.tipo_pregunta_dao = TipoPreguntaDAO(self.db_connection)
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
        self.spn_tiempo_maximo.setRange(0, 3600) # En SEGUNDOS, tabla PREGUNTAS.tiempo_maximo [cite: 28]
        self.spn_tiempo_maximo.setSuffix(" segundos")
        self.spn_tiempo_maximo.setToolTip("0 significa sin límite de tiempo para esta pregunta.")
        layout_general_info.addRow(QLabel("Tiempo Máximo (opcional):"), self.spn_tiempo_maximo)

        self.cmb_tema = QComboBox()
        layout_general_info.addRow(QLabel("Tema de la Pregunta:"), self.cmb_tema) # Referencia a TEMAS.tema_id [cite: 29]

        self.cmb_tipo_pregunta = QComboBox()
        layout_general_info.addRow(QLabel("Tipo de Pregunta:"), self.cmb_tipo_pregunta) # Referencia a TIPO_PREGUNTAS.tipo_pregunta_id [cite: 28]

        self.scroll_area_general_info.setWidget(group_general_info)
        self.main_layout.addWidget(self.scroll_area_general_info, 0) # No stretch

        self.group_specific_details = QGroupBox("Detalles Específicos del Tipo de Pregunta")
        layout_specific_details = QVBoxLayout(self.group_specific_details)
        layout_specific_details.setContentsMargins(15, 15, 15, 15)
        layout_specific_details.setSpacing(10)

        self.stacked_widget_tipo_pregunta = QStackedWidget()
        layout_specific_details.addWidget(self.stacked_widget_tipo_pregunta)

        self.main_layout.addWidget(self.group_specific_details, 1) # Stretch

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
        self.actualizar_ui_tipo_pregunta() # Llama inicial para configurar UI

    def _crear_layout_dinamico_scrollable(self):
        scroll_area = QScrollArea()
        scroll_area.setWidgetResizable(True)
        scroll_area.setObjectName("dynamicContentScrollArea")
        container_widget = QWidget()
        dynamic_item_layout = QVBoxLayout(container_widget)
        dynamic_item_layout.setSpacing(8)
        dynamic_item_layout.addStretch(1) # Importante para que los elementos se añadan arriba
        scroll_area.setWidget(container_widget)
        return scroll_area, dynamic_item_layout


    def setup_widgets_tipos_pregunta(self):
        # Widget por defecto (índice 0)
        default_widget = QWidget()
        default_layout = QVBoxLayout(default_widget)
        lbl_info = QLabel("Seleccione un tipo de pregunta para configurar sus detalles.")
        lbl_info.setAlignment(Qt.AlignCenter)
        default_layout.addWidget(lbl_info)
        self.stacked_widget_tipo_pregunta.addWidget(default_widget)

        # Widget para OPCION_UNICA, OPCION_MULTIPLE, VERDADERO_FALSO (índice 1)
        # Usa self.opciones_items_layout
        self.widget_opciones = QWidget()
        opciones_main_layout = QVBoxLayout(self.widget_opciones)
        opciones_scroll_area, self.opciones_items_layout = self._crear_layout_dinamico_scrollable()
        opciones_main_layout.addWidget(opciones_scroll_area, 1) # Stretch scroll area
        self.btn_add_opcion = QPushButton("Añadir Opción")
        self.btn_add_opcion.setObjectName("addOptionButton")
        self.btn_add_opcion.clicked.connect(lambda: self.anadir_opcion_input_dinamico())
        opciones_main_layout.addWidget(self.btn_add_opcion, 0, Qt.AlignRight) # No stretch button
        self.stacked_widget_tipo_pregunta.addWidget(self.widget_opciones)


        # Widget para COMPLETAR (índice 2)
        # Usa self.completar_espacios_items_layout
        self.widget_completar = QWidget()
        completar_main_layout = QVBoxLayout(self.widget_completar)
        completar_main_layout.setContentsMargins(0,0,0,0) # Ajustar si es necesario
        completar_main_layout.setSpacing(8)
        completar_main_layout.addWidget(QLabel("Texto base con espacios (ej: La capital de Francia es [Paris] y la de Italia es [Roma]). Use [palabra_clave] para cada espacio."))
        self.txt_texto_con_espacios_completar = QTextEdit() # COMPLETAR_PREGUNTAS.texto_con_espacios [cite: 3]
        self.txt_texto_con_espacios_completar.setObjectName("questionCreationText")
        self.txt_texto_con_espacios_completar.setPlaceholderText("Ej: El sol es [amarillo] y el cielo es [azul].")
        self.txt_texto_con_espacios_completar.setMinimumHeight(60)
        completar_main_layout.addWidget(self.txt_texto_con_espacios_completar)
        completar_main_layout.addWidget(QLabel("Respuestas correctas para los espacios (en el orden que aparecen en el texto):"))
        completar_scroll_area, self.completar_espacios_items_layout = self._crear_layout_dinamico_scrollable()
        completar_main_layout.addWidget(completar_scroll_area, 1) # Stretch scroll area
        self.btn_add_espacio_completar = QPushButton("Añadir Espacio de Respuesta")
        self.btn_add_espacio_completar.setObjectName("addFillBlankButton")
        # El texto para el espacio se ingresará en el input que se añade.
        self.btn_add_espacio_completar.clicked.connect(lambda: self.anadir_espacio_completar_input())
        completar_main_layout.addWidget(self.btn_add_espacio_completar, 0, Qt.AlignRight) # No stretch
        self.stacked_widget_tipo_pregunta.addWidget(self.widget_completar)


        # Widget para EMPAREJAR (índice 3)
        # Usa self.emparejar_items_layout
        self.widget_emparejar = QWidget()
        emparejar_main_layout = QVBoxLayout(self.widget_emparejar)
        emparejar_scroll_area, self.emparejar_items_layout = self._crear_layout_dinamico_scrollable()
        emparejar_main_layout.addWidget(emparejar_scroll_area, 1)
        self.btn_add_par = QPushButton("Añadir Par a Emparejar")
        self.btn_add_par.setObjectName("addPairButton")
        self.btn_add_par.clicked.connect(lambda: self.anadir_par_input_dinamico())
        emparejar_main_layout.addWidget(self.btn_add_par, 0, Qt.AlignRight)
        self.stacked_widget_tipo_pregunta.addWidget(self.widget_emparejar)


        # Widget para ORDENAR (índice 4)
        # Usa self.ordenar_items_layout
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
        # El stretch item es el último, así que iteramos hasta layout_ref.count() - 2
        for i in range(layout_ref.count() - 2, -1, -1):
            child = layout_ref.itemAt(i)
            if child and child.widget():
                child.widget().deleteLater()
        widget_list_ref.clear()

    def anadir_opcion_input_dinamico(self, texto="", es_correcta_val=False):
        widget_opcion = QWidget()
        layout_opcion = QHBoxLayout(widget_opcion)
        layout_opcion.setContentsMargins(0,0,0,0)

        tipo_actual_txt = self.cmb_tipo_pregunta.currentText() # OPCION_UNICA, VERDADERO_FALSO, OPCION_MULTIPLE
        if tipo_actual_txt == "OPCION_UNICA" or tipo_actual_txt == "VERDADERO_FALSO":
            # Para OPCION_UNICA y VERDADERO_FALSO, usamos QRadioButton para asegurar una única selección.
            # Necesitaremos un QButtonGroup si quisiéramos manejar la exclusividad automáticamente,
            # pero para guardar, validaremos que solo uno esté marcado.
            # Aquí, el control visual es importante.
            chk_correcta = QRadioButton()
            # Si hay otros radio buttons en el mismo layout/padre, se agruparán automáticamente.
            # Para asegurar que solo uno de *estos* radio buttons pueda ser seleccionado,
            # podrían necesitar un QButtonGroup si no están en el mismo padre directo del layout.
            # Sin embargo, para la lógica de guardado, la validación manual es clave.
        else: # OPCION_MULTIPLE
            chk_correcta = QCheckBox()

        chk_correcta.setChecked(es_correcta_val)
        txt_opcion = QLineEdit(texto)
        txt_opcion.setPlaceholderText(f"Texto de la Opción {len(self._dynamic_option_widgets) + 1}")

        btn_del_opcion = QPushButton("X")
        btn_del_opcion.setProperty("class", "small-action-button")
        btn_del_opcion.setToolTip("Eliminar esta opción")
        btn_del_opcion.setFixedSize(24, 24)
        btn_del_opcion.clicked.connect(lambda: self._remove_dynamic_widget(widget_opcion, self.opciones_items_layout, self._dynamic_option_widgets))

        layout_opcion.addWidget(chk_correcta)
        layout_opcion.addWidget(txt_opcion, 1) # Stretch al QLineEdit
        layout_opcion.addWidget(btn_del_opcion)

        # Insertar antes del stretch item
        self.opciones_items_layout.insertWidget(self.opciones_items_layout.count() -1, widget_opcion)
        self._dynamic_option_widgets.append(widget_opcion)
        txt_opcion.setFocus()

    def anadir_espacio_completar_input(self, texto_val=""):
        # Este widget representa una entrada para la respuesta correcta de un espacio.
        # COMPLETAR_ESPACIOS.texto_correcto [cite: 1]
        widget_espacio = QWidget()
        layout_espacio = QHBoxLayout(widget_espacio)
        layout_espacio.setContentsMargins(0,0,0,0)

        n_espacio = len(self._dynamic_fill_widgets) + 1 # Basado en cuántos inputs de respuesta ya hay
        lbl_espacio = QLabel(f"Respuesta para Espacio [{n_espacio}]:") # COMPLETAR_ESPACIOS.numero_espacio [cite: 1]
        txt_respuesta_espacio = QLineEdit(texto_val)
        txt_respuesta_espacio.setPlaceholderText(f"Texto correcto para espacio {n_espacio}")

        btn_del_espacio = QPushButton("X")
        btn_del_espacio.setProperty("class", "small-action-button")
        btn_del_espacio.setToolTip("Eliminar este campo de respuesta")
        btn_del_espacio.setFixedSize(24, 24)
        btn_del_espacio.clicked.connect(lambda: self._remove_dynamic_widget(widget_espacio, self.completar_espacios_items_layout, self._dynamic_fill_widgets))

        layout_espacio.addWidget(lbl_espacio)
        layout_espacio.addWidget(txt_respuesta_espacio, 1) # Stretch al QLineEdit
        layout_espacio.addWidget(btn_del_espacio)

        self.completar_espacios_items_layout.insertWidget(self.completar_espacios_items_layout.count() -1, widget_espacio)
        self._dynamic_fill_widgets.append(widget_espacio)
        txt_respuesta_espacio.setFocus()

    def anadir_par_input_dinamico(self, opcion_a_val="", opcion_b_val=""):
        # EMPAREJAMIENTO_PREGUNTAS.opcion_a, EMPAREJAMIENTO_PREGUNTAS.opcion_b [cite: 7]
        widget_par_container = QWidget()
        main_par_layout = QHBoxLayout(widget_par_container) # Layout principal HBox para el QFormLayout y el botón X
        main_par_layout.setContentsMargins(0,0,0,0)

        widget_par_form = QWidget() # Contenedor para el QFormLayout
        layout_par_form = QFormLayout(widget_par_form) # Usar QFormLayout para A y B
        layout_par_form.setContentsMargins(0,5,0,5) # Margen superior e inferior
        layout_par_form.setSpacing(5)

        txt_opcion_a = QLineEdit(opcion_a_val)
        txt_opcion_a.setPlaceholderText(f"Elemento A del par {len(self._dynamic_pair_widgets) + 1}")
        txt_opcion_b = QLineEdit(opcion_b_val)
        txt_opcion_b.setPlaceholderText(f"Elemento B del par {len(self._dynamic_pair_widgets) + 1}")
        layout_par_form.addRow("Elemento A:", txt_opcion_a)
        layout_par_form.addRow("Elemento B (su pareja correcta):", txt_opcion_b)

        main_par_layout.addWidget(widget_par_form, 1) # Darle stretch al form

        btn_del_par = QPushButton("X")
        btn_del_par.setProperty("class", "small-action-button")
        btn_del_par.setToolTip("Eliminar este par")
        btn_del_par.setFixedSize(24, 24)
        # Conectar la señal clicked del botón para eliminar el widget_par_container
        btn_del_par.clicked.connect(lambda: self._remove_dynamic_widget(widget_par_container, self.emparejar_items_layout, self._dynamic_pair_widgets))
        main_par_layout.addWidget(btn_del_par) # Botón X al lado

        self.emparejar_items_layout.insertWidget(self.emparejar_items_layout.count()-1, widget_par_container)
        self._dynamic_pair_widgets.append(widget_par_container)
        txt_opcion_a.setFocus()

    def anadir_elemento_ordenar_input_dinamico(self, texto_val=""):
        # ORDEN_PREGUNTAS.texto, ORDEN_PREGUNTAS.posicion_correcta [cite: 26]
        # La posición correcta será implícita por el orden en que se añaden aquí.
        widget_elemento = QWidget()
        layout_elemento = QHBoxLayout(widget_elemento)
        layout_elemento.setContentsMargins(0,0,0,0)

        n_elemento = len(self._dynamic_order_widgets) + 1
        lbl_orden = QLabel(f"{n_elemento}.") # Indicador visual del orden correcto
        txt_elemento = QLineEdit(texto_val)
        txt_elemento.setPlaceholderText(f"Texto del elemento en posición {n_elemento}")

        btn_del_elemento = QPushButton("X")
        btn_del_elemento.setProperty("class", "small-action-button")
        btn_del_elemento.setToolTip("Eliminar este elemento")
        btn_del_elemento.setFixedSize(24, 24)
        # Usar una lambda que capture el widget a eliminar
        btn_del_elemento.clicked.connect(lambda checked=False, w=widget_elemento: self._remove_dynamic_widget(w, self.ordenar_items_layout, self._dynamic_order_widgets, self.actualizar_numeros_ordenar))


        layout_elemento.addWidget(lbl_orden)
        layout_elemento.addWidget(txt_elemento, 1) # Stretch al QLineEdit
        layout_elemento.addWidget(btn_del_elemento)

        self.ordenar_items_layout.insertWidget(self.ordenar_items_layout.count()-1, widget_elemento)
        self._dynamic_order_widgets.append(widget_elemento)
        txt_elemento.setFocus()
        self.actualizar_numeros_ordenar() # Actualizar todos los números al añadir

    def _remove_dynamic_widget(self, widget_to_remove, layout_ref, widget_list_ref, callback_after_remove=None):
        if widget_to_remove in widget_list_ref:
            widget_to_remove.hide() # Ocultar primero
            layout_ref.removeWidget(widget_to_remove) # Quitar del layout
            widget_to_remove.deleteLater() # Programar para eliminación
            widget_list_ref.remove(widget_to_remove) # Quitar de la lista de seguimiento
            if callback_after_remove:
                callback_after_remove()

    def actualizar_numeros_ordenar(self):
        # Actualiza los números de los elementos de ordenar restantes.
        for i, widget in enumerate(self._dynamic_order_widgets):
            if not widget.isVisible(): continue # Si ya fue marcado para eliminar (aunque deleteLater es asíncrono)
            layout = widget.layout() # QHBoxLayout
            if layout and layout.count() > 0: # Debería tener QLabel, QLineEdit, QPushButton
                # El QLabel del número es el primer widget
                first_item_widget = layout.itemAt(0).widget()
                if isinstance(first_item_widget, QLabel):
                    first_item_widget.setText(f"{i+1}.")


    def actualizar_ui_tipo_pregunta(self):
        tipo_seleccionado_texto = self.cmb_tipo_pregunta.currentText() # ej: "OPCION_UNICA"
        tipo_seleccionado_data = self.cmb_tipo_pregunta.currentData() # ej: tipo_pregunta_id (int)

        self.group_specific_details.setTitle(f"Detalles para Pregunta de Tipo: {tipo_seleccionado_texto if tipo_seleccionado_data is not None else 'Ninguno'}")

        # Limpiar todos los layouts dinámicos antes de cambiar de tipo
        self._limpiar_layout_dinamico(self.opciones_items_layout, self._dynamic_option_widgets)
        self._limpiar_layout_dinamico(self.completar_espacios_items_layout, self._dynamic_fill_widgets)
        self.txt_texto_con_espacios_completar.clear() # Limpiar también el QTextEdit de completar
        self._limpiar_layout_dinamico(self.emparejar_items_layout, self._dynamic_pair_widgets)
        self._limpiar_layout_dinamico(self.ordenar_items_layout, self._dynamic_order_widgets)


        if tipo_seleccionado_data is None: # Si se selecciona "-- Seleccione un Tipo --"
            self.stacked_widget_tipo_pregunta.setCurrentIndex(0) # Mostrar widget por defecto
            return

        # El texto coincide con TIPO_PREGUNTAS.descripcion [cite: 49]
        if tipo_seleccionado_texto in ["OPCION_UNICA", "OPCION_MULTIPLE"]:
            self.stacked_widget_tipo_pregunta.setCurrentIndex(1) # widget_opciones
            self.btn_add_opcion.show() # Permitir añadir más opciones
            if not self._dynamic_option_widgets: # Si está vacío, añadir algunas por defecto
                 for _ in range(2): self.anadir_opcion_input_dinamico() # Añadir 2 opciones vacías
        elif tipo_seleccionado_texto == "VERDADERO_FALSO":
            self.stacked_widget_tipo_pregunta.setCurrentIndex(1) # widget_opciones
            self.btn_add_opcion.hide() # No permitir añadir más opciones para V/F
            if not self._dynamic_option_widgets: # Si está vacío, añadir V y F
                self.anadir_opcion_input_dinamico("Verdadero", False)
                self.anadir_opcion_input_dinamico("Falso", False)
        elif tipo_seleccionado_texto == "COMPLETAR":
            self.stacked_widget_tipo_pregunta.setCurrentIndex(2) # widget_completar
            if not self._dynamic_fill_widgets: # Si está vacío
                self.anadir_espacio_completar_input() # Añadir un campo de respuesta
        elif tipo_seleccionado_texto == "EMPAREJAR":
            self.stacked_widget_tipo_pregunta.setCurrentIndex(3) # widget_emparejar
            if not self._dynamic_pair_widgets: # Si está vacío
                for _ in range(2): self.anadir_par_input_dinamico() # Añadir 2 pares vacíos
        elif tipo_seleccionado_texto == "ORDENAR":
            self.stacked_widget_tipo_pregunta.setCurrentIndex(4) # widget_ordenar
            if not self._dynamic_order_widgets: # Si está vacío
                for _ in range(3): self.anadir_elemento_ordenar_input_dinamico() # Añadir 3 elementos vacíos
        else:
            self.stacked_widget_tipo_pregunta.setCurrentIndex(0) # Widget por defecto para tipos no manejados


    def cargar_combos(self):
        self.cmb_tema.clear()
        self.cmb_tema.addItem("-- Seleccione un Tema --", None)
        temas = obtener_temas_db() # Usa la función reemplazada [cite: 43]
        for tema_id, nombre_tema in temas:
            self.cmb_tema.addItem(nombre_tema, tema_id) # tema_id es el ID real

        self.cmb_tipo_pregunta.clear()
        self.cmb_tipo_pregunta.addItem("-- Seleccione un Tipo --", None)
        tipos = obtener_tipos_pregunta_db() # Usa la función reemplazada [cite: 48]
        for tipo_id, desc_tipo in tipos:
            self.cmb_tipo_pregunta.addItem(desc_tipo, tipo_id) # tipo_id es el ID real


    def guardar_pregunta(self):
        texto_pregunta = self.txt_texto_pregunta.toPlainText().strip()
        es_publica = 'S' if self.chk_es_publica.isChecked() else 'N' # PREGUNTAS.es_publica [cite: 28]
        tiempo_maximo = self.spn_tiempo_maximo.value() # PREGUNTAS.tiempo_maximo [cite: 28]
        tema_id = self.cmb_tema.currentData() # PREGUNTAS.tema_id [cite: 29]
        tipo_pregunta_id = self.cmb_tipo_pregunta.currentData() # PREGUNTAS.tipo_pregunta_id [cite: 28]
        tipo_pregunta_texto = self.cmb_tipo_pregunta.currentText() # TIPO_PREGUNTAS.descripcion [cite: 49]
        creador_id = current_user.usuario_id if current_user else -1 # PREGUNTAS.creador_id, de USUARIOS.usuario_id [cite: 28, 58]

        # Validaciones básicas
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

        pregunta_general_data = {
            'texto_pregunta': texto_pregunta, 'es_publica': es_publica, 'tiempo_maximo': tiempo_maximo,
            'tema_id': tema_id, 'tipo_pregunta_id': tipo_pregunta_id,
            'tipo_pregunta_texto': tipo_pregunta_texto, # Para lógica de guardado específico
            'creador_id': creador_id,
            'fecha_creacion': QDateTime.currentDateTime().toString(Qt.ISODate) # PREGUNTAS.fecha_creacion [cite: 28]
        }
        detalles_tipo_data = {}

        # Recopilar datos específicos del tipo y validar
        if tipo_pregunta_texto in ["OPCION_UNICA", "OPCION_MULTIPLE", "VERDADERO_FALSO"]:
            opciones = []
            num_correctas = 0
            if not self._dynamic_option_widgets:
                QMessageBox.warning(self, "Datos Incompletos", "Debe añadir opciones para este tipo de pregunta.")
                return

            for i, opcion_widget in enumerate(self._dynamic_option_widgets):
                # Encontrar QRadioButton o QCheckBox
                radio_o_check = opcion_widget.findChild(QRadioButton) or opcion_widget.findChild(QCheckBox)
                texto_opcion_widget = opcion_widget.findChild(QLineEdit)

                if texto_opcion_widget and radio_o_check:
                    texto_opcion = texto_opcion_widget.text().strip()
                    es_correcta_opcion = 'S' if radio_o_check.isChecked() else 'N' # OPCIONES_PREGUNTAS.es_correcta [cite: 24]
                    if es_correcta_opcion == 'S': num_correctas +=1

                    if not texto_opcion:
                        QMessageBox.warning(self, "Datos Incompletos", f"El texto de la opción {i+1} no puede estar vacío.")
                        texto_opcion_widget.setFocus()
                        return
                    opciones.append({'texto': texto_opcion, 'es_correcta': es_correcta_opcion, 'orden': i + 1}) # OPCIONES_PREGUNTAS.orden [cite: 24]
            detalles_tipo_data['opciones'] = opciones

            # Validaciones de correctas
            if tipo_pregunta_texto == "OPCION_UNICA" and num_correctas != 1:
                 QMessageBox.warning(self, "Validación Fallida", "Para preguntas de opción única, debe haber exactamente una respuesta correcta.")
                 return
            if tipo_pregunta_texto == "OPCION_MULTIPLE" and num_correctas < 1:
                 QMessageBox.warning(self, "Validación Fallida", "Para preguntas de opción múltiple, debe haber al menos una respuesta correcta.")
                 return
            if tipo_pregunta_texto == "VERDADERO_FALSO" and num_correctas != 1: # Asegura que una de V/F esté marcada
                 QMessageBox.warning(self, "Validación Fallida", "Para preguntas de Verdadero/Falso, debe seleccionar una opción como correcta.")
                 return

        elif tipo_pregunta_texto == "COMPLETAR":
            texto_con_espacios = self.txt_texto_con_espacios_completar.toPlainText().strip() # COMPLETAR_PREGUNTAS.texto_con_espacios [cite: 3]
            if not texto_con_espacios:
                QMessageBox.warning(self, "Datos Incompletos", "El texto base con espacios es obligatorio.")
                self.txt_texto_con_espacios_completar.setFocus()
                return
            detalles_tipo_data['texto_con_espacios'] = texto_con_espacios

            espacios_correctos = []
            if not self._dynamic_fill_widgets:
                QMessageBox.warning(self, "Datos Incompletos", "Debe añadir al menos un espacio de respuesta.")
                return
            for i, espacio_widget in enumerate(self._dynamic_fill_widgets):
                txt_respuesta_widget = espacio_widget.findChild(QLineEdit)
                if txt_respuesta_widget:
                    texto_correcto_espacio = txt_respuesta_widget.text().strip() # COMPLETAR_ESPACIOS.texto_correcto [cite: 1]
                    if not texto_correcto_espacio:
                        QMessageBox.warning(self, "Datos Incompletos", f"El texto de respuesta para el espacio {i+1} no puede estar vacío.")
                        txt_respuesta_widget.setFocus()
                        return
                    # COMPLETAR_ESPACIOS.numero_espacio [cite: 1]
                    espacios_correctos.append({'numero_espacio': i + 1, 'texto_correcto': texto_correcto_espacio})
            detalles_tipo_data['espacios'] = espacios_correctos

        elif tipo_pregunta_texto == "EMPAREJAR":
            pares = []
            if not self._dynamic_pair_widgets or len(self._dynamic_pair_widgets) < 2:
                QMessageBox.warning(self, "Datos Incompletos", "Debe añadir al menos dos pares para emparejar.")
                return
            for i, par_widget_container in enumerate(self._dynamic_pair_widgets):
                # El QFormLayout está dentro de un QWidget que es el primer item del QHBoxLayout principal del par_widget_container
                form_widget = par_widget_container.layout().itemAt(0).widget()
                inputs = form_widget.findChildren(QLineEdit) # Debería encontrar 2 QLineEdits
                if len(inputs) == 2:
                    opcion_a = inputs[0].text().strip() # EMPAREJAMIENTO_PREGUNTAS.opcion_a [cite: 7]
                    opcion_b = inputs[1].text().strip() # EMPAREJAMIENTO_PREGUNTAS.opcion_b [cite: 7]
                    if not opcion_a or not opcion_b:
                        QMessageBox.warning(self, "Datos Incompletos", f"Ambos elementos del par {i+1} deben tener texto.")
                        if not opcion_a: inputs[0].setFocus()
                        else: inputs[1].setFocus()
                        return
                    pares.append({'opcion_a': opcion_a, 'opcion_b': opcion_b})
            detalles_tipo_data['pares'] = pares

        elif tipo_pregunta_texto == "ORDENAR":
            elementos = []
            if not self._dynamic_order_widgets or len(self._dynamic_order_widgets) < 2:
                QMessageBox.warning(self, "Datos Incompletos", "Debe añadir al menos dos elementos para ordenar.")
                return
            for i, elemento_widget in enumerate(self._dynamic_order_widgets):
                txt_elemento_widget = elemento_widget.findChild(QLineEdit)
                if txt_elemento_widget:
                    texto_elemento = txt_elemento_widget.text().strip() # ORDEN_PREGUNTAS.texto [cite: 26]
                    if not texto_elemento:
                        QMessageBox.warning(self, "Datos Incompletos", f"El texto del elemento {i+1} no puede estar vacío.")
                        txt_elemento_widget.setFocus()
                        return
                    # ORDEN_PREGUNTAS.posicion_correcta [cite: 26]
                    elementos.append({'texto': texto_elemento, 'posicion_correcta': i + 1})
            detalles_tipo_data['elementos'] = elementos

        # Llamar a la función de guardado en BD
        if guardar_pregunta_completa_db(pregunta_general_data, detalles_tipo_data):
            QMessageBox.information(self, "Éxito", "Pregunta guardada en la base de datos.")
            self.cerrar_vista()
        else:
            QMessageBox.critical(self, "Error", "No se pudo guardar la pregunta en la base de datos.")


# --- Ventana Gestionar Preguntas (NUEVA) ---
class VentanaGestionarPreguntas(VistaBaseWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Gestionar Preguntas del Banco")
        self.setObjectName("manageQuestionsWindow")
        self.setMinimumSize(800, 600)
        self._todas_las_preguntas_cache = []
        # self.pregunta_dao = PreguntaDAO(self.db_connection)
        # self.tema_dao = TemaDAO(self.db_connection)
        # self.tipo_pregunta_dao = TipoPreguntaDAO(self.db_connection)
        self.init_ui()
        self.cargar_y_mostrar_preguntas_iniciales()


    def init_ui(self):
        main_layout = QVBoxLayout(self)
        main_layout.setContentsMargins(20, 20, 20, 20)
        main_layout.setSpacing(15)

        filter_group = QGroupBox("Filtros de Búsqueda")
        filter_layout = QHBoxLayout(filter_group)
        filter_layout.setSpacing(10)

        filter_layout.addWidget(QLabel("Filtrar por Tema:"))
        self.cmb_filtro_tema = QComboBox() # Se llena con TEMAS.tema_id como data [cite: 43]
        filter_layout.addWidget(self.cmb_filtro_tema)

        filter_layout.addWidget(QLabel("Filtrar por Tipo:"))
        self.cmb_filtro_tipo = QComboBox() # Se llena con TIPO_PREGUNTAS.tipo_pregunta_id como data [cite: 48]
        filter_layout.addWidget(self.cmb_filtro_tipo)

        filter_layout.addStretch(1)
        self.btn_aplicar_filtros = QPushButton("Aplicar Filtros")
        self.btn_aplicar_filtros.clicked.connect(self.aplicar_filtros_tabla)
        filter_layout.addWidget(self.btn_aplicar_filtros)
        
        self.btn_limpiar_filtros = QPushButton("Limpiar Filtros")
        self.btn_limpiar_filtros.clicked.connect(self.limpiar_filtros_y_recargar)
        filter_layout.addWidget(self.btn_limpiar_filtros)

        main_layout.addWidget(filter_group)

        # Llenar combos de filtro
        self.cmb_filtro_tema.addItem("Todos los Temas", None)
        for tema_id, nombre_tema in obtener_temas_db(): # Usa función reemplazada [cite: 43]
            self.cmb_filtro_tema.addItem(nombre_tema, tema_id) # ID real del tema
        self.cmb_filtro_tipo.addItem("Todos los Tipos", None)
        for tipo_id, desc_tipo in obtener_tipos_pregunta_db(): # Usa función reemplazada [cite: 48]
            self.cmb_filtro_tipo.addItem(desc_tipo, tipo_id) # ID real del tipo


        self.tabla_preguntas = QTableWidget()
        self.tabla_preguntas.setColumnCount(5) # ID, Texto, Tipo, Tema, Creador
        self.tabla_preguntas.setHorizontalHeaderLabels(["ID", "Texto de Pregunta", "Tipo", "Tema", "Creador"])
        self.tabla_preguntas.setSelectionBehavior(QAbstractItemView.SelectRows)
        self.tabla_preguntas.setEditTriggers(QAbstractItemView.NoEditTriggers)
        self.tabla_preguntas.verticalHeader().setVisible(False)
        self.tabla_preguntas.horizontalHeader().setSectionResizeMode(1, QHeaderView.Stretch) # Texto de pregunta
        header = self.tabla_preguntas.horizontalHeader()
        header.setSectionResizeMode(0, QHeaderView.ResizeToContents)
        header.setSectionResizeMode(2, QHeaderView.ResizeToContents)
        header.setSectionResizeMode(3, QHeaderView.ResizeToContents)
        header.setSectionResizeMode(4, QHeaderView.ResizeToContents)
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
        # El caché ahora contendrá los datos tal como vienen del DAO (transformados a dict si es necesario)
        self._todas_las_preguntas_cache = obtener_todas_las_preguntas_db() # Usa función reemplazada [cite: 28]
        self.popular_tabla_preguntas(self._todas_las_preguntas_cache)


    def popular_tabla_preguntas(self, preguntas_a_mostrar):
        self.tabla_preguntas.setRowCount(0)
        self.tabla_preguntas.setRowCount(len(preguntas_a_mostrar))
        for row, preg_data in enumerate(preguntas_a_mostrar):
            # preg_data es un diccionario con 'id', 'texto', 'tipo', 'tema', 'creador'
            # y los IDs reales 'tipo_id_simulado' y 'tema_id_simulado'
            self.tabla_preguntas.setItem(row, 0, QTableWidgetItem(str(preg_data.get('id'))))
            self.tabla_preguntas.setItem(row, 1, QTableWidgetItem(preg_data.get('texto')))
            self.tabla_preguntas.setItem(row, 2, QTableWidgetItem(preg_data.get('tipo')))
            self.tabla_preguntas.setItem(row, 3, QTableWidgetItem(preg_data.get('tema')))
            self.tabla_preguntas.setItem(row, 4, QTableWidgetItem(preg_data.get('creador')))
            # Guardar el ID real de la pregunta (PREGUNTAS.pregunta_id) [cite: 28]
            self.tabla_preguntas.item(row,0).setData(Qt.UserRole, preg_data.get('id'))


    def aplicar_filtros_tabla(self):
        filtro_tema_id = self.cmb_filtro_tema.currentData() # ID real del tema
        filtro_tipo_id = self.cmb_filtro_tipo.currentData() # ID real del tipo

        # En un escenario real, haríamos una nueva llamada al DAO con los filtros.
        # preguntas_filtradas_dto = self.pregunta_dao.obtener_filtradas_con_detalles_completos(
        #                                         tema_id=filtro_tema_id,
        #                                         tipo_pregunta_id=filtro_tipo_id
        #                                     )
        # # Luego transformar DTOs a la estructura de diccionario esperada por popular_tabla_preguntas
        # preguntas_filtradas = self.transformar_dtos_a_formato_tabla(preguntas_filtradas_dto)

        # Por ahora, filtramos el caché local (que ya tiene los IDs reales para filtrar)
        preguntas_filtradas = self._todas_las_preguntas_cache
        if filtro_tema_id is not None:
            # 'tema_id_simulado' ahora contiene el tema_id real de la BD
            preguntas_filtradas = [p for p in preguntas_filtradas if p.get('tema_id_simulado') == filtro_tema_id]
        if filtro_tipo_id is not None:
            # 'tipo_id_simulado' ahora contiene el tipo_pregunta_id real de la BD
            preguntas_filtradas = [p for p in preguntas_filtradas if p.get('tipo_id_simulado') == filtro_tipo_id]

        self.popular_tabla_preguntas(preguntas_filtradas)
        if not preguntas_filtradas:
            QMessageBox.information(self, "Sin Resultados", "No se encontraron preguntas que coincidan con los filtros.")

    def limpiar_filtros_y_recargar(self):
        self.cmb_filtro_tema.setCurrentIndex(0)
        self.cmb_filtro_tipo.setCurrentIndex(0)
        # Recargar desde el caché original (que vino de la BD)
        self.popular_tabla_preguntas(self._todas_las_preguntas_cache)


    def eliminar_pregunta_seleccionada(self):
        selected_rows = self.tabla_preguntas.selectionModel().selectedRows()
        if not selected_rows:
            QMessageBox.warning(self, "Sin Selección", "Seleccione una pregunta para eliminar.")
            return

        pregunta_id_a_eliminar = self.tabla_preguntas.item(selected_rows[0].row(), 0).data(Qt.UserRole) # ID real
        pregunta_texto = self.tabla_preguntas.item(selected_rows[0].row(), 1).text()

        reply = QMessageBox.question(self, "Confirmar Eliminación",
                                     f"¿Está seguro de que desea eliminar la pregunta:\n'{pregunta_texto}' (ID: {pregunta_id_a_eliminar})?",
                                     QMessageBox.Yes | QMessageBox.No, QMessageBox.No)
        if reply == QMessageBox.Yes:
            if eliminar_pregunta_db(pregunta_id_a_eliminar): # Usa función reemplazada [cite: 28]
                QMessageBox.information(self, "Eliminación Exitosa", f"Pregunta ID {pregunta_id_a_eliminar} eliminada de la BD.")
                # Recargar todas las preguntas y aplicar filtros actuales
                self.cargar_y_mostrar_preguntas_iniciales() # Esto recarga el caché desde la BD
                self.aplicar_filtros_tabla() # Reaplica los filtros que estaban seleccionados
            else:
                # El mensaje de error específico (ej. por FK) debería venir de eliminar_pregunta_db
                # QMessageBox.critical(self, "Error de Eliminación", f"No se pudo eliminar la pregunta ID {pregunta_id_a_eliminar}.")
                pass # El error ya se muestra en eliminar_pregunta_db

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
        examenes = obtener_examenes_profesor_db(current_user.usuario_id if current_user else -1) # EXAMENES [cite: 12]
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
            QMessageBox.information(self, "Éxito", f"Configuración de preguntas para el examen '{self.cmb_examenes_profesor.currentText()}' guardada")
        else:
            QMessageBox.critical(self, "Error", "No se pudo guardar la configuración de preguntas (simulación).")

class VentanaInscribirEstudianteAGrupo(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Inscripción de Estudiante a Grupo")
        self.resize(400, 200)
        self.conn = get_connection()
        self.usuario_dao = UsuarioDAO(self.conn)
        self.grupo_dao = GrupoDAO(self.conn)
        self.inscripcion_dao = InscripcionDAO(self.conn)
        self.init_ui()

    def init_ui(self):
        layout = QFormLayout(self)

        self.cmb_estudiante = QComboBox()
        estudiantes = self.usuario_dao.obtener_estudiantes()
        for est in estudiantes:
            self.cmb_estudiante.addItem(f"{est.usuario_id} - {est.nombre} {est.apellido}", est.usuario_id)
        layout.addRow("Estudiante:", self.cmb_estudiante)

        self.cmb_grupo = QComboBox()
        grupos = self.grupo_dao.obtener_por_profesor_id(current_user.usuario_id if current_user else -1) # Simulación de GRUPOS [cite: 15]
        for grupo in grupos:
            self.cmb_grupo.addItem(grupo[1], grupo[0])
        layout.addRow("Grupo:", self.cmb_grupo)

        self.btn_inscribir = QPushButton("Inscribir")
        self.btn_inscribir.clicked.connect(self.inscribir_estudiante)
        layout.addRow(self.btn_inscribir)

    def inscribir_estudiante(self):
        estudiante_id = self.cmb_estudiante.currentData()
        grupo_id = self.cmb_grupo.currentData()
        if estudiante_id is None or grupo_id is None:
            QMessageBox.warning(self, "Faltan datos", "Debe seleccionar estudiante y grupo.")
            return
        exito = self.inscripcion_dao.insertar(estudiante_id, grupo_id)
        if exito:
            QMessageBox.information(self, "Éxito", "Estudiante inscrito correctamente.")
        else:
            QMessageBox.critical(self, "Error", "No se pudo inscribir al estudiante.")

    def closeEvent(self, event):
        if self.conn:
            self.conn.close()
        event.accept()

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
        self.connection = get_connection()
        self.tipo_usuario_dao = TipoUsuarioDAO(self.connection) # DAOs para tipos de usuario
        self.tipo_usuario = self.tipo_usuario_dao.obtener_por_id(current_user.tipo_usuario_id) # Obtiene el tipo de usuario actual

        if current_user and self.tipo_usuario.descripcion == 'ESTUDIANTE':
             # Simulación de EXAMENES.fecha_limite [cite: 13]
            examenes = obtener_examenes_disponibles_db(current_user.usuario_id) # EXAMENES [cite: 12]
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


# --- MainApplicationController y LoginWindow necesitan acceso a DAOs ---
# Asumimos que LoginWindow crea sus DAOs y pasa el UserDTO a ExamApp.
# ExamApp luego puede instanciar sus propios DAOs o recibir la conexión.

class ExamApp(QMainWindow):
    # ... (sin cambios en __init__ por ahora, pero podría recibir/crear conexión) ...
    sesion_cerrada_signal = pyqtSignal()

    def __init__(self, usuario_info_dto): # Espera un UsuarioDTO
        super().__init__()
        global current_user
        current_user = usuario_info_dto # current_user es ahora un UsuarioDTO
        self.connection = get_connection()
        self.tipo_usuario_dao = TipoUsuarioDAO(self.connection) # DAOs para tipos de usuario

        tipo_usuario = self.tipo_usuario_dao.obtener_por_id(current_user.tipo_usuario_id) # Obtiene el tipo de usuario actual

        self.setWindowTitle(f"Sistema de Exámenes Interactivo - Usuario: {current_user.nombre} ({tipo_usuario.descripcion})")
        # ... resto del init_ui ...
        # self.db_connection = get_db_connection() # O gestionado por MainApplicationController
        # # Instanciar DAOs aquí si se van a usar frecuentemente por varias sub-ventanas
        # # o pasar la conexión a las sub-ventanas para que instancien sus propios DAOs.
        self.setGeometry(50, 50, 1100, 750)
        self.central_widget_stack = QStackedWidget()
        self.setCentralWidget(self.central_widget_stack)

        self.init_vistas()
        self.create_menu()
        self.mostrar_bienvenida()


    def init_vistas(self):
        # Asumiendo que UsuarioDTO tiene atributos 'nombre' y 'tipo_usuario_descripcion'
        self.vista_bienvenida = QLabel(f"¡Bienvenido, {current_user.nombre}!\n\nSelecciona una opción del menú para comenzar.")
        self.vista_bienvenida.setObjectName("welcomeLabel")
        self.vista_bienvenida.setAlignment(Qt.AlignCenter)
        self.central_widget_stack.addWidget(self.vista_bienvenida)

    def create_menu(self):
        menu_bar = self.menuBar()
        menu_archivo = menu_bar.addMenu("Archivo")
        accion_logout = QAction("Cerrar Sesión", self)
        accion_logout.triggered.connect(self.cerrar_sesion)
        menu_archivo.addAction(accion_logout)
        menu_archivo.addSeparator()
        accion_salir_app = QAction("Salir de la Aplicación", self)
        accion_salir_app.triggered.connect(self.close)
        menu_archivo.addAction(accion_salir_app)
        tipo_usuario = self.tipo_usuario_dao.obtener_por_id(current_user.tipo_usuario_id) # Obtiene el tipo de usuario actual
        
        # Asumiendo que UsuarioDTO tiene 'tipo_usuario_descripcion'
        if current_user and tipo_usuario.descripcion == 'PROFESOR': # Comparar con la descripción del tipo [cite: 51, 52]
            menu_gestion_examenes = menu_bar.addMenu("Gestión de Exámenes")
            accion_crear_examen = QAction("Crear Nuevo Examen", self)
            accion_crear_examen.triggered.connect(self.mostrar_crear_examen)
            menu_gestion_examenes.addAction(accion_crear_examen)

            accion_config_preg_examen = QAction("Configurar Preguntas de Examen", self)
            accion_config_preg_examen.triggered.connect(self.mostrar_configurar_preguntas_examen)
            menu_gestion_examenes.addAction(accion_config_preg_examen)

            action_inscribir_estudiantes = QAction("Inscribir Estudiantes a Grupos", self)
            action_inscribir_estudiantes.triggered.connect(self.mostrar_ventana_inscripcion)
            menu_gestion_examenes.addAction(action_inscribir_estudiantes)

            menu_gestion_preguntas = menu_bar.addMenu("Gestión de Preguntas")
            accion_crear_pregunta = QAction("Crear Nueva Pregunta", self)
            accion_crear_pregunta.triggered.connect(self.mostrar_crear_pregunta)
            menu_gestion_preguntas.addAction(accion_crear_pregunta)

            accion_gestionar_preguntas = QAction("Gestionar Preguntas Creadas", self)
            accion_gestionar_preguntas.triggered.connect(self.mostrar_gestionar_preguntas)
            menu_gestion_preguntas.addAction(accion_gestionar_preguntas)


        if current_user and tipo_usuario.descripcion == 'ESTUDIANTE': # Comparar con la descripción del tipo [cite: 51, 52]
            menu_rendir_examen = menu_bar.addMenu("Exámenes")
            accion_seleccionar_examen = QAction("Rendir Examen", self)
            accion_seleccionar_examen.triggered.connect(self.mostrar_seleccion_examen)
            menu_rendir_examen.addAction(accion_seleccionar_examen)
    # ... (resto de los métodos de ExamApp, _cambiar_vista_central, etc. permanecen estructuralmente iguales) ...
    # ... pero las ventanas que se crean (VentanaCrearExamen, etc.) ahora usarán DAOs.

    def _cambiar_vista_central(self, widget_instance_creator_func):
        widgets_a_remover = []
        for i in range(self.central_widget_stack.count()):
            widget = self.central_widget_stack.widget(i)
            if widget != self.vista_bienvenida:
                widgets_a_remover.append(widget)

        for widget in widgets_a_remover:
            if isinstance(widget, VistaBaseWidget):
                try:
                    widget.vista_cerrada.disconnect()
                except TypeError: pass 
            self.central_widget_stack.removeWidget(widget)
            widget.deleteLater()

        nueva_vista = widget_instance_creator_func(self) 
        if isinstance(nueva_vista, VistaBaseWidget):
             nueva_vista.vista_cerrada.connect(self.mostrar_bienvenida_y_limpiar_emisor)

        if self.central_widget_stack.indexOf(nueva_vista) == -1: 
            self.central_widget_stack.addWidget(nueva_vista)
        self.central_widget_stack.setCurrentWidget(nueva_vista)

    def mostrar_bienvenida_y_limpiar_emisor(self):
        emisor = self.sender()
        self.mostrar_bienvenida() 
        if emisor and emisor != self.vista_bienvenida and isinstance(emisor, VistaBaseWidget):
            if self.central_widget_stack.indexOf(emisor) != -1: 
                self.central_widget_stack.removeWidget(emisor)
            emisor.deleteLater()


    def mostrar_bienvenida(self):
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
        current_idx = self.central_widget_stack.currentIndex()
        if current_idx != -1:
            current_widget = self.central_widget_stack.widget(current_idx)
            if current_widget != self.vista_bienvenida and isinstance(current_widget, VistaBaseWidget):
                try: current_widget.vista_cerrada.disconnect()
                except TypeError: pass
                self.central_widget_stack.removeWidget(current_widget)
                current_widget.deleteLater()

        ventana_responder = VentanaResponderExamen(examen_id, self)
        ventana_responder.vista_cerrada.connect(lambda: self._cambiar_vista_central(lambda p: VentanaSeleccionExamen(self, p)))

        if self.central_widget_stack.indexOf(ventana_responder) == -1:
            self.central_widget_stack.addWidget(ventana_responder)
        self.central_widget_stack.setCurrentWidget(ventana_responder)


    def mostrar_gestionar_preguntas(self):
        self._cambiar_vista_central(VentanaGestionarPreguntas)

    def mostrar_configurar_preguntas_examen(self):
        self._cambiar_vista_central(VentanaConfigurarPreguntasExamen)
    
    def mostrar_ventana_inscripcion(self):
        self._cambiar_vista_central(VentanaInscribirEstudianteAGrupo)

    def cerrar_sesion(self):
        # LOGS_ACTIVIDAD tipo 'SALIDA' [cite: 22, 46]
        print(f"Cerrando sesión para usuario {current_user.usuario_id if current_user else 'N/A'}")
        try:
            # conn = get_db_connection()
            # log_dao = LogActividadDAO(conn)
            # log_dto = LogActividadDTO(
            #     log_actividad_id=None, # Autogenerado
            #     fecha=QDateTime.currentDateTime().toString("yyyy-MM-dd HH:mm:ss"), # Ajustar formato
            #     ip_address="127.0.0.1", # Obtener IP real si es posible
            #     tipo_accion_id=TIPO_ACCION_SALIDA_ID, # Asumir ID para 'SALIDA' [cite: 46]
            #     usuario_id=current_user.usuario_id,
            #     estado_accion_id=ESTADO_ACCION_EXITOSO_ID # Asumir ID para 'EXITOSO' [cite: 9]
            # )
            # log_dao.insertar(log_dto)
            # conn.close()
            print("DEV_NOTE: Simulación de registro de log de salida.")
        except Exception as e:
            print(f"Error al registrar log de salida: {e}")

        self.close()
        if hasattr(self, 'sesion_cerrada_signal'):
            self.sesion_cerrada_signal.emit()

class LoginWindow(QWidget):
    login_exitoso = pyqtSignal(object) # Emitirá el UsuarioDTO

    def __init__(self):
        super().__init__()
        self.setObjectName("loginWindow")
        self.connection = get_connection()
        self.usuario_dao = UsuarioDAO(self.connection) # Cada ventana puede manejar su conexión/DAO
        self.log_dao = LogActividadDAO(self.connection)
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

        self.username_input = QLineEdit() # Corresponde a USUARIOS.email [cite: 58]
        self.username_input.setPlaceholderText("usuario@dominio.com")
        form_layout.addRow(QLabel("Email:"), self.username_input)

        self.password_input = QLineEdit() # Corresponde a USUARIOS.contrasenia [cite: 58]
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

    def hash_password(self, password):
        # Similar al main.py, usar SHA-256. La BD almacena la contraseña encriptada. [cite: 58]
        sha256 = hashlib.sha256()
        sha256.update(password.encode('utf-8'))
        return sha256.hexdigest()

    def registrar_log_actividad(self, usuario_id_log, tipo_accion_id_log, estado_accion_id_log):
        try:
            log_dto = LogsActividadDTO(
            log_actividad_id=None,
            fecha=QDateTime.currentDateTime().toString("yyyy-MM-dd HH:mm:ss"), # Ajustar formato
            ip_address="127.0.0.1", # Obtener IP real si es posible
            tipo_accion_id=tipo_accion_id_log,
            usuario_id=usuario_id_log,
            estado_accion_id=estado_accion_id_log
            )
            self.log_dao.insertar(log_dto) # Usando el DAO instanciado en __init__
            print(f"DEV_NOTE: Log Actividad: Usuario {usuario_id_log}, Tipo Accion {tipo_accion_id_log}, Estado {estado_accion_id_log}")
        except Exception as e:
            print(f"Error al registrar log de actividad: {e}")


    def verify_login(self):
        email = self.username_input.text().strip()
        password = self.password_input.text()

        # Placeholder IDs para TIPO_ACCION [cite: 46] y ESTADO_ACCION [cite: 9]
        TIPO_ACCION_ENTRADA_ID = 1 # Asumir ID para 'ENTRADA'
        ESTADO_ACCION_EXITOSO_ID = 1 # Asumir ID para 'EXITOSO'
        ESTADO_ACCION_FALLIDO_ID = 2 # Asumir ID para 'FALLIDO'

        usuario_dto = None
        try:
            conn = get_connection() # Obtener conexión para este método
            usuario_dao_local = UsuarioDAO(conn)
            # # El DAO debe buscar por email y comparar la contraseña hasheada
            # # o la BD debe tener una función para verificar contraseña.
            # # Asumimos que el DAO maneja la comparación de hash.
            usuario_dto_temp = usuario_dao_local.buscar_por_email(email)
            if usuario_dto_temp and usuario_dto_temp.contrasenia == password and usuario_dto_temp.activo == 'S':
            #     # Cargar tipo_usuario_descripcion
                tipo_usuario_dao_local = TipoUsuarioDAO(conn)
                tipo_dto = tipo_usuario_dao_local.obtener_por_id(usuario_dto_temp.tipo_usuario_id)
                usuario_dto = usuario_dto_temp

            conn.close() # Cerrar la conexión local

        except Exception as e:
            print(f"Error durante el login (DB access): {e}")
            self.status_label.setText("Error de conexión o consulta.")
            # Registrar intento fallido genérico si es necesario, aunque el usuario_id no se conoce.
            return

        if usuario_dto:
            print(f"Login exitoso para: {usuario_dto.email}, Tipo: {tipo_dto.descripcion}")
            self.registrar_log_actividad(usuario_dto.usuario_id, TIPO_ACCION_ENTRADA_ID, ESTADO_ACCION_EXITOSO_ID)
            self.status_label.setText("")
            self.login_exitoso.emit(usuario_dto) # Emitir el DTO del usuario
            self.close()
        else:
            self.status_label.setText("Email o contraseña incorrectos, o usuario inactivo.")
            print(f"Login fallido para: {email}")
            # Para registrar un intento fallido, si el email existe, se podría obtener el usuario_id.
            # Si el email no existe, el log no tendría un usuario_id válido.
            # Por simplicidad, no se registra log de intento fallido si el email no es válido.
            # Si el email es válido pero la pass no, se podría:
            # temp_user_id_for_log = self.usuario_dao.obtener_id_por_email(email) # Nuevo método DAO
            # if temp_user_id_for_log:
            #    self.registrar_log_actividad(temp_user_id_for_log, TIPO_ACCION_ENTRADA_ID, ESTADO_ACCION_FALLIDO_ID)


class MainApplicationController:
    def __init__(self):
        self.login_window = None
        self.main_app_window = None
        # self.db_connection = get_db_connection() # Podría gestionar una conexión global aquí
        self.start_login()

    def start_login(self):
        if self.main_app_window:
            self.main_app_window.close()
            self.main_app_window.deleteLater()
            self.main_app_window = None

        self.login_window = LoginWindow()
        self.login_window.login_exitoso.connect(self.show_main_application)

        self.login_window.show()

    def show_main_application(self, usuario_info_dto):  # Recibe UsuarioDTO
        # Cerrar ventana de login
        if self.login_window:
            self.login_window.deleteLater()
            self.login_window = None

        # Instanciar tu ventana principal
        self.main_app_window = ExamApp(usuario_info_dto)

        # Conectar la señal que ya debe estar declarada en la clase ExamApp
        # (examplazo en ExamApp: sesion_cerrada_signal = pyqtSignal())
        self.main_app_window.sesion_cerrada_signal.connect(self.handle_logout)

        # Mostrarla
        self.main_app_window.showMaximized()

    def handle_logout(self):
        print("MainApplicationController: Logout detectado, reiniciando login.")
        # self.main_app_window ya se cerró o se ocultó.
        # Si no se elimina explícitamente, puede haber problemas al reabrir.
        if self.main_app_window:
            self.main_app_window.deleteLater()
            self.main_app_window = None
        self.start_login()


if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setApplicationName("Sistema Interactivo de Exámenes")

    stylesheet = load_stylesheet()
    if stylesheet:
        app.setStyleSheet(stylesheet)

    controller = MainApplicationController()
    
    # app.aboutToQuit.connect(controller.close_db_connection) # Cerrar conexión al salir

    original_excepthook = sys.excepthook
    def new_excepthook(type, value, traceback_obj):
        print(f"Excepción no controlada: {type}, {value}")
        # Formatear el traceback para el QMessageBox
        # tb_text = "".join(traceback.format_exception(type, value, traceback_obj))
        QMessageBox.critical(None, "Error Inesperado", f"Ha ocurrido un error:\n{type.__name__}: {value}\nConsulte la consola para más detalles.")
        original_excepthook(type, value, traceback_obj)
    sys.excepthook = new_excepthook

    sys.exit(app.exec_())