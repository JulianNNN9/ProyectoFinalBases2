from typing import List
from dto import RespuestasCompletarDTO


class RespuestasCompletarDAO:
    def __init__(self, connection):
        self.connection = connection
    def insertar_batch(self, lista_rc_dto: List[RespuestasCompletarDTO]):
        if not lista_rc_dto: return True
        query = """
        INSERT INTO respuestas_completar 
        (numero_espacio, texto_ingresado, completar_espacio_id, respuesta_estudiante_id)
        VALUES (:1, :2, :3, :4)
        """ # [cite: 33]
        try:
            cursor = self.connection.cursor()
            datos = [(dto.numero_espacio, dto.texto_ingresado, dto.completar_espacio_id, dto.respuesta_estudiante_id) for dto in lista_rc_dto] # [cite: 33]
            cursor.executemany(query, datos)
            self.connection.commit()
            return True
        except Exception as e:
            print(f"Error en RespuestasCompletarDAO.insertar_batch: {e}")
            self.connection.rollback()
            return False
        finally:
            if 'cursor' in locals() and cursor: cursor.close()
