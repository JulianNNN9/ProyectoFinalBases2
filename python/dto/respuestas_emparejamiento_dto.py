class RespuestasEmparejamientoDTO:
    def __init__(self, respuesta_emparejamiento_id: int, opcion_a: str, opcion_b: str,
                 respuesta_estudiante_id: int, emparejamiento_pregunta_id: int): # [cite: 35]
        self.respuesta_emparejamiento_id = respuesta_emparejamiento_id
        self.opcion_a = opcion_a
        self.opcion_b = opcion_b
        self.respuesta_estudiante_id = respuesta_estudiante_id
        self.emparejamiento_pregunta_id = emparejamiento_pregunta_id

    def __repr__(self):
        return (f"RespuestasEmparejamientoDTO(respuesta_emparejamiento_id={self.respuesta_emparejamiento_id}, "
                f"opcion_a='{self.opcion_a}', opcion_b='{self.opcion_b}', "
                f"respuesta_estudiante_id={self.respuesta_estudiante_id}, emparejamiento_pregunta_id={self.emparejamiento_pregunta_id})")

    def __str__(self):
        return f"RespuestasEmparejamientoDTO({self.respuesta_emparejamiento_id}, '{self.opcion_a}'<>'{self.opcion_b}', resp_est_id:{self.respuesta_estudiante_id})"
