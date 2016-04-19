USE `reporting`;

DROP VIEW IF EXISTS `search_serchio_ospiti`;

CREATE VIEW `search_serchio_ospiti` AS
SELECT DATE(Data) DateOnly, Ospite FROM SERCHIO
GROUP BY DateOnly,Ospite ORDER BY DateOnly DESC;