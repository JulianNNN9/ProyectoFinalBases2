class TipoPreguntasDTO:
    def __init__(self, tipo_pregunta_id: int, descripcion: str): # [cite: 48]
        self.tipo_pregunta_id = tipo_pregunta_id
        self.descripcion = descripcion # 'COMPLETAR', 'EMPAREJAR', 'OPCION_MULTIPLE', 'OPCION_UNICA', 'ORDENAR', 'VERDADERO_FALSO' [cite: 49]

    def __repr__(self):
        return f"TipoPreguntasDTO(tipo_pregunta_id={self.tipo_pregunta_id}, descripcion='{self.descripcion}')"

    def __str__(self):
        return f"TipoPreguntasDTO({self.tipo_pregunta_id}, '{self.descripcion}')"
