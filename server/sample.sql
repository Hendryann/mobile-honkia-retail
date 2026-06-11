-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: mhlab
-- ------------------------------------------------------
-- Server version	8.0.46-0ubuntu0.24.04.2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `items` (
  `id` char(12) NOT NULL,
  `name` varchar(100) NOT NULL,
  `type` varchar(25) NOT NULL,
  `description` varchar(2000) NOT NULL,
  `stock` int unsigned NOT NULL,
  `price` int unsigned NOT NULL,
  `image` mediumblob /*!80023 INVISIBLE */,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `image` CHECK ((length(`image`) <= 5242880))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `items`
--

LOCK TABLES `items` WRITE;
/*!40000 ALTER TABLE `items` DISABLE KEYS */;
INSERT INTO `items` (`id`, `name`, `type`, `description`, `stock`, `price`, `image`, `created_at`) VALUES ('0','Light Telescope','tool','A type of telescope to observe close-up of distance space objects (like planets) by visible light',100,100,NULL,'2026-06-11 00:57:41'),('1','Radio Telescope','tool','A type of telescope to detect radio signals from outer space',100,100,NULL,'2026-06-11 00:57:41'),('2','Otherworldly Crystal','material','A mysterious material from the outer galaxy. ',1,1000000,NULL,'2026-06-11 00:57:41'),('4','Lifeform Analyzer','tool','A tool to detect life outside within a planet',20,2000,NULL,'2026-06-11 00:57:41'),('5','Planet Analyzer','tool','A tool to analyze a planet\'s atmosphere & surface compositions',10,9,NULL,'2026-06-11 00:57:41'),('6','Neutronium','material','Don\'t worry about it',1,5000000,NULL,'2026-06-11 00:57:41');
/*!40000 ALTER TABLE `items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `name` varchar(100) NOT NULL,
  `isadmin` tinyint(1) DEFAULT '0',
  `password` binary(32) DEFAULT NULL /*!80023 INVISIBLE */,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` (`name`, `isadmin`, `password`) VALUES ('admin',1,0xE1CBC48151CB6D21D91759F390D6341009BCC62A92E3DE95465134B1D3CF1B27),('user',0,0x36CEACA53C3CACA129EB607987F2F8CC795CF0B47A20FC23410A11B67D0A13E9);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-11  7:59:09
