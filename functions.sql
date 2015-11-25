DROP FUNCTION IF EXISTS `test_repo`;
DROP FUNCTION IF EXISTS `get_repo`;

DROP FUNCTION IF EXISTS `test_win_evento`;
DROP FUNCTION IF EXISTS `get_win_evento`;
DROP FUNCTION IF EXISTS `test_win_messaggio`;
DROP FUNCTION IF EXISTS `get_win_messaggio`;
DROP FUNCTION IF EXISTS `test_win_report`;
DROP FUNCTION IF EXISTS `get_win_report`;
DROP FUNCTION IF EXISTS `test_win_duplicati`;
DROP FUNCTION IF EXISTS `get_win_referer`;

DROP FUNCTION IF EXISTS `test_ser_tessera`;
DROP FUNCTION IF EXISTS `get_ser_tessera`;
DROP FUNCTION IF EXISTS `test_ser_evento`;
DROP FUNCTION IF EXISTS `get_ser_evento`;
DROP FUNCTION IF EXISTS `test_ser_varco`;
DROP FUNCTION IF EXISTS `get_ser_varco`;
DROP FUNCTION IF EXISTS `test_ser_ospite`;
DROP FUNCTION IF EXISTS `get_ser_ospite`;
DROP FUNCTION IF EXISTS `test_ser_report`;
DROP FUNCTION IF EXISTS `get_ser_report`;
DROP FUNCTION IF EXISTS `test_ser_duplicati`;
DROP FUNCTION IF EXISTS `get_ser_referer`;

DROP FUNCTION IF EXISTS `test_adc_ospite`;
DROP FUNCTION IF EXISTS `get_adc_ospite`;
DROP FUNCTION IF EXISTS `test_adc_ospite_cf`;
DROP FUNCTION IF EXISTS `test_adc_ospite_nazionalita`;
DROP FUNCTION IF EXISTS `test_adc_documento`;
DROP FUNCTION IF EXISTS `get_adc_documento`;
DROP FUNCTION IF EXISTS `test_adc_struttura`;
DROP FUNCTION IF EXISTS `get_adc_struttura`;
DROP FUNCTION IF EXISTS `test_adc_profilo`;
DROP FUNCTION IF EXISTS `get_adc_profilo`;
DROP FUNCTION IF EXISTS `test_adc_report`;

DROP FUNCTION IF EXISTS `input_repo`;

DROP FUNCTION IF EXISTS `pre_win_data`;
DROP FUNCTION IF EXISTS `pre_ser_data`;
DROP FUNCTION IF EXISTS `pre_adc_data`;

DROP FUNCTION IF EXISTS `input_ser_tessera`;
DROP FUNCTION IF EXISTS `input_ser_varco`;
DROP FUNCTION IF EXISTS `input_ser_evento`;
DROP FUNCTION IF EXISTS `input_ser_ospite`;

DROP FUNCTION IF EXISTS `input_win_evento`;
DROP FUNCTION IF EXISTS `input_win_messaggio`;

DROP FUNCTION IF EXISTS `input_adc_ospite`;
DROP FUNCTION IF EXISTS `input_adc_documento`;
DROP FUNCTION IF EXISTS `input_adc_struttura`;
DROP FUNCTION IF EXISTS `input_adc_profilo`;

-- schema function input_foo_bar
-- begin
-- if not test_foo_bar
--	insert FOO_BAR(bar)
--	set @id_output = last insert id
-- else
--	set @id_output = select get_foo_bar(bar)
-- end if
-- return @id_output
-- end

-- uso interfacce tabelle atomiche
-- SET my_id_bar = (SELECT input_foo_bar(bar));

-- INPUT
--	WINWATCH: win_data, win_evento, win_messaggio
--	SERCHIO: ser_data, ser_tessera, ser_evento, ser_varco, ser_ospite


DELIMITER $$

-- utils generic

CREATE FUNCTION `test_repo`(in_checksum CHAR(32))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM REPOSITORY WHERE checksum=in_checksum));
END;
$$

CREATE FUNCTION `get_repo`(in_checksum CHAR(32))
RETURNS INT(11)
BEGIN
RETURN (SELECT Rid FROM REPOSITORY WHERE checksum=in_checksum);
END;
$$

