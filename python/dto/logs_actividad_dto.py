class LogsActividadDTO:
    def __init__(self, log_actividad_id: int, fecha: object, ip_address: str,
                 tipo_accion_id: int, usuario_id: int, estado_accion_id: int): # [cite: 22]
        self.log_actividad_id = log_actividad_id
        self.fecha = fecha # Expecting datetime object
        self.ip_address = ip_address
        self.tipo_accion_id = tipo_accion_id
        self.usuario_id = usuario_id
        self.estado_accion_id = estado_accion_id

    def __repr__(self):
        return (f"LogsActividadDTO(log_actividad_id={self.log_actividad_id}, fecha={self.fecha}, "
                f"ip_address='{self.ip_address}', tipo_accion_id={self.tipo_accion_id}, "
                f"usuario_id={self.usuario_id}, estado_accion_id={self.estado_accion_id})")

    def __str__(self):
        return f"LogsActividadDTO({self.log_actividad_id}, {self.fecha}, {self.usuario_id}, {self.tipo_accion_id})"
