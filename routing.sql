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

CREATE PROCEDURE `old_procedure_routing`(IN in_start datetime)
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

-- DECLARE query CURSOR FOR SELECT Data,id_tessera,id_ospite,id_evento,id_varco,direzione FROM SER_REPORT WHERE Data>=in_start AND id_evento IN (4,7,11,20,24,25);

DECLARE query CURSOR FOR 
SELECT Sid,SER_REPORT.Data,REPOSITORY.data,id_tessera,HTML_UnEncode(SER_OSPITI.nome),id_evento,id_varco,direzione
FROM SER_REPORT JOIN REPOSITORY USING(Rid) JOIN SER_OSPITI USING(id_ospite)
WHERE SER_REPORT.Data>=in_start AND id_tessera <> 1;

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

	FETCH query INTO main_sid,main_data,main_datafile,main_id_tessera,main_ospite,main_id_evento,main_id_varco,main_direzione;
	
	SELECT SER_REPORT.Data,id_evento,id_varco,direzione INTO sub_data,sub_id_evento,sub_id_varco,sub_direzione 
	FROM SER_REPORT JOIN REPOSITORY USING(Rid) JOIN SER_OSPITI USING(id_ospite) WHERE 
	REPOSITORY.data>=main_datafile AND 
	SER_REPORT.Data>=main_data AND 
	Sid>main_sid AND 
	id_tessera=main_id_tessera AND
	SUBSTRING(HTML_UnEncode(SER_OSPITI.nome),1,13)=SUBSTRING(main_ospite,1,13) LIMIT 1;
	
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

	IF done THEN
	LEAVE myloop;
	END IF;

END LOOP myloop;
CLOSE query;

SELECT data,durata,ospite,provenienza,destinazione FROM PASSAGGI ORDER BY Sid;
DROP TEMPORARY TABLE PASSAGGI;

END;
$$


CREATE VIEW `ser_reportstuff` AS
SELECT REPOSITORY.data AS datafile,SER_REPORT.Data AS data,Sid,id_tessera,(SELECT id2ospite(id_ospite)) AS ospite,id_evento,id_varco,direzione
FROM SER_REPORT LEFT JOIN REPOSITORY USING(Rid) WHERE id_tessera <> 1;
$$

CREATE PROCEDURE `routing`()
BEGIN

DECLARE my_datafile DATETIME;
DECLARE my_data DATETIME;
DECLARE my_sid INT;
DECLARE my_id_tessera INT;
DECLARE my_ospite VARCHAR(45);
DECLARE my_id_evento INT;
DECLARE my_id_varco INT;
DECLARE my_direzione VARCHAR(45);

DECLARE sub_data DATETIME;
DECLARE sub_id_evento INT;
DECLARE sub_id_varco INT;
DECLARE sub_direzione VARCHAR(45);

DECLARE done INT DEFAULT FALSE;
DECLARE cursor_query CURSOR FOR (SELECT datafile,data,Sid,id_tessera,ospite,id_evento,id_varco,direzione FROM ser_reportstuff);
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

SET @SUBQ = "SELECT 
		data,id_evento,id_varco,direzione INTO
		@sub_data,@sub_id_evento,@sub_id_varco,@sub_direzione
	FROM ser_reportstuff WHERE 
		datafile >= ? AND 
		data >= ? AND 
		Sid > ? AND 
		id_tessera = ? AND 
		ospite LIKE CONCAT('%', ? ,'%') LIMIT 1";
		
PREPARE subquery FROM @SUBQ;

OPEN cursor_query;

	read_loop: LOOP
		
		FETCH cursor_query INTO my_datafile,my_data,my_sid,my_id_tessera,my_ospite,my_id_evento,my_id_varco,my_direzione;
		
		IF done THEN
			LEAVE read_loop;
		END IF;
		
		EXECUTE subquery USING 
			my_datafile,
			my_data,
			my_sid,
			my_id_tessera,
			my_ospite,
			my_id_evento,
			my_id_varco,
			my_direzione;
		
		SELECT
			@my_data,
			TIMESTAMPDIFF(MINUTE,my_data,@sub_data),
			CONCAT_WS(' ',
			(SELECT id2tessera(my_id_tessera)),
			my_ospite),
			CONCAT_WS(' ',
			(SELECT id2evento(my_id_evento)),
			(SELECT id2varco(my_id_varco)),
			my_direzione),
			CONCAT_WS(' ',
			(SELECT id2evento(@sub_id_evento)),
			(SELECT id2varco(@sub_id_varco)),
			@sub_direzione);
			
	END LOOP read_loop;
	
CLOSE cursor_query;
DEALLOCATE PREPARE subquery;

END;
$$


DELIMITER ;