CREATE FUNCTION `pre_win_data`(in_data VARCHAR(45),in_ora VARCHAR(45))
RETURNS DATETIME
BEGIN
RETURN (SELECT STR_TO_DATE(CONCAT(in_data,' ',COALESCE(in_ora,'00:00')),'%d-%m-%y %H:%i'));
END;
$$

CREATE FUNCTION `pre_ser_data`(in_data VARCHAR(45),in_ora VARCHAR(45))
RETURNS DATETIME
BEGIN
RETURN (SELECT STR_TO_DATE(CONCAT(in_data,' ',COALESCE(in_ora,'00:00')),'%d/%m/%Y %H:%i'));
END;
$$

CREATE FUNCTION `pre_adc_data`(in_data VARCHAR(45))
RETURNS DATE
BEGIN
RETURN (SELECT STR_TO_DATE(in_data,'%d/%m/%Y'));
END;
$$

-- utils winwatch

CREATE FUNCTION `test_win_evento`(in_evento VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM WIN_EVENTI WHERE evento=in_evento));
END;
$$

CREATE FUNCTION `get_win_evento`(in_evento VARCHAR(45))
RETURNS INT(11)
BEGIN
RETURN (SELECT id_evento FROM WIN_EVENTI WHERE evento=in_evento);
END;
$$

CREATE FUNCTION `test_win_messaggio`(in_messaggio VARCHAR(100))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM WIN_MESSAGGI WHERE messaggio=in_messaggio));
END;
$$

CREATE FUNCTION `get_win_messaggio`(in_messaggio VARCHAR(100))
RETURNS INT(11)
BEGIN
RETURN (SELECT id_messaggio FROM WIN_MESSAGGI WHERE messaggio=in_messaggio);
END;
$$

CREATE FUNCTION `test_win_report`(
in_centrale VARCHAR(45),
in_data datetime,
in_id_evento INT,
in_id_messaggio INT
)
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM WIN_REPORT WHERE
Centrale=in_centrale AND Data=in_data AND id_evento=in_id_evento AND id_messaggio=in_id_messaggio));
END;
$$

CREATE FUNCTION `get_win_report`(
in_centrale VARCHAR(45),
in_data datetime,
in_id_evento INT,
in_id_messaggio INT
)
RETURNS INT(11)
BEGIN
RETURN (SELECT Wid FROM WIN_REPORT WHERE
Centrale=in_centrale AND Data=in_data AND id_evento=in_id_evento AND id_messaggio=in_id_messaggio);
END;
$$

CREATE FUNCTION `test_win_duplicati`(in_wid INT(11))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM WIN_REPORT WHERE Wid=in_wid AND contatore>1));
END;
$$

CREATE FUNCTION `get_win_referer`(in_wid INT(11))
RETURNS INT(11)
BEGIN
RETURN (SELECT Rid FROM WIN_REPORT WHERE Wid=in_wid);
END;
$$

-- utils serchio

CREATE FUNCTION `test_ser_tessera`(in_seriale VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM SER_TESSERE WHERE seriale=in_seriale));
END;
$$

CREATE FUNCTION `get_ser_tessera`(in_seriale VARCHAR(45))
RETURNS INT(11)
BEGIN
RETURN (SELECT id_tessera FROM SER_TESSERE WHERE seriale=in_seriale);
END;
$$

CREATE FUNCTION `test_ser_evento`(in_evento VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM SER_EVENTI WHERE evento=in_evento));
END;
$$

CREATE FUNCTION `get_ser_evento`(in_evento VARCHAR(45))
RETURNS INT(11)
BEGIN
RETURN (SELECT id_evento FROM SER_EVENTI WHERE evento=in_evento);
END;
$$

CREATE FUNCTION `test_ser_varco`(in_centrale INT(11),in_varco VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM SER_VARCHI WHERE centrale=in_centrale AND varco=in_varco));
END;
$$

CREATE FUNCTION `get_ser_varco`(in_centrale INT(11),in_varco VARCHAR(45))
RETURNS INT(11)
BEGIN
RETURN (SELECT id_varco FROM SER_VARCHI WHERE centrale=in_centrale AND varco=in_varco);
END;
$$

CREATE FUNCTION `test_ser_ospite`(in_ospite VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM SER_OSPITI WHERE nome=in_ospite));
END;
$$

