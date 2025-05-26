class RespuestasEstudiantesDTO:
    def __init__(self, respuesta_estudiante_id: int, es_correcta: str, puntaje_obtenido: float,
                 intento_examen_id: int, pregunta_examen_id: int): # [cite: 37]
        self.respuesta_estudiante_id = respuesta_estudiante_id
        self.es_correcta = es_correcta
        self.puntaje_obtenido = puntaje_obtenido
        self.intento_examen_id = intento_examen_id
        self.pregunta_examen_id = pregunta_examen_id

    def __repr__(self):
        return (f"RespuestasEstudiantesDTO(respuesta_estudiante_id={self.respuesta_estudiante_id}, "
                f"es_correcta='{self.es_correcta}', puntaje_obtenido={self.puntaje_obtenido}, "
                f"intento_examen_id={self.intento_examen_id}, pregunta_examen_id={self.pregunta_examen_id})")

    def __str__(self):
        return f"RespuestasEstudiantesDTO({self.respuesta_estudiante_id}, intento_id:{self.intento_examen_id}, preg_ex_id:{self.pregunta_examen_id})"
