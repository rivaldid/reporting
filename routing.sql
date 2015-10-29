DROP FUNCTION IF EXISTS `nextone`;

DELIMITER $$

CREATE FUNCTION `nextone`(
in_data datetime,
in_id_tessera INT(11),
in_id_ospite INT(11)
)
RETURNS INT(11)
BEGIN
RETURN (SELECT Sid FROM SER_REPORT WHERE data>in_data AND id_tessera=in_id_tessera AND id_ospite=in_id_ospite LIMIT 1);
END;
$$

DELIMITER ;


SELECT * FROM
(SELECT MAIN.Data,(SUB.Data) FROM 
(SELECT * FROM SER_REPORT WHERE data>=NOW() - INTERVAL 1 DAY) AS MAIN
JOIN
(SELECT * FROM SER_REPORT WHERE data>=NOW() - INTERVAL 1 DAY) AS SUB
USING (id_tessera,id_ospite)
WHERE MAIN.data < SUB.data
LIMIT 1) AS transito
JOIN 
SER_TESSERE ON transito.id_tessera=SER_TESSERE.id_tessera

SELECT MAIN.Data, TIMESTAMPDIFF(MINUTE,SUB.Data,MAIN.Data) AS Durata,MAIN.id_tessera,MAIN.id_ospite,
MAIN.id_evento,MAIN.id_varco,MAIN.direzione,
SUB.id_eventoSUB.id_varco,SUB.direzione
FROM 
(SELECT * FROM SER_REPORT WHERE data>=NOW() - INTERVAL 1 DAY) AS MAIN
JOIN
(SELECT * FROM SER_REPORT WHERE data>=NOW() - INTERVAL 1 DAY) AS SUB
USING (id_tessera,id_ospite)
WHERE MAIN.data < SUB.data
LIMIT 1