CREATE FUNCTION `get_ser_ospite`(in_ospite VARCHAR(45))
RETURNS INT(11)
BEGIN
RETURN (SELECT id_ospite FROM SER_OSPITI WHERE nome=in_ospite);
END;
$$

CREATE FUNCTION `test_ser_report`(
in_data datetime,
in_id_tessera INT,
in_id_evento INT,
in_id_varco INT,
in_direzione VARCHAR(45),
in_id_ospite INT
)
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM SER_REPORT WHERE
Data=COALESCE(in_data,0) AND
id_tessera=COALESCE(in_id_tessera,1) AND
id_evento=COALESCE(in_id_evento,1) AND
id_varco=COALESCE(in_id_varco,1) AND
direzione=in_direzione AND
id_ospite=COALESCE(in_id_ospite,1)));
END;
$$

CREATE FUNCTION `get_ser_report`(
in_data datetime,
in_id_tessera INT,
in_id_evento INT,
in_id_varco INT,
in_direzione VARCHAR(45),
in_id_ospite INT
)
RETURNS INT(11)
BEGIN
RETURN (SELECT Sid FROM SER_REPORT WHERE
Data=COALESCE(in_data,0) AND
id_tessera=COALESCE(in_id_tessera,1) AND
id_evento=COALESCE(in_id_evento,1) AND
id_varco=COALESCE(in_id_varco,1) AND
direzione=in_direzione AND
id_ospite=COALESCE(in_id_ospite,1));
END;
$$

CREATE FUNCTION `test_ser_duplicati`(in_sid INT(11))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM SER_REPORT WHERE Sid=in_sid AND contatore>1));
END;
$$

CREATE FUNCTION `get_ser_referer`(in_sid INT(11))
RETURNS INT(11)
BEGIN
RETURN (SELECT Rid FROM SER_REPORT WHERE Sid=in_sid);
END;
$$

-- utils adc

CREATE FUNCTION `test_adc_ospite`(in_nome VARCHAR(45),in_data_di_nascita date)
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM ADC_OSPITI WHERE nome=in_nome AND data_di_nascita=in_data_di_nascita));
END;
$$

CREATE FUNCTION `get_adc_ospite`(in_nome VARCHAR(45),in_data_di_nascita date)
RETURNS INT(11)
BEGIN
RETURN (SELECT id_ospite FROM ADC_OSPITI WHERE nome=in_nome AND data_di_nascita=in_data_di_nascita);
END;
$$

CREATE FUNCTION `test_adc_ospite_cf`(in_nome VARCHAR(45),in_data_di_nascita date)
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM ADC_OSPITI WHERE nome=in_nome AND data_di_nascita=in_data_di_nascita AND cf<>'NULL'));
END;
$$

CREATE FUNCTION `test_adc_ospite_nazionalita`(in_nome VARCHAR(45),in_data_di_nascita date)
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM ADC_OSPITI WHERE nome=in_nome AND data_di_nascita=in_data_di_nascita AND nazionalita<>'NULL'));
END;
$$

CREATE FUNCTION `test_adc_documento`(in_tipo VARCHAR(45),in_numero VARCHAR(45),in_scadenza date)
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM ADC_DOCUMENTI WHERE tipo=in_tipo AND numero=in_numero AND scadenza=in_scadenza));
END;
$$

CREATE FUNCTION `get_adc_documento`(in_tipo VARCHAR(45),in_numero VARCHAR(45),in_scadenza date)
RETURNS INT(11)
BEGIN
RETURN (SELECT id_documento FROM ADC_DOCUMENTI WHERE tipo=in_tipo AND numero=in_numero AND scadenza=in_scadenza);
END;
$$

CREATE FUNCTION `test_adc_struttura`(in_label VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM ADC_STRUTTURE WHERE label=in_label));
END;
$$

CREATE FUNCTION `get_adc_struttura`(in_label VARCHAR(45))
RETURNS INT(11)
BEGIN
RETURN (SELECT id_struttura FROM ADC_STRUTTURE WHERE label=in_label);
END;
$$

CREATE FUNCTION `test_adc_profilo`(in_label VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM ADC_PROFILI WHERE label=in_label));
END;
$$

CREATE FUNCTION `get_adc_profilo`(in_label VARCHAR(45))
RETURNS INT(11)
BEGIN
RETURN (SELECT id_profilo FROM ADC_PROFILI WHERE label=in_label);
END;
$$

