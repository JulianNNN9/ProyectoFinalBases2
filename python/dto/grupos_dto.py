class GruposDTO:
    def __init__(self, grupo_id: int, nombre: str, lugar: str, horario: str, profesor_id: int, curso_id: int): # [cite: 16]
        self.grupo_id = grupo_id
        self.nombre = nombre
        self.lugar = lugar
        self.horario = horario
        self.profesor_id = profesor_id
        self.curso_id = curso_id

    def __repr__(self):
        return (f"GruposDTO(grupo_id={self.grupo_id}, nombre='{self.nombre}', lugar='{self.lugar}', "
                f"horario='{self.horario}', profesor_id={self.profesor_id}, curso_id={self.curso_id})")

    def __str__(self):
        return f"GruposDTO({self.grupo_id}, '{self.nombre}', {self.profesor_id}, {self.curso_id})"