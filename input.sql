DROP PROCEDURE IF EXISTS `input_winwatch`;
DROP PROCEDURE IF EXISTS `input_serchio`;

DELIMITER $$


CREATE PROCEDURE `input_winwatch`(
IN in_centrale VARCHAR(45),
IN in_ora VARCHAR(45),
IN in_data VARCHAR(45),
IN in_evento VARCHAR(45),
IN in_messaggio VARCHAR(100),
IN in_filename VARCHAR(45)
)
BEGIN

DECLARE my_data datetime;
DECLARE my_id_evento INT;
DECLARE my_id_messaggio INT;

DECLARE my_rid INT;
DECLARE stored_wid INT;
DECLARE stored_rid INT;

-- referer
SET @my_rid = (SELECT input_repo('winwatch',in_filename));

-- data
SET @my_data = (SELECT STR_TO_DATE(CONCAT(in_data,' ',COALESCE(in_ora,'00:00')),'%d-%m-%y %H:%i'));

-- evento
IF (in_evento IS NOT NULL) THEN
	IF NOT (SELECT test_win_evento(in_evento)) THEN
		INSERT INTO WIN_EVENTI(evento) VALUES(in_evento);
		SET @my_id_evento = LAST_INSERT_ID();
	ELSE
		SET @my_id_evento = (SELECT get_win_evento(in_evento));
	END IF;
ELSE
	SET @my_id_evento = NULL;
END IF;

-- messaggio
IF (in_messaggio IS NOT NULL) THEN
	IF NOT (SELECT test_win_messaggio(in_messaggio)) THEN
		INSERT INTO WIN_MESSAGGI(messaggio) VALUES(in_messaggio);
		SET @my_id_messaggio = LAST_INSERT_ID();
	ELSE
		SET @my_id_messaggio = (SELECT get_win_messaggio(in_messaggio));
	END IF;
ELSE
	SET @my_id_messaggio = NULL;
END IF;

-- report
IF NOT (SELECT test_win_report(in_centrale,@my_data,@my_id_evento,@my_id_messaggio)) THEN
	
	INSERT INTO WIN_REPORT(Centrale,Data,id_evento,id_messaggio,Rid,contatore)
	VALUES(in_centrale,@my_data,@my_id_evento,@my_id_messaggio,@my_rid,'1');
	
ELSE
	
	SET @stored_wid = (SELECT get_win_report(in_centrale,@my_data,@my_id_evento,@my_id_messaggio));
	SET @stored_rid = (SELECT get_win_referer(@stored_wid));
	
	UPDATE WIN_REPORT SET contatore=contatore+1 WHERE Wid=@stored_wid AND @my_rid=@stored_rid;
			
END IF;

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
IN in_ospite VARCHAR(45),
IN in_filename VARCHAR(45)
)
BEGIN

DECLARE my_data datetime;
DECLARE my_id_tessera INT;
DECLARE my_id_evento INT;
DECLARE my_id_varco INT;
DECLARE my_id_ospite INT;

DECLARE my_rid INT;
DECLARE stored_sid INT;
DECLARE stored_rid INT;

-- referer
SET @my_rid = (SELECT input_repo('serchio',in_filename));

-- data
SET @my_data = (SELECT STR_TO_DATE(CONCAT(in_data,' ',COALESCE(in_ora,'00:00')),'%d/%m/%Y %H:%i'));

-- tessera
IF (in_seriale IS NOT NULL) THEN
	IF NOT (SELECT test_ser_tessera(in_seriale)) THEN
		INSERT INTO SER_TESSERE(seriale) VALUES(in_seriale);
		SET @my_id_tessera = LAST_INSERT_ID();
	ELSE
		SET @my_id_tessera = (SELECT get_ser_tessera(in_seriale));
	END IF;
ELSE
	SET @my_id_tessera = NULL;
END IF;
	

-- evento
IF (in_evento IS NOT NULL) THEN
	IF NOT (SELECT test_ser_evento(in_evento)) THEN
		INSERT INTO SER_EVENTI(evento) VALUES(in_evento);
		SET @my_id_evento = LAST_INSERT_ID();
	ELSE
		SET @my_id_evento = (SELECT get_ser_evento(in_evento));
	END IF;
ELSE
	SET @my_id_evento = NULL;
END IF;

-- varco
IF (in_varco IS NOT NULL) THEN
	IF NOT (SELECT test_ser_varco(in_varco)) THEN
		INSERT INTO SER_VARCHI(varco) VALUES(in_varco);
		SET @my_id_varco = LAST_INSERT_ID();
	ELSE
		SET @my_id_varco = (SELECT get_ser_varco(in_varco));
	END IF;
ELSE
	SET @my_id_varco = NULL;
END IF;

-- ospite
IF (in_ospite IS NOT NULL) THEN
	IF NOT (SELECT test_ser_ospite(in_ospite)) THEN
		INSERT INTO SER_OSPITI(nome) VALUES(in_ospite);
		SET @my_id_ospite = LAST_INSERT_ID();
	ELSE
		SET @my_id_ospite = (SELECT get_ser_ospite(in_ospite));
	END IF;
ELSE
	SET @my_id_ospite = NULL;
END IF;

-- report
IF NOT (SELECT test_ser_report(@my_data,in_centrale,@my_id_tessera,@my_id_evento,@my_id_vaco,in_direzione,@my_id_ospite)) THEN

	INSERT INTO SER_REPORT(Data,Centrale,id_tessera,id_evento,id_varco,direzione,id_ospite,Rid,contatore)
	VALUES(@my_data,in_centrale,@my_id_tessera,@my_id_evento,@my_id_varco,in_direzione,@my_id_ospite,@my_rid,'1');

ELSE

	SET @stored_sid = (SELECT get_ser_report(@my_data,in_centrale,@my_id_tessera,@my_id_evento,@my_id_varco,in_direzione,@my_id_ospite));
	SET @stored_rid = (SELECT get_ser_referer(@stored_sid));
	
	UPDATE SER_REPORT SET contatore=contatore+1 WHERE Sid=@stored_sid AND @my_rid=@stored_rid;

END IF;

END;
$$

DELIMITER ;