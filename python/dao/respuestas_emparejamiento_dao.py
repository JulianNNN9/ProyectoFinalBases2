from typing import List
from dto import RespuestasEmparejamientoDTO


class RespuestasEmparejamientoDAO:
    def __init__(self, connection):
        self.connection = connection
    def insertar_batch(self, lista_re_dto: List[RespuestasEmparejamientoDTO]):
        if not lista_re_dto: return True
        query = """
        INSERT INTO respuestas_emparejamiento
        (opcion_a, opcion_b, respuesta_estudiante_id, emparejamiento_pregunta_id)
        VALUES (:1, :2, :3, :4)
        """ # [cite: 35]
        try:
            cursor = self.connection.cursor()
            datos = [(dto.opcion_a, dto.opcion_b, dto.respuesta_estudiante_id, dto.emparejamiento_pregunta_id) for dto in lista_re_dto] # [cite: 35]
            cursor.executemany(query, datos)
            self.connection.commit()
            return True
        except Exception as e:
            print(f"Error en RespuestasEmparejamientoDAO.insertar_batch: {e}")
            self.connection.rollback()
            return False
        finally:
            if 'cursor' in locals() and cursor: cursor.close()
