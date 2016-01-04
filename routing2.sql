DROP VIEW IF EXISTS `join_ser_report_repository`;
CREATE VIEW `join_ser_report_repository` AS
SELECT Sid,SER_REPORT.Data,REPOSITORY.data AS datafile,id_tessera,id_ospite,id_evento,id_varco,direzione
FROM SER_REPORT JOIN REPOSITORY USING(Rid) WHERE id_tessera <> 1;


