class TipoAccionDTO:
    def __init__(self, tipo_accion_id: int, descripcion: str): # [cite: 45]
        self.tipo_accion_id = tipo_accion_id
        self.descripcion = descripcion # 'ENTRADA', 'SALIDA' [cite: 46]

    def __repr__(self):
        return f"TipoAccionDTO(tipo_accion_id={self.tipo_accion_id}, descripcion='{self.descripcion}')"

    def __str__(self):
        return f"TipoAccionDTO({self.tipo_accion_id}, '{self.descripcion}')"
