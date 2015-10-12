DROP FUNCTION IF EXISTS `test_repo`;
DROP FUNCTION IF EXISTS `get_repo`;

DROP FUNCTION IF EXISTS `test_win_evento`;
DROP FUNCTION IF EXISTS `get_win_evento`;
DROP FUNCTION IF EXISTS `test_win_messaggio`;
DROP FUNCTION IF EXISTS `get_win_messaggio`;
DROP FUNCTION IF EXISTS `test_win_report`;
DROP FUNCTION IF EXISTS `get_win_report`;

DROP FUNCTION IF EXISTS `test_ser_tessera`;
DROP FUNCTION IF EXISTS `get_ser_tessera`;
DROP FUNCTION IF EXISTS `test_ser_evento`;
DROP FUNCTION IF EXISTS `get_ser_evento`;
DROP FUNCTION IF EXISTS `test_ser_messaggio`;
DROP FUNCTION IF EXISTS `get_ser_messaggio`;
DROP FUNCTION IF EXISTS `test_ser_ospite`;
DROP FUNCTION IF EXISTS `get_ser_ospite`;


DELIMITER $$

-- generic

CREATE FUNCTION `test_repo`(in_tipo VARCHAR(45),in_filename VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM REPOSITORY WHERE tipo=in_tipo AND filename=in_filename));
END;
$$

CREATE FUNCTION `get_repo`(in_tipo VARCHAR(45),in_filename VARCHAR(45))
RETURNS INT(11)
BEGIN
RETURN (SELECT Rid FROM REPOSITORY WHERE tipo=in_tipo AND filename=in_filename);
END;
$$


-- winwatch

CREATE FUNCTION `test_win_evento`(in_evento VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM WIN_EVENTI WHERE evento=in_evento));
END;
$$

CREATE FUNCTION `get_win_evento`(in_evento VARCHAR(45))
RETURNS INT(11)
BEGIN
RETURN (SELECT id_evento FROM WIN_EVENTI WHERE evento=in_evento);
END;
$$

CREATE FUNCTION `test_win_messaggio`(in_messaggio VARCHAR(100))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM WIN_MESSAGGI WHERE messaggio=in_messaggio));
END;
$$

CREATE FUNCTION `get_win_messaggio`(in_messaggio VARCHAR(100))
RETURNS INT(11)
BEGIN
RETURN (SELECT id_messaggio FROM WIN_MESSAGGI WHERE messaggio=in_messaggio);
END;
$$

CREATE FUNCTION `test_win_report`(
in_centrale VARCHAR(45),
in_data datetime,
in_id_evento INT,
in_id_messaggio INT
)
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM WIN_REPORT WHERE 
Centrale=in_centrale AND Data=in_data AND id_evento=in_id_evento AND id_messaggio=in_id_messaggio));
END;
$$

CREATE FUNCTION `get_win_report`(
in_centrale VARCHAR(45),
in_data datetime,
in_id_evento INT,
in_id_messaggio INT
)
RETURNS INT(11)
BEGIN
RETURN (SELECT Wid FROM WIN_REPORT WHERE 
Centrale=in_centrale AND Data=in_data AND id_evento=in_id_evento AND id_messaggio=in_id_messaggio);
END;
$$

CREATE FUNCTION `test_win_rduplicati`(in_wid INT(11))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM WIN_DUPLICATI WHERE Wid=in_wid));
END;
$$

CREATE FUNCTION `get_win_rduplicati`(in_wid INT(11))
RETURNS INT(11)
BEGIN
RETURN (SELECT Rid FROM WIN_DUPLICATI WHERE Wid=in_wid);
END;
$$



-- serchio

CREATE FUNCTION `test_ser_tessera`(in_seriale VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM SER_TESSERE WHERE seriale=in_seriale));
END;
$$

CREATE FUNCTION `get_ser_tessera`(in_seriale VARCHAR(45))
RETURNS INT(11)
BEGIN
RETURN (SELECT id_tessera FROM SER_TESSERE WHERE seriale=in_seriale);
END;
$$

CREATE FUNCTION `test_ser_evento`(in_evento VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM SER_EVENTI WHERE evento=in_evento));
END;
$$

CREATE FUNCTION `get_ser_evento`(in_evento VARCHAR(45))
RETURNS INT(11)
BEGIN
RETURN (SELECT id_evento FROM SER_EVENTI WHERE evento=in_evento);
END;
$$

CREATE FUNCTION `test_ser_messaggio`(in_varco VARCHAR(45), in_direzione VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM SER_MESSAGGI WHERE varco=in_varco AND direzione=in_direzione));
END;
$$

CREATE FUNCTION `get_ser_messaggio`(in_varco VARCHAR(45), in_direzione VARCHAR(45))
RETURNS INT(11)
BEGIN
RETURN (SELECT id_messaggio FROM SER_MESSAGGI WHERE varco=in_varco AND direzione=in_direzione);
END;
$$

CREATE FUNCTION `test_ser_ospite`(in_ospite VARCHAR(45))
RETURNS TINYINT(1)
BEGIN
RETURN (SELECT EXISTS(SELECT 1 FROM SER_OSPITI WHERE nome=in_ospite));
END;
$$

CREATE FUNCTION `get_ser_ospite`(in_ospite VARCHAR(45))
RETURNS INT(11)
BEGIN
RETURN (SELECT id_ospite FROM SER_OSPITI WHERE nome=in_ospite);
END;
$$



DELIMITER ;