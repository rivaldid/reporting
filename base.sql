DROP DATABASE `reporting`;
CREATE DATABASE IF NOT EXISTS `reporting`
	DEFAULT CHARACTER SET utf8
	DEFAULT COLLATE utf8_general_ci;
USE `reporting`;


DROP TABLE IF EXISTS `REPOSITORY`;
CREATE TABLE `REPOSITORY` (
  `Rid` int(11) NOT NULL AUTO_INCREMENT,
  `data` datetime NOT NULL,
  `tipo` varchar(45) NOT NULL,
  `filename` varchar(45) NOT NULL,
  CONSTRAINT localkey UNIQUE (`tipo`,`filename`),
  PRIMARY KEY (`Rid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `WIN_EVENTI`;
CREATE TABLE `WIN_EVENTI` (
  `id_evento` int(11) NOT NULL AUTO_INCREMENT,
  `evento` varchar(45) NOT NULL,
  UNIQUE (`evento`),
  PRIMARY KEY (`id_evento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `WIN_MESSAGGI`;
CREATE TABLE `WIN_MESSAGGI` (
  `id_messaggio` int(11) NOT NULL AUTO_INCREMENT,
  `messaggio` varchar(100) NOT NULL,
  UNIQUE (`messaggio`),
  PRIMARY KEY (`id_messaggio`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `WIN_REPORT`;
CREATE TABLE `WIN_REPORT` (
  `Wid` int(11) NOT NULL AUTO_INCREMENT,
  `Centrale` varchar(45) DEFAULT NULL,
  `Data` datetime DEFAULT NULL,
  `id_evento` int(11) DEFAULT NULL,
  `id_messaggio` int(11) DEFAULT NULL,
  `Rid` int(11) DEFAULT NULL,
  `contatore` int(11) DEFAULT NULL,
  CONSTRAINT localkey UNIQUE 
  (`Centrale`,`Data`,`id_evento`,`id_messaggio`),
  PRIMARY KEY (`Wid`),
  CONSTRAINT FOREIGN KEY (`id_evento`) 
	REFERENCES WIN_EVENTI(`id_evento`) 
	ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (`id_messaggio`) 
	REFERENCES WIN_MESSAGGI(`id_messaggio`) 
	ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




DROP TABLE IF EXISTS `SER_TESSERE`;
CREATE TABLE `SER_TESSERE` (
  `id_tessera` int(11) NOT NULL AUTO_INCREMENT,
  `tipo` int(1) DEFAULT NULL,
  `numero` varchar(45) DEFAULT NULL,
  `seriale` varchar(45) NOT NULL,
  UNIQUE (seriale),
  PRIMARY KEY (`id_tessera`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `SER_OSPITI`;
CREATE TABLE `SER_OSPITI` (
  `id_ospite` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(45) NOT NULL,
  UNIQUE (`nome`),
  PRIMARY KEY (`id_ospite`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `SER_EVENTI`;
CREATE TABLE `SER_EVENTI` (
  `id_evento` int(11) NOT NULL AUTO_INCREMENT,
  `evento` varchar(45) NOT NULL,
  UNIQUE (`evento`),
  PRIMARY KEY (`id_evento`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `SER_VARCHI`;
CREATE TABLE `SER_VARCHI` (
  `id_varco` int(11) NOT NULL AUTO_INCREMENT,
  `centrale` int(11) DEFAULT NULL,
  `varco` varchar(45) NOT NULL,
  `label` varchar(45) DEFAULT NULL,
  `antipanico` int(1) DEFAULT NULL,
  `perimetrale` int(1) DEFAULT NULL,
  `tastierino` int(1) DEFAULT NULL,
  CONSTRAINT localkey UNIQUE (`centrale`,`varco`),
  PRIMARY KEY (`id_varco`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `SER_REPORT`;
CREATE TABLE `SER_REPORT` (
  `Sid` int(11) NOT NULL AUTO_INCREMENT,
  `Data` datetime DEFAULT NULL,
  `id_tessera` int(11) DEFAULT NULL,
  `id_evento` int(11) DEFAULT NULL,
  `id_varco` int(11) DEFAULT NULL,
  `direzione` VARCHAR(45) DEFAULT NULL,
  `id_ospite` int(11) DEFAULT NULL,
  `Rid` int(11) DEFAULT NULL,
  `contatore` int(11) DEFAULT NULL,
  CONSTRAINT localkey UNIQUE 
  (`Data`,`id_tessera`,`id_evento`,`id_varco`,`direzione`,`id_ospite`),
  PRIMARY KEY (`Sid`),
  CONSTRAINT FOREIGN KEY (`id_tessera`) 
	REFERENCES SER_TESSERE(`id_tessera`) 
	ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (`id_evento`) 
	REFERENCES SER_EVENTI(`id_evento`) 
	ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (`id_varco`) 
	REFERENCES SER_VARCHI(`id_varco`) 
	ON DELETE CASCADE,
  CONSTRAINT FOREIGN KEY (`id_ospite`) 
	REFERENCES SER_OSPITI(`id_ospite`) 
	ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

