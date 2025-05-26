class ExamenesDTO:
    def __init__(self, examen_id: int, descripcion: str, fecha_creacion: object, fecha_disponible: object,
                 fecha_limite: object, tiempo_limite: int, peso: float, umbral_aprobacion: float,
                 cantidad_preguntas_mostrar: int, aleatorizar_preguntas: str, creador_id: int, grupo_id: int):
        self.examen_id = examen_id
        self.descripcion = descripcion
        self.fecha_creacion = fecha_creacion # Expecting datetime object
        self.fecha_disponible = fecha_disponible # Expecting datetime object or None
        self.fecha_limite = fecha_limite # Expecting datetime object or None
        self.tiempo_limite = tiempo_limite
        self.peso = peso
        self.umbral_aprobacion = umbral_aprobacion
        self.cantidad_preguntas_mostrar = cantidad_preguntas_mostrar
        self.aleatorizar_preguntas = aleatorizar_preguntas
        self.creador_id = creador_id
        self.grupo_id = grupo_id

    def __repr__(self):
        return (f"ExamenesDTO(examen_id={self.examen_id}, descripcion='{self.descripcion[:50]}...', "
                f"fecha_creacion={self.fecha_creacion}, fecha_disponible={self.fecha_disponible}, "
                f"fecha_limite={self.fecha_limite}, tiempo_limite={self.tiempo_limite}, peso={self.peso}, "
                f"umbral_aprobacion={self.umbral_aprobacion}, cantidad_preguntas_mostrar={self.cantidad_preguntas_mostrar}, "
                f"aleatorizar_preguntas='{self.aleatorizar_preguntas}', creador_id={self.creador_id}, grupo_id={self.grupo_id})")

    def __str__(self):
        return f"ExamenesDTO({self.examen_id}, '{self.descripcion[:50]}...', {self.grupo_id})"
