--
-- Database: `novummc`
--

-- --------------------------------------------------------

--
-- Table structure for table `ui`
--

CREATE TABLE `uis` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

-- --------------------------------------------------------

--
-- Table structure for table `base_users`
--

CREATE TABLE `base_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `password` varchar(128) NOT NULL,
  `customer` int(11) NOT NULL,
  `pubkey` varchar(2056) NOT NULL,
  `ui` int(11) NOT NULL,
  `checked` timestamp NULL DEFAULT NULL,
  `added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  FOREIGN KEY (`customer`) REFERENCES `customers`(`id`),
  FOREIGN KEY (`ui`) REFERENCES `uis`(`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `field_users`
--

CREATE TABLE `field_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) DEFAULT NULL,
  `phone_number` varchar(128) DEFAULT NULL,
  `agency` varchar(128) DEFAULT NULL,
  `unit` varchar(128) DEFAULT NULL,
  `ip_addr` varchar(128) DEFAULT NULL,
  `mac_addr` varchar(128) DEFAULT NULL,
  `ui` int(11) NOT NULL,
  `added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `phone_number` (`phone_number`),
  UNIQUE KEY `ip_addr` (`ip_addr`),
  UNIQUE KEY `mac_addr` (`mac_addr`),
  FOREIGN KEY (`ui`) REFERENCES `uis`(`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `from` int(11) NOT NULL,
  `to` int(11) NOT NULL,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `message` blob NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`from`) REFERENCES `field_users`(`id`),
  FOREIGN KEY (`to`) REFERENCES `base_users`(`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `attachment`
--

CREATE TABLE `attachment` (
  `id` int(11) NOT NULL,
  `message` int(11) NOT NULL,
  `data` blob NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (message) REFERENCES messages(id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;