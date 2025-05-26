from typing import List, Tuple

class GrupoDAO:
    def __init__(self, connection):
        self.connection = connection

    def obtener_por_profesor_id(self, profesor_id: int) -> List[Tuple[int, str]]:
        query = "SELECT grupo_id, nombre FROM grupos WHERE profesor_id = :1" # [cite: 16]
        grupos = []
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (profesor_id,))
            for row in cursor.fetchall():
                grupos.append((row[0], row[1])) # (grupo_id, nombre)
            return grupos
        except Exception as e:
            print(f"Error en GrupoDAO.obtener_por_profesor_id: {e}")
            return []
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()