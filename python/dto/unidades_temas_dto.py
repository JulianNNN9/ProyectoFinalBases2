class UnidadesTemasDTO:
    def __init__(self, unidad_id: int, tema_id: int, orden: int): # [cite: 56]
        self.unidad_id = unidad_id
        self.tema_id = tema_id
        self.orden = orden

    def __repr__(self):
        return (f"UnidadesTemasDTO(unidad_id={self.unidad_id}, tema_id={self.tema_id}, orden={self.orden})")

    def __str__(self):
        return f"UnidadesTemasDTO(u:{self.unidad_id}, t:{self.tema_id}, o:{self.orden})"
