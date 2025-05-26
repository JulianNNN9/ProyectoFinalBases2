class TipoUsuarioDTO:
    def __init__(self, usuario_id: int, descripcion: str): # Columna se llama usuario_id en TIPO_USUARIO pero es el ID del tipo [cite: 51]
        self.tipo_usuario_id = usuario_id # Renombrado para claridad, aunque la tabla usa 'usuario_id'
        self.descripcion = descripcion # 'ESTUDIANTE', 'PROFESOR' [cite: 52]

    def __repr__(self):
        return f"TipoUsuarioDTO(tipo_usuario_id={self.tipo_usuario_id}, descripcion='{self.descripcion}')"

    def __str__(self):
        return f"TipoUsuarioDTO({self.tipo_usuario_id}, '{self.descripcion}')"
