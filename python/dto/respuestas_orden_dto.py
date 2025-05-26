class RespuestasOrdenDTO:
    def __init__(self, respuesta_orden_id: int, texto: str, posicion_estudiante: int,
                 orden_pregunta_id: int, respuesta_estudiante_id: int): # [cite: 41]
        self.respuesta_orden_id = respuesta_orden_id
        self.texto = texto
        self.posicion_estudiante = posicion_estudiante
        self.orden_pregunta_id = orden_pregunta_id
        self.respuesta_estudiante_id = respuesta_estudiante_id

    def __repr__(self):
        return (f"RespuestasOrdenDTO(respuesta_orden_id={self.respuesta_orden_id}, texto='{self.texto[:50]}...', "
                f"posicion_estudiante={self.posicion_estudiante}, orden_pregunta_id={self.orden_pregunta_id}, "
                f"respuesta_estudiante_id={self.respuesta_estudiante_id})")

    def __str__(self):
        return f"RespuestasOrdenDTO({self.respuesta_orden_id}, '{self.texto[:50]}...', pos:{self.posicion_estudiante}, resp_est_id:{self.respuesta_estudiante_id})"
