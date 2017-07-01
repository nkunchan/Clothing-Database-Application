-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: Dec 06, 2016 at 01:07 PM
-- Server version: 10.1.16-MariaDB
-- PHP Version: 7.0.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `catawba`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `checkOut` (IN `userid` CHAR(254))  BEGIN

	DECLARE cartid CHAR(254);
    
	SELECT cart.CartId INTO cartid FROM cart WHERE cart.UserId = userid;
	INSERT INTO solditem (soldItem.ItemId, solditem.SoldQuantity, solditem.Buyer)  
    SELECT 
     	cartitem.ItemId, 
     	cartitem.Quantity,
     	userid
     FROM 
     	cartitem INNER JOIN items 
     	ON cartitem.ItemId = items.ItemId 
     	WHERE cartitem.CartId = cartid;
        
    UPDATE 
    	items INNER JOIN cartitem 
        ON items.ItemId = cartitem.ItemId 
    SET 
    	items.Quantity = items.Quantity - cartitem.Quantity 
    WHERE 
    	cartitem.CartId = cartid;
        
    DELETE 
    	FROM approveditems 
    WHERE approveditems.ItemId IN (SELECT items.ItemId FROM items WHERE items.Quantity = 0);
    
    DELETE FROM cartitem WHERE cartitem.CartId = cartid;        
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `applicationuser`
--

