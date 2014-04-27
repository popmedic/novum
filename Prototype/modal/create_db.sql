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
-- Insert our uis
--

INSERT INTO `uis`(`id`, `name`) VALUES (1, "Base Client rev 1");
INSERT INTO `uis`(`id`, `name`) VALUES (2, "Field Client rev 1");

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
-- Insert our customers
--

INSERT INTO `customers`(`id`, `name`) VALUES (1, "Novum Root");
-- INSERT INTO `customers`(`name`) VALUES ("University Hospital");

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
  `ui` int(11) NOT NULL DEFAULT 1,
  `checked` timestamp NULL DEFAULT NULL,
  `added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  FOREIGN KEY (`customer`) REFERENCES `customers`(`id`),
  FOREIGN KEY (`ui`) REFERENCES `uis`(`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Insert our base_users
--

INSERT INTO `base_users`(`id`, `name`, `password`, `customer`, `pubkey`, `ui`) VALUES(1, 'novumroot', '5414a00ad69c1584167389e5640fe1b0', 1, '', 1);
INSERT INTO `base_users`(`id`, `name`, `password`, `customer`, `pubkey`, `ui`) VALUES(2, 'PSL', '5414a00ad69c1584167389e5640fe1b0', 1, '', 1);

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
  `ui` int(11) NOT NULL DEFAULT 2,
  `added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`ui`) REFERENCES `uis`(`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `base_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `from` int(11) NOT NULL,
  `to` int(11) NOT NULL,
  `read` timestamp NULL DEFAULT NULL,
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

CREATE TABLE `base_attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `message` int(11) NOT NULL,
  `data` MEDIUMBLOB NOT NULL,
  `type` VARCHAR(128) NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (message) REFERENCES messages(id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
