class CursosDTO:
    def __init__(self, curso_id: int, nombre: str, descripcion: str, activo: str):
        self.curso_id = curso_id
        self.nombre = nombre
        self.descripcion = descripcion
        self.activo = activo

    def __repr__(self):
        return (f"CursosDTO(curso_id={self.curso_id}, nombre='{self.nombre}', "
                f"descripcion='{self.descripcion[:50]}...', activo='{self.activo}')")

    def __str__(self):
        return f"CursosDTO({self.curso_id}, '{self.nombre}', '{self.activo}')"
