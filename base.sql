DROP DATABASE `reporting`;
CREATE DATABASE IF NOT EXISTS `reporting`
	DEFAULT CHARACTER SET utf8
	DEFAULT COLLATE utf8_general_ci;
USE `reporting`;

DROP TABLE IF EXISTS `WIN_AZIONI`;
CREATE TABLE `WIN_AZIONI` (
  `id_azione` int(11) NOT NULL AUTO_INCREMENT,
  `azione` varchar(45) NOT NULL,
  UNIQUE (azione),
  PRIMARY KEY (`id_azione`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `WIN_MESSAGGI`;
CREATE TABLE `WIN_MESSAGGI` (
  `id_messaggio` int(11) NOT NULL AUTO_INCREMENT,
  `messaggio` varchar(100) NOT NULL,
  UNIQUE (messaggio),
  PRIMARY KEY (`id_messaggio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `WIN_REPORT`;
CREATE TABLE `WIN_REPORT` (
  `Wid` int(11) NOT NULL AUTO_INCREMENT,
  `Centrale` varchar(45) DEFAULT NULL,
  `Ora` time DEFAULT NULL,
  `Data` date DEFAULT NULL,
  `id_azione` int(11) DEFAULT NULL,
  `id_messaggio` int(11) DEFAULT NULL,
  CONSTRAINT localkey UNIQUE 
  (`Centrale`,`Ora`,`Data`,`id_azione`,`id_messaggio`),
  PRIMARY KEY (`Wid`),
  CONSTRAINT FOREIGN KEY (`id_azione`) 
	REFERENCES WIN_AZIONI(`id_azione`) 
	ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (`id_messaggio`) 
	REFERENCES WIN_MESSAGGI(`id_messaggio`) 
	ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



DROP TABLE IF EXISTS `SER_TESSERE`;
CREATE TABLE `SER_TESSERE` (
  `id_tessera` int(11) NOT NULL AUTO_INCREMENT,
  `tipo` varchar(45) NOT NULL,
  `numero` varchar(45) NOT NULL,
  `seriale` varchar(45) NOT NULL,
  UNIQUE (seriale),
  PRIMARY KEY (`id_tessera`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `SER_PERSONE`;
CREATE TABLE `SER_PERSONE` (
  `id_persona` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(45) NOT NULL,
  `cognome` varchar(45) NOT NULL,
  CONSTRAINT nominativo UNIQUE (`nome`,`cognome`),
  PRIMARY KEY (`id_persona`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `SER_AZIONI`;
CREATE TABLE `SER_AZIONI` (
  `id_azione` int(11) NOT NULL AUTO_INCREMENT,
  `azione` varchar(45) NOT NULL,
  UNIQUE (azione),
  PRIMARY KEY (`id_azione`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `SER_MESSAGGI`;
CREATE TABLE `SER_MESSAGGI` (
  `id_messaggio` int(11) NOT NULL AUTO_INCREMENT,
  `messaggio` varchar(100) NOT NULL,
  UNIQUE (messaggio),
  PRIMARY KEY (`id_messaggio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `SER_REPORT`;
CREATE TABLE `SER_REPORT` (
  `Sid` int(11) NOT NULL AUTO_INCREMENT,
  `Data` date DEFAULT NULL,
  `Ora` time DEFAULT NULL,
  `Centrale` int(11) DEFAULT NULL,
  `id_tessera` int(11) DEFAULT NULL,
  `id_azione` int(11) DEFAULT NULL,
  `id_messaggio` int(11) DEFAULT NULL,
  `id_persona` int(11) DEFAULT NULL,
  CONSTRAINT localkey UNIQUE 
  (`Data`,`Ora`,`Centrale`,`id_tessera`,`id_azione`,`id_messaggio`,`id_persona`),
  PRIMARY KEY (`Sid`),
  CONSTRAINT FOREIGN KEY (`id_tessera`) 
	REFERENCES SER_TESSERE(`id_tessera`) 
	ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (`id_azione`) 
	REFERENCES SER_AZIONI(`id_azione`) 
	ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (`id_messaggio`) 
	REFERENCES SER_MESSAGGI(`id_messaggio`) 
	ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (`id_persona`) 
	REFERENCES SER_PERSONE(`id_persona`) 
	ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



DROP TABLE IF EXISTS `REPOSITORY`;
CREATE TABLE `REPOSITORY` (
  `Rid` int(11) NOT NULL AUTO_INCREMENT,
  `tipo` varchar(45) NOT NULL,
  `filename` varchar(45) NOT NULL,
  CONSTRAINT localkey UNIQUE (`tipo`,`filename`),
  PRIMARY KEY (`Rid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
