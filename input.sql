DROP PROCEDURE IF EXISTS `input_winwatch`;
DROP PROCEDURE IF EXISTS `input_serchio`;
DROP PROCEDURE IF EXISTS `input_adc`;

-- schema procedure input
-- begin
-- 1) set @myrid from input_repo(checksum)
-- 2) set @mydata
-- 3winwatch) set @myevento/@mymessaggio
-- 3serchio) set @myseriale/@myevento/@myvarco/@myospite
-- 4) REPORT
--	if not(test exists)
--		insert
--	else
--		get stored id
--		get stored rid
--		update contatore++ where id,rid
--	end if		
-- end

DELIMITER $$


CREATE PROCEDURE `input_winwatch`(
IN in_centrale VARCHAR(45),
IN in_ora VARCHAR(45),
IN in_data VARCHAR(45),
IN in_evento VARCHAR(45),
IN in_messaggio VARCHAR(100),
IN in_checksum CHAR(32)
)
BEGIN

DECLARE my_data datetime;
DECLARE my_id_evento INT;
DECLARE my_id_messaggio INT;

DECLARE my_rid INT;
DECLARE stored_wid INT;
DECLARE stored_rid INT;

-- referer
SET @my_rid = (SELECT input_repo(in_checksum));

-- data
SET @my_data = (SELECT input_win_data(in_data,in_ora));

-- evento
IF (in_evento IS NOT NULL) THEN
	SET @my_id_evento = (SELECT input_win_evento(in_evento));
ELSE
	SET @my_id_evento = NULL;
END IF;

-- messaggio
IF (in_messaggio IS NOT NULL) THEN
	SET @my_id_messaggio = (SELECT input_win_messaggio(in_messaggio));
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
IN in_checksum CHAR(32)
)
BEGIN

DECLARE my_data datetime;
DECLARE my_id_tessera INT;
DECLARE my_id_evento INT;
DECLARE my_id_varco INT;
DECLARE my_direzione VARCHAR(45);
DECLARE my_id_ospite INT;

DECLARE my_rid INT;
DECLARE stored_sid INT;
DECLARE stored_rid INT;

-- referer
SET @my_rid = (SELECT input_repo(in_checksum));

-- data
IF (in_data IS NOT NULL) THEN
	SET @my_data = (SELECT input_ser_data(in_data,in_ora));
ELSE
	SET @my_data = 0;
END IF;

-- tessera
IF (in_seriale IS NOT NULL) THEN
	SET @my_id_tessera = (SELECT input_ser_tessera(in_seriale,NULL,NULL));
ELSE
	SET @my_id_tessera = '1';
END IF;

-- evento
IF (in_evento IS NOT NULL) THEN
	SET @my_id_evento = (SELECT input_ser_evento(in_evento));
ELSE
	SET @my_id_evento = '1';
END IF;

-- varco
IF (in_varco IS NOT NULL) THEN
	SET @my_id_varco = (SELECT input_ser_varco(in_varco,in_centrale,NULL,NULL,NULL,NULL));
ELSE
	IF (in_centrale IS NOT NULL) THEN
		SET @my_id_varco = (SELECT input_ser_varco(NULL,in_centrale,NULL,NULL,NULL,NULL));
	ELSE
		SET @my_id_varco = '1';
	END IF;
END IF;

-- ospite
IF (in_ospite IS NOT NULL) THEN
	SET @my_id_ospite = (SELECT input_ser_ospite(in_ospite));
ELSE
	SET @my_id_ospite = '1';
END IF;

-- direzione
IF (in_direzione IS NOT NULL) THEN
	SET @my_direzione = in_direzione;
ELSE
	SET @my_direzione = '';
END IF;

-- report
IF NOT (SELECT test_ser_report(@my_data,@my_id_tessera,@my_id_evento,@my_id_varco,@my_direzione,@my_id_ospite)) THEN

	INSERT INTO SER_REPORT(Data,id_tessera,id_evento,id_varco,direzione,id_ospite,Rid,contatore)
	VALUES(@my_data,@my_id_tessera,@my_id_evento,@my_id_varco,@my_direzione,@my_id_ospite,@my_rid,'1');

ELSE

	SET @stored_sid = (SELECT get_ser_report(@my_data,@my_id_tessera,@my_id_evento,@my_id_varco,@my_direzione,@my_id_ospite));
	SET @stored_rid = (SELECT get_ser_referer(@stored_sid));

	UPDATE SER_REPORT SET contatore=contatore+1 WHERE Sid=@stored_sid AND @my_rid=@stored_rid;

END IF;

END;
$$


CREATE PROCEDURE `input_adc`(
IN in_cognome VARCHAR(45),
IN in_nome VARCHAR(45),
IN in_societa VARCHAR(45),
IN in_tipo_doc VARCHAR(45),
IN in_num_doc VARCHAR(45),
IN in_scad_doc VARCHAR(45),
IN in_decorrenza VARCHAR(45),
IN in_scadenza VARCHAR(45),
IN in_badge VARCHAR(45),
IN in_gruppo VARCHAR(45),
IN in_note VARCHAR(45),
IN in_struttura VARCHAR(45),
IN in_profilo VARCHAR(45),
IN in_locali VARCHAR(200)
)
BEGIN
DECLARE my_scad_doc DATE;
DECLARE my_decorrenza DATE;
DECLARE my_scadenza DATE;
DECLARE my_data_di_nascita DATE;
END;
$$


DELIMITER ;