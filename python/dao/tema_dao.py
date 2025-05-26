from typing import List, Tuple


class TemaDAO:
    def __init__(self, connection):
        self.connection = connection

    def obtener_todos(self) -> List[Tuple[int, str]]:
        query = "SELECT tema_id, nombre FROM temas ORDER BY orden, tema_id, nombre" # [cite: 43]
        temas = []
        try:
            cursor = self.connection.cursor()
            cursor.execute(query)
            for row in cursor.fetchall():
                temas.append((row[0], row[1])) # (tema_id, nombre) [cite: 43]
            return temas
        except Exception as e:
            print(f"Error en TemaDAO.obtener_todos: {e}")
            return []
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()