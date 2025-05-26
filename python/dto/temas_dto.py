class TemasDTO:
    def __init__(self, tema_id: int, nombre: str, descripcion: str, orden: int): # [cite: 43]
        self.tema_id = tema_id
        self.nombre = nombre
        self.descripcion = descripcion
        self.orden = orden

    def __repr__(self):
        return (f"TemasDTO(tema_id={self.tema_id}, nombre='{self.nombre}', "
                f"descripcion='{self.descripcion[:50]}...', orden={self.orden})")

    def __str__(self):
        return f"TemasDTO({self.tema_id}, '{self.nombre}')"
