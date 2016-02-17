USE `reporting`;

DROP FUNCTION IF EXISTS `INCROCIO_ACCESSI`;

DELIMITER $$

CREATE FUNCTION `INCROCIO_ACCESSI`(in_data DATETIME,in_regexp VARCHAR(45))
BEGIN
RETURN (SELECT adc.ospiteadc,Societa FROM
(SELECT DISTINCT(Ospite) AS ospiteadc,Societa FROM ADC WHERE Data>=in_data) AS adc
INNER JOIN
(SELECT DISTINCT(Ospite) AS ospiteserchio FROM SERCHIO WHERE Data>in_data)  AS serchio
ON SUBSTRING(adc.ospiteadc,1,13) = SUBSTRING(serchio.ospiteserchio,1,13)
WHERE adc.Societa REGEXP in_regexp);
-- example '^(CIEL|COIL)$'
END;
$$

DELIMITER ;