class IntentosExamenDTO:
    def __init__(self, intento_examen_id: int, fecha_inicio: object, fecha_fin: object,
                 tiempo_utilizado: int, puntaje_total: float, ip_address: str,
                 estudiante_id: int, examen_id: int): # [cite: 20]
        self.intento_examen_id = intento_examen_id
        self.fecha_inicio = fecha_inicio # Expecting datetime object
        self.fecha_fin = fecha_fin # Expecting datetime object
        self.tiempo_utilizado = tiempo_utilizado
        self.puntaje_total = puntaje_total
        self.ip_address = ip_address
        self.estudiante_id = estudiante_id
        self.examen_id = examen_id

    def __repr__(self):
        return (f"IntentosExamenDTO(intento_examen_id={self.intento_examen_id}, fecha_inicio={self.fecha_inicio}, "
                f"fecha_fin={self.fecha_fin}, tiempo_utilizado={self.tiempo_utilizado}, puntaje_total={self.puntaje_total}, "
                f"ip_address='{self.ip_address}', estudiante_id={self.estudiante_id}, examen_id={self.examen_id})")

    def __str__(self):
        return f"IntentosExamenDTO({self.intento_examen_id}, {self.estudiante_id}, {self.examen_id}, {self.puntaje_total})"
