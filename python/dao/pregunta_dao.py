import cx_Oracle
from typing import Any, Dict, List, Optional
from dto import PreguntasDTO

class PreguntaDAO:
    def __init__(self, connection):
        self.connection = connection

    def obtener_todas_con_detalles_completos(self, tema_id_filtro=None, tipo_id_filtro=None) -> List[Dict[str, Any]]:
        query = """
        SELECT p.pregunta_id, p.texto, p.tema_id, t.nombre AS tema_nombre,
               p.tipo_pregunta_id, tp.descripcion AS tipo_pregunta_descripcion,
               p.creador_id, u.nombre AS creador_nombre, u.apellido AS creador_apellido
        FROM preguntas p
        JOIN temas t ON p.tema_id = t.tema_id
        JOIN tipo_preguntas tp ON p.tipo_pregunta_id = tp.tipo_pregunta_id
        JOIN usuarios u ON p.creador_id = u.usuario_id
        WHERE 1=1
        """ # [cite: 28, 43, 48, 58]
        params = {}
        if tema_id_filtro:
            query += " AND p.tema_id = :tema_id" # [cite: 29]
            params['tema_id'] = tema_id_filtro
        if tipo_id_filtro:
            query += " AND p.tipo_pregunta_id = :tipo_id" # [cite: 28]
            params['tipo_id'] = tipo_id_filtro
        query += " ORDER BY p.pregunta_id ASC"

        preguntas_formato_tabla = []
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, params)
            for row in cursor.fetchall():
                # row[1] viene de la columna p.texto que es CLOB → convertir a str si es necesario
                texto = row[1]
                if isinstance(texto, cx_Oracle.LOB):
                    texto = texto.read()

                preguntas_formato_tabla.append({
                    'id': row[0],
                    'texto': texto,
                    'tema_id_simulado': row[2],
                    'tema': row[3],
                    'tipo_id_simulado': row[4],
                    'tipo': row[5],
                    'creador_id': row[6],  # Guardamos creador_id por si acaso
                    'creador': f"{row[7]} {row[8]}"
                })
            return preguntas_formato_tabla
        except Exception as e:
            print(f"Error en PreguntaDAO.obtener_todas_con_detalles_completos: {e}")
            return []
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()


    def obtener_por_tema_ids(self, tema_ids: List[int]) -> List[Dict[str, Any]]:
        """
        Obtiene preguntas por lista de IDs de tema.
        Devuelve lista de dicts con keys: 'id', 'texto', 'tipo_pregunta_id', 'tema_id'.
        """
        if not tema_ids:
            return []
        placeholders = ','.join(f':{i+1}' for i in range(len(tema_ids)))
        query = f"""
            SELECT pregunta_id, texto, tipo_pregunta_id, tema_id
              FROM preguntas
             WHERE tema_id IN ({placeholders})
        """
        preguntas = []
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, tuple(tema_ids))
            for row in cursor.fetchall():
                texto = row[1]
                if isinstance(texto, cx_Oracle.LOB):
                    texto = texto.read()
                preguntas.append({
                    'id': row[0],
                    'texto': texto,
                    'tipo_pregunta_id': row[2],
                    'tema_id': row[3]
                })
            return preguntas
        except Exception as e:
            print(f"Error en PreguntaDAO.obtener_por_tema_ids: {e}")
            return []
        finally:
            cursor.close()

    def insertar(self, pregunta_dto: PreguntasDTO) -> Optional[int]:
        query = """
        INSERT INTO preguntas (
            texto, fecha_creacion, es_publica, tiempo_maximo,
            pregunta_padre_id, tipo_pregunta_id, creador_id, tema_id
        ) VALUES (
            :1, TO_TIMESTAMP(:2, 'YYYY-MM-DD HH24:MI:SS'), :3, :4,
            :5, :6, :7, :8
        ) RETURNING pregunta_id INTO :out_pregunta_id
        """ # [cite: 28, 29]
        # SEQ_PREGUNTA_ID es un placeholder
        try:
            cursor = self.connection.cursor()
            out_pregunta_id = cursor.var(int)
            cursor.execute(query, (
                pregunta_dto.texto, pregunta_dto.fecha_creacion, pregunta_dto.es_publica,
                pregunta_dto.tiempo_maximo, pregunta_dto.pregunta_padre_id,
                pregunta_dto.tipo_pregunta_id, pregunta_dto.creador_id, pregunta_dto.tema_id,
                out_pregunta_id
            )) # [cite: 28, 29]
            self.connection.commit()
            return out_pregunta_id.getvalue()[0]
        except Exception as e:
            print(f"Error en PreguntaDAO.insertar: {e}")
            self.connection.rollback()
            return None
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()

    def eliminar_completa(self, pregunta_id: int) -> bool:
        from dao.preguntas_examenes_dao import PreguntasExamenesDAO

        # Esta función debe ser transaccional o las eliminaciones de hijos deben hacerse primero.
        # Asumimos que ON DELETE CASCADE no está configurado para todo, así que borramos explícitamente.
        # 0. Verificar si está en PREGUNTAS_EXAMENES
        pe_dao = PreguntasExamenesDAO(self.connection)
        if pe_dao.existe_asociacion_con_pregunta(pregunta_id):
            # Ya se muestra un QMessageBox en la capa de UI, aquí solo retornamos False.
            print(f"Pregunta {pregunta_id} en uso, no se puede eliminar.")
            return False
            
        try:
            # Iniciar transacción (si no se maneja externamente)
            # self.connection.begin() # Depende de la librería de conexión

            # 1. Eliminar de tablas de tipos específicos
            from dao.opciones_preguntas_dao import OpcionesPreguntasDAO
            OpcionesPreguntasDAO(self.connection).eliminar_por_pregunta_id(pregunta_id)
            # Para COMPLETAR, necesitamos el completar_pregunta_id primero
            from dao.completar_preguntas_dao import CompletarPreguntasDAO
            cp_dao = CompletarPreguntasDAO(self.connection)
            completar_preg_ids = cp_dao.obtener_ids_por_pregunta_id(pregunta_id)
            for cp_id in completar_preg_ids:
                from dao.completar_espacios_dao import CompletarEspaciosDAO
                CompletarEspaciosDAO(self.connection).eliminar_por_completar_pregunta_id(cp_id)
            cp_dao.eliminar_por_pregunta_id(pregunta_id) # Ahora eliminar de completar_preguntas
            from dao.emparejamiento_preguntas_dao import EmparejamientoPreguntasDAO
            EmparejamientoPreguntasDAO(self.connection).eliminar_por_pregunta_id(pregunta_id)
            from dao.orden_preguntas_dao import OrdenPreguntasDAO
            OrdenPreguntasDAO(self.connection).eliminar_por_pregunta_id(pregunta_id)

            # 2. Eliminar de PREGUNTAS
            cursor = self.connection.cursor()
            query_preg = "DELETE FROM preguntas WHERE pregunta_id = :1" # [cite: 28]
            cursor.execute(query_preg, (pregunta_id,))
            
            self.connection.commit()
            return True
        except Exception as e:
            print(f"Error en PreguntaDAO.eliminar_completa: {e}")
            self.connection.rollback()
            return False
        finally:
            if 'cursor' in locals() and cursor: # Solo si se define en el try
                cursor.close()
