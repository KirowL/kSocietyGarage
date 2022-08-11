CREATE TABLE  `society_vehicles` (
  `job` varchar(36) NOT NULL,
  `plate` varchar(30) NOT NULL,
  `vehicle` json NOT NULL,
  `is_stored` tinyint(1) NOT NULL,
  PRIMARY KEY (`plate`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

