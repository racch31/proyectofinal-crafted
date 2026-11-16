-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: crafted
-- ------------------------------------------------------
-- Server version	8.0.46-0ubuntu0.24.04.5

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
-- Current Database: `crafted`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `crafted` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `crafted`;

--
-- Table structure for table `carrito`
--

DROP TABLE IF EXISTS `carrito`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `carrito` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint unsigned NOT NULL,
  `producto_id` bigint unsigned DEFAULT NULL,
  `formula_id` bigint unsigned DEFAULT NULL,
  `cantidad` smallint unsigned NOT NULL DEFAULT '1',
  `agregado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_carrito_producto` (`usuario_id`,`producto_id`),
  UNIQUE KEY `uq_carrito_formula` (`usuario_id`,`formula_id`),
  KEY `producto_id` (`producto_id`),
  KEY `formula_id` (`formula_id`),
  CONSTRAINT `carrito_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `carrito_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`),
  CONSTRAINT `carrito_ibfk_3` FOREIGN KEY (`formula_id`) REFERENCES `formulas` (`id`),
  CONSTRAINT `carrito_chk_1` CHECK (((`producto_id` is null) <> (`formula_id` is null))),
  CONSTRAINT `carrito_chk_2` CHECK ((`cantidad` between 1 and 99))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carrito`
--

