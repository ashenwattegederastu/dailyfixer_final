-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: dailyfixer_main
-- ------------------------------------------------------
-- Server version	8.0.43

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
-- Table structure for table `access_permissions`
--

DROP TABLE IF EXISTS `access_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `access_permissions` (
  `permission_id` int NOT NULL AUTO_INCREMENT,
  `volunteer_id` int NOT NULL,
  `resource_type` enum('DIAGNOSTIC_TREE','OTHER') DEFAULT 'DIAGNOSTIC_TREE',
  `access_level` enum('VIEW','SUGGEST','EDIT','APPROVE') DEFAULT 'VIEW',
  `granted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`permission_id`),
  KEY `volunteer_id` (`volunteer_id`),
  CONSTRAINT `access_permissions_ibfk_1` FOREIGN KEY (`volunteer_id`) REFERENCES `volunteers` (`volunteer_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `badges`
--

DROP TABLE IF EXISTS `badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `badges` (
  `badge_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `icon` varchar(50) DEFAULT NULL,
  `required_score` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`badge_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bank_details`
--

DROP TABLE IF EXISTS `bank_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bank_details` (
  `bank_detail_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `bank_name` varchar(100) NOT NULL,
  `branch` varchar(100) DEFAULT NULL,
  `account_number` varchar(30) NOT NULL,
  `account_holder_name` varchar(150) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`bank_detail_id`),
  UNIQUE KEY `uq_bank_user` (`user_id`),
  CONSTRAINT `fk_bank_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_cancellations`
--

DROP TABLE IF EXISTS `booking_cancellations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking_cancellations` (
  `cancellation_id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `cancelled_by` int NOT NULL,
  `cancellation_reason` text NOT NULL,
  `cancelled_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`cancellation_id`),
  KEY `idx_booking` (`booking_id`),
  KEY `idx_cancelled_by` (`cancelled_by`),
  CONSTRAINT `fk_cancellation_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cancellation_user` FOREIGN KEY (`cancelled_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_no_shows`
--

DROP TABLE IF EXISTS `booking_no_shows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking_no_shows` (
  `no_show_id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `technician_id` int NOT NULL,
  `scheduled_at` datetime NOT NULL,
  `detected_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `notes` text,
  PRIMARY KEY (`no_show_id`),
  UNIQUE KEY `uq_ns_booking` (`booking_id`),
  KEY `idx_ns_tech` (`technician_id`),
  CONSTRAINT `fk_ns_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ns_tech` FOREIGN KEY (`technician_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_notifications`
--

DROP TABLE IF EXISTS `booking_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking_notifications` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `booking_id` int NOT NULL,
  `message` varchar(500) NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `idx_bn_user` (`user_id`),
  KEY `idx_bn_booking` (`booking_id`),
  KEY `idx_bn_read` (`is_read`),
  CONSTRAINT `fk_bn_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bn_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_ratings`
--

DROP TABLE IF EXISTS `booking_ratings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking_ratings` (
  `rating_id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `rated_by` int NOT NULL,
  `rated_user` int NOT NULL,
  `rating_type` enum('TECHNICIAN_RATING','CLIENT_RATING') NOT NULL,
  `rating` tinyint NOT NULL,
  `review` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`rating_id`),
  UNIQUE KEY `uq_booking_rating_type` (`booking_id`,`rating_type`),
  KEY `fk_br_rated_by` (`rated_by`),
  KEY `fk_br_rated_user` (`rated_user`),
  CONSTRAINT `fk_br_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_br_rated_by` FOREIGN KEY (`rated_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_br_rated_user` FOREIGN KEY (`rated_user`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `booking_ratings_chk_1` CHECK ((`rating` between 1 and 5))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `booking_reschedule_requests`
--

DROP TABLE IF EXISTS `booking_reschedule_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `booking_reschedule_requests` (
  `reschedule_id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `requested_by` int NOT NULL,
  `new_date` date NOT NULL,
  `new_time` time NOT NULL,
  `reason` text,
  `status` enum('PENDING','ACCEPTED','REJECTED') NOT NULL DEFAULT 'PENDING',
  `responded_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reschedule_id`),
  KEY `idx_rr_booking` (`booking_id`),
  KEY `idx_rr_status` (`status`),
  KEY `fk_rr_requester` (`requested_by`),
  CONSTRAINT `fk_rr_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rr_requester` FOREIGN KEY (`requested_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookings` (
  `booking_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `technician_id` int NOT NULL,
  `service_id` int NOT NULL,
  `booking_date` date NOT NULL,
  `booking_time` time NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `problem_description` text NOT NULL,
  `location_address` varchar(255) NOT NULL,
  `location_latitude` decimal(10,8) DEFAULT NULL,
  `location_longitude` decimal(11,8) DEFAULT NULL,
  `status` enum('REQUESTED','ACCEPTED','REJECTED','CANCELLED','IN_PROGRESS','TECHNICIAN_COMPLETED','FULLY_COMPLETED','NO_SHOW','RESCHEDULE_PENDING','AUTO_REJECTED','CLIENT_NO_SHOW') NOT NULL DEFAULT 'REQUESTED',
  `rejection_reason` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `recurring_contract_id` int DEFAULT NULL,
  `recurring_sequence` tinyint DEFAULT NULL COMMENT '1-12, which month in the contract',
  PRIMARY KEY (`booking_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_technician` (`technician_id`),
  KEY `idx_service` (`service_id`),
  KEY `idx_status` (`status`),
  KEY `idx_booking_date` (`booking_date`),
  KEY `idx_recurring_contract` (`recurring_contract_id`),
  CONSTRAINT `fk_booking_contract` FOREIGN KEY (`recurring_contract_id`) REFERENCES `recurring_contracts` (`contract_id`),
  CONSTRAINT `fk_booking_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`service_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_booking_technician` FOREIGN KEY (`technician_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_booking_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chat_conversations`
--

DROP TABLE IF EXISTS `chat_conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_conversations` (
  `conversation_id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `user_id` int NOT NULL,
  `technician_id` int NOT NULL,
  `last_message_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`conversation_id`),
  UNIQUE KEY `unique_booking_conversation` (`booking_id`),
  KEY `idx_conversations_user` (`user_id`),
  KEY `idx_conversations_technician` (`technician_id`),
  CONSTRAINT `fk_conversations_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_conversations_technician` FOREIGN KEY (`technician_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_conversations_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chat_messages`
--

DROP TABLE IF EXISTS `chat_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_messages` (
  `message_id` int NOT NULL AUTO_INCREMENT,
  `chat_id` int NOT NULL,
  `sender_id` int NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`message_id`),
  KEY `idx_chat` (`chat_id`),
  KEY `fk_message_sender` (`sender_id`),
  CONSTRAINT `fk_message_chat` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`chat_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_message_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chats`
--

DROP TABLE IF EXISTS `chats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `chats` (
  `chat_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `technician_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`chat_id`),
  UNIQUE KEY `unique_user_tech` (`user_id`,`technician_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_technician` (`technician_id`),
  CONSTRAINT `fk_chat_technician` FOREIGN KEY (`technician_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_chat_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `client_no_show_penalties`
--

DROP TABLE IF EXISTS `client_no_show_penalties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `client_no_show_penalties` (
  `penalty_id` int NOT NULL AUTO_INCREMENT,
  `booking_id` int NOT NULL,
  `client_id` int NOT NULL,
  `technician_id` int NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT '2500.00',
  `status` enum('PENDING','PROOF_UPLOADED','CONFIRMED_PAID','ADMIN_REVIEW','RESOLVED','FRAUD_SUSPENDED') NOT NULL DEFAULT 'PENDING',
  `tech_proof_path` varchar(500) DEFAULT NULL COMMENT 'Technician arrival proof photo (required when marking client not home)',
  `proof_path` varchar(500) DEFAULT NULL,
  `proof_uploaded_at` timestamp NULL DEFAULT NULL,
  `tech_action` enum('CONFIRMED_PAID','MARKED_NOT_PAID') DEFAULT NULL,
  `tech_action_at` timestamp NULL DEFAULT NULL,
  `admin_action` enum('MARK_PAID','SUSPEND_CLIENT') DEFAULT NULL,
  `admin_action_at` timestamp NULL DEFAULT NULL,
  `admin_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`penalty_id`),
  UNIQUE KEY `uq_cnsp_booking` (`booking_id`),
  KEY `idx_cnsp_client` (`client_id`),
  KEY `idx_cnsp_technician` (`technician_id`),
  KEY `idx_cnsp_status` (`status`),
  CONSTRAINT `fk_cnsp_booking` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`booking_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cnsp_client` FOREIGN KEY (`client_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cnsp_technician` FOREIGN KEY (`technician_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `deleted_users`
--

DROP TABLE IF EXISTS `deleted_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `deleted_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `username` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `role` varchar(20) DEFAULT NULL,
  `deleted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delivery_assignments`
--

DROP TABLE IF EXISTS `delivery_assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_assignments` (
  `assignment_id` int NOT NULL AUTO_INCREMENT,
  `order_id` varchar(50) NOT NULL,
  `store_id` int NOT NULL,
  `driver_id` int DEFAULT NULL,
  `required_vehicle_type` varchar(50) NOT NULL,
  `delivery_fee_earned` decimal(10,2) NOT NULL DEFAULT '0.00',
  `pickup_address` varchar(255) DEFAULT NULL,
  `delivery_address` text,
  `delivery_lat` decimal(10,7) DEFAULT NULL,
  `delivery_lng` decimal(11,7) DEFAULT NULL,
  `delivery_pin` char(6) DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'PENDING',
  `completion_method` varchar(24) DEFAULT NULL,
  `assigned_at` timestamp NULL DEFAULT NULL,
  `picked_up_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `driver_payout_id` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`assignment_id`),
  UNIQUE KEY `uq_da_order` (`order_id`),
  KEY `idx_da_status` (`status`),
  KEY `idx_da_driver` (`driver_id`),
  KEY `idx_da_store` (`store_id`),
  CONSTRAINT `fk_da_driver` FOREIGN KEY (`driver_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL,
  CONSTRAINT `fk_da_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_da_store` FOREIGN KEY (`store_id`) REFERENCES `stores` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delivery_drop_proofs`
--

DROP TABLE IF EXISTS `delivery_drop_proofs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_drop_proofs` (
  `proof_id` int NOT NULL AUTO_INCREMENT,
  `assignment_id` int NOT NULL,
  `order_id` varchar(50) NOT NULL,
  `driver_id` int NOT NULL,
  `photo_package_path` varchar(255) NOT NULL,
  `photo_door_context_path` varchar(255) NOT NULL,
  `note` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`proof_id`),
  UNIQUE KEY `uq_ddp_assignment` (`assignment_id`),
  KEY `idx_ddp_order` (`order_id`),
  KEY `idx_ddp_driver` (`driver_id`),
  CONSTRAINT `fk_ddp_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `delivery_assignments` (`assignment_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ddp_driver` FOREIGN KEY (`driver_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ddp_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delivery_rates`
--

DROP TABLE IF EXISTS `delivery_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_rates` (
  `rate_id` int NOT NULL AUTO_INCREMENT,
  `vehicle_type` varchar(50) NOT NULL,
  `cost_per_km` decimal(10,2) NOT NULL,
  `base_fee` decimal(10,2) NOT NULL DEFAULT '100.00',
  `distribution_weight` decimal(5,2) NOT NULL DEFAULT '33.33' COMMENT 'Percentage weight used in weighted-average customer price (weights should sum to 100)',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `max_simultaneous_orders` int NOT NULL DEFAULT '3' COMMENT 'Max concurrent ACCEPTED+PICKED_UP orders a driver of this vehicle type can hold',
  PRIMARY KEY (`rate_id`),
  UNIQUE KEY `uq_vehicle_type` (`vehicle_type`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `delivery_requeue_events`
--

DROP TABLE IF EXISTS `delivery_requeue_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery_requeue_events` (
  `requeue_event_id` int NOT NULL AUTO_INCREMENT,
  `assignment_id` int NOT NULL,
  `order_id` varchar(50) NOT NULL,
  `actor_driver_id` int NOT NULL,
  `reason_code` enum('NOT_ENOUGH_SPACE','EMERGENCY','VEHICLE_ISSUE','OTHER') NOT NULL,
  `reason_note` varchar(400) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`requeue_event_id`),
  KEY `idx_dre_assignment` (`assignment_id`),
  KEY `idx_dre_driver` (`actor_driver_id`),
  KEY `idx_dre_created_at` (`created_at`),
  CONSTRAINT `fk_dre_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `delivery_assignments` (`assignment_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_dre_driver` FOREIGN KEY (`actor_driver_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `diagnostic_categories`
--

DROP TABLE IF EXISTS `diagnostic_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `diagnostic_categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `parent_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  KEY `parent_id` (`parent_id`),
  CONSTRAINT `diagnostic_categories_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `diagnostic_categories` (`category_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `diagnostic_nodes`
--

DROP TABLE IF EXISTS `diagnostic_nodes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `diagnostic_nodes` (
  `node_id` int NOT NULL AUTO_INCREMENT,
  `tree_id` int NOT NULL,
  `parent_id` int DEFAULT NULL,
  `node_text` text NOT NULL,
  `option_label` varchar(255) DEFAULT NULL,
  `node_type` enum('QUESTION','RESULT') NOT NULL DEFAULT 'QUESTION',
  `display_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`node_id`),
  KEY `idx_nodes_tree` (`tree_id`),
  KEY `idx_nodes_parent` (`parent_id`),
  CONSTRAINT `diagnostic_nodes_ibfk_1` FOREIGN KEY (`tree_id`) REFERENCES `diagnostic_trees` (`tree_id`) ON DELETE CASCADE,
  CONSTRAINT `diagnostic_nodes_ibfk_2` FOREIGN KEY (`parent_id`) REFERENCES `diagnostic_nodes` (`node_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `diagnostic_ratings`
--

DROP TABLE IF EXISTS `diagnostic_ratings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `diagnostic_ratings` (
  `rating_id` int NOT NULL AUTO_INCREMENT,
  `tree_id` int NOT NULL,
  `user_id` int NOT NULL,
  `rating` tinyint NOT NULL,
  `feedback` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`rating_id`),
  UNIQUE KEY `unique_user_tree_rating` (`tree_id`,`user_id`),
  KEY `user_id` (`user_id`),
  KEY `idx_ratings_tree` (`tree_id`),
  CONSTRAINT `diagnostic_ratings_ibfk_1` FOREIGN KEY (`tree_id`) REFERENCES `diagnostic_trees` (`tree_id`) ON DELETE CASCADE,
  CONSTRAINT `diagnostic_ratings_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `diagnostic_ratings_chk_1` CHECK (((`rating` >= 1) and (`rating` <= 5)))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `diagnostic_trees`
--

DROP TABLE IF EXISTS `diagnostic_trees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `diagnostic_trees` (
  `tree_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text,
  `category_id` int NOT NULL,
  `creator_id` int NOT NULL,
  `status` enum('draft','published') DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`tree_id`),
  KEY `idx_trees_category` (`category_id`),
  KEY `idx_trees_creator` (`creator_id`),
  KEY `idx_trees_status` (`status`),
  CONSTRAINT `diagnostic_trees_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `diagnostic_categories` (`category_id`) ON DELETE RESTRICT,
  CONSTRAINT `diagnostic_trees_ibfk_2` FOREIGN KEY (`creator_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `discount_products`
--

DROP TABLE IF EXISTS `discount_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `discount_products` (
  `discount_id` int NOT NULL,
  `product_id` int NOT NULL,
  PRIMARY KEY (`discount_id`,`product_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `discount_products_ibfk_1` FOREIGN KEY (`discount_id`) REFERENCES `discounts` (`discount_id`) ON DELETE CASCADE,
  CONSTRAINT `discount_products_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `discount_variants`
--

DROP TABLE IF EXISTS `discount_variants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `discount_variants` (
  `discount_id` int NOT NULL,
  `variant_id` int NOT NULL,
  PRIMARY KEY (`discount_id`,`variant_id`),
  KEY `variant_id` (`variant_id`),
  CONSTRAINT `discount_variants_ibfk_1` FOREIGN KEY (`discount_id`) REFERENCES `discounts` (`discount_id`) ON DELETE CASCADE,
  CONSTRAINT `discount_variants_ibfk_2` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`variant_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `discounts`
--

DROP TABLE IF EXISTS `discounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `discounts` (
  `discount_id` int NOT NULL AUTO_INCREMENT,
  `discount_name` varchar(255) NOT NULL,
  `discount_type` enum('PERCENTAGE','FIXED') NOT NULL,
  `discount_value` decimal(10,2) NOT NULL,
  `start_date` timestamp NULL DEFAULT NULL,
  `end_date` timestamp NULL DEFAULT NULL,
  `store_username` varchar(255) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`discount_id`),
  KEY `store_username` (`store_username`),
  CONSTRAINT `discounts_ibfk_1` FOREIGN KEY (`store_username`) REFERENCES `users` (`username`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `driver_incidents`
--

DROP TABLE IF EXISTS `driver_incidents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `driver_incidents` (
  `incident_id` int NOT NULL AUTO_INCREMENT,
  `driver_id` int NOT NULL,
  `assignment_id` int NOT NULL,
  `order_id` varchar(50) NOT NULL,
  `incident_type` enum('PICKUP_NO_DELIVERY','ACCEPT_NO_PICKUP') NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `reviewed` tinyint(1) NOT NULL DEFAULT '0',
  `reviewed_by` int DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `review_notes` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`incident_id`),
  KEY `driver_id` (`driver_id`),
  KEY `assignment_id` (`assignment_id`),
  CONSTRAINT `driver_incidents_ibfk_1` FOREIGN KEY (`driver_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `driver_incidents_ibfk_2` FOREIGN KEY (`assignment_id`) REFERENCES `delivery_assignments` (`assignment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `driver_requests`
--

DROP TABLE IF EXISTS `driver_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `driver_requests` (
  `request_id` int NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `city` varchar(50) DEFAULT NULL,
  `nic_number` varchar(20) NOT NULL,
  `nic_front_path` varchar(255) NOT NULL,
  `nic_back_path` varchar(255) NOT NULL,
  `profile_picture_path` varchar(255) NOT NULL,
  `license_front_path` varchar(255) NOT NULL,
  `license_back_path` varchar(255) DEFAULT NULL,
  `policy_accepted` tinyint(1) NOT NULL DEFAULT '0',
  `status` enum('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  `rejection_reason` text,
  `submitted_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `reviewed_date` timestamp NULL DEFAULT NULL,
  `reviewed_by` int DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  UNIQUE KEY `uq_dr_username` (`username`),
  UNIQUE KEY `uq_dr_email` (`email`),
  KEY `idx_dr_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `guide_categories`
--

DROP TABLE IF EXISTS `guide_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guide_categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `guide_comments`
--

DROP TABLE IF EXISTS `guide_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guide_comments` (
  `comment_id` int NOT NULL AUTO_INCREMENT,
  `guide_id` int NOT NULL,
  `user_id` int NOT NULL,
  `comment` text NOT NULL,
  `reply` text,
  `reply_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`comment_id`),
  KEY `guide_id` (`guide_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `guide_comments_ibfk_1` FOREIGN KEY (`guide_id`) REFERENCES `guides` (`guide_id`) ON DELETE CASCADE,
  CONSTRAINT `guide_comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `guide_flags`
--

DROP TABLE IF EXISTS `guide_flags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guide_flags` (
  `flag_id` int NOT NULL AUTO_INCREMENT,
  `guide_id` int NOT NULL,
  `user_id` int NOT NULL,
  `reason` enum('INACCURATE','OUTDATED','INAPPROPRIATE','SPAM','OTHER') NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`flag_id`),
  UNIQUE KEY `unique_flag` (`guide_id`,`user_id`),
  KEY `idx_guide_flags_guide` (`guide_id`),
  KEY `idx_guide_flags_user` (`user_id`),
  CONSTRAINT `guide_flags_ibfk_1` FOREIGN KEY (`guide_id`) REFERENCES `guides` (`guide_id`) ON DELETE CASCADE,
  CONSTRAINT `guide_flags_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `guide_moderation_log`
--

DROP TABLE IF EXISTS `guide_moderation_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guide_moderation_log` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `guide_id` int NOT NULL,
  `admin_id` int NOT NULL,
  `action` enum('HIDDEN','DISMISSED','UNHIDDEN') NOT NULL,
  `reason` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `admin_id` (`admin_id`),
  KEY `idx_guide_mod_log_guide` (`guide_id`),
  CONSTRAINT `guide_moderation_log_ibfk_1` FOREIGN KEY (`guide_id`) REFERENCES `guides` (`guide_id`) ON DELETE CASCADE,
  CONSTRAINT `guide_moderation_log_ibfk_2` FOREIGN KEY (`admin_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `guide_ratings`
--

DROP TABLE IF EXISTS `guide_ratings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guide_ratings` (
  `rating_id` int NOT NULL AUTO_INCREMENT,
  `guide_id` int NOT NULL,
  `user_id` int NOT NULL,
  `rating` enum('UP','DOWN') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`rating_id`),
  UNIQUE KEY `unique_rating` (`guide_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `guide_ratings_ibfk_1` FOREIGN KEY (`guide_id`) REFERENCES `guides` (`guide_id`) ON DELETE CASCADE,
  CONSTRAINT `guide_ratings_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `guide_requirements`
--

DROP TABLE IF EXISTS `guide_requirements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guide_requirements` (
  `req_id` int NOT NULL AUTO_INCREMENT,
  `guide_id` int NOT NULL,
  `requirement` varchar(500) NOT NULL,
  PRIMARY KEY (`req_id`),
  KEY `guide_id` (`guide_id`),
  CONSTRAINT `guide_requirements_ibfk_1` FOREIGN KEY (`guide_id`) REFERENCES `guides` (`guide_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `guide_step_images`
--

DROP TABLE IF EXISTS `guide_step_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guide_step_images` (
  `image_id` int NOT NULL AUTO_INCREMENT,
  `step_id` int NOT NULL,
  `image_path` varchar(255) NOT NULL,
  PRIMARY KEY (`image_id`),
  KEY `step_id` (`step_id`),
  CONSTRAINT `guide_step_images_ibfk_1` FOREIGN KEY (`step_id`) REFERENCES `guide_steps` (`step_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `guide_steps`
--

DROP TABLE IF EXISTS `guide_steps`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guide_steps` (
  `step_id` int NOT NULL AUTO_INCREMENT,
  `guide_id` int NOT NULL,
  `step_order` int NOT NULL,
  `step_title` varchar(255) NOT NULL,
  `step_body` text,
  PRIMARY KEY (`step_id`),
  KEY `guide_id` (`guide_id`),
  CONSTRAINT `guide_steps_ibfk_1` FOREIGN KEY (`guide_id`) REFERENCES `guides` (`guide_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `guide_sub_categories`
--

DROP TABLE IF EXISTS `guide_sub_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guide_sub_categories` (
  `sub_category_id` int NOT NULL AUTO_INCREMENT,
  `category_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`sub_category_id`),
  UNIQUE KEY `unique_sub` (`category_id`,`name`),
  KEY `idx_sub_cat_parent` (`category_id`),
  CONSTRAINT `guide_sub_categories_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `guide_categories` (`category_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `guides`
--

DROP TABLE IF EXISTS `guides`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `guides` (
  `guide_id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `main_image_path` varchar(255) DEFAULT NULL,
  `main_category` varchar(100) NOT NULL,
  `sub_category` varchar(100) NOT NULL,
  `youtube_url` varchar(255) DEFAULT NULL,
  `created_by` int NOT NULL,
  `created_role` enum('admin','volunteer','technician') NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `view_count` int DEFAULT '0',
  `status` enum('ACTIVE','HIDDEN','PENDING_REVIEW') NOT NULL DEFAULT 'ACTIVE',
  `hide_reason` varchar(500) DEFAULT NULL,
  `hidden_at` timestamp NULL DEFAULT NULL,
  `hidden_by` int DEFAULT NULL,
  PRIMARY KEY (`guide_id`),
  KEY `idx_guides_category` (`main_category`,`sub_category`),
  KEY `idx_guides_created_by` (`created_by`),
  KEY `idx_guides_status` (`status`),
  CONSTRAINT `guides_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` varchar(50) NOT NULL,
  `store_id` int NOT NULL,
  `product_id` int DEFAULT NULL,
  `variant_id` int DEFAULT NULL,
  `product_name` varchar(150) DEFAULT NULL,
  `quantity` int DEFAULT '1',
  `unit_price` decimal(10,2) DEFAULT NULL,
  `total_price` decimal(10,2) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'PENDING',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `store_id` (`store_id`),
  KEY `product_id` (`product_id`),
  KEY `variant_id` (`variant_id`),
  CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`store_id`) REFERENCES `stores` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `order_items_ibfk_3` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE SET NULL,
  CONSTRAINT `order_items_ibfk_4` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`variant_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` varchar(50) NOT NULL,
  `customer_name` varchar(200) DEFAULT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text,
  `city` varchar(100) DEFAULT NULL,
  `product_name` varchar(500) DEFAULT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `delivery_fee` decimal(10,2) NOT NULL DEFAULT '0.00',
  `currency` varchar(10) DEFAULT 'LKR',
  `status` varchar(20) DEFAULT 'PENDING',
  `store_username` varchar(100) DEFAULT NULL,
  `store_id` int DEFAULT NULL,
  `payhere_payment_id` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `buyer_id` int DEFAULT NULL,
  `refund_reason` varchar(500) DEFAULT NULL,
  `refund_number` varchar(50) DEFAULT NULL,
  `refunded_at` timestamp NULL DEFAULT NULL,
  `delivery_latitude` decimal(10,7) DEFAULT NULL,
  `delivery_longitude` decimal(11,7) DEFAULT NULL,
  `doorstep_drop_consent` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_id` (`order_id`),
  KEY `fk_orders_store` (`store_id`),
  CONSTRAINT `fk_orders_store` FOREIGN KEY (`store_id`) REFERENCES `stores` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `token` varchar(255) NOT NULL,
  `expiry` timestamp NOT NULL,
  `used` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `password_reset_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payout_line_items`
--

DROP TABLE IF EXISTS `payout_line_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payout_line_items` (
  `line_item_id` int NOT NULL AUTO_INCREMENT,
  `payout_id` int NOT NULL,
  `source_type` enum('STORE_ORDER','DELIVERY') NOT NULL,
  `source_id` int NOT NULL COMMENT 'store_order_id or assignment_id',
  `amount` decimal(12,2) NOT NULL,
  PRIMARY KEY (`line_item_id`),
  KEY `idx_pli_payout` (`payout_id`),
  KEY `idx_pli_source` (`source_type`,`source_id`),
  CONSTRAINT `fk_pli_payout` FOREIGN KEY (`payout_id`) REFERENCES `payouts` (`payout_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payouts`
--

DROP TABLE IF EXISTS `payouts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payouts` (
  `payout_id` int NOT NULL AUTO_INCREMENT,
  `payee_type` enum('STORE','DRIVER') NOT NULL,
  `payee_id` int NOT NULL COMMENT 'store_id for STORE, user_id for DRIVER',
  `amount` decimal(12,2) NOT NULL,
  `status` enum('PENDING','PROCESSING','COMPLETED') NOT NULL DEFAULT 'PENDING',
  `locked_by_admin_id` int DEFAULT NULL,
  `receipt_image_path` varchar(255) DEFAULT NULL,
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`payout_id`),
  KEY `idx_payouts_status` (`status`),
  KEY `idx_payouts_payee` (`payee_type`,`payee_id`),
  KEY `idx_payouts_admin` (`locked_by_admin_id`),
  CONSTRAINT `fk_payout_admin` FOREIGN KEY (`locked_by_admin_id`) REFERENCES `users` (`user_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `product_reviews`
--

DROP TABLE IF EXISTS `product_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_reviews` (
  `review_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `user_id` int NOT NULL,
  `rating` int NOT NULL,
  `comment` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  UNIQUE KEY `unique_user_product_review` (`user_id`,`product_id`),
  KEY `idx_product_reviews_product` (`product_id`),
  KEY `idx_product_reviews_user` (`user_id`),
  KEY `idx_product_reviews_created` (`created_at`),
  CONSTRAINT `product_reviews_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE,
  CONSTRAINT `product_reviews_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `product_reviews_chk_1` CHECK (((`rating` >= 1) and (`rating` <= 5)))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `product_variants`
--

DROP TABLE IF EXISTS `product_variants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_variants` (
  `variant_id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `color` varchar(50) DEFAULT NULL,
  `size` varchar(50) DEFAULT NULL,
  `power` varchar(50) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `quantity` int NOT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`variant_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `product_variants_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `product_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `type` varchar(50) NOT NULL,
  `quantity` int NOT NULL,
  `quantity_unit` enum('No of items','Litres','Kg','Metres') NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `description` text,
  `image_path` varchar(255) DEFAULT NULL,
  `warranty_info` varchar(500) DEFAULT NULL,
  `store_username` varchar(50) NOT NULL,
  `store_id` int DEFAULT NULL,
  PRIMARY KEY (`product_id`),
  KEY `fk_products_store` (`store_id`),
  CONSTRAINT `fk_products_store` FOREIGN KEY (`store_id`) REFERENCES `stores` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `recurring_contracts`
--

DROP TABLE IF EXISTS `recurring_contracts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recurring_contracts` (
  `contract_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `technician_id` int NOT NULL,
  `service_id` int NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `booking_day_of_month` tinyint NOT NULL COMMENT 'Day 1-28 that repeats each month',
  `recurring_fee` decimal(10,2) NOT NULL COMMENT 'Snapshot of fee at time of contract',
  `status` enum('PENDING','ACTIVE','CANCELLED','COMPLETED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDING',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`contract_id`),
  KEY `idx_rc_user` (`user_id`),
  KEY `idx_rc_technician` (`technician_id`),
  KEY `idx_rc_service` (`service_id`),
  KEY `idx_rc_status` (`status`),
  CONSTRAINT `fk_rc_service` FOREIGN KEY (`service_id`) REFERENCES `services` (`service_id`),
  CONSTRAINT `fk_rc_technician` FOREIGN KEY (`technician_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `fk_rc_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `service_categories`
--

DROP TABLE IF EXISTS `service_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_categories` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `services`
--

DROP TABLE IF EXISTS `services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `services` (
  `service_id` int NOT NULL AUTO_INCREMENT,
  `technician_id` int NOT NULL,
  `service_name` varchar(100) NOT NULL,
  `description` text,
  `category` varchar(50) DEFAULT NULL,
  `pricing_type` enum('fixed','hourly') NOT NULL,
  `fixed_rate` decimal(10,2) DEFAULT NULL,
  `hourly_rate` decimal(10,2) DEFAULT NULL,
  `inspection_charge` decimal(10,2) DEFAULT NULL,
  `transport_charge` decimal(10,2) DEFAULT NULL,
  `available_dates` text,
  `service_image` longblob,
  `image_type` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `recurring_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `recurring_fee` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`service_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `store_orders`
--

DROP TABLE IF EXISTS `store_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `store_orders` (
  `store_order_id` int NOT NULL AUTO_INCREMENT,
  `order_id` varchar(50) NOT NULL,
  `store_id` int NOT NULL,
  `store_total` decimal(10,2) NOT NULL,
  `delivery_fee` decimal(10,2) NOT NULL DEFAULT '0.00',
  `commission` decimal(10,2) DEFAULT '0.00',
  `payable_amount` decimal(10,2) NOT NULL,
  `status` enum('PENDING','PAID','CANCELLED','REFUNDED') DEFAULT 'PENDING',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`store_order_id`),
  KEY `fk_store_orders_order` (`order_id`),
  KEY `fk_store_orders_store` (`store_id`),
  CONSTRAINT `fk_store_orders_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_store_orders_store` FOREIGN KEY (`store_id`) REFERENCES `stores` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `stores`
--

DROP TABLE IF EXISTS `stores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stores` (
  `store_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `store_name` varchar(150) NOT NULL,
  `store_address` varchar(255) NOT NULL,
  `store_city` varchar(50) NOT NULL,
  `store_type` enum('electronics','hardware','vehicle repair','other') DEFAULT 'other',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  PRIMARY KEY (`store_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `stores_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `technician_availability`
--

DROP TABLE IF EXISTS `technician_availability`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `technician_availability` (
  `availability_id` int NOT NULL AUTO_INCREMENT,
  `technician_id` int NOT NULL,
  `availability_mode` enum('WEEKDAYS','WEEKENDS','CUSTOM') NOT NULL DEFAULT 'WEEKDAYS',
  `monday` tinyint(1) DEFAULT '0',
  `tuesday` tinyint(1) DEFAULT '0',
  `wednesday` tinyint(1) DEFAULT '0',
  `thursday` tinyint(1) DEFAULT '0',
  `friday` tinyint(1) DEFAULT '0',
  `saturday` tinyint(1) DEFAULT '0',
  `sunday` tinyint(1) DEFAULT '0',
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`availability_id`),
  KEY `idx_technician` (`technician_id`),
  CONSTRAINT `fk_availability_technician` FOREIGN KEY (`technician_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `technician_daily_limits`
--

DROP TABLE IF EXISTS `technician_daily_limits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `technician_daily_limits` (
  `limit_id` int NOT NULL AUTO_INCREMENT,
  `technician_id` int NOT NULL,
  `max_bookings_per_day` int NOT NULL DEFAULT '5',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`limit_id`),
  UNIQUE KEY `uq_tdl_tech` (`technician_id`),
  CONSTRAINT `fk_tdl_tech` FOREIGN KEY (`technician_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `technician_penalty_log`
--

DROP TABLE IF EXISTS `technician_penalty_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `technician_penalty_log` (
  `penalty_id` int NOT NULL AUTO_INCREMENT,
  `technician_id` int NOT NULL,
  `no_show_id` int NOT NULL COMMENT 'FK to booking_no_shows',
  `penalty_level` tinyint NOT NULL COMMENT '1=warning, 2=listing suppressed, 3=suspended',
  `issued_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` timestamp NULL DEFAULT NULL COMMENT 'NULL means indefinite (level 3)',
  `lifted_by` int DEFAULT NULL COMMENT 'admin user_id who lifted this penalty',
  `lifted_at` timestamp NULL DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`penalty_id`),
  KEY `idx_tpl_tech` (`technician_id`),
  KEY `idx_tpl_noshow` (`no_show_id`),
  CONSTRAINT `fk_tpl_ns` FOREIGN KEY (`no_show_id`) REFERENCES `booking_no_shows` (`no_show_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_tpl_tech` FOREIGN KEY (`technician_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `technician_request_files`
--

DROP TABLE IF EXISTS `technician_request_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `technician_request_files` (
  `file_id` int NOT NULL AUTO_INCREMENT,
  `request_id` int NOT NULL,
  `file_type` enum('QUALIFICATION','WORK_PROOF') NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `original_filename` varchar(255) DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`file_id`),
  KEY `idx_trf_request` (`request_id`),
  CONSTRAINT `fk_trf_request` FOREIGN KEY (`request_id`) REFERENCES `technician_requests` (`request_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `technician_requests`
--

DROP TABLE IF EXISTS `technician_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `technician_requests` (
  `request_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `city` varchar(50) DEFAULT NULL,
  `profile_picture_path` varchar(255) NOT NULL,
  `has_qualifications` tinyint(1) NOT NULL DEFAULT '0',
  `has_experience` tinyint(1) NOT NULL DEFAULT '0',
  `experience_company` varchar(150) DEFAULT NULL,
  `experience_role` varchar(100) DEFAULT NULL,
  `experience_years` int DEFAULT NULL,
  `emp_id_card_path` varchar(255) DEFAULT NULL,
  `emp_id_card_name` varchar(100) DEFAULT NULL,
  `status` enum('PENDING','APPROVED','REJECTED') NOT NULL DEFAULT 'PENDING',
  `rejection_reason` text,
  `submitted_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `reviewed_date` timestamp NULL DEFAULT NULL,
  `reviewed_by` int DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  UNIQUE KEY `uq_tr_username` (`username`),
  UNIQUE KEY `uq_tr_email` (`email`),
  KEY `idx_tr_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(11,7) DEFAULT NULL,
  `nic_number` varchar(20) DEFAULT NULL,
  `nic_front_path` varchar(255) DEFAULT NULL,
  `nic_back_path` varchar(255) DEFAULT NULL,
  `license_front_path` varchar(255) DEFAULT NULL,
  `license_back_path` varchar(255) DEFAULT NULL,
  `bio` text,
  `profile_picture_path` varchar(255) DEFAULT NULL,
  `role` enum('user','volunteer','technician','driver','store','admin') DEFAULT 'user',
  `status` enum('active','suspended') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vehicle_makes`
--

DROP TABLE IF EXISTS `vehicle_makes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicle_makes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category` varchar(50) NOT NULL,
  `make_name` varchar(100) NOT NULL,
  `is_custom` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_make` (`category`,`make_name`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vehicles`
--

DROP TABLE IF EXISTS `vehicles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vehicles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `driver_id` int NOT NULL,
  `vehicle_type` varchar(50) NOT NULL,
  `brand` varchar(50) NOT NULL,
  `model` varchar(50) NOT NULL,
  `plate_number` varchar(20) NOT NULL,
  `img_front` varchar(500) DEFAULT NULL,
  `img_left` varchar(500) DEFAULT NULL,
  `img_right` varchar(500) DEFAULT NULL,
  `img_back` varchar(500) DEFAULT NULL,
  `doc_registration` varchar(500) DEFAULT NULL,
  `doc_insurance` varchar(500) DEFAULT NULL,
  `doc_revenue` varchar(500) DEFAULT NULL,
  `vehicle_category` varchar(50) NOT NULL DEFAULT 'Bike',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_driver_vehicle` (`driver_id`),
  KEY `driver_id` (`driver_id`),
  CONSTRAINT `vehicles_ibfk_1` FOREIGN KEY (`driver_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `volunteer_badges`
--

DROP TABLE IF EXISTS `volunteer_badges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `volunteer_badges` (
  `id` int NOT NULL AUTO_INCREMENT,
  `volunteer_id` int NOT NULL,
  `badge_id` int NOT NULL,
  `earned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_badge_per_volunteer` (`volunteer_id`,`badge_id`),
  KEY `badge_id` (`badge_id`),
  CONSTRAINT `volunteer_badges_ibfk_1` FOREIGN KEY (`volunteer_id`) REFERENCES `volunteers` (`volunteer_id`) ON DELETE CASCADE,
  CONSTRAINT `volunteer_badges_ibfk_2` FOREIGN KEY (`badge_id`) REFERENCES `badges` (`badge_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=332 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `volunteer_proofs`
--

DROP TABLE IF EXISTS `volunteer_proofs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `volunteer_proofs` (
  `proof_id` int NOT NULL AUTO_INCREMENT,
  `request_id` int NOT NULL,
  `proof_type` enum('Educational Certificate','Technical Certification','Trade License','Workshop Training Certificate','Work Experience Letter','Portfolio Screenshot','Previous Published Guide','Professional ID','Other') NOT NULL,
  `image_path` varchar(255) NOT NULL,
  `description` varchar(500) DEFAULT NULL,
  `upload_order` int DEFAULT '1',
  PRIMARY KEY (`proof_id`),
  KEY `idx_vp_request` (`request_id`),
  CONSTRAINT `fk_vp_request` FOREIGN KEY (`request_id`) REFERENCES `volunteer_requests` (`request_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `volunteer_requests`
--

DROP TABLE IF EXISTS `volunteer_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `volunteer_requests` (
  `request_id` int NOT NULL AUTO_INCREMENT,
  `full_name` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `password_hash` varchar(255) NOT NULL,
  `city` varchar(50) DEFAULT NULL,
  `profile_picture_path` varchar(255) DEFAULT NULL,
  `expertise` varchar(500) NOT NULL,
  `skill_level` enum('Beginner','Intermediate','Advanced','Professional') NOT NULL,
  `experience_years` enum('0-1','1-3','3-5','5+') DEFAULT NULL,
  `bio` text,
  `sample_guide` text,
  `sample_guide_file_path` varchar(255) DEFAULT NULL,
  `status` enum('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  `rejection_reason` text,
  `submitted_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `reviewed_date` timestamp NULL DEFAULT NULL,
  `reviewed_by` int DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  UNIQUE KEY `uq_vr_username` (`username`),
  UNIQUE KEY `uq_vr_email` (`email`),
  KEY `idx_vr_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `volunteers`
--

DROP TABLE IF EXISTS `volunteers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `volunteers` (
  `volunteer_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `expertise` varchar(100) NOT NULL,
  `skill_level` varchar(20) DEFAULT NULL,
  `experience_years` varchar(10) DEFAULT NULL,
  `bio` text,
  `profile_picture_path` varchar(255) DEFAULT NULL,
  `agreement` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `reputation_score` decimal(10,2) DEFAULT '0.00',
  PRIMARY KEY (`volunteer_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `volunteers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-15 18:19:09
