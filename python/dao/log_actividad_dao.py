from dto import LogsActividadDTO

class LogActividadDAO:
    def __init__(self, connection):
        self.connection = connection

    def insertar(self, log_dto: LogsActividadDTO) -> bool:
        query = """
        INSERT INTO logs_actividad
        (fecha, ip_address, tipo_accion_id, usuario_id, estado_accion_id)
        VALUES (TO_TIMESTAMP(:1, 'YYYY-MM-DD HH24:MI:SS'), :2, :3, :4, :5)
        """
        # SEQ_LOG_ACTIVIDAD_ID es un placeholder para tu secuencia de Oracle
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (
                log_dto.fecha, log_dto.ip_address, log_dto.tipo_accion_id,
                log_dto.usuario_id, log_dto.estado_accion_id
            )) # [cite: 22]
            self.connection.commit()
            return True
        except Exception as e:
            print(f"Error en LogActividadDAO.insertar: {e}")
            self.connection.rollback()
            return False
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()

