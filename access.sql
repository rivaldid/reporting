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

SET max_data = COALESCE((SELECT MAX(DATE(Data)) FROM SERCHIO),CURDATE());

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

	IF (temp_in IS NOT NULL) THEN
		INSERT INTO accessi(data,ospite,ingresso,uscita) VALUES(temp_data,temp_ospite,temp_in,temp_out);
		SET temp_in = NULL;
	END IF;

	SET in_data = DATE_ADD(in_data, INTERVAL 1 DAY);

UNTIL in_data > max_data END REPEAT;

SELECT * FROM accessi;

END;
$$

DELIMITER ;