DROP VIEW IF EXISTS `WINWATCH`;
DROP VIEW IF EXISTS `SERCHIO`;

CREATE VIEW `WINWATCH` AS
SELECT Centrale,Data,azione,messaggio FROM WIN_REPORT
LEFT JOIN WIN_AZIONI USING(id_azione)
LEFT JOIN WIN_MESSAGGI USING(id_messaggio)
ORDER BY Data DESC;

CREATE VIEW `SERCHIO` AS
SELECT Data,Centrale,seriale,azione,messaggio,nome AS Ospite FROM SER_REPORT
LEFT JOIN SER_TESSERE USING(id_tessera)
LEFT JOIN SER_AZIONI USING(id_azione)
LEFT JOIN SER_MESSAGGI USING(id_messaggio)
LEFT JOIN SER_OSPITI USING(id_ospite)
ORDER BY Data DESC;