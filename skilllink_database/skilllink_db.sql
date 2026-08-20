-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 20, 2026 at 03:51 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `skilllink_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `service_id` bigint(20) UNSIGNED NOT NULL,
  `booking_date` date NOT NULL,
  `booking_time` time NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `status` enum('pending','confirmed','completed','cancelled') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`id`, `user_id`, `service_id`, `booking_date`, `booking_time`, `total_amount`, `status`, `created_at`, `updated_at`) VALUES
(1, 2, 1, '2026-08-20', '10:00:00', 15.00, 'confirmed', '2026-08-14 06:39:48', '2026-08-14 06:43:33'),
(2, 3, 1, '2026-08-20', '11:00:00', 15.00, 'confirmed', '2026-08-14 06:52:22', '2026-08-14 06:54:10'),
(3, 2, 2, '2026-08-26', '10:30:00', 25.00, 'pending', '2026-08-14 07:26:22', '2026-08-14 07:26:22'),
(4, 2, 1, '2026-08-29', '10:00:00', 15.00, 'confirmed', '2026-08-19 00:15:26', '2026-08-19 00:15:40'),
(5, 2, 7, '2026-08-21', '18:00:00', 30.00, 'confirmed', '2026-08-19 01:12:09', '2026-08-19 01:12:15'),
(6, 12, 4, '2026-08-20', '10:00:00', 10.00, 'confirmed', '2026-08-19 02:29:52', '2026-08-19 02:29:59'),
(7, 12, 6, '2026-08-21', '10:00:00', 18.00, 'confirmed', '2026-08-19 06:48:23', '2026-08-19 06:48:31'),
(8, 12, 7, '2026-08-29', '12:00:00', 30.00, 'confirmed', '2026-08-19 06:58:00', '2026-08-19 06:58:05'),
(9, 12, 4, '2026-08-22', '22:00:00', 10.00, 'confirmed', '2026-08-19 08:25:46', '2026-08-19 08:25:48'),
(10, 12, 8, '2026-08-21', '10:00:00', 30.00, 'completed', '2026-08-19 08:33:33', '2026-08-19 08:34:13'),
(11, 12, 3, '2026-08-29', '10:00:00', 20.00, 'confirmed', '2026-08-19 18:36:16', '2026-08-19 18:36:18');

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `image`, `created_at`, `updated_at`) VALUES
(1, 'Technology', NULL, '2026-08-14 05:23:26', '2026-08-14 05:23:26'),
(2, 'Language', NULL, '2026-08-14 05:50:15', '2026-08-14 05:50:15'),
(3, 'Design', NULL, '2026-08-14 05:50:35', '2026-08-14 05:50:35'),
(4, 'Business', NULL, '2026-08-14 05:50:48', '2026-08-14 05:50:48'),
(5, 'Lifestyle', NULL, '2026-08-14 05:51:03', '2026-08-14 05:51:03'),
(6, 'Education', NULL, '2026-08-14 06:47:45', '2026-08-14 06:47:45'),
(7, 'Photography', NULL, '2026-08-14 06:47:45', '2026-08-14 06:47:45'),
(8, 'Beauty', NULL, '2026-08-14 06:47:45', '2026-08-14 06:47:45'),
(9, 'Home Services', NULL, '2026-08-14 06:47:45', '2026-08-14 06:47:45');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` varchar(255) NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` smallint(5) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_08_13_151807_create_categories_table', 2),
(5, '2026_08_13_152103_create_services_table', 2),
(6, '2026_08_13_152200_create_bookings_table', 2),
(7, '2026_08_13_152254_create_payments_table', 2),
(8, '2026_08_13_152941_add_role_and_profile_image_to_users_table', 3),
(9, '2026_08_13_153537_create_personal_access_tokens_table', 4),
(10, '2026_08_19_083509_create_wallets_table', 5),
(11, '2026_08_19_085816_create_wallet_transactions_table', 6);

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `booking_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` enum('card','khqr','wallet') NOT NULL,
  `transaction_id` varchar(255) NOT NULL,
  `status` enum('pending','paid','failed') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`id`, `booking_id`, `amount`, `payment_method`, `transaction_id`, `status`, `created_at`, `updated_at`) VALUES
(1, 1, 15.00, 'khqr', 'SL-20260814134333-RK2BAO', 'paid', '2026-08-14 06:43:33', '2026-08-14 06:43:33'),
(2, 2, 15.00, 'card', 'SL-20260814135410-DMNHZQ', 'paid', '2026-08-14 06:54:10', '2026-08-14 06:54:10'),
(3, 4, 15.00, 'card', 'SL-20260819071540-FYCU6D', 'paid', '2026-08-19 00:15:40', '2026-08-19 00:15:40'),
(4, 5, 30.00, 'wallet', 'SL-20260819081215-NZMNRO', 'paid', '2026-08-19 01:12:15', '2026-08-19 01:12:15'),
(5, 6, 10.00, 'khqr', 'SL-20260819092959-IWU4ZK', 'paid', '2026-08-19 02:29:59', '2026-08-19 02:29:59'),
(6, 7, 18.00, 'khqr', 'SL-20260819134831-E5SHNR', 'paid', '2026-08-19 06:48:31', '2026-08-19 06:48:31'),
(7, 8, 30.00, 'wallet', 'SL-20260819135805-038YJC', 'paid', '2026-08-19 06:58:05', '2026-08-19 06:58:05'),
(8, 9, 10.00, 'khqr', 'SL-20260819152547-GQPSJ9', 'paid', '2026-08-19 08:25:47', '2026-08-19 08:25:47'),
(9, 10, 30.00, 'card', 'SL-20260819153336-YKKLGH', 'paid', '2026-08-19 08:33:36', '2026-08-19 08:33:36'),
(10, 11, 20.00, 'khqr', 'SL-20260820013618-IRWCBH', 'paid', '2026-08-19 18:36:18', '2026-08-19 18:36:18');

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `services`
--

CREATE TABLE `services` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `provider_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `duration` int(11) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `rating` decimal(2,1) NOT NULL DEFAULT 0.0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `services`
--

