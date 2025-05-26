class PreguntasExamenesDTO:
    def __init__(self, pregunta_examen_id: int, peso: float, orden: int, pregunta_id: int, examen_id: int): # [cite: 31]
        self.pregunta_examen_id = pregunta_examen_id
        self.peso = peso
        self.orden = orden
        self.pregunta_id = pregunta_id
        self.examen_id = examen_id

    def __repr__(self):
        return (f"PreguntasExamenesDTO(pregunta_examen_id={self.pregunta_examen_id}, peso={self.peso}, "
                f"orden={self.orden}, pregunta_id={self.pregunta_id}, examen_id={self.examen_id})")

    def __str__(self):
        return f"PreguntasExamenesDTO({self.pregunta_examen_id}, p_id:{self.pregunta_id}, e_id:{self.examen_id})"
