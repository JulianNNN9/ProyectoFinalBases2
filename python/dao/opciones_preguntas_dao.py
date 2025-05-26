from typing import List
from dto import OpcionesPreguntasDTO

class OpcionesPreguntasDAO:
    def __init__(self, connection):
        self.connection = connection

    def insertar_batch(self, lista_op_dto: List[OpcionesPreguntasDTO]) -> bool:
        if not lista_op_dto: return True
        query = """
        INSERT INTO opciones_preguntas (pregunta_id, texto, es_correcta, orden)
        VALUES (:1, :2, :3, :4)
        """ # [cite: 24]
        # SEQ_OPCION_PREGUNTA_ID es placeholder
        try:
            cursor = self.connection.cursor()
            datos_para_insertar = [
                (dto.pregunta_id, dto.texto, dto.es_correcta, dto.orden) for dto in lista_op_dto
            ] # [cite: 24]
            cursor.executemany(query, datos_para_insertar)
            self.connection.commit() # Commit solo si todo el batch tiene éxito
            return True
        except Exception as e:
            print(f"Error en OpcionesPreguntasDAO.insertar_batch: {e}")
            self.connection.rollback()
            return False
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()

    def eliminar_por_pregunta_id(self, pregunta_id: int) -> bool:
        query = "DELETE FROM opciones_preguntas WHERE pregunta_id = :1" # [cite: 24]
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (pregunta_id,))
            # No se hace commit aquí si es parte de una transacción mayor (ej. eliminar_pregunta_completa)
            # Pero si es autónomo, sí. Para este ejemplo, se asume autónomo o la transacción se maneja fuera.
            # Para el caso de PreguntaDAO.eliminar_completa, el commit está allí.
            # self.connection.commit() 
            return True
        except Exception as e:
            print(f"Error en OpcionesPreguntasDAO.eliminar_por_pregunta_id: {e}")
            # self.connection.rollback()
            return False
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()
