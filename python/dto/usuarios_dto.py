class UsuariosDTO:
    def __init__(self, usuario_id: int, nombre: str, apellido: str, email: str, contrasenia: str,
                 fecha_registro: object, activo: str, tipo_usuario_id: int): # [cite: 58]
        self.usuario_id = usuario_id
        self.nombre = nombre
        self.apellido = apellido
        self.email = email
        self.contrasenia = contrasenia # Consider storing/handling hashed passwords
        self.fecha_registro = fecha_registro # Expecting datetime object
        self.activo = activo
        self.tipo_usuario_id = tipo_usuario_id

    def __repr__(self):
        return (f"UsuariosDTO(usuario_id={self.usuario_id}, nombre='{self.nombre}', apellido='{self.apellido}', "
                f"email='{self.email}', contrasenia='***', fecha_registro={self.fecha_registro}, "
                f"activo='{self.activo}', tipo_usuario_id={self.tipo_usuario_id})")

    def __str__(self):
        return f"UsuariosDTO({self.usuario_id}, '{self.nombre} {self.apellido}', '{self.email}')"
