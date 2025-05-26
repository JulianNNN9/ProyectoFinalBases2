from typing import List, Optional
from dto import RespuestasEstudiantesDTO


class RespuestasEstudiantesDAO:
    def __init__(self, connection):
        self.connection = connection

    def insertar_batch_y_retornar_ids(self, lista_re_dto: List[RespuestasEstudiantesDTO]) -> List[Optional[int]]:
        """
        Inserta un batch de respuestas y intenta retornar sus IDs.
        NOTA: Retornar IDs de un batch insert con RETURNING INTO y executemany es complejo
        y depende del driver de Oracle (cx_Oracle puede necesitar un enfoque diferente).
        Este es un enfoque simplificado; puede que necesites insertar uno por uno si el batch con RETURNING es problemático.
        """
        if not lista_re_dto: return []
        
        inserted_ids = []
        query = """
        INSERT INTO respuestas_estudiantes (
            es_correcta, puntaje_obtenido,
            intento_examen_id, pregunta_examen_id
        ) VALUES (
            :1, :2, :3, :4
        ) RETURNING respuesta_estudiante_id INTO :out_id
        """ # [cite: 37]
        # SEQ_RESP_ESTUDIANTE_ID es placeholder
        
        try:
            cursor = self.connection.cursor()
            for dto in lista_re_dto:
                out_id_var = cursor.var(int)
                cursor.execute(query, (
                    dto.es_correcta, dto.puntaje_obtenido,
                    dto.intento_examen_id, dto.pregunta_examen_id,
                    out_id_var
                )) # [cite: 37]
                inserted_ids.append(out_id_var.getvalue()[0])
            self.connection.commit()
            return inserted_ids
        except Exception as e:
            print(f"Error en RespuestasEstudiantesDAO.insertar_batch_y_retornar_ids: {e}")
            self.connection.rollback()
            return [None] * len(lista_re_dto) # Retornar Nones en caso de error
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()
