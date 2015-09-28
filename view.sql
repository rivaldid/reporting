DROP VIEW IF EXISTS `WINWATCH`;

CREATE VIEW `WINWATCH` AS
SELECT Centrale,Ora,Data,azione,messaggio FROM WIN_REPORT
LEFT JOIN WIN_AZIONI USING(id_azione)
LEFT JOIN WIN_MESSAGGI USING(id_messaggio)
ORDER BY Data,Ora;