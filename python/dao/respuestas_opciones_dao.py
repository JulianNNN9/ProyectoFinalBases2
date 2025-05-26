from typing import List
from dto import RespuestasOpcionesDTO


class RespuestasOpcionesDAO:
    def __init__(self, connection):
        self.connection = connection
    def insertar_batch(self, lista_ro_dto: List[RespuestasOpcionesDTO]):
        if not lista_ro_dto: return True
        query = """
        INSERT INTO respuestas_opciones (respuesta_estudiante_id, opcion_pregunta_id)
        VALUES (:1, :2)
        """ # [cite: 39]
        try:
            cursor = self.connection.cursor()
            datos = [(dto.respuesta_estudiante_id, dto.opcion_pregunta_id) for dto in lista_ro_dto] # [cite: 39]
            cursor.executemany(query, datos)
            self.connection.commit()
            return True
        except Exception as e:
            print(f"Error en RespuestasOpcionesDAO.insertar_batch: {e}")
            self.connection.rollback()
            return False
        finally:
            if 'cursor' in locals() and cursor: cursor.close()

