USE `reporting`;

DROP VIEW IF EXISTS `CRITICAL_WINWATCH`;
DROP VIEW IF EXISTS `CRITICAL_SERCHIO`;

CREATE VIEW `CRITICAL_WINWATCH` AS
SELECT
DATE(Data) DateOnly,
CONCAT_WS(' ',Evento,'PULSAR',RIGHT(Centrale,1),Messaggio) Critical,
SUM(contatore) tot
FROM `WINWATCH` WHERE
`Evento` NOT REGEXP '(UNIT|FINE|DIS|UC|FINE|ATTIV|INSER|RISUL|SEGNAL)' AND
`Messaggio` NOT REGEXP '(RIPOSO)'
GROUP BY DateOnly,Centrale,Evento,Messaggio
ORDER BY DateOnly DESC;

CREATE VIEW `CRITICAL_SERCHIO` AS
SELECT
DATE(Data) DateOnly,
CONCAT_WS(' ',evento,'PULSAR',centrale,Messaggio,COALESCE(seriale,''),COALESCE(Ospite,'')) Critical,
SUM(contatore) tot
FROM `SERCHIO` WHERE
`evento` NOT REGEXP '(TRANSITO|CHIUSO|ABILITATA|ACQUISITI)'
GROUP BY DateOnly,centrale,evento,Messaggio
ORDER BY DateOnly DESC;
