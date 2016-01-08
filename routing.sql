DROP FUNCTION IF EXISTS `id2tessera`;
DROP FUNCTION IF EXISTS `id2ospite`;
DROP FUNCTION IF EXISTS `id2evento`;
DROP FUNCTION IF EXISTS `id2varco`;
DROP PROCEDURE IF EXISTS `old_procedure_routing`;
DROP VIEW IF EXISTS `ser_reportstuff`;
DROP PROCEDURE IF EXISTS `routing`;

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

CREATE PROCEDURE `routing`(IN in_start datetime)
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
DECLARE query CURSOR FOR SELECT * FROM ser_reportstuff WHERE data>=in_start;
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

	SET @subsel = "SELECT data,id_evento,id_varco,direzione INTO sub_data,sub_id_evento,sub_id_varco,sub_direzione
				FROM ser_reportstuff WHERE
				datafile >= main_datafile AND
				data >= main_data AND
				Sid > main_sid AND
				id_tessera = main_id_tessera AND
				SUBSTRING(ospite,1,13) = SUBSTRING( main_ospite ,1,13) LIMIT 1;";

	PREPARE stmt FROM @subsel;
	EXECUTE stmt;
	
	INSERT INTO PASSAGGI(sid,data,durata,ospite,provenienza,destinazione) VALUES(
	main_sid,
	main_data,
	TIMESTAMPDIFF(MINUTE,main_data,sub_data),
	CONCAT_WS(' ',
	(SELECT id2tessera(main_id_tessera)),
	main_ospite),
	CONCAT_WS(' ',
	(SELECT id2evento(main_id_evento)),
	(SELECT id2varco(main_id_varco)),
	main_direzione),
	CONCAT_WS(' ',
	(SELECT id2evento(sub_id_evento)),
	(SELECT id2varco(sub_id_varco)),
	sub_direzione)
	);
	
	DEALLOCATE PREPARE stmt;

	IF done THEN
		LEAVE myloop;
	END IF;

END LOOP myloop;
CLOSE query;

SELECT data,durata,ospite,provenienza,destinazione FROM PASSAGGI ORDER BY Sid;
DROP TEMPORARY TABLE PASSAGGI;

END;
$$


DELIMITER ;