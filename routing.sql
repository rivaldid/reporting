DROP FUNCTION IF EXISTS `id2tessera`;
DROP FUNCTION IF EXISTS `id2ospite`;
DROP FUNCTION IF EXISTS `id2evento`;
DROP FUNCTION IF EXISTS `id2varco`;
DROP VIEW IF EXISTS `join_ser_report_repository`;
DROP VIEW IF EXISTS `routing`;

DELIMITER $$

CREATE FUNCTION `id2tessera`(in_id_tessera INT) RETURNS VARCHAR(90)
BEGIN
RETURN (SELECT 
CONCAT(CASE tipo WHEN 1 THEN (SELECT 'ESTERNI') WHEN 2 THEN (SELECT 'POSTE') ELSE (SELECT 'SCONOSCIUTO') END,' ',numero)
FROM SER_TESSERE WHERE id_tessera=in_id_tessera);
END;
$$

CREATE FUNCTION `id2ospite`(in_id_ospite INT) RETURNS VARCHAR(45)
BEGIN
RETURN (SELECT HTML_UnEncode(nome) FROM SER_OSPITI WHERE id_ospite=in_id_ospite);
END;
$$

CREATE FUNCTION `id2evento`(in_id_evento INT) RETURNS VARCHAR(45)
BEGIN
RETURN (SELECT evento FROM SER_EVENTI WHERE id_evento=in_id_evento);
END;
$$

CREATE FUNCTION `id2varco`(in_id_varco INT) RETURNS VARCHAR(45)
BEGIN
RETURN (SELECT label FROM SER_VARCHI WHERE id_varco=in_id_varco);
END;
$$

CREATE VIEW `join_ser_report_repository` AS
SELECT Sid,SER_REPORT.Data,REPOSITORY.data AS datafile,id_tessera,id_ospite,id_evento,id_varco,direzione
FROM SER_REPORT JOIN REPOSITORY USING(Rid) WHERE id_tessera <> 1;

CREATE VIEW `routing` AS
SELECT
MAIN.Sid,
MAIN.Data,
TIMESTAMPDIFF(MINUTE,MAIN.Data,SUB.Data),
(SELECT * FROM join_ser_report_repository) AS MAIN
(SELECT * FROM join_ser_report_repository) AS SUB

DELIMITER ;