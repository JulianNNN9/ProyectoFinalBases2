from typing import List
from dto import CompletarEspaciosDTO


class CompletarEspaciosDAO:
    def __init__(self, connection):
        self.connection = connection

    def insertar_batch(self, lista_ce_dto: List[CompletarEspaciosDTO]) -> bool:
        if not lista_ce_dto: return True
        query = """
        INSERT INTO completar_espacios (completar_pregunta_id, numero_espacio, texto_correcto)
        VALUES (:1, :2, :3)
        """ # [cite: 1]
        # SEQ_COMPLETAR_ESPACIO_ID es placeholder
        try:
            cursor = self.connection.cursor()
            datos_para_insertar = [
                (dto.completar_pregunta_id, dto.numero_espacio, dto.texto_correcto) for dto in lista_ce_dto
            ] # [cite: 1]
            cursor.executemany(query, datos_para_insertar)
            # self.connection.commit() # Commit en guardar_pregunta_completa
            return True
        except Exception as e:
            print(f"Error en CompletarEspaciosDAO.insertar_batch: {e}")
            # self.connection.rollback()
            return False
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()

    def eliminar_por_completar_pregunta_id(self, completar_pregunta_id: int) -> bool:
        query = "DELETE FROM completar_espacios WHERE completar_pregunta_id = :1" # [cite: 1]
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (completar_pregunta_id,))
            return True
        except Exception as e:
            print(f"Error en CompletarEspaciosDAO.eliminar_por_completar_pregunta_id: {e}")
            return False
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()
