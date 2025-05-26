from typing import List, Tuple


class TipoPreguntaDAO:
    def __init__(self, connection):
        self.connection = connection

    def obtener_todos(self) -> List[Tuple[int, str]]:
        query = "SELECT tipo_pregunta_id, descripcion FROM tipo_preguntas ORDER BY descripcion" # [cite: 48]
        tipos = []
        try:
            cursor = self.connection.cursor()
            cursor.execute(query)
            for row in cursor.fetchall():
                tipos.append((row[0], row[1])) # (tipo_pregunta_id, descripcion) [cite: 48]
            return tipos
        except Exception as e:
            print(f"Error en TipoPreguntaDAO.obtener_todos: {e}")
            return []
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()