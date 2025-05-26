class RespuestasCompletarDTO:
    def __init__(self, respuesta_completar_id: int, numero_espacio: int, texto_ingresado: str,
                 completar_espacio_id: int, respuesta_estudiante_id: int): # [cite: 33]
        self.respuesta_completar_id = respuesta_completar_id
        self.numero_espacio = numero_espacio
        self.texto_ingresado = texto_ingresado
        self.completar_espacio_id = completar_espacio_id
        self.respuesta_estudiante_id = respuesta_estudiante_id

    def __repr__(self):
        return (f"RespuestasCompletarDTO(respuesta_completar_id={self.respuesta_completar_id}, "
                f"numero_espacio={self.numero_espacio}, texto_ingresado='{self.texto_ingresado}', "
                f"completar_espacio_id={self.completar_espacio_id}, respuesta_estudiante_id={self.respuesta_estudiante_id})")

    def __str__(self):
        return f"RespuestasCompletarDTO({self.respuesta_completar_id}, '{self.texto_ingresado}', resp_est_id:{self.respuesta_estudiante_id})"
