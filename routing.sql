DROP FUNCTION IF EXISTS `id2tessera`;
DROP FUNCTION IF EXISTS `id2ospite`;
DROP FUNCTION IF EXISTS `id2evento`;
DROP FUNCTION IF EXISTS `id2varco`;
DROP PROCEDURE IF EXISTS `routing`;

DELIMITER $$

-- PREPARE nextone FROM 'SELECT * FROM SER_REPORT WHERE Data>=? AND id_tessera=? AND id_ospite=? LIMIT 1';


CREATE FUNCTION `id2tessera`(in_id_tessera INT) RETURNS VARCHAR(90)
BEGIN
RETURN (SELECT 
CONCAT(CASE tipo WHEN 1 THEN (SELECT 'ESTERNI') WHEN 2 THEN (SELECT 'POSTE') ELSE (SELECT 'SCONOSCIUTO') END,' ',numero)
FROM SER_TESSERE WHERE id_tessera=in_id_tessera);
END;
$$

CREATE FUNCTION `id2ospite`(in_id_ospite INT) RETURNS VARCHAR(45)
BEGIN
RETURN (SELECT nome FROM SER_OSPITI WHERE id_ospite=in_id_ospite);
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

CREATE PROCEDURE `routing`(IN in_start datetime)
BEGIN

DECLARE main_data datetime;
DECLARE main_id_tessera INT;
DECLARE main_id_ospite INT;
DECLARE main_id_evento INT;
DECLARE main_id_varco INT;
DECLARE main_direzione VARCHAR(45);

DECLARE sub_data datetime;
DECLARE sub_id_evento INT;
DECLARE sub_id_varco INT;
DECLARE sub_direzione VARCHAR(45);

DECLARE done INT DEFAULT FALSE;
DECLARE query CURSOR FOR SELECT Data,id_tessera,id_ospite,id_evento,id_varco,direzione FROM SER_REPORT WHERE Data>=in_start AND id_evento IN (4,7,11,20,24,25);
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

CREATE TEMPORARY TABLE TRANSITI(
data datetime,
durata int,
ospite varchar(135),
provenienza varchar(135),
destinazione varchar(135));

OPEN query;
myloop: LOOP

	FETCH query INTO main_data,main_id_tessera,main_id_ospite,main_id_evento,main_id_varco,main_direzione;
	SELECT Data,id_evento,id_varco,direzione INTO sub_data,sub_id_evento,sub_id_varco,sub_direzione 
	FROM SER_REPORT  WHERE Data>main_data AND id_tessera=main_id_tessera LIMIT 1;
	
	INSERT INTO TRANSITI(data,durata,ospite,provenienza,destinazione)
	VALUES(
	main_data,
	TIMESTAMPDIFF(MINUTE,main_data,sub_data),
	CONCAT_WS(' ',
	(SELECT id2tessera(main_id_tessera)),
	(SELECT id2ospite(main_id_ospite))),
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

SELECT * FROM TRANSITI;
DROP TEMPORARY TABLE TRANSITI;

END;
$$



DELIMITER ;
