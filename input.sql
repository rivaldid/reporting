DROP PROCEDURE IF EXISTS `input_winwatch`;

DELIMITER $$


CREATE PROCEDURE `input_repo`(
IN in_tipo VARCHAR(45),
IN in_filename VARCHAR(45)
)
BEGIN
IF NOT (SELECT test_repo(in_tipo,in_filename)) THEN
	INSERT INTO REPOSITORY(tipo,filename) VALUES(in_tipo,in_filename);
END IF;
END;
$$


CREATE PROCEDURE `input_winwatch`(
IN in_centrale VARCHAR(45),
IN in_ora TIME,
IN in_data DATE,
IN in_azione VARCHAR(45),
IN in_messaggio VARCHAR(100)
)
BEGIN

DECLARE my_data DATE;
DECLARE my_id_azione INT;
DECLARE my_id_messaggio INT;

-- data
SET my_data = (SELECT dmy2Ymd(in_data));

-- azione
IF NOT (SELECT test_azione(in_azione)) THEN
	INSERT INTO WIN_AZIONI(azione) VALUES(in_azione);
	SET my_id_azione = LAST_INSERT_ID();
ELSE
	SET my_id_azione = (SELECT get_id_azione(in_azione));
END IF;

-- messaggio
IF NOT (SELECT test_messaggio(in_messaggio)) THEN
	INSERT INTO WIN_MESSAGGI(messaggio) VALUES(in_messaggio);
	SET my_id_messaggio = LAST_INSERT_ID();
ELSE
	SET my_id_messaggio = (SELECT get_id_messaggio(in_messaggio));
END IF;

-- report
INSERT INTO WIN_REPORT(Centrale,Ora,Data,id_azione,id_messaggio)
VALUES(in_centrale,in_ora,my_data,my_id_azione,my_id_messaggio);

END;
$$

DELIMITER ;