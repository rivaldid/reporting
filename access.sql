USE `reporting`;

DROP VIEW IF EXISTS `search_serchio_ospiti`;

CREATE VIEW `search_serchio_ospiti` AS
SELECT DATE(Data) DateOnly, Ospite FROM SERCHIO WHERE
GROUP BY DateOnly, Ospite;