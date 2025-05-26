class OpcionesPreguntasDTO:
    def __init__(self, opcion_pregunta_id: int, texto: str, es_correcta: str, orden: int, pregunta_id: int): # [cite: 24]
        self.opcion_pregunta_id = opcion_pregunta_id
        self.texto = texto
        self.es_correcta = es_correcta
        self.orden = orden
        self.pregunta_id = pregunta_id

    def __repr__(self):
        return (f"OpcionesPreguntasDTO(opcion_pregunta_id={self.opcion_pregunta_id}, texto='{self.texto[:50]}...', "
                f"es_correcta='{self.es_correcta}', orden={self.orden}, pregunta_id={self.pregunta_id})")

    def __str__(self):
        return f"OpcionesPreguntasDTO({self.opcion_pregunta_id}, '{self.texto[:50]}...', '{self.es_correcta}')"
