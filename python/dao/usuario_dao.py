from typing import Optional
from dto import UsuariosDTO


class UsuarioDAO:
    def __init__(self, connection):
        self.connection = connection

    def buscar_por_email(self, email: str) -> Optional[UsuariosDTO]:
        """
        Busca un usuario por email y adjunta la descripción de su tipo.
        Retorna UsuarioDTO si se encuentra y está activo, None en caso contrario.
        """
        query = """
        SELECT usuario_id, nombre, apellido, email, contrasenia,
               fecha_registro, activo, tipo_usuario_id
        FROM usuarios
        WHERE email = :1 AND activo = 'S'
        """
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (email,))
            row = cursor.fetchone()
            if row:
                return UsuariosDTO(
                    usuario_id=row[0], nombre=row[1], apellido=row[2], email=row[3],
                    contrasenia=row[4], fecha_registro=row[5], activo=row[6],
                    tipo_usuario_id=row[7]
                )
            return None
        except Exception as e:
            print(f"Error en UsuarioDAO.buscar_por_email: {e}")
            return None
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()

    def obtener_id_por_email(self, email: str) -> Optional[int]:
        query = "SELECT usuario_id FROM usuarios WHERE email = :1"
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (email,))
            row = cursor.fetchone()
            return row[0] if row else None
        except Exception as e:
            print(f"Error en UsuarioDAO.obtener_id_por_email: {e}")
            return None
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()

    def obtener_estudiantes(self):
        """
        Retorna una lista de UsuariosDTO para los usuarios cuyo tipo sea 'ESTUDIANTE'.
        """
        query = """
        SELECT u.usuario_id, u.nombre, u.apellido, u.email, u.contrasenia,
            u.fecha_registro, u.activo, u.tipo_usuario_id
        FROM usuarios u
        JOIN tipo_usuario tu ON u.tipo_usuario_id = tu.usuario_id
        WHERE tu.descripcion = 'ESTUDIANTE' AND u.activo = 'S'
        """
        try:
            cursor = self.connection.cursor()
            cursor.execute(query)
            estudiantes = []
            for row in cursor.fetchall():
                estudiantes.append(UsuariosDTO(
                    usuario_id=row[0], nombre=row[1], apellido=row[2], email=row[3],
                    contrasenia=row[4], fecha_registro=row[5], activo=row[6], tipo_usuario_id=row[7]
                ))
            return estudiantes
        except Exception as e:
            print(f"Error en UsuarioDAO.obtener_estudiantes: {e}")
            return []
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()