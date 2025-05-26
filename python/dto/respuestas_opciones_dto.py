class RespuestasOpcionesDTO:
    def __init__(self, respuesta_opcion_id: int, respuesta_estudiante_id: int, opcion_pregunta_id: int): # [cite: 39]
        self.respuesta_opcion_id = respuesta_opcion_id
        self.respuesta_estudiante_id = respuesta_estudiante_id
        self.opcion_pregunta_id = opcion_pregunta_id

    def __repr__(self):
        return (f"RespuestasOpcionesDTO(respuesta_opcion_id={self.respuesta_opcion_id}, "
                f"respuesta_estudiante_id={self.respuesta_estudiante_id}, opcion_pregunta_id={self.opcion_pregunta_id})")

    def __str__(self):
        return f"RespuestasOpcionesDTO({self.respuesta_opcion_id}, resp_est_id:{self.respuesta_estudiante_id}, opc_preg_id:{self.opcion_pregunta_id})"
