from typing import List
from dto import OrdenPreguntasDTO

class OrdenPreguntasDAO:
    def __init__(self, connection):
        self.connection = connection

    def insertar_batch(self, lista_op_dto: List[OrdenPreguntasDTO]) -> bool:
        if not lista_op_dto: return True
        query = """
        INSERT INTO orden_preguntas (pregunta_id, texto, posicion_correcta)
        VALUES (:1, :2, :3)
        """ # [cite: 26]
        # SEQ_ORDEN_PREGUNTA_ID es placeholder
        try:
            cursor = self.connection.cursor()
            datos_para_insertar = [
                (dto.pregunta_id, dto.texto, dto.posicion_correcta) for dto in lista_op_dto
            ] # [cite: 26]
            cursor.executemany(query, datos_para_insertar)
            return True
        except Exception as e:
            print(f"Error en OrdenPreguntasDAO.insertar_batch: {e}")
            return False
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()

    def eliminar_por_pregunta_id(self, pregunta_id: int) -> bool:
        query = "DELETE FROM orden_preguntas WHERE pregunta_id = :1" # [cite: 26]
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (pregunta_id,))
            return True
        except Exception as e:
            print(f"Error en OrdenPreguntasDAO.eliminar_por_pregunta_id: {e}")
            return False
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()