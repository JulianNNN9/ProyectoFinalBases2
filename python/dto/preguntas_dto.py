class PreguntasDTO:
    def __init__(self, pregunta_id: int, texto: str, fecha_creacion: object, es_publica: str,
                 tiempo_maximo: int, pregunta_padre_id: int, tipo_pregunta_id: int,
                 creador_id: int, tema_id: int): # [cite: 28]
        self.pregunta_id = pregunta_id
        self.texto = texto
        self.fecha_creacion = fecha_creacion # Expecting datetime object
        self.es_publica = es_publica
        self.tiempo_maximo = tiempo_maximo
        self.pregunta_padre_id = pregunta_padre_id
        self.tipo_pregunta_id = tipo_pregunta_id
        self.creador_id = creador_id
        self.tema_id = tema_id

    def __repr__(self):
        return (f"PreguntasDTO(pregunta_id={self.pregunta_id}, texto='{self.texto[:50]}...', "
                f"fecha_creacion={self.fecha_creacion}, es_publica='{self.es_publica}', "
                f"tiempo_maximo={self.tiempo_maximo}, pregunta_padre_id={self.pregunta_padre_id}, "
                f"tipo_pregunta_id={self.tipo_pregunta_id}, creador_id={self.creador_id}, tema_id={self.tema_id})")

    def __str__(self):
        return f"PreguntasDTO({self.pregunta_id}, '{self.texto[:50]}...', {self.tipo_pregunta_id})"
