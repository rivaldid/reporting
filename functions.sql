DROP FUNCTION IF EXISTS `test_azione`;
DROP FUNCTION IF EXISTS `get_id_azione`;
DROP FUNCTION IF EXISTS `test_messaggio`;
DROP FUNCTION IF EXISTS `get_id_messaggio`;
DROP FUNCTION IF EXISTS `dmy2Ymd`;

DELIMITER $$

CREATE FUNCTION `test_azione`(in_azione VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM WIN_AZIONI WHERE azione=in_azione));
END;
$$

CREATE FUNCTION `get_id_azione`(in_azione VARCHAR(45))
RETURNS INT(11)
BEGIN
RETURN (SELECT id_azione FROM WIN_AZIONI WHERE azione=in_azione);
END;
$$

CREATE FUNCTION `test_messaggio`(in_messaggio VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM WIN_MESSAGGI WHERE messaggio=in_messaggio));
END;
$$

CREATE FUNCTION `get_id_messaggio`(in_messaggio VARCHAR(45))
RETURNS INT(11)
BEGIN
RETURN (SELECT id_messaggio FROM WIN_MESSAGGI WHERE messaggio=in_messaggio);
END;
$$

CREATE FUNCTION `dmy2Ymd`(in_data VARCHAR(45))
RETURNS DATE
BEGIN
RETURN (SELECT DATE_FORMAT(DATE_FORMAT(in_data,'%d-%m-%y'),'%Y-%m-%d'));
END;
$$

DELIMITER ;