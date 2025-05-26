from typing import List
from dto import EmparejamientoPreguntasDTO

class EmparejamientoPreguntasDAO:
    def __init__(self, connection):
        self.connection = connection

    def insertar_batch(self, lista_ep_dto: List[EmparejamientoPreguntasDTO]) -> bool:
        if not lista_ep_dto: return True
        query = """
        INSERT INTO emparejamiento_preguntas (pregunta_id, opcion_a, opcion_b)
        VALUES (:1, :2, :3)
        """ # [cite: 7]
        # SEQ_EMPAREJAMIENTO_PREG_ID es placeholder
        try:
            cursor = self.connection.cursor()
            datos_para_insertar = [
                (dto.pregunta_id, dto.opcion_a, dto.opcion_b) for dto in lista_ep_dto
            ] # [cite: 7]
            cursor.executemany(query, datos_para_insertar)
            return True
        except Exception as e:
            print(f"Error en EmparejamientoPreguntasDAO.insertar_batch: {e}")
            return False
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()

    def eliminar_por_pregunta_id(self, pregunta_id: int) -> bool:
        query = "DELETE FROM emparejamiento_preguntas WHERE pregunta_id = :1" # [cite: 7]
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (pregunta_id,))
            return True
        except Exception as e:
            print(f"Error en EmparejamientoPreguntasDAO.eliminar_por_pregunta_id: {e}")
            return False
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()