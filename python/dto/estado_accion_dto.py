class EstadoAccionDTO:
    def __init__(self, estado_accion_id: int, descripcion: str):
        self.estado_accion_id = estado_accion_id
        self.descripcion = descripcion # 'EXITOSO', 'FALLIDO' [cite: 9, 10]

    def __repr__(self):
        return f"EstadoAccionDTO(estado_accion_id={self.estado_accion_id}, descripcion='{self.descripcion}')"

    def __str__(self):
        return f"EstadoAccionDTO({self.estado_accion_id}, '{self.descripcion}')"