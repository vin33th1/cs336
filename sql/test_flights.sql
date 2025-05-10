-- MySQL dump 10.13  Distrib 8.0.42, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: test
-- ------------------------------------------------------
-- Server version	8.0.42

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
-- Table structure for table `flights`
--

DROP TABLE IF EXISTS `flights`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `flights` (
  `FlightID` int NOT NULL AUTO_INCREMENT,
  `AirlineID` char(2) NOT NULL,
  `FlightNumber` varchar(10) NOT NULL,
  `DepartureAirport` char(3) NOT NULL,
  `ArrivalAirport` char(3) NOT NULL,
  `DepartureTime` time NOT NULL,
  `ArrivalTime` time NOT NULL,
  `DurationMinutes` int NOT NULL,
  `FlightDate` date NOT NULL DEFAULT '2023-12-01',
  `DaysOfWeek` varchar(50) NOT NULL,
  `FlightType` enum('Domestic','International') NOT NULL,
  `TripType` enum('OneWay','RoundTrip') NOT NULL,
  `Stops` int NOT NULL,
  `EconomySeats` int NOT NULL,
  `BusinessSeats` int NOT NULL,
  `FirstSeats` int NOT NULL,
  `EconomyPrice` decimal(10,2) NOT NULL,
  `BusinessPrice` decimal(10,2) NOT NULL,
  `FirstPrice` decimal(10,2) NOT NULL,
  PRIMARY KEY (`FlightID`),
  KEY `AirlineID` (`AirlineID`),
  KEY `DepartureAirport` (`DepartureAirport`),
  KEY `ArrivalAirport` (`ArrivalAirport`),
  CONSTRAINT `flights_ibfk_1` FOREIGN KEY (`AirlineID`) REFERENCES `airlines` (`AirlineID`),
  CONSTRAINT `flights_ibfk_2` FOREIGN KEY (`DepartureAirport`) REFERENCES `airports` (`AirportCode`),
  CONSTRAINT `flights_ibfk_3` FOREIGN KEY (`ArrivalAirport`) REFERENCES `airports` (`AirportCode`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `flights`
--

LOCK TABLES `flights` WRITE;
/*!40000 ALTER TABLE `flights` DISABLE KEYS */;
INSERT INTO `flights` VALUES (1,'AA','AA100','JFK','LAX','08:00:00','11:00:00',0,'2025-06-15','Mon,Wed,Fri','Domestic','OneWay',0,120,20,10,299.99,599.99,899.99),(2,'AA','AA200','LAX','JFK','14:00:00','22:00:00',0,'2025-10-12','Mon,Wed,Fri','Domestic','OneWay',0,120,20,10,299.99,599.99,899.99),(3,'AA','AA300','ORD','LAX','09:30:00','12:00:00',0,'2025-12-05','Tue,Thu,Sat','Domestic','RoundTrip',0,100,30,20,199.99,499.99,799.99),(4,'DL','DL101','JFK','ATL','07:00:00','09:30:00',0,'2025-05-22','Daily','Domestic','OneWay',0,150,20,10,249.99,549.99,849.99),(5,'DL','DL202','ATL','SFO','11:00:00','14:00:00',0,'2025-07-15','Mon-Fri','Domestic','OneWay',1,130,30,20,349.99,649.99,949.99),(6,'UA','UA123','ORD','SFO','06:00:00','08:30:00',0,'2025-08-20','Daily','Domestic','OneWay',0,100,40,20,279.99,579.99,879.99),(7,'UA','UA456','SFO','LAX','12:00:00','13:30:00',0,'2025-09-30','Daily','Domestic','RoundTrip',0,80,30,10,99.99,299.99,499.99),(8,'UA','UA789','LAX','ORD','18:00:00','23:30:00',0,'2025-11-10','Sun','Domestic','OneWay',1,110,25,15,329.99,629.99,929.99),(9,'AA','AA101','JFK','LAX','06:00:00','09:00:00',180,'2025-06-15','Daily','Domestic','OneWay',0,120,20,10,299.99,599.99,899.99),(10,'DL','DL102','JFK','LAX','08:30:00','14:00:00',330,'2025-06-12','Mon,Wed,Fri','Domestic','OneWay',1,110,25,15,249.99,549.99,849.99),(11,'UA','UA103','JFK','LAX','12:00:00','15:00:00',180,'2025-06-13','Tue,Thu,Sat','Domestic','OneWay',0,100,30,20,349.99,649.99,949.99),(12,'AA','AA104','JFK','LAX','14:30:00','21:30:00',420,'2025-06-14','Sun','Domestic','OneWay',2,130,15,5,199.99,499.99,799.99),(13,'DL','DL105','JFK','LAX','18:00:00','21:00:00',180,'2025-06-16','Mon-Fri','Domestic','OneWay',0,90,40,30,399.99,699.99,999.99),(14,'UA','UA106','JFK','LAX','22:00:00','01:00:00',180,'2025-06-17','Daily','Domestic','OneWay',0,80,20,10,279.99,579.99,879.99),(15,'AA','AA107','JFK','LAX','09:15:00','15:45:00',390,'2025-06-18','Weekends','Domestic','OneWay',1,100,25,15,229.99,529.99,829.99),(16,'DL','DL108','JFK','LAX','13:00:00','16:00:00',180,'2025-06-15','Daily','International','OneWay',0,110,30,20,379.99,679.99,979.99);
/*!40000 ALTER TABLE `flights` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-05-07 16:35:57
