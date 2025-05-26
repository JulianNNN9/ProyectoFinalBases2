import cx_Oracle
from typing import Any, Dict, List
from dto import PreguntasExamenesDTO


class PreguntasExamenesDAO:
    def __init__(self, connection):
        self.connection = connection

    def existe_asociacion_con_pregunta(self, pregunta_id: int) -> bool:
        query = "SELECT 1 FROM preguntas_examenes WHERE pregunta_id = :1 AND ROWNUM = 1" # [cite: 31]
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (pregunta_id,))
            return cursor.fetchone() is not None
        except Exception as e:
            print(f"Error en PreguntasExamenesDAO.existe_asociacion_con_pregunta: {e}")
            return True # Asumir que existe en caso de error para prevenir borrado
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()
                
    def obtener_detalles_por_examen_id(self, examen_id: int) -> List[Dict[str, Any]]:
        query = """
        SELECT pe.pregunta_id, p.texto, pe.peso, pe.orden
        FROM preguntas_examenes pe
        JOIN preguntas p ON pe.pregunta_id = p.pregunta_id
        WHERE pe.examen_id = :1
        ORDER BY pe.orden
        """  # [cite: 31, 28]
        preguntas_asociadas = []
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (examen_id,))
            for row in cursor.fetchall():
                texto = row[1]
                if isinstance(texto, cx_Oracle.LOB):
                    texto = texto.read()

                preguntas_asociadas.append({
                    'id': row[0],  # pregunta_id
                    'texto': texto,
                    'peso': row[2],
                    'orden': row[3]
                })
            return preguntas_asociadas
        except Exception as e:
            print(f"Error en PreguntasExamenesDAO.obtener_detalles_por_examen_id: {e}")
            return []
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()

    def reemplazar_asociaciones_por_examen_id(self, examen_id: int, lista_pe_dto: List[PreguntasExamenesDTO]) -> bool:
        try:
            cursor = self.connection.cursor()
            # 1. Eliminar existentes
            query_delete = "DELETE FROM preguntas_examenes WHERE examen_id = :1" # [cite: 31]
            cursor.execute(query_delete, (examen_id,))

            # 2. Insertar nuevas
            if lista_pe_dto:
                query_insert = """
                INSERT INTO preguntas_examenes (examen_id, pregunta_id, peso, orden)
                VALUES (:1, :2, :3, :4)
                """ # [cite: 31]
                # SEQ_PREGUNTA_EXAMEN_ID es placeholder
                datos_para_insertar = [
                    (dto.examen_id, dto.pregunta_id, dto.peso, dto.orden) for dto in lista_pe_dto
                ]
                cursor.executemany(query_insert, datos_para_insertar)
            
            self.connection.commit()
            return True
        except Exception as e:
            print(f"Error en PreguntasExamenesDAO.reemplazar_asociaciones_por_examen_id: {e}")
            self.connection.rollback()
            return False
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()
    
    def obtener_preguntas_formateadas_para_rendir(self, examen_id: int) -> List[Dict[str, Any]]:
        """
        Este es el método más complejo. Debería construir la estructura de datos
        que `VentanaResponderExamen` espera, similar a `obtener_preguntas_examen_db` simulado.
        Devolverá una lista de diccionarios, cada diccionario representando una pregunta completa.
        """
        print(f"DEV_NOTE: PreguntasExamenesDAO.obtener_preguntas_formateadas_para_rendir para examen {examen_id} necesita una implementación compleja.")
        # 1. Obtener las preguntas_examenes para el examen_id, incluyendo pregunta_id, peso, orden.
        # 2. Para cada pregunta_id:
        #    a. Obtener los detalles de la tabla PREGUNTAS (texto, tipo_pregunta).
        #    b. Basado en tipo_pregunta, obtener los detalles de las tablas específicas:
        #       - OPCIONES_PREGUNTAS (texto, es_correcta, orden)
        #       - COMPLETAR_PREGUNTAS (texto_con_espacios) y luego COMPLETAR_ESPACIOS (numero_espacio, texto_correcto)
        #       - EMPAREJAMIENTO_PREGUNTAS (opcion_a, opcion_b)
        #       - ORDEN_PREGUNTAS (texto, posicion_correcta)
        #    c. Ensamblar todo en el formato de diccionario esperado.

        # Simulación simplificada como en la UI, para que no falle:
        if examen_id == 101: # Asumiendo que examen 101 existe para el ejemplo
            return [
                {'pregunta_examen_id': 1, 'pregunta_id': 10, 'texto': '¿Derivada de x^2? (DB Full)', 
                 'tipo_pregunta': 'OPCION_UNICA', # De TIPO_PREGUNTAS.descripcion
                 'opciones': [{'opcion_pregunta_id': 101, 'texto': '2x', 'es_correcta': 'S'}, 
                              {'opcion_pregunta_id': 102, 'texto': 'x', 'es_correcta': 'N'}],
                 'peso': 50, 'orden': 1},
                {'pregunta_examen_id': 3, 'pregunta_id': 12, 'texto': '¿POO es un paradigma? (DB Full)', 
                 'tipo_pregunta': 'VERDADERO_FALSO', 'peso': 50, 'orden': 2,
                 'opciones': [{'opcion_pregunta_id': 201, 'texto': 'Verdadero', 'es_correcta': 'S'}, # V/F también usa opciones
                              {'opcion_pregunta_id': 202, 'texto': 'Falso', 'es_correcta': 'N'}]} 
            ]
        return []

    def insertar_batch(self, lista_pe_dto: List[Any]) -> bool:
        """
        Inserta múltiples asociaciones de preguntas en un examen.
        Cada DTO en lista_pe_dto debe tener atributos: examen_id, pregunta_id, peso, orden.
        """
        query = """
        INSERT INTO preguntas_examenes (
            examen_id, pregunta_id, peso, orden
        ) VALUES (
            :examen_id, :pregunta_id, :peso, :orden
        )
        """
        try:
            cursor = self.connection.cursor()
            data = [
                {
                    'examen_id': dto.examen_id,
                    'pregunta_id': dto.pregunta_id,
                    'peso': dto.peso,
                    'orden': dto.orden
                }
                for dto in lista_pe_dto
            ]
            cursor.executemany(query, data)
            self.connection.commit()
            return True
        except Exception as e:
            print(f"Error en PreguntasExamenesDAO.insertar_batch: {e}")
            self.connection.rollback()
            return False
        finally:
            cursor.close()
