class InscripcionesDTO:
    def __init__(self, inscripcion_id: int, fecha_inscripcion: object, grupo_id: int, estudiante_id: int): # [cite: 18]
        self.inscripcion_id = inscripcion_id
        self.fecha_inscripcion = fecha_inscripcion # Expecting datetime object
        self.grupo_id = grupo_id
        self.estudiante_id = estudiante_id

    def __repr__(self):
        return (f"InscripcionesDTO(inscripcion_id={self.inscripcion_id}, fecha_inscripcion={self.fecha_inscripcion}, "
                f"grupo_id={self.grupo_id}, estudiante_id={self.estudiante_id})")

    def __str__(self):
        return f"InscripcionesDTO({self.inscripcion_id}, {self.grupo_id}, {self.estudiante_id})"