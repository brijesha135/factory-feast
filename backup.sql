-- MySQL dump 10.13  Distrib 9.2.0, for Win64 (x86_64)
--
-- Host: localhost    Database: artisan_cafe_ck
-- ------------------------------------------------------
-- Server version	9.2.0

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
-- Table structure for table `factory_order_manifests`
--

DROP TABLE IF EXISTS `factory_order_manifests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `factory_order_manifests` (
  `manifest_id` int NOT NULL AUTO_INCREMENT,
  `manifest_no` varchar(20) NOT NULL,
  `license_key` varchar(50) NOT NULL,
  `outlet_brand` varchar(100) NOT NULL,
  `fulfillment_type` varchar(50) NOT NULL,
  `manifest_date` varchar(255) DEFAULT NULL,
  `manifest_time` varchar(255) DEFAULT NULL,
  `workflow_status` varchar(20) DEFAULT 'PLACED',
  `pickup_due_date` date DEFAULT NULL,
  `chef_instructions` text,
  `sys_created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`manifest_id`),
  UNIQUE KEY `idx_manifest_no` (`manifest_no`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `factory_order_manifests`
--

LOCK TABLES `factory_order_manifests` WRITE;
/*!40000 ALTER TABLE `factory_order_manifests` DISABLE KEYS */;
INSERT INTO `factory_order_manifests` VALUES (1,'M-001','L-BK-01','Artisan Main','Counter','2026-01-03','10:00:00','COMPLETED',NULL,NULL,'2026-01-03 12:00:56'),(2,'M-002','L-BK-02','Artisan South','Advance','2026-01-03','10:15:00','PROCESSING',NULL,NULL,'2026-01-03 12:00:56'),(3,'M-003','L-BK-01','Artisan Main','Urgent','2026-01-03','10:30:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(4,'M-004','L-BK-03','Artisan North','Counter','2026-01-03','11:00:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(5,'M-005','L-BK-01','Artisan Main','Counter','2026-01-03','11:20:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(6,'M-006','L-BK-02','Artisan South','Advance','2026-01-04','09:00:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(7,'M-007','L-BK-03','Artisan North','Urgent','2026-01-03','11:45:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(8,'M-008','L-BK-01','Artisan Main','Counter','2026-01-03','12:00:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(9,'M-009','L-BK-02','Artisan South','Counter','2026-01-03','12:15:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(10,'M-010','L-BK-03','Artisan North','Advance','2026-01-05','14:00:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(11,'M-011','L-BK-01','Artisan Main','Counter','2026-01-03','12:45:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(12,'M-012','L-BK-01','Artisan Main','Urgent','2026-01-03','13:00:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(13,'M-013','L-BK-02','Artisan South','Counter','2026-01-03','13:10:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(14,'M-014','L-BK-03','Artisan North','Counter','2026-01-03','13:30:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(15,'M-015','L-BK-01','Artisan Main','Advance','2026-01-04','16:00:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(16,'M-016','L-BK-02','Artisan South','Counter','2026-01-03','14:00:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(17,'M-017','L-BK-03','Artisan North','Urgent','2026-01-03','14:20:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(18,'M-018','L-BK-01','Artisan Main','Counter','2026-01-03','14:45:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(19,'M-019','L-BK-02','Artisan South','Counter','2026-01-03','15:00:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(20,'M-020','L-BK-03','Artisan North','Advance','2026-01-06','10:00:00','PLACED',NULL,NULL,'2026-01-03 12:00:56'),(21,'MAN-1767462009101','LIC-12345','ARTISAN_POS','REGULAR',NULL,NULL,'PLACED',NULL,NULL,'2026-01-03 17:40:09'),(22,'MAN-1767462483489','LIC-12345','ARTISAN_POS','URGENT',NULL,NULL,'PLACED',NULL,NULL,'2026-01-03 17:48:03'),(23,'TRM-1767464266529','LIC-12345','Artisan Bakery & Cafe','REGULAR',NULL,NULL,'PLACED',NULL,NULL,'2026-01-03 18:17:46'),(24,'TXN-1767464461316','LIC-POS-9988','Artisan Bakery & Cafe','ADVANCE',NULL,NULL,'PLACED',NULL,NULL,'2026-01-03 18:21:01'),(25,'F-1767516990854','LIC-FACTORY-FEAST-2026','FACTORY FEAST','SALE',NULL,NULL,'PLACED',NULL,NULL,'2026-01-04 08:56:32'),(26,'F-1767517319650','LIC-FACTORY-FEAST-2026','FACTORY FEAST','ADVANCE',NULL,NULL,'PLACED',NULL,NULL,'2026-01-04 09:01:59'),(27,'F-1767517325763','LIC-FACTORY-FEAST-2026','FACTORY FEAST','URGENT',NULL,NULL,'PLACED',NULL,NULL,'2026-01-04 09:02:05'),(28,'F-1767528695332','LIC-FACTORY-FEAST-2026','FACTORY FEAST','SALE',NULL,NULL,'PLACED',NULL,NULL,'2026-01-04 12:11:35');
/*!40000 ALTER TABLE `factory_order_manifests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `master_categories`
--

DROP TABLE IF EXISTS `master_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `master_categories` (
  `category_code` varchar(50) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  PRIMARY KEY (`category_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `master_categories`
--

LOCK TABLES `master_categories` WRITE;
/*!40000 ALTER TABLE `master_categories` DISABLE KEYS */;
INSERT INTO `master_categories` VALUES ('CAT_BK','Artisan Bakery'),('CAT_BV','Beverages'),('CAT_CK','Full Cakes'),('CAT_PZ','Pizzas');
/*!40000 ALTER TABLE `master_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `master_modifiers`
--

DROP TABLE IF EXISTS `master_modifiers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `master_modifiers` (
  `modifier_code` varchar(50) NOT NULL,
  `modifier_name` varchar(100) NOT NULL,
  `price` double DEFAULT NULL,
  PRIMARY KEY (`modifier_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `master_modifiers`
--

LOCK TABLES `master_modifiers` WRITE;
/*!40000 ALTER TABLE `master_modifiers` DISABLE KEYS */;
INSERT INTO `master_modifiers` VALUES ('M01','Extra Cheese',50),('M02','Oat Milk Swap',65),('M03','Almond Milk Swap',70),('M04','Sugar Free Syrup',40),('M05','Extra Shot Espresso',45),('M06','Whipped Cream',30),('M07','Gluten Free Crust',120),('M08','Vegan Cheese',80),('M09','Basil Pesto Drizzle',35),('M10','Caramel Drizzle',25),('M11','Chocolate Chips',30),('M12','Walnuts',55),('M13','Gift Wrap Box',45),('M14','Birthday Candle',10),('M15','Personalized Note',15),('M16','Double Patty',90),('M17','Jalapenos',30),('M18','Fresh Fruit Topping',50),('M19','Honey Drizzle',20),('M20','Butter Dip',25),('MOD_CH','Extra Cheese',55),('MOD_GB','Gift Box Wrap',25),('MOD_OL','Black Olives',35),('MOD_OM','Oat Milk Swap',50);
/*!40000 ALTER TABLE `master_modifiers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `master_subcategories`
--

DROP TABLE IF EXISTS `master_subcategories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `master_subcategories` (
  `subcategory_id` int NOT NULL AUTO_INCREMENT,
  `category_code` varchar(50) NOT NULL,
  `subcategory_name` varchar(100) NOT NULL,
  PRIMARY KEY (`subcategory_id`),
  KEY `fk_cat_ref` (`category_code`),
  CONSTRAINT `fk_cat_ref` FOREIGN KEY (`category_code`) REFERENCES `master_categories` (`category_code`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `master_subcategories`
--

LOCK TABLES `master_subcategories` WRITE;
/*!40000 ALTER TABLE `master_subcategories` DISABLE KEYS */;
INSERT INTO `master_subcategories` VALUES (1,'CAT_BK','Sourdough'),(2,'CAT_BK','Pastries'),(3,'CAT_BK','Cookies'),(4,'CAT_BK','Buns'),(5,'CAT_BK','Savory'),(6,'CAT_BV','Hot Coffee'),(7,'CAT_BV','Cold Coffee'),(8,'CAT_BV','Teas'),(9,'CAT_BV','Frappes'),(10,'CAT_BV','Juices'),(11,'CAT_PZ','Classic Pizza'),(12,'CAT_PZ','Gourmet Pizza'),(13,'CAT_PZ','Deep Dish'),(14,'CAT_PZ','Calzones'),(15,'CAT_PZ','Flatbreads'),(16,'CAT_CK','Chocolate Cakes'),(17,'CAT_CK','Fruit Cakes'),(18,'CAT_CK','Pastry Slices'),(19,'CAT_CK','Wedding Cakes'),(20,'CAT_CK','Custom Tins');
/*!40000 ALTER TABLE `master_subcategories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `master_variants`
--

DROP TABLE IF EXISTS `master_variants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `master_variants` (
  `variant_id` int NOT NULL AUTO_INCREMENT,
  `sku_code` int NOT NULL,
  `variant_name` varchar(100) NOT NULL,
  `additional_price` double DEFAULT NULL,
  PRIMARY KEY (`variant_id`),
  KEY `fk_variant_sku` (`sku_code`),
  CONSTRAINT `fk_variant_sku` FOREIGN KEY (`sku_code`) REFERENCES `menu_catalog` (`sku_code`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `master_variants`
--

LOCK TABLES `master_variants` WRITE;
/*!40000 ALTER TABLE `master_variants` DISABLE KEYS */;
INSERT INTO `master_variants` VALUES (1,501,'Small (7 inch)',0),(2,501,'Medium (10 inch)',140),(3,501,'Large (12 inch)',240),(4,516,'Regular',0),(5,516,'Large',40),(6,103,'Small 7\"',0),(7,103,'Medium 10\"',150),(8,103,'Large 12\"',250),(9,104,'Regular',0),(10,104,'Large',180),(11,105,'Regular',0),(12,105,'Grande',45),(13,106,'Regular',0),(14,106,'Tall',50),(15,107,'500g',0),(16,107,'1kg',800),(17,111,'Personal',0),(18,111,'Family',350),(19,112,'Small',0),(20,112,'Jumbo',60),(21,115,'Iced',20),(22,115,'Hot',0),(23,116,'Half KG',0),(24,116,'Full KG',600),(25,120,'With Dip',30);
/*!40000 ALTER TABLE `master_variants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menu_catalog`
--

DROP TABLE IF EXISTS `menu_catalog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu_catalog` (
  `sku_code` int NOT NULL,
  `product_display_name` varchar(255) NOT NULL,
  `category_code` varchar(50) DEFAULT NULL,
  `base_factory_price` double DEFAULT NULL,
  `tax_indicator` varchar(10) DEFAULT 'A',
  `kitchen_station_code` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`sku_code`),
  KEY `fk_cat_link` (`category_code`),
  CONSTRAINT `fk_cat_link` FOREIGN KEY (`category_code`) REFERENCES `master_categories` (`category_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_catalog`
--

LOCK TABLES `menu_catalog` WRITE;
/*!40000 ALTER TABLE `menu_catalog` DISABLE KEYS */;
INSERT INTO `menu_catalog` VALUES (101,'Artisan Sourdough','CAT_BK',180,'A','OVEN'),(102,'Butter Croissant','CAT_BK',120,'A','OVEN'),(103,'Margherita Pizza','CAT_PZ',250,'B','PIZZA'),(104,'Farmhouse Veggie','CAT_PZ',320,'B','PIZZA'),(105,'Cappuccino','CAT_BV',140,'A','BAR'),(106,'Cafe Latte','CAT_BV',150,'A','BAR'),(107,'Belgian Choco Cake','CAT_CK',1200,'C','COLD'),(108,'Red Velvet Slice','CAT_CK',160,'B','COLD'),(109,'Blueberry Muffin','CAT_BK',95,'A','OVEN'),(110,'Iced Americano','CAT_BV',130,'A','BAR'),(111,'Pepperoni Feast','CAT_PZ',450,'B','PIZZA'),(112,'Vanilla Frappe','CAT_BV',190,'A','BAR'),(113,'Multigrain Loaf','CAT_BK',90,'A','OVEN'),(114,'Chocolate Danish','CAT_BK',145,'A','OVEN'),(115,'Matcha Latte','CAT_BV',180,'A','BAR'),(116,'Pineapple Cake','CAT_CK',850,'C','COLD'),(117,'Chicken Tikka Puff','CAT_BK',85,'B','OVEN'),(118,'Paneer Patty','CAT_BK',75,'B','OVEN'),(119,'Tiramisu Jar','CAT_CK',240,'B','COLD'),(120,'Cheese Garlic Bread','CAT_BK',140,'A','OVEN'),(501,'Margherita Classic','CAT_PZ',220,'A','OVEN'),(502,'Farmhouse Veggie','CAT_PZ',310,'A','OVEN'),(503,'Multigrain Sourdough','CAT_BK',160,'A','BAKE'),(504,'Butter Croissant','CAT_BK',110,'A','BAKE'),(505,'Pain Au Chocolat','CAT_BK',135,'A','BAKE'),(506,'Blueberry Muffin','CAT_BK',85,'A','BAKE'),(507,'Almond Danish','CAT_BK',145,'A','BAKE'),(508,'Chicken Tikka Puff','CAT_BK',75,'A','BAKE'),(509,'Paneer Patty','CAT_BK',65,'A','BAKE'),(510,'Garlic Cheese Bread','CAT_BK',130,'A','BAKE'),(511,'Chocolate Truffle','CAT_CK',1100,'A','COLD'),(512,'Red Velvet Full Cake','CAT_CK',950,'A','COLD'),(513,'Pineapple Fresh Cream','CAT_CK',800,'A','COLD'),(514,'Tiramisu Jar','CAT_BK',210,'A','COLD'),(515,'Brownie Blast','CAT_BK',105,'A','COLD'),(516,'Cappuccino','CAT_BV',130,'A','BAR'),(517,'Cafe Latte','CAT_BV',145,'A','BAR'),(518,'Iced Americano','CAT_BV',120,'A','BAR'),(519,'Vanilla Frappe','CAT_BV',175,'A','BAR'),(520,'Hot Chocolate','CAT_BV',155,'A','BAR');
/*!40000 ALTER TABLE `menu_catalog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_specification_addons`
--

DROP TABLE IF EXISTS `product_specification_addons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_specification_addons` (
  `custom_id` bigint NOT NULL AUTO_INCREMENT,
  `entry_id` int NOT NULL,
  `modifier_code` varchar(50) NOT NULL,
  `modifier_label` varchar(255) NOT NULL,
  `upcharge_price` double DEFAULT NULL,
  PRIMARY KEY (`custom_id`),
  KEY `fk_line_entry` (`entry_id`),
  CONSTRAINT `fk_line_entry` FOREIGN KEY (`entry_id`) REFERENCES `production_line_items` (`entry_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_specification_addons`
--

LOCK TABLES `product_specification_addons` WRITE;
/*!40000 ALTER TABLE `product_specification_addons` DISABLE KEYS */;
INSERT INTO `product_specification_addons` VALUES (1,1,'M01','Extra Cheese',50),(2,1,'M17','Jalapenos',30),(3,2,'M13','Gift Wrap Box',45),(4,3,'M02','Oat Milk Swap',65),(5,5,'M09','Basil Pesto Drizzle',35),(6,6,'M14','Birthday Candle',10),(7,7,'M08','Vegan Cheese',80),(8,8,'M19','Honey Drizzle',20),(9,9,'M10','Caramel Drizzle',25),(10,10,'M07','Gluten Free Crust',120),(11,11,'M04','Sugar Free Syrup',40),(12,12,'M06','Whipped Cream',30),(13,14,'M15','Personalized Note',15),(14,15,'M11','Chocolate Chips',30),(15,16,'M20','Butter Dip',25),(16,17,'M05','Extra Shot Espresso',45),(17,18,'M16','Double Patty',90),(18,19,'M12','Walnuts',55),(19,20,'M10','Caramel Drizzle',25),(20,4,'M13','Eco-Friendly Box',10),(21,24,'M1','Extra Cheese',20),(22,24,'M1','Extra Cheese',20);
/*!40000 ALTER TABLE `product_specification_addons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `production_line_items`
--

DROP TABLE IF EXISTS `production_line_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `production_line_items` (
  `entry_id` int NOT NULL AUTO_INCREMENT,
  `manifest_id` int NOT NULL,
  `product_sku` varchar(50) NOT NULL,
  `item_description` varchar(255) NOT NULL,
  `menu_category` varchar(100) DEFAULT NULL,
  `receive_qty` int NOT NULL,
  `dispatch_qty` int DEFAULT NULL,
  `unit_base_price` double DEFAULT NULL,
  `gross_line_total` double DEFAULT NULL,
  `tax_data_json` text,
  PRIMARY KEY (`entry_id`),
  KEY `fk_manifest_header` (`manifest_id`),
  CONSTRAINT `fk_manifest_header` FOREIGN KEY (`manifest_id`) REFERENCES `factory_order_manifests` (`manifest_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `production_line_items`
--

LOCK TABLES `production_line_items` WRITE;
/*!40000 ALTER TABLE `production_line_items` DISABLE KEYS */;
INSERT INTO `production_line_items` VALUES (1,1,'103','Margherita Pizza *Large','CAT_PZ',2,NULL,500,1050,'{\"CGST\": 25, \"SGST\": 25}'),(2,2,'107','Belgian Choco Cake *1kg','CAT_CK',1,NULL,2000,2180,'{\"CGST\": 90, \"SGST\": 90}'),(3,3,'105','Cappuccino *Grande','CAT_BV',1,NULL,185,194.25,'{\"CGST\": 4.6, \"SGST\": 4.6}'),(4,4,'101','Artisan Sourdough','CAT_BK',5,NULL,180,945,'{\"CGST\": 22.5, \"SGST\": 22.5}'),(5,5,'120','Cheese Garlic Bread','CAT_BK',3,NULL,140,441,'{\"CGST\": 10.5, \"SGST\": 10.5}'),(6,6,'116','Pineapple Cake *Full KG','CAT_CK',2,NULL,1450,3161,'{\"CGST\": 130, \"SGST\": 130}'),(7,7,'104','Farmhouse Veggie *Large','CAT_PZ',1,NULL,500,525,'{\"CGST\": 12.5, \"SGST\": 12.5}'),(8,8,'102','Butter Croissant','CAT_BK',10,NULL,120,1260,'{\"CGST\": 30, \"SGST\": 30}'),(9,9,'112','Vanilla Frappe *Jumbo','CAT_BV',2,NULL,250,525,'{\"CGST\": 12.5, \"SGST\": 12.5}'),(10,10,'111','Pepperoni Feast *Family','CAT_PZ',1,NULL,800,840,'{\"CGST\": 20, \"SGST\": 20}'),(11,11,'106','Cafe Latte *Tall','CAT_BV',1,NULL,200,210,'{\"CGST\": 5, \"SGST\": 5}'),(12,12,'109','Blueberry Muffin','CAT_BK',4,NULL,95,399,'{\"CGST\": 9.5, \"SGST\": 9.5}'),(13,13,'118','Paneer Patty','CAT_BK',6,NULL,75,472.5,'{\"CGST\": 11.25, \"SGST\": 11.25}'),(14,14,'119','Tiramisu Jar','CAT_CK',3,NULL,240,756,'{\"CGST\": 18, \"SGST\": 18}'),(15,15,'108','Red Velvet Slice','CAT_CK',4,NULL,160,672,'{\"CGST\": 16, \"SGST\": 16}'),(16,16,'113','Multigrain Loaf','CAT_BK',2,NULL,90,189,'{\"CGST\": 4.5, \"SGST\": 4.5}'),(17,17,'115','Matcha Latte *Hot','CAT_BV',1,NULL,180,189,'{\"CGST\": 4.5, \"SGST\": 4.5}'),(18,18,'117','Chicken Tikka Puff','CAT_BK',5,NULL,85,446.25,'{\"CGST\": 10.6, \"SGST\": 10.6}'),(19,19,'114','Chocolate Danish','CAT_BK',4,NULL,145,609,'{\"CGST\": 14.5, \"SGST\": 14.5}'),(20,20,'110','Iced Americano','CAT_BV',2,NULL,130,273,'{\"CGST\": 6.5, \"SGST\": 6.5}'),(21,21,'0','Tiramisu Jar',NULL,4,NULL,NULL,400,NULL),(22,22,'101','Artisan Sourdough (Large)',NULL,1,NULL,NULL,230,NULL),(23,22,'101','Artisan Sourdough (Regular)',NULL,1,NULL,NULL,180,NULL),(24,22,'101','Artisan Sourdough',NULL,1,NULL,NULL,220,NULL),(25,23,'113','Multigrain Loaf',NULL,1,NULL,NULL,NULL,NULL),(26,24,'MOCK','12x Croissant',NULL,1,NULL,NULL,NULL,NULL),(27,25,'109','Blueberry Muffin',NULL,1,NULL,NULL,203.5,NULL),(28,26,'MOCK','25x Baguette',NULL,1,NULL,NULL,3750,NULL),(29,27,'MOCK','15x Croissant',NULL,1,NULL,NULL,2700,NULL),(30,28,'509','Paneer Patty',NULL,1,NULL,NULL,143,NULL),(31,28,'501','Margherita Classic',NULL,1,NULL,NULL,451,NULL);
/*!40000 ALTER TABLE `production_line_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tax_rules`
--

DROP TABLE IF EXISTS `tax_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tax_rules` (
  `rule_code` varchar(50) NOT NULL,
  `label` varchar(50) NOT NULL,
  `percentage` double DEFAULT NULL,
  `indicator_group` varchar(10) NOT NULL,
  PRIMARY KEY (`rule_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tax_rules`
--

LOCK TABLES `tax_rules` WRITE;
/*!40000 ALTER TABLE `tax_rules` DISABLE KEYS */;
INSERT INTO `tax_rules` VALUES ('CGST_2.5','CGST',2.5,'A'),('CGST_6','CGST',6,'B'),('CGST_9','CGST',9,'C'),('GST_C','CGST',2.5,'A'),('GST_S','SGST',2.5,'A'),('SGST_2.5','SGST',2.5,'A'),('SGST_6','SGST',6,'B'),('SGST_9','SGST',9,'C');
/*!40000 ALTER TABLE `tax_rules` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-11  0:33:53
