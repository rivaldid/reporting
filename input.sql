DROP PROCEDURE IF EXISTS `input_winwatch`;
DROP PROCEDURE IF EXISTS `input_serchio`;
DROP PROCEDURE IF EXISTS `input_adc`;

-- schema procedure input winwatch-serchio
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
SET @my_rid = (SELECT input_repo((SELECT NOW()),in_checksum));

-- data
SET @my_data = (SELECT pre_win_data(in_data,in_ora));

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
SET @my_rid = (SELECT input_repo((SELECT NOW()),in_checksum));

-- data
IF (in_data IS NOT NULL) THEN
	SET @my_data = (SELECT pre_ser_data(in_data));
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
IN in_cf VARCHAR(45),
IN in_data_di_nascita VARCHAR(45),
IN in_nazionalita VARCHAR(45),
IN in_locali VARCHAR(200),
IN in_data_report VARCHAR(45),
IN in_checksum CHAR(32),
IN in_data_file DATETIME
)
BEGIN
DECLARE my_scad_doc DATE;
DECLARE my_decorrenza DATE;
DECLARE my_scadenza DATE;
DECLARE my_data_di_nascita DATE;
DECLARE my_data_report DATE;

DECLARE my_id_ospite INT;
DECLARE my_id_documento INT;
DECLARE my_id_struttura INT;
DECLARE my_id_profilo INT;

DECLARE my_rid INT;

-- scad_doc
IF (in_scad_doc IS NOT NULL) THEN
	SET @my_scad_doc = (SELECT pre_adc_data(in_scad_doc));
ELSE
	SET @my_scad_doc = 0;
END IF;

-- decorrenza
IF (in_decorrenza IS NOT NULL) THEN
	SET @my_decorrenza = (SELECT pre_adc_data(in_decorrenza));
ELSE
	SET @my_decorrenza = 0;
END IF;

-- scadenza
IF (in_scadenza IS NOT NULL) THEN
	SET @my_scadenza = (SELECT pre_adc_data(in_scadenza));
ELSE
	SET @my_scadenza = 0;
END IF;

-- data_di_nascita
IF (in_data_di_nascita IS NOT NULL) THEN
	SET @my_data_di_nascita = (SELECT pre_adc_data(in_data_di_nascita));
ELSE
	SET @my_data_di_nascita = 0;
END IF;

-- data_report
IF (in_data_report IS NOT NULL) THEN
	SET @my_data_report = (SELECT pre_adc_data(in_data_report));
ELSE
	SET @my_data_report = 0;
END IF;

-- referer
SET @my_rid = (SELECT input_repo(in_data_file,in_checksum));

-- ospite
IF (in_cognome IS NOT NULL) THEN
	SET @my_id_ospite = (SELECT input_adc_ospite(CONCAT(in_cognome,' ',in_nome),in_cf,@my_data_di_nascita,in_nazionalita));
ELSE
	SET @my_id_ospite='1';
END IF;

-- documento
IF (in_num_doc IS NOT NULL) THEN
	SET @my_id_documento = (SELECT input_adc_documento(in_tipo_doc,in_num_doc,@my_scad_doc));
ELSE
	SET @my_id_documento='1';
END IF;

-- struttura
IF (in_struttura IS NOT NULL) THEN
	SET @my_id_struttura = (SELECT input_adc_struttura(in_struttura));
ELSE
	SET @my_id_struttura='1';
END IF;

-- profilo
IF (in_profilo IS NOT NULL) THEN
	SET @my_id_profilo = (SELECT input_adc_profilo(in_profilo));
ELSE
	SET @my_id_profilo='1';
END IF;

INSERT INTO ADC_REPORT(id_ospite,societa,id_documento,decorrenza,scadenza,badge,gruppo,note,id_struttura,id_profilo,locali,data_report,Rid)
VALUES(@my_id_ospite,in_societa,@my_id_documento,@my_decorrenza,@my_scadenza,in_badge,in_gruppo,in_note,@my_id_struttura,@my_id_profilo,in_locali,@my_data_report,@my_rid);


END;
$$


DELIMITER ;