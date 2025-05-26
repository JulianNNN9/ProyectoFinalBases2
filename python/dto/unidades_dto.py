class UnidadesDTO:
    def __init__(self, unidad_id: int, nombre: str, descripcion: str, orden: int, curso_id: int): # [cite: 54]
        self.unidad_id = unidad_id
        self.nombre = nombre
        self.descripcion = descripcion
        self.orden = orden
        self.curso_id = curso_id

    def __repr__(self):
        return (f"UnidadesDTO(unidad_id={self.unidad_id}, nombre='{self.nombre}', "
                f"descripcion='{self.descripcion[:50]}...', orden={self.orden}, curso_id={self.curso_id})")

    def __str__(self):
        return f"UnidadesDTO({self.unidad_id}, '{self.nombre}', curso_id:{self.curso_id})"
