USE `reporting`;

DROP PROCEDURE IF EXISTS `ACCESSI_SERCHIO`;

DELIMITER $$

CREATE PROCEDURE `ACCESSI_SERCHIO`(IN in_data DATE, IN in_ospite VARCHAR(45))
BEGIN

DECLARE temp_data DATE;
DECLARE temp_ospite VARCHAR(45);
DECLARE temp_in TIME;
DECLARE temp_out TIME;

declare max_data DATE;


DROP TEMPORARY TABLE IF EXISTS accessi;
CREATE TEMPORARY TABLE accessi(
data date,
ospite varchar(45),
ingresso time,
uscita time);

SELECT MAX(DATE(Data)) INTO max_data FROM SERCHIO;

REPEAT

	SELECT 
	DATE(Data) DateOnly, 
	Ospite, 
	MIN(DATE_FORMAT(Data,'%H:%i:%s')) INGRESSO, 
	MAX(DATE_FORMAT(Data,'%H:%i:%s')) USCITA 
	INTO
	temp_data,
	temp_ospite,
	temp_in,
	temp_out
	FROM SERCHIO 
	WHERE 
	DATE(Data) = in_data AND
	Ospite <> '' AND 
	Ospite LIKE CONCAT(in_ospite,'%')
	GROUP BY DateOnly, Ospite;

	INSERT INTO accessi(data,ospite,ingresso,uscita) VALUES(temp_data,temp_ospite,temp_in,temp_out);
	
	SET in_data = (SELECT in_data + INTERVAL 1 DAY);

UNTIL (in_data <= max_data) END REPEAT;

SELECT * FROM accessi;

END;
$$

DELIMITER ;