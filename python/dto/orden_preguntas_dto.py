class OrdenPreguntasDTO:
    def __init__(self, orden_pregunta_id: int, texto: str, posicion_correcta: int, pregunta_id: int): # [cite: 26]
        self.orden_pregunta_id = orden_pregunta_id
        self.texto = texto
        self.posicion_correcta = posicion_correcta
        self.pregunta_id = pregunta_id

    def __repr__(self):
        return (f"OrdenPreguntasDTO(orden_pregunta_id={self.orden_pregunta_id}, texto='{self.texto}', "
                f"posicion_correcta={self.posicion_correcta}, pregunta_id={self.pregunta_id})")

    def __str__(self):
        return f"OrdenPreguntasDTO({self.orden_pregunta_id}, '{self.texto}', {self.posicion_correcta})"