LOCK TABLES `carrito` WRITE;
/*!40000 ALTER TABLE `carrito` DISABLE KEYS */;
/*!40000 ALTER TABLE `carrito` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `compras`
--

DROP TABLE IF EXISTS `compras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `compras` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint unsigned NOT NULL,
  `direccion_envio` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `total` decimal(12,2) NOT NULL,
  `estado` enum('simulado','pendiente','pagado','cancelado') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'simulado',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `compras_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compras`
--

LOCK TABLES `compras` WRITE;
/*!40000 ALTER TABLE `compras` DISABLE KEYS */;
/*!40000 ALTER TABLE `compras` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalle_compra`
--

DROP TABLE IF EXISTS `detalle_compra`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalle_compra` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `compra_id` bigint unsigned NOT NULL,
  `producto_id` bigint unsigned DEFAULT NULL,
  `formula_id` bigint unsigned DEFAULT NULL,
  `nombre_snapshot` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cantidad` smallint unsigned NOT NULL,
  `precio_unitario` decimal(12,2) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `compra_id` (`compra_id`),
  KEY `producto_id` (`producto_id`),
  KEY `formula_id` (`formula_id`),
  CONSTRAINT `detalle_compra_ibfk_1` FOREIGN KEY (`compra_id`) REFERENCES `compras` (`id`) ON DELETE CASCADE,
  CONSTRAINT `detalle_compra_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`),
  CONSTRAINT `detalle_compra_ibfk_3` FOREIGN KEY (`formula_id`) REFERENCES `formulas` (`id`),
  CONSTRAINT `detalle_compra_chk_1` CHECK (((`producto_id` is null) <> (`formula_id` is null)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalle_compra`
--

LOCK TABLES `detalle_compra` WRITE;
/*!40000 ALTER TABLE `detalle_compra` DISABLE KEYS */;
/*!40000 ALTER TABLE `detalle_compra` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `formula_ingredientes`
--

DROP TABLE IF EXISTS `formula_ingredientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `formula_ingredientes` (
  `formula_id` bigint unsigned NOT NULL,
  `ingrediente_id` bigint unsigned NOT NULL,
  `cantidad_por_porcion_g` decimal(14,8) NOT NULL,
  `precio_por_gramo_snapshot` decimal(10,4) NOT NULL,
  PRIMARY KEY (`formula_id`,`ingrediente_id`),
  KEY `ingrediente_id` (`ingrediente_id`),
  CONSTRAINT `formula_ingredientes_ibfk_1` FOREIGN KEY (`formula_id`) REFERENCES `formulas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `formula_ingredientes_ibfk_2` FOREIGN KEY (`ingrediente_id`) REFERENCES `ingredientes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `formula_ingredientes`
--

LOCK TABLES `formula_ingredientes` WRITE;
/*!40000 ALTER TABLE `formula_ingredientes` DISABLE KEYS */;
/*!40000 ALTER TABLE `formula_ingredientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `formulas`
--

DROP TABLE IF EXISTS `formulas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `formulas` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint unsigned NOT NULL,
  `nombre` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `base_id` bigint unsigned NOT NULL,
  `sabor_id` bigint unsigned NOT NULL,
  `presentacion_id` int unsigned NOT NULL,
  `peso_porcion_g` decimal(10,3) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `usuario_id` (`usuario_id`),
  KEY `base_id` (`base_id`),
  KEY `sabor_id` (`sabor_id`),
  KEY `presentacion_id` (`presentacion_id`),
  CONSTRAINT `formulas_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `formulas_ibfk_2` FOREIGN KEY (`base_id`) REFERENCES `ingredientes` (`id`),
  CONSTRAINT `formulas_ibfk_3` FOREIGN KEY (`sabor_id`) REFERENCES `ingredientes` (`id`),
  CONSTRAINT `formulas_ibfk_4` FOREIGN KEY (`presentacion_id`) REFERENCES `presentaciones` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `formulas`
--

LOCK TABLES `formulas` WRITE;
/*!40000 ALTER TABLE `formulas` DISABLE KEYS */;
/*!40000 ALTER TABLE `formulas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `historial_compras`
--

DROP TABLE IF EXISTS `historial_compras`;
/*!50001 DROP VIEW IF EXISTS `historial_compras`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `historial_compras` AS SELECT 
 1 AS `id_compra`,
 1 AS `usuario`,
 1 AS `producto`,
 1 AS `formula_id`,
 1 AS `nombre_snapshot`,
 1 AS `cantidad`,
 1 AS `subtotal`,
 1 AS `creado_en`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `ingredientes`
--

DROP TABLE IF EXISTS `ingredientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ingredientes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `categoria` enum('base','sabor','suplemento','fibra') COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `beneficios` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `origen` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fabricante` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `foto` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'assets/img/producto.svg',
  `organico_certificado` tinyint(1) NOT NULL DEFAULT '0',
  `numero_certificado` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `alergenos` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Consultar fabricante',
  `precio_por_gramo` decimal(10,4) NOT NULL,
  `stock_gramos` decimal(12,2) NOT NULL DEFAULT '0.00',
  `minimo_g` decimal(14,8) NOT NULL DEFAULT '0.00000000',
  `maximo_g` decimal(14,8) NOT NULL DEFAULT '0.00000000',
  `admite_barrita` tinyint(1) NOT NULL DEFAULT '1',
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  CONSTRAINT `ingredientes_chk_1` CHECK ((`stock_gramos` >= 0)),
  CONSTRAINT `ingredientes_chk_2` CHECK ((`precio_por_gramo` >= 0)),
  CONSTRAINT `ingredientes_chk_3` CHECK ((`maximo_g` >= `minimo_g`))
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ingredientes`
--

LOCK TABLES `ingredientes` WRITE;
/*!40000 ALTER TABLE `ingredientes` DISABLE KEYS */;
INSERT INTO `ingredientes` VALUES (1,'Proteína de suero (Whey)','base','Proteína láctea para complementar la ingesta diaria','Contribuye a la ingesta diaria de proteína','México','Proveedor demostrativo','assets/img/base.svg',0,NULL,'Contiene leche',1.1200,45000.00,25.00000000,25.00000000,1,1),(2,'Aislado de suero','base','Proteína láctea concentrada, con menos lactosa que el concentrado','Contribuye a la ingesta diaria de proteína','Estados Unidos','Proveedor demostrativo','assets/img/base.svg',0,NULL,'Contiene leche',1.4500,45000.00,25.00000000,25.00000000,1,1),(3,'Proteína de chícharo','base','Alternativa proteica de origen vegetal','Contribuye a la ingesta diaria de proteína','Canadá','Proveedor demostrativo','assets/img/base.svg',0,NULL,'Consultar fabricante',1.1000,45000.00,25.00000000,25.00000000,1,1),(4,'Proteína de arroz','base','Alternativa vegetal elaborada a partir de arroz','Contribuye a la ingesta diaria de proteína','México','Proveedor demostrativo','assets/img/base.svg',0,NULL,'Consultar fabricante',1.0400,45000.00,25.00000000,25.00000000,1,1),(5,'Proteína de soya','base','Proteína vegetal de alta calidad','Contribuye a la ingesta diaria de proteína','México','Proveedor demostrativo','assets/img/base.svg',0,NULL,'Contiene soya',0.9200,45000.00,25.00000000,25.00000000,1,1),(6,'Mezcla vegetal','base','Combinación de proteínas vegetales','Contribuye a la ingesta diaria de proteína','México','Proveedor demostrativo','assets/img/base.svg',0,NULL,'Consultar fabricante',1.1600,45000.00,25.00000000,25.00000000,1,1),(7,'Chocolate','sabor','Saborizante alimentario de chocolate; verificar composición con proveedor','Personaliza el sabor de la fórmula','México','Proveedor demostrativo','assets/img/sabor.svg',0,NULL,'Consultar fabricante',0.4000,30000.00,2.00000000,2.00000000,1,1),(8,'Vainilla','sabor','Saborizante alimentario de vainilla; verificar composición con proveedor','Personaliza el sabor de la fórmula','México','Proveedor demostrativo','assets/img/sabor.svg',0,NULL,'Consultar fabricante',0.3200,30000.00,2.00000000,2.00000000,1,1),(9,'Fresa','sabor','Saborizante alimentario de fresa; verificar composición con proveedor','Personaliza el sabor de la fórmula','México','Proveedor demostrativo','assets/img/sabor.svg',0,NULL,'Consultar fabricante',0.3400,30000.00,2.00000000,2.00000000,1,1),(10,'Plátano','sabor','Saborizante alimentario de plátano; verificar composición con proveedor','Personaliza el sabor de la fórmula','México','Proveedor demostrativo','assets/img/sabor.svg',0,NULL,'Consultar fabricante',0.3200,30000.00,2.00000000,2.00000000,1,1),(11,'Café','sabor','Saborizante alimentario de café; verificar composición con proveedor','Personaliza el sabor de la fórmula','México','Proveedor demostrativo','assets/img/sabor.svg',0,NULL,'Consultar fabricante',0.3600,30000.00,2.00000000,2.00000000,1,1),(12,'Canela','sabor','Saborizante alimentario de canela; verificar composición con proveedor','Personaliza el sabor de la fórmula','México','Proveedor demostrativo','assets/img/sabor.svg',0,NULL,'Consultar fabricante',0.3100,30000.00,2.00000000,2.00000000,1,1),(13,'Cacao intenso','sabor','Saborizante alimentario de cacao intenso; verificar composición con proveedor','Personaliza el sabor de la fórmula','México','Proveedor demostrativo','assets/img/sabor.svg',0,NULL,'Consultar fabricante',0.4400,30000.00,2.00000000,2.00000000,1,1),(14,'Frutos rojos','sabor','Saborizante alimentario de frutos rojos; verificar composición con proveedor','Personaliza el sabor de la fórmula','México','Proveedor demostrativo','assets/img/sabor.svg',0,NULL,'Consultar fabricante',0.4100,30000.00,2.00000000,2.00000000,1,1),(15,'Creatina monohidratada','suplemento','Ingrediente utilizado en nutrición deportiva; consultar evidencia y precauciones','Descripción educativa; no sustituye evaluación profesional','Por verificar','Proveedor demostrativo','assets/img/suplemento.svg',0,NULL,'Consultar fabricante',0.6500,12000.00,0.50000000,5.00000000,1,1),(16,'Vitamina B12','suplemento','Micronutriente que interviene en funciones metabólicas','Descripción educativa; no sustituye evaluación profesional','Por verificar','Proveedor demostrativo','assets/img/suplemento.svg',0,NULL,'Consultar fabricante',1750.0000,12000.00,0.00000100,0.00000240,1,1),(17,'Vitamina C','suplemento','Vitamina hidrosoluble para complementar la dieta','Descripción educativa; no sustituye evaluación profesional','Por verificar','Proveedor demostrativo','assets/img/suplemento.svg',0,NULL,'Consultar fabricante',0.5500,12000.00,0.01000000,0.10000000,1,1),(18,'Vitamina D3','suplemento','Micronutriente liposoluble; requiere revisión de ingesta total','Descripción educativa; no sustituye evaluación profesional','Por verificar','Proveedor demostrativo','assets/img/suplemento.svg',0,NULL,'Consultar fabricante',8500.0000,12000.00,0.00000500,0.00002000,1,1),(19,'Magnesio','suplemento','Mineral esencial en diversas funciones del organismo; la forma química importa','Descripción educativa; no sustituye evaluación profesional','Por verificar','Proveedor demostrativo','assets/img/suplemento.svg',0,NULL,'Consultar fabricante',0.6500,12000.00,0.05000000,0.15000000,1,1),(20,'Zinc','suplemento','Mineral esencial; requiere revisar otras fuentes de ingesta','Descripción educativa; no sustituye evaluación profesional','Por verificar','Proveedor demostrativo','assets/img/suplemento.svg',0,NULL,'Consultar fabricante',1.2000,12000.00,0.00200000,0.01000000,1,1),(21,'Cacao natural','suplemento','Ingrediente botánico de cacao sin afirmación orgánica automática','Descripción educativa; no sustituye evaluación profesional','Por verificar','Proveedor demostrativo','assets/img/suplemento.svg',0,NULL,'Consultar fabricante',0.3500,12000.00,0.50000000,4.00000000,1,1),(22,'Espirulina','suplemento','Biomasa de cianobacterias para uso alimentario de calidad verificada','Descripción educativa; no sustituye evaluación profesional','Por verificar','Proveedor demostrativo','assets/img/suplemento.svg',0,NULL,'Consultar fabricante',0.5500,12000.00,0.20000000,2.00000000,1,1),(23,'Maca en polvo','suplemento','Ingrediente de origen vegetal; beneficios no garantizados','Descripción educativa; no sustituye evaluación profesional','Por verificar','Proveedor demostrativo','assets/img/suplemento.svg',0,NULL,'Consultar fabricante',0.5000,12000.00,0.30000000,3.00000000,1,1),(24,'Matcha','suplemento','Té verde molido; contiene cafeína','Descripción educativa; no sustituye evaluación profesional','Por verificar','Proveedor demostrativo','assets/img/suplemento.svg',0,NULL,'Consultar fabricante',1.1500,12000.00,0.20000000,1.50000000,1,1),(25,'Inulina','fibra','Fuente de fibra de tipo inulina','Contribuye al aporte de fibra; depende de tolerancia individual','Por verificar','Proveedor demostrativo','assets/img/fibra.svg',0,NULL,'Consultar fabricante',0.4500,16000.00,0.50000000,4.00000000,1,1),(26,'Psyllium','fibra','Fuente de fibra de tipo psyllium','Contribuye al aporte de fibra; depende de tolerancia individual','Por verificar','Proveedor demostrativo','assets/img/fibra.svg',0,NULL,'Consultar fabricante',0.4800,16000.00,0.50000000,4.00000000,1,1),(27,'Fibra de avena','fibra','Fuente de fibra de tipo fibra de avena','Contribuye al aporte de fibra; depende de tolerancia individual','Por verificar','Proveedor demostrativo','assets/img/fibra.svg',0,NULL,'Consultar fabricante',0.2900,16000.00,0.50000000,5.00000000,1,1),(28,'Fibra de acacia','fibra','Fuente de fibra de tipo fibra de acacia','Contribuye al aporte de fibra; depende de tolerancia individual','Por verificar','Proveedor demostrativo','assets/img/fibra.svg',0,NULL,'Consultar fabricante',0.4700,16000.00,0.50000000,4.00000000,1,1),(29,'Linaza molida','fibra','Fuente de fibra de tipo linaza molida','Contribuye al aporte de fibra; depende de tolerancia individual','Por verificar','Proveedor demostrativo','assets/img/fibra.svg',0,NULL,'Consultar fabricante',0.2400,16000.00,0.50000000,5.00000000,1,1),(30,'Chía molida','fibra','Fuente de fibra de tipo chía molida','Contribuye al aporte de fibra; depende de tolerancia individual','Por verificar','Proveedor demostrativo','assets/img/fibra.svg',0,NULL,'Consultar fabricante',0.3800,16000.00,0.50000000,5.00000000,1,1),(31,'Fibra de manzana','fibra','Fuente de fibra de tipo fibra de manzana','Contribuye al aporte de fibra; depende de tolerancia individual','Por verificar','Proveedor demostrativo','assets/img/fibra.svg',0,NULL,'Consultar fabricante',0.3800,16000.00,0.50000000,4.00000000,1,1);
/*!40000 ALTER TABLE `ingredientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `objetivos_usuarios`
--

DROP TABLE IF EXISTS `objetivos_usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `objetivos_usuarios` (
  `usuario_id` bigint unsigned NOT NULL,
  `objetivo` enum('masa','rendimiento','energia','sueno','digestion','bienestar') COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`usuario_id`,`objetivo`),
  CONSTRAINT `objetivos_usuarios_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `objetivos_usuarios`
--

LOCK TABLES `objetivos_usuarios` WRITE;
/*!40000 ALTER TABLE `objetivos_usuarios` DISABLE KEYS */;
/*!40000 ALTER TABLE `objetivos_usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `perfiles`
--

DROP TABLE IF EXISTS `perfiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `perfiles` (
  `usuario_id` bigint unsigned NOT NULL,
  `peso_kg` decimal(5,2) NOT NULL,
  `estatura_cm` decimal(5,1) NOT NULL,
  `actividad` enum('baja','ligera','moderada','alta') COLLATE utf8mb4_unicode_ci NOT NULL,
  `dias_entrenamiento` tinyint unsigned NOT NULL,
  `tipo_ejercicio` varchar(90) COLLATE utf8mb4_unicode_ci NOT NULL,
  `alimentacion` enum('omnivora','vegetariana','vegana','otra') COLLATE utf8mb4_unicode_ci NOT NULL,
  `alergias` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `prefiere_organico` tinyint(1) NOT NULL DEFAULT '0',
  `consiente_datos` tinyint(1) NOT NULL DEFAULT '0',
  `actualizado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`usuario_id`),
  CONSTRAINT `perfiles_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `perfiles`
--

LOCK TABLES `perfiles` WRITE;
/*!40000 ALTER TABLE `perfiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `perfiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `presentaciones`
--

DROP TABLE IF EXISTS `presentaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `presentaciones` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `formato` enum('polvo','barrita') COLLATE utf8mb4_unicode_ci NOT NULL,
  `porciones` smallint unsigned NOT NULL,
  `precio_base` decimal(10,2) NOT NULL,
  `descripcion` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `activo` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `presentaciones`
--

LOCK TABLES `presentaciones` WRITE;
/*!40000 ALTER TABLE `presentaciones` DISABLE KEYS */;
INSERT INTO `presentaciones` VALUES (1,'Polvo · 15 porciones','polvo',15,90.00,'Bolsa resellable; 15 porciones de demostración',1),(2,'Polvo · 30 porciones','polvo',30,150.00,'Bolsa resellable; 30 porciones de demostración',1),(3,'Barritas · 6 piezas','barrita',6,130.00,'Caja con seis barritas de demostración',1),(4,'Barritas · 12 piezas','barrita',12,230.00,'Caja con doce barritas de demostración',1);
/*!40000 ALTER TABLE `presentaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productos`
--

DROP TABLE IF EXISTS `productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productos` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(170) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `foto` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'assets/img/producto.svg',
  `precio` decimal(10,2) NOT NULL,
  `cantidad_almacen` int unsigned NOT NULL DEFAULT '0',
  `fabricante` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `origen` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `categoria` enum('base','sabor','suplemento','fibra','pack') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pack',
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `productos_chk_1` CHECK ((`precio` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productos`
--

LOCK TABLES `productos` WRITE;
/*!40000 ALTER TABLE `productos` DISABLE KEYS */;
INSERT INTO `productos` VALUES (1,'Kit Proteína de suero (Whey)','Kit demostrativo: Proteína láctea para complementar la ingesta diaria. Ingredientes y existencia sujetos a disponibilidad.','assets/img/product_01.svg',299.00,30,'crafted (demo)','México','base',1,'2026-11-16 18:07:52'),(2,'Kit Aislado de suero','Kit demostrativo: Proteína láctea concentrada, con menos lactosa que el concentrado. Ingredientes y existencia sujetos a disponibilidad.','assets/img/product_02.svg',328.00,32,'crafted (demo)','Estados Unidos','base',1,'2026-11-16 18:07:52'),(3,'Kit Proteína de chícharo','Kit demostrativo: Alternativa proteica de origen vegetal. Ingredientes y existencia sujetos a disponibilidad.','assets/img/product_03.svg',357.00,34,'crafted (demo)','Canadá','base',1,'2026-11-16 18:07:52'),(4,'Kit Proteína de arroz','Kit demostrativo: Alternativa vegetal elaborada a partir de arroz. Ingredientes y existencia sujetos a disponibilidad.','assets/img/product_04.svg',386.00,36,'crafted (demo)','México','base',1,'2026-11-16 18:07:52'),(5,'Kit Proteína de soya','Kit demostrativo: Proteína vegetal de alta calidad. Ingredientes y existencia sujetos a disponibilidad.','assets/img/product_05.svg',415.00,38,'crafted (demo)','México','base',1,'2026-11-16 18:07:52'),(6,'Kit Mezcla vegetal','Kit demostrativo: Combinación de proteínas vegetales. Ingredientes y existencia sujetos a disponibilidad.','assets/img/product_06.svg',444.00,40,'crafted (demo)','México','base',1,'2026-11-16 18:07:52'),(7,'Sabor Chocolate · pack','Complemento de sabor chocolate para recetas de proteína; producto ilustrativo.','assets/img/product_07.svg',99.00,35,'crafted (demo)','México','sabor',1,'2026-11-16 18:07:52'),(8,'Sabor Vainilla · pack','Complemento de sabor vainilla para recetas de proteína; producto ilustrativo.','assets/img/product_08.svg',107.00,37,'crafted (demo)','México','sabor',1,'2026-11-16 18:07:52'),(9,'Sabor Fresa · pack','Complemento de sabor fresa para recetas de proteína; producto ilustrativo.','assets/img/product_09.svg',115.00,39,'crafted (demo)','México','sabor',1,'2026-11-16 18:07:52'),(10,'Sabor Plátano · pack','Complemento de sabor plátano para recetas de proteína; producto ilustrativo.','assets/img/product_10.svg',123.00,41,'crafted (demo)','México','sabor',1,'2026-11-16 18:07:52'),(11,'Sabor Café · pack','Complemento de sabor café para recetas de proteína; producto ilustrativo.','assets/img/product_11.svg',131.00,43,'crafted (demo)','México','sabor',1,'2026-11-16 18:07:52'),(12,'Sabor Canela · pack','Complemento de sabor canela para recetas de proteína; producto ilustrativo.','assets/img/product_12.svg',139.00,45,'crafted (demo)','México','sabor',1,'2026-11-16 18:07:52'),(13,'Sabor Cacao intenso · pack','Complemento de sabor cacao intenso para recetas de proteína; producto ilustrativo.','assets/img/product_13.svg',147.00,47,'crafted (demo)','México','sabor',1,'2026-11-16 18:07:52'),(14,'Sabor Frutos rojos · pack','Complemento de sabor frutos rojos para recetas de proteína; producto ilustrativo.','assets/img/product_14.svg',155.00,49,'crafted (demo)','México','sabor',1,'2026-11-16 18:07:52'),(15,'Complemento Creatina monohidratada','Ingrediente utilizado en nutrición deportiva; consultar evidencia y precauciones. Producto educativo de demostración.','assets/img/product_15.svg',149.00,25,'crafted (demo)','Por verificar','suplemento',1,'2026-11-16 18:07:52'),(16,'Complemento Vitamina B12','Micronutriente que interviene en funciones metabólicas. Producto educativo de demostración.','assets/img/product_16.svg',162.00,27,'crafted (demo)','Por verificar','suplemento',1,'2026-11-16 18:07:52'),(17,'Complemento Vitamina C','Vitamina hidrosoluble para complementar la dieta. Producto educativo de demostración.','assets/img/product_17.svg',175.00,29,'crafted (demo)','Por verificar','suplemento',1,'2026-11-16 18:07:52'),(18,'Complemento Vitamina D3','Micronutriente liposoluble; requiere revisión de ingesta total. Producto educativo de demostración.','assets/img/product_18.svg',188.00,31,'crafted (demo)','Por verificar','suplemento',1,'2026-11-16 18:07:52'),(19,'Complemento Magnesio','Mineral esencial en diversas funciones del organismo; la forma química importa. Producto educativo de demostración.','assets/img/product_19.svg',201.00,33,'crafted (demo)','Por verificar','suplemento',1,'2026-11-16 18:07:52'),(20,'Complemento Zinc','Mineral esencial; requiere revisar otras fuentes de ingesta. Producto educativo de demostración.','assets/img/product_20.svg',214.00,35,'crafted (demo)','Por verificar','suplemento',1,'2026-11-16 18:07:52'),(21,'Complemento Cacao natural','Ingrediente botánico de cacao sin afirmación orgánica automática. Producto educativo de demostración.','assets/img/product_21.svg',227.00,37,'crafted (demo)','Por verificar','suplemento',1,'2026-11-16 18:07:52'),(22,'Complemento Espirulina','Biomasa de cianobacterias para uso alimentario de calidad verificada. Producto educativo de demostración.','assets/img/product_22.svg',240.00,39,'crafted (demo)','Por verificar','suplemento',1,'2026-11-16 18:07:52'),(23,'Complemento Maca en polvo','Ingrediente de origen vegetal; beneficios no garantizados. Producto educativo de demostración.','assets/img/product_23.svg',253.00,41,'crafted (demo)','Por verificar','suplemento',1,'2026-11-16 18:07:52'),(24,'Complemento Matcha','Té verde molido; contiene cafeína. Producto educativo de demostración.','assets/img/product_24.svg',266.00,43,'crafted (demo)','Por verificar','suplemento',1,'2026-11-16 18:07:52'),(25,'Fibra Inulina','Fuente de fibra: Inulina. Producto educativo de demostración.','assets/img/product_25.svg',115.00,42,'crafted (demo)','Por verificar','fibra',1,'2026-11-16 18:07:52'),(26,'Fibra Psyllium','Fuente de fibra: Psyllium. Producto educativo de demostración.','assets/img/product_26.svg',126.00,43,'crafted (demo)','Por verificar','fibra',1,'2026-11-16 18:07:52'),(27,'Fibra Fibra de avena','Fuente de fibra: Fibra de avena. Producto educativo de demostración.','assets/img/product_27.svg',137.00,44,'crafted (demo)','Por verificar','fibra',1,'2026-11-16 18:07:52'),(28,'Fibra Fibra de acacia','Fuente de fibra: Fibra de acacia. Producto educativo de demostración.','assets/img/product_28.svg',148.00,45,'crafted (demo)','Por verificar','fibra',1,'2026-11-16 18:07:52'),(29,'Fibra Linaza molida','Fuente de fibra: Linaza molida. Producto educativo de demostración.','assets/img/product_29.svg',159.00,46,'crafted (demo)','Por verificar','fibra',1,'2026-11-16 18:07:52'),(30,'Fibra Chía molida','Fuente de fibra: Chía molida. Producto educativo de demostración.','assets/img/product_30.svg',170.00,47,'crafted (demo)','Por verificar','fibra',1,'2026-11-16 18:07:52'),(31,'Fibra Fibra de manzana','Fuente de fibra: Fibra de manzana. Producto educativo de demostración.','assets/img/product_31.svg',181.00,48,'crafted (demo)','Por verificar','fibra',1,'2026-11-16 18:07:52'),(32,'Pack Polvo · 15 porciones','Bolsa resellable; 15 porciones de demostración. Presentación ilustrativa para catálogo.','assets/img/product_32.svg',200.00,26,'crafted (demo)','México','pack',1,'2026-11-16 18:07:52'),(33,'Pack Polvo · 30 porciones','Bolsa resellable; 30 porciones de demostración. Presentación ilustrativa para catálogo.','assets/img/product_33.svg',260.00,29,'crafted (demo)','México','pack',1,'2026-11-16 18:07:52'),(34,'Pack Barritas · 6 piezas','Caja con seis barritas de demostración. Presentación ilustrativa para catálogo.','assets/img/product_34.svg',240.00,32,'crafted (demo)','México','pack',1,'2026-11-16 18:07:52'),(35,'Pack Barritas · 12 piezas','Caja con doce barritas de demostración. Presentación ilustrativa para catálogo.','assets/img/product_35.svg',340.00,35,'crafted (demo)','México','pack',1,'2026-11-16 18:07:52');
/*!40000 ALTER TABLE `productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sesiones_persistentes`
--

DROP TABLE IF EXISTS `sesiones_persistentes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sesiones_persistentes` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint unsigned NOT NULL,
  `selector` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  `verificador_hash` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `vence_en` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `selector` (`selector`),
  KEY `usuario_id` (`usuario_id`),
  CONSTRAINT `sesiones_persistentes_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sesiones_persistentes`
--

LOCK TABLES `sesiones_persistentes` WRITE;
/*!40000 ALTER TABLE `sesiones_persistentes` DISABLE KEYS */;
/*!40000 ALTER TABLE `sesiones_persistentes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correo` varchar(190) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_nacimiento` date NOT NULL,
  `direccion_postal` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `tarjeta_ultimos4` char(4) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'No almacenar PAN completo',
  `rol` enum('cliente','admin') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cliente',
  `creado_en` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `correo` (`correo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Current Database: `crafted`
--

USE `crafted`;

--
-- Final view structure for view `historial_compras`
--

/*!50001 DROP VIEW IF EXISTS `historial_compras`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `historial_compras` AS select `c`.`id` AS `id_compra`,`c`.`usuario_id` AS `usuario`,`dc`.`producto_id` AS `producto`,`dc`.`formula_id` AS `formula_id`,`dc`.`nombre_snapshot` AS `nombre_snapshot`,`dc`.`cantidad` AS `cantidad`,`dc`.`subtotal` AS `subtotal`,`c`.`creado_en` AS `creado_en` from (`compras` `c` join `detalle_compra` `dc` on((`dc`.`compra_id` = `c`.`id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-16 12:07:52
