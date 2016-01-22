DROP VIEW IF EXISTS `WINWATCH`;
DROP VIEW IF EXISTS `SERCHIO`;
DROP VIEW IF EXISTS `BADGES`;
DROP VIEW IF EXISTS `SERCHIO_OSPITI`;
DROP VIEW IF EXISTS `ADC`;

CREATE VIEW `WINWATCH` AS
SELECT Centrale,Data,HTML_UnEncode(evento) AS Evento,HTML_UnEncode(messaggio) AS Messaggio,contatore FROM WIN_REPORT
LEFT JOIN WIN_EVENTI USING(id_evento)
LEFT JOIN WIN_MESSAGGI USING(id_messaggio)
ORDER BY Data DESC;

CREATE VIEW `SERCHIO` AS
SELECT Data,centrale,seriale,evento,CONCAT(COALESCE(varco,''),' ',COALESCE(direzione,'')) AS Messaggio,HTML_UnEncode(nome) AS Ospite,contatore
FROM SER_REPORT
LEFT JOIN SER_TESSERE USING(id_tessera)
LEFT JOIN SER_EVENTI USING(id_evento)
LEFT JOIN SER_VARCHI USING(id_varco)
LEFT JOIN SER_OSPITI USING(id_ospite)
ORDER BY Data DESC, Sid DESC;

CREATE VIEW `BADGES` AS
SELECT CONCAT_WS(' ',
CASE tipo WHEN 1 THEN (SELECT 'ESTERNI') WHEN 2 THEN (SELECT 'POSTE') ELSE (SELECT 'SCONOSCIUTO') END,
IF(NULLIF(numero,NULL),(SELECT CONCAT(' ',numero)),NULL),
' | ',seriale) AS Badges
FROM SER_TESSERE
WHERE seriale<>''
ORDER BY tipo DESC,LENGTH(numero),numero;

CREATE VIEW `SERCHIO_OSPITI` AS
SELECT HTML_UnEncode(nome) AS Ospite FROM SER_OSPITI ORDER BY nome;

CREATE VIEW `ADC` AS
SELECT
ADC_REPORT.data_report AS Data,
HTML_UnEncode(ADC_OSPITI.nome) AS Ospite,
HTML_UnEncode(ADC_REPORT.societa) AS Societa,
CONCAT_WS('|',ADC_DOCUMENTI.tipo,ADC_DOCUMENTI.numero,ADC_DOCUMENTI.scadenza) AS Documento,
ADC_REPORT.decorrenza AS Decorrenza,
ADC_REPORT.scadenza AS Scadenza,
ADC_REPORT.badge AS Badge,
ADC_REPORT.gruppo AS Gruppo_Badge,
HTML_UnEncode(ADC_REPORT.note) AS NOTE,
ADC_STRUTTURE.label AS Struttura,
ADC_PROFILI.label AS Profilo,
ADC_OSPITI.cf AS Codice_Fiscale,
ADC_OSPITI.data_di_nascita AS Data_di_Nascita,
ADC_OSPITI.nazionalita AS Nazionalita,
ADC_REPORT.locali AS Locali
FROM ADC_REPORT
LEFT JOIN ADC_OSPITI USING(id_ospite)
LEFT JOIN ADC_DOCUMENTI USING(id_documento)
LEFT JOIN ADC_STRUTTURE USING(id_struttura)
LEFT JOIN ADC_PROFILI USING(id_profilo)
ORDER BY ADC_REPORT.data_report DESC,ADC_OSPITI.nome;