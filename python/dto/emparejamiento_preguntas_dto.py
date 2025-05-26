class EmparejamientoPreguntasDTO:
    def __init__(self, emparejamiento_pregunta_id: int, opcion_a: str, opcion_b: str, pregunta_id: int):
        self.emparejamiento_pregunta_id = emparejamiento_pregunta_id
        self.opcion_a = opcion_a
        self.opcion_b = opcion_b
        self.pregunta_id = pregunta_id

    def __repr__(self):
        return (f"EmparejamientoPreguntasDTO(emparejamiento_pregunta_id={self.emparejamiento_pregunta_id}, "
                f"opcion_a='{self.opcion_a}', opcion_b='{self.opcion_b}', pregunta_id={self.pregunta_id})")

    def __str__(self):
        return (f"EmparejamientoPreguntasDTO({self.emparejamiento_pregunta_id}, '{self.opcion_a}', "
                f"'{self.opcion_b}', {self.pregunta_id})")
