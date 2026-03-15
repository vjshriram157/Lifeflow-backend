-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: localhost    Database: bloodbank
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `password` varchar(100) DEFAULT NULL,
  `blood_group` varchar(10) DEFAULT NULL,
  `account_type` varchar(20) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `role` varchar(50) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'PENDING',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `strikes` int DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (2,'Admin','admin@lifeflow.com',NULL,NULL,NULL,NULL,NULL,'240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9','ADMIN','APPROVED','2026-02-10 21:02:02',0),(4,'Mukesh','mukesh18@gmail.com','9595995223',NULL,'AB+',NULL,'CHENNAI','ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae','DONOR','APPROVED','2026-02-10 21:02:02',3),(5,'Vijay Shriram BS','vijay.shriram157@gmail.com','09150200538',NULL,'O+',NULL,'CHENNAI','0dfee0daca587e1826e80dbd56e0c0215be463504cbe8ca9a9dd41adc2ed2df4','DONOR','APPROVED','2026-02-10 21:02:02',0),(6,'L1 blood bank','l1bloodbank@gmail.com','9874563215',NULL,'',NULL,'CHENNAI','ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae','BANK','APPROVED','2026-02-10 21:02:02',0),(7,'srijith','srijith@gmail.com','9745625115',NULL,'B-',NULL,'chennai','ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae','DONOR','APPROVED','2026-02-11 06:38:07',0),(8,'suriya sri','suriyasricse@gmail.com','9887199956',NULL,'O+',NULL,'trichy','ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae','DONOR','APPROVED','2026-02-13 05:09:28',0),(9,'L2 blood bank','l2bloodbank@gmail.com','9855858585',NULL,'O+',NULL,'trichy','ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae','BANK','APPROVED','2026-02-13 05:12:19',0),(10,'L3 blood bank','l3bloodbank@gmail.com','9898465415',NULL,'',NULL,'coimbatore','ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae','BANK','APPROVED','2026-02-13 08:15:18',0),(11,'dharshan','dharshan@gmail.com','9874562255',NULL,'AB+',NULL,'kanchipuram','ecd71870d1963316a97e3ac3408c9835ad8cf0f3c1bc703527c30265534f75ae','DONOR','APPROVED','2026-02-13 08:25:44',0);
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

-- Dump completed on 2026-03-15 13:10:39
