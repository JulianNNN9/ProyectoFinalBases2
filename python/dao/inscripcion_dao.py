from typing import Optional
from datetime import datetime


class InscripcionDAO:
    def __init__(self, connection):
        self.connection = connection

    def insertar(self, estudiante_id: int, grupo_id: int, fecha_inscripcion: Optional[str] = None) -> bool:
        """
        Inserta una nueva inscripción en la tabla inscripciones.
        Si no se proporciona fecha_inscripcion, se usará la fecha y hora actual del sistema.
        """
        query = """
        INSERT INTO inscripciones (estudiante_id, grupo_id, fecha_inscripcion)
        VALUES (:1, :2, TO_TIMESTAMP(:3, 'YYYY-MM-DD HH24:MI:SS'))
        """
        if fecha_inscripcion is None:
            fecha_inscripcion = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (estudiante_id, grupo_id, fecha_inscripcion))
            self.connection.commit()
            return True
        except Exception as e:
            print(f"Error en InscripcionesDAO.insertar: {e}")
            self.connection.rollback()
            return False
        finally:
            cursor.close()