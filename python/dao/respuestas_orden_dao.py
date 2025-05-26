from typing import List
from dto.respuestas_orden_dto import RespuestasOrdenDTO

class RespuestasOrdenDAO:
    def __init__(self, connection):
        self.connection = connection
    def insertar_batch(self, lista_ro_dto: List[RespuestasOrdenDTO]):
        if not lista_ro_dto: return True
        query = """
        INSERT INTO respuestas_orden
        (texto, posicion_estudiante, orden_pregunta_id, respuesta_estudiante_id)
        VALUES (:1, :2, :3, :4)
        """ # [cite: 41]
        try:
            cursor = self.connection.cursor()
            datos = [(dto.texto, dto.posicion_estudiante, dto.orden_pregunta_id, dto.respuesta_estudiante_id) for dto in lista_ro_dto] # [cite: 41]
            cursor.executemany(query, datos)
            self.connection.commit()
            return True
        except Exception as e:
            print(f"Error en RespuestasOrdenDAO.insertar_batch: {e}")
            self.connection.rollback()
            return False
        finally:
            if 'cursor' in locals() and cursor: cursor.close()