CREATE FUNCTION `test_adc_report`(in_data_report DATE)
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM ADC_REPORT WHERE data_report=in_data_report));
END;
$$


-- insert

CREATE FUNCTION `input_repo`(in_data DATETIME,in_checksum CHAR(32))
RETURNS INT(11)
BEGIN
DECLARE id_output INT(11);
IF NOT (SELECT test_repo(in_checksum)) THEN
	INSERT INTO REPOSITORY(data,checksum) VALUES(in_data,in_checksum);
	SET @id_output = LAST_INSERT_ID();
ELSE
	SET @id_output = (SELECT get_repo(in_checksum));
END IF;
RETURN @id_output;
END;
$$

CREATE FUNCTION `input_ser_tessera`(in_seriale VARCHAR(45),in_numero INT(11),in_tipo VARCHAR(45))
RETURNS INT(11)
BEGIN
DECLARE my_tipo INT(1);
DECLARE id_output INT(11);

IF (in_tipo IS NOT NULL) THEN
	CASE
	WHEN (STRCMP(in_tipo,'ESTERNI')=0) THEN
		SET @my_tipo='1';
	WHEN (STRCMP(in_tipo,'POSTE')=0) THEN
		SET @my_tipo='2';
	ELSE
		SET @my_tipo='0';
	END CASE;
ELSE
	SET @my_tipo=NULL;
END IF;

IF NOT (SELECT test_ser_tessera(in_seriale)) THEN
	INSERT INTO SER_TESSERE(tipo,numero,seriale) VALUES(@my_tipo,in_numero,in_seriale);
	SET @id_output = LAST_INSERT_ID();
ELSE
	SET @id_output = (SELECT get_ser_tessera(in_seriale));
END IF;

RETURN @id_output;
END;
$$

CREATE FUNCTION `input_ser_varco`(
	in_varco VARCHAR(45),
	in_centrale VARCHAR(45),
	in_label VARCHAR(45),
	in_antipanico INT(1),
	in_perimetrale INT(1),
	in_tastierino INT(1)
)
RETURNS INT(11)
BEGIN
DECLARE my_centrale INT(1);
DECLARE id_output INT(11);

IF (in_centrale IS NOT NULL) THEN
	CASE
	WHEN (STRCMP(in_centrale,'PULSAR 1')=0) THEN
		SET @my_centrale='1';
	WHEN (STRCMP(in_centrale,'PULSAR 2')=0) THEN
		SET @my_centrale='2';
	WHEN (STRCMP(in_centrale,'1')=0) THEN
		SET @my_centrale='1';
	WHEN (STRCMP(in_centrale,'2')=0) THEN
		SET @my_centrale='2';
	ELSE
		SET @my_centrale='0';
	END CASE;
ELSE
	SET @my_centrale='0';
END IF;

IF NOT (SELECT test_ser_varco(@my_centrale,in_varco)) THEN
	INSERT INTO SER_VARCHI(centrale,varco,label,antipanico,perimetrale,tastierino)
	VALUES(@my_centrale,in_varco,in_label,in_antipanico,in_perimetrale,in_tastierino);
	SET @id_output = LAST_INSERT_ID();
ELSE
	SET @id_output = (SELECT get_ser_varco(@my_centrale,in_varco));
END IF;

RETURN @id_output;
END;
$$

CREATE FUNCTION `input_ser_evento`(in_evento VARCHAR(45))
RETURNS INT(11)
BEGIN
DECLARE id_output INT(11);
IF NOT (SELECT test_ser_evento(in_evento)) THEN
	INSERT INTO SER_EVENTI(evento) VALUES(in_evento);
	SET @id_output = LAST_INSERT_ID();
ELSE
	SET @id_output = (SELECT get_ser_evento(in_evento));
END IF;
RETURN @id_output;
END;
$$

CREATE FUNCTION `input_ser_ospite`(in_ospite VARCHAR(45))
RETURNS INT(11)
BEGIN
DECLARE id_output INT(11);
IF NOT (SELECT test_ser_ospite(in_ospite)) THEN
	INSERT INTO SER_OSPITI(nome) VALUES(in_ospite);
	SET @id_output = LAST_INSERT_ID();
ELSE
	SET @id_output = (SELECT get_ser_ospite(in_ospite));
