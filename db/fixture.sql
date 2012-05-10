DROP DATABASE pipes;
CREATE DATABASE IF NOT EXISTS pipes CHARACTER SET utf8 COLLATE utf8_general_ci;
USE pipes;
CREATE TABLE IF NOT EXISTS `user` (
  `uid` CHAR(64) NOT NULL,
  `udid` CHAR(64) NOT NULL,
  `nickname` VARCHAR(255),
  `tel` VARCHAR(255),
  `faceimage_path` VARCHAR(255) ,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `i0` (`udid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
INSERT INTO user (uid, udid) values ('helium', '9999-9999-9999-9999');
INSERT INTO user (uid, udid) values ('natrium', '8888-8888-8888-8888');
INSERT INTO user (uid, udid) values ('lithium', '7777-7777-7777-7777');
INSERT INTO user (uid, udid) values ('neon', '6666-6666-6666-6666');
CREATE TABLE IF NOT EXISTS `pipe` (
  `pipe_id` INT(11) UNSIGNED AUTO_INCREMENT NOT NULL,
  `from_uid` CHAR(128) NOT NULL,
  `to_uid` CHAR(128) NOT NULL,
  `status` TINYINT NOT NULL,
  `uids` CHAR(128) NOT NULL,
  PRIMARY KEY (`pipe_id`),
  UNIQUE KEY `i0` (`uids`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT = 10000;
INSERT INTO pipe (from_uid, to_uid, status, uids) values ('lithium', 'neon', 1, 'lithiumneon');
CREATE TABLE IF NOT EXISTS `message` (
  `message_id` BIGINT UNSIGNED AUTO_INCREMENT NOT NULL,
  `pipe_id` INT(11) UNSIGNED NOT NULL ,
  `from_uid` CHAR(128) NOT NULL,
  `to_uid` CHAR(128) NOT NULL,
  `timestamp` CHAR(32) NOT NULL,
  `message` TEXT,
  `image_path` VARCHAR(255),
  PRIMARY KEY (`message_id`),
  KEY `i0` (`pipe_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT = 1000000;


