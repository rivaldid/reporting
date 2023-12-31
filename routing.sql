USE `reporting`;

DROP FUNCTION IF EXISTS `id2tessera`;
DROP FUNCTION IF EXISTS `id2ospite`;
DROP FUNCTION IF EXISTS `id2evento`;
DROP FUNCTION IF EXISTS `id2varco`;
DROP VIEW IF EXISTS `ser_reportstuff`;

DROP FUNCTION IF EXISTS `ser_routing`;
DROP PROCEDURE IF EXISTS `PASSAGGI`;

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
SELECT SER_REPORT.Data AS data,Sid,id_tessera,HTML_UnEncode(SER_OSPITI.nome) AS ospite,id_evento,id_varco,direzione
FROM SER_REPORT
JOIN SER_OSPITI USING(id_ospite)
WHERE id_tessera <> 1;
$$

CREATE FUNCTION `ser_routing`(in_sid INT,in_data DATETIME,in_ospite VARCHAR(45)) RETURNS INT
BEGIN
RETURN (SELECT Sid FROM ser_reportstuff WHERE
data >= in_data AND Sid > in_sid AND
SUBSTRING(ospite,1,13) = SUBSTRING(in_ospite,1,13) LIMIT 1);
END;
$$

CREATE PROCEDURE `PASSAGGI`(IN in_start DATETIME, IN in_ospite VARCHAR(45))
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
DECLARE query CURSOR FOR SELECT data,Sid,id_tessera,ospite,id_evento,id_varco,direzione FROM ser_reportstuff WHERE data BETWEEN in_start AND in_start + INTERVAL 1 DAY AND ospite LIKE CONCAT('%',in_ospite,'%') ORDER BY Sid ASC;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

DROP TEMPORARY TABLE IF EXISTS passaggi;
CREATE TEMPORARY TABLE passaggi(
sid int,
data datetime,
durata int,
ospite varchar(150),
provenienza varchar(150),
destinazione varchar(150));

OPEN query;

-- REPEAT
read_loop: LOOP

	FETCH query INTO main_data,main_sid,main_id_tessera,main_ospite,main_id_evento,main_id_varco,main_direzione;

	IF done THEN
		LEAVE read_loop;
	END IF;

	SET sub_sid = ser_routing(main_sid,main_data,main_ospite);

	SET sub_data = NULL;
	SET sub_id_evento = NULL;
	SET sub_id_varco = NULL;
	SET sub_direzione = NULL;

	IF (sub_sid IS NOT NULL) THEN
		SELECT data,id_evento,id_varco,direzione INTO sub_data,sub_id_evento,sub_id_varco,sub_direzione FROM ser_reportstuff WHERE Sid = sub_sid;
	END IF;

	INSERT INTO passaggi(sid,data,durata,ospite,provenienza,destinazione) VALUES(
	main_sid,
	main_data,
	TIMESTAMPDIFF(MINUTE,main_data,sub_data),
	CONCAT_WS(' ',id2tessera(main_id_tessera),main_ospite),
	CONCAT_WS(' ',IF(id2evento(main_id_evento)='Transito effettuato','OK','ERR'),id2varco(main_id_varco),main_direzione),
	CONCAT_WS(' ',IF(id2evento(sub_id_evento)='Transito effettuato','OK','ERR'),id2varco(sub_id_varco),sub_direzione)
	);

END LOOP read_loop;
-- UNTIL done END REPEAT;

CLOSE query;

SELECT data,durata,ospite,provenienza,destinazione FROM passaggi;

END;
$$

DELIMITER ;