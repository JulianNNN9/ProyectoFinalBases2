from typing import List, Optional
from dto import CompletarPreguntasDTO

class CompletarPreguntasDAO:
    def __init__(self, connection):
        self.connection = connection

    def insertar(self, cp_dto: CompletarPreguntasDTO) -> Optional[int]:
        query = """
        INSERT INTO completar_preguntas (pregunta_id, texto_con_espacios)
        VALUES (:1, :2)
        RETURNING completar_pregunta_id INTO :out_id
        """ # [cite: 3]
        # SEQ_COMPLETAR_PREGUNTA_ID es placeholder
        try:
            cursor = self.connection.cursor()
            out_id = cursor.var(int)
            cursor.execute(query, (cp_dto.pregunta_id, cp_dto.texto_con_espacios, out_id)) # [cite: 3]
            # self.connection.commit() # Commit en guardar_pregunta_completa
            return out_id.getvalue()[0]
        except Exception as e:
            print(f"Error en CompletarPreguntasDAO.insertar: {e}")
            # self.connection.rollback()
            return None
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()
                
    def obtener_ids_por_pregunta_id(self, pregunta_id: int) -> List[int]:
        query = "SELECT completar_pregunta_id FROM completar_preguntas WHERE pregunta_id = :1" # [cite: 3]
        ids = []
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (pregunta_id,))
            for row in cursor.fetchall():
                ids.append(row[0])
            return ids
        except Exception as e:
            print(f"Error en CompletarPreguntasDAO.obtener_ids_por_pregunta_id: {e}")
            return []
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()


    def eliminar_por_pregunta_id(self, pregunta_id: int) -> bool:
        # Primero obtener los completar_pregunta_id para poder eliminar los espacios asociados si no hay ON DELETE CASCADE
        # Esto ya se maneja en PreguntaDAO.eliminar_completa que llama a CompletarEspaciosDAO.eliminar_por_completar_pregunta_id
        query = "DELETE FROM completar_preguntas WHERE pregunta_id = :1" # [cite: 3]
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (pregunta_id,))
            return True
        except Exception as e:
            print(f"Error en CompletarPreguntasDAO.eliminar_por_pregunta_id: {e}")
            return False
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()
