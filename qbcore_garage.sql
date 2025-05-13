CREATE TABLE IF NOT EXISTS `player_vehicles` (
  `citizenid` varchar(46) DEFAULT NULL,
  `plate` varchar(12) NOT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'car',
  `state` tinyint(4) NOT NULL DEFAULT 0,
  `garage` varchar(60) DEFAULT NULL,
  `impound` tinyint(4) DEFAULT 0,
  `job` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;