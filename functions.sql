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

DROP FUNCTION IF EXISTS `input_repo`;
DROP FUNCTION IF EXISTS `input_tessera`;
DROP FUNCTION IF EXISTS `input_varco`;

DELIMITER $$

-- utils generic

CREATE FUNCTION `test_repo`(in_tipo VARCHAR(45),in_filename VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM REPOSITORY WHERE tipo=in_tipo AND filename=in_filename));
END;
$$

CREATE FUNCTION `get_repo`(in_tipo VARCHAR(45),in_filename VARCHAR(45))
RETURNS INT(11)
BEGIN
RETURN (SELECT Rid FROM REPOSITORY WHERE tipo=in_tipo AND filename=in_filename);
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
in_centrale VARCHAR(45),
in_id_tessera INT,
in_id_evento INT,
in_id_varco INT,
in_direzione VARCHAR(45),
in_id_ospite INT
)
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM SER_REPORT WHERE 
Data=in_data AND Centrale=in_centrale AND id_tessera=in_id_tessera AND id_evento=in_id_evento AND id_varco=in_id_varco AND direzione=in_direzione AND id_ospite=in_id_ospite));
END;
$$

CREATE FUNCTION `get_ser_report`(
in_data datetime,
in_centrale VARCHAR(45),
in_id_tessera INT,
in_id_evento INT,
in_id_varco INT,
in_direzione VARCHAR(45),
in_id_ospite INT
)
RETURNS INT(11)
BEGIN
RETURN (SELECT Sid FROM SER_REPORT WHERE 
Data=in_data AND Centrale=in_centrale AND id_tessera=in_id_tessera AND id_evento=in_id_evento AND id_varco=in_id_varco AND direzione=in_direzione AND id_ospite=in_id_ospite);
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

-- insert 

CREATE FUNCTION `input_repo`(in_tipo VARCHAR(45),in_filename VARCHAR(45))
RETURNS INT(11)
BEGIN
DECLARE id_output INT(11);
IF NOT (SELECT test_repo(in_tipo,in_filename)) THEN
	INSERT INTO REPOSITORY(data,tipo,filename) VALUES((SELECT NOW()),in_tipo,in_filename);
	SET @id_output = LAST_INSERT_ID();
ELSE
	SET @id_output = (SELECT get_repo(in_tipo,in_filename));
END IF;
RETURN @id_output;
END;
$$

CREATE FUNCTION `input_tessera`(in_seriale VARCHAR(45),in_numero INT(11),in_tipo VARCHAR(45))
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

CREATE FUNCTION `input_varco`(
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


DELIMITER ;