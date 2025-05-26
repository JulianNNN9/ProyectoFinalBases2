class CompletarPreguntasDTO:
    def __init__(self, completar_pregunta_id: int, texto_con_espacios: str, pregunta_id: int):
        self.completar_pregunta_id = completar_pregunta_id
        self.texto_con_espacios = texto_con_espacios
        self.pregunta_id = pregunta_id

    def __repr__(self):
        return (f"CompletarPreguntasDTO(completar_pregunta_id={self.completar_pregunta_id}, "
                f"texto_con_espacios='{self.texto_con_espacios[:50]}...', pregunta_id={self.pregunta_id})") # Truncated for brevity

    def __str__(self):
        return (f"CompletarPreguntasDTO({self.completar_pregunta_id}, "
                f"'{self.texto_con_espacios[:50]}...', {self.pregunta_id})")
