import cx_Oracle
from typing import Any, Dict, List, Optional, Tuple
from dto.examenes_dto import ExamenesDTO

class ExamenDAO:
    def __init__(self, connection):
        self.connection = connection

    def obtener_examenes_disponibles_para_estudiante(self, estudiante_id: int) -> List[Tuple[int, str, Any]]:
        """
        Devuelve lista de tuplas (examen_id, descripcion, fecha_limite).
        """
        query = """
        SELECT DISTINCT e.examen_id, TO_CHAR(e.descripcion) AS descripcion, e.fecha_limite
        FROM examenes e
        JOIN grupos g ON e.grupo_id = g.grupo_id
        JOIN inscripciones i ON g.grupo_id = i.grupo_id
        WHERE i.estudiante_id = :1
        AND (e.fecha_disponible IS NULL OR e.fecha_disponible <= SYSTIMESTAMP)
        AND (e.fecha_limite IS NULL OR e.fecha_limite >= SYSTIMESTAMP)
        ORDER BY e.fecha_limite ASC
        """
        examenes = []
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (estudiante_id,))
            for row in cursor.fetchall():
                examen_id, descripcion_lob, fecha_limite = row
                # Si es LOB, leer como str
                if isinstance(descripcion_lob, cx_Oracle.LOB):
                    descripcion = descripcion_lob.read()
                else:
                    descripcion = descripcion_lob
                examenes.append((examen_id, descripcion, fecha_limite))
            return examenes
        except Exception as e:
            print(f"Error en ExamenDAO.obtener_examenes_disponibles_para_estudiante: {e}")
            return []
        finally:
            cursor.close()

    def obtener_por_id(self, examen_id: int) -> Optional[ExamenesDTO]:
        """
        Devuelve un ExamenesDTO con todos los campos del examen.
        """
        query = """
        SELECT examen_id, descripcion, fecha_creacion, fecha_disponible, fecha_limite,
               tiempo_limite, peso, umbral_aprobacion, cantidad_preguntas_mostrar,
               aleatorizar_preguntas, creador_id, grupo_id
        FROM examenes
        WHERE examen_id = :1
        """
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (examen_id,))
            row = cursor.fetchone()
            if not row:
                return None

            # Leer CLOB de descripcion
            descripcion_lob = row[1]
            if isinstance(descripcion_lob, cx_Oracle.LOB):
                descripcion = descripcion_lob.read()
            else:
                descripcion = descripcion_lob

            return ExamenesDTO(
                examen_id=row[0],
                descripcion=descripcion,
                fecha_creacion=row[2],
                fecha_disponible=row[3],
                fecha_limite=row[4],
                tiempo_limite=row[5],
                peso=row[6],
                umbral_aprobacion=row[7],
                cantidad_preguntas_mostrar=row[8],
                aleatorizar_preguntas=row[9],
                creador_id=row[10],
                grupo_id=row[11]
            )
        except Exception as e:
            print(f"Error en ExamenDAO.obtener_por_id: {e}")
            return None
        finally:
            cursor.close()

    def obtener_por_creador_id(self, profesor_id: int) -> List[Dict[str, Any]]:
        """
        Devuelve lista de dicts {'id', 'descripcion'} para los exámenes creados por un profesor.
        """
        query = "SELECT examen_id, descripcion FROM examenes WHERE creador_id = :1"
        examenes = []
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (profesor_id,))
            for row in cursor.fetchall():
                examen_id, descripcion_lob = row
                # Leer CLOB de descripcion
                if isinstance(descripcion_lob, cx_Oracle.LOB):
                    descripcion = descripcion_lob.read()
                else:
                    descripcion = descripcion_lob
                examenes.append({'id': examen_id, 'descripcion': descripcion})
            return examenes
        except Exception as e:
            print(f"Error en ExamenDAO.obtener_por_creador_id: {e}")
            return []
        finally:
            cursor.close()

    def insertar(self, examen_dto: ExamenesDTO) -> Optional[int]:
        """
        Inserta un nuevo examen y retorna su ID generado.
        """
        query = """
        INSERT INTO examenes (
            descripcion, fecha_creacion, fecha_disponible, fecha_limite,
            tiempo_limite, peso, umbral_aprobacion, cantidad_preguntas_mostrar,
            aleatorizar_preguntas, creador_id, grupo_id
        ) VALUES (
            :descripcion,
            TO_TIMESTAMP(:fecha_creacion, 'YYYY-MM-DD HH24:MI:SS'),
            TO_TIMESTAMP(:fecha_disponible, 'YYYY-MM-DD HH24:MI:SS'),
            TO_TIMESTAMP(:fecha_limite, 'YYYY-MM-DD HH24:MI:SS'),
            :tiempo_limite, :peso, :umbral_aprobacion, :cantidad_preguntas_mostrar,
            :aleatorizar_preguntas, :creador_id, :grupo_id
        ) RETURNING examen_id INTO :out_id
        """
        try:
            cursor = self.connection.cursor()
            out_id = cursor.var(int)
            params = {
                'descripcion': examen_dto.descripcion,
                'fecha_creacion': examen_dto.fecha_creacion,
                'fecha_disponible': examen_dto.fecha_disponible,
                'fecha_limite': examen_dto.fecha_limite,
                'tiempo_limite': examen_dto.tiempo_limite,
                'peso': examen_dto.peso,
                'umbral_aprobacion': examen_dto.umbral_aprobacion,
                'cantidad_preguntas_mostrar': examen_dto.cantidad_preguntas_mostrar,
                'aleatorizar_preguntas': examen_dto.aleatorizar_preguntas,
                'creador_id': examen_dto.creador_id,
                'grupo_id': examen_dto.grupo_id,
                'out_id': out_id
            }
            cursor.execute(query, params)
            self.connection.commit()
            return out_id.getvalue()[0]
        except Exception as e:
            print(f"Error en ExamenDAO.insertar: {e}")
            self.connection.rollback()
            return None
        finally:
            cursor.close()