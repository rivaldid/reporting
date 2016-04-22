USE `reporting`;

DROP VIEW IF EXISTS `search_serchio_ospiti`;

CREATE VIEW `search_serchio_ospiti` AS
SELECT DATE(Data) DateOnly, Ospite FROM SERCHIO
GROUP BY DateOnly,Ospite ORDER BY DateOnly DESC;

/*
DELIMITER $$

CREATE PROCEDURE `minmax_serchio`(IN in_data DATETIME, IN in_ospite VARCHAR(45))
BEGIN

DECLARE temp_data DATETIME;
DECLARE temp_centrale VARCHAR(45);
DECLARE temp_messaggio VARCHAR(45);

DECLARE min_data DATETIME;
DECLARE min_centrale VARCHAR(45);
DECLARE min_messaggio VARCHAR(45);

DECLARE max_data DATETIME;
DECLARE max_centrale VARCHAR(45);
DECLARE max_messaggio VARCHAR(45);

DECLARE done INT DEFAULT FALSE;

DECLARE query CURSOR FOR 
	SELECT Data,Centrale,Messaggio 
	FROM SERCHIO 
	WHERE 
		DATE(Data) = in_data AND 
		Ospite LIKE CONCAT(in_ospite,'%');

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN query;

FETCH query INTO min_data,min_centrale,min_messaggio;
FETCH query INTO max_data,max_centrale,max_messaggio;

read_loop: LOOP

	FETCH query INTO temp_data,temp_centrale,temp_messaggio;
	
	IF done THEN
		LEAVE read_loop;
	END IF;
	
	IF (temp_data < min_data) THEN
		SET min_data = temp_data;
		SET min_centrale = temp_centrale;
		SET min_messaggio = temp_messaggio;
	END IF;

	IF (temp_data > max_data) THEN
		SET max_data = temp_data;
		SET max_centrale = temp_centrale;
		SET max_messaggio = temp_messaggio;
	END IF;
	

END LOOP read_loop;

CLOSE query;

SELECT 
	in_data,
	in_ospite,
	CONCAT_WS(' ','PULSAR',min_centrale,min_messaggio,DATE_FORMAT(min_data,'%H:%i:%s')) INGRESSO,
	CONCAT_WS(' ','PULSAR',max_centrale,max_messaggio,DATE_FORMAT(max_data,'%H:%i:%s')) USCITA,
	TIMESTAMPDIFF(MINUTE,max_data,min_data) DURATA;

END;
$$

DELIMITER ;
*/