INSERT INTO `services` (`id`, `category_id`, `provider_id`, `title`, `description`, `price`, `duration`, `image`, `rating`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'Website Design Consultation', 'Get professional advice on designing a modern and user-friendly website for your business or personal project.', 15.00, 60, NULL, 4.8, '2026-08-14 05:44:45', '2026-08-14 05:44:45'),
(2, 1, 3, 'Mobile App Development', 'Professional guidance for planning and developing modern mobile applications.', 25.00, 90, NULL, 4.9, '2026-08-14 06:47:45', '2026-08-14 06:47:45'),
(3, 3, 4, 'Logo Design', 'Create a professional and memorable logo for your business or personal brand.', 20.00, 60, NULL, 4.7, '2026-08-14 06:47:45', '2026-08-14 06:47:45'),
(4, 6, 5, 'English Conversation Tutoring', 'Practice everyday English conversation with an experienced tutor.', 10.00, 60, NULL, 4.9, '2026-08-14 06:47:45', '2026-08-14 06:47:45'),
(5, 7, 4, 'Portrait Photography', 'Professional portrait photography for personal profiles, social media, and special occasions.', 35.00, 90, NULL, 4.8, '2026-08-14 06:47:45', '2026-08-14 06:47:45'),
(6, 8, 1, 'Hair Styling', 'Professional hair styling for everyday looks, events, and special occasions.', 18.00, 60, NULL, 4.6, '2026-08-14 06:47:45', '2026-08-14 06:47:45'),
(7, 9, 3, 'Home Cleaning Service', 'Reliable home cleaning service for apartments and houses.', 30.00, 120, NULL, 4.7, '2026-08-14 06:47:45', '2026-08-14 06:47:45'),
(8, 1, 11, 'Chef', 'Learn how to cook your perfect meal.', 30.00, 90, 'services/ZOwyVtqGGTzaPAHEb8HY9mkzzA8OiOAQUIX5ipt2.jpg', 0.0, '2026-08-19 08:32:40', '2026-08-19 08:32:40');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('pphMuC0UF8l4kuLHkWIMkMbMcZrAHUrJc08SY1ug', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', 'eyJfdG9rZW4iOiI2SjZLM0xHZTBKQnRCcXJmYUJFYjRCNzFsWDVobUVlY0txdU5Fb3pVIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdDo4MDAwIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1787123623),
('XrEfeDBCtHSd82yDecltVbIgmUMsaROZe3pfz7Cg', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', 'eyJfdG9rZW4iOiJXWHMyQjI5UmQ1cmhFMkJwa0phTnUxdVRza3BFeXZqdGliRHJhMVV2IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdDo4MDAwIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1787145275),
('Y2RPzRMlQAdNVIG6p2GCWJjruH1ZVMM4cAxoAkze', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', 'eyJfdG9rZW4iOiJTWHZwYkc1NWRjeHBPUDVFSllFMWg1NDdVSEkxTjhjbGZnc0s4NWdQIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdDo4MDAwIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19', 1786709905);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(255) NOT NULL DEFAULT 'user',
  `profile_image` varchar(255) DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `role`, `profile_image`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Sarah Johnson', 'sarah@skilllink.test', NULL, '$2y$12$ttqG6D/Mco2CTQcpnDZOtucwC9X1h5qr7M66KVdcQjMMlAiXmhZ.W', 'provider', NULL, NULL, '2026-08-14 05:40:39', '2026-08-14 05:40:39'),
(2, 'Emma Davis', 'emma@skilllink.test', NULL, '$2y$12$nT7p0X/VGzme4fBf.bcsde0PJ/UxKhfkRv4hsJ5SSlyjyAMHj5sv6', 'user', NULL, NULL, '2026-08-14 06:39:11', '2026-08-14 06:39:11'),
(3, 'David Smith', 'david@skilllink.test', NULL, '$2y$12$uQCWnoFW1tWkaviIv8KP2.bhpPIXbDdK.abVKRvrtp8TRebnI0aXi', 'provider', NULL, NULL, '2026-08-14 06:47:43', '2026-08-14 06:47:43'),
(4, 'Lisa Chen', 'lisa@skilllink.test', NULL, '$2y$12$hdP/anWcK8QhyAdFWffWke6HGqHL7xBWCmlp46swJKl/r1g0st.Gy', 'provider', NULL, NULL, '2026-08-14 06:47:44', '2026-08-14 06:47:44'),
(5, 'Daniel Wilson', 'daniel@skilllink.test', NULL, '$2y$12$zNSfBYrxY0q4W3O7uiR0neLNkORCTvf/u21k7OPTFoga0Toh2GnAi', 'provider', NULL, NULL, '2026-08-14 06:47:44', '2026-08-14 06:47:44'),
(6, 'Michael Brown', 'michael@skilllink.test', NULL, '$2y$12$fA4YzqXq.c43XWvAJRpRLeEPamE6xlhMtXy6gC/19Evk/yR/3MtmC', 'user', NULL, NULL, '2026-08-14 06:47:44', '2026-08-14 06:47:44'),
(7, 'Sophia Wilson', 'sophia@skilllink.test', NULL, '$2y$12$ErYuCPAaTkuC0PAbHxNzfuje43DOBY3IbPQbOtFHf386nC2LSD3Am', 'user', NULL, NULL, '2026-08-14 06:47:45', '2026-08-14 06:47:45'),
(8, 'Daniel Lee', 'daniel.lee@skilllink.test', NULL, '$2y$12$nJ2LF6tgsDWZ.5FkQ.S0He2wi0FYRXd35fUuRK2Y7SwSkfcxrx8xq', 'user', NULL, NULL, '2026-08-14 06:47:45', '2026-08-14 06:47:45'),
(9, 'Olivia Taylor', 'olivia@skilllink.test', NULL, '$2y$12$2H7XzkjZkDEKN37g61qkNei0YBu9D70hM.uigGboJ9mq.J0.yj39e', 'user', NULL, NULL, '2026-08-14 06:47:45', '2026-08-14 06:47:45'),
(10, 'Sokny Kim', 'sokny@skilllink.test', NULL, '$2y$12$TRF7ofI/wpK.2xFww8hOAO/mgjOeh9ACeVUJxaQ3hljMLLYwLBdLe', 'user', NULL, NULL, '2026-08-19 00:47:16', '2026-08-19 00:47:16'),
(11, 'Lily Smith', 'lily21@gmail.com', NULL, '$2y$12$2lAoYf0TAetSfDpUN1HTVeScEnAY4U.myAYJDKSmJxML6vgyJSte.', 'provider', NULL, NULL, '2026-08-19 02:22:34', '2026-08-19 02:22:34'),
(12, 'Nana Frost', 'nana12@gmail.com', NULL, '$2y$12$DJEs8tBuXP0DRZdhQumLT.57gnzJZ/8yddAwZrkL9IIxfXD5ergv6', 'user', NULL, NULL, '2026-08-19 02:27:29', '2026-08-19 02:27:29');

-- --------------------------------------------------------

--
-- Table structure for table `wallets`
--

CREATE TABLE `wallets` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `balance` decimal(12,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `wallets`
--

INSERT INTO `wallets` (`id`, `user_id`, `balance`, `created_at`, `updated_at`) VALUES
(1, 5, 0.00, '2026-08-19 01:41:23', '2026-08-19 01:41:23'),
(2, 11, 0.00, '2026-08-19 02:22:34', '2026-08-19 02:22:34'),
(3, 12, 0.00, '2026-08-19 02:27:29', '2026-08-19 02:27:29');

-- --------------------------------------------------------

--
-- Table structure for table `wallet_transactions`
--

CREATE TABLE `wallet_transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `wallet_id` bigint(20) UNSIGNED NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `type` enum('deposit','payment','refund') NOT NULL,
  `status` enum('pending','completed','failed') NOT NULL DEFAULT 'completed',
  `description` varchar(255) DEFAULT NULL,
  `reference` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `bookings_user_id_foreign` (`user_id`),
  ADD KEY `bookings_service_id_foreign` (`service_id`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`),
  ADD KEY `failed_jobs_connection_queue_failed_at_index` (`connection`,`queue`,`failed_at`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `payments_transaction_id_unique` (`transaction_id`),
  ADD KEY `payments_booking_id_foreign` (`booking_id`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indexes for table `services`
--
ALTER TABLE `services`
  ADD PRIMARY KEY (`id`),
  ADD KEY `services_category_id_foreign` (`category_id`),
  ADD KEY `services_provider_id_foreign` (`provider_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indexes for table `wallets`
--
ALTER TABLE `wallets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `wallets_user_id_unique` (`user_id`);

--
-- Indexes for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `wallet_transactions_reference_unique` (`reference`),
  ADD KEY `wallet_transactions_wallet_id_foreign` (`wallet_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `services`
--
ALTER TABLE `services`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `wallets`
--
ALTER TABLE `wallets`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bookings`
--
ALTER TABLE `bookings`
  ADD CONSTRAINT `bookings_service_id_foreign` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `bookings_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_booking_id_foreign` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `services`
--
ALTER TABLE `services`
  ADD CONSTRAINT `services_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `services_provider_id_foreign` FOREIGN KEY (`provider_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `wallets`
--
ALTER TABLE `wallets`
  ADD CONSTRAINT `wallets_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `wallet_transactions`
--
ALTER TABLE `wallet_transactions`
  ADD CONSTRAINT `wallet_transactions_wallet_id_foreign` FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
