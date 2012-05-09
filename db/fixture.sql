DROP DATABASE pipes;
CREATE DATABASE IF NOT EXISTS pipes CHARACTER SET utf8 COLLATE utf8_general_ci;
USE pipes;
CREATE TABLE IF NOT EXISTS `user` (
  `uuid` char(40) NOT NULL,
  `udid` char(40) NOT NULL,
  `userid` varchar(255) NOT NULL,
  `nickname` varchar(255),
  `tel` varchar(255),
  `faceimage_path` varchar(255) ,
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `i0` (`udid`),
  UNIQUE KEY `i1` (`userid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