CREATE TABLE `applicationuser` (
  `UserId` varchar(254) NOT NULL,
  `Name` varchar(50) NOT NULL,
  `EmailId` varchar(100) NOT NULL,
  `Password` varchar(500) NOT NULL,
  `Address` varchar(500) DEFAULT NULL,
  `Phone` bigint(10) DEFAULT NULL,
  `IsSubscribed` tinyint(1) NOT NULL,
  `Role` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `applicationuser`
--

INSERT INTO `applicationuser` (`UserId`, `Name`, `EmailId`, `Password`, `Address`, `Phone`, `IsSubscribed`, `Role`) VALUES
('146b2f30-bb2d-11e6-8901-ed9a6cfe8ec1', 'User', 'user@gmail.com', 'abcd', NULL, NULL, 0, 'User'),
('3bbc7df0-bb2d-11e6-8901-ed9a6cfe8ec1', 'Donor', 'donor@gmail.com', 'abcd', NULL, NULL, 1, 'Donor'),
('ee922890-bb2c-11e6-8901-ed9a6cfe8ec1', 'Member', 'member@gmail.com', 'abcd', NULL, NULL, 0, 'Member');

-- --------------------------------------------------------

--
-- Table structure for table `approveditems`
--

CREATE TABLE `approveditems` (
  `ItemId` varchar(254) NOT NULL,
  `ApprovedBy` varchar(254) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `approveditems`
--

INSERT INTO `approveditems` (`ItemId`, `ApprovedBy`) VALUES
('20c5a0c8-9b78-11e6-9f33-a24fc0d9649c', '5d695080-ba75-11e6-a4a6-cec0c932ce01'),
('20c5a49c-9b78-11e6-9f33-a24fc0d9649c', '5d695490-ba75-11e6-a4a6-cec0c932ce01'),
('20c5a69a-9b78-11e6-9f33-a24fc0d9649c', '5d6955bc-ba75-11e6-a4a6-cec0c932ce01'),
('20c5a85c-9b78-11e6-9f33-a24fc0d9649c', '5d695990-ba75-11e6-a4a6-cec0c932ce01'),
('20c5aa1e-9b78-11e6-9f33-a24fc0d9649c', '5d695a8a-ba75-11e6-a4a6-cec0c932ce01'),
('20c5abb8-9b78-11e6-9f33-a24fc0d9649c', '5d695080-ba75-11e6-a4a6-cec0c932ce01'),
('20c5b1c6-9b78-11e6-9f33-a24fc0d9649c', '5d695490-ba75-11e6-a4a6-cec0c932ce01'),
('20c5b3ba-9b78-11e6-9f33-a24fc0d9649c', '5d6955bc-ba75-11e6-a4a6-cec0c932ce01'),
('20c5b554-9b78-11e6-9f33-a24fc0d9649c', '5d695990-ba75-11e6-a4a6-cec0c932ce01'),
('20c5b702-9b78-11e6-9f33-a24fc0d9649c', '5d695a8a-ba75-11e6-a4a6-cec0c932ce01'),
('20c5b8b0-9b78-11e6-9f33-a24fc0d9649c', '5d695080-ba75-11e6-a4a6-cec0c932ce01'),
('20c5ba7c-9b78-11e6-9f33-a24fc0d9649c', '5d695490-ba75-11e6-a4a6-cec0c932ce01'),
('20c5bcb6-9b78-11e6-9f33-a24fc0d9649c', '5d6955bc-ba75-11e6-a4a6-cec0c932ce01'),
('20c5c24c-9b78-11e6-9f33-a24fc0d9649c', '5d695990-ba75-11e6-a4a6-cec0c932ce01'),
('20c5c422-9b78-11e6-9f33-a24fc0d9649c', '5d695a8a-ba75-11e6-a4a6-cec0c932ce01'),
('20c5c5e4-9b78-11e6-9f33-a24fc0d9649c', '5d695080-ba75-11e6-a4a6-cec0c932ce01'),
('20c5c7b0-9b78-11e6-9f33-a24fc0d9649c', '5d695490-ba75-11e6-a4a6-cec0c932ce01'),
('20c5c972-9b78-11e6-9f33-a24fc0d9649c', '5d6955bc-ba75-11e6-a4a6-cec0c932ce01'),
('20c5cb8e-9b78-11e6-9f33-a24fc0d9649c', '5d695990-ba75-11e6-a4a6-cec0c932ce01'),
('20c5d0fc-9b78-11e6-9f33-a24fc0d9649c', '5d695a8a-ba75-11e6-a4a6-cec0c932ce01'),
('20c5d322-9b78-11e6-9f33-a24fc0d9649c', '5d695080-ba75-11e6-a4a6-cec0c932ce01'),
('20c5d4ee-9b78-11e6-9f33-a24fc0d9649c', '5d695490-ba75-11e6-a4a6-cec0c932ce01'),
('20c5d85e-9b78-11e6-9f33-a24fc0d9649c', '5d6955bc-ba75-11e6-a4a6-cec0c932ce01'),
('20c5da34-9b78-11e6-9f33-a24fc0d9649c', '5d695990-ba75-11e6-a4a6-cec0c932ce01'),
('20c5dbd8-9b78-11e6-9f33-a24fc0d9649c', '5d695a8a-ba75-11e6-a4a6-cec0c932ce01'),
('20c5dd9a-9b78-11e6-9f33-a24fc0d9649c', '5d695080-ba75-11e6-a4a6-cec0c932ce01'),
('20c5e876-9b78-11e6-9f33-a24fc0d9649c', '5d695490-ba75-11e6-a4a6-cec0c932ce01'),
('20c5ea92-9b78-11e6-9f33-a24fc0d9649c', '5d6955bc-ba75-11e6-a4a6-cec0c932ce01'),
('20c5ec18-9b78-11e6-9f33-a24fc0d9649c', '5d695990-ba75-11e6-a4a6-cec0c932ce01'),
('20c5ed9e-9b78-11e6-9f33-a24fc0d9649c', '5d695a8a-ba75-11e6-a4a6-cec0c932ce01'),
('20c5ef2e-9b78-11e6-9f33-a24fc0d9649c', '5d695080-ba75-11e6-a4a6-cec0c932ce01'),
('20c5f0dc-9b78-11e6-9f33-a24fc0d9649c', '5d695490-ba75-11e6-a4a6-cec0c932ce01'),
('20c5f294-9b78-11e6-9f33-a24fc0d9649c', '5d6955bc-ba75-11e6-a4a6-cec0c932ce01'),
('20c5f7a8-9b78-11e6-9f33-a24fc0d9649c', '5d695990-ba75-11e6-a4a6-cec0c932ce01'),
('20c5f97e-9b78-11e6-9f33-a24fc0d9649c', '5d695a8a-ba75-11e6-a4a6-cec0c932ce01'),
('20c5fb0e-9b78-11e6-9f33-a24fc0d9649c', '5d695080-ba75-11e6-a4a6-cec0c932ce01'),
('20c5fca8-9b78-11e6-9f33-a24fc0d9649c', '5d695490-ba75-11e6-a4a6-cec0c932ce01'),
('20c5fe6a-9b78-11e6-9f33-a24fc0d9649c', '5d6955bc-ba75-11e6-a4a6-cec0c932ce01'),
('20c60022-9b78-11e6-9f33-a24fc0d9649c', '5d695990-ba75-11e6-a4a6-cec0c932ce01'),
('20c601a8-9b78-11e6-9f33-a24fc0d9649c', '5d695a8a-ba75-11e6-a4a6-cec0c932ce01'),
('20c606e4-9b78-11e6-9f33-a24fc0d9649c', '5d695080-ba75-11e6-a4a6-cec0c932ce01'),
('20c608ce-9b78-11e6-9f33-a24fc0d9649c', '5d695490-ba75-11e6-a4a6-cec0c932ce01'),
('20c60af4-9b78-11e6-9f33-a24fc0d9649c', '5d6955bc-ba75-11e6-a4a6-cec0c932ce01'),
('20c60c8e-9b78-11e6-9f33-a24fc0d9649c', '5d695990-ba75-11e6-a4a6-cec0c932ce01'),
('20c60e28-9b78-11e6-9f33-a24fc0d9649c', '5d695a8a-ba75-11e6-a4a6-cec0c932ce01'),
('20c61da0-9b78-11e6-9f33-a24fc0d9649c', '5d695080-ba75-11e6-a4a6-cec0c932ce01'),
('20c61fd0-9b78-11e6-9f33-a24fc0d9649c', '5d695490-ba75-11e6-a4a6-cec0c932ce01'),
('20c6261a-9b78-11e6-9f33-a24fc0d9649c', '5d6955bc-ba75-11e6-a4a6-cec0c932ce01'),
('20c627dc-9b78-11e6-9f33-a24fc0d9649c', '5d695990-ba75-11e6-a4a6-cec0c932ce01'),
('20c62980-9b78-11e6-9f33-a24fc0d9649c', '5d695a8a-ba75-11e6-a4a6-cec0c932ce01'),
('20c62b10-9b78-11e6-9f33-a24fc0d9649c', '5d695080-ba75-11e6-a4a6-cec0c932ce01'),
('20c62caa-9b78-11e6-9f33-a24fc0d9649c', '5d695490-ba75-11e6-a4a6-cec0c932ce01'),
('20c62e44-9b78-11e6-9f33-a24fc0d9649c', '5d6955bc-ba75-11e6-a4a6-cec0c932ce01'),
('20c63088-9b78-11e6-9f33-a24fc0d9649c', '5d695990-ba75-11e6-a4a6-cec0c932ce01'),
('20c636d2-9b78-11e6-9f33-a24fc0d9649c', '5d695a8a-ba75-11e6-a4a6-cec0c932ce01'),
('20c63858-9b78-11e6-9f33-a24fc0d9649c', '5d695a8a-ba75-11e6-a4a6-cec0c932ce01');

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

CREATE TABLE `cart` (
  `CartId` varchar(254) NOT NULL,
  `UserId` varchar(254) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `cart`
--

INSERT INTO `cart` (`CartId`, `UserId`) VALUES
('146e1560-bb2d-11e6-8901-ed9a6cfe8ec1', '146b2f30-bb2d-11e6-8901-ed9a6cfe8ec1'),
('3bc0c3b0-bb2d-11e6-8901-ed9a6cfe8ec1', '3bbc7df0-bb2d-11e6-8901-ed9a6cfe8ec1'),
('ee984310-bb2c-11e6-8901-ed9a6cfe8ec1', 'ee922890-bb2c-11e6-8901-ed9a6cfe8ec1');

-- --------------------------------------------------------

--
-- Table structure for table `cartitem`
--

CREATE TABLE `cartitem` (
  `CartId` varchar(254) NOT NULL,
  `ItemId` varchar(254) NOT NULL,
  `Quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `cartitem`
--

INSERT INTO `cartitem` (`CartId`, `ItemId`, `Quantity`) VALUES
('3bc0c3b0-bb2d-11e6-8901-ed9a6cfe8ec1', '20c5a0c8-9b78-11e6-9f33-a24fc0d9649c', 1);

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `CategoryId` varchar(254) NOT NULL,
  `CategoryName` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`CategoryId`, `CategoryName`) VALUES
('228daab4-9b7c-11e6-9f33-a24fc0d9649c', 'Baby Products (Excluding Apparel)'),
('228dae92-9b7c-11e6-9f33-a24fc0d9649c', 'Beauty'),
('228db07c-9b7c-11e6-9f33-a24fc0d9649c', 'Books'),
('228db20c-9b7c-11e6-9f33-a24fc0d9649c', 'Business Products (B2B)'),
('228db784-9b7c-11e6-9f33-a24fc0d9649c', 'Camera & Photo'),
('228dba68-9b7c-11e6-9f33-a24fc0d9649c', 'Cell Phones'),
('228dbbf8-9b7c-11e6-9f33-a24fc0d9649c', 'Clothing & Accessories'),
('228dbd74-9b7c-11e6-9f33-a24fc0d9649c', 'Collectible Coins'),
('228dbedc-9b7c-11e6-9f33-a24fc0d9649c', 'Collectibles (Books)'),
('228dc058-9b7c-11e6-9f33-a24fc0d9649c', 'Collectibles (Entertainment)'),
('228dc1de-9b7c-11e6-9f33-a24fc0d9649c', 'Electronics (Accessories)'),
('228dc76a-9b7c-11e6-9f33-a24fc0d9649c', 'Electronics (Consumer)'),
('228dc904-9b7c-11e6-9f33-a24fc0d9649c', 'Fine Art'),
('228dca8a-9b7c-11e6-9f33-a24fc0d9649c', 'Grocery & Gourmet Food'),
('228dcbfc-9b7c-11e6-9f33-a24fc0d9649c', 'Handmade'),
('228dcd78-9b7c-11e6-9f33-a24fc0d9649c', 'Health & Personal Care'),
('228dceea-9b7c-11e6-9f33-a24fc0d9649c', 'Historical & Advertising Collectibles'),
('228dd3a4-9b7c-11e6-9f33-a24fc0d9649c', 'Home & Garden'),
('228dd5b6-9b7c-11e6-9f33-a24fc0d9649c', 'Industrial & Scientific'),
('228dd75a-9b7c-11e6-9f33-a24fc0d9649c', 'Jewelry');

-- --------------------------------------------------------

--
-- Table structure for table `itemcategory`
--

CREATE TABLE `itemcategory` (
  `CategoryId` varchar(254) NOT NULL,
  `ItemId` varchar(254) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `itemcategory`
--

INSERT INTO `itemcategory` (`CategoryId`, `ItemId`) VALUES
('228daab4-9b7c-11e6-9f33-a24fc0d9649c', '20c5a0c8-9b78-11e6-9f33-a24fc0d9649c'),
('228dae92-9b7c-11e6-9f33-a24fc0d9649c', '20c5a49c-9b78-11e6-9f33-a24fc0d9649c'),
('228db07c-9b7c-11e6-9f33-a24fc0d9649c', '20c5a69a-9b78-11e6-9f33-a24fc0d9649c'),
('228db20c-9b7c-11e6-9f33-a24fc0d9649c', '20c5a85c-9b78-11e6-9f33-a24fc0d9649c'),
('228db784-9b7c-11e6-9f33-a24fc0d9649c', '20c5aa1e-9b78-11e6-9f33-a24fc0d9649c'),
('228dba68-9b7c-11e6-9f33-a24fc0d9649c', '20c5abb8-9b78-11e6-9f33-a24fc0d9649c'),
('228dbbf8-9b7c-11e6-9f33-a24fc0d9649c', '20c5b1c6-9b78-11e6-9f33-a24fc0d9649c'),
('228dbd74-9b7c-11e6-9f33-a24fc0d9649c', '20c5b3ba-9b78-11e6-9f33-a24fc0d9649c'),
('228dbedc-9b7c-11e6-9f33-a24fc0d9649c', '20c5b554-9b78-11e6-9f33-a24fc0d9649c'),
('228dc058-9b7c-11e6-9f33-a24fc0d9649c', '20c5b702-9b78-11e6-9f33-a24fc0d9649c'),
('228dc1de-9b7c-11e6-9f33-a24fc0d9649c', '20c5b8b0-9b78-11e6-9f33-a24fc0d9649c'),
('228dc76a-9b7c-11e6-9f33-a24fc0d9649c', '20c5ba7c-9b78-11e6-9f33-a24fc0d9649c'),
('228dc904-9b7c-11e6-9f33-a24fc0d9649c', '20c5bcb6-9b78-11e6-9f33-a24fc0d9649c'),
('228dca8a-9b7c-11e6-9f33-a24fc0d9649c', '20c5c24c-9b78-11e6-9f33-a24fc0d9649c'),
('228dcbfc-9b7c-11e6-9f33-a24fc0d9649c', '20c5c422-9b78-11e6-9f33-a24fc0d9649c'),
('228dcd78-9b7c-11e6-9f33-a24fc0d9649c', '20c5c5e4-9b78-11e6-9f33-a24fc0d9649c'),
('228dceea-9b7c-11e6-9f33-a24fc0d9649c', '20c5c7b0-9b78-11e6-9f33-a24fc0d9649c'),
('228dd3a4-9b7c-11e6-9f33-a24fc0d9649c', '20c5c972-9b78-11e6-9f33-a24fc0d9649c'),
('228dd5b6-9b7c-11e6-9f33-a24fc0d9649c', '20c5cb8e-9b78-11e6-9f33-a24fc0d9649c'),
('228dd75a-9b7c-11e6-9f33-a24fc0d9649c', '20c5d0fc-9b78-11e6-9f33-a24fc0d9649c'),
('228daab4-9b7c-11e6-9f33-a24fc0d9649c', '20c5d322-9b78-11e6-9f33-a24fc0d9649c'),
('228dae92-9b7c-11e6-9f33-a24fc0d9649c', '20c5d4ee-9b78-11e6-9f33-a24fc0d9649c'),
('228db07c-9b7c-11e6-9f33-a24fc0d9649c', '20c5d85e-9b78-11e6-9f33-a24fc0d9649c'),
('228db20c-9b7c-11e6-9f33-a24fc0d9649c', '20c5da34-9b78-11e6-9f33-a24fc0d9649c'),
('228db784-9b7c-11e6-9f33-a24fc0d9649c', '20c5dbd8-9b78-11e6-9f33-a24fc0d9649c'),
('228dba68-9b7c-11e6-9f33-a24fc0d9649c', '20c5dd9a-9b78-11e6-9f33-a24fc0d9649c'),
('228dbbf8-9b7c-11e6-9f33-a24fc0d9649c', '20c5e876-9b78-11e6-9f33-a24fc0d9649c'),
('228dbd74-9b7c-11e6-9f33-a24fc0d9649c', '20c5ea92-9b78-11e6-9f33-a24fc0d9649c'),
('228dbedc-9b7c-11e6-9f33-a24fc0d9649c', '20c5ec18-9b78-11e6-9f33-a24fc0d9649c'),
('228dc058-9b7c-11e6-9f33-a24fc0d9649c', '20c5ed9e-9b78-11e6-9f33-a24fc0d9649c'),
('228dc1de-9b7c-11e6-9f33-a24fc0d9649c', '20c5ef2e-9b78-11e6-9f33-a24fc0d9649c'),
('228dc76a-9b7c-11e6-9f33-a24fc0d9649c', '20c5f0dc-9b78-11e6-9f33-a24fc0d9649c'),
('228dc904-9b7c-11e6-9f33-a24fc0d9649c', '20c5f294-9b78-11e6-9f33-a24fc0d9649c'),
('228dca8a-9b7c-11e6-9f33-a24fc0d9649c', '20c5f7a8-9b78-11e6-9f33-a24fc0d9649c'),
('228dcbfc-9b7c-11e6-9f33-a24fc0d9649c', '20c5f97e-9b78-11e6-9f33-a24fc0d9649c'),
('228dcd78-9b7c-11e6-9f33-a24fc0d9649c', '20c5fb0e-9b78-11e6-9f33-a24fc0d9649c'),
('228dceea-9b7c-11e6-9f33-a24fc0d9649c', '20c5fca8-9b78-11e6-9f33-a24fc0d9649c'),
('228dd3a4-9b7c-11e6-9f33-a24fc0d9649c', '20c5fe6a-9b78-11e6-9f33-a24fc0d9649c'),
('228dd5b6-9b7c-11e6-9f33-a24fc0d9649c', '20c60022-9b78-11e6-9f33-a24fc0d9649c'),
('228dd75a-9b7c-11e6-9f33-a24fc0d9649c', '20c601a8-9b78-11e6-9f33-a24fc0d9649c'),
('228daab4-9b7c-11e6-9f33-a24fc0d9649c', '20c606e4-9b78-11e6-9f33-a24fc0d9649c'),
('228dae92-9b7c-11e6-9f33-a24fc0d9649c', '20c608ce-9b78-11e6-9f33-a24fc0d9649c'),
('228db07c-9b7c-11e6-9f33-a24fc0d9649c', '20c60af4-9b78-11e6-9f33-a24fc0d9649c'),
('228db20c-9b7c-11e6-9f33-a24fc0d9649c', '20c60c8e-9b78-11e6-9f33-a24fc0d9649c'),
('228db784-9b7c-11e6-9f33-a24fc0d9649c', '20c60e28-9b78-11e6-9f33-a24fc0d9649c'),
('228dba68-9b7c-11e6-9f33-a24fc0d9649c', '20c61da0-9b78-11e6-9f33-a24fc0d9649c'),
('228dbbf8-9b7c-11e6-9f33-a24fc0d9649c', '20c61fd0-9b78-11e6-9f33-a24fc0d9649c'),
('228dbd74-9b7c-11e6-9f33-a24fc0d9649c', '20c6261a-9b78-11e6-9f33-a24fc0d9649c'),
('228dbedc-9b7c-11e6-9f33-a24fc0d9649c', '20c627dc-9b78-11e6-9f33-a24fc0d9649c'),
('228dc058-9b7c-11e6-9f33-a24fc0d9649c', '20c62980-9b78-11e6-9f33-a24fc0d9649c'),
('228dc1de-9b7c-11e6-9f33-a24fc0d9649c', '20c62b10-9b78-11e6-9f33-a24fc0d9649c'),
('228dc76a-9b7c-11e6-9f33-a24fc0d9649c', '20c62caa-9b78-11e6-9f33-a24fc0d9649c'),
('228dc904-9b7c-11e6-9f33-a24fc0d9649c', '20c62e44-9b78-11e6-9f33-a24fc0d9649c'),
('228dca8a-9b7c-11e6-9f33-a24fc0d9649c', '20c63088-9b78-11e6-9f33-a24fc0d9649c'),
('228dcbfc-9b7c-11e6-9f33-a24fc0d9649c', '20c636d2-9b78-11e6-9f33-a24fc0d9649c'),
('228dcd78-9b7c-11e6-9f33-a24fc0d9649c', '20c63858-9b78-11e6-9f33-a24fc0d9649c'),
('228daab4-9b7c-11e6-9f33-a24fc0d9649c', '');

-- --------------------------------------------------------

--
-- Table structure for table `items`
--

CREATE TABLE `items` (
  `ItemId` varchar(254) NOT NULL,
  `ItemName` varchar(50) NOT NULL,
  `Description` varchar(500) NOT NULL,
  `Price` decimal(10,0) NOT NULL,
  `OnSale` tinyint(1) NOT NULL DEFAULT '0',
  `Discount` decimal(10,0) NOT NULL DEFAULT '0',
  `Quantity` int(11) NOT NULL,
  `IsApproved` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `items`
--

INSERT INTO `items` (`ItemId`, `ItemName`, `Description`, `Price`, `OnSale`, `Discount`, `Quantity`, `IsApproved`) VALUES
('20c5a0c8-9b78-11e6-9f33-a24fc0d9649c', 'ABC Blocks W/Apple On top', 'ABC-Blocks-W/Apple-On-top', '78', 1, '9', 2, 1),
('20c5a49c-9b78-11e6-9f33-a24fc0d9649c', 'ABC/123 and Pencil Cup ', 'ABC/123-and-Pencil-Cup-', '68', 0, '0', 5, 1),
('20c5a69a-9b78-11e6-9f33-a24fc0d9649c', 'Airplane ', 'Airplane-', '31', 0, '0', 7, 1),
('20c5a85c-9b78-11e6-9f33-a24fc0d9649c', 'Alligator', 'Alligator', '95', 0, '0', 10, 1),
('20c5aa1e-9b78-11e6-9f33-a24fc0d9649c', 'Ambulance', 'Ambulance', '67', 0, '0', 1, 1),
('20c5abb8-9b78-11e6-9f33-a24fc0d9649c', 'American Flag Heart', 'American-Flag-Heart', '31', 0, '0', 6, 1),
('20c5b1c6-9b78-11e6-9f33-a24fc0d9649c', 'Angel', 'Angel', '19', 0, '0', 8, 1),
('20c5b3ba-9b78-11e6-9f33-a24fc0d9649c', 'Anklet', 'Anklet', '80', 0, '0', 8, 1),
('20c5b554-9b78-11e6-9f33-a24fc0d9649c', 'Anime book', 'Anime-book', '18', 0, '0', 2, 1),
('20c5b702-9b78-11e6-9f33-a24fc0d9649c', 'Archery kit', 'Archery-kit', '78', 0, '0', 3, 1),
('20c5b8b0-9b78-11e6-9f33-a24fc0d9649c', 'Appletart', 'Appletart', '33', 1, '12', 6, 1),
('20c5ba7c-9b78-11e6-9f33-a24fc0d9649c', 'Apple Chalkboard ', 'Apple-Chalkboard-', '65', 0, '0', 7, 1),
('20c5bcb6-9b78-11e6-9f33-a24fc0d9649c', 'Apple Face ', 'Apple-Face-', '32', 0, '0', 7, 1),
('20c5c24c-9b78-11e6-9f33-a24fc0d9649c', 'Apple with Bite', 'Apple-with-Bite', '36', 0, '0', 3, 1),
('20c5c422-9b78-11e6-9f33-a24fc0d9649c', 'Apple with Pencil', 'Apple-with-Pencil', '20', 0, '0', 3, 1),
('20c5c5e4-9b78-11e6-9f33-a24fc0d9649c', 'Art Box', 'Art-Box', '69', 0, '0', 1, 1),
('20c5c7b0-9b78-11e6-9f33-a24fc0d9649c', 'Baby Bottle', 'Baby-Bottle', '97', 0, '0', 10, 1),
('20c5c972-9b78-11e6-9f33-a24fc0d9649c', 'Baby Duck', 'Baby-Duck', '76', 0, '0', 9, 1),
('20c5cb8e-9b78-11e6-9f33-a24fc0d9649c', 'Baby Overalls', 'Baby-Overalls', '55', 0, '0', 2, 1),
('20c5d0fc-9b78-11e6-9f33-a24fc0d9649c', 'Baby Rattle', 'Baby-Rattle', '46', 0, '0', 3, 1),
('20c5d322-9b78-11e6-9f33-a24fc0d9649c', 'Baby Shoes ', 'Baby-Shoes-', '55', 1, '6', 3, 1),
('20c5d4ee-9b78-11e6-9f33-a24fc0d9649c', 'Ballerina', 'Ballerina', '58', 0, '0', 7, 1),
('20c5d85e-9b78-11e6-9f33-a24fc0d9649c', 'Ballet Slipper ? black ', 'Ballet-Slipper-?-black-', '83', 0, '0', 10, 1),
('20c5da34-9b78-11e6-9f33-a24fc0d9649c', 'Ballet Slipper ? pink', 'Ballet-Slipper-?-pink', '21', 0, '0', 2, 1),
('20c5dbd8-9b78-11e6-9f33-a24fc0d9649c', 'Balloons ', 'Balloons-', '11', 0, '0', 1, 1),
('20c5dd9a-9b78-11e6-9f33-a24fc0d9649c', 'Banana ', 'Banana-', '90', 0, '0', 8, 1),
('20c5e876-9b78-11e6-9f33-a24fc0d9649c', 'Baseball ', 'Baseball-', '15', 0, '0', 4, 1),
('20c5ea92-9b78-11e6-9f33-a24fc0d9649c', 'Baseball Mitt', 'Baseball-Mitt', '22', 1, '10', 9, 1),
('20c5ec18-9b78-11e6-9f33-a24fc0d9649c', 'Basket of Apples ', 'Basket-of-Apples-', '90', 0, '0', 5, 1),
('20c5ed9e-9b78-11e6-9f33-a24fc0d9649c', 'Basket of Fruit', 'Basket-of-Fruit', '42', 0, '0', 6, 1),
('20c5ef2e-9b78-11e6-9f33-a24fc0d9649c', 'Basket of Pansies', 'Basket-of-Pansies', '22', 0, '0', 9, 1),
('20c5f0dc-9b78-11e6-9f33-a24fc0d9649c', 'Basket of Vegetables ', 'Basket-of-Vegetables-', '35', 0, '0', 1, 1),
('20c5f294-9b78-11e6-9f33-a24fc0d9649c', 'Basketball ', 'Basketball-', '10', 0, '0', 8, 1),
('20c5f7a8-9b78-11e6-9f33-a24fc0d9649c', 'Basketball Net ', 'Basketball-Net-', '55', 0, '0', 5, 1),
('20c5f97e-9b78-11e6-9f33-a24fc0d9649c', 'Beach Ball ', 'Beach-Ball-', '42', 0, '0', 4, 1),
('20c5fb0e-9b78-11e6-9f33-a24fc0d9649c', 'Bear ? Sailor', 'Bear-?-Sailor', '55', 1, '16', 10, 1),
('20c5fca8-9b78-11e6-9f33-a24fc0d9649c', 'Bear ', 'Bear-', '58', 0, '0', 2, 1),
('20c5fe6a-9b78-11e6-9f33-a24fc0d9649c', 'Bear Baby', 'Bear-Baby', '53', 0, '0', 3, 1),
('20c60022-9b78-11e6-9f33-a24fc0d9649c', 'Bear Couple Picnic ', 'Bear-Couple-Picnic-', '71', 0, '0', 7, 1),
('20c601a8-9b78-11e6-9f33-a24fc0d9649c', 'Bear Gymnast on 1 Leg', 'Bear-Gymnast-on-1-Leg', '98', 0, '0', 6, 1),
('20c606e4-9b78-11e6-9f33-a24fc0d9649c', 'Bear Holding Heart ', 'Bear-Holding-Heart-', '45', 0, '0', 7, 1),
('20c608ce-9b78-11e6-9f33-a24fc0d9649c', 'Bear Holding Ice Cream ', 'Bear-Holding-Ice-Cream-', '53', 0, '0', 6, 1),
('20c60af4-9b78-11e6-9f33-a24fc0d9649c', 'Bear Holding Lollipop', 'Bear-Holding-Lollipop', '43', 1, '15', 3, 1),
('20c60c8e-9b78-11e6-9f33-a24fc0d9649c', 'Bear in Dress', 'Bear-in-Dress', '70', 1, '9', 8, 1),
('20c60e28-9b78-11e6-9f33-a24fc0d9649c', 'Bear on Moon ', 'Bear-on-Moon-', '35', 0, '0', 5, 1),
('20c61da0-9b78-11e6-9f33-a24fc0d9649c', 'Bear with Argyle Sweater ', 'Bear-with-Argyle-Sweater-', '13', 0, '0', 10, 1),
('20c61fd0-9b78-11e6-9f33-a24fc0d9649c', 'Bear with Stick Horse', 'Bear-with-Stick-Horse', '92', 0, '0', 4, 1),
('20c6261a-9b78-11e6-9f33-a24fc0d9649c', 'Bee Hive ', 'Bee-Hive-', '53', 0, '0', 9, 1),
('20c627dc-9b78-11e6-9f33-a24fc0d9649c', 'Beetle ', 'Beetle-', '47', 0, '0', 1, 1),
('20c62980-9b78-11e6-9f33-a24fc0d9649c', 'Bird ', 'Bird-', '65', 1, '7', 2, 1),
('20c62b10-9b78-11e6-9f33-a24fc0d9649c', 'Bird House ', 'Bird-House-', '41', 0, '0', 9, 1),
('20c62caa-9b78-11e6-9f33-a24fc0d9649c', 'Bird House Kit', 'Bird-House-Kit', '75', 0, '0', 10, 1),
('20c62e44-9b78-11e6-9f33-a24fc0d9649c', 'Bird Nest', 'Bird-Nest', '72', 0, '0', 8, 1),
('20c63088-9b78-11e6-9f33-a24fc0d9649c', 'Birthday Cake', 'Birthday-Cake', '51', 0, '0', 2, 1),
('20c636d2-9b78-11e6-9f33-a24fc0d9649c', 'Books w/Globe', 'Books-w/Globe', '70', 0, '0', 4, 1),
('20c63858-9b78-11e6-9f33-a24fc0d9649c', 'Bumble Bee ', 'Bumble-Bee-', '94', 1, '10', 7, 1),
('509ac6b0-bb4f-11e6-9c4d-d374eb3a84b7', 'Pepe Jeans', 'New pairs of jeans!', '12', 0, '0', 45, 1);

-- --------------------------------------------------------

--
-- Table structure for table `solditem`
--

CREATE TABLE `solditem` (
  `ItemId` varchar(254) NOT NULL,
  `SoldQuantity` int(11) NOT NULL,
  `SoldDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Buyer` varchar(254) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `applicationuser`
--
ALTER TABLE `applicationuser`
  ADD PRIMARY KEY (`UserId`),
  ADD UNIQUE KEY `EmailId` (`EmailId`),
  ADD UNIQUE KEY `Phone` (`Phone`);

--
-- Indexes for table `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`CartId`);

--
-- Indexes for table `cartitem`
--
ALTER TABLE `cartitem`
  ADD PRIMARY KEY (`CartId`,`ItemId`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`CategoryId`);

--
-- Indexes for table `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`ItemId`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
