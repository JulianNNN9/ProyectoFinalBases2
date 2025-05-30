/*==============================================================*/
/* DDL STATEMENTS                                                */
/*==============================================================*/

CREATE SEQUENCE SQ_INTENTO_EXAMEN_ID
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;
/

-- Create sequence for PREGUNTAS_EXAMENES table
CREATE SEQUENCE EDUNOVA.SQ_PREGUNTA_EXAMEN_ID
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE
  NOMAXVALUE;

  /

  -- Create sequence for EXAMENES table
CREATE SEQUENCE EDUNOVA.seq_examenes
  START WITH 1
  INCREMENT BY 1
  NOCACHE
  NOCYCLE
  NOMAXVALUE;

  
CREATE SEQUENCE  "EDUNOVA"."SQ_RESPUESTA_ESTUDIANTE_ID"  
MINVALUE 1 MAXVALUE 9999999999999999999999999999 
INCREMENT BY 1 START WITH 1 NOCACHE  NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;


CREATE SEQUENCE  "EDUNOVA"."SQ_RESPUESTAS_EST_ID"
MINVALUE 1 MAXVALUE 9999999999999999999999999999
 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  GLOBAL ;

     -- Crear las secuencias necesarias si no existen
BEGIN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE SQ_TEMA_ID START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN -- nombre ya existe
            NULL;
        ELSE
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'CREATE SEQUENCE SQ_PREGUNTA_ID START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -955 THEN -- nombre ya existe
            NULL;
        ELSE
            RAISE;
        END IF;
END;
/