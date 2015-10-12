DROP VIEW IF EXISTS `WINWATCH`;
DROP VIEW IF EXISTS `SERCHIO`;

CREATE VIEW `WINWATCH` AS
SELECT Centrale,Data,evento,messaggio FROM WIN_REPORT
LEFT JOIN WIN_EVENTI USING(id_evento)
LEFT JOIN WIN_MESSAGGI USING(id_messaggio)
ORDER BY Data DESC;

CREATE VIEW `SERCHIO` AS
SELECT Data,Centrale,seriale,evento,CONCAT(varco,' ',direzione) AS Messaggio,nome AS Ospite FROM SER_REPORT
LEFT JOIN SER_TESSERE USING(id_tessera)
LEFT JOIN SER_EVENTI USING(id_evento)
LEFT JOIN SER_MESSAGGI USING(id_messaggio)
LEFT JOIN SER_OSPITI USING(id_ospite)
ORDER BY Data DESC;