END IF;
RETURN @id_output;
END;
$$

CREATE FUNCTION `input_win_evento`(in_evento VARCHAR(45))
RETURNS INT(11)
BEGIN
DECLARE id_output INT(11);
IF NOT (SELECT test_win_evento(in_evento)) THEN
	INSERT INTO WIN_EVENTI(evento) VALUES(in_evento);
	SET @id_output = LAST_INSERT_ID();
ELSE
	SET @id_output = (SELECT get_win_evento(in_evento));
END IF;

RETURN @id_output;
END;
$$

CREATE FUNCTION `input_win_messaggio`(in_messaggio VARCHAR(100))
RETURNS INT(11)
BEGIN
DECLARE id_output INT(11);
IF NOT (SELECT test_win_messaggio(in_messaggio)) THEN
	INSERT INTO WIN_MESSAGGI(messaggio) VALUES(in_messaggio);
	SET @id_output = LAST_INSERT_ID();
ELSE
	SET @id_output = (SELECT get_win_messaggio(in_messaggio));
END IF;
RETURN @id_output;
END;
$$

CREATE FUNCTION `input_adc_ospite`(
in_nome VARCHAR(45),
in_cf VARCHAR(45),
in_data_di_nascita date,
in_nazionalita VARCHAR(45))
RETURNS INT(11)
BEGIN
DECLARE id_output INT(11);
IF NOT (SELECT test_adc_ospite(in_nome,in_data_di_nascita)) THEN
	-- new
	INSERT INTO ADC_OSPITI(nome,cf,data_di_nascita,nazionalita) VALUES
	(in_nome,in_cf,in_data_di_nascita,in_nazionalita);
	-- id
	SET @id_output = LAST_INSERT_ID();
ELSE
	-- cf
	IF (in_cf IS NOT NULL) THEN
		UPDATE ADC_OSPITI SET cf=in_cf WHERE nome=in_nome AND data_di_nascita=in_data_di_nascita;
	END IF;
	-- nazionalita
	IF (in_nazionalita IS NOT NULL) THEN
		UPDATE ADC_OSPITI SET nazionalita=in_nazionalita WHERE nome=in_nome AND data_di_nascita=in_data_di_nascita;
	END IF;
	-- id
	SET @id_output = (SELECT get_adc_ospite(in_nome,in_data_di_nascita));
END IF;
RETURN @id_output;
END;
$$

CREATE FUNCTION `input_adc_documento`(in_tipo VARCHAR(45),in_numero VARCHAR(45),in_scadenza date)
RETURNS INT(11)
BEGIN
DECLARE id_output INT(11);
IF NOT (SELECT test_adc_documento(in_tipo,in_numero,in_scadenza)) THEN
	INSERT INTO ADC_DOCUMENTI(tipo,numero,scadenza) VALUES (in_tipo,in_numero,in_scadenza);
	SET @id_output = LAST_INSERT_ID();
ELSE
	IF (in_scadenza IS NOT NULL) THEN
		UPDATE ADC_DOCUMENTI SET scadenza=in_scadenza WHERE tipo=in_tipo AND numero=in_numero;
	END IF;
	SET @id_output = (SELECT get_adc_documento(in_tipo,in_numero,in_scadenza));
END IF;
RETURN @id_output;
END;
$$

CREATE FUNCTION `input_adc_struttura`(in_label VARCHAR(45))
RETURNS INT(11)
BEGIN
DECLARE id_output INT(11);
IF NOT (SELECT test_adc_struttura(in_label)) THEN
	INSERT INTO ADC_STRUTTURE(label) VALUES (in_label);
	SET @id_output = LAST_INSERT_ID();
ELSE
	SET @id_output = (SELECT get_adc_struttura(in_label));
END IF;
RETURN @id_output;
END;
$$

CREATE FUNCTION `input_adc_profilo`(in_label VARCHAR(45))
RETURNS INT(11)
BEGIN
DECLARE id_output INT(11);
IF NOT (SELECT test_adc_profilo(in_label)) THEN
	INSERT INTO ADC_PROFILI(label) VALUES (in_label);
	SET @id_output = LAST_INSERT_ID();
ELSE
	SET @id_output = (SELECT get_adc_profilo(in_label));
END IF;
RETURN @id_output;
END;
$$

DELIMITER ;