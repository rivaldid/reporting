DROP PROCEDURE IF EXISTS `clear_ser_bychecksum`;
DROP PROCEDURE IF EXISTS `clear_ser_bydate`;

DELIMITER $$

CREATE PROCEDURE `clear_ser_bychecksum`(IN in_checksum CHAR(32))
BEGIN
DECLARE my_rid INT;
SET @my_rid = (SELECT Rid FROM REPOSITORY WHERE checksum=in_checksum);
DELETE FROM SER_REPORT WHERE Rid=@my_rid;
DELETE FROM REPOSITORY WHERE Rid=@my_rid;
END;
$$

CREATE PROCEDURE `clear_ser_bydate`(IN in_date DATETIME)
BEGIN
DECLARE my_rid INT;
SET @my_rid = (SELECT Rid FROM SER_REPORT WHERE data>=in_data LIMIT 1);
DELETE FROM SER_REPORT WHERE Rid=@my_rid;
DELETE FROM REPOSITORY WHERE Rid=@my_rid;
END;
$$

DELIMITER ;