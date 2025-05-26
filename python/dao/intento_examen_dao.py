from typing import Optional
from dto import IntentosExamenDTO

class IntentoExamenDAO:
    def __init__(self, connection):
        self.connection = connection

    def iniciar_intento(self, intento_dto: IntentosExamenDTO) -> Optional[int]:
        query = """
        INSERT INTO intentos_examen (
            fecha_inicio, fecha_fin, tiempo_utilizado,
            puntaje_total, ip_address, estudiante_id, examen_id
        ) VALUES (
            TO_TIMESTAMP(:1, 'YYYY-MM-DD HH24:MI:SS'),
            TO_TIMESTAMP(:2, 'YYYY-MM-DD HH24:MI:SS'), :3, :4, :5, :6, :7
        ) RETURNING intento_examen_id INTO :out_id
        """ # [cite: 20]
        # SEQ_INTENTO_EXAMEN_ID es placeholder. Fecha_fin y puntaje_total pueden ser NULL al inicio.
        # El DTO debe permitir valores nulos para campos no obligatorios.
        try:
            cursor = self.connection.cursor()
            out_id = cursor.var(int)
            cursor.execute(query, (
                intento_dto.fecha_inicio, intento_dto.fecha_fin, # fecha_fin podría ser null al inicio
                intento_dto.tiempo_utilizado, intento_dto.puntaje_total, # puntaje_total podría ser null
                intento_dto.ip_address, intento_dto.estudiante_id, intento_dto.examen_id,
                out_id
            )) # [cite: 20]
            self.connection.commit()
            return out_id.getvalue()[0]
        except Exception as e:
            print(f"Error en IntentoExamenDAO.iniciar_intento: {e}")
            self.connection.rollback()
            return None
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()

    def finalizar_intento(self, intento_id: int, fecha_fin_str: str, tiempo_utilizado: int, puntaje_total: float) -> bool:
        query = """
        UPDATE intentos_examen
        SET fecha_fin = TO_TIMESTAMP(:1, 'YYYY-MM-DD HH24:MI:SS'),
            tiempo_utilizado = :2,
            puntaje_total = :3
        WHERE intento_examen_id = :4
        """ # [cite: 20]
        try:
            cursor = self.connection.cursor()
            cursor.execute(query, (fecha_fin_str, tiempo_utilizado, puntaje_total, intento_id)) # [cite: 20]
            self.connection.commit()
            return True
        except Exception as e:
            print(f"Error en IntentoExamenDAO.finalizar_intento: {e}")
            self.connection.rollback()
            return False
        finally:
            if 'cursor' in locals() and cursor:
                cursor.close()