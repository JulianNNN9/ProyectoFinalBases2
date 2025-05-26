class CompletarEspaciosDTO:
    def __init__(self, completar_espacio_id: int, numero_espacio: int, texto_correcto: str, completar_pregunta_id: int):
        self.completar_espacio_id = completar_espacio_id
        self.numero_espacio = numero_espacio
        self.texto_correcto = texto_correcto
        self.completar_pregunta_id = completar_pregunta_id

    def __repr__(self):
        return (f"CompletarEspaciosDTO(completar_espacio_id={self.completar_espacio_id}, "
                f"numero_espacio={self.numero_espacio}, texto_correcto='{self.texto_correcto}', "
                f"completar_pregunta_id={self.completar_pregunta_id})")

    def __str__(self):
        return (f"CompletarEspaciosDTO({self.completar_espacio_id}, {self.numero_espacio}, "
                f"'{self.texto_correcto}', {self.completar_pregunta_id})")
