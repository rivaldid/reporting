USE `reporting`;
DROP VIEW IF EXISTS `WINWATCH_remap`;
DROP VIEW IF EXISTS `SERCHIO_remap`;
DROP VIEW IF EXISTS `REPORT_remap`;

CREATE VIEW `WINWATCH_remap` AS
SELECT
Data,
(IF(
	Centrale REGEXP '^[0-9]+$',
	CONCAT_WS(' ','PULSAR',RIGHT(Centrale,1),COALESCE(HTML_UnEncode(evento),'')),
	CONCAT_WS(' ',Centrale,COALESCE(HTML_UnEncode(evento),''))
)) Sensore,
HTML_UnEncode(messaggio) Evento,
contatore
FROM WIN_REPORT
LEFT JOIN WIN_EVENTI USING(id_evento)
LEFT JOIN WIN_MESSAGGI USING(id_messaggio)
ORDER BY Data DESC;

CREATE VIEW `SERCHIO_remap` AS
SELECT
Data,
CONCAT_WS(' ','PULSAR',centrale,COALESCE(varco,'')) Sensore,
CONCAT_WS(' ',seriale,evento,COALESCE(direzione,''),HTML_UnEncode(nome)) Evento,
contatore
FROM SER_REPORT
LEFT JOIN SER_TESSERE USING(id_tessera)
LEFT JOIN SER_EVENTI USING(id_evento)
LEFT JOIN SER_VARCHI USING(id_varco)
LEFT JOIN SER_OSPITI USING(id_ospite)
ORDER BY Data DESC, Sid DESC;

CREATE VIEW `REPORT_remap` AS
SELECT * FROM WINWATCH_remap UNION SELECT * FROM SERCHIO_remap ORDER BY Data ASC;