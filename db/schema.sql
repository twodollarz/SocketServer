CREATE DATABASE IF NOT EXISTS pipes CHARACTER SET utf8 COLLATE utf8_general_ci;
USE pipes;
CREATE TABLE IF NOT EXISTS `user` (
  `uid` char(64) NOT NULL,
  `udid` char(64) NOT NULL,
  `nickname` varchar(255),
  `tel` varchar(255),
  `faceimage_path` varchar(255) ,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `i0` (`udid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE IF NOT EXISTS `pipe` (
  `pipeid` INT(11) UNSIGNED AUTO_INCREMENT NOT NULL,
  `from_uid` char(128) NOT NULL,
  `to_uid` char(128) NOT NULL,
  `status` TINYINT NOT NULL,
  `uids` char(128) NOT NULL,
  PRIMARY KEY (`pipeid`),
  UNIQUE KEY `i0` (`uids`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT = 10000;

