from typing import Optional
from dto import TipoUsuarioDTO


class TipoUsuarioDAO:
    def __init__(self, connection):
        self.connection = connection

    def obtener_por_id(self, tipo_usuario_id: int) -> Optional[TipoUsuarioDTO]:
        query = "SELECT usuario_id, descripcion FROM tipo_usuario WHERE usuario_id = :1" # [cite: 51]
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (tipo_usuario_id,))
            row = cursor.fetchone()
            if row:
                return TipoUsuarioDTO(usuario_id=row[0], descripcion=row[1]) # [cite: 51]
            return None
        except Exception as e:
            print(f"Error en TipoUsuarioDAO.obtener_por_id: {e}")
            return None
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()