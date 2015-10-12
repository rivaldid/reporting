DROP PROCEDURE IF EXISTS `input_winwatch`;
DROP PROCEDURE IF EXISTS `input_serchio`;

DELIMITER $$


CREATE PROCEDURE `input_repo`(
IN in_tipo VARCHAR(45),
IN in_filename VARCHAR(45)
)
BEGIN
IF NOT (SELECT test_repo(in_tipo,in_filename)) THEN
	INSERT INTO REPOSITORY(data,tipo,filename) VALUES((SELECT NOW()),in_tipo,in_filename);
END IF;
END;
$$


CREATE PROCEDURE `input_winwatch`(
IN in_centrale VARCHAR(45),
IN in_ora VARCHAR(45),
IN in_data VARCHAR(45),
IN in_evento VARCHAR(45),
IN in_messaggio VARCHAR(100)
)
BEGIN

DECLARE my_data datetime;
DECLARE my_id_evento INT;
DECLARE my_id_messaggio INT;

-- data
SET my_data = (SELECT STR_TO_DATE(CONCAT(in_data,' ',in_ora),'%d-%m-%y %H:%i'));

-- evento
IF NOT (SELECT test_win_evento(in_evento)) THEN
	INSERT INTO WIN_EVENTI(evento) VALUES(in_evento);
	SET my_id_evento = LAST_INSERT_ID();
ELSE
	SET my_id_evento = (SELECT get_win_evento(in_evento));
END IF;

-- messaggio
IF NOT (SELECT test_win_messaggio(in_messaggio)) THEN
	INSERT INTO WIN_MESSAGGI(messaggio) VALUES(in_messaggio);
	SET my_id_messaggio = LAST_INSERT_ID();
ELSE
	SET my_id_messaggio = (SELECT get_win_messaggio(in_messaggio));
END IF;

-- report
INSERT INTO WIN_REPORT(Centrale,Data,id_evento,id_messaggio)
VALUES(in_centrale,my_data,my_id_evento,my_id_messaggio);

END;
$$


CREATE PROCEDURE `input_serchio`(
IN in_data VARCHAR(45),
IN in_ora VARCHAR(45),
IN in_centrale VARCHAR(45),
IN in_seriale VARCHAR(45),
IN in_evento VARCHAR(45),
IN in_varco VARCHAR(45),
IN in_direzione VARCHAR(45),
IN in_ospite VARCHAR(45)
)
BEGIN

DECLARE my_data datetime;
DECLARE my_id_tessera INT;
DECLARE my_id_evento INT;
DECLARE my_id_messaggio INT;
DECLARE my_id_ospite INT;

-- data
SET my_data = (SELECT STR_TO_DATE(CONCAT(in_data,' ',in_ora),'%d/%m/%Y %H:%i'));

-- tessera
IF NOT (SELECT test_ser_tessera(in_seriale)) THEN
	INSERT INTO SER_TESSERE(seriale) VALUES(in_seriale);
	SET my_id_tessera = LAST_INSERT_ID();
ELSE
	SET my_id_tessera = (SELECT get_ser_tessera(in_seriale));
END IF;

-- evento
IF NOT (SELECT test_ser_evento(in_evento)) THEN
	INSERT INTO SER_EVENTI(evento) VALUES(in_evento);
	SET my_id_evento = LAST_INSERT_ID();
ELSE
	SET my_id_evento = (SELECT get_ser_evento(in_evento));
END IF;

-- messaggio
IF NOT (SELECT test_ser_messaggio(in_varco,in_direzione)) THEN
	INSERT INTO SER_MESSAGGI(varco,direzione) VALUES(in_varco,in_direzione);
	SET my_id_messaggio = LAST_INSERT_ID();
ELSE
	SET my_id_messaggio = (SELECT get_ser_messaggio(in_varco,in_direzione));
END IF;

-- ospite
IF NOT (SELECT test_ser_ospite(in_ospite)) THEN
	INSERT INTO SER_OSPITI(nome) VALUES(in_ospite);
	SET my_id_ospite = LAST_INSERT_ID();
ELSE
	SET my_id_ospite = (SELECT get_ser_ospite(in_ospite));
END IF;

-- report
INSERT INTO SER_REPORT(Data,Centrale,id_tessera,id_evento,id_messaggio,id_ospite)
VALUES(my_data,in_centrale,my_id_tessera,my_id_evento,my_id_messaggio,my_id_ospite);


END;
$$

DELIMITER ;