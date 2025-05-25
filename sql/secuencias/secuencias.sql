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