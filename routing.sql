DROP FUNCTION IF EXISTS `id2tessera`;
DROP FUNCTION IF EXISTS `id2ospite`;
DROP FUNCTION IF EXISTS `id2evento`;
DROP FUNCTION IF EXISTS `id2varco`;
DROP VIEW IF EXISTS `ser_reportstuff`;

DROP FUNCTION IF EXISTS `routing_core`;
DROP PROCEDURE IF EXISTS `ROUTING`;

DELIMITER $$

CREATE FUNCTION `id2tessera`(in_id_tessera INT) RETURNS VARCHAR(90)
BEGIN
RETURN (SELECT
CONCAT(CASE tipo WHEN 1 THEN (SELECT 'ESTERNI') WHEN 2 THEN (SELECT 'POSTE') ELSE (SELECT 'SCONOSCIUTO') END,' ',numero)
FROM SER_TESSERE WHERE id_tessera=in_id_tessera);
END;
$$

CREATE FUNCTION `id2ospite`(in_id_ospite INT) RETURNS VARCHAR(45)
BEGIN
RETURN (SELECT HTML_UnEncode(nome) AS nome FROM SER_OSPITI WHERE id_ospite=in_id_ospite);
END;
$$

CREATE FUNCTION `id2evento`(in_id_evento INT) RETURNS VARCHAR(45)
BEGIN
RETURN (SELECT evento FROM SER_EVENTI WHERE id_evento=in_id_evento);
END;
$$

CREATE FUNCTION `id2varco`(in_id_varco INT) RETURNS VARCHAR(45)
BEGIN
RETURN (SELECT label FROM SER_VARCHI WHERE id_varco=in_id_varco);
END;
$$

CREATE VIEW `ser_reportstuff` AS
SELECT REPOSITORY.data AS datafile,SER_REPORT.Data AS data,Sid,id_tessera,id2ospite(id_ospite) AS ospite,id_evento,id_varco,direzione
FROM SER_REPORT LEFT JOIN REPOSITORY USING(Rid) WHERE id_tessera <> 1;
$$

CREATE FUNCTION `routing_core`(in_data DATETIME,in_id_tessera INT,in_ospite VARCHAR(45)) RETURNS INT
BEGIN
RETURN (SELECT Sid FROM ser_reportstuff WHERE 
data > in_data AND
(id_tessera = in_id_tessera OR SUBSTRING(ospite,1,13) = SUBSTRING(in_ospite ,1,13)) 
LIMIT 1);
END;
$$

CREATE PROCEDURE `ROUTING`(IN in_start DATETIME, IN in_ospite VARCHAR(45))
BEGIN

DECLARE main_sid INT;
DECLARE main_data DATETIME;
DECLARE main_id_tessera INT;
DECLARE main_ospite VARCHAR(45);

DECLARE main_id_evento INT;
DECLARE main_id_varco INT;
DECLARE main_direzione VARCHAR(45);

DECLARE sub_sid INT;

DECLARE sub_data datetime;
DECLARE sub_id_evento INT;
DECLARE sub_id_varco INT;
DECLARE sub_direzione VARCHAR(45);

DECLARE done INT DEFAULT FALSE;
DECLARE query CURSOR FOR SELECT data,Sid,id_tessera,ospite,id_evento,id_varco,direzione FROM ser_reportstuff WHERE data BETWEEN in_start AND in_start + INTERVAL 1 DAY AND ospite LIKE CONCAT('%',in_ospite,'%');
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

CREATE TEMPORARY TABLE passaggi(
sid int,
data datetime,
durata int,
ospite varchar(150),
provenienza varchar(150),
destinazione varchar(150));

OPEN query;
myloop: LOOP

	FETCH query INTO main_data,main_sid,main_id_tessera,main_ospite,main_id_evento,main_id_varco,main_direzione;
	SET sub_sid = (SELECT routing_core(main_data,main_id_tessera,main_ospite));
	
	SELECT data,id_evento,id_varco,direzione INTO sub_data,sub_id_evento,sub_id_varco,sub_direzione FROM ser_reportstuff WHERE Sid = sub_sid;
	
	INSERT INTO passaggi(sid,data,durata,ospite,provenienza,destinazione) VALUES(
	main_sid,
	main_data,
	TIMESTAMPDIFF(MINUTE,main_data,sub_data),
	CONCAT_WS(' ',id2tessera(main_id_tessera),main_ospite),
	CONCAT_WS(' ',IF(id2evento(main_id_evento)='Transito effettuato','OK','ERR'),id2varco(main_id_varco),main_direzione),
	CONCAT_WS(' ',IF(id2evento(sub_id_evento)='Transito effettuato','OK','ERR'),id2varco(sub_id_varco),sub_direzione)
	);
	
	IF done THEN
		LEAVE myloop;
	END IF;

END LOOP myloop;
CLOSE query;

SELECT data,durata,ospite,provenienza,destinazione FROM passaggi ORDER BY Sid;
DROP TEMPORARY TABLE passaggi;

END;
$$


/*
CREATE PROCEDURE `routing`(IN in_start datetime, IN in_ospite VARCHAR(45))
BEGIN

DECLARE main_sid INT;
DECLARE main_data datetime;
DECLARE main_datafile datetime;
DECLARE main_id_tessera INT;
DECLARE main_ospite VARCHAR(45);
DECLARE main_id_evento INT;
DECLARE main_id_varco INT;
DECLARE main_direzione VARCHAR(45);

DECLARE sub_data datetime;
DECLARE sub_id_evento INT;
DECLARE sub_id_varco INT;
DECLARE sub_direzione VARCHAR(45);

DECLARE done INT DEFAULT FALSE;
DECLARE query CURSOR FOR SELECT * FROM ser_reportstuff WHERE data BETWEEN in_start AND in_start + INTERVAL 1 DAY AND ospite LIKE CONCAT('%',in_ospite,'%');
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

CREATE TEMPORARY TABLE PASSAGGI(
sid int,
data datetime,
durata int,
ospite varchar(150),
provenienza varchar(150),
destinazione varchar(150));

OPEN query;
myloop: LOOP

	FETCH query INTO main_datafile,main_data,main_sid,main_id_tessera,main_ospite,main_id_evento,main_id_varco,main_direzione;

	SELECT data,id_evento,id_varco,direzione INTO sub_data,sub_id_evento,sub_id_varco,sub_direzione
	FROM ser_reportstuff WHERE
	--datafile >= main_datafile AND
	data >= main_data AND
	--Sid > main_sid AND
	id_tessera = main_id_tessera AND
	SUBSTRING(ospite,1,13) = SUBSTRING(main_ospite ,1,13) LIMIT 1;

	INSERT INTO PASSAGGI(sid,data,durata,ospite,provenienza,destinazione) VALUES(
	main_sid,
	main_data,
	TIMESTAMPDIFF(MINUTE,main_data,sub_data),
	CONCAT_WS(' ',id2tessera(main_id_tessera),main_ospite),
	CONCAT_WS(' ',IF(id2evento(main_id_evento)='Transito effettuato','OK','ERR'),id2varco(main_id_varco),main_direzione),
	CONCAT_WS(' ',IF(id2evento(sub_id_evento)='Transito effettuato','OK','ERR'),id2varco(sub_id_varco),sub_direzione)
	);

	IF done THEN
		LEAVE myloop;
	END IF;

END LOOP myloop;
CLOSE query;

SELECT data,durata,ospite,provenienza,destinazione FROM PASSAGGI ORDER BY Sid;
DROP TEMPORARY TABLE PASSAGGI;

END;
$$
*/


DELIMITER ;