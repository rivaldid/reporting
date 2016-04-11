CALL administration.drop_user('webreporting',@res);
SELECT @res;
CREATE USER 'webreporting'@'%' IDENTIFIED BY 'w3bR3port.';
GRANT EXECUTE ON FUNCTION reporting.html_unencode TO 'webreporting'@'%';
GRANT SELECT ON reporting.SERCHIO TO 'webreporting'@'%';
GRANT SELECT ON reporting.SERCHIO_OSPITI TO 'webreporting'@'%';
GRANT SELECT ON reporting.VARCHI TO 'webreporting'@'%';
GRANT SELECT ON reporting.BADGES TO 'webreporting'@'%';
GRANT SELECT ON reporting.WINWATCH TO 'webreporting'@'%';
GRANT SELECT ON reporting.ADC TO 'webreporting'@'%';
#GRANT SELECT ON magazzino.vserv_trace TO 'webreporting'@'%';
GRANT EXECUTE ON PROCEDURE reporting.PASSAGGI TO 'webreporting'@'%';
GRANT SELECT ON reporting.CRITICAL_WINWATCH TO 'webreporting'@'%';
GRANT SELECT ON reporting.CRITICAL_SERCHIO TO 'webreporting'@'%';
GRANT SELECT ON reporting.CRITICAL TO 'webreporting'@'%';
GRANT SELECT ON reporting.WINWATCH_remap TO 'webreporting'@'%';
GRANT SELECT ON reporting.SERCHIO_remap TO 'webreporting'@'%';
GRANT SELECT ON reporting.REPORT_remap TO 'webreporting'@'%';
FLUSH PRIVILEGES;