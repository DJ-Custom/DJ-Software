-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: software_dj
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `ajuste_detalle`
--

DROP TABLE IF EXISTS `ajuste_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ajuste_detalle` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ajuste_id` bigint(20) unsigned NOT NULL,
  `producto_id` bigint(20) unsigned NOT NULL,
  `stock_sistema` int(11) NOT NULL DEFAULT 0,
  `stock_fisico` int(11) DEFAULT NULL,
  `cantidad_ajuste` int(11) NOT NULL DEFAULT 0,
  `notas` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ajuste_detalle_ajuste_id_foreign` (`ajuste_id`),
  KEY `ajuste_detalle_producto_id_foreign` (`producto_id`),
  CONSTRAINT `ajuste_detalle_ajuste_id_foreign` FOREIGN KEY (`ajuste_id`) REFERENCES `ajustes_inventario` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ajuste_detalle_producto_id_foreign` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ajuste_detalle`
--

LOCK TABLES `ajuste_detalle` WRITE;
/*!40000 ALTER TABLE `ajuste_detalle` DISABLE KEYS */;
INSERT INTO `ajuste_detalle` VALUES (1,1,1,50,NULL,30,NULL,'2026-06-04 01:39:17'),(2,1,2,15,NULL,30,NULL,'2026-06-04 01:39:35'),(3,2,1,50,NULL,0,NULL,'2026-06-04 02:04:06'),(4,2,1,50,30,-20,NULL,'2026-06-04 02:04:18');
/*!40000 ALTER TABLE `ajuste_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ajustes_inventario`
--

DROP TABLE IF EXISTS `ajustes_inventario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ajustes_inventario` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `numero_ajuste` varchar(255) NOT NULL,
  `tipo` varchar(255) NOT NULL,
  `motivo` varchar(255) NOT NULL,
  `motivo_detalle` text DEFAULT NULL,
  `ubicacion_id` bigint(20) unsigned DEFAULT NULL,
  `usuario_id` bigint(20) unsigned NOT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'borrador',
  `notas` text DEFAULT NULL,
  `aplicado_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ajustes_inventario_numero_ajuste_unique` (`numero_ajuste`),
  KEY `ajustes_inventario_ubicacion_id_foreign` (`ubicacion_id`),
  KEY `ajustes_inventario_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `ajustes_inventario_ubicacion_id_foreign` FOREIGN KEY (`ubicacion_id`) REFERENCES `ubicaciones` (`id`) ON DELETE SET NULL,
  CONSTRAINT `ajustes_inventario_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ajustes_inventario`
--

LOCK TABLES `ajustes_inventario` WRITE;
/*!40000 ALTER TABLE `ajustes_inventario` DISABLE KEYS */;
INSERT INTO `ajustes_inventario` VALUES (1,'AJ-20260603-7046','conteo','correccion','Si',1,1,'aplicado',NULL,'2026-06-04 01:39:48','2026-06-04 01:39:03','2026-06-04 01:39:48'),(2,'AJ-20260603-4509','conteo','correccion','NHJ',1,1,'aplicado',NULL,'2026-06-04 02:04:27','2026-06-04 02:03:57','2026-06-04 02:04:27'),(3,'AJ-20260615-6690','conteo','correccion','hola',1,1,'borrador','.',NULL,'2026-06-15 16:21:29','2026-06-15 16:21:29');
/*!40000 ALTER TABLE `ajustes_inventario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asiento_detalle`
--

DROP TABLE IF EXISTS `asiento_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asiento_detalle` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `asiento_id` bigint(20) unsigned NOT NULL,
  `cuenta_id` bigint(20) unsigned NOT NULL,
  `debe` decimal(12,2) NOT NULL DEFAULT 0.00,
  `haber` decimal(12,2) NOT NULL DEFAULT 0.00,
  `descripcion` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `asiento_detalle_asiento_id_foreign` (`asiento_id`),
  KEY `asiento_detalle_cuenta_id_foreign` (`cuenta_id`),
  CONSTRAINT `asiento_detalle_asiento_id_foreign` FOREIGN KEY (`asiento_id`) REFERENCES `asientos_contables` (`id`) ON DELETE CASCADE,
  CONSTRAINT `asiento_detalle_cuenta_id_foreign` FOREIGN KEY (`cuenta_id`) REFERENCES `cuentas_contables` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asiento_detalle`
--

LOCK TABLES `asiento_detalle` WRITE;
/*!40000 ALTER TABLE `asiento_detalle` DISABLE KEYS */;
/*!40000 ALTER TABLE `asiento_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `asientos_contables`
--

DROP TABLE IF EXISTS `asientos_contables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `asientos_contables` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `numero` varchar(255) NOT NULL,
  `fecha` date NOT NULL,
  `descripcion` text DEFAULT NULL,
  `referencia_tipo` varchar(255) DEFAULT NULL,
  `referencia_id` bigint(20) unsigned DEFAULT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `asientos_contables_numero_unique` (`numero`),
  KEY `asientos_contables_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `asientos_contables_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asientos_contables`
--

LOCK TABLES `asientos_contables` WRITE;
/*!40000 ALTER TABLE `asientos_contables` DISABLE KEYS */;
/*!40000 ALTER TABLE `asientos_contables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auditoria`
--

DROP TABLE IF EXISTS `auditoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auditoria` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `accion` varchar(10) NOT NULL,
  `modulo` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `auditable_id` bigint(20) unsigned DEFAULT NULL,
  `auditable_type` varchar(100) DEFAULT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `user_agent` varchar(500) DEFAULT NULL,
  `url` varchar(500) DEFAULT NULL,
  `codigo_respuesta` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `auditoria_usuario_id_created_at_index` (`usuario_id`,`created_at`),
  KEY `auditoria_modulo_index` (`modulo`),
  KEY `auditoria_auditable_type_auditable_id_index` (`auditable_type`,`auditable_id`),
  CONSTRAINT `auditoria_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=242 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auditoria`
--

LOCK TABLES `auditoria` WRITE;
/*!40000 ALTER TABLE `auditoria` DISABLE KEYS */;
INSERT INTO `auditoria` VALUES (1,NULL,'created','roles','Creó Role #1',1,'App\\Models\\Role',NULL,'{\"nombre\":\"Administrador\",\"descripcion\":\"Acceso total al sistema\",\"id\":1}','127.0.0.1','Symfony','http://localhost',NULL,'2026-05-22 09:20:42'),(2,NULL,'created','usuarios','Creó User #1',1,'App\\Models\\User',NULL,'{\"email\":\"admin@sdj.com\",\"nombre\":\"Administrador\",\"rol_id\":1,\"activo\":true,\"theme_mode\":\"dark\",\"id\":1}','127.0.0.1','Symfony','http://localhost',NULL,'2026-05-22 09:20:42'),(3,1,'POST','productividad','POST api/productividad/sesion',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productividad/sesion',200,'2026-05-22 09:55:47'),(4,1,'POST','auth','POST api/auth/toggle-theme',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',500,'2026-05-22 10:18:01'),(5,1,'POST','productividad','POST api/productividad/cerrar-sesion',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productividad/cerrar-sesion',200,'2026-05-22 11:31:25'),(6,1,'POST','logout','POST api/logout',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/logout',200,'2026-05-22 11:31:26'),(7,1,'POST','productividad','POST api/productividad/sesion',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productividad/sesion',200,'2026-05-22 23:43:46'),(8,1,'POST','auth','POST api/auth/toggle-theme',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',500,'2026-05-22 23:43:54'),(9,1,'POST','auth','POST api/auth/toggle-theme',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',500,'2026-05-22 23:44:03'),(10,1,'POST','auth','POST api/auth/toggle-theme',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',500,'2026-05-22 23:44:04'),(11,1,'POST','auth','POST api/auth/toggle-theme',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',500,'2026-05-22 23:44:04'),(12,1,'POST','configuracion','POST api/configuracion/ubicaciones',NULL,NULL,NULL,'{\"nombre\":\"Tienda Grecia\",\"tipo\":\"sucursal\",\"direccion\":null,\"telefono\":\"88888888\",\"responsable\":\"Jay\",\"lat\":\"10.072344986604936\",\"lng\":\"-84.31163349893521\",\"activo\":true}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/configuracion/ubicaciones',200,'2026-05-22 23:48:35'),(13,1,'POST','configuracion','POST api/configuracion/cajas',NULL,NULL,NULL,'{\"nombre\":\"Caja principal\",\"ubicacion_id\":1,\"activo\":true}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/configuracion/cajas',200,'2026-05-22 23:48:48'),(14,1,'POST','caja','POST api/caja/abrir',NULL,NULL,NULL,'{\"caja_id\":1,\"monto_apertura\":50000}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/caja/abrir',200,'2026-05-22 23:49:06'),(15,1,'POST','caja','POST api/caja/cerrar',NULL,NULL,NULL,'{\"sesion_id\":1,\"monto_cierre\":50000,\"notas_cierre\":\"No se vendio\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/caja/cerrar',200,'2026-05-22 23:49:35'),(16,1,'created','productos','Creó Producto #1',1,'App\\Models\\Producto',NULL,'{\"codigo\":\"camisa1\",\"codigo_barras\":null,\"nombre\":\"Camisa\",\"categoria_id\":null,\"proveedor_id\":null,\"precio_compra\":\"2000.00\",\"precio_venta\":\"8000.00\",\"stock\":30,\"stock_minimo\":10,\"impuesto\":\"13.00\",\"activo\":true,\"id\":1}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productos',NULL,'2026-05-22 23:51:43'),(17,1,'POST','productos','POST api/productos',NULL,NULL,NULL,'{\"codigo\":\"camisa1\",\"codigo_barras\":null,\"nombre\":\"Camisa\",\"categoria_id\":null,\"proveedor_id\":null,\"precio_compra\":2000,\"precio_venta\":8000,\"stock\":30,\"stock_minimo\":10,\"impuesto\":13,\"activo\":1,\"inventario_ubicaciones\":[{\"ubicacion_id\":1,\"ubicacion_nombre\":\"Tienda Grecia\",\"cantidad\":0,\"cantidad_reservada\":0,\"stock_minimo\":null,\"stock_maximo\":null}]}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productos',200,'2026-05-22 23:51:43'),(18,1,'PUT','productos','PUT api/productos/1',NULL,NULL,NULL,'{\"id\":1,\"codigo\":\"camisa1\",\"codigo_barras\":null,\"nombre\":\"Camisa\",\"descripcion\":null,\"categoria_id\":null,\"proveedor_id\":null,\"precio_compra\":\"2000.00\",\"precio_venta\":\"8000.00\",\"stock\":30,\"stock_minimo\":10,\"stock_maximo\":null,\"unidad\":null,\"imagen\":null,\"impuesto\":\"13.00\",\"margen_ganancia\":null,\"peso\":null,\"costo_envio\":null,\"costo_marketing\":null,\"costo_logistica\":null,\"visible_web\":false,\"activo\":true,\"created_at\":\"2026-05-22T17:51:43.000000Z\",\"updated_at\":\"2026-05-22T17:51:43.000000Z\",\"inventario_ubicaciones\":[{\"id\":1,\"ubicacion_id\":1,\"ubicacion_nombre\":\"Tienda Grecia\",\"ubicacion_tipo\":\"sucursal\",\"cantidad\":10,\"cantidad_reservada\":0,\"stock_minimo\":null,\"stock_maximo\":null,\"estado\":\"activo\",\"updated_at\":\"2026-05-22 17:51:43\"}],\"categoria\":null,\"variantes\":[],\"imagenes\":[],\"proveedor\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productos/1',200,'2026-05-22 23:51:53'),(19,1,'created','ventas','Creó Venta #1',1,'App\\Models\\Venta',NULL,'{\"numero_factura\":\"VTA-20260522-0001\",\"cliente_id\":null,\"usuario_id\":1,\"ubicacion_id\":1,\"subtotal\":\"8000.00\",\"descuento_total\":\"0.00\",\"impuesto_total\":\"1040.00\",\"total\":\"9040.00\",\"metodo_pago\":\"efectivo\",\"monto_efectivo\":10000,\"monto_tarjeta\":0,\"monto_sinpe\":0,\"referencia_sinpe\":\"\",\"dinero_recibido\":10000,\"cambio\":960,\"estado\":\"completada\",\"notas\":\"\",\"id\":1}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ventas',NULL,'2026-05-22 23:53:11'),(20,1,'created','venta_detalle','Creó VentaDetalle #1',1,'App\\Models\\VentaDetalle',NULL,'{\"venta_id\":1,\"producto_id\":1,\"cantidad\":1,\"precio_unitario\":\"8000.00\",\"descuento\":0,\"impuesto\":1040,\"subtotal\":8000,\"id\":1}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ventas',NULL,'2026-05-22 23:53:11'),(21,1,'POST','ventas','POST api/ventas',NULL,NULL,NULL,'{\"ubicacion_id\":1,\"cliente_id\":null,\"nombre_factura\":\"David\",\"items\":[{\"producto_id\":1,\"cantidad\":1,\"precio_unitario\":\"8000.00\",\"descuento\":0,\"impuesto\":1040,\"subtotal\":8000,\"combo_id\":null}],\"metodo_pago\":\"efectivo\",\"subtotal\":8000,\"descuento_total\":0,\"impuesto_total\":1040,\"total\":9040,\"notas\":null,\"monto_efectivo\":10000,\"dinero_recibido\":10000,\"cambio\":960}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ventas',200,'2026-05-22 23:53:11'),(22,1,'POST','cotizaciones','POST api/cotizaciones',NULL,NULL,NULL,'{\"cliente_id\":null,\"cliente_nombre\":null,\"fecha_vencimiento\":\"2026-05-29\",\"items\":[{\"producto_id\":1,\"nombre\":\"Camisa\",\"cantidad\":1,\"precio_unitario\":\"8000.00\",\"descuento\":0}],\"notas\":\"Producto prueba\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/cotizaciones',200,'2026-05-22 23:55:51'),(23,1,'POST','ticket-designer','POST api/ticket-designer',NULL,NULL,NULL,'{\"ancho_mm\":80,\"fuente\":\"Verdana\",\"fuente_size\":12,\"mostrar_logo\":1,\"mostrar_nombre_negocio\":1,\"mostrar_direccion\":1,\"mostrar_telefono\":1,\"mostrar_cedula\":1,\"mostrar_vendedor\":false,\"mostrar_cliente\":1,\"mostrar_fecha\":1,\"mostrar_detalle_impuesto\":1,\"mostrar_descuento\":1,\"mostrar_metodo_pago\":1,\"mostrar_codigo_producto\":0,\"mostrar_sinpe_info\":1,\"header_text\":null,\"footer_text\":\"¡Gracias por su compra!\",\"logo_path\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ticket-designer',200,'2026-05-22 23:59:19'),(24,1,'POST','etiquetas','POST api/etiquetas',NULL,NULL,NULL,'{\"nombre\":\"Cliente David\",\"color\":\"#25b136\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/etiquetas',200,'2026-05-23 00:05:52'),(25,1,'created','roles','Creó Role #2',2,'App\\Models\\Role',NULL,'{\"nombre\":\"Vendedor\",\"descripcion\":null,\"permisos\":[\"ventas\",\"chats\",\"listas_precios\",\"clientes\",\"caja\"],\"id\":2}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/roles',NULL,'2026-05-23 00:29:41'),(26,1,'POST','roles','POST api/roles',NULL,NULL,NULL,'{\"nombre\":\"Vendedor\",\"descripcion\":null,\"activo\":true,\"permisos\":[\"ventas\",\"chats\",\"listas_precios\",\"clientes\",\"caja\"]}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/roles',200,'2026-05-23 00:29:41'),(27,1,'created','usuarios','Creó User #2',2,'App\\Models\\User',NULL,'{\"nombre\":\"David Alpizar\",\"email\":\"admin@david.com\",\"rol_id\":2,\"modulos_acceso\":null,\"activo\":true,\"id\":2}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/usuarios',NULL,'2026-05-23 00:30:15'),(28,1,'POST','usuarios','POST api/usuarios',NULL,NULL,NULL,'{\"nombre\":\"David Alpizar\",\"email\":\"admin@david.com\",\"rol_id\":2}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/usuarios',200,'2026-05-23 00:30:15'),(29,2,'POST','productividad','POST api/productividad/sesion',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productividad/sesion',200,'2026-05-23 00:30:39'),(30,2,'POST','auth','POST api/auth/toggle-theme',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',500,'2026-05-23 00:30:48'),(31,1,'created','chats','Creó Chat #1',1,'App\\Models\\Chat',NULL,'{\"titulo\":\"Reunion\",\"descripcion\":\"Hoy reunion a las 9am\",\"creador_id\":1,\"estado\":\"abierto\",\"id\":1}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats',NULL,'2026-05-23 00:31:16'),(32,1,'POST','chats','POST api/chats',NULL,NULL,NULL,'{\"titulo\":\"Reunion\",\"descripcion\":\"Hoy reunion a las 9am\",\"participantes\":[2]}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats',200,'2026-05-23 00:31:16'),(33,1,'POST','chats','POST api/chats/1/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/leido',200,'2026-05-23 00:31:19'),(35,1,'POST','chats','POST api/chats/1/mensajes',NULL,NULL,NULL,'{\"contenido\":\"Hola buenas tardes😄\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/mensajes',500,'2026-05-23 00:31:33'),(36,1,'POST','chats','POST api/chats/1/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/leido',200,'2026-05-23 00:31:51'),(37,1,'POST','chats','POST api/chats/1/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/leido',200,'2026-05-23 00:31:52'),(38,1,'POST','productividad','POST api/productividad/cerrar-sesion',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productividad/cerrar-sesion',200,'2026-05-23 00:32:24'),(39,1,'POST','logout','POST api/logout',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/logout',200,'2026-05-23 00:32:24'),(40,1,'POST','productividad','POST api/productividad/sesion',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productividad/sesion',200,'2026-05-23 00:32:27'),(41,1,'POST','chats','POST api/chats/1/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/leido',200,'2026-05-23 00:32:30'),(42,1,'POST','chats','POST api/chats/1/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/leido',200,'2026-05-23 00:32:31'),(43,1,'POST','chats','POST api/chats/1/cerrar',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/cerrar',500,'2026-05-23 00:32:33'),(44,1,'POST','chats','POST api/chats/1/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/leido',200,'2026-05-23 00:33:31'),(45,1,'POST','chats','POST api/chats/1/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/leido',200,'2026-05-23 00:34:35'),(46,1,'created','notificaciones','Creó Notificacion #1',1,'App\\Models\\Notificacion',NULL,'{\"titulo\":\"Nuevo Producto\",\"mensaje\":\"Ingreso nueva camisa color negra!\",\"color\":\"#049014\",\"icono\":\"fas fa-info-circle\",\"tipo\":\"informativa\",\"prioridad\":\"normal\",\"creador_id\":1,\"global\":true,\"enviada_en\":\"2026-05-22T18:37:23.000000Z\",\"id\":1}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones',NULL,'2026-05-23 00:37:23'),(47,1,'POST','notificaciones','POST api/notificaciones',NULL,NULL,NULL,'{\"titulo\":\"Nuevo Producto\",\"mensaje\":\"Ingreso nueva camisa color negra!\",\"tipo\":\"informativa\",\"prioridad\":\"normal\",\"color\":\"#049014\",\"icono\":\"fas fa-info-circle\",\"global\":true,\"destinatarios\":[],\"roles\":[]}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones',200,'2026-05-23 00:37:25'),(48,2,'DELETE','notificaciones','DELETE api/notificaciones/1/descartar',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones/1/descartar',200,'2026-05-23 00:37:55'),(49,1,'POST','productividad','POST api/productividad/cerrar-sesion',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productividad/cerrar-sesion',200,'2026-05-23 00:41:54'),(50,1,'POST','logout','POST api/logout',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/logout',200,'2026-05-23 00:41:54'),(51,1,'POST','productividad','POST api/productividad/sesion',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productividad/sesion',200,'2026-05-23 00:42:02'),(52,1,'POST','notificaciones','POST api/notificaciones/leer-todas',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones/leer-todas',200,'2026-05-23 00:42:33'),(53,1,'DELETE','notificaciones','DELETE api/notificaciones/1/descartar',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones/1/descartar',200,'2026-05-23 00:42:36'),(54,1,'POST','ticket-designer','POST api/ticket-designer/logo',NULL,NULL,NULL,'{\"logo\":{}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ticket-designer/logo',200,'2026-05-23 03:13:19'),(55,1,'POST','ticket-designer','POST api/ticket-designer',NULL,NULL,NULL,'{\"ancho_mm\":80,\"fuente\":\"Verdana\",\"fuente_size\":12,\"mostrar_logo\":1,\"mostrar_nombre_negocio\":1,\"mostrar_direccion\":1,\"mostrar_telefono\":1,\"mostrar_cedula\":1,\"mostrar_vendedor\":true,\"mostrar_cliente\":1,\"mostrar_fecha\":1,\"mostrar_detalle_impuesto\":1,\"mostrar_descuento\":1,\"mostrar_metodo_pago\":1,\"mostrar_codigo_producto\":0,\"mostrar_sinpe_info\":1,\"header_text\":null,\"footer_text\":\"¡Gracias por su compra!\",\"logo_path\":\"ticket-logos\\/Mm08cXJX1Z18HQBBJ7sSX5HNNGyb3w6RjD92uv7O.png\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ticket-designer',200,'2026-05-23 03:13:29'),(56,1,'POST','chats','POST api/chats/1/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/leido',200,'2026-05-23 03:15:04'),(57,1,'POST','email-builder','POST api/email-builder/campaigns',NULL,NULL,NULL,'{\"nombre\":\"lol\",\"asunto\":null,\"html_content\":\"* { box-sizing: border-box; } body {margin: 0;}\",\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[],\\\"pages\\\":[{\\\"frames\\\":[{\\\"component\\\":{\\\"type\\\":\\\"wrapper\\\",\\\"stylable\\\":[\\\"background\\\",\\\"background-color\\\",\\\"background-image\\\",\\\"background-repeat\\\",\\\"background-attachment\\\",\\\"background-position\\\",\\\"background-size\\\"],\\\"head\\\":{\\\"type\\\":\\\"head\\\"},\\\"docEl\\\":{\\\"tagName\\\":\\\"html\\\"}},\\\"id\\\":\\\"eXMWFSbjddjBM1YK\\\"}],\\\"type\\\":\\\"main\\\",\\\"id\\\":\\\"ABS2CMsu78HQedOw\\\"}],\\\"symbols\\\":[]}\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/email-builder/campaigns',422,'2026-05-23 03:28:41'),(58,1,'created','email_campaigns','Creó EmailCampaign #1',1,'App\\Models\\EmailCampaign',NULL,'{\"nombre\":\"lol\",\"asunto\":\"lol\",\"html_content\":\"* { box-sizing: border-box; } body {margin: 0;}\",\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[],\\\"pages\\\":[{\\\"frames\\\":[{\\\"component\\\":{\\\"type\\\":\\\"wrapper\\\",\\\"stylable\\\":[\\\"background\\\",\\\"background-color\\\",\\\"background-image\\\",\\\"background-repeat\\\",\\\"background-attachment\\\",\\\"background-position\\\",\\\"background-size\\\"],\\\"head\\\":{\\\"type\\\":\\\"head\\\"},\\\"docEl\\\":{\\\"tagName\\\":\\\"html\\\"}},\\\"id\\\":\\\"eXMWFSbjddjBM1YK\\\"}],\\\"type\\\":\\\"main\\\",\\\"id\\\":\\\"ABS2CMsu78HQedOw\\\"}],\\\"symbols\\\":[]}\",\"estado\":\"borrador\",\"usuario_id\":1,\"id\":1}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/email-builder/campaigns',NULL,'2026-05-23 03:28:47'),(59,1,'POST','email-builder','POST api/email-builder/campaigns',NULL,NULL,NULL,'{\"nombre\":\"lol\",\"asunto\":\"lol\",\"html_content\":\"* { box-sizing: border-box; } body {margin: 0;}\",\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[],\\\"pages\\\":[{\\\"frames\\\":[{\\\"component\\\":{\\\"type\\\":\\\"wrapper\\\",\\\"stylable\\\":[\\\"background\\\",\\\"background-color\\\",\\\"background-image\\\",\\\"background-repeat\\\",\\\"background-attachment\\\",\\\"background-position\\\",\\\"background-size\\\"],\\\"head\\\":{\\\"type\\\":\\\"head\\\"},\\\"docEl\\\":{\\\"tagName\\\":\\\"html\\\"}},\\\"id\\\":\\\"eXMWFSbjddjBM1YK\\\"}],\\\"type\\\":\\\"main\\\",\\\"id\\\":\\\"ABS2CMsu78HQedOw\\\"}],\\\"symbols\\\":[]}\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/email-builder/campaigns',200,'2026-05-23 03:28:47'),(60,1,'POST','ticket-designer','POST api/ticket-designer',NULL,NULL,NULL,'{\"ancho_mm\":80,\"fuente\":\"Verdana\",\"fuente_size\":12,\"mostrar_logo\":1,\"mostrar_nombre_negocio\":1,\"mostrar_direccion\":1,\"mostrar_telefono\":1,\"mostrar_cedula\":1,\"mostrar_vendedor\":1,\"mostrar_cliente\":1,\"mostrar_fecha\":1,\"mostrar_detalle_impuesto\":1,\"mostrar_descuento\":1,\"mostrar_metodo_pago\":1,\"mostrar_codigo_producto\":0,\"mostrar_sinpe_info\":1,\"header_text\":null,\"footer_text\":\"¡Gracias por su compra!\",\"logo_path\":\"ticket-logos\\/Mm08cXJX1Z18HQBBJ7sSX5HNNGyb3w6RjD92uv7O.png\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ticket-designer',200,'2026-05-23 03:49:29'),(61,1,'POST','chats','POST api/chats/1/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/leido',200,'2026-05-23 03:54:22'),(62,1,'created','chat_mensajes','Creó ChatMensaje #2',2,'App\\Models\\ChatMensaje',NULL,'{\"chat_id\":\"1\",\"usuario_id\":1,\"contenido\":\"Hola\",\"id\":2,\"archivo_url_completa\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/mensajes',NULL,'2026-05-23 03:54:24'),(63,1,'POST','chats','POST api/chats/1/mensajes',NULL,NULL,NULL,'{\"contenido\":\"Hola\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/mensajes',200,'2026-05-23 03:54:27'),(64,1,'created','chat_mensajes','Creó ChatMensaje #3',3,'App\\Models\\ChatMensaje',NULL,'{\"chat_id\":\"1\",\"usuario_id\":1,\"contenido\":\"😄😄😄\",\"id\":3,\"archivo_url_completa\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/mensajes',NULL,'2026-05-23 03:54:32'),(65,1,'POST','chats','POST api/chats/1/mensajes',NULL,NULL,NULL,'{\"contenido\":\"😄😄😄\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/mensajes',200,'2026-05-23 03:54:34'),(66,2,'POST','productividad','POST api/productividad/sesion',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productividad/sesion',200,'2026-05-23 03:55:11'),(67,2,'POST','chats','POST api/chats/1/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/leido',200,'2026-05-23 03:55:19'),(68,2,'POST','auth','POST api/auth/toggle-theme',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',500,'2026-05-23 03:55:23'),(69,2,'POST','chats','POST api/chats/1/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/leido',200,'2026-05-23 03:55:25'),(70,2,'created','chat_mensajes','Creó ChatMensaje #4',4,'App\\Models\\ChatMensaje',NULL,'{\"chat_id\":\"1\",\"usuario_id\":2,\"contenido\":\"Hola hola\",\"id\":4,\"archivo_url_completa\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/mensajes',NULL,'2026-05-23 03:55:31'),(71,2,'POST','chats','POST api/chats/1/mensajes',NULL,NULL,NULL,'{\"contenido\":\"Hola hola\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/mensajes',200,'2026-05-23 03:55:33'),(72,2,'POST','chats','POST api/chats/1/mensajes',NULL,NULL,NULL,'{\"archivo\":[]}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/mensajes',422,'2026-05-23 03:55:38'),(73,2,'POST','chats','POST api/chats/1/mensajes',NULL,NULL,NULL,'{\"contenido\":\"Hola\",\"archivo\":[]}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/mensajes',422,'2026-05-23 03:55:45'),(74,2,'POST','chats','POST api/chats/1/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/leido',200,'2026-05-23 04:00:44'),(75,1,'PUT','email-builder','PUT api/email-builder/campaigns/1',NULL,NULL,NULL,'{\"nombre\":\"lol\",\"asunto\":\"lol\",\"html_content\":\"\",\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[{\\\"selectors\\\":[\\\"#i7mm\\\"],\\\"style\\\":{\\\"background-color\\\":\\\"#f75555\\\",\\\"padding-bottom\\\":\\\"29px\\\"},\\\"wrapper\\\":1}],\\\"pages\\\":[],\\\"symbols\\\":[]}\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/email-builder/campaigns/1',500,'2026-05-23 04:07:01'),(76,1,'PUT','email-builder','PUT api/email-builder/campaigns/1',NULL,NULL,NULL,'{\"nombre\":\"lol\",\"asunto\":\"lol\",\"html_content\":\"\",\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[{\\\"selectors\\\":[\\\"#i7mm\\\"],\\\"style\\\":{\\\"background-color\\\":\\\"#f75555\\\",\\\"padding-bottom\\\":\\\"29px\\\"},\\\"wrapper\\\":1}],\\\"pages\\\":[],\\\"symbols\\\":[]}\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/email-builder/campaigns/1',500,'2026-05-23 04:09:45'),(77,1,'POST','chats','POST api/chats/1/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/leido',200,'2026-05-23 04:57:33'),(78,1,'POST','chats','POST api/chats/1/mensajes',NULL,NULL,NULL,'{\"archivo\":{}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/mensajes',422,'2026-05-23 04:57:40'),(79,1,'POST','chats','POST api/chats/1/mensajes',NULL,NULL,NULL,'{\"archivo\":{}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/mensajes',422,'2026-05-23 04:57:43'),(80,1,'POST','chats','POST api/chats/1/mensajes',NULL,NULL,NULL,'{\"archivo\":{}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/mensajes',422,'2026-05-23 04:57:56'),(81,1,'POST','chats','POST api/chats/1/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/leido',200,'2026-05-23 05:10:21'),(82,1,'POST','chats','POST api/chats/1/mensajes',NULL,NULL,NULL,'{\"archivo\":{}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/mensajes',422,'2026-05-23 05:10:25'),(83,1,'POST','chats','POST api/chats/1/mensajes',NULL,NULL,NULL,'{\"archivo\":{}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/mensajes',422,'2026-05-23 05:10:37'),(84,1,'POST','chats','POST api/chats/1/mensajes',NULL,NULL,NULL,'{\"contenido\":\"asd\",\"archivo\":{}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/mensajes',422,'2026-05-23 05:10:42'),(85,2,'POST','auth','POST api/auth/toggle-theme',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',500,'2026-05-23 05:14:51'),(86,1,'POST','chats','POST api/chats/1/mensajes',NULL,NULL,NULL,'{\"contenido\":\"asd\",\"archivo\":{}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/mensajes',422,'2026-05-23 05:14:56'),(87,1,'POST','productividad','POST api/productividad/cerrar-sesion',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productividad/cerrar-sesion',200,'2026-05-30 01:22:16'),(88,1,'POST','logout','POST api/logout',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/logout',200,'2026-05-30 01:22:16'),(89,1,'POST','productividad','POST api/productividad/sesion',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productividad/sesion',200,'2026-05-30 01:27:18'),(90,1,'created','ventas','Creó Venta #2',2,'App\\Models\\Venta',NULL,'{\"numero_factura\":\"VTA-20260529-0001\",\"cliente_id\":null,\"usuario_id\":1,\"ubicacion_id\":1,\"subtotal\":\"16000.00\",\"descuento_total\":\"0.00\",\"impuesto_total\":\"2080.00\",\"total\":\"18080.00\",\"metodo_pago\":\"efectivo\",\"monto_efectivo\":19000,\"monto_tarjeta\":0,\"monto_sinpe\":0,\"referencia_sinpe\":\"\",\"dinero_recibido\":19000,\"cambio\":920,\"estado\":\"completada\",\"notas\":\"\",\"id\":2}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ventas',NULL,'2026-05-30 01:28:26'),(91,1,'created','venta_detalle','Creó VentaDetalle #2',2,'App\\Models\\VentaDetalle',NULL,'{\"venta_id\":2,\"producto_id\":1,\"cantidad\":2,\"precio_unitario\":\"8000.00\",\"descuento\":0,\"impuesto\":2080,\"subtotal\":16000,\"id\":2}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ventas',NULL,'2026-05-30 01:28:26'),(92,1,'POST','ventas','POST api/ventas',NULL,NULL,NULL,'{\"ubicacion_id\":1,\"cliente_id\":null,\"nombre_factura\":\"David\",\"items\":[{\"producto_id\":1,\"cantidad\":2,\"precio_unitario\":\"8000.00\",\"descuento\":0,\"impuesto\":2080,\"subtotal\":16000,\"combo_id\":null}],\"metodo_pago\":\"efectivo\",\"subtotal\":16000,\"descuento_total\":0,\"impuesto_total\":2080,\"total\":18080,\"notas\":null,\"monto_efectivo\":19000,\"dinero_recibido\":19000,\"cambio\":920}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ventas',200,'2026-05-30 01:28:26'),(93,1,'created','ventas','Creó Venta #3',3,'App\\Models\\Venta',NULL,'{\"numero_factura\":\"VTA-20260529-0002\",\"cliente_id\":null,\"usuario_id\":1,\"ubicacion_id\":1,\"subtotal\":\"16000.00\",\"descuento_total\":\"0.00\",\"impuesto_total\":\"2080.00\",\"total\":\"18080.00\",\"metodo_pago\":\"efectivo\",\"monto_efectivo\":19000,\"monto_tarjeta\":0,\"monto_sinpe\":0,\"referencia_sinpe\":\"\",\"dinero_recibido\":19000,\"cambio\":920,\"estado\":\"completada\",\"notas\":\"\",\"id\":3}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ventas',NULL,'2026-05-30 01:28:26'),(94,1,'created','venta_detalle','Creó VentaDetalle #3',3,'App\\Models\\VentaDetalle',NULL,'{\"venta_id\":3,\"producto_id\":1,\"cantidad\":2,\"precio_unitario\":\"8000.00\",\"descuento\":0,\"impuesto\":2080,\"subtotal\":16000,\"id\":3}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ventas',NULL,'2026-05-30 01:28:26'),(95,1,'POST','ventas','POST api/ventas',NULL,NULL,NULL,'{\"ubicacion_id\":1,\"cliente_id\":null,\"nombre_factura\":\"David\",\"items\":[{\"producto_id\":1,\"cantidad\":2,\"precio_unitario\":\"8000.00\",\"descuento\":0,\"impuesto\":2080,\"subtotal\":16000,\"combo_id\":null}],\"metodo_pago\":\"efectivo\",\"subtotal\":16000,\"descuento_total\":0,\"impuesto_total\":2080,\"total\":18080,\"notas\":null,\"monto_efectivo\":19000,\"dinero_recibido\":19000,\"cambio\":920}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ventas',200,'2026-05-30 01:28:26'),(96,1,'POST','caja','POST api/caja/abrir',NULL,NULL,NULL,'{\"caja_id\":1,\"monto_apertura\":50000}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/caja/abrir',200,'2026-05-30 01:28:27'),(97,1,'POST','caja','POST api/caja/abrir',NULL,NULL,NULL,'{\"caja_id\":1,\"monto_apertura\":50000}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/caja/abrir',400,'2026-05-30 01:28:28'),(98,1,'POST','auth','POST api/auth/toggle-theme',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',500,'2026-05-30 01:32:15'),(99,1,'POST','auth','POST api/auth/toggle-theme',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',500,'2026-05-30 01:32:15'),(100,1,'POST','auth','POST api/auth/toggle-theme',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',500,'2026-05-30 01:32:16'),(101,1,'POST','auth','POST api/auth/toggle-theme',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',500,'2026-05-30 01:32:30'),(102,1,'PUT','email-builder','PUT api/email-builder/campaigns/1',NULL,NULL,NULL,'{\"nombre\":\"lol\",\"asunto\":\"lol\",\"html_content\":\"\",\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[],\\\"pages\\\":[],\\\"symbols\\\":[]}\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/email-builder/campaigns/1',500,'2026-05-30 01:45:56'),(103,1,'POST','configuracion','POST api/configuracion/ubicaciones',NULL,NULL,NULL,'{\"nombre\":\"Tienda Naranjo\",\"tipo\":\"almacen\",\"direccion\":\"Naranjo\",\"telefono\":\"00000000\",\"responsable\":\"David\",\"lat\":\"10.09698437049689\",\"lng\":\"-84.37971997431058\",\"activo\":true}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/configuracion/ubicaciones',200,'2026-05-30 01:49:42'),(104,1,'PUT','usuarios','PUT api/usuarios/2',NULL,NULL,NULL,'{\"nombre\":\"David Alpizar\",\"email\":\"admin@david.com\",\"rol_id\":2}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/usuarios/2',500,'2026-05-30 01:58:34'),(105,NULL,'updated','usuarios','Modificó User #2',2,'App\\Models\\User','{\"intentos_fallidos\":0}','{\"intentos_fallidos\":1,\"auditOriginal\":{\"id\":2,\"nombre\":\"David Alpizar\",\"email\":\"admin@david.com\",\"password\":\"***REDACTED***\",\"rol_id\":2,\"avatar\":null,\"activo\":true,\"theme_mode\":\"light\",\"pin_rapido\":\"***REDACTED***\",\"auto_logout_min\":null,\"modulos_acceso\":null,\"secret_2fa\":\"***REDACTED***\",\"two_fa_enabled\":false,\"ip_whitelist\":null,\"intentos_fallidos\":0,\"bloqueado_hasta\":null,\"ultimo_login\":null,\"token_recuperacion\":\"***REDACTED***\",\"created_at\":\"2026-05-22T18:30:15.000000Z\",\"updated_at\":\"2026-05-22T18:30:15.000000Z\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/login',NULL,'2026-05-30 01:58:38'),(106,NULL,'updated','usuarios','Modificó User #2',2,'App\\Models\\User','{\"intentos_fallidos\":1}','{\"intentos_fallidos\":2,\"auditOriginal\":{\"id\":2,\"nombre\":\"David Alpizar\",\"email\":\"admin@david.com\",\"password\":\"***REDACTED***\",\"rol_id\":2,\"avatar\":null,\"activo\":true,\"theme_mode\":\"light\",\"pin_rapido\":\"***REDACTED***\",\"auto_logout_min\":null,\"modulos_acceso\":null,\"secret_2fa\":\"***REDACTED***\",\"two_fa_enabled\":false,\"ip_whitelist\":null,\"intentos_fallidos\":1,\"bloqueado_hasta\":null,\"ultimo_login\":null,\"token_recuperacion\":\"***REDACTED***\",\"created_at\":\"2026-05-22T18:30:15.000000Z\",\"updated_at\":\"2026-05-29T19:58:38.000000Z\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/login',NULL,'2026-05-30 01:58:44'),(107,NULL,'updated','usuarios','Modificó User #2',2,'App\\Models\\User','{\"intentos_fallidos\":2}','{\"intentos_fallidos\":3,\"auditOriginal\":{\"id\":2,\"nombre\":\"David Alpizar\",\"email\":\"admin@david.com\",\"password\":\"***REDACTED***\",\"rol_id\":2,\"avatar\":null,\"activo\":true,\"theme_mode\":\"light\",\"pin_rapido\":\"***REDACTED***\",\"auto_logout_min\":null,\"modulos_acceso\":null,\"secret_2fa\":\"***REDACTED***\",\"two_fa_enabled\":false,\"ip_whitelist\":null,\"intentos_fallidos\":2,\"bloqueado_hasta\":null,\"ultimo_login\":null,\"token_recuperacion\":\"***REDACTED***\",\"created_at\":\"2026-05-22T18:30:15.000000Z\",\"updated_at\":\"2026-05-29T19:58:44.000000Z\"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/login',NULL,'2026-05-30 01:58:49'),(108,1,'created','usuarios','Creó User #3',3,'App\\Models\\User',NULL,'{\"nombre\":\"Rodrigo\",\"email\":\"admin@gigroup.com\",\"rol_id\":2,\"modulos_acceso\":null,\"activo\":true,\"id\":3}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/usuarios',NULL,'2026-05-30 01:59:34'),(109,1,'POST','usuarios','POST api/usuarios',NULL,NULL,NULL,'{\"nombre\":\"Rodrigo\",\"email\":\"admin@gigroup.com\",\"rol_id\":2}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/usuarios',200,'2026-05-30 01:59:34'),(110,3,'POST','productividad','POST api/productividad/sesion',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productividad/sesion',200,'2026-05-30 01:59:53'),(112,1,'POST','notificaciones','POST api/notificaciones',NULL,NULL,NULL,'{\"titulo\":\"Reunion a las 3\",\"mensaje\":\"Hola\",\"tipo\":\"recordatorio\",\"prioridad\":\"normal\",\"color\":\"#00ff04\",\"icono\":\"fas fa-clock\",\"global\":false,\"destinatarios\":[],\"roles\":[]}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones',500,'2026-05-30 02:02:25'),(114,1,'POST','notificaciones','POST api/notificaciones',NULL,NULL,NULL,'{\"titulo\":\"Reunion a las 3\",\"mensaje\":\"Hola\",\"tipo\":\"recordatorio\",\"prioridad\":\"normal\",\"color\":\"#00ff04\",\"icono\":\"fas fa-clock\",\"global\":false,\"destinatarios\":[],\"roles\":[]}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones',500,'2026-05-30 02:02:27'),(115,1,'created','notificaciones','Creó Notificacion #4',4,'App\\Models\\Notificacion',NULL,'{\"titulo\":\"Reunion a las 3\",\"mensaje\":\"Hola\",\"color\":\"#00ff04\",\"icono\":\"fas fa-clock\",\"tipo\":\"recordatorio\",\"prioridad\":\"normal\",\"creador_id\":1,\"global\":true,\"enviada_en\":\"2026-05-29T20:02:30.000000Z\",\"id\":4}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones',NULL,'2026-05-30 02:02:30'),(116,1,'POST','notificaciones','POST api/notificaciones',NULL,NULL,NULL,'{\"titulo\":\"Reunion a las 3\",\"mensaje\":\"Hola\",\"tipo\":\"recordatorio\",\"prioridad\":\"normal\",\"color\":\"#00ff04\",\"icono\":\"fas fa-clock\",\"global\":true,\"destinatarios\":[],\"roles\":[]}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones',200,'2026-05-30 02:02:33'),(117,1,'created','notificaciones','Creó Notificacion #5',5,'App\\Models\\Notificacion',NULL,'{\"titulo\":\"Reunion a las 3\",\"mensaje\":\"Hola\",\"color\":\"#00ff04\",\"icono\":\"fas fa-clock\",\"tipo\":\"recordatorio\",\"prioridad\":\"normal\",\"creador_id\":1,\"global\":true,\"enviada_en\":\"2026-05-29T20:02:34.000000Z\",\"id\":5}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones',NULL,'2026-05-30 02:02:34'),(118,1,'POST','notificaciones','POST api/notificaciones',NULL,NULL,NULL,'{\"titulo\":\"Reunion a las 3\",\"mensaje\":\"Hola\",\"tipo\":\"recordatorio\",\"prioridad\":\"normal\",\"color\":\"#00ff04\",\"icono\":\"fas fa-clock\",\"global\":true,\"destinatarios\":[],\"roles\":[]}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones',200,'2026-05-30 02:02:34'),(119,3,'DELETE','notificaciones','DELETE api/notificaciones/5/descartar',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones/5/descartar',200,'2026-05-30 02:02:56'),(120,3,'DELETE','notificaciones','DELETE api/notificaciones/1/descartar',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones/1/descartar',200,'2026-05-30 02:03:00'),(121,3,'DELETE','notificaciones','DELETE api/notificaciones/4/descartar',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones/4/descartar',200,'2026-05-30 02:03:02'),(122,1,'DELETE','notificaciones','DELETE api/notificaciones/4/descartar',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones/4/descartar',200,'2026-05-30 02:04:05'),(123,1,'DELETE','notificaciones','DELETE api/notificaciones/5/descartar',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones/5/descartar',200,'2026-05-30 02:04:07'),(124,1,'POST','chats','POST api/chats/1/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/leido',200,'2026-05-30 02:11:20'),(125,1,'created','chats','Creó Chat #2',2,'App\\Models\\Chat',NULL,'{\"titulo\":\"Preguntas de filtros\",\"descripcion\":null,\"creador_id\":1,\"estado\":\"abierto\",\"id\":2}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats',NULL,'2026-05-30 02:11:56'),(126,1,'POST','chats','POST api/chats',NULL,NULL,NULL,'{\"titulo\":\"Preguntas de filtros\",\"descripcion\":null,\"participantes\":[3]}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats',200,'2026-05-30 02:11:56'),(127,1,'POST','chats','POST api/chats/2/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/2/leido',200,'2026-05-30 02:12:00'),(128,1,'created','chat_mensajes','Creó ChatMensaje #5',5,'App\\Models\\ChatMensaje',NULL,'{\"chat_id\":\"2\",\"usuario_id\":1,\"contenido\":\"Hola😁\",\"id\":5,\"archivo_url_completa\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/2/mensajes',NULL,'2026-05-30 02:12:11'),(129,1,'POST','chats','POST api/chats/2/mensajes',NULL,NULL,NULL,'{\"contenido\":\"Hola😁\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/2/mensajes',200,'2026-05-30 02:12:14'),(130,3,'POST','chats','POST api/chats/2/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/2/leido',200,'2026-05-30 02:13:07'),(131,1,'POST','chats','POST api/chats/2/cerrar',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/2/cerrar',500,'2026-05-30 02:13:20'),(132,1,'POST','chats','POST api/chats/2/leido',NULL,NULL,NULL,'[]','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/2/leido',200,'2026-05-30 02:13:30'),(133,1,'updated','usuarios','Modificó User #2',2,'App\\Models\\User','{\"password\":\"***REDACTED***\"}','{\"password\":\"***REDACTED***\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/usuarios/2',200,'2026-06-02 07:14:19'),(134,1,'updated','chats','Modificó Chat #2',2,'App\\Models\\Chat','{\"estado\":\"abierto\",\"cerrado_por\":null,\"cerrado_en\":null}','{\"estado\":\"cerrado\",\"cerrado_por\":1,\"cerrado_en\":\"2026-06-02T01:15:51.488376Z\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/2/cerrar',200,'2026-06-02 07:15:51'),(135,1,'updated','email_campaigns','Modificó EmailCampaign #1',1,'App\\Models\\EmailCampaign','{\"html_content\":\"* { box-sizing: border-box; } body {margin: 0;}\",\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[],\\\"pages\\\":[{\\\"frames\\\":[{\\\"component\\\":{\\\"type\\\":\\\"wrapper\\\",\\\"stylable\\\":[\\\"background\\\",\\\"background-color\\\",\\\"background-image\\\",\\\"background-repeat\\\",\\\"background-attachment\\\",\\\"background-position\\\",\\\"background-size\\\"],\\\"head\\\":{\\\"type\\\":\\\"head\\\"},\\\"docEl\\\":{\\\"tagName\\\":\\\"html\\\"}},\\\"id\\\":\\\"eXMWFSbjddjBM1YK\\\"}],\\\"type\\\":\\\"main\\\",\\\"id\\\":\\\"ABS2CMsu78HQedOw\\\"}],\\\"symbols\\\":[]}\"}','{\"html_content\":\"\",\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[],\\\"pages\\\":[],\\\"symbols\\\":[]}\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/email-builder/campaigns/1',200,'2026-06-02 07:20:10'),(136,1,'updated','usuarios','Modificó User #2',2,'App\\Models\\User','{\"activo\":true}','{\"activo\":false}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/usuarios/2/toggle',200,'2026-06-03 08:12:13'),(137,1,'updated','usuarios','Modificó User #2',2,'App\\Models\\User','{\"activo\":false}','{\"activo\":true}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/usuarios/2/toggle',200,'2026-06-03 08:12:15'),(138,1,'created','chat_mensajes','Creó ChatMensaje #6',6,'App\\Models\\ChatMensaje',NULL,'{\"chat_id\":\"1\",\"usuario_id\":1,\"contenido\":\"\",\"archivo_url\":\"chat_adjuntos\\/6dd97830-ef57-450d-85f1-c7b7575600a3.png\",\"archivo_nombre\":\"LOGO.png\",\"archivo_tipo\":\"image\\/png\",\"archivo_size\":177506,\"id\":6,\"archivo_url_completa\":\"http:\\/\\/127.0.0.1:8000\\/storage\\/chat_adjuntos\\/6dd97830-ef57-450d-85f1-c7b7575600a3.png\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/mensajes',200,'2026-06-03 08:12:35'),(139,1,'deleted','email_campaigns','Eliminó EmailCampaign #1',1,'App\\Models\\EmailCampaign','{\"id\":1,\"nombre\":\"lol\",\"asunto\":\"lol\",\"html_content\":\"\",\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[],\\\"pages\\\":[],\\\"symbols\\\":[]}\",\"thumbnail\":null,\"estado\":\"borrador\",\"usuario_id\":1,\"programada_para\":null,\"enviada_en\":null,\"total_recipients\":0,\"total_enviados\":0,\"total_abiertos\":0,\"total_clicks\":0,\"total_rebotes\":0}',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/email-builder/campaigns/1',200,'2026-06-03 08:39:40'),(140,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-03 09:00:43'),(141,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-03 09:00:45'),(142,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-03 09:00:45'),(143,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-03 09:00:46'),(144,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-03 09:00:47'),(145,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-03 09:00:47'),(146,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-03 09:00:48'),(147,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-03 09:00:49'),(148,1,'created','clientes','Creó Cliente #1',1,'App\\Models\\Cliente',NULL,'{\"nombre\":\"Jose Hernandez\",\"cedula\":\"512341234\",\"empresa\":null,\"cedula_juridica\":null,\"telefono\":\"88778877\",\"email\":null,\"direccion\":null,\"ciudad\":null,\"clasificacion\":\"regular\",\"credito_tienda\":\"0.00\",\"activo\":true,\"id\":1}','127.0.0.1','Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36','http://127.0.0.1:8000/api/clientes',200,'2026-06-03 22:35:50'),(149,1,'created','productos','Creó Producto #2',2,'App\\Models\\Producto',NULL,'{\"codigo\":\"Botella1\",\"codigo_barras\":null,\"nombre\":\"Botella de metal\",\"categoria_id\":null,\"proveedor_id\":null,\"precio_compra\":\"1500.00\",\"precio_venta\":\"4500.00\",\"stock\":0,\"stock_minimo\":5,\"impuesto\":\"13.00\",\"activo\":true,\"id\":2}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productos',200,'2026-06-04 00:47:11'),(150,1,'updated','productos','Modificó Producto #2',2,'App\\Models\\Producto','{\"stock_minimo\":5}','{\"stock_minimo\":10}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productos/2',200,'2026-06-04 00:47:40'),(151,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-04 01:36:35'),(152,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-04 01:36:37'),(153,1,'updated','productos','Modificó Producto #2',2,'App\\Models\\Producto','{\"proveedor_id\":null}','{\"proveedor_id\":1}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productos/2',200,'2026-06-04 02:25:20'),(154,1,'deleted','chats','Eliminó Chat #2',2,'App\\Models\\Chat','{\"id\":2,\"titulo\":\"Preguntas de filtros\",\"descripcion\":null,\"creador_id\":1,\"estado\":\"cerrado\",\"cerrado_por\":1,\"cerrado_en\":\"2026-06-02 01:15:51\"}',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/2',200,'2026-06-04 04:03:59'),(155,1,'created','email_campaigns','Creó EmailCampaign #2',2,'App\\Models\\EmailCampaign',NULL,'{\"nombre\":\"Lol\",\"asunto\":\"xd\",\"html_content\":\"* { box-sizing: border-box; } body {margin: 0;}#igyb{max-width:100%;display:block;border-radius:8px;width:177px;height:222px;}#i1uk{padding:0;text-align:center;}#iosh{background-color:#bdeae7;}#ie5ff{margin:0;}#iibsm{padding:20px;font-family:Arial,sans-serif;font-size:16px;line-height:1.7;color:#374151;}<table width=\\\"100%\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" border=\\\"0\\\"><tbody><tr><td id=\\\"i1uk\\\"><img src=\\\"data:image\\/png;base64,iVBORw0KGgoAAAANSUhEUgAABDgAAAVGCAYAAAB7TwuKAAAAtGVYSWZJSSoACAAAAAYAEgEDAAEAAAABAAAAGgEFAAEAAABWAAAAGwEFAAEAAABeAAAAKAEDAAEAAAACAAAAEwIDAAEAAAABAAAAaYcEAAEAAABmAAAAAAAAAGAAAAABAAAAYAAAAAEAAAAGAACQBwAEAAAAMDIxMAGRBwAEAAAAAQIDAACgBwAEAAAAMDEwMAGgAwABAAAA\\/\\/8AAAKgBAABAAAAOAQAAAOgBAABAAAARgUAAAAAAADTyGbmAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAFXGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSfvu78nIGlkPSdXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQnPz4KPHg6eG1wbWV0YSB4bWxuczp4PSdhZG9iZTpuczptZXRhLyc+CjxyZGY6UkRGIHhtbG5zOnJkZj0naHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyc+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczpBdHRyaWI9J2h0dHA6Ly9ucy5hdHRyaWJ1dGlvbi5jb20vYWRzLzEuMC8nPgogIDxBdHRyaWI6QWRzPgogICA8cmRmOlNlcT4KICAgIDxyZGY6bGkgcmRmOnBhcnNlVHlwZT0nUmVzb3VyY2UnPgogICAgIDxBdHRyaWI6Q3JlYXRlZD4yMDI2LTA1LTA3PC9BdHRyaWI6Q3JlYXRlZD4KICAgICA8QXR0cmliOkRhdGE+eyZxdW90O2RvYyZxdW90OzomcXVvdDtEQUhHWXBzZmxSTSZxdW90OywmcXVvdDt1c2VyJnF1b3Q7OiZxdW90O1VBRU9OVndMYVdZJnF1b3Q7LCZxdW90O2JyYW5kJnF1b3Q7OiZxdW90O1RlY25vRmlicmFzIFMuQSYjMzk7cyB0ZWFtJnF1b3Q7fTwvQXR0cmliOkRhdGE+CiAgICAgPEF0dHJpYjpFeHRJZD44NGRkMzJmMy0yNzZiLTQ3ZjctYWZmYS04NTM0YmMzM2VhMDA8L0F0dHJpYjpFeHRJZD4KICAgICA8QXR0cmliOkZiSWQ+NTI1MjY1OTE0MTc5NTgwPC9BdHRyaWI6RmJJZD4KICAgICA8QXR0cmliOlRvdWNoVHlwZT4yPC9BdHRyaWI6VG91Y2hUeXBlPgogICAgPC9yZGY6bGk+CiAgIDwvcmRmOlNlcT4KICA8L0F0dHJpYjpBZHM+CiA8L3JkZjpEZXNjcmlwdGlvbj4KCiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0nJwogIHhtbG5zOmRjPSdodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyc+CiAgPGRjOnRpdGxlPgogICA8cmRmOkFsdD4KICAgIDxyZGY6bGkgeG1sOmxhbmc9J3gtZGVmYXVsdCc+MjAwMCAyMDAwIC0gNDwvcmRmOmxpPgogICA8L3JkZjpBbHQ+CiAgPC9kYzp0aXRsZT4KIDwvcmRmOkRlc2NyaXB0aW9uPgoKIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PScnCiAgeG1sbnM6cGRmPSdodHRwOi8vbnMuYWRvYmUuY29tL3BkZi8xLjMvJz4KICA8cGRmOkF1dGhvcj5EYXZpZCBBbHBpemFyPC9wZGY6QXV0aG9yPgogPC9yZGY6RGVzY3JpcHRpb24+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczp4bXA9J2h0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8nPgogIDx4bXA6Q3JlYXRvclRvb2w+Q2FudmEgZG9jPURBSEdZcHNmbFJNIHVzZXI9VUFFT05Wd0xhV1kgYnJhbmQ9VGVjbm9GaWJyYXMgUy5BJiMzOTtzIHRlYW08L3htcDpDcmVhdG9yVG9vbD4KIDwvcmRmOkRlc2NyaXB0aW9uPgo8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSdyJz8+6JVLDgAAIABJREFUeJzs3QucXXlBH\\/D\\/edzHzL137ryTzWZD2KRsG2GXNaIuIAQBEVrUVlNFtFItW6VKX7i2aCUisKw8FlAei0qrFNQtSq20FC2syMpredR3axUtoPtxLbC47DPJTM+5904yj3snyZw5c2fu\\/X4\\/n1\\/ObDaEzf+ef3LOL\\/\\/zPyEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAnPPkLB8V2eHcMTE19fwAAAAA2yJJTkYhPpt9dUZkB7PUaLVfHgAAAGA7JEnyrSFES9mXeZZFdiCd822i1boxAAAAwHZIqsm3KThkh6PgAAAAYHspOGQIWSk4PKICAADA9lBwyBCi4AAAAGB7JUnyrNC74QzDv\\/GV8YhHVAAAANheSZJ8e1BwyM6mW3C02woOAAAAtkeSJM8OCg7Z2XTOt8l2+2UBAAAAtkOSJN8RFByys1FwAAAMQbTFsDO2+vn47KAnSZLvDAoO2dl0zrdmq\\/3SAABAeZaXl6NVifPcurycrGS5m\\/gCiQZl2L++vWazsVw\\/7iuf0anbbktXcv0tt1ROnjpVXZ\\/8+\\/PkP+bWtZ+pz4ixouCQIaRzvjVaVnAAAJSi0m5\\/RbXZ\\/HeN6embW9Ozr27Nz7+6Obfwuqm5xTe0Zxff3J5ffHNrsZNbphYX35jlp6YWsn+fJftxr82Tff2aZjc3t+YXX5X92Fe2s2Rf\\/0SWm9oLiy9vLSzcmOWl2Y99ydTcwo9nP8+Lp+bnT2V50dTs7I\\/mac7O\\/rtO5uZ+JMsPd48LK\\/nh1tzcC1szc\\/+2NTPzQwNyQ5YfLDk39LL6\\/3P9f8e\\/WUmj+8\\/5f3P+3\\/7C3q\\/tR\\/Jf58qve2q2Mw4\\/lo9L9u9e0ppbeGmWG1tz8zdln0c+hq\\/ojeurm\\/MLN2c\\/5rXNmXz8536qOTf\\/hsmZuTc2Z+ZvmZyd\\/eksPzs5Pf3vJ6dnfm5ievqt9ZmZt2d5W+fYnnnbxPTMW7Pv\\/\\/nJ6dl\\/35ie\\/ZnJmdk3NWfmXt\\/IP\\/u5uRubs\\/M\\/lv+3NmZnX5CdE\\/98cmrqnzWbzesbjcZ3TTSb31prtb6h0W4\\/uX3Z\\/Je39+17+OTk5IHQbC5MHz48ffC66ybCyZNJsCqEPUDBIUNI9xEVKzgAALbfrbfemlQnW2\\/Jvnwwy+ksZ1bl7CY5UzCnZWAudSw3+5wuJX0+m+ih7JgnPz8eyHJflnuyfCHLXVk+G6Lo\\/0ZR9EdprfaBSrX+C3G1emM6MfGvJxqNZ03Mzj52\\/qqrrrr2cU89cP2pU5MBdhEFhwwh3YKjqeAAANh2J289Va01Wu8OnRvcaOVC\\/2Iu+Nf\\/WNnhRN3kz5Vs64X3Bf9\\/o2hDBvzYvBD5Yoiiv4zS9Pertfp7klrtJ6uTkz\\/cnF34h3P79z9mcXHxynzlx+HDh+vhVIgD7CQFh+x8egVHS8EBALDdTt56a7XWaL4ndP8Gf9gXfrJ306\\/gGPT9+bmWrxC5P8tfRXH8sbSavqM1N3fD\\/OWXP+nqr\\/zKh5\\/sPuYCpbKCQ4YQBQcAQFlO5QVHc0rBITuZ86s\\/wpoVIA+FKPpCFMd\\/GiXJ+2r1+ptrzeb3ziweeNyRI0cWr7\\/++kqAbZQkyT8KCg7Z2Sg4AADKkhcc9ebU\\/wgu8GV3ZN1qj0758aXs+Pu1yebrpxcWnvPwL7v2mhMnTjSz71\\/ZzBS2Jkm+Kyg4ZGfTLThaCg4AgG33A697Xa3eaL0vuMCX3ZUN+35kx7PZ8YEoiv8iSpIPJ7Xam5szM9fPzu4\\/dtVVV7UCXCoFh+x8FBwAAGXpFBxNBYfs7kRRtHJcv7lpvpfHnVGU\\/Hp9svmimcWZxy0sLOw\\/fvy4x1m4sCT5x0HBITsbBQcAQFme3ik4mu8NLvBlb6Xf5qV52XF3FEWfrExMvKY9O\\/vUr3r2s6cCDJIk\\/zhScMjORsEBAFCW7gqOqd8INhmVPZ4Nr62NorvTNL2tWq\\/\\/WKPdfsq+I0cWw6lTXkXLOUmSfLeCQ3Y4nfOt0Wq\\/LAAAsL3y18TWp9p5weECX0YtK5uU5l8\\/GKLod6r1yRcefeTxI8vLyyubk9qkdIwlSfI9Cg7Z4Sg4AADKkr9FZbI9\\/evBCg4Z0USdTUrjXtkRPZR936eTSvUXq43Gd1x+9OjBwNhScMgQouAAAChLXnA0ZmffExQcMh5ZvWfH2ShNPzw5NfW8K44+8kj2z9VgRcdYSZLKP1FwyA6nc741W217cAAAbLdewfHfg4JDxiurXkEb3xfF8R8ntdot7X2XP\\/nqr\\/u6RmA8VCrPVXDIDkfBAQBQlltuuaXSmpl9d1BwyNgm35g0WXmE5Z4kTd\\/dmJl51uyBA1ecOHEiDYysOI6vV3DIDkfBAQBQlk7BMTv7X4OCQ8Y6UX7s3ehGZ0MU5as6fq\\/ZnHr+tdd+zUJgJMWVyvcqOGSHo+AAACjLLbd8rNKamX9XUHDImCbq5dw\\/d141u7Ipabg3SZKPTDSb33\\/ZZZc9LASvmR0llUrl+xQcssPpnG+TrZaCAwBgu93ysU7B8V\\/CuYIjGvbFn8huyrkNSbP82exlB5\\/7zOuvnwxdNiTd4yqVyvPiSMEhOxoFBwBAWW67bTlVcIhsnnxVR+g+vnJvlCR3TEw0\\/vllD3\\/4wwJ7Wl5wRAoO2dkoOAAAytJ7REXBIXJROffoyukoiu5ozMw8+8AjHjEf2IuiSqXy\\/R5RkR2OPTgAAMpy23JnBcevhnMX+AoOkQtkqbtPR7SyouO97dmFf3j8mc9ceXSFvaFTcOSPqEQKDtm5dAqORqv9sgAAwPa67bbb0tbc\\/DuDgkPkUrPyatl87tyTVCr\\/YWpu7jHHjh2rBvaCvOD4AQWH7HCs4AAAKMup225L23OLCg6RradzwxJFUf6Y111prXrTw44fvyyw250rOIKCQ3YuVnAAAJTltk7BsfArQcEhUjQrj62ciaLkQ\\/VG47uuvPLKdmC3imIFh+x8FBwAAGW5dXk5ac8t\\/nJQcIhsV1ZumE8nlcovTh84cO3JkyeTwG7TWcGRKDhkZ6PgAAAoi4JDpJSs3DSfyfKptDpxw\\/6jRxcCu4lHVGQYUXAAAJSlV3C8I3Q3TFxWcIhsa5ai7g30mSiK3jc1u++rg01Id4vuW1RiBYfsaHoFR0vBAQCw3fKCY3p+\\/629t0EsKzhEtjf5vhxxHOc3NfkmpHemtdoLTp46peQYvk7BkSg4ZGfjLSoAAGXpFBwLCg6RHcjKjfSXoiR5x2S7fTwsL0eBYckLjn\\/mERXZ4Sg4AADKkhccM\\/P7f0nBIbJj6b1tJfxFa27um3obkCo6hqBSqTyvW3BECg7ZqSg4AADK0i049v1SsAeHyE5mZdXAXXGavmT+iisOBCXHjqtUKt9nBYfscGwyCgBQlk7BsbC\\/V3DkF18KDpGdSm8lx5koSd4ze+josezrOLBjFBwyhCg4AADKouAQGWpWHlc5E6Lojyanp78hsGPiSuV784IjUnDIzkXBAQBQFgWHyK7IStFxZ21i4gWHDh2aCZROwSFDiIIDAKAsy8vLsYJDZLiJomg5juKlOO6UHPcnSeXnrrr2WvtylCyuxB5RkZ2OggMAoCwKDpFdl3wunk7S9L\\/PX375IwKlie3BITufXsHRUnAAAGw3BYfIrk0+Jz+8\\/9ChLwuUQsEhQ0jnfJtUcAAAbD8Fh8iuTedGKIqiT07Pzz\\/x1KlT3rCyzeJK5XlRUHDIjkbBAQBQll7B8YtBwSGyW7MUovDpyZmZZwSvkd1W+QoOBYfscHoFhz04AAC2nRUcIrs+3RvwKPrURLP5zSGcSAPbIq5Uro9DpOCQnYyCAwCgLJ2CY58VHCJ7IPkc\\/Wy12TwZTig5tkWl8k8iBYfsbBQcAABlyQuOWQWHyB5IfiOe5PP08\\/XJye\\/OjkmgkCRJvlvBITucbsHRVnAAAGy77gqOfQoOkT2Rczfjf1lvNJ5z\\/PjxSmDLkiR5TrAHh+xsFBwAAGXp7sGx7xeCgkNkD6VTdHx+dmHh6wNbliTJPwrnCw4pJ7tgvuyqKDgAAMqi4BDZk1l5hewnLjvyt48HtiRJkmeHVTfj2XiubOi69p\\/XfX2h5D92fS72fzvo59nK\\/77fz7fx+7rZrp9\\/1VtpluLuf\\/uw58pui4IDAKAsCg6RvZveDev\\/nplZfFxgKx6d5U1ZXt\\/LLVl+Osube1\\/n\\/+6NWd6Q5aey\\/GSW12V5bZbXZLm5l1evOuZ51eDEeV65Kr3v2+x\\/08kFft5zeeUF\\/l2eV\\/TyE9n\\/d56bsq9fnuXGLC\\/r5cd7efGqr1\\/SS\\/bv4xu7\\/\\/tOXtH7+W\\/ujU8+Zj8TouiD2fFs2AVzZRdFwQEAUBYFh8jeTXR+pcEd+6448sjApYqyVLNUeqn2SWVV0gFJRiDxFrP651gZj3zcatXW9Ddmxwet4lgTBQcAQFk6BcfivreHzkVXfrPkQlRkD+ZslCS3z19+5SMC7BJpvf7E7HBvsBfH6ig4AADK0nlN7OJlnYIj8ry0yF7O2ZAkH2nNz18VYBdIJyYemx3+JnQL9GHPj92STsEx0W7fWGhwAQDYaF3BsazgENmzWXlc5Tcuu+yyhwUYsjStPz47fMnqwI3ztKHgAADYfgoOkVFK50bydFKpvP3w4UdPBxiiNE2fkB3uU3CsiYIDAKAsq\\/fgUHCI7PVEKxuPPpRWq6ey+Z1voglDkabpE7PDAwqONVFwAACUpVdwvC0oOERGIt15HOc3lJ+vN6a+PXTfagE7rreC434Fx5ooOAAAyrJmBUd+czT8iz8R2ZZ0VnLcOTE7+9UBhmBtwREU6N0oOAAAyqLgEBnNxHGcr8rKXx9724ErrzwUYIelafo1QcGxPgoOAICyrHlEJSg4REYsndc\\/x0nylgMHDkwG2EG9guM+BcfaORkUHAAA5VBwiIx2uvtxhHtqExPPP3XqVBxgh6RpPS847lVwrImCAwCgLKsfUell2Bd\\/IrKtyW8qu\\/txNKennxRgh6Rp+vjscG+vZFu20WgnCg4AgLKsKziGfeEnIuWkc1MVJcl7H\\/3oE9MBdoCCY\\/BcVHAAAJTACo6Luxgdgwx7nKXk5HtxZHkgrVZvOnjddRMBSpbWu4+oKDjWRMEBAFCWvOCY6+3BEdzonkv+rHgv2U1hd6PGlTHq3SieS+juX9JJGJDN\\/l2\\/H3uhn2\\/1zxldKH3+ewf9OjbJ0D8T2Zbkn+WD9ampbw9Qsl7BcZ+CY8McVHAAAJRh9SajwY3sufQ2w\\/tClKa\\/HOL4lhAnb8yOb87yM71k3xe\\/KcsbsvxUltdleW2W12S5uZdX9\\/KqVXnlqrxiXX5iVVb9c3pTLy\\/P\\/jnPTef+Xej8PK\\/Kjnlu7uW1vbwu+zW8Pssbs7wpy09neUuWn8+Sr9r5pSy\\/kuW\\/ZXlfltuzfCjL\\/8zyZ1k+FzpvQAhnwgXKlmF\\/XnLRWSm3Pnrg2LFDAUqk4Bg8BxUcAAAl8BaVtYmipLtyI9+UMQqfPHjNNZcXH+U9Iw4nQhpmZtqhVjsaKuGrQxKemX3\\/92d5VZZ3hG4J8r+y3JPldHa+nA0h9FsBMvTPUjbNmaRS+VmPqlCmlYJj5S0qCo5OFBwAAGVRcKxNFMXnC458JUOjsS87RkXHeQTkY5BmyW+IF0O1enWoJt+Uff2jobsi5HeyfDH0X+0x9M9V1iaOO3+jfu9Ee\\/Zb1n\\/QsF0UHH2zUnC8vNjoAgCwwaqC46yCI0\\/cO3YuyD\\/eWFzcV3SMx0ASJsNlIQ0nsq9\\/MMtbs\\/xhlrtDXnhs3ONjF3zOEvI5H0UfOnDkyBUDPlcoRMHRNwoOAICy9AqO\\/xgUHL2sKTg+oeC4ZHGWepa88Hha9k\\/5Rfzvhc6bFJQcuyz553A6rVRuDkeP1gZ+orBFaZo+ITvcr+DYMO8UHAAAZVBwrE0Uot4YdJbwf7KxsLC\\/8CCPt7jRaOwPSfL3Qhznm53+QZa\\/Cave4hJ2wec+rumN\\/53N+f1PvMDnCJcsTdP8vHpQwbEm9uAAACjL6oIjDP\\/CbxelW3CEhYaCo7jze5gcW2jWGrWnZd\\/zqyHfsyNaWdGRj7ebn2EkiqKzIUl+\\/dCjHjWz2YcIl6perz8pm9cPBqu2VkfBAQBQFgVH\\/\\/T+ZvuTwQqOcuzb1wiVyvE4jl8Uuq+lvT94fGUY5\\/nKuf5AZWIif1uODXXZNmm34DgdzOvVUXAAAJRFwTEokUdUdkir1ZoLcXhe9uXvhm7RcbZz0x25KdrB5I8L\\/c7hxxxzvrNt0nr9ayMFx4a5FhQcAADlUHAMSm+TUQXHTkmyXB6S5Huy4weyPHD+8ZVhnwujn95+KA+m1dpPhGPHqhf1icEFpPX6k6MQnTm\\/B4cEBQcAQHk6Bcf8SsGR74FgH4RuvEVlaA5OzWbfPjfL+7N8IZx\\/dMVNUnnn+8o5\\/7mJiamvvqjPCS4grdefEvJXRdtkdHUUHAAAZVFwbHoR+nEFx9DEs7OzU9VW6+9nX38iKDh26pxfiuPkl06ePGUVB4WdLziCgmPdPFNwAACUYO0jKgqOVekWHI2GgmPIaq3WI0Ic5zcDnwm918uG4Z8fo5p8bO9OJie\\/KdhwlILSRuOpkYKj3xxTcAAAlMEKjk0vQj\\/ebDYXi40w26U+0\\/qa7PDBLGd6JYeio4T0xvb20GrNX\\/SHA330Co58fycFx\\/msFBwvLza6AABsoODY9CJUwbG7RNnnsRDHcf460z8OK29bGf65MlLpjel9SbX6bZfw2cAGaa32dQqODbGCAwCgLN6isulF6CcUHLtTZXLy2uzwrixfCvbnKOf8j6L\\/sm\\/fvsbFfyqwloJjwNxScAAAlKO7gmNRwdH\\/IlTBsXvl+0NMx5XK87PjXUHJUcb5f9fE3NxXXvxHAmv1Co5V81LBETyiAgBQHgXHoEQKjr3g1Km43mo9PvvqtiwPxXH2uUXDPndGIvn5fzau1l+cHZNL+kygJ63VnhYUHP3mloIDAKAMCo5BiezBsXdErcsvnwtx\\/MYohAciKzm2I0tRFOdvrPndw49+9PQlfyIQugWHFRwb51ZQcAAAlGPtJqNDv\\/DbRVFw7DWzs7NTcRy\\/IPvyL8OqR1aym\\/RdcD7tyeTj96XW3Nw3XuJHAR0bV3BIUHAAAJRHwTEoCo69KqlW8xvyO4N9ObYjS1GSvvPEiRP10N33BC5aWqt9fTAHN8ypoOAAACiHgmNQFBx7WDoxMfHYEEUfzJfHR8GrZAskH7vPTczOXnfpHwPjTsExcE4pOAAAyqDgGBSbjO51jUbjUdnhN6MQHgpusraafB+OpThNX3TpnwDjLqnVnh7MvQ1zKig4AADK0Sk4Fm0yujEKjhEQTczOHsyOvxY8rrLVdMYtipL3H37Oc+qX\\/Akw1hQcg+dUo92+scjYAgDQh4JjUBQco6Jer1+ZHX41CuHB4Gbr0hN15sJftxYXPabCJVFw9I2CAwCgLAqOQVFwjJL9R48uhCi8J3TPczdcl56lOKm8IZw8mWxh+BlTCo7+cykoOAAAyqHgGBQFx6hpzc9fFaLot6IoOhtFNh69xOTj9b8mJycPbGnwGUsKjoFzScEBAFCG7iajCo6NUXCMonpr5vHZ4dPerHLJycfrbL3dfspWxp3xVKvVnhGGf+7utthkFACgLAqOQVFwjKi0NjmV\\/63yn\\/dWcuyCc21PpFMIpdXqy7Y27IwjBcfAuaTgAAAoQ\\/cRFa+J3RgFxyiLK5Xrs8O9HlW5+ERRvBSi6IPXXXfdxBaHnTGj4OgbBQcAQFnswTEoCo5RduD48cmQpq\\/Mvnwo2CPgopKveMmOd1Xm5h6ztVFn3Cg4+kbBAQBQFgXHoCg4Rl3rwIH5EEXvz1dxWMlx4fTG6Eyc1v5Vdoy3Ou6Mj17BsRSUiKuj4AAAKIuCY1A6N3MfV3CMtqRW+4bscL+C48LJ9yvpjFMUvTMsLDS3POiMjVqt9nfDLjh3d1kUHAAAZVFwDIqCY0zUs+Sva3wg+Fvmi0k+Rn8SpusP29JoM1YUHAPnkIIDAKAMCo5BUXCMjXo4lH17e+jOASXH5snH54u1RuNpWxtsxomCY+AcUnAAAJShV3C8NSg41kXBMUaiyXb7K7LjpzyqcsHk43M6rlZfstXBZnwoOAbOobzguLHI2AIA0IeCY1AUHOMmraX55pm9VRzRcjfDPg93ZfJ9ON5z+MSJ+tZHm3Gg4BgwfxQcAADlUHBsehH68WZzn4JjTDQajf3Z4XejKORvVVlWcPRPb5XLn4dW66rsGG19xBl1ecER7YJzdpelW3C0FBwAANtOwbHpRejHFBxjJapOTn5jdvzrYC+OPukWPr2C46GkNvmMrQ8140DB0TcKDgCAsig4Nr0IVXCMozh+e34Tbz+O9emuaumNy1Kcpj+Sj1ahsWakeUSlbxQcAABlUXBsehFqD44xlKbpY7PDXcEqjnVZs4Ij34fjP2XH2tZHmlGn4OgbBQcAQFkUHJtehH5MwTF+jh07Vo3T+DXZlw8GJceGRJ0NeDslx4dDmG8VGGpGnIKjb2wyCgBQFgXHphehCo4xNTU19beyw\\/\\/xmMqm8+Mz9cX2lVsfZUadgmPg3FFwAACUQcGx6UWogmN8VeKl49ykAAAgAElEQVQ4fm12PKvkGDg\\/7q412k8tMMaMOAXHwLmj4AAAKIOCY9OLUAXHGGs0Go\\/KDp8NHlMZND9OhzQ9tdXxZfQpOAbOHQUHAEAZFBybXoQqOMZbGsfxG7LjmaDk6D9H4vhtx48frxQYY0aYgmPAvFFwAACUQ8Gx6UWogmPMpfX647PD3d3XxsbDPid3W\\/LNRr1KmYEUHIPmjYIDAKAUCo5NL0LvCAqO8TYz0w5R9N+yr5aiKBr2Obnbks+Rv6rVWlcVGWJGl4Jj4LxRcAAAlGFdwWEZ\\/tqL0LzgWCgyvux91YmJb84OX7LZaN85cm9lYuKriowvoysvOKLhn6e7LQoOAICyKDgGJVJw0HHl8ePt7HB7HMfmx9p0NhpNqtVvKzK+jK7eCo6l4M+W9fNGwQEAUAYFx6AoODgvTuMbovM3J7vg\\/NwV6dyoxXF8Q6HBZWQpOAbPGwUHAEAJFBybXoTeEfbvV3AQJiYmvjI7fDGYI2vmSNR5k0r6qkKDy8iyB0f\\/eZNnst1+WZGxBQCgDwXHphehCg46ZvLNRkP4tWCOrJkjnX1Joug\\/Z7+RRIUGmJFkBUf\\/eROs4AAAKEen4JhXcPSJgoM1qtXqt2aH+2w2umGefOTo059eKzS4jKRarfaMSMHRb84oOAAAytArOH4+KDj6XYQqODjn2HXXzWaH\\/6PgOJ98LLIb2D9qHzo0U3B4GUG9gmPo5+kui4IDAKAsecExreAYdBGq4GCNOI7fHoXOYxlL3Ru3aNjn6VDTK3vuDDMzj8yOHlNhDQVH3yg4AADK0tuDQ8HR\\/yJUwcEaSaXyndl9\\/OkoWpkr8bDP02EnH4f7QpI8Myg4WCcvOMLwz9Hdlk7BMaHgAADYfgqOTS9C72h6TSznRdkN29Hs+CehO1+Wx30FR+jOk7NxpfJ9xYaWUZQoOAbNGW9RAQAog4JjUDpL7z8aFBysdvx4Jfv2zVnOhBCbL93kr4p9dQgn0mKDy6hJPKLSf74oOAAAymEPjkFRcNBfUq3+g+zwN1GIl9y8dZLPlfeG2dmpgkPLiFFwDJwvCg4AgDIoOAZFwUF\\/tVbrEdnhzzubjVrFkScfg983V1gvqdWeHoZ\\/fu62KDgAAMqi4BgUBQcD5CsVoug3os588crYXsnz2TAxcbDw2DJSFBx9o+AAACiLgmPTi1AFB\\/1UQxy\\/Ji84osgKjt6bZO6uNptfVnhkGSm9gsMcWRsFBwBAWboFx7yCo\\/9F6B2h1ZovMr6MpqSafHMUwkNRZAVHbwXHA2m9eaLouDJaFBx9o+AAACiLgmPTi1CviaWvynTjmuzwWQVHnk7B8VBSrX5T0XFltCg4+qZbcLQUHAAA207BselF6B0eUaGffVdf3cgO77cHR1juvk0mOh2S6ncUHlhGSlJLFBwbo+AAACiLgmPTi1AFB4PF8VuCebOcv00mCuF0Nh7\\/tPCYMlLygiMa8\\/nRJx5RAQAoi01GN70IvSM09ys46Cuu1Z6XHc6EMZ83vYLjTIjjFxceVEZKWku\\/Poz5\\/OiTTsEx0W7fWGRsAQDoQ8Gx6UXoHSHYZJT+0kYjv3l7KIz5vOkWHNHZEMc\\/W3hQGSlpquDoEys4AADKouDY9CJUwcFA1UbjUdnhi8G8We7uRRL92qlTp9Ki48roSNPa04L5sT6dgqNhBQcAwPZTcGx6EargYLDJycuybz8TzJvlzptUougD4diJZtFhZXQoOPpGwQEAUBYFx6YXoQoOBmu3Z7JvPxrMm86bVEKIfi\\/MXn6w6LAyOhQcfaPgAAAoi4Jj04tQBQeDHT5cjyuVnwvmTa\\/gCJ8NlckvLzqsjA4FR98oOAAAyqLg2PQiVMHBZqI0TW8I3bkz7PN1yMn34AhfDGn9RMExZYQoOPqmW3C0WgoOAIDt1i045hUc5xKvvghVcLCppF5\\/dna4L4z53Imizq8\\/G4fa04uOKaMjTWtfF7rnxnLUOU+ioZ+ruyArr4l9ecHhBQBgPQXH+qwtOFotBQeD1ZvNJ2aHvw5jPneyG9f81\\/9ACMm3FB1TRkea1p6aFxydciMoOHrpFhwtBQcAwLZTcKzPSsHRuWHLN5BUcDBQfWbmUHb40zDmc6dXcDwU4vh5RceU0dErOM5G2e+nCo5zUXAAAJTFHhzrs3IBvlJwWMHBYO1Dh\\/I3qfxh6MyfaNX5M17pFRxnQohvyo5x4YFlJKRp\\/Smh92eLguNcegVHS8EBALDdrODY9CLUHhxs6vCJE\\/XscHswd5Z6+Q9ZKkXGlNHRKzjOhHPzQ8ERzhccNhkFANhuy8vL0fTCQv6qSwXHxotQBQebu\\/VkEiXJO3srGMZ5\\/vR+\\/dF\\/zo61osPKaEjrCo4+sYIDAKAs3YJjUcHR\\/yLUHhxcUJwkb1BwnCs43psdJ4uOKaMhrdefHBQcfeeKFRwAACXwiMqmF6EKDi4oTtMbFRznHlH5RJaZgkPKiEjr9a\\/NDqeDgmPDXFFwAACUIC84phQcq3LuAjwfi4+0Wq25QgPMyEvr1VPR+Rv8XXAOD\\/XG7dOT8\\/MHio4poyGt158UOgVHpOBYO08UHAAAZbCCY31WXhPbGYsPBwUHFxCn6atD9\\/GMcZ8\\/+a\\/\\/c6FWO1J0TBkNaZo+MTs8GKzgWD9PFBwAAGVQcKyPgoNLkr8x5DfG+RWxq5LPmS9Um81HFh1URkOapk8ICo5+80TBAQBQhm7BsajgOJeVgqPzt\\/EfUnBwAXGWX+7uwWEFR5Z70nrzCUUHldGQ1utfkx0eCAqO9fNEwQEAUAYFx\\/qsWcHxoTA1NVtogBl5cRq\\/TMFxbs48kFQnnlV4UBkJadopOO4PCo7182RpstV6WaHBBQBgI4+obHoRquDgguI0\\/mFvUTk3Z07Hae1fFx1TRkOa1h+fHe4L5sb6eaLgAAAog4Jj04tQBQcXFKfxixUc53I2Tqs3FR1TRkOapnnBsWoFh4TzBcdLi4wtAAB9KDg2vQhVcHBhcfyTCo5V8yapvCn7fSUqOqzsfWndCo4+6RYczaaCAwBguyk4Nr0I\\/WAICg42l1Sr35EdTofhn7O7IUshit517NixZsFhZQT0Cg4rONbPkW7B8eNFxhYAgD4UHOtzbhO8fCx+W8HBhVQbjUdlhy+Ezjkz9q+LzefNH07Mzh4sOq7sfQqOgXNkaXJqWsEBALDdFBzrs\\/o1sdHtod2eKTjEjLpa+0j27WeC+bPcG4O7qtXq3yk2qIyCXsGx6jWxEs4XHC8uMrYAAPSh4FgfBQeXqF4\\/nH37Z8H86c2bcG92Y\\/uEYoPKKEjTznmg4FibXsEx9WNFxhYAgD4UHOuzuuAIHwjtQwoONlefflj27ad658wuOIeHmc7jOWdDtfqsosPK3pemaV5wPBj82bI6vT04pl5UZGwBAOhDwbE+a1Zw\\/FaYnp4uOMSMuInZ2Suywx8rOFbmTViK4\\/hfZUdvUhlzab1+Iig41mflEZUfLTC0AAD0o+DYmKibfCzePz19WMHBphqHD+\\/PDr+bZal37gz9HB5i8jFYitP05dnXcdGxZW9L6\\/WvjaIof8OQP1tWzZHQLTh+pNDgAgCwUbfgWFRwrMqqguM3reDgQg4eO5a\\/aee3g4Kjc\\/MWRZ0VHD+TfZ0UHVv2trRWe2p2OBP82bJmjuSZbLdfWGRsAQDoQ8GxMasLDis4uJB9V1\\/dyA7vDgqOczdvIYrekx2rBYeWPS5t1J4W\\/NnSd4402u0fKjK2AAD0oeDYmNWPqFjBwYUcv\\/76Sna4NctZBce5fPzA8eOTBYeWPa5Wqz0j+HNlfVYKjhcUGVsAAPpQcGyMgoNLcfLWk0mI458LVnCsvoH70zB7+cGiY8veltRqzwwrq3qGf17ulnQLjunZf1lkbAEA6EPBsT4rb1HpFRxeE8sFZHMoCkn8pmD+9NJ5k8rnQ73+5IJDyx6XVKvfHBQc69MZj+bc3A8UGVsAAPpQcKzPmoLjN9vttoKDTeUFR1qr3BzcyPXSKTjuTyr17yw4tOxxSbX67cG8WJ\\/OeLTm9z23yNgCANCHgmN9FBxcump98qXB2yJWz53TcRzfUGxU2esqtdo\\/DQqOfvNjaWpxUQEIALDdFBzrs6bg+K2g4OAiTHSfp38gmENZovx4NsTx28LRo7WCQ8seFler+atQFRxr0xmP9v7931JkbAEA6EPBsT5R7xh3C46g4ODCpvbt+7bs8KVgDq3MoXwc7piaOjhbbGTZ0+L45qj7yJJ5cT6d8ZjZd+CZhcYWAICNFBxrE0UrBUfnovzDrVZrrtgIMw6mr7jsCdnh7mAOrSQfh8\\/Wpqb+VqGBZY+LfzaK8rK48\\/vpqt9fxzndwmf24MGvLzq6AACso+BYm5UL8O5FefidMDl5WbERZhzMHjp0LDv8dTCHVpKPw4Nprfa0QgPLXveL2e+pq1ZwxMM8J3dJuuMxt2\\/f1xYcWwAA1lNwrE0UxcvR+YvQT4TQXCw4xIyBhYNHjmaHO4M5tJLOTVylXvemiPH2rvz31POP\\/lnBsVJwTC8sPKHo4AIAsI6CY23OFxyxR1S4aAeOHLkiO3wmmEPL3ZvYeCmbR0txnL6m6NiyR504Uc++vb27gkOxsSrd18TOzDyu0PgCALCRgmNtOgVH528cO2PxkdBqzRcbYcbBviNH8pU+n+otxx\\/6eTy8RJ3HvHpZClH0ruKjy57Ufbzvj4I\\/V9anU3BMTE19VYHRBQCgHwXH2qwvOFoHDig4uKCZ48fb2c387ys4ouW1byKK7ggLx5rFR5g9p1a7Kvv2L4I\\/V9anU3BMTk09psDoAgDQj4JjbdYVHPkjKgoOLujw4cP1EEW\\/vXZDxXHM6oKjMxZ3VRqNawoPMHtPpXJt9u3nw1jPh77pFhzt9pcXGF0AAPpRcKxNn4LDHhxcjEoURe9WcGwoOB5KJia+tfDoshfle0zcE8Z6PvRNPh4PNGdmHllgbAEA6EfBsT7nbtDysfiQgoOLlIYo+hUFx4YshTi+JTtWC40ue9GzstwfzIeNcyKEu9qLi1cWGFsAAPrpFByLCo6Niazg4FKkcRz\\/QnZcsg\\/HmuRj8b4s7SKDy54ThTj+wex4Ovhzpd+c+IMDj3iExx8BALabgmNQIis4uBRJUqm9Pig41icfi\\/9bq9WOFhpd9po0xPGrQvfPlWGfg7stZ7PfLd53uPsaXQAAtpOCY2AUHFyKuDrZ\\/NHQ20AwDP\\/83S3Jx+KetNl8UpHBZc\\/Jb97fHsyFfjmb1mrvPHnrrUmB8QUAoB8Fx6B0\\/hb+g2FqarbQADM26q3W9wQFx\\/rkY3E6pOkPFRlb9pzFLB8O5sK6dPZ3OtOYnr25yOACADCATUYHRsHBJalNTn5DdngomEfr51G+0Wi+P0laYHjZW\\/5Olv8XzIU1iaI4G4\\/o\\/vlDh55baHQBAOivt4LjrUHBsS5WcHBp0nrnMYx77MGxNlH395U\\/mT1w4IpCA8xe8vQsDwZ\\/pqydC1E2HlH0xYUrrnhCodEFAKC\\/vOCYUXD0Sa\\/gCAoOLk5zZuaR2eHTkXm0Jr3C50vVyclvLDTA7CUvzHImmAvrk4\\/HX+0\\/dOjLCowtAACDKDgGpXNT9tsKDi7W4sMfvi87fFzBsTbdZflhKY7jVwSPqYyDbAqEd\\/SKLXNhzVyI8rcsfergNddcXmiEAQDob13BMfQLwN2TXsHhERUu0r6rr26EKHpfMJfWpHNT17nRjT6S\\/bP5NPLaM9k3f+BRrX5zIc7nw0cPHDgwWWiIAQDoT8ExMN2Co925WIcLOnHiRBrH8VuCpfmD5tNdlXb7ywsMMXvDU7LcHcyBfnNgKUnT\\/5odK1sfXgAABlJwDErnbx9v7\\/1tJFyUuFb7F8Hmiv2Sj8eDlVrt+wsML7tfkuXHg9clD5oDS5VG41XZMd7yCAMAMJiCY1A8osKlS6rJP8gO9wY3d\\/2SP6byP2ZnZ6dCd58GRk87yweCgmPA+R+W6pOt79768AIAsCkFx6D03qLiERUuQdqaeGx2+FwY+vm7+9Lbk+HzoVL5igJDzO52TZY7g3KjX\\/IxuX9yZuYZWx9eAAA2peAYFAUHWzAxcUX27ad6b0twk7cq596qEVeeX2iM2a3yVTk3BI9oDUo+Jn8xffniNVseYQAANqfg2PRi9IMeUeGSdM+XDwVL9PukV3BE4VeDR1RGUX7u\\/2bwZ8mgZOd+9Mmj1\\/5\\/9u4EXs6rrh\\/wme3ua5KbpEnapmna0gilkGKpFbiWRSoWQQygLBUVEAVxAQQUiAJ\\/BQTEgogKIohgAQGRspQdZBPZLCIIFFkKFKS0ULo3\\/3PuzG1u03lnuzPzzsx9ns\\/n27lN7rznvO+8c3Pf35z3nNstdXyEAQBoTIEjK7U5OIICByvSvBHNL0x2754IxeJLgwJHvffU6iiOr4\\/Pzp7Y9FgyXEqle8X\\/\\/jA472+ReN6n3FCZmvr7AwcPjq3nMAMA0IACR1ZWCxxuUSFdu5XODcViK7dWFOL3\\/X4hvp\\/conKL91R6TMfkuniMnhcfyy0cT4ZDei1fERT26qZ2y9o1s\\/PzD1\\/HMQYAoBkFjqxYRYWqU5eXF+LFybtXRmYcOFBq9v2lycn7x4cfKnDc4j11aE2R46sxe5odS4ZEde6Z9JoqcNTJys+CQuGynccff9Y6jjIAAM0ocGTGCA6S4sTs7Lnx8QfxAuVtYceOqWZP2LJz54nxQv4rChwN31vp8UHNjiVDoRyKxT+Kj9cGxY265\\/vKCI5i8cs79+7dtY7jDABAMwoc2b+UBgWODW9mZnuad+Mjheo58dXJycmmFyhLy\\/tm4sNHg4u9zPdWtfhTfFUw2egoOD7mGwp62ed7Sqlcfs+mvXvnOj\\/MAAA0pcCRFZOMEsLU7Ox9Cmn0Rm3uiOnFxVNaeFqhWCqZaLRBahfDX1w46qhjWzieDLTio8NNRav8z60BzMrPgcrk5PMPtHCLGwAA66DAkRUFjo1ux\\/79U8Vi8fxC9b2xcvE2Njn5Cy09uVz8\\/fjf64MCR90UCsV0XK4OxcqjglEcw2t+ZYTb+2qTaOZ+Xg1oVs71zdu3n9v5gQYAoCUKHFlR4NjgCqWpqXPi42WF6rmwUqgoFotPaeXJpamxn4sPV9eeOwDn80AmHZsP1y6SGT6FUKqcGywN2yQrxZ+v7N1\\/6+M7P9QAALREgSP7l9KgwLFhbdq0Kd0r\\/9ZweOh9NcXia+Jjsdnzx2Zm9sWHS4MCR6OkY3NlaXz87GbHkwE0GXYGc820cI4XbiyNjb397LPPHu\\/4WAMA0BoFjqwocGxklUrl3PhwZbj5xduNhRA+vbB790Kz589sT5OTFj6kwNE0afnMNx04cGCs2TFl0BR\\/Pf7nGnNvNDm\\/47+tY5OTf9rxYQYAoHUKHFlR4NioxsfHT4gPF4VbfjKd3iPfqszPn9ZsG\\/v27RsrFosvUuBonNrF8Q9KY2P3D+biGB7j43vjfz9l7o2Wzu9rZjZv\\/vnODzYAAC1T4MiKAsdGVSwW\\/yRkrwpxXfyG32hlO2OTkw+I59GRo0BkTW66\\/adQeHt8nG3luJK7SszzY25Q4GiadH5\\/Y3x2y0mdHmwAANqwUuDYsu0fggLHEUkXXoV\\/C3MKHBvJ9PTKMrBfyhp2X\\/3z4stDmoGgibldS2kkyNdDQYGjSdLx+X5pbKy1FWrI2\\/6YS4JlkFtI4cZCufyWk848SfEOAKAfagUOIzjq\\/GK6UuAIVnjYMKqreaSJRdMn04fqfTJdK3x8Kmap2eb2P2J\\/JX7\\/u4MLwaapHdePhcXFY5odV3JTCNPT2+PjBaH2HgkDcO4McNI5fd3k\\/OzjDxw4UOrwmAMA0A63qGRFgWOjKVUnFr0+NChG1C7ELwljY7ducbMvDgocTVMsrhzX64vF4uNbPK7k449Ck\\/eI3JR0jC5d2rf3dp0dagAA2qbAkRUFjo2ktqzrRfECu+GFW63AcWXLt1NUKo8JChxNU5vLIR2jz05u3ryzpWNLPxXK5fIZ8fF\\/g3O5lay858uVyoVn\\/8VjLA8LANAvChxZWZ1kVIFjA0jLvr4+tHbhtrLsYyiW0siMpqt+lEqlnwlpYtLqpKV1b3uRlGJ6zx2qHtvii8LevS4KB8uemM8FS8K2mpUCx8TMzDM6O9wAAHREgSMrtQKHSUZH24EDpWKx+Lvxqx+G1j+Zrs4XMbtzc7PNTywsHBsf\\/mt12wocme+3Q7Xjk47TZaXx8Z9tdmzpky1b0gSZr4i5PmvyXblF0nG6em5p6eyOjjkAAJ2xikpWFDg2gvLExF3iw6WhvWH36XuviM\\/+ydBsFMf+\\/ZVQXFl15YY229jIScvGviPs2uW9l7+ZUAzPio\\/XBOdvW+dwoVj4+PGnnLK1o6MOAEBnFDiysnqLigLHqDrjwIHJYrF4fqjePtJugSMtF\\/uE0MptKpNjDwjtjRDZ6EnH6ZpQLD4zPk40O770TDm+Br8THy83cqPt8\\/e6qbm5p8bHYicHHgCADilwZEWBY6Tt2jVZHh9PK3ZcWZvgstXzYuUCplBYuYhJS8qWm7Y1MbE7\\/vcLBZONtpPqrSpjY\\/drenzphbSs6cNivtve+2OjJx2nlYmKv33sXqunAAD0nQJH5i+q6ZfUD4V5k4yOorHJmQPx4YedfDJdKBRX54r43zAz08oQ9IlQDP8UFDjayeqomv+cmJjY08IxpptKpXPif78ZnLNtZuWcvbFQKr0\\/PpooFwCg36qTjCpw1Em1wGEEx6gpTszO3ik+fnbN0qRtnx8rz023nZTGfq6FNgvFSuUR8fHa4GKxvWNcWFlV5eVhaWmmhePM+hVCqZTO6a8budFJVkZv3DA2PfHE0MLtawAAdJkRHJlR4BhB09PTp8SHL4TuFBrSNl4W9u0ba9bu7OzsSSGN+FDg6OQY\\/ygUiwf3Wjq214qhXP7p+HhxcJ62ndoy0DeGQvjO4nG7TunkBQAAYJ0UODKjwDFaCvHi7cz4+O+heyuapG18K+bHWmi\\/UqxUXhAfr68NY8\\/7\\/B6SpNuBSul4XRWKxWcHw\\/57Jd2K98cxlxYKRednB6mNeLlucn722fvT6kkAAPSfAkdmagUOc3CMgEKoTN0+Pn46dHdOgdVt\\/WYrnZiYnUi3xvygesFu6H8Hx\\/qqmD+PWQiG\\/3dLOo5HxbwyuIVqXVkpDBUK3916\\/LE\\/0e6LAABAlyhwZMYIjlFRqZwW\\/\\/vpQqFwfZeXu6wVOAr\\/3FI\\/ZmaW4n8\\/VVgZwaHA0W5qr93VMeeZ\\/LdrTo15W8w1teOrwNF5biyXy+\\/etW+ffzMAAPJiktHsX1ZjPjQ3p8AxxEqhUrljfPx46N1qEOl989UQxk9qqT\\/lcroN4LouF1o2UtJxuy7mdTEnhzRvBJ1It1DcOeaTwUop3Tovr1rcuvVR4eBB5yQAQF4UOBr+wvqhoMAxtMrVCRPTUpc9PLfTSIzCjaFY\\/IPQwm0T04uLt4kP3wguKNeb9Jp+uXR4FRu3rLRqebkcz9cnxa++X5sY85DVUtadG4vl8ifPvPfdd7T9egAA0D0KHFkpGMExvCZKlcqvxMcvx3S8FGxrWbkwTNv\\/TMy2pj1Lkw8Wi\\/8UfGq+rlTnO6hN8losPj1MTu5qeuxZHdF0fswPV5dJVuBYd1bex1MLc09t9wUBAKDLFDiyUjCCYziNFSvjj4qPl\\/fxNpDUzjUhlO\\/ZSgdLY2P3iw83uE1l\\/SkcLhS9P5TLZ8XHpkv2bkDplontMWmU0SVBca3bScfyh0cff\\/StW35FAADoDQWOrNQKHNXlExkCC7sXFlY+zQ\\/he6ufTof+XeDcENt+bksdnZzcGf\\/72eAis2vHP77W6efXpSuvwfj4icEtK6vSz69Hxnwi5moTifYk10\\/Nz77sjAMHJlt\\/WQAA6AkFjqy4RWWYjKeL2mLxVaG6ykYeF3Cpzc+GiYljW+husTK+Msrkqpz6OqqpFppC+Fw8F34vvhZ7wsYsdBTDZDg6VAsbqUi7ep4513pwzhWKxf+93Z1O39fqiwMAQA8pcGT\\/4hrzYbeoDLiD8WJuYuInQ3qtQuj2MrDtni\\/XhlD6tdDCRfX+u91tPn7XZ4KLzi6mcGNagrdYHc0RX4vwuVAq\\/WrYWKOw0lLEvx7z+fheWC32KW70JivHdWxq6mVhYxbSAAAGjwJHVgoKHINuYWGhWCz+bvzq2yH\\/i7jVW2LeHjPXSveL5fIzQvV95+Kzy1lzK0YqdPx7TJoA8vSYUXs\\/pwvrzTF3iklLEH8qrMwHk\\/v7YSMkTXT7nc3H7jyrhdcJAIB+UODISrXAMTs7u3ldB5heKEwsLOwOhcLrwuGLudzPmdpF9ffK1RElTY1NT58S0iogA9L\\/UU2an6P22vwopMlIQ\\/jNmJNipkJaWaSqEAb\\/U\\/jV\\/qVJQ6dj9sc8LVRHL6V9U9ToX9Jxvm5mdvYlB88\\/aGJbAIBBocCRFQWOgbRr12QolX4xVD+pzvOWlFuk2pfC9fHrl8SMt7A3lWKplL43PWdg9mNEc+OaUR1pTopvxnwk5q9i0vm0vzZaq9jsRctJOp\\/S5Kn3jTkvVPv+nZjrgttQ8jmfioUvH3\\/aKVZOAQAYJAoc2b\\/AhupFhALHYCiF6enbhGrx4IpQu6CLF615nyf1zpvvxtyxlZ2anJu7YyiEb1rdor+vUaGWcDiXxXw05qUxvxKTbjs4OWZLqN5ylFbISKM9ejnKI227EqqjM9K8ISfEnB2qy7v+a8xXw8377JzJ6fyJuWF6dvZ5+\\/fvr2S8lgAA5EGBo+EvsanAMWr37A+f+fnFUCz+dvzqCzHXF4vFQb6wW5noMj6+IBy+\\/SHbjh1TxerqL4O8T6OVQhptc9N7fOX1WlNgij8HVybnvDzmGzFpIth0W8urY\\/40hJXz8KEhlO8ZH1PBLS35uzkshZn4OBGqBYpSRsq1v0+3xqQCxo6YtPrGXUN1FEna9p\\/H\\/EvMf8T8b8wPQnUekRsKNx+Fkv9x3Li5Ib5nv7T3dgvKnm0AACAASURBVLezcgoAwKBR4MhMdZJRBY787No1WR4fv3v86sIwRBMn1i5CPx+vd49pZTcnN206I1Qvpgd+3zZI6o2SWJt0S9EPQ3Vy24tj\\/jvmEzEfDNVz9YJQLVKkvKn2mEZgvC3mPTEfqz0nPTfNwZKKKdc2aTPvYyKh+t4uhMI1s4vzT47\\/dg76nC0AABuPAkdWqnNwzFlFJRdjY2P7Qij+Tfzy++HwSiNDcaFXK3CkgsyTQ2u3NBSKlUr65N5cHIOXxsWO6pK0Nxzx5zdkfH3k92T93dCc6xswNxaLhYtOOuWk4wIAAINHgSP7F9mYjyhw9NG+fWOhXE6jGZ4XVkZADPUFf+p3uqXm6FZ2vTI1dbv48NVBmjRVRG6W9N78weJRWx65vLycbjcCAGDQrBQ4tihw1Ik5OPpnLF7g3z4Uiy+LX\\/9fOPzp+DBf7K\\/sw9jY2M+1dAT27RsrlsvPCjetijFwk6eKbORU38\\/j42\\/+iwsuaGWFJAAA8qDAcWRuurC0ikqvTUzsKVaKvxG\\/ekfMpeHIIfuDt0JKO+fRjbXbnF67MjKlBZt27twVqsvfxucVDylyiAxGaiOrLtt2zDFpQlgAAAZVrcCRVnFQ4FhJcfXr9AvtR2dnZ7es6wCzVlpJYksol+8SisU\\/iV9fFG45ueIAnAPduiiqLRlbDmmi1JYmJCxWKr8TH65zq4rIwOTG+F6+Znrz4p8uLy+nlXIAABhUtTk4VpepzPsXyQHIzUZwpNUOFDjWa8eOqdrcGn8aqqNivhdz\\/cqKBCO87OWapUjT6hmLrRyqrVu3bosPH0jFkdrzRSS\\/rPx8KlfKH7\\/rbz7UaD4AgEGnwNHwF9uPBiM42lUMW7bMhvHxvaFU+pn4\\/88IofDO+PidsDFXiUj7eXk8Fj\\/b6gGcmJ9Ow+C\\/uYGOkcigJr0Hr5jevPDQAADA4FPgyEpxZZnYsH1maV0HePgV6uRm4jlUCPPHLIZy+W6hWHxK\\/KN3x1xaKBQO1bKRChr1kvb9HWFpaabFY14K5eJzwuE5SfLuv8hGTHrvXTs5N\\/e8g+ef39I8OgAA5GzNHBwupG6WlYvyD4VtM1tDi\\/MnjKjStm3bpsP09LaJiYnj4v\\/fIeaBMb8b82chTaIZwgdDdVnXK8KRE4U6r1YKPPEEuip+\\/QehOg9JU0u7d28vlEpvjs+9wXwcIv1Nofaza3xq4oJ9d7jD9gAAwHBQ4MhMOh6f3HLMMfunjj56x+Tk5p1h06ZdYXIyZedKpqZ23JQwdVR8rGZ6enst20JImdkaZmqJ167x8XDCakIta79emf8jZrZBjtzGytdbq+3GpH5M3dS3HSv9DmFXCJNHT0wsHBsm5veMj8\\/tHZ+dPakyOXl6CGM\\/H0qlh4di8fHx+54e8+KYN4fq6h7\\/G\\/P9EAo3pALQ2jk0jNLIzppRLN+IOTG0aG7z3I+H6kgYIzlE+psbC8XiJcecetKZAQCA4VG7ReUfgwuoW\\/yCG9Kn7oXC\\/8THz4XqCIUvxVxcy5dr\\/\\/\\/FWv6nli\\/Uvndt\\/ruN1Hve55qk3nNX+\\/PFWj+\\/VOtz6vtXakkFi6\\/GfC2EQrr4Tku1XhGqow2uC7ccidEoeb9eg550jK6P+euYqdCaSrFcflp8vMYxFulb0oir6zdt3\\/q45eXlcgAAYHgocDT5Rffw7QHtXOyPSvI+\\/iOWlXPphzH3DS2a3blzc6FUSCNojOIQ6U\\/SbWGf3rRz564AAMBwWSlwLG17dXDxJB0k3X6Rdx+GIWnJ1+rSrytFjveFXbsmQ4vm5uZOjw\\/fDt6jIj1Kuo2suHor2dd37d19l7Cx514CABhOqcCxSYFDpC+pXUBdFcLKajPjoRX791eKExOPCCvzn3ifivQihcLKylnXTM5O\\/\\/7KylAAAAwfBQ6R\\/qZW5Lg6lMt3D20oVUp\\/G25+25SIdCG199R15bGx1526fOpCAABgOLlFRaTvuTENhw+hcEFYWGj5YmpuaemEUCh8oraqSt77IDISKRaL1ZWgSqV\\/O+7k444NAAAMLwUOkf6nUCilx6tDsfik+DgWWjS9devdQnXlGxPBinQnN4RC+OqmHVvbGlEFAMAAUuAQyS3pPfetMDFxVmjV8nJ5fHryt+NXV7lVRaTz1CZITu+h7y8sbT73wIEDpQAAwHBT4BDJNel2k\\/eHycmjQ4v2n3POVHly8rlhZbJS71uRDpPeOz+YmJt6+q4zWl\\/VCACAAWaSUZH8UhuFkYocLwpt3Koyu3Pn5kKp9MZQnXQ09\\/0QGbKsvO\\/GJiZe+pDHPW46AAAwGhQ4RHJPeu9dFkqlh8XHYmjRntve6sRCufzvxWLxkNtVRFrOyooppXL5jccff3zLI6cAABgCChwi+adWoPhaCGO3CW0Ym5h4UHy4rpBGcoSb5hUQkTpZHTFVKpfev3zOOVsCAACjRYFDJP\\/ULrxS3hAzG1q1e\\/fE5MLC78WvLjOKQ6RhVoobhXLpIws7d942AAAweqoFju0KHCI5Zs2KDtfGvCBs2dJykSO+h0tj4+PPil9ercghUjfV4kax+Mmd+044NQAAMJoUOEQGKul9+KOY3whtOPXUUxdK4+PnxS+vCd7LIkcmFTc+vfWYY86MXxcCAACjSYFDZJCSJgwtpvfixaFc\\/qnQxsXYrX78xzeXKpVXheooEO9nkcMjNz6zdceOVNwAAGCUKXCIDFxW5+P4fExbqzyc+sv3WSiNjb2qkC7qLCErGzs3FovFVNz4xGlnnnlSAABg9ClwiAxk0vvx+pi3xuwObdh0\\/PFHlyqVV8Yvrw7e17Jxc32hVPrQ5u3b7xAAANgYFDhEBjarIzlevWnTprnQhjPvfe\\/ZUqXykrC6hGyhYAlZGekUi8WVx9pEu9cVSoV3nXDaaXsCAAAbR63A8ZqgwCEyiEnvyzQS4x9nZma2hjYcc8wxi2Pj48+OX\\/4gXfQpcMiop1bcuHpsYuzvd524a2cAAGBjqRY4thnBITKwKdyY5tQoFoupWDEe2nDgwIGx8tjYU+OX3425IZiXQ0YstdFJq6OdLi+NV\\/7yVnf98c0BAICNR4FDZOCzevH2fzE\\/Hdq0b9++sYmFhYfGL7+aLgSLxaL3uoxMagW7dE5\\/Z3x6+vH7lpdnAgAAG1OtwOEWFZHBTXXC0ULhLRPz88eFzpQWjlq6c6lceleojeQYgP0SWW9Win+lcvl9m3fuPCsV8wIAABuXSUZFBjO1eTPS+\\/KqUCy+ut05OOo5+eSTjyoWi6mg+aM1w\\/pz31eRdrM630Z5bOwtu0+91e4AAABGcIgMZmoXcFcWK+U\\/CwsLC6FL9u7dOzc+Pf178ctvhMO3v+S+vyItJp2vN8T3x7cm5mefdOL+\\/VsCAAAkKwWOLQocIoOSNEdGbZ6My8sTY8\\/cctJJs6HLDh48WJyfn79bKBQ+Xwjh+loxJfd9F2mQG0N1VFO6xerrizt2PDD9+xUAAGCVERwiA5XVC7hvTc7NPWbbKadMh94pbDnqqP2FUunt8etrg58BMthZmYumVCi8d3Hr4plh\\/\\/5KAACAtWpzcChwiOSYNUtdXl8oFi6aXJi97\\/LBg+XQB1uOPfao4tjYM+OXXyuE6rwflpKVQUg6D9NoppWiX6HwrfL42LN2HH\\/80QEAAOqpFTjODwocIrlldULRUrn83hPuePuT458VQv+ktkrzmzefFS8i\\/ytUR5H4eSC556aJcAvhK7PbNv9c\\/LoUAAAgy80LHOlTW5\\/civQrhcOTfP6gVKm8cmnPnhNCfgrz27YdVyqVXhS\\/\\/r8QCgodkkvWrPDz3fi+ePGm7dv3xX+r+ln0AwBgGClwiOSWldUgYr5Znhh74j0eco9ezrfRsvPPP780Mz9\\/v\\/jlRaHaPyutSL+yeq5dn0YTzWya\\/4Xl97ynL7dqAQAwAlKBY2Fp+2uDAodIP1Odb6NQePvs4kBOmFhc2rXrhPTpefz6qqDAIb3PTaM2xqYmnrHtpGOPi19bJQUAgNYpcIj0L6tD7+PjFcVK6SXHnnzyUWGAnXLKKdOV8fFHFkL4ZMw1q3OFhAE4ljISWZ3UNo0UuqJQLv3r5h077tavCXYBABgxtQLH64ICh0ivs\\/oJ9acn5+fv3+MlYLupOL91656xiYk\\/iV9fEtyyIt3L6u0on5hbXHzQMbe5zWLo7wS7AACMEgUOkd5mzaiHNGrjHxaWlk4NQ+jA+eeXpufn714old4Q\\/\\/f\\/Coc\\/fVfskBZTWPt+uC4UCl8qT4w9c2nPrjS5rsIGAADrs1Lg2Lz99UGBQ6QXWR3t8KWJhdlfDtVlLof1Qq7a7wMHSpuWlu4Zv\\/pASPOIBAUOaTmr74crKpPjz7\\/DPe58dKga1vcEAACDpFbgMIJDpEspFGqfUlcv5C4tVSp\\/Pb2wcOqBAwdScWNUFLZt27Z1Ynri3LivqdCxMhFpbd9XEgbgtZD83wth5byo3YoSwtcq4+MvWdy6eOYZZ5wxGQAAoJvOP3R+aWFpqxEcIt3J6vD7a2O+NDkz84B0a0cYYfvOOGPT5Nz0Y0MhfCbu+9VpwsjVyVRD\\/q+H5PQ+CCvvheJqYeOS0ljl7446ac9pB84fqUIfAACDZKXAsVmBQ6Tz3PSeSRdzaTWI7xZLpfPmdi3tDRtlmctDobC0e\\/f26bm5BxcKhffHP7kyrJmM1IiOjZKbClvpfZAmD\\/3c2MzUH2\\/avv3H9u7dOx4AAKCXzj90qLSween11V9MFThE2k1ttEK6oLs8fv220tTU2bt3L0+EDWrnrW61eWxm5gGlcumC+L+XxmNy3eGJJVd\\/zuT\\/uklXszJao7bc65WhUPjM2MTEwS17dp548ODBjVHkAwAgf9U5OJb+WYFDpO2sflp9XcxnS1MTv7pnz575YMLEJB2DqcVjdvxkZWLspfHrbxUOHy+3roxWVl\\/TH4VC4QNTm+YfvuXoo3fE\\/y8HAADopzSCY37TSoHjBgUOkZZyeJnLEL5cHBv744mt83vCwQ1yO0qb9h04MDa\\/ZcvtyxMTTyyUS2lC0stCdcTLjebqGL6sec1Srk5LvZYqlb8bn5299759+zYFBT4AAPKSChyzi1veEFYuOBQ4RBpk9aIuTZr4nWKp+Bfbjj32uOCCrmX3eNxDpheOOurOlfHx58cL5S+F6mSsNwajOwY9N59bI4QrCqXS+6cW5x+1Z\\/\\/+Y+q81AAA0H+pwDG3uOVNofqL6yEFDpFbZs2n1l8rVSrnTc7NnR527bLMZYf2P+IRlfmtW\\/eMTUw8KB7P18Q\\/+kLMtek2lmIoHiqEtPpG8VA1+b\\/+GyWF9JgmhC0U02N12d\\/qvwkrk+cWSqX3xdfsyXObNt1x+\\/btS0FxDwCAQaLAIVI3a0cUpFtRLol52dzmzXc4dOiQi7ouOnjoYHHbScceV5ya+vV4Uf3GeMl8caiuwpJGChw5usMoj96e6yujNAqFQjr2V8d8M+aDxXL56Qvbtyyfc845U01eTgAAyE8qcEwvbv6XoMAhsprVC71r44XeRfHi7vmTm2bPMGKjD5aWZpZ27dpbmpj4pWKp9DelUundoVi8OFQvthU6upI0KmbldsQbCzefByUVNS4vFAufKBaL\\/1gZH3\\/U\\/FFbTpubm9sUlk0YCgDAEFgpcMwpcMiGzsoF3uGlTMOlpXL5LROz0+ceddxxx1rmMieHDhXu8ZCHTO85+eQTpjfP321iaurJpUrl1YVi8RPxby8phMJVwQiPls\\/vcNN5XqyO0gjhh\\/F8\\/99SpfzeyuTkC2Y3bXrYpp3b7njr00\\/fdvDQIec8AADDZ6XAsbD5zUGBQzZkbrYixHeLpdKrNx+786y9e\\/eOB\\/MLDJr0epRPOvPM2eNPOfnWM5sXH12qlF4e\\/+y\\/Yq4ItZVZ6mQAzrO+Jqvok261uiwexU+UKpW\\/XlhaOnffmWces3t5eSL+uYIGAADD7+B73lOeXlhcU+AQGcWsLdwVVj7FLlSLG2k1iH8rj409fW7btjsu\\/\\/Ivp4s9hsTy8nJ5aWlp+\\/yWLadNzE79arFcflqxUnpZoVD4YCgULg5r5vI4fCtGGsFQGNZCyC36fMRtJiu3VsV8L\\/7Zf8dz+z2lSunFxbHyE2e2LD5wcevWU7bv3bt04MCBUrdeAwAAGBi1Ase\\/BgUOGencdFG7uszl5fEC+MMTs7MPu8297rUYGCm\\/fPDgxOYTT7zV2PzM\\/cbHJx9TmZp4cbzYvzC+5p+Nf\\/2tmB+FaiEgjWpI58MNa9Ko+JE1OqJbadTG2j6mfl8T84OYr8f9uqhUKl1QmZx8bmVi4lfnt269+97TT9\\/1iI+\\/pNLVAwsAAIOsWuDYpMAhI5nD82oU0vn9\\/Xgh+MHyxMQzJjfPnb6we\\/dCMDR\\/Q0gjPbadsm16btfcpon5+ePmt8yfNjM\\/c9bk\\/PwvTM7OPr40Pn5esVI5P5RKF4Ri8ePxPPlyfNq3QyqEVSc4XS2EHJ7Lov4okPVktfiWCi+pcPGd2I+vhDTnSKn0tkK5\\/PrYz78dm519Uur3xMLMnacXFm47sbh4zNyuXZt27N8\\/ZWQGAAAb2kqBY37xrUGBQ0YjR845kIoan4oXiX89PjV19uytbrU5QIaDBw+W997udktLu3adkIoH5cnZM6c2L\\/zczOL8Iyfm5v5wbHz8OaVK6W+LldKrQ7n0unhu\\/UuhVLggjQ6JeW+hXPpAzIdK5dJHYj5WTfmj6f\\/j338g5n0x7ywU0nMKb4zf+9rSWOkVlfHKeVMzU380s3nzb80tLj5wYnb2TpXp6VNTP44\\/5ZStj3jEI4zEAACAZt6TChxzi28LChwypCkUiocKK0teVpe9DNVP3L9SrFT+Znxh4d6bdu7cFf\\/fpKF07lA8d9LoiOXlctgfKmFvPJ92hzRfy+S2bduml5aWZjZt2jS3uLg4v7B7YWH+mGMWj8zinsX59D1btmyZDfE5YVeYXNnOvn1jabsroy8OHTryHHXOAgBAq1KBY2p+8e1heCbZkw2dNFlo4cbDCTcUCitzEXy7UCh8slKp\\/OXY9OQvzu1aOmHv2WenogYAAAAbQbXAMa\\/AIQOZQqGwklBdKSKN1DhUWxEljThKkyu+bXxx7tFLu3efmm63CocVgk+\\/AQAANg4jOGTAUm\\/yxTTx4hWhUPivUrn82vLE2NMnZ2fvOz47e1Ia8n\\/olsP6AQAA2Ghqk4ymAkfW8oiyoXPTrSBdz00rnBRutv10HqZVJK4MaRWLQuHC4tjYM6eX5u65Y9++Yw4dOmTVEwAAAG5pZZLR+fl3BgUOqZvuFjgOL9saVicETeddWorzfwql0tvL4+PPqoyPP2piYeanJiYmjksjNIKlXAEAAGgmDe+fnFt8dPzyvJgXivQo6fz6i5g\\/j3lOzMGYx8Q8uDwz81MT27Ydt2nv3rlw8KBiBgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADDbF\\/Mz8c8Keb5Ma+MuSDmjTGviDkv5mDMQ2N25NNFGjgz5nExz4t5ecy\\/xLwh5sUxT415eMzZMZty6t+omoo5LeYhoXqcXxjzmpi3xry69v\\/pzx8csz9mMp9uAgDAcPqtmEPrzOUxX4j5t5g3xbw05hmh+kv89v7tys28PKx\\/v1rNF\\/qzS7n6iZgnx7wjdH6M0nnxgJjpPvZ7uUGfbtXHftTzR6F+v77co\\/bShfWbMtpslHTx\\/eB1tPuADtrsZ356HfvWinvFPCfmIx3270Mxz+pDP1t1asju66dz7Nd6PCFk79Pv5tgvAADa1I0CR7N8MlQ\\/zd\\/bn11a8fIu9r9ZRrXAcVLMM2P+J3T\\/mL0+5kF92IflBn3YKAWOtJ+vzmirnXwx5pEdtL8RCxxnhWpB77Iu9\\/XSmL8K1RE4eWlU4Ei5W35d60g55ushe38UOAAAhkg\\/Chxr895QvbWh117ex30atQLHT8a8LuaG0Ptj99WYx4beDcVfbtD2Rihw\\/E5GG+vJxaG94tRGKXCUYh4YOh+p0W7eG3PvmEKX+t+qZgWON\\/a5P+v1S6Hx\\/ihwAAAMkX4XOFbznzH36+F+vbyP+zIqBY49oXpxksf58O2YR\\/dgn5YbtDnKBY4018O\\/Zmy\\/W0nzrsy00JeNUOC4S8xFOfX\\/Y6E6X0e\\/NCtwpMLonj72Z73S8Wu0PwocAABDJK8Cx2reHLO7B\\/v18j7uwygUOA6GfM+D1bw7dPfiaLlBW6Na4EhD7judK6XdfDBmrkl\\/RrnAsSVUCz1570NKmiC2lYLTejUrcKSc14d+dMOdQvN9UeAAABgieRc4Uq6I+cUu79fL+9j\\/YS5wHBPz\\/tDZfn825lWhuurDU2r5s5iXhepIkE92uN10Pvxal\\/ZvuUE7o1rgeHnGdusd50+F6mt1Xq0\\/LwrVVT3aOSfSJJizDfozqgWO5dB47oZGSbex\\/EU4\\/L5Zm\\/TnH+1wu+ln0e063J9WtVLgSBNPD8MKPOeH5vuiwAEAMESyChwXh+ov8O0kLSv5h6F6wfStjO02ygu7uF8nd9D\\/ZnlFRr+HtcBxl5jvhNZfn6+F6kVwmkSw2af2q9JFzs+G6ioSX2yjrZRnrXP\\/kuUG2x\\/FAsfPZGxzbS6ofV8zR4Xqz4ePt7jNLFvD+t97H85o98IubLuTC\\/HHZvQnK\\/8RqvOhnNFmO2fWnvepNtt7YAf71KpWChwpT+hhH7ohjRS7LihwAACMlKwCx391Ydsnxjwm5j0ZbdTLW0LvJpxcr7SiyKgUOO4TWn9N0nwpD+1Su3eIeW4bbb9kne0tN9j2KBY4PpuxzZRLQvV178RTGmw39fe0dfS5FW\\/NaPvVPW63nj\\/J6Eu9pMl6z+pSu6mw+OY22n5Ul9o9UqsFjjS6pdyjPnTD80Jr+6HAAQAwRHpZ4FgrXUz+fUZbRyYVRPpxL3m7RqXA0eotA6mwcU6P+rAjVEfstNKP9VzELjfY7qgVOH4lY3spXwnVguN6\\/Hi45cisd8YsrXO7rRiUAseLM\\/pxZP455jY96kO6BeUtLfbjMT1ov9UCR0q3bz3slnRLVbqNRoEDAGDE9KvAsSr90t\\/K\\/eXpF\\/hSj\\/rQqVEocKRPk1v5pb5fw8tvHZqvYpDy3A63v9xgm6NW4LgwY3tpGP5t19vZmrSd79W2+\\/zQv0\\/oB6HA8aSMPhz52v1cn\\/qTljdtZQ6Qbi\\/L3U6B42NdbrtbUtGi1X1Q4AAAGCL9LnCselxGu2vzVz3uQ7uGvcDxYzGXhcbH\\/F0xe3Po2x826VfKr3ew3eUG2xulAseWjG2lPLsbnV0jzQtxbpe32UzeBY4HZbR\\/5M+rRpOt9kKaPyRrbqC1uWMX22ynwJFyZhfb7oZizJeCAgcAwEjKq8CRpNEcjeYMSHlkH\\/rRqmEucMyH6mva6Fg\\/L7feVaVJaq8Ijft4jza3udxgW6NU4HhoxrZSju9GZ3OWZ4Hj9jFXZrSf8qOY+\\/ahH42kn5ONJsxMIz22dqmtdgscecyT0siB0F7\\/FTgAAIZIngWOJN2\\/3+iWlatC94bXr9cwFzjeEBr\\/Ev\\/Y\\/Lp2M+m1Tqu1ZPUz\\/d3mNra33GBbo1TgyLp9ol\\/v417Lq8CxGPM\\/GW2npHkc7tTjPrTq3qHxe\\/zCLrXTqMDx3Yw\\/P7pLbXdDu8tiK3AAAAyRvAscSVpy9JMZ\\/Riki7RhLXDcLzT+Bf6P8utaXWkSxUafmL+2jW0tN9jOKBU4np+xrfd1paf5y6vA8ecZ7aZcG\\/PTPW6\\/Xc1upXlYF9q4bYPtPyfjz7t9m1Sn0q069fqX5grJGk34O7n0FACAjgxCgSNJn\\/A1+uT+D\\/rcn3qGtcDR6BPof8yxX43cPzS+UDu7xe0sN9jGKBU4Xpmxrbd0paf5y6PAcauMNlfTq2VY1yvr51TKxTHT69x+owLH6aH+z\\/E0Me3UOtvthn8I9fudCkNZt\\/AZwQEAMEQGpcCR3DmjLyk\\/iDkmhz6tNYwFjnTrSdYxTRfSC\\/l1ral6nwZ\\/LrQ338FynW1spALHJ7vS0\\/zlUeB4fUabKW\\/qYbvd0GhlovUWixsVOPbHPDnj73qxZG07doX685Sk+UnSakAKHAAAI2CQChxJo6UY\\/zanPq0atgJH+qT2myH7eLY7YWce\\/iNU+3pJzCM6eP5y2BgFjmdnbOuKrvQ0f\\/0ucPxERnsp34\\/Z1qN2uyVN4JzV\\/zSaYnEd2240B8dpobqyS71bzNLKJcV1tLteWe+RJ9X+XoEDAGAEDFqBoxKy74VOn77lsYTpqmErcDRaevWVOfarHSfHPDV0Pqx+OWyMAsfvZGwr5axudDZn\\/S5wvCujvZROlivOw5+F7H14+jq226zAkbwk4+\\/vs4521yPdHvO9Ov1JhZhNte9R4AAAGAGDVuBI7pXRp5QX5tivYStwNBq9cVSO\\/eqn5bAxChz3zNhWypu70dmc9bPA0egWjI\\/1oL1emY35Vqi\\/H99ex3ZbKXCcnPH371xHu+uR9e\\/c2n9PFDgAAEbAIBY4kg+H+v26LFRHeeRhmAocaRLOrIuQ5+TYr35bDhujwDEWqkuWZu3r\\/bvQ3zz1s8DxJxltpZzTg\\/Z66fdD9r7cs8NttlLgSN6e8T39XvY73RbzpTr9uCHc\\/GeAAgcAwAgY1ALHz4fsX6J\\/Iac+DVOB42Uh+\\/gN+vwB3bQcNkaBI\\/mnjO2t5vR19jdP\\/Sxw1LsYThnGCVtnQvb50OmcRq0WOM7J+J6\\/67DdTt03ox9HThSrwAEAMAIGtcCRRmnUu2c6j1+Ql8ahIgAAGoxJREFUVw1LgaMQqhMh1uvrG3PsVx6Ww8YpcNw9Y3tr84vr63Ju+lXg2J\\/RTsrvdbmtfnl5qL8\\/l4bqz4p2tVrgSNv+XJ3vuSZmawftdiprPpW7HvF9ChwAACNgUAscyV+F+n37Yk79GZYCR6MVIH4px37lYTlsnAJHkrVc7NqkCSD7eYHZDf0qcDwxo52UYZ235mdCawWJVrVa4Egek\\/F9f9xBu53Imk\\/l03W+V4EDAGAEDHKB40DI\\/kV6dw79GZYCx1NC9nHbnmO\\/8rAcNlaBIxUuLsnY7tqk+TrS8pgz62irn\\/pV4Lgwo53PdLmdfmp0m8rvd7C9dgocWauXpMlPxztou12vyOjnw+p8rwIHAMAIGOQCR1q+L+sX6Z\\/PoT\\/DUuA4P9Tv50V5diony2FjFTiS0zK2Wy+pGJIu4Dpdhrdf+lXguCyjnb\\/scjv99pFQf79e0cG22ilwJM\\/N+N5f66DtduwK1dthWi2uKHAAAIyAQS5wJBeH7n3yuF7DUuD4RKjfz1fm2amcLIeNV+BIfilj21lJF31PjdnchbZ7oR8Fji0ZbaQ8oovt5CHdllRvvz7YwbbaLXDsCdUVS4783nq3iXTT\\/8vo4x9mfL8CBwDACBj0Asc7Q\\/3+dboCwHoMS4HjylC\\/n0\\/Ls1M5WQ4bs8CRnBWqE0m2U+i4IlQLYWkJ0WKX+tEN\\/ShwnJHRRspZXWwnD08I9ffr2x1sq90CR\\/LajO\\/\\/6Q7ab0XWrTHpZ+OmjOcocAAAjIBBL3D8Tajfv7fn0JdhKHDMhuyLj4fm2K+8LIeNW+BIjo15c0Y7zZL68dhQvVjMWz8KHD+b0UbKsV1sJw9pae2sfWv39e2kwPFTGd\\/\\/5jbbbtWjMtp7SYPnKHAAAIyAQS9w\\/Emo379eD2+uZxgKHI3mLTmQY7\\/yshw2doFj1U+G7Ak0m+Xbtb5u6UG\\/WtWPAsd9M9pIGbZVZ45055C9bye0ua1OChzJpzKe0+33YdbytM3aUuAAABgBg17g+L1Qv3+X5tCXYShwpAuxrIuP++bYr7wsBwWOtdI58N8Z7TbLD2KeHfIZ0dGPAkejVZuybmsYFvtC9r7dpc1tdVrg+OWM53R7AtdzMtp5S5PnKXAAAIyAQS9wPDrU79\\/lOfRlGAociyH74sMIDgWOVefGvCOj\\/Wb5bMz+PvRxrX4UOO6T0UbKsI\\/gSBN9Zu3b3drcVqcFjrRyybfqPKfRvBidyDqv79nkeQocAAAjYNALHE8K9fv3tRz6MgwFjjQxZNbFx6\\/k2K+8LAcFjkaODtXzut6EjM3y233sZz8KHHfLaCPl+C62k4fbhux9O73NbXVa4EielvG8J7XZhyxZ+5luaSw0ea4CBwDACBj0AkfWHBwX5dCXYShwJINwQTooloMCRytmQnWlja9n9Ckrr+hT\\/\\/JeReX2XWwnD43m4Di5zW2tp8CxLeaaOs9L5125zX7U87KMfv1aC89V4AAAGAGDXuBIFzD1+ndhDn0ZlgJHukCu18\\/n59mpnCwHBY52pYvBz4fWixzpvTjR4z71o8CxN6ONlJ\\/vYjt5ODdk71u7k8eup8CR\\/F3Gcx\\/cZj+OlG4jqlc8SbfFjLfwfAUOAIARMOgFjn8P9fv3whz6MiwFjqx70P81z07lZDkocHQifZqebmlqtdDxzzGlHvanHwWO1P9rM9r5\\/S62k4esn12XdbCt9RY4sp7\\/sQ76slbW++mPWny+AgcAwAgY5AJH+tSt3idyKb+VQ3+GpcDxolC\\/n9\\/Ks1M5WQ4KHOtRCdVbm74Tmhc5Ht3DfvSjwJH8Z0Y7r+lyO\\/329lB\\/v97bwbbWW+BI3pXx\\/Lt00J8kawLT9O9HqxPEKnAAAIyAQS5w3D1k\\/yL9kzn0Z1gKHI8K2cft1Bz7lYfloMDRDek2hjQCqFGBI03826tbVfpV4PjHjHbyWJa6W9Kyvlmv2Qs62F43Chz3y3j++R30J3l4xvZe2sY2FDgAAEbAIBc4nh3q9+2KnPozLAWOW4fsC5An5tivPCwHBY5uynpPruYJPWq3XwWO38hoJ+UnutxWv5wTsvfpfh1srxsFjrTa05fqPP+GUF3Sth1pdZTPZfTntm1sR4EDAGAEDGqBI\\/3SmrWiw1tz6tOwFDiSesO1Uz6XZ6dysBwUOLrtDSH7mH6qR232q8DRqDh4Xpfb6pd0e03WPi10sL1uFDiS383YxvPa7M\\/ZGdt5R5vbUeAAABgBg1rguEfI\\/iX6N3Lq0zAVOP4uZB+\\/H8+xX\\/22HLKPw23y69aKrCWQB73AsTk0Xk72+B602a8CR\\/LFjLa+3YO2ei3dWpT1On2gw212q8AxG3N5nW1cXvu7Vl2Q0Zdz2thGosABADACBrXA8b5Qv19Xhc4+deyGYSpw3DVkX4S8Msd+9duZIfs43DXHfiVZRajP59mpFj02ZB\\/Xx\\/agvX4WOLJG1qQ8vAft9dJTQ\\/a+PKrDbXarwJG8IGM7v93i82+V8fw0Uq3QZl8UOAAARsAgFjjultGnXl3QtGqYChxJ1ifRKbty7Fc\\/NboYe1CO\\/UqyVrb4eJ6datFMzPdD\\/f6\\/pAft9bPAsTejrZTP9KC9XkmTi6ZRJ1n70mmhuJsFjjTfxg11tpPm5yi28PyXZPSjk+KNAgcAwAgYtAJHKebTGX1KaWfSuG4btgLH48NgForasRxzYcwJHT5\\/d8g+Bk9af\\/fW5fOhfr\\/anTsgL1lLfV7Qg7b6WeBI\\/iWjvZS8bpFrV9bPq5S\\/Wcd2u1ngSN6Usa1mE6BuirmyzvO+F6rFnXYpcAAAjIBBK3A8IaM\\/Ka\\/LqU+rhq3Ake5jT7\\/sZx3Pe+bXtZakJUf\\/Oxzub5p8cK7NbaSC2bWh\\/v6\\/t1sd7cBtMvqU8pc59qsdWZ+e\\/2cP2up3gePOGe2tXkBv61G73XJyyO5\\/ynom2O12gSNrOfD3NHneUzKe98wO+pAocAAAjIBBKnA0uqhIuXUOfVpr2AocSaP5BL4ZBvtWlaeHW\\/b5azEPbnM7H6uzndXs6FZn23SwQZ+GZYTAH4b6\\/f9qD9rqd4EjeW9Gmynv6mG765UKmxeF7L6v95h1u8CRfCpje1kj9sZD\\/ZWirgmd\\/0xT4AAAGAGDUuBInzg2Wpnh2X3uTz0vDPX7NshLr6a5Ei4O2cf1Q6E6UmLQpPkxGhW77tXGtp7bYDtP7l6X2\\/KlBn36sXVsNxVsnrHu3rXm+aF+\\/z\\/cg7byKHDsz2hzNS\\/qYdvr8cbQuN\\/HrXP7vShwPDxje6\\/I+P5fafP7W6HAAQAwAgahwLEv5hsZ\\/UhJF+gzbW5zMeasUP3l9O9jjupCP8\\/P6N\\/7u7DtXvqF0PiCJ803UMqtd7eUhqxn3VaS8uY2t3evBtu6InTn3GjHkxv0p9PRD9Ph5qNC+rFCzOtC\\/X14fQ\\/ayqPAkWSt8rGaJ\\/S4\\/Xb9VWjc3yd2oY1eFDgajcjYWuf7s+ZpWs8cTQocAAAjIO8Cxxkx38noQ0q60L1ji9tK35eKEF+os52f7kJfv5LRx3\\/uwrZ77TWh8YXPP+TXtZtJ84L8IGT389LQ2fwHlzbY5t+uu9et2xmqRZWsvvy\\/Drb5q6F6687a7by3C31tJI36yZrf5YU9aC+vAkea8+VzGW2v5jE97kOr\\/jw07ueHutROLwocyTMytnnknBpZq2yt97YhBQ4AgBGQZ4Gj2W0IKY9tY3tnNdhOJxeOa53QYNvDMClkGgHTaHWalHeGzpeO7Ib7ZPRrbe7b4baf12S7v7KejrcojbL49yb9OLHNbTba3m91pdf13b9Bu+f2oL28ChxJumWoUVEq5bl96EeWdF69NqNfq7kkVItr3dCrAkeaO+O6Ots8clWUrBVuOv3ZsEqBAwBgBORV4Ph\\/Ge2uzUvb3ObmBtv67x7292Hr3Ha\\/nBQar6qyepxuk0Pf\\/qBJv1LWczvA9pgfNdh2Gil0l3Vsv5l0C9AFDdpP+fsOtvuiBttL+7u8zn7XMxayl7i9KlQnuey2PAscyQMy2l+bt4T+FwiPjfl4C327Uxfb7FWBI3llxnYfWfv7tPrLDXX+Ps1pU1xn2wocAAAjoN8FjvSL6sUZba7NWzvcfqPh5J1+op0++byswXb7PYfDejRbqSbl+6F\\/w+7Tp+MfaqFPL+5CW1lD4FeTbo15eBfaOVI6P97RQtvHdLDtY5tsN4086ObFbXJeg\\/be0OW2VuVd4EgaLWG9mlT4uVuf+pNGHTW69Wo1D+hyu70scNwxY7vp53ohZBf0ujFaSYEDAGAE9KPAMR\\/zmyF7Dosj84FQvfe9E41GAqSLyHZ\\/AU+3djS6DeA\\/Ouxnnlr5NDrlg6F6208vnBmqIxZa6cfrutTmZMwXW2gvfYrcrU\\/i0wSn9SZP7OZFVL3ldI\\/Mvdex\\/bX+uEk77axu045BKHAkf5nRjyOTVvPY26M+pCLAO1vsRy8uzntZ4Eg+mrHtrFsaj7yFpVMKHAAAI6BXBY5U1Ei3brwpY\\/tZScP4J9fR7s4m209L0e5vcVupyPK+Jtv7tXX0NU\\/pfvVWX5NU6EivZadFp1XpdU2fOn+4jbZfts42j3SHmCtbaDcVJdJ7o9JhO+ki8MIW2klJtzasZ3h9OVQnFW3URprb4O9iju6wjbSMc7P9ubDTHWjBoBQ4kudk9KVeXhWqE+euV5pn48Ex726j7d\\/oQrv19LrA0Wh+l3p5VhfaTBQ4AABGQFaB49sxT2kz6RaAdBHV6oXdkenW6gsvbKGtNMw+a3WWtMRsKyNOvtKl\\/ublp2K+G9p7jdISoOeG6jFqJs3F8BO170\\/LbTa6zade\\/mz9u1hXqyNYUv4nVCeQvF\\/MpibbTfv6+FAtWLS6\\/fRpdbtLINeT5hipt3pQvbwxVI\\/BUgvbfGjM21rc7q27sB9ZBqnAkTw+oz9ZSe+ztFrPz7TRRnqPPSRkL8fbKA9cz8410esCRyrYHbkqUFZS4W5XF9pMFDgAAEZAVoGjn0lzPvxiF\\/cp3V7w9RbbTpPTpYukVJz569B8xMba9GPljV7bHfNvobPXLa3M8LFQXdUgHbvVY5iGz3+jw22mpFuJHtHDfQ617XfSt6+GagHvJaE68WxaIrjZ6jRZ+VSoTozbLWn00n+22Yc0qWyaNyPNcfLHtcc06qqVW3n6eRE4aAWOJN2+9c2MfjXLl0P1Z00qXqSCbDr2fxWqxz7dEndJh9tNc1Wc2sudDr0vcCRPbNDG2ryqS+0lChwAACMg7wJHGhHQ6bD5Ru7Z4353suLFIGs2AWe\\/8p5QLbr0QxoK38rtKr1IKpLM92CftoXsOQx6lfWsbtOqQSxwJOl4vybk\\/75JSaPSujEXRTP9KHCk0VKtvDfP6FJ7iQIHAMAIyKvAkSbnbGe4dic6\\/ZS+WdIcEuuZJ2RQnRCyLyR7nXT7ymN7v4u3cNvQeOWdXuRJPd6ndJH72j7ty2\\/2eF9WDWqBY1UazdHv82g1aRWi2\\/Z+F2\\/SjwJH0mxC1\\/d3sa1EgQMAYAT0u8CRPrn+2b7sWdXDu9z\\/NCR6uo\\/9z0N6fT4T+nM+XBPz56G7t2q0KxUEXhB6v6+fCNV5OvrlyaH9OVZaTZrv4\\/T+7crAFziSNCFtKtKl+Yv68d5J88P8Uqgun9pP\\/SpwnNygnZT7d7GtRIEDAGAE9KPAkeZpSMu3HtenfTpS+kW5nbk16iXN6fGofnc8Z2l\\/PxJ6c06ki8AXxRzft71pLvUlzSFyRejuvqZz70F93I+10kSvaULMVicgbZY00uZ5oTsTo7ZjGAocq9LkoGnp3q+E3rx30pwvv92vnamjXwWO5IKMdtLcSetZeageBQ4AgBHQjQLH5TGfD9WlKtOEhX8Tqr\\/gp5n8m63U0E9pidB0Afud0Pq+pU\\/dfz1mIof+DooTY54a866wvvPk46E6WuOs\\/na\\/beniPa0eknVx1UrS++FpoXrsBkUaPfL8mItC+\\/uTVlJJK3rkdWvWMBU41rpLqBaE0s+R9bx3UpHsYOjvrShZ+lng+JmMdnpRdFDgAABgaKVix+NC9YL7laF6MZvmLUgrGaQVDVpZRnMjSrdzpOVlHxOqqz+kC88L1yQtQfqKmL8I1QuyXw39vZWhF9LcJHcN1bkz0qoXFx6RdO48K+Y+oXoB2mw52UGQloBNtzekQmRaOeX8UC1i\\/FOovgf+NOaRMbfPq4MjKP08Sbd\\/pUlZXxbzjnDLcyklvafS6Kb0HkvFwFG\\/JQ4AAAAAAAAAAAAAAAAAAAAAAACANvxDzJUiIiLStbw0AADQd2nlh\\/UuBSsiIiKH86oAAEDfKXCIiIh0NwocAAA5UOAQERHpbhQ4AAByoMAhIiLS3ShwAADkQIFDRESku1HgAADIwdNi3i0iIiJdy5MDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD\\/vz04JAAAAAAQ9P+1wRsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAL6JKIFTUgrE4AAAAASUVORK5CYII=\\\" alt=\\\"Imagen\\\" id=\\\"igyb\\\"\\/><\\/td><\\/tr><\\/tbody><\\/table><table width=\\\"100%\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" border=\\\"0\\\"><tbody><tr><td id=\\\"iibsm\\\"><p id=\\\"ie5ff\\\">Prueba 1<\\/p><\\/td><\\/tr><\\/tbody><\\/table>\",\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[{\\\"type\\\":\\\"image\\\",\\\"src\\\":\\\"data:image\\/png;base64,iVBORw0KGgoAAAANSUhEUgAABDgAAAVGCAYAAAB7TwuKAAAAtGVYSWZJSSoACAAAAAYAEgEDAAEAAAABAAAAGgEFAAEAAABWAAAAGwEFAAEAAABeAAAAKAEDAAEAAAACAAAAEwIDAAEAAAABAAAAaYcEAAEAAABmAAAAAAAAAGAAAAABAAAAYAAAAAEAAAAGAACQBwAEAAAAMDIxMAGRBwAEAAAAAQIDAACgBwAEAAAAMDEwMAGgAwABAAAA\\/\\/8AAAKgBAABAAAAOAQAAAOgBAABAAAARgUAAAAAAADTyGbmAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAFXGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSfvu78nIGlkPSdXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQnPz4KPHg6eG1wbWV0YSB4bWxuczp4PSdhZG9iZTpuczptZXRhLyc+CjxyZGY6UkRGIHhtbG5zOnJkZj0naHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyc+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczpBdHRyaWI9J2h0dHA6Ly9ucy5hdHRyaWJ1dGlvbi5jb20vYWRzLzEuMC8nPgogIDxBdHRyaWI6QWRzPgogICA8cmRmOlNlcT4KICAgIDxyZGY6bGkgcmRmOnBhcnNlVHlwZT0nUmVzb3VyY2UnPgogICAgIDxBdHRyaWI6Q3JlYXRlZD4yMDI2LTA1LTA3PC9BdHRyaWI6Q3JlYXRlZD4KICAgICA8QXR0cmliOkRhdGE+eyZxdW90O2RvYyZxdW90OzomcXVvdDtEQUhHWXBzZmxSTSZxdW90OywmcXVvdDt1c2VyJnF1b3Q7OiZxdW90O1VBRU9OVndMYVdZJnF1b3Q7LCZxdW90O2JyYW5kJnF1b3Q7OiZxdW90O1RlY25vRmlicmFzIFMuQSYjMzk7cyB0ZWFtJnF1b3Q7fTwvQXR0cmliOkRhdGE+CiAgICAgPEF0dHJpYjpFeHRJZD44NGRkMzJmMy0yNzZiLTQ3ZjctYWZmYS04NTM0YmMzM2VhMDA8L0F0dHJpYjpFeHRJZD4KICAgICA8QXR0cmliOkZiSWQ+NTI1MjY1OTE0MTc5NTgwPC9BdHRyaWI6RmJJZD4KICAgICA8QXR0cmliOlRvdWNoVHlwZT4yPC9BdHRyaWI6VG91Y2hUeXBlPgogICAgPC9yZGY6bGk+CiAgIDwvcmRmOlNlcT4KICA8L0F0dHJpYjpBZHM+CiA8L3JkZjpEZXNjcmlwdGlvbj4KCiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0nJwogIHhtbG5zOmRjPSdodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyc+CiAgPGRjOnRpdGxlPgogICA8cmRmOkFsdD4KICAgIDxyZGY6bGkgeG1sOmxhbmc9J3gtZGVmYXVsdCc+MjAwMCAyMDAwIC0gNDwvcmRmOmxpPgogICA8L3JkZjpBbHQ+CiAgPC9kYzp0aXRsZT4KIDwvcmRmOkRlc2NyaXB0aW9uPgoKIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PScnCiAgeG1sbnM6cGRmPSdodHRwOi8vbnMuYWRvYmUuY29tL3BkZi8xLjMvJz4KICA8cGRmOkF1dGhvcj5EYXZpZCBBbHBpemFyPC9wZGY6QXV0aG9yPgogPC9yZGY6RGVzY3JpcHRpb24+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczp4bXA9J2h0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8nPgogIDx4bXA6Q3JlYXRvclRvb2w+Q2FudmEgZG9jPURBSEdZcHNmbFJNIHVzZXI9VUFFT05Wd0xhV1kgYnJhbmQ9VGVjbm9GaWJyYXMgUy5BJiMzOTtzIHRlYW08L3htcDpDcmVhdG9yVG9vbD4KIDwvcmRmOkRlc2NyaXB0aW9uPgo8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSdyJz8+6JVLDgAAIABJREFUeJzs3QucXXlBH\\/D\\/edzHzL137ryTzWZD2KRsG2GXNaIuIAQBEVrUVlNFtFItW6VKX7i2aCUisKw8FlAei0qrFNQtSq20FC2syMpredR3axUtoPtxLbC47DPJTM+5904yj3snyZw5c2fu\\/X4\\/n1\\/ObDaEzf+ef3LOL\\/\\/zPyEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAnPPkLB8V2eHcMTE19fwAAAAA2yJJTkYhPpt9dUZkB7PUaLVfHgAAAGA7JEnyrSFES9mXeZZFdiCd822i1boxAAAAwHZIqsm3KThkh6PgAAAAYHspOGQIWSk4PKICAADA9lBwyBCi4AAAAGB7JUnyrNC74QzDv\\/GV8YhHVAAAANheSZJ8e1BwyM6mW3C02woOAAAAtkeSJM8OCg7Z2XTOt8l2+2UBAAAAtkOSJN8RFByys1FwAAAMQbTFsDO2+vn47KAnSZLvDAoO2dl0zrdmq\\/3SAABAeZaXl6NVifPcurycrGS5m\\/gCiQZl2L++vWazsVw\\/7iuf0anbbktXcv0tt1ROnjpVXZ\\/8+\\/PkP+bWtZ+pz4ixouCQIaRzvjVaVnAAAJSi0m5\\/RbXZ\\/HeN6embW9Ozr27Nz7+6Obfwuqm5xTe0Zxff3J5ffHNrsZNbphYX35jlp6YWsn+fJftxr82Tff2aZjc3t+YXX5X92Fe2s2Rf\\/0SWm9oLiy9vLSzcmOWl2Y99ydTcwo9nP8+Lp+bnT2V50dTs7I\\/mac7O\\/rtO5uZ+JMsPd48LK\\/nh1tzcC1szc\\/+2NTPzQwNyQ5YfLDk39LL6\\/3P9f8e\\/WUmj+8\\/5f3P+3\\/7C3q\\/tR\\/Jf58qve2q2Mw4\\/lo9L9u9e0ppbeGmWG1tz8zdln0c+hq\\/ojeurm\\/MLN2c\\/5rXNmXz8536qOTf\\/hsmZuTc2Z+ZvmZyd\\/eksPzs5Pf3vJ6dnfm5ievqt9ZmZt2d5W+fYnnnbxPTMW7Pv\\/\\/nJ6dl\\/35ie\\/ZnJmdk3NWfmXt\\/IP\\/u5uRubs\\/M\\/lv+3NmZnX5CdE\\/98cmrqnzWbzesbjcZ3TTSb31prtb6h0W4\\/uX3Z\\/Je39+17+OTk5IHQbC5MHz48ffC66ybCyZNJsCqEPUDBIUNI9xEVKzgAALbfrbfemlQnW2\\/Jvnwwy+ksZ1bl7CY5UzCnZWAudSw3+5wuJX0+m+ih7JgnPz8eyHJflnuyfCHLXVk+G6Lo\\/0ZR9EdprfaBSrX+C3G1emM6MfGvJxqNZ03Mzj52\\/qqrrrr2cU89cP2pU5MBdhEFhwwh3YKjqeAAANh2J289Va01Wu8OnRvcaOVC\\/2Iu+Nf\\/WNnhRN3kz5Vs64X3Bf9\\/o2hDBvzYvBD5Yoiiv4zS9Pertfp7klrtJ6uTkz\\/cnF34h3P79z9mcXHxynzlx+HDh+vhVIgD7CQFh+x8egVHS8EBALDdTt56a7XWaL4ndP8Gf9gXfrJ306\\/gGPT9+bmWrxC5P8tfRXH8sbSavqM1N3fD\\/OWXP+nqr\\/zKh5\\/sPuYCpbKCQ4YQBQcAQFlO5QVHc0rBITuZ86s\\/wpoVIA+FKPpCFMd\\/GiXJ+2r1+ptrzeb3ziweeNyRI0cWr7\\/++kqAbZQkyT8KCg7Z2Sg4AADKkhcc9ebU\\/wgu8GV3ZN1qj0758aXs+Pu1yebrpxcWnvPwL7v2mhMnTjSz71\\/ZzBS2Jkm+Kyg4ZGfTLThaCg4AgG33A697Xa3eaL0vuMCX3ZUN+35kx7PZ8YEoiv8iSpIPJ7Xam5szM9fPzu4\\/dtVVV7UCXCoFh+x8FBwAAGXpFBxNBYfs7kRRtHJcv7lpvpfHnVGU\\/Hp9svmimcWZxy0sLOw\\/fvy4x1m4sCT5x0HBITsbBQcAQFme3ik4mu8NLvBlb6Xf5qV52XF3FEWfrExMvKY9O\\/vUr3r2s6cCDJIk\\/zhScMjORsEBAFCW7gqOqd8INhmVPZ4Nr62NorvTNL2tWq\\/\\/WKPdfsq+I0cWw6lTXkXLOUmSfLeCQ3Y4nfOt0Wq\\/LAAAsL3y18TWp9p5weECX0YtK5uU5l8\\/GKLod6r1yRcefeTxI8vLyyubk9qkdIwlSfI9Cg7Z4Sg4AADKkr9FZbI9\\/evBCg4Z0USdTUrjXtkRPZR936eTSvUXq43Gd1x+9OjBwNhScMgQouAAAChLXnA0ZmffExQcMh5ZvWfH2ShNPzw5NfW8K44+8kj2z9VgRcdYSZLKP1FwyA6nc741W217cAAAbLdewfHfg4JDxiurXkEb3xfF8R8ntdot7X2XP\\/nqr\\/u6RmA8VCrPVXDIDkfBAQBQlltuuaXSmpl9d1BwyNgm35g0WXmE5Z4kTd\\/dmJl51uyBA1ecOHEiDYysOI6vV3DIDkfBAQBQlk7BMTv7X4OCQ8Y6UX7s3ehGZ0MU5as6fq\\/ZnHr+tdd+zUJgJMWVyvcqOGSHo+AAACjLLbd8rNKamX9XUHDImCbq5dw\\/d141u7Ipabg3SZKPTDSb33\\/ZZZc9LASvmR0llUrl+xQcssPpnG+TrZaCAwBgu93ysU7B8V\\/CuYIjGvbFn8huyrkNSbP82exlB5\\/7zOuvnwxdNiTd4yqVyvPiSMEhOxoFBwBAWW67bTlVcIhsnnxVR+g+vnJvlCR3TEw0\\/vllD3\\/4wwJ7Wl5wRAoO2dkoOAAAytJ7REXBIXJROffoyukoiu5ozMw8+8AjHjEf2IuiSqXy\\/R5RkR2OPTgAAMpy23JnBcevhnMX+AoOkQtkqbtPR7SyouO97dmFf3j8mc9ceXSFvaFTcOSPqEQKDtm5dAqORqv9sgAAwPa67bbb0tbc\\/DuDgkPkUrPyatl87tyTVCr\\/YWpu7jHHjh2rBvaCvOD4AQWH7HCs4AAAKMup225L23OLCg6RradzwxJFUf6Y111prXrTw44fvyyw250rOIKCQ3YuVnAAAJTltk7BsfArQcEhUjQrj62ciaLkQ\\/VG47uuvPLKdmC3imIFh+x8FBwAAGW5dXk5ac8t\\/nJQcIhsV1ZumE8nlcovTh84cO3JkyeTwG7TWcGRKDhkZ6PgAAAoi4JDpJSs3DSfyfKptDpxw\\/6jRxcCu4lHVGQYUXAAAJSlV3C8I3Q3TFxWcIhsa5ai7g30mSiK3jc1u++rg01Id4vuW1RiBYfsaHoFR0vBAQCw3fKCY3p+\\/629t0EsKzhEtjf5vhxxHOc3NfkmpHemtdoLTp46peQYvk7BkSg4ZGfjLSoAAGXpFBwLCg6RHcjKjfSXoiR5x2S7fTwsL0eBYckLjn\\/mERXZ4Sg4AADKkhccM\\/P7f0nBIbJj6b1tJfxFa27um3obkCo6hqBSqTyvW3BECg7ZqSg4AADK0i049v1SsAeHyE5mZdXAXXGavmT+iisOBCXHjqtUKt9nBYfscGwyCgBQlk7BsbC\\/V3DkF18KDpGdSm8lx5koSd4ze+josezrOLBjFBwyhCg4AADKouAQGWpWHlc5E6Lojyanp78hsGPiSuV784IjUnDIzkXBAQBQFgWHyK7IStFxZ21i4gWHDh2aCZROwSFDiIIDAKAsy8vLsYJDZLiJomg5juKlOO6UHPcnSeXnrrr2WvtylCyuxB5RkZ2OggMAoCwKDpFdl3wunk7S9L\\/PX375IwKlie3BITufXsHRUnAAAGw3BYfIrk0+Jz+8\\/9ChLwuUQsEhQ0jnfJtUcAAAbD8Fh8iuTedGKIqiT07Pzz\\/x1KlT3rCyzeJK5XlRUHDIjkbBAQBQll7B8YtBwSGyW7MUovDpyZmZZwSvkd1W+QoOBYfscHoFhz04AAC2nRUcIrs+3RvwKPrURLP5zSGcSAPbIq5Uro9DpOCQnYyCAwCgLJ2CY58VHCJ7IPkc\\/Wy12TwZTig5tkWl8k8iBYfsbBQcAABlyQuOWQWHyB5IfiOe5PP08\\/XJye\\/OjkmgkCRJvlvBITucbsHRVnAAAGy77gqOfQoOkT2Rczfjf1lvNJ5z\\/PjxSmDLkiR5TrAHh+xsFBwAAGXp7sGx7xeCgkNkD6VTdHx+dmHh6wNbliTJPwrnCw4pJ7tgvuyqKDgAAMqi4BDZk1l5hewnLjvyt48HtiRJkmeHVTfj2XiubOi69p\\/XfX2h5D92fS72fzvo59nK\\/77fz7fx+7rZrp9\\/1VtpluLuf\\/uw58pui4IDAKAsCg6RvZveDev\\/nplZfFxgKx6d5U1ZXt\\/LLVl+Osube1\\/n\\/+6NWd6Q5aey\\/GSW12V5bZbXZLm5l1evOuZ51eDEeV65Kr3v2+x\\/08kFft5zeeUF\\/l2eV\\/TyE9n\\/d56bsq9fnuXGLC\\/r5cd7efGqr1\\/SS\\/bv4xu7\\/\\/tOXtH7+W\\/ujU8+Zj8TouiD2fFs2AVzZRdFwQEAUBYFh8jeTXR+pcEd+6448sjApYqyVLNUeqn2SWVV0gFJRiDxFrP651gZj3zcatXW9Ddmxwet4lgTBQcAQFk6BcfivreHzkVXfrPkQlRkD+ZslCS3z19+5SMC7BJpvf7E7HBvsBfH6ig4AADK0nlN7OJlnYIj8ry0yF7O2ZAkH2nNz18VYBdIJyYemx3+JnQL9GHPj92STsEx0W7fWGhwAQDYaF3BsazgENmzWXlc5Tcuu+yyhwUYsjStPz47fMnqwI3ztKHgAADYfgoOkVFK50bydFKpvP3w4UdPBxiiNE2fkB3uU3CsiYIDAKAsq\\/fgUHCI7PVEKxuPPpRWq6ey+Z1voglDkabpE7PDAwqONVFwAACUpVdwvC0oOERGIt15HOc3lJ+vN6a+PXTfagE7rreC434Fx5ooOAAAyrJmBUd+czT8iz8R2ZZ0VnLcOTE7+9UBhmBtwREU6N0oOAAAyqLgEBnNxHGcr8rKXx9724ErrzwUYIelafo1QcGxPgoOAICyrHlEJSg4REYsndc\\/x0nylgMHDkwG2EG9guM+BcfaORkUHAAA5VBwiIx2uvtxhHtqExPPP3XqVBxgh6RpPS847lVwrImCAwCgLKsfUell2Bd\\/IrKtyW8qu\\/txNKennxRgh6Rp+vjscG+vZFu20WgnCg4AgLKsKziGfeEnIuWkc1MVJcl7H\\/3oE9MBdoCCY\\/BcVHAAAJTACo6Luxgdgwx7nKXk5HtxZHkgrVZvOnjddRMBSpbWu4+oKDjWRMEBAFCWvOCY6+3BEdzonkv+rHgv2U1hd6PGlTHq3SieS+juX9JJGJDN\\/l2\\/H3uhn2\\/1zxldKH3+ewf9OjbJ0D8T2Zbkn+WD9ampbw9Qsl7BcZ+CY8McVHAAAJRh9SajwY3sufQ2w\\/tClKa\\/HOL4lhAnb8yOb87yM71k3xe\\/KcsbsvxUltdleW2W12S5uZdX9\\/KqVXnlqrxiXX5iVVb9c3pTLy\\/P\\/jnPTef+Xej8PK\\/Kjnlu7uW1vbwu+zW8Pssbs7wpy09neUuWn8+Sr9r5pSy\\/kuW\\/ZXlfltuzfCjL\\/8zyZ1k+FzpvQAhnwgXKlmF\\/XnLRWSm3Pnrg2LFDAUqk4Bg8BxUcAAAl8BaVtYmipLtyI9+UMQqfPHjNNZcXH+U9Iw4nQhpmZtqhVjsaKuGrQxKemX3\\/92d5VZZ3hG4J8r+y3JPldHa+nA0h9FsBMvTPUjbNmaRS+VmPqlCmlYJj5S0qCo5OFBwAAGVRcKxNFMXnC458JUOjsS87RkXHeQTkY5BmyW+IF0O1enWoJt+Uff2jobsi5HeyfDH0X+0x9M9V1iaOO3+jfu9Ee\\/Zb1n\\/QsF0UHH2zUnC8vNjoAgCwwaqC46yCI0\\/cO3YuyD\\/eWFzcV3SMx0ASJsNlIQ0nsq9\\/MMtbs\\/xhlrtDXnhs3ONjF3zOEvI5H0UfOnDkyBUDPlcoRMHRNwoOAICy9AqO\\/xgUHL2sKTg+oeC4ZHGWepa88Hha9k\\/5Rfzvhc6bFJQcuyz553A6rVRuDkeP1gZ+orBFaZo+ITvcr+DYMO8UHAAAZVBwrE0Uot4YdJbwf7KxsLC\\/8CCPt7jRaOwPSfL3Qhznm53+QZa\\/Cave4hJ2wec+rumN\\/53N+f1PvMDnCJcsTdP8vHpQwbEm9uAAACjL6oIjDP\\/CbxelW3CEhYaCo7jze5gcW2jWGrWnZd\\/zqyHfsyNaWdGRj7ebn2EkiqKzIUl+\\/dCjHjWz2YcIl6perz8pm9cPBqu2VkfBAQBQFgVH\\/\\/T+ZvuTwQqOcuzb1wiVyvE4jl8Uuq+lvT94fGUY5\\/nKuf5AZWIif1uODXXZNmm34DgdzOvVUXAAAJRFwTEokUdUdkir1ZoLcXhe9uXvhm7RcbZz0x25KdrB5I8L\\/c7hxxxzvrNt0nr9ayMFx4a5FhQcAADlUHAMSm+TUQXHTkmyXB6S5Huy4weyPHD+8ZVhnwujn95+KA+m1dpPhGPHqhf1icEFpPX6k6MQnTm\\/B4cEBQcAQHk6Bcf8SsGR74FgH4RuvEVlaA5OzWbfPjfL+7N8IZx\\/dMVNUnnn+8o5\\/7mJiamvvqjPCS4grdefEvJXRdtkdHUUHAAAZVFwbHoR+nEFx9DEs7OzU9VW6+9nX38iKDh26pxfiuPkl06ePGUVB4WdLziCgmPdPFNwAACUYO0jKgqOVekWHI2GgmPIaq3WI0Ic5zcDnwm918uG4Z8fo5p8bO9OJie\\/KdhwlILSRuOpkYKj3xxTcAAAlMEKjk0vQj\\/ebDYXi40w26U+0\\/qa7PDBLGd6JYeio4T0xvb20GrNX\\/SHA330Co58fycFx\\/msFBwvLza6AABsoODY9CJUwbG7RNnnsRDHcf460z8OK29bGf65MlLpjel9SbX6bZfw2cAGaa32dQqODbGCAwCgLN6isulF6CcUHLtTZXLy2uzwrixfCvbnKOf8j6L\\/sm\\/fvsbFfyqwloJjwNxScAAAlKO7gmNRwdH\\/IlTBsXvl+0NMx5XK87PjXUHJUcb5f9fE3NxXXvxHAmv1Co5V81LBETyiAgBQHgXHoEQKjr3g1Km43mo9PvvqtiwPxXH2uUXDPndGIvn5fzau1l+cHZNL+kygJ63VnhYUHP3mloIDAKAMCo5BiezBsXdErcsvnwtx\\/MYohAciKzm2I0tRFOdvrPndw49+9PQlfyIQugWHFRwb51ZQcAAAlGPtJqNDv\\/DbRVFw7DWzs7NTcRy\\/IPvyL8OqR1aym\\/RdcD7tyeTj96XW3Nw3XuJHAR0bV3BIUHAAAJRHwTEoCo69KqlW8xvyO4N9ObYjS1GSvvPEiRP10N33BC5aWqt9fTAHN8ypoOAAACiHgmNQFBx7WDoxMfHYEEUfzJfHR8GrZAskH7vPTczOXnfpHwPjTsExcE4pOAAAyqDgGBSbjO51jUbjUdnhN6MQHgpusraafB+OpThNX3TpnwDjLqnVnh7MvQ1zKig4AADK0Sk4Fm0yujEKjhEQTczOHsyOvxY8rrLVdMYtipL3H37Oc+qX\\/Akw1hQcg+dUo92+scjYAgDQh4JjUBQco6Jer1+ZHX41CuHB4Gbr0hN15sJftxYXPabCJVFw9I2CAwCgLAqOQVFwjJL9R48uhCi8J3TPczdcl56lOKm8IZw8mWxh+BlTCo7+cykoOAAAyqHgGBQFx6hpzc9fFaLot6IoOhtFNh69xOTj9b8mJycPbGnwGUsKjoFzScEBAFCG7iajCo6NUXCMonpr5vHZ4dPerHLJycfrbL3dfspWxp3xVKvVnhGGf+7utthkFACgLAqOQVFwjKi0NjmV\\/63yn\\/dWcuyCc21PpFMIpdXqy7Y27IwjBcfAuaTgAAAoQ\\/cRFa+J3RgFxyiLK5Xrs8O9HlW5+ERRvBSi6IPXXXfdxBaHnTGj4OgbBQcAQFnswTEoCo5RduD48cmQpq\\/Mvnwo2CPgopKveMmOd1Xm5h6ztVFn3Cg4+kbBAQBQFgXHoCg4Rl3rwIH5EEXvz1dxWMlx4fTG6Eyc1v5Vdoy3Ou6Mj17BsRSUiKuj4AAAKIuCY1A6N3MfV3CMtqRW+4bscL+C48LJ9yvpjFMUvTMsLDS3POiMjVqt9nfDLjh3d1kUHAAAZVFwDIqCY0zUs+Sva3wg+Fvmi0k+Rn8SpusP29JoM1YUHAPnkIIDAKAMCo5BUXCMjXo4lH17e+jOASXH5snH54u1RuNpWxtsxomCY+AcUnAAAJShV3C8NSg41kXBMUaiyXb7K7LjpzyqcsHk43M6rlZfstXBZnwoOAbOobzguLHI2AIA0IeCY1AUHOMmraX55pm9VRzRcjfDPg93ZfJ9ON5z+MSJ+tZHm3Gg4BgwfxQcAADlUHBsehH68WZzn4JjTDQajf3Z4XejKORvVVlWcPRPb5XLn4dW66rsGG19xBl1ecER7YJzdpelW3C0FBwAANtOwbHpRejHFBxjJapOTn5jdvzrYC+OPukWPr2C46GkNvmMrQ8140DB0TcKDgCAsig4Nr0IVXCMozh+e34Tbz+O9emuaumNy1Kcpj+Sj1ahsWakeUSlbxQcAABlUXBsehFqD44xlKbpY7PDXcEqjnVZs4Ij34fjP2XH2tZHmlGn4OgbBQcAQFkUHJtehH5MwTF+jh07Vo3T+DXZlw8GJceGRJ0NeDslx4dDmG8VGGpGnIKjb2wyCgBQFgXHphehCo4xNTU19beyw\\/\\/xmMqm8+Mz9cX2lVsfZUadgmPg3FFwAACUQcGx6UWogmN8VeKl49ykAAAgAElEQVQ4fm12PKvkGDg\\/7q412k8tMMaMOAXHwLmj4AAAKIOCY9OLUAXHGGs0Go\\/KDp8NHlMZND9OhzQ9tdXxZfQpOAbOHQUHAEAZFBybXoQqOMZbGsfxG7LjmaDk6D9H4vhtx48frxQYY0aYgmPAvFFwAACUQ8Gx6UWogmPMpfX647PD3d3XxsbDPid3W\\/LNRr1KmYEUHIPmjYIDAKAUCo5NL0LvCAqO8TYz0w5R9N+yr5aiKBr2Obnbks+Rv6rVWlcVGWJGl4Jj4LxRcAAAlGFdwWEZ\\/tqL0LzgWCgyvux91YmJb84OX7LZaN85cm9lYuKriowvoysvOKLhn6e7LQoOAICyKDgGJVJw0HHl8ePt7HB7HMfmx9p0NhpNqtVvKzK+jK7eCo6l4M+W9fNGwQEAUAYFx6AoODgvTuMbovM3J7vg\\/NwV6dyoxXF8Q6HBZWQpOAbPGwUHAEAJFBybXoTeEfbvV3AQJiYmvjI7fDGYI2vmSNR5k0r6qkKDy8iyB0f\\/eZNnst1+WZGxBQCgDwXHphehCg46ZvLNRkP4tWCOrJkjnX1Joug\\/Z7+RRIUGmJFkBUf\\/eROs4AAAKEen4JhXcPSJgoM1qtXqt2aH+2w2umGefOTo059eKzS4jKRarfaMSMHRb84oOAAAytArOH4+KDj6XYQqODjn2HXXzWaH\\/6PgOJ98LLIb2D9qHzo0U3B4GUG9gmPo5+kui4IDAKAsecExreAYdBGq4GCNOI7fHoXOYxlL3Ru3aNjn6VDTK3vuDDMzj8yOHlNhDQVH3yg4AADK0tuDQ8HR\\/yJUwcEaSaXyndl9\\/OkoWpkr8bDP02EnH4f7QpI8Myg4WCcvOMLwz9Hdlk7BMaHgAADYfgqOTS9C72h6TSznRdkN29Hs+CehO1+Wx30FR+jOk7NxpfJ9xYaWUZQoOAbNGW9RAQAog4JjUDpL7z8aFBysdvx4Jfv2zVnOhBCbL93kr4p9dQgn0mKDy6hJPKLSf74oOAAAymEPjkFRcNBfUq3+g+zwN1GIl9y8dZLPlfeG2dmpgkPLiFFwDJwvCg4AgDIoOAZFwUF\\/tVbrEdnhzzubjVrFkScfg983V1gvqdWeHoZ\\/fu62KDgAAMqi4BgUBQcD5CsVoug3os588crYXsnz2TAxcbDw2DJSFBx9o+AAACiLgmPTi1AFB\\/1UQxy\\/Ji84osgKjt6bZO6uNptfVnhkGSm9gsMcWRsFBwBAWboFx7yCo\\/9F6B2h1ZovMr6MpqSafHMUwkNRZAVHbwXHA2m9eaLouDJaFBx9o+AAACiLgmPTi1CviaWvynTjmuzwWQVHnk7B8VBSrX5T0XFltCg4+qZbcLQUHAAA207BselF6B0eUaGffVdf3cgO77cHR1juvk0mOh2S6ncUHlhGSlJLFBwbo+AAACiLgmPTi1AFB4PF8VuCebOcv00mCuF0Nh7\\/tPCYMlLygiMa8\\/nRJx5RAQAoi01GN70IvSM09ys46Cuu1Z6XHc6EMZ83vYLjTIjjFxceVEZKWku\\/Poz5\\/OiTTsEx0W7fWGRsAQDoQ8Gx6UXoHSHYZJT+0kYjv3l7KIz5vOkWHNHZEMc\\/W3hQGSlpquDoEys4AADKouDY9CJUwcFA1UbjUdnhi8G8We7uRRL92qlTp9Ki48roSNPa04L5sT6dgqNhBQcAwPZTcGx6EargYLDJycuybz8TzJvlzptUougD4diJZtFhZXQoOPpGwQEAUBYFx6YXoQoOBmu3Z7JvPxrMm86bVEKIfi\\/MXn6w6LAyOhQcfaPgAAAoi4Jj04tQBQeDHT5cjyuVnwvmTa\\/gCJ8NlckvLzqsjA4FR98oOAAAyqLg2PQiVMHBZqI0TW8I3bkz7PN1yMn34AhfDGn9RMExZYQoOPqmW3C0WgoOAIDt1i045hUc5xKvvghVcLCppF5\\/dna4L4z53Imizq8\\/G4fa04uOKaMjTWtfF7rnxnLUOU+ioZ+ruyArr4l9ecHhBQBgPQXH+qwtOFotBQeD1ZvNJ2aHvw5jPneyG9f81\\/9ACMm3FB1TRkea1p6aFxydciMoOHrpFhwtBQcAwLZTcKzPSsHRuWHLN5BUcDBQfWbmUHb40zDmc6dXcDwU4vh5RceU0dErOM5G2e+nCo5zUXAAAJTFHhzrs3IBvlJwWMHBYO1Dh\\/I3qfxh6MyfaNX5M17pFRxnQohvyo5x4YFlJKRp\\/Smh92eLguNcegVHS8EBALDdrODY9CLUHhxs6vCJE\\/XscHswd5Z6+Q9ZKkXGlNHRKzjOhHPzQ8ERzhccNhkFANhuy8vL0fTCQv6qSwXHxotQBQebu\\/VkEiXJO3srGMZ5\\/vR+\\/dF\\/zo61osPKaEjrCo4+sYIDAKAs3YJjUcHR\\/yLUHhxcUJwkb1BwnCs43psdJ4uOKaMhrdefHBQcfeeKFRwAACXwiMqmF6EKDi4oTtMbFRznHlH5RJaZgkPKiEjr9a\\/NDqeDgmPDXFFwAACUIC84phQcq3LuAjwfi4+0Wq25QgPMyEvr1VPR+Rv8XXAOD\\/XG7dOT8\\/MHio4poyGt158UOgVHpOBYO08UHAAAZbCCY31WXhPbGYsPBwUHFxCn6atD9\\/GMcZ8\\/+a\\/\\/c6FWO1J0TBkNaZo+MTs8GKzgWD9PFBwAAGVQcKyPgoNLkr8x5DfG+RWxq5LPmS9Um81HFh1URkOapk8ICo5+80TBAQBQhm7BsajgOJeVgqPzt\\/EfUnBwAXGWX+7uwWEFR5Z70nrzCUUHldGQ1utfkx0eCAqO9fNEwQEAUAYFx\\/qsWcHxoTA1NVtogBl5cRq\\/TMFxbs48kFQnnlV4UBkJadopOO4PCo7182RpstV6WaHBBQBgI4+obHoRquDgguI0\\/mFvUTk3Z07Hae1fFx1TRkOa1h+fHe4L5sb6eaLgAAAog4Jj04tQBQcXFKfxixUc53I2Tqs3FR1TRkOapnnBsWoFh4TzBcdLi4wtAAB9KDg2vQhVcHBhcfyTCo5V8yapvCn7fSUqOqzsfWndCo4+6RYczaaCAwBguyk4Nr0I\\/WAICg42l1Sr35EdTofhn7O7IUshit517NixZsFhZQT0Cg4rONbPkW7B8eNFxhYAgD4UHOtzbhO8fCx+W8HBhVQbjUdlhy+Ezjkz9q+LzefNH07Mzh4sOq7sfQqOgXNkaXJqWsEBALDdFBzrs\\/o1sdHtod2eKTjEjLpa+0j27WeC+bPcG4O7qtXq3yk2qIyCXsGx6jWxEs4XHC8uMrYAAPSh4FgfBQeXqF4\\/nH37Z8H86c2bcG92Y\\/uEYoPKKEjTznmg4FibXsEx9WNFxhYAgD4UHOuzuuAIHwjtQwoONlefflj27ad658wuOIeHmc7jOWdDtfqsosPK3pemaV5wPBj82bI6vT04pl5UZGwBAOhDwbE+a1Zw\\/FaYnp4uOMSMuInZ2Suywx8rOFbmTViK4\\/hfZUdvUhlzab1+Iig41mflEZUfLTC0AAD0o+DYmKibfCzePz19WMHBphqHD+\\/PDr+bZal37gz9HB5i8jFYitP05dnXcdGxZW9L6\\/WvjaIof8OQP1tWzZHQLTh+pNDgAgCwUbfgWFRwrMqqguM3reDgQg4eO5a\\/aee3g4Kjc\\/MWRZ0VHD+TfZ0UHVv2trRWe2p2OBP82bJmjuSZbLdfWGRsAQDoQ8GxMasLDis4uJB9V1\\/dyA7vDgqOczdvIYrekx2rBYeWPS5t1J4W\\/NnSd4402u0fKjK2AAD0oeDYmNWPqFjBwYUcv\\/76Sna4NctZBce5fPzA8eOTBYeWPa5Wqz0j+HNlfVYKjhcUGVsAAPpQcGyMgoNLcfLWk0mI458LVnCsvoH70zB7+cGiY8veltRqzwwrq3qGf17ulnQLjunZf1lkbAEA6EPBsT4rb1HpFRxeE8sFZHMoCkn8pmD+9NJ5k8rnQ73+5IJDyx6XVKvfHBQc69MZj+bc3A8UGVsAAPpQcKzPmoLjN9vttoKDTeUFR1qr3BzcyPXSKTjuTyr17yw4tOxxSbX67cG8WJ\\/OeLTm9z23yNgCANCHgmN9FBxcump98qXB2yJWz53TcRzfUGxU2esqtdo\\/DQqOfvNjaWpxUQEIALDdFBzrs6bg+K2g4OAiTHSfp38gmENZovx4NsTx28LRo7WCQ8seFler+atQFRxr0xmP9v7931JkbAEA6EPBsT5R7xh3C46g4ODCpvbt+7bs8KVgDq3MoXwc7piaOjhbbGTZ0+L45qj7yJJ5cT6d8ZjZd+CZhcYWAICNFBxrE0UrBUfnovzDrVZrrtgIMw6mr7jsCdnh7mAOrSQfh8\\/Wpqb+VqGBZY+LfzaK8rK48\\/vpqt9fxzndwmf24MGvLzq6AACso+BYm5UL8O5FefidMDl5WbERZhzMHjp0LDv8dTCHVpKPw4Nprfa0QgPLXveL2e+pq1ZwxMM8J3dJuuMxt2\\/f1xYcWwAA1lNwrE0UxcvR+YvQT4TQXCw4xIyBhYNHjmaHO4M5tJLOTVylXvemiPH2rvz31POP\\/lnBsVJwTC8sPKHo4AIAsI6CY23OFxyxR1S4aAeOHLkiO3wmmEPL3ZvYeCmbR0txnL6m6NiyR504Uc++vb27gkOxsSrd18TOzDyu0PgCALCRgmNtOgVH528cO2PxkdBqzRcbYcbBviNH8pU+n+otxx\\/6eTy8RJ3HvHpZClH0ruKjy57Ufbzvj4I\\/V9anU3BMTE19VYHRBQCgHwXH2qwvOFoHDig4uKCZ48fb2c387ys4ouW1byKK7ggLx5rFR5g9p1a7Kvv2L4I\\/V9anU3BMTk09psDoAgDQj4JjbdYVHPkjKgoOLujw4cP1EEW\\/vXZDxXHM6oKjMxZ3VRqNawoPMHtPpXJt9u3nw1jPh77pFhzt9pcXGF0AAPpRcKxNn4LDHhxcjEoURe9WcGwoOB5KJia+tfDoshfle0zcE8Z6PvRNPh4PNGdmHllgbAEA6EfBsT7nbtDysfiQgoOLlIYo+hUFx4YshTi+JTtWC40ue9GzstwfzIeNcyKEu9qLi1cWGFsAAPrpFByLCo6Niazg4FKkcRz\\/QnZcsg\\/HmuRj8b4s7SKDy54ThTj+wex4Ovhzpd+c+IMDj3iExx8BALabgmNQIis4uBRJUqm9Pig41icfi\\/9bq9WOFhpd9po0xPGrQvfPlWGfg7stZ7PfLd53uPsaXQAAtpOCY2AUHFyKuDrZ\\/NHQ20AwDP\\/83S3Jx+KetNl8UpHBZc\\/Jb97fHsyFfjmb1mrvPHnrrUmB8QUAoB8Fx6B0\\/hb+g2FqarbQADM26q3W9wQFx\\/rkY3E6pOkPFRlb9pzFLB8O5sK6dPZ3OtOYnr25yOACADCATUYHRsHBJalNTn5DdngomEfr51G+0Wi+P0laYHjZW\\/5Olv8XzIU1iaI4G4\\/o\\/vlDh55baHQBAOivt4LjrUHBsS5WcHBp0nrnMYx77MGxNlH395U\\/mT1w4IpCA8xe8vQsDwZ\\/pqydC1E2HlH0xYUrrnhCodEFAKC\\/vOCYUXD0Sa\\/gCAoOLk5zZuaR2eHTkXm0Jr3C50vVyclvLDTA7CUvzHImmAvrk4\\/HX+0\\/dOjLCowtAACDKDgGpXNT9tsKDi7W4sMfvi87fFzBsTbdZflhKY7jVwSPqYyDbAqEd\\/SKLXNhzVyI8rcsfergNddcXmiEAQDob13BMfQLwN2TXsHhERUu0r6rr26EKHpfMJfWpHNT17nRjT6S\\/bP5NPLaM9k3f+BRrX5zIc7nw0cPHDgwWWiIAQDoT8ExMN2Co925WIcLOnHiRBrH8VuCpfmD5tNdlXb7ywsMMXvDU7LcHcyBfnNgKUnT\\/5odK1sfXgAABlJwDErnbx9v7\\/1tJFyUuFb7F8Hmiv2Sj8eDlVrt+wsML7tfkuXHg9clD5oDS5VG41XZMd7yCAMAMJiCY1A8osKlS6rJP8gO9wY3d\\/2SP6byP2ZnZ6dCd58GRk87yweCgmPA+R+W6pOt79768AIAsCkFx6D03qLiERUuQdqaeGx2+FwY+vm7+9Lbk+HzoVL5igJDzO52TZY7g3KjX\\/IxuX9yZuYZWx9eAAA2peAYFAUHWzAxcUX27ad6b0twk7cq596qEVeeX2iM2a3yVTk3BI9oDUo+Jn8xffniNVseYQAANqfg2PRi9IMeUeGSdM+XDwVL9PukV3BE4VeDR1RGUX7u\\/2bwZ8mgZOd+9Mmj1\\/5\\/9u4EXs6rrh\\/wme3ua5KbpEnapmna0gilkGKpFbiWRSoWQQygLBUVEAVxAQQUiAJ\\/BQTEgogKIohgAQGRspQdZBPZLCIIFFkKFKS0ULo3\\/3PuzG1u03lnuzPzzsx9ns\\/n27lN7rznvO+8c3Pf35z3nNstdXyEAQBoTIEjK7U5OIICByvSvBHNL0x2754IxeJLgwJHvffU6iiOr4\\/Pzp7Y9FgyXEqle8X\\/\\/jA472+ReN6n3FCZmvr7AwcPjq3nMAMA0IACR1ZWCxxuUSFdu5XODcViK7dWFOL3\\/X4hvp\\/conKL91R6TMfkuniMnhcfyy0cT4ZDei1fERT26qZ2y9o1s\\/PzD1\\/HMQYAoBkFjqxYRYWqU5eXF+LFybtXRmYcOFBq9v2lycn7x4cfKnDc4j11aE2R46sxe5odS4ZEde6Z9JoqcNTJys+CQuGynccff9Y6jjIAAM0ocGTGCA6S4sTs7Lnx8QfxAuVtYceOqWZP2LJz54nxQv4rChwN31vp8UHNjiVDoRyKxT+Kj9cGxY265\\/vKCI5i8cs79+7dtY7jDABAMwoc2b+UBgWODW9mZnuad+Mjheo58dXJycmmFyhLy\\/tm4sNHg4u9zPdWtfhTfFUw2egoOD7mGwp62ed7Sqlcfs+mvXvnOj\\/MAAA0pcCRFZOMEsLU7Ox9Cmn0Rm3uiOnFxVNaeFqhWCqZaLRBahfDX1w46qhjWzieDLTio8NNRav8z60BzMrPgcrk5PMPtHCLGwAA66DAkRUFjo1ux\\/79U8Vi8fxC9b2xcvE2Njn5Cy09uVz8\\/fjf64MCR90UCsV0XK4OxcqjglEcw2t+ZYTb+2qTaOZ+Xg1oVs71zdu3n9v5gQYAoCUKHFlR4NjgCqWpqXPi42WF6rmwUqgoFotPaeXJpamxn4sPV9eeOwDn80AmHZsP1y6SGT6FUKqcGywN2yQrxZ+v7N1\\/6+M7P9QAALREgSP7l9KgwLFhbdq0Kd0r\\/9ZweOh9NcXia+Jjsdnzx2Zm9sWHS4MCR6OkY3NlaXz87GbHkwE0GXYGc820cI4XbiyNjb397LPPHu\\/4WAMA0BoFjqwocGxklUrl3PhwZbj5xduNhRA+vbB790Kz589sT5OTFj6kwNE0afnMNx04cGCs2TFl0BR\\/Pf7nGnNvNDm\\/47+tY5OTf9rxYQYAoHUKHFlR4NioxsfHT4gPF4VbfjKd3iPfqszPn9ZsG\\/v27RsrFosvUuBonNrF8Q9KY2P3D+biGB7j43vjfz9l7o2Wzu9rZjZv\\/vnODzYAAC1T4MiKAsdGVSwW\\/yRkrwpxXfyG32hlO2OTkw+I59GRo0BkTW66\\/adQeHt8nG3luJK7SszzY25Q4GiadH5\\/Y3x2y0mdHmwAANqwUuDYsu0fggLHEUkXXoV\\/C3MKHBvJ9PTKMrBfyhp2X\\/3z4stDmoGgibldS2kkyNdDQYGjSdLx+X5pbKy1FWrI2\\/6YS4JlkFtI4cZCufyWk848SfEOAKAfagUOIzjq\\/GK6UuAIVnjYMKqreaSJRdMn04fqfTJdK3x8Kmap2eb2P2J\\/JX7\\/u4MLwaapHdePhcXFY5odV3JTCNPT2+PjBaH2HgkDcO4McNI5fd3k\\/OzjDxw4UOrwmAMA0A63qGRFgWOjKVUnFr0+NChG1C7ELwljY7ducbMvDgocTVMsrhzX64vF4uNbPK7k449Ck\\/eI3JR0jC5d2rf3dp0dagAA2qbAkRUFjo2ktqzrRfECu+GFW63AcWXLt1NUKo8JChxNU5vLIR2jz05u3ryzpWNLPxXK5fIZ8fF\\/g3O5lay858uVyoVn\\/8VjLA8LANAvChxZWZ1kVIFjA0jLvr4+tHbhtrLsYyiW0siMpqt+lEqlnwlpYtLqpKV1b3uRlGJ6zx2qHtvii8LevS4KB8uemM8FS8K2mpUCx8TMzDM6O9wAAHREgSMrtQKHSUZH24EDpWKx+Lvxqx+G1j+Zrs4XMbtzc7PNTywsHBsf\\/mt12wocme+3Q7Xjk47TZaXx8Z9tdmzpky1b0gSZr4i5PmvyXblF0nG6em5p6eyOjjkAAJ2xikpWFDg2gvLExF3iw6WhvWH36XuviM\\/+ydBsFMf+\\/ZVQXFl15YY229jIScvGviPs2uW9l7+ZUAzPio\\/XBOdvW+dwoVj4+PGnnLK1o6MOAEBnFDiysnqLigLHqDrjwIHJYrF4fqjePtJugSMtF\\/uE0MptKpNjDwjtjRDZ6EnH6ZpQLD4zPk40O770TDm+Br8THy83cqPt8\\/e6qbm5p8bHYicHHgCADilwZEWBY6Tt2jVZHh9PK3ZcWZvgstXzYuUCplBYuYhJS8qWm7Y1MbE7\\/vcLBZONtpPqrSpjY\\/drenzphbSs6cNivtve+2OjJx2nlYmKv33sXqunAAD0nQJH5i+q6ZfUD4V5k4yOorHJmQPx4YedfDJdKBRX54r43zAz08oQ9IlQDP8UFDjayeqomv+cmJjY08IxpptKpXPif78ZnLNtZuWcvbFQKr0\\/PpooFwCg36qTjCpw1Em1wGEEx6gpTszO3ik+fnbN0qRtnx8rz023nZTGfq6FNgvFSuUR8fHa4GKxvWNcWFlV5eVhaWmmhePM+hVCqZTO6a8budFJVkZv3DA2PfHE0MLtawAAdJkRHJlR4BhB09PTp8SHL4TuFBrSNl4W9u0ba9bu7OzsSSGN+FDg6OQY\\/ygUiwf3Wjq214qhXP7p+HhxcJ62ndoy0DeGQvjO4nG7TunkBQAAYJ0UODKjwDFaCvHi7cz4+O+heyuapG18K+bHWmi\\/UqxUXhAfr68NY8\\/7\\/B6SpNuBSul4XRWKxWcHw\\/57Jd2K98cxlxYKRednB6mNeLlucn722fvT6kkAAPSfAkdmagUOc3CMgEKoTN0+Pn46dHdOgdVt\\/WYrnZiYnUi3xvygesFu6H8Hx\\/qqmD+PWQiG\\/3dLOo5HxbwyuIVqXVkpDBUK3916\\/LE\\/0e6LAABAlyhwZMYIjlFRqZwW\\/\\/vpQqFwfZeXu6wVOAr\\/3FI\\/ZmaW4n8\\/VVgZwaHA0W5qr93VMeeZ\\/LdrTo15W8w1teOrwNF5biyXy+\\/etW+ffzMAAPJiktHsX1ZjPjQ3p8AxxEqhUrljfPx46N1qEOl989UQxk9qqT\\/lcroN4LouF1o2UtJxuy7mdTEnhzRvBJ1It1DcOeaTwUop3Tovr1rcuvVR4eBB5yQAQF4UOBr+wvqhoMAxtMrVCRPTUpc9PLfTSIzCjaFY\\/IPQwm0T04uLt4kP3wguKNeb9Jp+uXR4FRu3rLRqebkcz9cnxa++X5sY85DVUtadG4vl8ifPvPfdd7T9egAA0D0KHFkpGMExvCZKlcqvxMcvx3S8FGxrWbkwTNv\\/TMy2pj1Lkw8Wi\\/8UfGq+rlTnO6hN8losPj1MTu5qeuxZHdF0fswPV5dJVuBYd1bex1MLc09t9wUBAKDLFDiyUjCCYziNFSvjj4qPl\\/fxNpDUzjUhlO\\/ZSgdLY2P3iw83uE1l\\/SkcLhS9P5TLZ8XHpkv2bkDplontMWmU0SVBca3bScfyh0cff\\/StW35FAADoDQWOrNQKHNXlExkCC7sXFlY+zQ\\/he6ufTof+XeDcENt+bksdnZzcGf\\/72eAis2vHP77W6efXpSuvwfj4icEtK6vSz69Hxnwi5moTifYk10\\/Nz77sjAMHJlt\\/WQAA6AkFjqy4RWWYjKeL2mLxVaG6ykYeF3Cpzc+GiYljW+husTK+Msrkqpz6OqqpFppC+Fw8F34vvhZ7wsYsdBTDZDg6VAsbqUi7ep4513pwzhWKxf+93Z1O39fqiwMAQA8pcGT\\/4hrzYbeoDLiD8WJuYuInQ3qtQuj2MrDtni\\/XhlD6tdDCRfX+u91tPn7XZ4KLzi6mcGNagrdYHc0RX4vwuVAq\\/WrYWKOw0lLEvx7z+fheWC32KW70JivHdWxq6mVhYxbSAAAGjwJHVgoKHINuYWGhWCz+bvzq2yH\\/i7jVW2LeHjPXSveL5fIzQvV95+Kzy1lzK0YqdPx7TJoA8vSYUXs\\/pwvrzTF3iklLEH8qrMwHk\\/v7YSMkTXT7nc3H7jyrhdcJAIB+UODISrXAMTs7u3ldB5heKEwsLOwOhcLrwuGLudzPmdpF9ffK1RElTY1NT58S0iogA9L\\/UU2an6P22vwopMlIQ\\/jNmJNipkJaWaSqEAb\\/U\\/jV\\/qVJQ6dj9sc8LVRHL6V9U9ToX9Jxvm5mdvYlB88\\/aGJbAIBBocCRFQWOgbRr12QolX4xVD+pzvOWlFuk2pfC9fHrl8SMt7A3lWKplL43PWdg9mNEc+OaUR1pTopvxnwk5q9i0vm0vzZaq9jsRctJOp\\/S5Kn3jTkvVPv+nZjrgttQ8jmfioUvH3\\/aKVZOAQAYJAoc2b\\/AhupFhALHYCiF6enbhGrx4IpQu6CLF615nyf1zpvvxtyxlZ2anJu7YyiEb1rdor+vUaGWcDiXxXw05qUxvxKTbjs4OWZLqN5ylFbISKM9ejnKI227EqqjM9K8ISfEnB2qy7v+a8xXw8377JzJ6fyJuWF6dvZ5+\\/fvr2S8lgAA5EGBo+EvsanAMWr37A+f+fnFUCz+dvzqCzHXF4vFQb6wW5noMj6+IBy+\\/SHbjh1TxerqL4O8T6OVQhptc9N7fOX1WlNgij8HVybnvDzmGzFpIth0W8urY\\/40hJXz8KEhlO8ZH1PBLS35uzkshZn4OBGqBYpSRsq1v0+3xqQCxo6YtPrGXUN1FEna9p\\/H\\/EvMf8T8b8wPQnUekRsKNx+Fkv9x3Li5Ib5nv7T3dgvKnm0AACAASURBVLezcgoAwKBR4MhMdZJRBY787No1WR4fv3v86sIwRBMn1i5CPx+vd49pZTcnN206I1Qvpgd+3zZI6o2SWJt0S9EPQ3Vy24tj\\/jvmEzEfDNVz9YJQLVKkvKn2mEZgvC3mPTEfqz0nPTfNwZKKKdc2aTPvYyKh+t4uhMI1s4vzT47\\/dg76nC0AABuPAkdWqnNwzFlFJRdjY2P7Qij+Tfzy++HwSiNDcaFXK3CkgsyTQ2u3NBSKlUr65N5cHIOXxsWO6pK0Nxzx5zdkfH3k92T93dCc6xswNxaLhYtOOuWk4wIAAINHgSP7F9mYjyhw9NG+fWOhXE6jGZ4XVkZADPUFf+p3uqXm6FZ2vTI1dbv48NVBmjRVRG6W9N78weJRWx65vLycbjcCAGDQrBQ4tihw1Ik5OPpnLF7g3z4Uiy+LX\\/9fOPzp+DBf7K\\/sw9jY2M+1dAT27RsrlsvPCjetijFwk6eKbORU38\\/j42\\/+iwsuaGWFJAAA8qDAcWRuurC0ikqvTUzsKVaKvxG\\/ekfMpeHIIfuDt0JKO+fRjbXbnF67MjKlBZt27twVqsvfxucVDylyiAxGaiOrLtt2zDFpQlgAAAZVrcCRVnFQ4FhJcfXr9AvtR2dnZ7es6wCzVlpJYksol+8SisU\\/iV9fFG45ueIAnAPduiiqLRlbDmmi1JYmJCxWKr8TH65zq4rIwOTG+F6+Znrz4p8uLy+nlXIAABhUtTk4VpepzPsXyQHIzUZwpNUOFDjWa8eOqdrcGn8aqqNivhdz\\/cqKBCO87OWapUjT6hmLrRyqrVu3bosPH0jFkdrzRSS\\/rPx8KlfKH7\\/rbz7UaD4AgEGnwNHwF9uPBiM42lUMW7bMhvHxvaFU+pn4\\/88IofDO+PidsDFXiUj7eXk8Fj\\/b6gGcmJ9Ow+C\\/uYGOkcigJr0Hr5jevPDQAADA4FPgyEpxZZnYsH1maV0HePgV6uRm4jlUCPPHLIZy+W6hWHxK\\/KN3x1xaKBQO1bKRChr1kvb9HWFpaabFY14K5eJzwuE5SfLuv8hGTHrvXTs5N\\/e8g+ef39I8OgAA5GzNHBwupG6WlYvyD4VtM1tDi\\/MnjKjStm3bpsP09LaJiYnj4v\\/fIeaBMb8b82chTaIZwgdDdVnXK8KRE4U6r1YKPPEEuip+\\/QehOg9JU0u7d28vlEpvjs+9wXwcIv1Nofaza3xq4oJ9d7jD9gAAwHBQ4MhMOh6f3HLMMfunjj56x+Tk5p1h06ZdYXIyZedKpqZ23JQwdVR8rGZ6enst20JImdkaZmqJ167x8XDCakIta79emf8jZrZBjtzGytdbq+3GpH5M3dS3HSv9DmFXCJNHT0wsHBsm5veMj8\\/tHZ+dPakyOXl6CGM\\/H0qlh4di8fHx+54e8+KYN4fq6h7\\/G\\/P9EAo3pALQ2jk0jNLIzppRLN+IOTG0aG7z3I+H6kgYIzlE+psbC8XiJcecetKZAQCA4VG7ReUfgwuoW\\/yCG9Kn7oXC\\/8THz4XqCIUvxVxcy5dr\\/\\/\\/FWv6nli\\/Uvndt\\/ruN1Hve55qk3nNX+\\/PFWj+\\/VOtz6vtXakkFi6\\/GfC2EQrr4Tku1XhGqow2uC7ccidEoeb9eg550jK6P+euYqdCaSrFcflp8vMYxFulb0oir6zdt3\\/q45eXlcgAAYHgocDT5Rffw7QHtXOyPSvI+\\/iOWlXPphzH3DS2a3blzc6FUSCNojOIQ6U\\/SbWGf3rRz564AAMBwWSlwLG17dXDxJB0k3X6Rdx+GIWnJ1+rSrytFjveFXbsmQ4vm5uZOjw\\/fDt6jIj1Kuo2suHor2dd37d19l7Cx514CABhOqcCxSYFDpC+pXUBdFcLKajPjoRX791eKExOPCCvzn3ifivQihcLKylnXTM5O\\/\\/7KylAAAAwfBQ6R\\/qZW5Lg6lMt3D20oVUp\\/G25+25SIdCG199R15bGx1526fOpCAABgOLlFRaTvuTENhw+hcEFYWGj5YmpuaemEUCh8oraqSt77IDISKRaL1ZWgSqV\\/O+7k444NAAAMLwUOkf6nUCilx6tDsfik+DgWWjS9devdQnXlGxPBinQnN4RC+OqmHVvbGlEFAMAAUuAQyS3pPfetMDFxVmjV8nJ5fHryt+NXV7lVRaTz1CZITu+h7y8sbT73wIEDpQAAwHBT4BDJNel2k\\/eHycmjQ4v2n3POVHly8rlhZbJS71uRDpPeOz+YmJt6+q4zWl\\/VCACAAWaSUZH8UhuFkYocLwpt3Koyu3Pn5kKp9MZQnXQ09\\/0QGbKsvO\\/GJiZe+pDHPW46AAAwGhQ4RHJPeu9dFkqlh8XHYmjRntve6sRCufzvxWLxkNtVRFrOyooppXL5jccff3zLI6cAABgCChwi+adWoPhaCGO3CW0Ym5h4UHy4rpBGcoSb5hUQkTpZHTFVKpfev3zOOVsCAACjRYFDJP\\/ULrxS3hAzG1q1e\\/fE5MLC78WvLjOKQ6RhVoobhXLpIws7d942AAAweqoFju0KHCI5Zs2KDtfGvCBs2dJykSO+h0tj4+PPil9ercghUjfV4kax+Mmd+044NQAAMJoUOEQGKul9+KOY3whtOPXUUxdK4+PnxS+vCd7LIkcmFTc+vfWYY86MXxcCAACjSYFDZJCSJgwtpvfixaFc\\/qnQxsXYrX78xzeXKpVXheooEO9nkcMjNz6zdceOVNwAAGCUKXCIDFxW5+P4fExbqzyc+sv3WSiNjb2qkC7qLCErGzs3FovFVNz4xGlnnnlSAABg9ClwiAxk0vvx+pi3xuwObdh0\\/PFHlyqVV8Yvrw7e17Jxc32hVPrQ5u3b7xAAANgYFDhEBjarIzlevWnTprnQhjPvfe\\/ZUqXykrC6hGyhYAlZGekUi8WVx9pEu9cVSoV3nXDaaXsCAAAbR63A8ZqgwCEyiEnvyzQS4x9nZma2hjYcc8wxi2Pj48+OX\\/4gXfQpcMiop1bcuHpsYuzvd524a2cAAGBjqRY4thnBITKwKdyY5tQoFoupWDEe2nDgwIGx8tjYU+OX3425IZiXQ0YstdFJq6OdLi+NV\\/7yVnf98c0BAICNR4FDZOCzevH2fzE\\/Hdq0b9++sYmFhYfGL7+aLgSLxaL3uoxMagW7dE5\\/Z3x6+vH7lpdnAgAAG1OtwOEWFZHBTXXC0ULhLRPz88eFzpQWjlq6c6lceleojeQYgP0SWW9Win+lcvl9m3fuPCsV8wIAABuXSUZFBjO1eTPS+\\/KqUCy+ut05OOo5+eSTjyoWi6mg+aM1w\\/pz31eRdrM630Z5bOwtu0+91e4AAABGcIgMZmoXcFcWK+U\\/CwsLC6FL9u7dOzc+Pf178ctvhMO3v+S+vyItJp2vN8T3x7cm5mefdOL+\\/VsCAAAkKwWOLQocIoOSNEdGbZ6My8sTY8\\/cctJJs6HLDh48WJyfn79bKBQ+Xwjh+loxJfd9F2mQG0N1VFO6xerrizt2PDD9+xUAAGCVERwiA5XVC7hvTc7NPWbbKadMh94pbDnqqP2FUunt8etrg58BMthZmYumVCi8d3Hr4plh\\/\\/5KAACAtWpzcChwiOSYNUtdXl8oFi6aXJi97\\/LBg+XQB1uOPfao4tjYM+OXXyuE6rwflpKVQUg6D9NoppWiX6HwrfL42LN2HH\\/80QEAAOqpFTjODwocIrlldULRUrn83hPuePuT458VQv+ktkrzmzefFS8i\\/ytUR5H4eSC556aJcAvhK7PbNv9c\\/LoUAAAgy80LHOlTW5\\/civQrhcOTfP6gVKm8cmnPnhNCfgrz27YdVyqVXhS\\/\\/r8QCgodkkvWrPDz3fi+ePGm7dv3xX+r+ln0AwBgGClwiOSWldUgYr5Znhh74j0eco9ezrfRsvPPP780Mz9\\/v\\/jlRaHaPyutSL+yeq5dn0YTzWya\\/4Xl97ynL7dqAQAwAlKBY2Fp+2uDAodIP1Odb6NQePvs4kBOmFhc2rXrhPTpefz6qqDAIb3PTaM2xqYmnrHtpGOPi19bJQUAgNYpcIj0L6tD7+PjFcVK6SXHnnzyUWGAnXLKKdOV8fFHFkL4ZMw1q3OFhAE4ljISWZ3UNo0UuqJQLv3r5h077tavCXYBABgxtQLH64ICh0ivs\\/oJ9acn5+fv3+MlYLupOL91656xiYk\\/iV9fEtyyIt3L6u0on5hbXHzQMbe5zWLo7wS7AACMEgUOkd5mzaiHNGrjHxaWlk4NQ+jA+eeXpufn714old4Q\\/\\/f\\/Coc\\/fVfskBZTWPt+uC4UCl8qT4w9c2nPrjS5rsIGAADrs1Lg2Lz99UGBQ6QXWR3t8KWJhdlfDtVlLof1Qq7a7wMHSpuWlu4Zv\\/pASPOIBAUOaTmr74crKpPjz7\\/DPe58dKga1vcEAACDpFbgMIJDpEspFGqfUlcv5C4tVSp\\/Pb2wcOqBAwdScWNUFLZt27Z1Ynri3LivqdCxMhFpbd9XEgbgtZD83wth5byo3YoSwtcq4+MvWdy6eOYZZ5wxGQAAoJvOP3R+aWFpqxEcIt3J6vD7a2O+NDkz84B0a0cYYfvOOGPT5Nz0Y0MhfCbu+9VpwsjVyVRD\\/q+H5PQ+CCvvheJqYeOS0ljl7446ac9pB84fqUIfAACDZKXAsVmBQ6Tz3PSeSRdzaTWI7xZLpfPmdi3tDRtlmctDobC0e\\/f26bm5BxcKhffHP7kyrJmM1IiOjZKbClvpfZAmD\\/3c2MzUH2\\/avv3H9u7dOx4AAKCXzj90qLSween11V9MFThE2k1ttEK6oLs8fv220tTU2bt3L0+EDWrnrW61eWxm5gGlcumC+L+XxmNy3eGJJVd\\/zuT\\/uklXszJao7bc65WhUPjM2MTEwS17dp548ODBjVHkAwAgf9U5OJb+WYFDpO2sflp9XcxnS1MTv7pnz575YMLEJB2DqcVjdvxkZWLspfHrbxUOHy+3roxWVl\\/TH4VC4QNTm+YfvuXoo3fE\\/y8HAADopzSCY37TSoHjBgUOkZZyeJnLEL5cHBv744mt83vCwQ1yO0qb9h04MDa\\/ZcvtyxMTTyyUS2lC0stCdcTLjebqGL6sec1Srk5LvZYqlb8bn5299759+zYFBT4AAPKSChyzi1veEFYuOBQ4RBpk9aIuTZr4nWKp+Bfbjj32uOCCrmX3eNxDpheOOurOlfHx58cL5S+F6mSsNwajOwY9N59bI4QrCqXS+6cW5x+1Z\\/\\/+Y+q81AAA0H+pwDG3uOVNofqL6yEFDpFbZs2n1l8rVSrnTc7NnR527bLMZYf2P+IRlfmtW\\/eMTUw8KB7P18Q\\/+kLMtek2lmIoHiqEtPpG8VA1+b\\/+GyWF9JgmhC0U02N12d\\/qvwkrk+cWSqX3xdfsyXObNt1x+\\/btS0FxDwCAQaLAIVI3a0cUpFtRLol52dzmzXc4dOiQi7ouOnjoYHHbScceV5ya+vV4Uf3GeMl8caiuwpJGChw5usMoj96e6yujNAqFQjr2V8d8M+aDxXL56Qvbtyyfc845U01eTgAAyE8qcEwvbv6XoMAhsprVC71r44XeRfHi7vmTm2bPMGKjD5aWZpZ27dpbmpj4pWKp9DelUundoVi8OFQvthU6upI0KmbldsQbCzefByUVNS4vFAufKBaL\\/1gZH3\\/U\\/FFbTpubm9sUlk0YCgDAEFgpcMwpcMiGzsoF3uGlTMOlpXL5LROz0+ceddxxx1rmMieHDhXu8ZCHTO85+eQTpjfP321iaurJpUrl1YVi8RPxby8phMJVwQiPls\\/vcNN5XqyO0gjhh\\/F8\\/99SpfzeyuTkC2Y3bXrYpp3b7njr00\\/fdvDQIec8AADDZ6XAsbD5zUGBQzZkbrYixHeLpdKrNx+786y9e\\/eOB\\/MLDJr0epRPOvPM2eNPOfnWM5sXH12qlF4e\\/+y\\/Yq4ItZVZ6mQAzrO+Jqvok261uiwexU+UKpW\\/XlhaOnffmWces3t5eSL+uYIGAADD7+B73lOeXlhcU+AQGcWsLdwVVj7FLlSLG2k1iH8rj409fW7btjsu\\/\\/Ivp4s9hsTy8nJ5aWlp+\\/yWLadNzE79arFcflqxUnpZoVD4YCgULg5r5vI4fCtGGsFQGNZCyC36fMRtJiu3VsV8L\\/7Zf8dz+z2lSunFxbHyE2e2LD5wcevWU7bv3bt04MCBUrdeAwAAGBi1Ase\\/BgUOGencdFG7uszl5fEC+MMTs7MPu8297rUYGCm\\/fPDgxOYTT7zV2PzM\\/cbHJx9TmZp4cbzYvzC+5p+Nf\\/2tmB+FaiEgjWpI58MNa9Ko+JE1OqJbadTG2j6mfl8T84OYr8f9uqhUKl1QmZx8bmVi4lfnt269+97TT9\\/1iI+\\/pNLVAwsAAIOsWuDYpMAhI5nD82oU0vn9\\/Xgh+MHyxMQzJjfPnb6we\\/dCMDR\\/Q0gjPbadsm16btfcpon5+ePmt8yfNjM\\/c9bk\\/PwvTM7OPr40Pn5esVI5P5RKF4Ri8ePxPPlyfNq3QyqEVSc4XS2EHJ7Lov4okPVktfiWCi+pcPGd2I+vhDTnSKn0tkK5\\/PrYz78dm519Uur3xMLMnacXFm47sbh4zNyuXZt27N8\\/ZWQGAAAb2kqBY37xrUGBQ0YjR845kIoan4oXiX89PjV19uytbrU5QIaDBw+W997udktLu3adkIoH5cnZM6c2L\\/zczOL8Iyfm5v5wbHz8OaVK6W+LldKrQ7n0unhu\\/UuhVLggjQ6JeW+hXPpAzIdK5dJHYj5WTfmj6f\\/j338g5n0x7ywU0nMKb4zf+9rSWOkVlfHKeVMzU380s3nzb80tLj5wYnb2TpXp6VNTP44\\/5ZStj3jEI4zEAACAZt6TChxzi28LChwypCkUiocKK0teVpe9DNVP3L9SrFT+Znxh4d6bdu7cFf\\/fpKF07lA8d9LoiOXlctgfKmFvPJ92hzRfy+S2bduml5aWZjZt2jS3uLg4v7B7YWH+mGMWj8zinsX59D1btmyZDfE5YVeYXNnOvn1jabsroy8OHTryHHXOAgBAq1KBY2p+8e1heCbZkw2dNFlo4cbDCTcUCitzEXy7UCh8slKp\\/OXY9OQvzu1aOmHv2WenogYAAAAbQbXAMa\\/AIQOZQqGwklBdKSKN1DhUWxEljThKkyu+bXxx7tFLu3efmm63CocVgk+\\/AQAANg4jOGTAUm\\/yxTTx4hWhUPivUrn82vLE2NMnZ2fvOz47e1Ia8n\\/olsP6AQAA2Ghqk4ymAkfW8oiyoXPTrSBdz00rnBRutv10HqZVJK4MaRWLQuHC4tjYM6eX5u65Y9++Yw4dOmTVEwAAAG5pZZLR+fl3BgUOqZvuFjgOL9saVicETeddWorzfwql0tvL4+PPqoyPP2piYeanJiYmjksjNIKlXAEAAGgmDe+fnFt8dPzyvJgXivQo6fz6i5g\\/j3lOzMGYx8Q8uDwz81MT27Ydt2nv3rlw8KBiBgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADDbF\\/Mz8c8Keb5Ma+MuSDmjTGviDkv5mDMQ2N25NNFGjgz5nExz4t5ecy\\/xLwh5sUxT415eMzZMZty6t+omoo5LeYhoXqcXxjzmpi3xry69v\\/pzx8csz9mMp9uAgDAcPqtmEPrzOUxX4j5t5g3xbw05hmh+kv89v7tys28PKx\\/v1rNF\\/qzS7n6iZgnx7wjdH6M0nnxgJjpPvZ7uUGfbtXHftTzR6F+v77co\\/bShfWbMtpslHTx\\/eB1tPuADtrsZ356HfvWinvFPCfmIx3270Mxz+pDP1t1asju66dz7Nd6PCFk79Pv5tgvAADa1I0CR7N8MlQ\\/zd\\/bn11a8fIu9r9ZRrXAcVLMM2P+J3T\\/mL0+5kF92IflBn3YKAWOtJ+vzmirnXwx5pEdtL8RCxxnhWpB77Iu9\\/XSmL8K1RE4eWlU4Ei5W35d60g55ushe38UOAAAhkg\\/Chxr895QvbWh117ex30atQLHT8a8LuaG0Ptj99WYx4beDcVfbtD2Rihw\\/E5GG+vJxaG94tRGKXCUYh4YOh+p0W7eG3PvmEKX+t+qZgWON\\/a5P+v1S6Hx\\/ihwAAAMkX4XOFbznzH36+F+vbyP+zIqBY49oXpxksf58O2YR\\/dgn5YbtDnKBY4018O\\/Zmy\\/W0nzrsy00JeNUOC4S8xFOfX\\/Y6E6X0e\\/NCtwpMLonj72Z73S8Wu0PwocAABDJK8Cx2reHLO7B\\/v18j7uwygUOA6GfM+D1bw7dPfiaLlBW6Na4EhD7judK6XdfDBmrkl\\/RrnAsSVUCz1570NKmiC2lYLTejUrcKSc14d+dMOdQvN9UeAAABgieRc4Uq6I+cUu79fL+9j\\/YS5wHBPz\\/tDZfn825lWhuurDU2r5s5iXhepIkE92uN10Pvxal\\/ZvuUE7o1rgeHnGdusd50+F6mt1Xq0\\/LwrVVT3aOSfSJJizDfozqgWO5dB47oZGSbex\\/EU4\\/L5Zm\\/TnH+1wu+ln0e063J9WtVLgSBNPD8MKPOeH5vuiwAEAMESyChwXh+ov8O0kLSv5h6F6wfStjO02ygu7uF8nd9D\\/ZnlFRr+HtcBxl5jvhNZfn6+F6kVwmkSw2af2q9JFzs+G6ioSX2yjrZRnrXP\\/kuUG2x\\/FAsfPZGxzbS6ofV8zR4Xqz4ePt7jNLFvD+t97H85o98IubLuTC\\/HHZvQnK\\/8RqvOhnNFmO2fWnvepNtt7YAf71KpWChwpT+hhH7ohjRS7LihwAACMlKwCx391Ydsnxjwm5j0ZbdTLW0LvJpxcr7SiyKgUOO4TWn9N0nwpD+1Su3eIeW4bbb9kne0tN9j2KBY4PpuxzZRLQvV178RTGmw39fe0dfS5FW\\/NaPvVPW63nj\\/J6Eu9pMl6z+pSu6mw+OY22n5Ul9o9UqsFjjS6pdyjPnTD80Jr+6HAAQAwRHpZ4FgrXUz+fUZbRyYVRPpxL3m7RqXA0eotA6mwcU6P+rAjVEfstNKP9VzELjfY7qgVOH4lY3spXwnVguN6\\/Hi45cisd8YsrXO7rRiUAseLM\\/pxZP455jY96kO6BeUtLfbjMT1ov9UCR0q3bz3slnRLVbqNRoEDAGDE9KvAsSr90t\\/K\\/eXpF\\/hSj\\/rQqVEocKRPk1v5pb5fw8tvHZqvYpDy3A63v9xgm6NW4LgwY3tpGP5t19vZmrSd79W2+\\/zQv0\\/oB6HA8aSMPhz52v1cn\\/qTljdtZQ6Qbi\\/L3U6B42NdbrtbUtGi1X1Q4AAAGCL9LnCselxGu2vzVz3uQ7uGvcDxYzGXhcbH\\/F0xe3Po2x826VfKr3ew3eUG2xulAseWjG2lPLsbnV0jzQtxbpe32UzeBY4HZbR\\/5M+rRpOt9kKaPyRrbqC1uWMX22ynwJFyZhfb7oZizJeCAgcAwEjKq8CRpNEcjeYMSHlkH\\/rRqmEucMyH6mva6Fg\\/L7feVaVJaq8Ijft4jza3udxgW6NU4HhoxrZSju9GZ3OWZ4Hj9jFXZrSf8qOY+\\/ahH42kn5ONJsxMIz22dqmtdgscecyT0siB0F7\\/FTgAAIZIngWOJN2\\/3+iWlatC94bXr9cwFzjeEBr\\/Ev\\/Y\\/Lp2M+m1Tqu1ZPUz\\/d3mNra33GBbo1TgyLp9ol\\/v417Lq8CxGPM\\/GW2npHkc7tTjPrTq3qHxe\\/zCLrXTqMDx3Yw\\/P7pLbXdDu8tiK3AAAAyRvAscSVpy9JMZ\\/Riki7RhLXDcLzT+Bf6P8utaXWkSxUafmL+2jW0tN9jOKBU4np+xrfd1paf5y6vA8ecZ7aZcG\\/PTPW6\\/Xc1upXlYF9q4bYPtPyfjz7t9m1Sn0q069fqX5grJGk34O7n0FACAjgxCgSNJn\\/A1+uT+D\\/rcn3qGtcDR6BPof8yxX43cPzS+UDu7xe0sN9jGKBU4Xpmxrbd0paf5y6PAcauMNlfTq2VY1yvr51TKxTHT69x+owLH6aH+z\\/E0Me3UOtvthn8I9fudCkNZt\\/AZwQEAMEQGpcCR3DmjLyk\\/iDkmhz6tNYwFjnTrSdYxTRfSC\\/l1ral6nwZ\\/LrQ338FynW1spALHJ7vS0\\/zlUeB4fUabKW\\/qYbvd0GhlovUWixsVOPbHPDnj73qxZG07doX685Sk+UnSakAKHAAAI2CQChxJo6UY\\/zanPq0atgJH+qT2myH7eLY7YWce\\/iNU+3pJzCM6eP5y2BgFjmdnbOuKrvQ0f\\/0ucPxERnsp34\\/Z1qN2uyVN4JzV\\/zSaYnEd2240B8dpobqyS71bzNLKJcV1tLteWe+RJ9X+XoEDAGAEDFqBoxKy74VOn77lsYTpqmErcDRaevWVOfarHSfHPDV0Pqx+OWyMAsfvZGwr5axudDZn\\/S5wvCujvZROlivOw5+F7H14+jq226zAkbwk4+\\/vs4521yPdHvO9Ov1JhZhNte9R4AAAGAGDVuBI7pXRp5QX5tivYStwNBq9cVSO\\/eqn5bAxChz3zNhWypu70dmc9bPA0egWjI\\/1oL1emY35Vqi\\/H99ex3ZbKXCcnPH371xHu+uR9e\\/c2n9PFDgAAEbAIBY4kg+H+v26LFRHeeRhmAocaRLOrIuQ5+TYr35bDhujwDEWqkuWZu3r\\/bvQ3zz1s8DxJxltpZzTg\\/Z66fdD9r7cs8NttlLgSN6e8T39XvY73RbzpTr9uCHc\\/GeAAgcAwAgY1ALHz4fsX6J\\/Iac+DVOB42Uh+\\/gN+vwB3bQcNkaBI\\/mnjO2t5vR19jdP\\/Sxw1LsYThnGCVtnQvb50OmcRq0WOM7J+J6\\/67DdTt03ox9HThSrwAEAMAIGtcCRRmnUu2c6j1+Ql8ahIgAAGoxJREFUVw1LgaMQqhMh1uvrG3PsVx6Ww8YpcNw9Y3tr84vr63Ju+lXg2J\\/RTsrvdbmtfnl5qL8\\/l4bqz4p2tVrgSNv+XJ3vuSZmawftdiprPpW7HvF9ChwAACNgUAscyV+F+n37Yk79GZYCR6MVIH4px37lYTlsnAJHkrVc7NqkCSD7eYHZDf0qcDwxo52UYZ235mdCawWJVrVa4Egek\\/F9f9xBu53Imk\\/l03W+V4EDAGAEDHKB40DI\\/kV6dw79GZYCx1NC9nHbnmO\\/8rAcNlaBIxUuLsnY7tqk+TrS8pgz62irn\\/pV4Lgwo53PdLmdfmp0m8rvd7C9dgocWauXpMlPxztou12vyOjnw+p8rwIHAMAIGOQCR1q+L+sX6Z\\/PoT\\/DUuA4P9Tv50V5diony2FjFTiS0zK2Wy+pGJIu4Dpdhrdf+lXguCyjnb\\/scjv99pFQf79e0cG22ilwJM\\/N+N5f66DtduwK1dthWi2uKHAAAIyAQS5wJBeH7n3yuF7DUuD4RKjfz1fm2amcLIeNV+BIfilj21lJF31PjdnchbZ7oR8Fji0ZbaQ8oovt5CHdllRvvz7YwbbaLXDsCdUVS4783nq3iXTT\\/8vo4x9mfL8CBwDACBj0Asc7Q\\/3+dboCwHoMS4HjylC\\/n0\\/Ls1M5WQ4bs8CRnBWqE0m2U+i4IlQLYWkJ0WKX+tEN\\/ShwnJHRRspZXWwnD08I9ffr2x1sq90CR\\/LajO\\/\\/6Q7ab0XWrTHpZ+OmjOcocAAAjIBBL3D8Tajfv7fn0JdhKHDMhuyLj4fm2K+8LIeNW+BIjo15c0Y7zZL68dhQvVjMWz8KHD+b0UbKsV1sJw9pae2sfWv39e2kwPFTGd\\/\\/5jbbbtWjMtp7SYPnKHAAAIyAQS9w\\/Emo379eD2+uZxgKHI3mLTmQY7\\/yshw2doFj1U+G7Ak0m+Xbtb5u6UG\\/WtWPAsd9M9pIGbZVZ45055C9bye0ua1OChzJpzKe0+33YdbytM3aUuAAABgBg17g+L1Qv3+X5tCXYShwpAuxrIuP++bYr7wsBwWOtdI58N8Z7TbLD2KeHfIZ0dGPAkejVZuybmsYFvtC9r7dpc1tdVrg+OWM53R7AtdzMtp5S5PnKXAAAIyAQS9wPDrU79\\/lOfRlGAociyH74sMIDgWOVefGvCOj\\/Wb5bMz+PvRxrX4UOO6T0UbKsI\\/gSBN9Zu3b3drcVqcFjrRyybfqPKfRvBidyDqv79nkeQocAAAjYNALHE8K9fv3tRz6MgwFjjQxZNbFx6\\/k2K+8LAcFjkaODtXzut6EjM3y233sZz8KHHfLaCPl+C62k4fbhux9O73NbXVa4EielvG8J7XZhyxZ+5luaSw0ea4CBwDACBj0AkfWHBwX5dCXYShwJINwQTooloMCRytmQnWlja9n9Ckrr+hT\\/\\/JeReX2XWwnD43m4Di5zW2tp8CxLeaaOs9L5125zX7U87KMfv1aC89V4AAAGAGDXuBIFzD1+ndhDn0ZlgJHukCu18\\/n59mpnCwHBY52pYvBz4fWixzpvTjR4z71o8CxN6ONlJ\\/vYjt5ODdk71u7k8eup8CR\\/F3Gcx\\/cZj+OlG4jqlc8SbfFjLfwfAUOAIARMOgFjn8P9fv3whz6MiwFjqx70P81z07lZDkocHQifZqebmlqtdDxzzGlHvanHwWO1P9rM9r5\\/S62k4esn12XdbCt9RY4sp7\\/sQ76slbW++mPWny+AgcAwAgY5AJH+tSt3idyKb+VQ3+GpcDxolC\\/n9\\/Ks1M5WQ4KHOtRCdVbm74Tmhc5Ht3DfvSjwJH8Z0Y7r+lyO\\/329lB\\/v97bwbbWW+BI3pXx\\/Lt00J8kawLT9O9HqxPEKnAAAIyAQS5w3D1k\\/yL9kzn0Z1gKHI8K2cft1Bz7lYfloMDRDek2hjQCqFGBI03826tbVfpV4PjHjHbyWJa6W9Kyvlmv2Qs62F43Chz3y3j++R30J3l4xvZe2sY2FDgAAEbAIBc4nh3q9+2KnPozLAWOW4fsC5An5tivPCwHBY5uynpPruYJPWq3XwWO38hoJ+UnutxWv5wTsvfpfh1srxsFjrTa05fqPP+GUF3Sth1pdZTPZfTntm1sR4EDAGAEDGqBI\\/3SmrWiw1tz6tOwFDiSesO1Uz6XZ6dysBwUOLrtDSH7mH6qR232q8DRqDh4Xpfb6pd0e03WPi10sL1uFDiS383YxvPa7M\\/ZGdt5R5vbUeAAABgBg1rguEfI\\/iX6N3Lq0zAVOP4uZB+\\/H8+xX\\/22HLKPw23y69aKrCWQB73AsTk0Xk72+B602a8CR\\/LFjLa+3YO2ei3dWpT1On2gw212q8AxG3N5nW1cXvu7Vl2Q0Zdz2thGosABADACBrXA8b5Qv19Xhc4+deyGYSpw3DVkX4S8Msd+9duZIfs43DXHfiVZRajP59mpFj02ZB\\/Xx\\/agvX4WOLJG1qQ8vAft9dJTQ\\/a+PKrDbXarwJG8IGM7v93i82+V8fw0Uq3QZl8UOAAARsAgFjjultGnXl3QtGqYChxJ1ifRKbty7Fc\\/NboYe1CO\\/UqyVrb4eJ6datFMzPdD\\/f6\\/pAft9bPAsTejrZTP9KC9XkmTi6ZRJ1n70mmhuJsFjjTfxg11tpPm5yi28PyXZPSjk+KNAgcAwAgYtAJHKebTGX1KaWfSuG4btgLH48NgForasRxzYcwJHT5\\/d8g+Bk9af\\/fW5fOhfr\\/anTsgL1lLfV7Qg7b6WeBI\\/iWjvZS8bpFrV9bPq5S\\/Wcd2u1ngSN6Usa1mE6BuirmyzvO+F6rFnXYpcAAAjIBBK3A8IaM\\/Ka\\/LqU+rhq3Ake5jT7\\/sZx3Pe+bXtZakJUf\\/Oxzub5p8cK7NbaSC2bWh\\/v6\\/t1sd7cBtMvqU8pc59qsdWZ+e\\/2cP2up3gePOGe2tXkBv61G73XJyyO5\\/ynom2O12gSNrOfD3NHneUzKe98wO+pAocAAAjIBBKnA0uqhIuXUOfVpr2AocSaP5BL4ZBvtWlaeHW\\/b5azEPbnM7H6uzndXs6FZn23SwQZ+GZYTAH4b6\\/f9qD9rqd4EjeW9Gmynv6mG765UKmxeF7L6v95h1u8CRfCpje1kj9sZD\\/ZWirgmd\\/0xT4AAAGAGDUuBInzg2Wpnh2X3uTz0vDPX7NshLr6a5Ei4O2cf1Q6E6UmLQpPkxGhW77tXGtp7bYDtP7l6X2\\/KlBn36sXVsNxVsnrHu3rXm+aF+\\/z\\/cg7byKHDsz2hzNS\\/qYdvr8cbQuN\\/HrXP7vShwPDxje6\\/I+P5fafP7W6HAAQAwAgahwLEv5hsZ\\/UhJF+gzbW5zMeasUP3l9O9jjupCP8\\/P6N\\/7u7DtXvqF0PiCJ803UMqtd7eUhqxn3VaS8uY2t3evBtu6InTn3GjHkxv0p9PRD9Ph5qNC+rFCzOtC\\/X14fQ\\/ayqPAkWSt8rGaJ\\/S4\\/Xb9VWjc3yd2oY1eFDgajcjYWuf7s+ZpWs8cTQocAAAjIO8Cxxkx38noQ0q60L1ji9tK35eKEF+os52f7kJfv5LRx3\\/uwrZ77TWh8YXPP+TXtZtJ84L8IGT389LQ2fwHlzbY5t+uu9et2xmqRZWsvvy\\/Drb5q6F6687a7by3C31tJI36yZrf5YU9aC+vAkea8+VzGW2v5jE97kOr\\/jw07ueHutROLwocyTMytnnknBpZq2yt97YhBQ4AgBGQZ4Gj2W0IKY9tY3tnNdhOJxeOa53QYNvDMClkGgHTaHWalHeGzpeO7Ib7ZPRrbe7b4baf12S7v7KejrcojbL49yb9OLHNbTba3m91pdf13b9Bu+f2oL28ChxJumWoUVEq5bl96EeWdF69NqNfq7kkVItr3dCrAkeaO+O6Ots8clWUrBVuOv3ZsEqBAwBgBORV4Ph\\/Ge2uzUvb3ObmBtv67x7292Hr3Ha\\/nBQar6qyepxuk0Pf\\/qBJv1LWczvA9pgfNdh2Gil0l3Vsv5l0C9AFDdpP+fsOtvuiBttL+7u8zn7XMxayl7i9KlQnuey2PAscyQMy2l+bt4T+FwiPjfl4C327Uxfb7FWBI3llxnYfWfv7tPrLDXX+Ps1pU1xn2wocAAAjoN8FjvSL6sUZba7NWzvcfqPh5J1+op0++byswXb7PYfDejRbqSbl+6F\\/w+7Tp+MfaqFPL+5CW1lD4FeTbo15eBfaOVI6P97RQtvHdLDtY5tsN4086ObFbXJeg\\/be0OW2VuVd4EgaLWG9mlT4uVuf+pNGHTW69Wo1D+hyu70scNwxY7vp53ohZBf0ujFaSYEDAGAE9KPAMR\\/zmyF7Dosj84FQvfe9E41GAqSLyHZ\\/AU+3djS6DeA\\/Ouxnnlr5NDrlg6F6208vnBmqIxZa6cfrutTmZMwXW2gvfYrcrU\\/i0wSn9SZP7OZFVL3ldI\\/Mvdex\\/bX+uEk77axu045BKHAkf5nRjyOTVvPY26M+pCLAO1vsRy8uzntZ4Eg+mrHtrFsaj7yFpVMKHAAAI6BXBY5U1Ei3brwpY\\/tZScP4J9fR7s4m209L0e5vcVupyPK+Jtv7tXX0NU\\/pfvVWX5NU6EivZadFp1XpdU2fOn+4jbZfts42j3SHmCtbaDcVJdJ7o9JhO+ki8MIW2klJtzasZ3h9OVQnFW3URprb4O9iju6wjbSMc7P9ubDTHWjBoBQ4kudk9KVeXhWqE+euV5pn48Ex726j7d\\/oQrv19LrA0Wh+l3p5VhfaTBQ4AABGQFaB49sxT2kz6RaAdBHV6oXdkenW6gsvbKGtNMw+a3WWtMRsKyNOvtKl\\/ublp2K+G9p7jdISoOeG6jFqJs3F8BO170\\/LbTa6zade\\/mz9u1hXqyNYUv4nVCeQvF\\/MpibbTfv6+FAtWLS6\\/fRpdbtLINeT5hipt3pQvbwxVI\\/BUgvbfGjM21rc7q27sB9ZBqnAkTw+oz9ZSe+ztFrPz7TRRnqPPSRkL8fbKA9cz8410esCRyrYHbkqUFZS4W5XF9pMFDgAAEZAVoGjn0lzPvxiF\\/cp3V7w9RbbTpPTpYukVJz569B8xMba9GPljV7bHfNvobPXLa3M8LFQXdUgHbvVY5iGz3+jw22mpFuJHtHDfQ617XfSt6+GagHvJaE68WxaIrjZ6jRZ+VSoTozbLWn00n+22Yc0qWyaNyPNcfLHtcc06qqVW3n6eRE4aAWOJN2+9c2MfjXLl0P1Z00qXqSCbDr2fxWqxz7dEndJh9tNc1Wc2sudDr0vcCRPbNDG2ryqS+0lChwAACMg7wJHGhHQ6bD5Ru7Z4353suLFIGs2AWe\\/8p5QLbr0QxoK38rtKr1IKpLM92CftoXsOQx6lfWsbtOqQSxwJOl4vybk\\/75JSaPSujEXRTP9KHCk0VKtvDfP6FJ7iQIHAMAIyKvAkSbnbGe4dic6\\/ZS+WdIcEuuZJ2RQnRCyLyR7nXT7ymN7v4u3cNvQeOWdXuRJPd6ndJH72j7ty2\\/2eF9WDWqBY1UazdHv82g1aRWi2\\/Z+F2\\/SjwJH0mxC1\\/d3sa1EgQMAYAT0u8CRPrn+2b7sWdXDu9z\\/NCR6uo\\/9z0N6fT4T+nM+XBPz56G7t2q0KxUEXhB6v6+fCNV5OvrlyaH9OVZaTZrv4\\/T+7crAFziSNCFtKtKl+Yv68d5J88P8Uqgun9pP\\/SpwnNygnZT7d7GtRIEDAGAE9KPAkeZpSMu3HtenfTpS+kW5nbk16iXN6fGofnc8Z2l\\/PxJ6c06ki8AXxRzft71pLvUlzSFyRejuvqZz70F93I+10kSvaULMVicgbZY00uZ5oTsTo7ZjGAocq9LkoGnp3q+E3rx30pwvv92vnamjXwWO5IKMdtLcSetZeageBQ4AgBHQjQLH5TGfD9WlKtOEhX8Tqr\\/gp5n8m63U0E9pidB0Afud0Pq+pU\\/dfz1mIof+DooTY54a866wvvPk46E6WuOs\\/na\\/beniPa0eknVx1UrS++FpoXrsBkUaPfL8mItC+\\/uTVlJJK3rkdWvWMBU41rpLqBaE0s+R9bx3UpHsYOjvrShZ+lng+JmMdnpRdFDgAABgaKVix+NC9YL7laF6MZvmLUgrGaQVDVpZRnMjSrdzpOVlHxOqqz+kC88L1yQtQfqKmL8I1QuyXw39vZWhF9LcJHcN1bkz0qoXFx6RdO48K+Y+oXoB2mw52UGQloBNtzekQmRaOeX8UC1i\\/FOovgf+NOaRMbfPq4MjKP08Sbd\\/pUlZXxbzjnDLcyklvafS6Kb0HkvFwFG\\/JQ4AAAAAAAAAAAAAAAAAAAAAAACANvxDzJUiIiLStbw0AADQd2nlh\\/UuBSsiIiKH86oAAEDfKXCIiIh0NwocAAA5UOAQERHpbhQ4AAByoMAhIiLS3ShwAADkQIFDRESku1HgAADIwdNi3i0iIiJdy5MDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD\\/vz04JAAAAAAQ9P+1wRsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAL6JKIFTUgrE4AAAAASUVORK5CYII=\\\",\\\"unitDim\\\":\\\"px\\\",\\\"height\\\":1350,\\\"width\\\":1080,\\\"name\\\":\\\"2000 2000 (2).png\\\"}],\\\"styles\\\":[{\\\"selectors\\\":[\\\"#igyb\\\"],\\\"style\\\":{\\\"max-width\\\":\\\"100%\\\",\\\"display\\\":\\\"block\\\",\\\"border-radius\\\":\\\"8px\\\",\\\"width\\\":\\\"177px\\\",\\\"height\\\":\\\"222px\\\"}},{\\\"selectors\\\":[\\\"#i1uk\\\"],\\\"style\\\":{\\\"padding\\\":\\\"0\\\",\\\"text-align\\\":\\\"center\\\"}},{\\\"selectors\\\":[\\\"#iosh\\\"],\\\"style\\\":{\\\"background-color\\\":\\\"#bdeae7\\\"},\\\"wrapper\\\":1},{\\\"selectors\\\":[\\\"#ie5ff\\\"],\\\"style\\\":{\\\"margin\\\":\\\"0\\\"}},{\\\"selectors\\\":[\\\"#iibsm\\\"],\\\"style\\\":{\\\"padding\\\":\\\"20px\\\",\\\"font-family\\\":\\\"Arial,sans-serif\\\",\\\"font-size\\\":\\\"16px\\\",\\\"line-height\\\":\\\"1.7\\\",\\\"color\\\":\\\"#374151\\\"}}],\\\"pages\\\":[{\\\"frames\\\":[{\\\"component\\\":{\\\"type\\\":\\\"wrapper\\\",\\\"stylable\\\":[\\\"background\\\",\\\"background-color\\\",\\\"background-image\\\",\\\"background-repeat\\\",\\\"background-attachment\\\",\\\"background-position\\\",\\\"background-size\\\"],\\\"attributes\\\":{\\\"id\\\":\\\"iosh\\\"},\\\"components\\\":[{\\\"type\\\":\\\"table\\\",\\\"droppable\\\":[\\\"tbody\\\",\\\"thead\\\",\\\"tfoot\\\"],\\\"attributes\\\":{\\\"width\\\":\\\"100%\\\",\\\"cellpadding\\\":\\\"0\\\",\\\"cellspacing\\\":\\\"0\\\",\\\"border\\\":\\\"0\\\"},\\\"components\\\":[{\\\"type\\\":\\\"tbody\\\",\\\"draggable\\\":[\\\"table\\\"],\\\"droppable\\\":[\\\"tr\\\"],\\\"components\\\":[{\\\"type\\\":\\\"row\\\",\\\"draggable\\\":[\\\"thead\\\",\\\"tbody\\\",\\\"tfoot\\\"],\\\"droppable\\\":[\\\"th\\\",\\\"td\\\"],\\\"components\\\":[{\\\"type\\\":\\\"cell\\\",\\\"draggable\\\":[\\\"tr\\\"],\\\"attributes\\\":{\\\"id\\\":\\\"i1uk\\\"},\\\"components\\\":[{\\\"type\\\":\\\"image\\\",\\\"resizable\\\":{\\\"ratioDefault\\\":1},\\\"attributes\\\":{\\\"src\\\":\\\"data:image\\/png;base64,iVBORw0KGgoAAAANSUhEUgAABDgAAAVGCAYAAAB7TwuKAAAAtGVYSWZJSSoACAAAAAYAEgEDAAEAAAABAAAAGgEFAAEAAABWAAAAGwEFAAEAAABeAAAAKAEDAAEAAAACAAAAEwIDAAEAAAABAAAAaYcEAAEAAABmAAAAAAAAAGAAAAABAAAAYAAAAAEAAAAGAACQBwAEAAAAMDIxMAGRBwAEAAAAAQIDAACgBwAEAAAAMDEwMAGgAwABAAAA\\/\\/8AAAKgBAABAAAAOAQAAAOgBAABAAAARgUAAAAAAADTyGbmAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAFXGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSfvu78nIGlkPSdXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQnPz4KPHg6eG1wbWV0YSB4bWxuczp4PSdhZG9iZTpuczptZXRhLyc+CjxyZGY6UkRGIHhtbG5zOnJkZj0naHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyc+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczpBdHRyaWI9J2h0dHA6Ly9ucy5hdHRyaWJ1dGlvbi5jb20vYWRzLzEuMC8nPgogIDxBdHRyaWI6QWRzPgogICA8cmRmOlNlcT4KICAgIDxyZGY6bGkgcmRmOnBhcnNlVHlwZT0nUmVzb3VyY2UnPgogICAgIDxBdHRyaWI6Q3JlYXRlZD4yMDI2LTA1LTA3PC9BdHRyaWI6Q3JlYXRlZD4KICAgICA8QXR0cmliOkRhdGE+eyZxdW90O2RvYyZxdW90OzomcXVvdDtEQUhHWXBzZmxSTSZxdW90OywmcXVvdDt1c2VyJnF1b3Q7OiZxdW90O1VBRU9OVndMYVdZJnF1b3Q7LCZxdW90O2JyYW5kJnF1b3Q7OiZxdW90O1RlY25vRmlicmFzIFMuQSYjMzk7cyB0ZWFtJnF1b3Q7fTwvQXR0cmliOkRhdGE+CiAgICAgPEF0dHJpYjpFeHRJZD44NGRkMzJmMy0yNzZiLTQ3ZjctYWZmYS04NTM0YmMzM2VhMDA8L0F0dHJpYjpFeHRJZD4KICAgICA8QXR0cmliOkZiSWQ+NTI1MjY1OTE0MTc5NTgwPC9BdHRyaWI6RmJJZD4KICAgICA8QXR0cmliOlRvdWNoVHlwZT4yPC9BdHRyaWI6VG91Y2hUeXBlPgogICAgPC9yZGY6bGk+CiAgIDwvcmRmOlNlcT4KICA8L0F0dHJpYjpBZHM+CiA8L3JkZjpEZXNjcmlwdGlvbj4KCiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0nJwogIHhtbG5zOmRjPSdodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyc+CiAgPGRjOnRpdGxlPgogICA8cmRmOkFsdD4KICAgIDxyZGY6bGkgeG1sOmxhbmc9J3gtZGVmYXVsdCc+MjAwMCAyMDAwIC0gNDwvcmRmOmxpPgogICA8L3JkZjpBbHQ+CiAgPC9kYzp0aXRsZT4KIDwvcmRmOkRlc2NyaXB0aW9uPgoKIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PScnCiAgeG1sbnM6cGRmPSdodHRwOi8vbnMuYWRvYmUuY29tL3BkZi8xLjMvJz4KICA8cGRmOkF1dGhvcj5EYXZpZCBBbHBpemFyPC9wZGY6QXV0aG9yPgogPC9yZGY6RGVzY3JpcHRpb24+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczp4bXA9J2h0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8nPgogIDx4bXA6Q3JlYXRvclRvb2w+Q2FudmEgZG9jPURBSEdZcHNmbFJNIHVzZXI9VUFFT05Wd0xhV1kgYnJhbmQ9VGVjbm9GaWJyYXMgUy5BJiMzOTtzIHRlYW08L3htcDpDcmVhdG9yVG9vbD4KIDwvcmRmOkRlc2NyaXB0aW9uPgo8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSdyJz8+6JVLDgAAIABJREFUeJzs3QucXXlBH\\/D\\/edzHzL137ryTzWZD2KRsG2GXNaIuIAQBEVrUVlNFtFItW6VKX7i2aCUisKw8FlAei0qrFNQtSq20FC2syMpredR3axUtoPtxLbC47DPJTM+5904yj3snyZw5c2fu\\/X4\\/n1\\/ObDaEzf+ef3LOL\\/\\/zPyEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAnPPkLB8V2eHcMTE19fwAAAAA2yJJTkYhPpt9dUZkB7PUaLVfHgAAAGA7JEnyrSFES9mXeZZFdiCd822i1boxAAAAwHZIqsm3KThkh6PgAAAAYHspOGQIWSk4PKICAADA9lBwyBCi4AAAAGB7JUnyrNC74QzDv\\/GV8YhHVAAAANheSZJ8e1BwyM6mW3C02woOAAAAtkeSJM8OCg7Z2XTOt8l2+2UBAAAAtkOSJN8RFByys1FwAAAMQbTFsDO2+vn47KAnSZLvDAoO2dl0zrdmq\\/3SAABAeZaXl6NVifPcurycrGS5m\\/gCiQZl2L++vWazsVw\\/7iuf0anbbktXcv0tt1ROnjpVXZ\\/8+\\/PkP+bWtZ+pz4ixouCQIaRzvjVaVnAAAJSi0m5\\/RbXZ\\/HeN6embW9Ozr27Nz7+6Obfwuqm5xTe0Zxff3J5ffHNrsZNbphYX35jlp6YWsn+fJftxr82Tff2aZjc3t+YXX5X92Fe2s2Rf\\/0SWm9oLiy9vLSzcmOWl2Y99ydTcwo9nP8+Lp+bnT2V50dTs7I\\/mac7O\\/rtO5uZ+JMsPd48LK\\/nh1tzcC1szc\\/+2NTPzQwNyQ5YfLDk39LL6\\/3P9f8e\\/WUmj+8\\/5f3P+3\\/7C3q\\/tR\\/Jf58qve2q2Mw4\\/lo9L9u9e0ppbeGmWG1tz8zdln0c+hq\\/ojeurm\\/MLN2c\\/5rXNmXz8536qOTf\\/hsmZuTc2Z+ZvmZyd\\/eksPzs5Pf3vJ6dnfm5ievqt9ZmZt2d5W+fYnnnbxPTMW7Pv\\/\\/nJ6dl\\/35ie\\/ZnJmdk3NWfmXt\\/IP\\/u5uRubs\\/M\\/lv+3NmZnX5CdE\\/98cmrqnzWbzesbjcZ3TTSb31prtb6h0W4\\/uX3Z\\/Je39+17+OTk5IHQbC5MHz48ffC66ybCyZNJsCqEPUDBIUNI9xEVKzgAALbfrbfemlQnW2\\/Jvnwwy+ksZ1bl7CY5UzCnZWAudSw3+5wuJX0+m+ih7JgnPz8eyHJflnuyfCHLXVk+G6Lo\\/0ZR9EdprfaBSrX+C3G1emM6MfGvJxqNZ03Mzj52\\/qqrrrr2cU89cP2pU5MBdhEFhwwh3YKjqeAAANh2J289Va01Wu8OnRvcaOVC\\/2Iu+Nf\\/WNnhRN3kz5Vs64X3Bf9\\/o2hDBvzYvBD5Yoiiv4zS9Pertfp7klrtJ6uTkz\\/cnF34h3P79z9mcXHxynzlx+HDh+vhVIgD7CQFh+x8egVHS8EBALDdTt56a7XWaL4ndP8Gf9gXfrJ306\\/gGPT9+bmWrxC5P8tfRXH8sbSavqM1N3fD\\/OWXP+nqr\\/zKh5\\/sPuYCpbKCQ4YQBQcAQFlO5QVHc0rBITuZ86s\\/wpoVIA+FKPpCFMd\\/GiXJ+2r1+ptrzeb3ziweeNyRI0cWr7\\/++kqAbZQkyT8KCg7Z2Sg4AADKkhcc9ebU\\/wgu8GV3ZN1qj0758aXs+Pu1yebrpxcWnvPwL7v2mhMnTjSz71\\/ZzBS2Jkm+Kyg4ZGfTLThaCg4AgG33A697Xa3eaL0vuMCX3ZUN+35kx7PZ8YEoiv8iSpIPJ7Xam5szM9fPzu4\\/dtVVV7UCXCoFh+x8FBwAAGXpFBxNBYfs7kRRtHJcv7lpvpfHnVGU\\/Hp9svmimcWZxy0sLOw\\/fvy4x1m4sCT5x0HBITsbBQcAQFme3ik4mu8NLvBlb6Xf5qV52XF3FEWfrExMvKY9O\\/vUr3r2s6cCDJIk\\/zhScMjORsEBAFCW7gqOqd8INhmVPZ4Nr62NorvTNL2tWq\\/\\/WKPdfsq+I0cWw6lTXkXLOUmSfLeCQ3Y4nfOt0Wq\\/LAAAsL3y18TWp9p5weECX0YtK5uU5l8\\/GKLod6r1yRcefeTxI8vLyyubk9qkdIwlSfI9Cg7Z4Sg4AADKkr9FZbI9\\/evBCg4Z0USdTUrjXtkRPZR936eTSvUXq43Gd1x+9OjBwNhScMgQouAAAChLXnA0ZmffExQcMh5ZvWfH2ShNPzw5NfW8K44+8kj2z9VgRcdYSZLKP1FwyA6nc741W217cAAAbLdewfHfg4JDxiurXkEb3xfF8R8ntdot7X2XP\\/nqr\\/u6RmA8VCrPVXDIDkfBAQBQlltuuaXSmpl9d1BwyNgm35g0WXmE5Z4kTd\\/dmJl51uyBA1ecOHEiDYysOI6vV3DIDkfBAQBQlk7BMTv7X4OCQ8Y6UX7s3ehGZ0MU5as6fq\\/ZnHr+tdd+zUJgJMWVyvcqOGSHo+AAACjLLbd8rNKamX9XUHDImCbq5dw\\/d141u7Ipabg3SZKPTDSb33\\/ZZZc9LASvmR0llUrl+xQcssPpnG+TrZaCAwBgu93ysU7B8V\\/CuYIjGvbFn8huyrkNSbP82exlB5\\/7zOuvnwxdNiTd4yqVyvPiSMEhOxoFBwBAWW67bTlVcIhsnnxVR+g+vnJvlCR3TEw0\\/vllD3\\/4wwJ7Wl5wRAoO2dkoOAAAytJ7REXBIXJROffoyukoiu5ozMw8+8AjHjEf2IuiSqXy\\/R5RkR2OPTgAAMpy23JnBcevhnMX+AoOkQtkqbtPR7SyouO97dmFf3j8mc9ceXSFvaFTcOSPqEQKDtm5dAqORqv9sgAAwPa67bbb0tbc\\/DuDgkPkUrPyatl87tyTVCr\\/YWpu7jHHjh2rBvaCvOD4AQWH7HCs4AAAKMup225L23OLCg6RradzwxJFUf6Y111prXrTw44fvyyw250rOIKCQ3YuVnAAAJTltk7BsfArQcEhUjQrj62ciaLkQ\\/VG47uuvPLKdmC3imIFh+x8FBwAAGW5dXk5ac8t\\/nJQcIhsV1ZumE8nlcovTh84cO3JkyeTwG7TWcGRKDhkZ6PgAAAoi4JDpJSs3DSfyfKptDpxw\\/6jRxcCu4lHVGQYUXAAAJSlV3C8I3Q3TFxWcIhsa5ai7g30mSiK3jc1u++rg01Id4vuW1RiBYfsaHoFR0vBAQCw3fKCY3p+\\/629t0EsKzhEtjf5vhxxHOc3NfkmpHemtdoLTp46peQYvk7BkSg4ZGfjLSoAAGXpFBwLCg6RHcjKjfSXoiR5x2S7fTwsL0eBYckLjn\\/mERXZ4Sg4AADKkhccM\\/P7f0nBIbJj6b1tJfxFa27um3obkCo6hqBSqTyvW3BECg7ZqSg4AADK0i049v1SsAeHyE5mZdXAXXGavmT+iisOBCXHjqtUKt9nBYfscGwyCgBQlk7BsbC\\/V3DkF18KDpGdSm8lx5koSd4ze+josezrOLBjFBwyhCg4AADKouAQGWpWHlc5E6Lojyanp78hsGPiSuV784IjUnDIzkXBAQBQFgWHyK7IStFxZ21i4gWHDh2aCZROwSFDiIIDAKAsy8vLsYJDZLiJomg5juKlOO6UHPcnSeXnrrr2WvtylCyuxB5RkZ2OggMAoCwKDpFdl3wunk7S9L\\/PX375IwKlie3BITufXsHRUnAAAGw3BYfIrk0+Jz+8\\/9ChLwuUQsEhQ0jnfJtUcAAAbD8Fh8iuTedGKIqiT07Pzz\\/x1KlT3rCyzeJK5XlRUHDIjkbBAQBQll7B8YtBwSGyW7MUovDpyZmZZwSvkd1W+QoOBYfscHoFhz04AAC2nRUcIrs+3RvwKPrURLP5zSGcSAPbIq5Uro9DpOCQnYyCAwCgLJ2CY58VHCJ7IPkc\\/Wy12TwZTig5tkWl8k8iBYfsbBQcAABlyQuOWQWHyB5IfiOe5PP08\\/XJye\\/OjkmgkCRJvlvBITucbsHRVnAAAGy77gqOfQoOkT2Rczfjf1lvNJ5z\\/PjxSmDLkiR5TrAHh+xsFBwAAGXp7sGx7xeCgkNkD6VTdHx+dmHh6wNbliTJPwrnCw4pJ7tgvuyqKDgAAMqi4BDZk1l5hewnLjvyt48HtiRJkmeHVTfj2XiubOi69p\\/XfX2h5D92fS72fzvo59nK\\/77fz7fx+7rZrp9\\/1VtpluLuf\\/uw58pui4IDAKAsCg6RvZveDev\\/nplZfFxgKx6d5U1ZXt\\/LLVl+Osube1\\/n\\/+6NWd6Q5aey\\/GSW12V5bZbXZLm5l1evOuZ51eDEeV65Kr3v2+x\\/08kFft5zeeUF\\/l2eV\\/TyE9n\\/d56bsq9fnuXGLC\\/r5cd7efGqr1\\/SS\\/bv4xu7\\/\\/tOXtH7+W\\/ujU8+Zj8TouiD2fFs2AVzZRdFwQEAUBYFh8jeTXR+pcEd+6448sjApYqyVLNUeqn2SWVV0gFJRiDxFrP651gZj3zcatXW9Ddmxwet4lgTBQcAQFk6BcfivreHzkVXfrPkQlRkD+ZslCS3z19+5SMC7BJpvf7E7HBvsBfH6ig4AADK0nlN7OJlnYIj8ry0yF7O2ZAkH2nNz18VYBdIJyYemx3+JnQL9GHPj92STsEx0W7fWGhwAQDYaF3BsazgENmzWXlc5Tcuu+yyhwUYsjStPz47fMnqwI3ztKHgAADYfgoOkVFK50bydFKpvP3w4UdPBxiiNE2fkB3uU3CsiYIDAKAsq\\/fgUHCI7PVEKxuPPpRWq6ey+Z1voglDkabpE7PDAwqONVFwAACUpVdwvC0oOERGIt15HOc3lJ+vN6a+PXTfagE7rreC434Fx5ooOAAAyrJmBUd+czT8iz8R2ZZ0VnLcOTE7+9UBhmBtwREU6N0oOAAAyqLgEBnNxHGcr8rKXx9724ErrzwUYIelafo1QcGxPgoOAICyrHlEJSg4REYsndc\\/x0nylgMHDkwG2EG9guM+BcfaORkUHAAA5VBwiIx2uvtxhHtqExPPP3XqVBxgh6RpPS847lVwrImCAwCgLKsfUell2Bd\\/IrKtyW8qu\\/txNKennxRgh6Rp+vjscG+vZFu20WgnCg4AgLKsKziGfeEnIuWkc1MVJcl7H\\/3oE9MBdoCCY\\/BcVHAAAJTACo6Luxgdgwx7nKXk5HtxZHkgrVZvOnjddRMBSpbWu4+oKDjWRMEBAFCWvOCY6+3BEdzonkv+rHgv2U1hd6PGlTHq3SieS+juX9JJGJDN\\/l2\\/H3uhn2\\/1zxldKH3+ewf9OjbJ0D8T2Zbkn+WD9ampbw9Qsl7BcZ+CY8McVHAAAJRh9SajwY3sufQ2w\\/tClKa\\/HOL4lhAnb8yOb87yM71k3xe\\/KcsbsvxUltdleW2W12S5uZdX9\\/KqVXnlqrxiXX5iVVb9c3pTLy\\/P\\/jnPTef+Xej8PK\\/Kjnlu7uW1vbwu+zW8Pssbs7wpy09neUuWn8+Sr9r5pSy\\/kuW\\/ZXlfltuzfCjL\\/8zyZ1k+FzpvQAhnwgXKlmF\\/XnLRWSm3Pnrg2LFDAUqk4Bg8BxUcAAAl8BaVtYmipLtyI9+UMQqfPHjNNZcXH+U9Iw4nQhpmZtqhVjsaKuGrQxKemX3\\/92d5VZZ3hG4J8r+y3JPldHa+nA0h9FsBMvTPUjbNmaRS+VmPqlCmlYJj5S0qCo5OFBwAAGVRcKxNFMXnC458JUOjsS87RkXHeQTkY5BmyW+IF0O1enWoJt+Uff2jobsi5HeyfDH0X+0x9M9V1iaOO3+jfu9Ee\\/Zb1n\\/QsF0UHH2zUnC8vNjoAgCwwaqC46yCI0\\/cO3YuyD\\/eWFzcV3SMx0ASJsNlIQ0nsq9\\/MMtbs\\/xhlrtDXnhs3ONjF3zOEvI5H0UfOnDkyBUDPlcoRMHRNwoOAICy9AqO\\/xgUHL2sKTg+oeC4ZHGWepa88Hha9k\\/5Rfzvhc6bFJQcuyz553A6rVRuDkeP1gZ+orBFaZo+ITvcr+DYMO8UHAAAZVBwrE0Uot4YdJbwf7KxsLC\\/8CCPt7jRaOwPSfL3Qhznm53+QZa\\/Cave4hJ2wec+rumN\\/53N+f1PvMDnCJcsTdP8vHpQwbEm9uAAACjL6oIjDP\\/CbxelW3CEhYaCo7jze5gcW2jWGrWnZd\\/zqyHfsyNaWdGRj7ebn2EkiqKzIUl+\\/dCjHjWz2YcIl6perz8pm9cPBqu2VkfBAQBQFgVH\\/\\/T+ZvuTwQqOcuzb1wiVyvE4jl8Uuq+lvT94fGUY5\\/nKuf5AZWIif1uODXXZNmm34DgdzOvVUXAAAJRFwTEokUdUdkir1ZoLcXhe9uXvhm7RcbZz0x25KdrB5I8L\\/c7hxxxzvrNt0nr9ayMFx4a5FhQcAADlUHAMSm+TUQXHTkmyXB6S5Huy4weyPHD+8ZVhnwujn95+KA+m1dpPhGPHqhf1icEFpPX6k6MQnTm\\/B4cEBQcAQHk6Bcf8SsGR74FgH4RuvEVlaA5OzWbfPjfL+7N8IZx\\/dMVNUnnn+8o5\\/7mJiamvvqjPCS4grdefEvJXRdtkdHUUHAAAZVFwbHoR+nEFx9DEs7OzU9VW6+9nX38iKDh26pxfiuPkl06ePGUVB4WdLziCgmPdPFNwAACUYO0jKgqOVekWHI2GgmPIaq3WI0Ic5zcDnwm918uG4Z8fo5p8bO9OJie\\/KdhwlILSRuOpkYKj3xxTcAAAlMEKjk0vQj\\/ebDYXi40w26U+0\\/qa7PDBLGd6JYeio4T0xvb20GrNX\\/SHA330Co58fycFx\\/msFBwvLza6AABsoODY9CJUwbG7RNnnsRDHcf460z8OK29bGf65MlLpjel9SbX6bZfw2cAGaa32dQqODbGCAwCgLN6isulF6CcUHLtTZXLy2uzwrixfCvbnKOf8j6L\\/sm\\/fvsbFfyqwloJjwNxScAAAlKO7gmNRwdH\\/IlTBsXvl+0NMx5XK87PjXUHJUcb5f9fE3NxXXvxHAmv1Co5V81LBETyiAgBQHgXHoEQKjr3g1Km43mo9PvvqtiwPxXH2uUXDPndGIvn5fzau1l+cHZNL+kygJ63VnhYUHP3mloIDAKAMCo5BiezBsXdErcsvnwtx\\/MYohAciKzm2I0tRFOdvrPndw49+9PQlfyIQugWHFRwb51ZQcAAAlGPtJqNDv\\/DbRVFw7DWzs7NTcRy\\/IPvyL8OqR1aym\\/RdcD7tyeTj96XW3Nw3XuJHAR0bV3BIUHAAAJRHwTEoCo69KqlW8xvyO4N9ObYjS1GSvvPEiRP10N33BC5aWqt9fTAHN8ypoOAAACiHgmNQFBx7WDoxMfHYEEUfzJfHR8GrZAskH7vPTczOXnfpHwPjTsExcE4pOAAAyqDgGBSbjO51jUbjUdnhN6MQHgpusraafB+OpThNX3TpnwDjLqnVnh7MvQ1zKig4AADK0Sk4Fm0yujEKjhEQTczOHsyOvxY8rrLVdMYtipL3H37Oc+qX\\/Akw1hQcg+dUo92+scjYAgDQh4JjUBQco6Jer1+ZHX41CuHB4Gbr0hN15sJftxYXPabCJVFw9I2CAwCgLAqOQVFwjJL9R48uhCi8J3TPczdcl56lOKm8IZw8mWxh+BlTCo7+cykoOAAAyqHgGBQFx6hpzc9fFaLot6IoOhtFNh69xOTj9b8mJycPbGnwGUsKjoFzScEBAFCG7iajCo6NUXCMonpr5vHZ4dPerHLJycfrbL3dfspWxp3xVKvVnhGGf+7utthkFACgLAqOQVFwjKi0NjmV\\/63yn\\/dWcuyCc21PpFMIpdXqy7Y27IwjBcfAuaTgAAAoQ\\/cRFa+J3RgFxyiLK5Xrs8O9HlW5+ERRvBSi6IPXXXfdxBaHnTGj4OgbBQcAQFnswTEoCo5RduD48cmQpq\\/Mvnwo2CPgopKveMmOd1Xm5h6ztVFn3Cg4+kbBAQBQFgXHoCg4Rl3rwIH5EEXvz1dxWMlx4fTG6Eyc1v5Vdoy3Ou6Mj17BsRSUiKuj4AAAKIuCY1A6N3MfV3CMtqRW+4bscL+C48LJ9yvpjFMUvTMsLDS3POiMjVqt9nfDLjh3d1kUHAAAZVFwDIqCY0zUs+Sva3wg+Fvmi0k+Rn8SpusP29JoM1YUHAPnkIIDAKAMCo5BUXCMjXo4lH17e+jOASXH5snH54u1RuNpWxtsxomCY+AcUnAAAJShV3C8NSg41kXBMUaiyXb7K7LjpzyqcsHk43M6rlZfstXBZnwoOAbOobzguLHI2AIA0IeCY1AUHOMmraX55pm9VRzRcjfDPg93ZfJ9ON5z+MSJ+tZHm3Gg4BgwfxQcAADlUHBsehH68WZzn4JjTDQajf3Z4XejKORvVVlWcPRPb5XLn4dW66rsGG19xBl1ecER7YJzdpelW3C0FBwAANtOwbHpRejHFBxjJapOTn5jdvzrYC+OPukWPr2C46GkNvmMrQ8140DB0TcKDgCAsig4Nr0IVXCMozh+e34Tbz+O9emuaumNy1Kcpj+Sj1ahsWakeUSlbxQcAABlUXBsehFqD44xlKbpY7PDXcEqjnVZs4Ij34fjP2XH2tZHmlGn4OgbBQcAQFkUHJtehH5MwTF+jh07Vo3T+DXZlw8GJceGRJ0NeDslx4dDmG8VGGpGnIKjb2wyCgBQFgXHphehCo4xNTU19beyw\\/\\/xmMqm8+Mz9cX2lVsfZUadgmPg3FFwAACUQcGx6UWogmN8VeKl49ykAAAgAElEQVQ4fm12PKvkGDg\\/7q412k8tMMaMOAXHwLmj4AAAKIOCY9OLUAXHGGs0Go\\/KDp8NHlMZND9OhzQ9tdXxZfQpOAbOHQUHAEAZFBybXoQqOMZbGsfxG7LjmaDk6D9H4vhtx48frxQYY0aYgmPAvFFwAACUQ8Gx6UWogmPMpfX647PD3d3XxsbDPid3W\\/LNRr1KmYEUHIPmjYIDAKAUCo5NL0LvCAqO8TYz0w5R9N+yr5aiKBr2Obnbks+Rv6rVWlcVGWJGl4Jj4LxRcAAAlGFdwWEZ\\/tqL0LzgWCgyvux91YmJb84OX7LZaN85cm9lYuKriowvoysvOKLhn6e7LQoOAICyKDgGJVJw0HHl8ePt7HB7HMfmx9p0NhpNqtVvKzK+jK7eCo6l4M+W9fNGwQEAUAYFx6AoODgvTuMbovM3J7vg\\/NwV6dyoxXF8Q6HBZWQpOAbPGwUHAEAJFBybXoTeEfbvV3AQJiYmvjI7fDGYI2vmSNR5k0r6qkKDy8iyB0f\\/eZNnst1+WZGxBQCgDwXHphehCg46ZvLNRkP4tWCOrJkjnX1Joug\\/Z7+RRIUGmJFkBUf\\/eROs4AAAKEen4JhXcPSJgoM1qtXqt2aH+2w2umGefOTo059eKzS4jKRarfaMSMHRb84oOAAAytArOH4+KDj6XYQqODjn2HXXzWaH\\/6PgOJ98LLIb2D9qHzo0U3B4GUG9gmPo5+kui4IDAKAsecExreAYdBGq4GCNOI7fHoXOYxlL3Ru3aNjn6VDTK3vuDDMzj8yOHlNhDQVH3yg4AADK0tuDQ8HR\\/yJUwcEaSaXyndl9\\/OkoWpkr8bDP02EnH4f7QpI8Myg4WCcvOMLwz9Hdlk7BMaHgAADYfgqOTS9C72h6TSznRdkN29Hs+CehO1+Wx30FR+jOk7NxpfJ9xYaWUZQoOAbNGW9RAQAog4JjUDpL7z8aFBysdvx4Jfv2zVnOhBCbL93kr4p9dQgn0mKDy6hJPKLSf74oOAAAymEPjkFRcNBfUq3+g+zwN1GIl9y8dZLPlfeG2dmpgkPLiFFwDJwvCg4AgDIoOAZFwUF\\/tVbrEdnhzzubjVrFkScfg983V1gvqdWeHoZ\\/fu62KDgAAMqi4BgUBQcD5CsVoug3os588crYXsnz2TAxcbDw2DJSFBx9o+AAACiLgmPTi1AFB\\/1UQxy\\/Ji84osgKjt6bZO6uNptfVnhkGSm9gsMcWRsFBwBAWboFx7yCo\\/9F6B2h1ZovMr6MpqSafHMUwkNRZAVHbwXHA2m9eaLouDJaFBx9o+AAACiLgmPTi1CviaWvynTjmuzwWQVHnk7B8VBSrX5T0XFltCg4+qZbcLQUHAAA207BselF6B0eUaGffVdf3cgO77cHR1juvk0mOh2S6ncUHlhGSlJLFBwbo+AAACiLgmPTi1AFB4PF8VuCebOcv00mCuF0Nh7\\/tPCYMlLygiMa8\\/nRJx5RAQAoi01GN70IvSM09ys46Cuu1Z6XHc6EMZ83vYLjTIjjFxceVEZKWku\\/Poz5\\/OiTTsEx0W7fWGRsAQDoQ8Gx6UXoHSHYZJT+0kYjv3l7KIz5vOkWHNHZEMc\\/W3hQGSlpquDoEys4AADKouDY9CJUwcFA1UbjUdnhi8G8We7uRRL92qlTp9Ki48roSNPa04L5sT6dgqNhBQcAwPZTcGx6EargYLDJycuybz8TzJvlzptUougD4diJZtFhZXQoOPpGwQEAUBYFx6YXoQoOBmu3Z7JvPxrMm86bVEKIfi\\/MXn6w6LAyOhQcfaPgAAAoi4Jj04tQBQeDHT5cjyuVnwvmTa\\/gCJ8NlckvLzqsjA4FR98oOAAAyqLg2PQiVMHBZqI0TW8I3bkz7PN1yMn34AhfDGn9RMExZYQoOPqmW3C0WgoOAIDt1i045hUc5xKvvghVcLCppF5\\/dna4L4z53Imizq8\\/G4fa04uOKaMjTWtfF7rnxnLUOU+ioZ+ruyArr4l9ecHhBQBgPQXH+qwtOFotBQeD1ZvNJ2aHvw5jPneyG9f81\\/9ACMm3FB1TRkea1p6aFxydciMoOHrpFhwtBQcAwLZTcKzPSsHRuWHLN5BUcDBQfWbmUHb40zDmc6dXcDwU4vh5RceU0dErOM5G2e+nCo5zUXAAAJTFHhzrs3IBvlJwWMHBYO1Dh\\/I3qfxh6MyfaNX5M17pFRxnQohvyo5x4YFlJKRp\\/Smh92eLguNcegVHS8EBALDdrODY9CLUHhxs6vCJE\\/XscHswd5Z6+Q9ZKkXGlNHRKzjOhHPzQ8ERzhccNhkFANhuy8vL0fTCQv6qSwXHxotQBQebu\\/VkEiXJO3srGMZ5\\/vR+\\/dF\\/zo61osPKaEjrCo4+sYIDAKAs3YJjUcHR\\/yLUHhxcUJwkb1BwnCs43psdJ4uOKaMhrdefHBQcfeeKFRwAACXwiMqmF6EKDi4oTtMbFRznHlH5RJaZgkPKiEjr9a\\/NDqeDgmPDXFFwAACUIC84phQcq3LuAjwfi4+0Wq25QgPMyEvr1VPR+Rv8XXAOD\\/XG7dOT8\\/MHio4poyGt158UOgVHpOBYO08UHAAAZbCCY31WXhPbGYsPBwUHFxCn6atD9\\/GMcZ8\\/+a\\/\\/c6FWO1J0TBkNaZo+MTs8GKzgWD9PFBwAAGVQcKyPgoNLkr8x5DfG+RWxq5LPmS9Um81HFh1URkOapk8ICo5+80TBAQBQhm7BsajgOJeVgqPzt\\/EfUnBwAXGWX+7uwWEFR5Z70nrzCUUHldGQ1utfkx0eCAqO9fNEwQEAUAYFx\\/qsWcHxoTA1NVtogBl5cRq\\/TMFxbs48kFQnnlV4UBkJadopOO4PCo7182RpstV6WaHBBQBgI4+obHoRquDgguI0\\/mFvUTk3Z07Hae1fFx1TRkOa1h+fHe4L5sb6eaLgAAAog4Jj04tQBQcXFKfxixUc53I2Tqs3FR1TRkOapnnBsWoFh4TzBcdLi4wtAAB9KDg2vQhVcHBhcfyTCo5V8yapvCn7fSUqOqzsfWndCo4+6RYczaaCAwBguyk4Nr0I\\/WAICg42l1Sr35EdTofhn7O7IUshit517NixZsFhZQT0Cg4rONbPkW7B8eNFxhYAgD4UHOtzbhO8fCx+W8HBhVQbjUdlhy+Ezjkz9q+LzefNH07Mzh4sOq7sfQqOgXNkaXJqWsEBALDdFBzrs\\/o1sdHtod2eKTjEjLpa+0j27WeC+bPcG4O7qtXq3yk2qIyCXsGx6jWxEs4XHC8uMrYAAPSh4FgfBQeXqF4\\/nH37Z8H86c2bcG92Y\\/uEYoPKKEjTznmg4FibXsEx9WNFxhYAgD4UHOuzuuAIHwjtQwoONlefflj27ad658wuOIeHmc7jOWdDtfqsosPK3pemaV5wPBj82bI6vT04pl5UZGwBAOhDwbE+a1Zw\\/FaYnp4uOMSMuInZ2Suywx8rOFbmTViK4\\/hfZUdvUhlzab1+Iig41mflEZUfLTC0AAD0o+DYmKibfCzePz19WMHBphqHD+\\/PDr+bZal37gz9HB5i8jFYitP05dnXcdGxZW9L6\\/WvjaIof8OQP1tWzZHQLTh+pNDgAgCwUbfgWFRwrMqqguM3reDgQg4eO5a\\/aee3g4Kjc\\/MWRZ0VHD+TfZ0UHVv2trRWe2p2OBP82bJmjuSZbLdfWGRsAQDoQ8GxMasLDis4uJB9V1\\/dyA7vDgqOczdvIYrekx2rBYeWPS5t1J4W\\/NnSd4402u0fKjK2AAD0oeDYmNWPqFjBwYUcv\\/76Sna4NctZBce5fPzA8eOTBYeWPa5Wqz0j+HNlfVYKjhcUGVsAAPpQcGyMgoNLcfLWk0mI458LVnCsvoH70zB7+cGiY8veltRqzwwrq3qGf17ulnQLjunZf1lkbAEA6EPBsT4rb1HpFRxeE8sFZHMoCkn8pmD+9NJ5k8rnQ73+5IJDyx6XVKvfHBQc69MZj+bc3A8UGVsAAPpQcKzPmoLjN9vttoKDTeUFR1qr3BzcyPXSKTjuTyr17yw4tOxxSbX67cG8WJ\\/OeLTm9z23yNgCANCHgmN9FBxcump98qXB2yJWz53TcRzfUGxU2esqtdo\\/DQqOfvNjaWpxUQEIALDdFBzrs6bg+K2g4OAiTHSfp38gmENZovx4NsTx28LRo7WCQ8seFler+atQFRxr0xmP9v7931JkbAEA6EPBsT5R7xh3C46g4ODCpvbt+7bs8KVgDq3MoXwc7piaOjhbbGTZ0+L45qj7yJJ5cT6d8ZjZd+CZhcYWAICNFBxrE0UrBUfnovzDrVZrrtgIMw6mr7jsCdnh7mAOrSQfh8\\/Wpqb+VqGBZY+LfzaK8rK48\\/vpqt9fxzndwmf24MGvLzq6AACso+BYm5UL8O5FefidMDl5WbERZhzMHjp0LDv8dTCHVpKPw4Nprfa0QgPLXveL2e+pq1ZwxMM8J3dJuuMxt2\\/f1xYcWwAA1lNwrE0UxcvR+YvQT4TQXCw4xIyBhYNHjmaHO4M5tJLOTVylXvemiPH2rvz31POP\\/lnBsVJwTC8sPKHo4AIAsI6CY23OFxyxR1S4aAeOHLkiO3wmmEPL3ZvYeCmbR0txnL6m6NiyR504Uc++vb27gkOxsSrd18TOzDyu0PgCALCRgmNtOgVH528cO2PxkdBqzRcbYcbBviNH8pU+n+otxx\\/6eTy8RJ3HvHpZClH0ruKjy57Ufbzvj4I\\/V9anU3BMTE19VYHRBQCgHwXH2qwvOFoHDig4uKCZ48fb2c387ys4ouW1byKK7ggLx5rFR5g9p1a7Kvv2L4I\\/V9anU3BMTk09psDoAgDQj4JjbdYVHPkjKgoOLujw4cP1EEW\\/vXZDxXHM6oKjMxZ3VRqNawoPMHtPpXJt9u3nw1jPh77pFhzt9pcXGF0AAPpRcKxNn4LDHhxcjEoURe9WcGwoOB5KJia+tfDoshfle0zcE8Z6PvRNPh4PNGdmHllgbAEA6EfBsT7nbtDysfiQgoOLlIYo+hUFx4YshTi+JTtWC40ue9GzstwfzIeNcyKEu9qLi1cWGFsAAPrpFByLCo6Niazg4FKkcRz\\/QnZcsg\\/HmuRj8b4s7SKDy54ThTj+wex4Ovhzpd+c+IMDj3iExx8BALabgmNQIis4uBRJUqm9Pig41icfi\\/9bq9WOFhpd9po0xPGrQvfPlWGfg7stZ7PfLd53uPsaXQAAtpOCY2AUHFyKuDrZ\\/NHQ20AwDP\\/83S3Jx+KetNl8UpHBZc\\/Jb97fHsyFfjmb1mrvPHnrrUmB8QUAoB8Fx6B0\\/hb+g2FqarbQADM26q3W9wQFx\\/rkY3E6pOkPFRlb9pzFLB8O5sK6dPZ3OtOYnr25yOACADCATUYHRsHBJalNTn5DdngomEfr51G+0Wi+P0laYHjZW\\/5Olv8XzIU1iaI4G4\\/o\\/vlDh55baHQBAOivt4LjrUHBsS5WcHBp0nrnMYx77MGxNlH395U\\/mT1w4IpCA8xe8vQsDwZ\\/pqydC1E2HlH0xYUrrnhCodEFAKC\\/vOCYUXD0Sa\\/gCAoOLk5zZuaR2eHTkXm0Jr3C50vVyclvLDTA7CUvzHImmAvrk4\\/HX+0\\/dOjLCowtAACDKDgGpXNT9tsKDi7W4sMfvi87fFzBsTbdZflhKY7jVwSPqYyDbAqEd\\/SKLXNhzVyI8rcsfergNddcXmiEAQDob13BMfQLwN2TXsHhERUu0r6rr26EKHpfMJfWpHNT17nRjT6S\\/bP5NPLaM9k3f+BRrX5zIc7nw0cPHDgwWWiIAQDoT8ExMN2Co925WIcLOnHiRBrH8VuCpfmD5tNdlXb7ywsMMXvDU7LcHcyBfnNgKUnT\\/5odK1sfXgAABlJwDErnbx9v7\\/1tJFyUuFb7F8Hmiv2Sj8eDlVrt+wsML7tfkuXHg9clD5oDS5VG41XZMd7yCAMAMJiCY1A8osKlS6rJP8gO9wY3d\\/2SP6byP2ZnZ6dCd58GRk87yweCgmPA+R+W6pOt79768AIAsCkFx6D03qLiERUuQdqaeGx2+FwY+vm7+9Lbk+HzoVL5igJDzO52TZY7g3KjX\\/IxuX9yZuYZWx9eAAA2peAYFAUHWzAxcUX27ad6b0twk7cq596qEVeeX2iM2a3yVTk3BI9oDUo+Jn8xffniNVseYQAANqfg2PRi9IMeUeGSdM+XDwVL9PukV3BE4VeDR1RGUX7u\\/2bwZ8mgZOd+9Mmj1\\/5\\/9u4EXs6rrh\\/wme3ua5KbpEnapmna0gilkGKpFbiWRSoWQQygLBUVEAVxAQQUiAJ\\/BQTEgogKIohgAQGRspQdZBPZLCIIFFkKFKS0ULo3\\/3PuzG1u03lnuzPzzsx9ns\\/n27lN7rznvO+8c3Pf35z3nNstdXyEAQBoTIEjK7U5OIICByvSvBHNL0x2754IxeJLgwJHvffU6iiOr4\\/Pzp7Y9FgyXEqle8X\\/\\/jA472+ReN6n3FCZmvr7AwcPjq3nMAMA0IACR1ZWCxxuUSFdu5XODcViK7dWFOL3\\/X4hvp\\/conKL91R6TMfkuniMnhcfyy0cT4ZDei1fERT26qZ2y9o1s\\/PzD1\\/HMQYAoBkFjqxYRYWqU5eXF+LFybtXRmYcOFBq9v2lycn7x4cfKnDc4j11aE2R46sxe5odS4ZEde6Z9JoqcNTJys+CQuGynccff9Y6jjIAAM0ocGTGCA6S4sTs7Lnx8QfxAuVtYceOqWZP2LJz54nxQv4rChwN31vp8UHNjiVDoRyKxT+Kj9cGxY265\\/vKCI5i8cs79+7dtY7jDABAMwoc2b+UBgWODW9mZnuad+Mjheo58dXJycmmFyhLy\\/tm4sNHg4u9zPdWtfhTfFUw2egoOD7mGwp62ed7Sqlcfs+mvXvnOj\\/MAAA0pcCRFZOMEsLU7Ox9Cmn0Rm3uiOnFxVNaeFqhWCqZaLRBahfDX1w46qhjWzieDLTio8NNRav8z60BzMrPgcrk5PMPtHCLGwAA66DAkRUFjo1ux\\/79U8Vi8fxC9b2xcvE2Njn5Cy09uVz8\\/fjf64MCR90UCsV0XK4OxcqjglEcw2t+ZYTb+2qTaOZ+Xg1oVs71zdu3n9v5gQYAoCUKHFlR4NjgCqWpqXPi42WF6rmwUqgoFotPaeXJpamxn4sPV9eeOwDn80AmHZsP1y6SGT6FUKqcGywN2yQrxZ+v7N1\\/6+M7P9QAALREgSP7l9KgwLFhbdq0Kd0r\\/9ZweOh9NcXia+Jjsdnzx2Zm9sWHS4MCR6OkY3NlaXz87GbHkwE0GXYGc820cI4XbiyNjb397LPPHu\\/4WAMA0BoFjqwocGxklUrl3PhwZbj5xduNhRA+vbB790Kz589sT5OTFj6kwNE0afnMNx04cGCs2TFl0BR\\/Pf7nGnNvNDm\\/47+tY5OTf9rxYQYAoHUKHFlR4NioxsfHT4gPF4VbfjKd3iPfqszPn9ZsG\\/v27RsrFosvUuBonNrF8Q9KY2P3D+biGB7j43vjfz9l7o2Wzu9rZjZv\\/vnODzYAAC1T4MiKAsdGVSwW\\/yRkrwpxXfyG32hlO2OTkw+I59GRo0BkTW66\\/adQeHt8nG3luJK7SszzY25Q4GiadH5\\/Y3x2y0mdHmwAANqwUuDYsu0fggLHEUkXXoV\\/C3MKHBvJ9PTKMrBfyhp2X\\/3z4stDmoGgibldS2kkyNdDQYGjSdLx+X5pbKy1FWrI2\\/6YS4JlkFtI4cZCufyWk848SfEOAKAfagUOIzjq\\/GK6UuAIVnjYMKqreaSJRdMn04fqfTJdK3x8Kmap2eb2P2J\\/JX7\\/u4MLwaapHdePhcXFY5odV3JTCNPT2+PjBaH2HgkDcO4McNI5fd3k\\/OzjDxw4UOrwmAMA0A63qGRFgWOjKVUnFr0+NChG1C7ELwljY7ducbMvDgocTVMsrhzX64vF4uNbPK7k449Ck\\/eI3JR0jC5d2rf3dp0dagAA2qbAkRUFjo2ktqzrRfECu+GFW63AcWXLt1NUKo8JChxNU5vLIR2jz05u3ryzpWNLPxXK5fIZ8fF\\/g3O5lay858uVyoVn\\/8VjLA8LANAvChxZWZ1kVIFjA0jLvr4+tHbhtrLsYyiW0siMpqt+lEqlnwlpYtLqpKV1b3uRlGJ6zx2qHtvii8LevS4KB8uemM8FS8K2mpUCx8TMzDM6O9wAAHREgSMrtQKHSUZH24EDpWKx+Lvxqx+G1j+Zrs4XMbtzc7PNTywsHBsf\\/mt12wocme+3Q7Xjk47TZaXx8Z9tdmzpky1b0gSZr4i5PmvyXblF0nG6em5p6eyOjjkAAJ2xikpWFDg2gvLExF3iw6WhvWH36XuviM\\/+ydBsFMf+\\/ZVQXFl15YY229jIScvGviPs2uW9l7+ZUAzPio\\/XBOdvW+dwoVj4+PGnnLK1o6MOAEBnFDiysnqLigLHqDrjwIHJYrF4fqjePtJugSMtF\\/uE0MptKpNjDwjtjRDZ6EnH6ZpQLD4zPk40O770TDm+Br8THy83cqPt8\\/e6qbm5p8bHYicHHgCADilwZEWBY6Tt2jVZHh9PK3ZcWZvgstXzYuUCplBYuYhJS8qWm7Y1MbE7\\/vcLBZONtpPqrSpjY\\/drenzphbSs6cNivtve+2OjJx2nlYmKv33sXqunAAD0nQJH5i+q6ZfUD4V5k4yOorHJmQPx4YedfDJdKBRX54r43zAz08oQ9IlQDP8UFDjayeqomv+cmJjY08IxpptKpXPif78ZnLNtZuWcvbFQKr0\\/PpooFwCg36qTjCpw1Em1wGEEx6gpTszO3ik+fnbN0qRtnx8rz023nZTGfq6FNgvFSuUR8fHa4GKxvWNcWFlV5eVhaWmmhePM+hVCqZTO6a8budFJVkZv3DA2PfHE0MLtawAAdJkRHJlR4BhB09PTp8SHL4TuFBrSNl4W9u0ba9bu7OzsSSGN+FDg6OQY\\/ygUiwf3Wjq214qhXP7p+HhxcJ62ndoy0DeGQvjO4nG7TunkBQAAYJ0UODKjwDFaCvHi7cz4+O+heyuapG18K+bHWmi\\/UqxUXhAfr68NY8\\/7\\/B6SpNuBSul4XRWKxWcHw\\/57Jd2K98cxlxYKRednB6mNeLlucn722fvT6kkAAPSfAkdmagUOc3CMgEKoTN0+Pn46dHdOgdVt\\/WYrnZiYnUi3xvygesFu6H8Hx\\/qqmD+PWQiG\\/3dLOo5HxbwyuIVqXVkpDBUK3916\\/LE\\/0e6LAABAlyhwZMYIjlFRqZwW\\/\\/vpQqFwfZeXu6wVOAr\\/3FI\\/ZmaW4n8\\/VVgZwaHA0W5qr93VMeeZ\\/LdrTo15W8w1teOrwNF5biyXy+\\/etW+ffzMAAPJiktHsX1ZjPjQ3p8AxxEqhUrljfPx46N1qEOl989UQxk9qqT\\/lcroN4LouF1o2UtJxuy7mdTEnhzRvBJ1It1DcOeaTwUop3Tovr1rcuvVR4eBB5yQAQF4UOBr+wvqhoMAxtMrVCRPTUpc9PLfTSIzCjaFY\\/IPQwm0T04uLt4kP3wguKNeb9Jp+uXR4FRu3rLRqebkcz9cnxa++X5sY85DVUtadG4vl8ifPvPfdd7T9egAA0D0KHFkpGMExvCZKlcqvxMcvx3S8FGxrWbkwTNv\\/TMy2pj1Lkw8Wi\\/8UfGq+rlTnO6hN8losPj1MTu5qeuxZHdF0fswPV5dJVuBYd1bex1MLc09t9wUBAKDLFDiyUjCCYziNFSvjj4qPl\\/fxNpDUzjUhlO\\/ZSgdLY2P3iw83uE1l\\/SkcLhS9P5TLZ8XHpkv2bkDplontMWmU0SVBca3bScfyh0cff\\/StW35FAADoDQWOrNQKHNXlExkCC7sXFlY+zQ\\/he6ufTof+XeDcENt+bksdnZzcGf\\/72eAis2vHP77W6efXpSuvwfj4icEtK6vSz69Hxnwi5moTifYk10\\/Nz77sjAMHJlt\\/WQAA6AkFjqy4RWWYjKeL2mLxVaG6ykYeF3Cpzc+GiYljW+husTK+Msrkqpz6OqqpFppC+Fw8F34vvhZ7wsYsdBTDZDg6VAsbqUi7ep4513pwzhWKxf+93Z1O39fqiwMAQA8pcGT\\/4hrzYbeoDLiD8WJuYuInQ3qtQuj2MrDtni\\/XhlD6tdDCRfX+u91tPn7XZ4KLzi6mcGNagrdYHc0RX4vwuVAq\\/WrYWKOw0lLEvx7z+fheWC32KW70JivHdWxq6mVhYxbSAAAGjwJHVgoKHINuYWGhWCz+bvzq2yH\\/i7jVW2LeHjPXSveL5fIzQvV95+Kzy1lzK0YqdPx7TJoA8vSYUXs\\/pwvrzTF3iklLEH8qrMwHk\\/v7YSMkTXT7nc3H7jyrhdcJAIB+UODISrXAMTs7u3ldB5heKEwsLOwOhcLrwuGLudzPmdpF9ffK1RElTY1NT58S0iogA9L\\/UU2an6P22vwopMlIQ\\/jNmJNipkJaWaSqEAb\\/U\\/jV\\/qVJQ6dj9sc8LVRHL6V9U9ToX9Jxvm5mdvYlB88\\/aGJbAIBBocCRFQWOgbRr12QolX4xVD+pzvOWlFuk2pfC9fHrl8SMt7A3lWKplL43PWdg9mNEc+OaUR1pTopvxnwk5q9i0vm0vzZaq9jsRctJOp\\/S5Kn3jTkvVPv+nZjrgttQ8jmfioUvH3\\/aKVZOAQAYJAoc2b\\/AhupFhALHYCiF6enbhGrx4IpQu6CLF615nyf1zpvvxtyxlZ2anJu7YyiEb1rdor+vUaGWcDiXxXw05qUxvxKTbjs4OWZLqN5ylFbISKM9ejnKI227EqqjM9K8ISfEnB2qy7v+a8xXw8377JzJ6fyJuWF6dvZ5+\\/fvr2S8lgAA5EGBo+EvsanAMWr37A+f+fnFUCz+dvzqCzHXF4vFQb6wW5noMj6+IBy+\\/SHbjh1TxerqL4O8T6OVQhptc9N7fOX1WlNgij8HVybnvDzmGzFpIth0W8urY\\/40hJXz8KEhlO8ZH1PBLS35uzkshZn4OBGqBYpSRsq1v0+3xqQCxo6YtPrGXUN1FEna9p\\/H\\/EvMf8T8b8wPQnUekRsKNx+Fkv9x3Li5Ib5nv7T3dgvKnm0AACAASURBVLezcgoAwKBR4MhMdZJRBY787No1WR4fv3v86sIwRBMn1i5CPx+vd49pZTcnN206I1Qvpgd+3zZI6o2SWJt0S9EPQ3Vy24tj\\/jvmEzEfDNVz9YJQLVKkvKn2mEZgvC3mPTEfqz0nPTfNwZKKKdc2aTPvYyKh+t4uhMI1s4vzT47\\/dg76nC0AABuPAkdWqnNwzFlFJRdjY2P7Qij+Tfzy++HwSiNDcaFXK3CkgsyTQ2u3NBSKlUr65N5cHIOXxsWO6pK0Nxzx5zdkfH3k92T93dCc6xswNxaLhYtOOuWk4wIAAINHgSP7F9mYjyhw9NG+fWOhXE6jGZ4XVkZADPUFf+p3uqXm6FZ2vTI1dbv48NVBmjRVRG6W9N78weJRWx65vLycbjcCAGDQrBQ4tihw1Ik5OPpnLF7g3z4Uiy+LX\\/9fOPzp+DBf7K\\/sw9jY2M+1dAT27RsrlsvPCjetijFwk6eKbORU38\\/j42\\/+iwsuaGWFJAAA8qDAcWRuurC0ikqvTUzsKVaKvxG\\/ekfMpeHIIfuDt0JKO+fRjbXbnF67MjKlBZt27twVqsvfxucVDylyiAxGaiOrLtt2zDFpQlgAAAZVrcCRVnFQ4FhJcfXr9AvtR2dnZ7es6wCzVlpJYksol+8SisU\\/iV9fFG45ueIAnAPduiiqLRlbDmmi1JYmJCxWKr8TH65zq4rIwOTG+F6+Znrz4p8uLy+nlXIAABhUtTk4VpepzPsXyQHIzUZwpNUOFDjWa8eOqdrcGn8aqqNivhdz\\/cqKBCO87OWapUjT6hmLrRyqrVu3bosPH0jFkdrzRSS\\/rPx8KlfKH7\\/rbz7UaD4AgEGnwNHwF9uPBiM42lUMW7bMhvHxvaFU+pn4\\/88IofDO+PidsDFXiUj7eXk8Fj\\/b6gGcmJ9Ow+C\\/uYGOkcigJr0Hr5jevPDQAADA4FPgyEpxZZnYsH1maV0HePgV6uRm4jlUCPPHLIZy+W6hWHxK\\/KN3x1xaKBQO1bKRChr1kvb9HWFpaabFY14K5eJzwuE5SfLuv8hGTHrvXTs5N\\/e8g+ef39I8OgAA5GzNHBwupG6WlYvyD4VtM1tDi\\/MnjKjStm3bpsP09LaJiYnj4v\\/fIeaBMb8b82chTaIZwgdDdVnXK8KRE4U6r1YKPPEEuip+\\/QehOg9JU0u7d28vlEpvjs+9wXwcIv1Nofaza3xq4oJ9d7jD9gAAwHBQ4MhMOh6f3HLMMfunjj56x+Tk5p1h06ZdYXIyZedKpqZ23JQwdVR8rGZ6enst20JImdkaZmqJ167x8XDCakIta79emf8jZrZBjtzGytdbq+3GpH5M3dS3HSv9DmFXCJNHT0wsHBsm5veMj8\\/tHZ+dPakyOXl6CGM\\/H0qlh4di8fHx+54e8+KYN4fq6h7\\/G\\/P9EAo3pALQ2jk0jNLIzppRLN+IOTG0aG7z3I+H6kgYIzlE+psbC8XiJcecetKZAQCA4VG7ReUfgwuoW\\/yCG9Kn7oXC\\/8THz4XqCIUvxVxcy5dr\\/\\/\\/FWv6nli\\/Uvndt\\/ruN1Hve55qk3nNX+\\/PFWj+\\/VOtz6vtXakkFi6\\/GfC2EQrr4Tku1XhGqow2uC7ccidEoeb9eg550jK6P+euYqdCaSrFcflp8vMYxFulb0oir6zdt3\\/q45eXlcgAAYHgocDT5Rffw7QHtXOyPSvI+\\/iOWlXPphzH3DS2a3blzc6FUSCNojOIQ6U\\/SbWGf3rRz564AAMBwWSlwLG17dXDxJB0k3X6Rdx+GIWnJ1+rSrytFjveFXbsmQ4vm5uZOjw\\/fDt6jIj1Kuo2suHor2dd37d19l7Cx514CABhOqcCxSYFDpC+pXUBdFcLKajPjoRX791eKExOPCCvzn3ifivQihcLKylnXTM5O\\/\\/7KylAAAAwfBQ6R\\/qZW5Lg6lMt3D20oVUp\\/G25+25SIdCG199R15bGx1526fOpCAABgOLlFRaTvuTENhw+hcEFYWGj5YmpuaemEUCh8oraqSt77IDISKRaL1ZWgSqV\\/O+7k444NAAAMLwUOkf6nUCilx6tDsfik+DgWWjS9devdQnXlGxPBinQnN4RC+OqmHVvbGlEFAMAAUuAQyS3pPfetMDFxVmjV8nJ5fHryt+NXV7lVRaTz1CZITu+h7y8sbT73wIEDpQAAwHBT4BDJNel2k\\/eHycmjQ4v2n3POVHly8rlhZbJS71uRDpPeOz+YmJt6+q4zWl\\/VCACAAWaSUZH8UhuFkYocLwpt3Koyu3Pn5kKp9MZQnXQ09\\/0QGbKsvO\\/GJiZe+pDHPW46AAAwGhQ4RHJPeu9dFkqlh8XHYmjRntve6sRCufzvxWLxkNtVRFrOyooppXL5jccff3zLI6cAABgCChwi+adWoPhaCGO3CW0Ym5h4UHy4rpBGcoSb5hUQkTpZHTFVKpfev3zOOVsCAACjRYFDJP\\/ULrxS3hAzG1q1e\\/fE5MLC78WvLjOKQ6RhVoobhXLpIws7d942AAAweqoFju0KHCI5Zs2KDtfGvCBs2dJykSO+h0tj4+PPil9ercghUjfV4kax+Mmd+044NQAAMJoUOEQGKul9+KOY3whtOPXUUxdK4+PnxS+vCd7LIkcmFTc+vfWYY86MXxcCAACjSYFDZJCSJgwtpvfixaFc\\/qnQxsXYrX78xzeXKpVXheooEO9nkcMjNz6zdceOVNwAAGCUKXCIDFxW5+P4fExbqzyc+sv3WSiNjb2qkC7qLCErGzs3FovFVNz4xGlnnnlSAABg9ClwiAxk0vvx+pi3xuwObdh0\\/PFHlyqVV8Yvrw7e17Jxc32hVPrQ5u3b7xAAANgYFDhEBjarIzlevWnTprnQhjPvfe\\/ZUqXykrC6hGyhYAlZGekUi8WVx9pEu9cVSoV3nXDaaXsCAAAbR63A8ZqgwCEyiEnvyzQS4x9nZma2hjYcc8wxi2Pj48+OX\\/4gXfQpcMiop1bcuHpsYuzvd524a2cAAGBjqRY4thnBITKwKdyY5tQoFoupWDEe2nDgwIGx8tjYU+OX3425IZiXQ0YstdFJq6OdLi+NV\\/7yVnf98c0BAICNR4FDZOCzevH2fzE\\/Hdq0b9++sYmFhYfGL7+aLgSLxaL3uoxMagW7dE5\\/Z3x6+vH7lpdnAgAAG1OtwOEWFZHBTXXC0ULhLRPz88eFzpQWjlq6c6lceleojeQYgP0SWW9Win+lcvl9m3fuPCsV8wIAABuXSUZFBjO1eTPS+\\/KqUCy+ut05OOo5+eSTjyoWi6mg+aM1w\\/pz31eRdrM630Z5bOwtu0+91e4AAABGcIgMZmoXcFcWK+U\\/CwsLC6FL9u7dOzc+Pf178ctvhMO3v+S+vyItJp2vN8T3x7cm5mefdOL+\\/VsCAAAkKwWOLQocIoOSNEdGbZ6My8sTY8\\/cctJJs6HLDh48WJyfn79bKBQ+Xwjh+loxJfd9F2mQG0N1VFO6xerrizt2PDD9+xUAAGCVERwiA5XVC7hvTc7NPWbbKadMh94pbDnqqP2FUunt8etrg58BMthZmYumVCi8d3Hr4plh\\/\\/5KAACAtWpzcChwiOSYNUtdXl8oFi6aXJi97\\/LBg+XQB1uOPfao4tjYM+OXXyuE6rwflpKVQUg6D9NoppWiX6HwrfL42LN2HH\\/80QEAAOqpFTjODwocIrlldULRUrn83hPuePuT458VQv+ktkrzmzefFS8i\\/ytUR5H4eSC556aJcAvhK7PbNv9c\\/LoUAAAgy80LHOlTW5\\/civQrhcOTfP6gVKm8cmnPnhNCfgrz27YdVyqVXhS\\/\\/r8QCgodkkvWrPDz3fi+ePGm7dv3xX+r+ln0AwBgGClwiOSWldUgYr5Znhh74j0eco9ezrfRsvPPP780Mz9\\/v\\/jlRaHaPyutSL+yeq5dn0YTzWya\\/4Xl97ynL7dqAQAwAlKBY2Fp+2uDAodIP1Odb6NQePvs4kBOmFhc2rXrhPTpefz6qqDAIb3PTaM2xqYmnrHtpGOPi19bJQUAgNYpcIj0L6tD7+PjFcVK6SXHnnzyUWGAnXLKKdOV8fFHFkL4ZMw1q3OFhAE4ljISWZ3UNo0UuqJQLv3r5h077tavCXYBABgxtQLH64ICh0ivs\\/oJ9acn5+fv3+MlYLupOL91656xiYk\\/iV9fEtyyIt3L6u0on5hbXHzQMbe5zWLo7wS7AACMEgUOkd5mzaiHNGrjHxaWlk4NQ+jA+eeXpufn714old4Q\\/\\/f\\/Coc\\/fVfskBZTWPt+uC4UCl8qT4w9c2nPrjS5rsIGAADrs1Lg2Lz99UGBQ6QXWR3t8KWJhdlfDtVlLof1Qq7a7wMHSpuWlu4Zv\\/pASPOIBAUOaTmr74crKpPjz7\\/DPe58dKga1vcEAACDpFbgMIJDpEspFGqfUlcv5C4tVSp\\/Pb2wcOqBAwdScWNUFLZt27Z1Ynri3LivqdCxMhFpbd9XEgbgtZD83wth5byo3YoSwtcq4+MvWdy6eOYZZ5wxGQAAoJvOP3R+aWFpqxEcIt3J6vD7a2O+NDkz84B0a0cYYfvOOGPT5Nz0Y0MhfCbu+9VpwsjVyVRD\\/q+H5PQ+CCvvheJqYeOS0ljl7446ac9pB84fqUIfAACDZKXAsVmBQ6Tz3PSeSRdzaTWI7xZLpfPmdi3tDRtlmctDobC0e\\/f26bm5BxcKhffHP7kyrJmM1IiOjZKbClvpfZAmD\\/3c2MzUH2\\/avv3H9u7dOx4AAKCXzj90qLSween11V9MFThE2k1ttEK6oLs8fv220tTU2bt3L0+EDWrnrW61eWxm5gGlcumC+L+XxmNy3eGJJVd\\/zuT\\/uklXszJao7bc65WhUPjM2MTEwS17dp548ODBjVHkAwAgf9U5OJb+WYFDpO2sflp9XcxnS1MTv7pnz575YMLEJB2DqcVjdvxkZWLspfHrbxUOHy+3roxWVl\\/TH4VC4QNTm+YfvuXoo3fE\\/y8HAADopzSCY37TSoHjBgUOkZZyeJnLEL5cHBv744mt83vCwQ1yO0qb9h04MDa\\/ZcvtyxMTTyyUS2lC0stCdcTLjebqGL6sec1Srk5LvZYqlb8bn5299759+zYFBT4AAPKSChyzi1veEFYuOBQ4RBpk9aIuTZr4nWKp+Bfbjj32uOCCrmX3eNxDpheOOurOlfHx58cL5S+F6mSsNwajOwY9N59bI4QrCqXS+6cW5x+1Z\\/\\/+Y+q81AAA0H+pwDG3uOVNofqL6yEFDpFbZs2n1l8rVSrnTc7NnR527bLMZYf2P+IRlfmtW\\/eMTUw8KB7P18Q\\/+kLMtek2lmIoHiqEtPpG8VA1+b\\/+GyWF9JgmhC0U02N12d\\/qvwkrk+cWSqX3xdfsyXObNt1x+\\/btS0FxDwCAQaLAIVI3a0cUpFtRLol52dzmzXc4dOiQi7ouOnjoYHHbScceV5ya+vV4Uf3GeMl8caiuwpJGChw5usMoj96e6yujNAqFQjr2V8d8M+aDxXL56Qvbtyyfc845U01eTgAAyE8qcEwvbv6XoMAhsprVC71r44XeRfHi7vmTm2bPMGKjD5aWZpZ27dpbmpj4pWKp9DelUundoVi8OFQvthU6upI0KmbldsQbCzefByUVNS4vFAufKBaL\\/1gZH3\\/U\\/FFbTpubm9sUlk0YCgDAEFgpcMwpcMiGzsoF3uGlTMOlpXL5LROz0+ceddxxx1rmMieHDhXu8ZCHTO85+eQTpjfP321iaurJpUrl1YVi8RPxby8phMJVwQiPls\\/vcNN5XqyO0gjhh\\/F8\\/99SpfzeyuTkC2Y3bXrYpp3b7njr00\\/fdvDQIec8AADDZ6XAsbD5zUGBQzZkbrYixHeLpdKrNx+786y9e\\/eOB\\/MLDJr0epRPOvPM2eNPOfnWM5sXH12qlF4e\\/+y\\/Yq4ItZVZ6mQAzrO+Jqvok261uiwexU+UKpW\\/XlhaOnffmWces3t5eSL+uYIGAADD7+B73lOeXlhcU+AQGcWsLdwVVj7FLlSLG2k1iH8rj409fW7btjsu\\/\\/Ivp4s9hsTy8nJ5aWlp+\\/yWLadNzE79arFcflqxUnpZoVD4YCgULg5r5vI4fCtGGsFQGNZCyC36fMRtJiu3VsV8L\\/7Zf8dz+z2lSunFxbHyE2e2LD5wcevWU7bv3bt04MCBUrdeAwAAGBi1Ase\\/BgUOGencdFG7uszl5fEC+MMTs7MPu8297rUYGCm\\/fPDgxOYTT7zV2PzM\\/cbHJx9TmZp4cbzYvzC+5p+Nf\\/2tmB+FaiEgjWpI58MNa9Ko+JE1OqJbadTG2j6mfl8T84OYr8f9uqhUKl1QmZx8bmVi4lfnt269+97TT9\\/1iI+\\/pNLVAwsAAIOsWuDYpMAhI5nD82oU0vn9\\/Xgh+MHyxMQzJjfPnb6we\\/dCMDR\\/Q0gjPbadsm16btfcpon5+ePmt8yfNjM\\/c9bk\\/PwvTM7OPr40Pn5esVI5P5RKF4Ri8ePxPPlyfNq3QyqEVSc4XS2EHJ7Lov4okPVktfiWCi+pcPGd2I+vhDTnSKn0tkK5\\/PrYz78dm519Uur3xMLMnacXFm47sbh4zNyuXZt27N8\\/ZWQGAAAb2kqBY37xrUGBQ0YjR845kIoan4oXiX89PjV19uytbrU5QIaDBw+W997udktLu3adkIoH5cnZM6c2L\\/zczOL8Iyfm5v5wbHz8OaVK6W+LldKrQ7n0unhu\\/UuhVLggjQ6JeW+hXPpAzIdK5dJHYj5WTfmj6f\\/j338g5n0x7ywU0nMKb4zf+9rSWOkVlfHKeVMzU380s3nzb80tLj5wYnb2TpXp6VNTP44\\/5ZStj3jEI4zEAACAZt6TChxzi28LChwypCkUiocKK0teVpe9DNVP3L9SrFT+Znxh4d6bdu7cFf\\/fpKF07lA8d9LoiOXlctgfKmFvPJ92hzRfy+S2bduml5aWZjZt2jS3uLg4v7B7YWH+mGMWj8zinsX59D1btmyZDfE5YVeYXNnOvn1jabsroy8OHTryHHXOAgBAq1KBY2p+8e1heCbZkw2dNFlo4cbDCTcUCitzEXy7UCh8slKp\\/OXY9OQvzu1aOmHv2WenogYAAAAbQbXAMa\\/AIQOZQqGwklBdKSKN1DhUWxEljThKkyu+bXxx7tFLu3efmm63CocVgk+\\/AQAANg4jOGTAUm\\/yxTTx4hWhUPivUrn82vLE2NMnZ2fvOz47e1Ia8n\\/olsP6AQAA2Ghqk4ymAkfW8oiyoXPTrSBdz00rnBRutv10HqZVJK4MaRWLQuHC4tjYM6eX5u65Y9++Yw4dOmTVEwAAAG5pZZLR+fl3BgUOqZvuFjgOL9saVicETeddWorzfwql0tvL4+PPqoyPP2piYeanJiYmjksjNIKlXAEAAGgmDe+fnFt8dPzyvJgXivQo6fz6i5g\\/j3lOzMGYx8Q8uDwz81MT27Ydt2nv3rlw8KBiBgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADDbF\\/Mz8c8Keb5Ma+MuSDmjTGviDkv5mDMQ2N25NNFGjgz5nExz4t5ecy\\/xLwh5sUxT415eMzZMZty6t+omoo5LeYhoXqcXxjzmpi3xry69v\\/pzx8csz9mMp9uAgDAcPqtmEPrzOUxX4j5t5g3xbw05hmh+kv89v7tys28PKx\\/v1rNF\\/qzS7n6iZgnx7wjdH6M0nnxgJjpPvZ7uUGfbtXHftTzR6F+v77co\\/bShfWbMtpslHTx\\/eB1tPuADtrsZ356HfvWinvFPCfmIx3270Mxz+pDP1t1asju66dz7Nd6PCFk79Pv5tgvAADa1I0CR7N8MlQ\\/zd\\/bn11a8fIu9r9ZRrXAcVLMM2P+J3T\\/mL0+5kF92IflBn3YKAWOtJ+vzmirnXwx5pEdtL8RCxxnhWpB77Iu9\\/XSmL8K1RE4eWlU4Ei5W35d60g55ushe38UOAAAhkg\\/Chxr895QvbWh117ex30atQLHT8a8LuaG0Ptj99WYx4beDcVfbtD2Rihw\\/E5GG+vJxaG94tRGKXCUYh4YOh+p0W7eG3PvmEKX+t+qZgWON\\/a5P+v1S6Hx\\/ihwAAAMkX4XOFbznzH36+F+vbyP+zIqBY49oXpxksf58O2YR\\/dgn5YbtDnKBY4018O\\/Zmy\\/W0nzrsy00JeNUOC4S8xFOfX\\/Y6E6X0e\\/NCtwpMLonj72Z73S8Wu0PwocAABDJK8Cx2reHLO7B\\/v18j7uwygUOA6GfM+D1bw7dPfiaLlBW6Na4EhD7judK6XdfDBmrkl\\/RrnAsSVUCz1570NKmiC2lYLTejUrcKSc14d+dMOdQvN9UeAAABgieRc4Uq6I+cUu79fL+9j\\/YS5wHBPz\\/tDZfn825lWhuurDU2r5s5iXhepIkE92uN10Pvxal\\/ZvuUE7o1rgeHnGdusd50+F6mt1Xq0\\/LwrVVT3aOSfSJJizDfozqgWO5dB47oZGSbex\\/EU4\\/L5Zm\\/TnH+1wu+ln0e063J9WtVLgSBNPD8MKPOeH5vuiwAEAMESyChwXh+ov8O0kLSv5h6F6wfStjO02ygu7uF8nd9D\\/ZnlFRr+HtcBxl5jvhNZfn6+F6kVwmkSw2af2q9JFzs+G6ioSX2yjrZRnrXP\\/kuUG2x\\/FAsfPZGxzbS6ofV8zR4Xqz4ePt7jNLFvD+t97H85o98IubLuTC\\/HHZvQnK\\/8RqvOhnNFmO2fWnvepNtt7YAf71KpWChwpT+hhH7ohjRS7LihwAACMlKwCx391Ydsnxjwm5j0ZbdTLW0LvJpxcr7SiyKgUOO4TWn9N0nwpD+1Su3eIeW4bbb9kne0tN9j2KBY4PpuxzZRLQvV178RTGmw39fe0dfS5FW\\/NaPvVPW63nj\\/J6Eu9pMl6z+pSu6mw+OY22n5Ul9o9UqsFjjS6pdyjPnTD80Jr+6HAAQAwRHpZ4FgrXUz+fUZbRyYVRPpxL3m7RqXA0eotA6mwcU6P+rAjVEfstNKP9VzELjfY7qgVOH4lY3spXwnVguN6\\/Hi45cisd8YsrXO7rRiUAseLM\\/pxZP455jY96kO6BeUtLfbjMT1ov9UCR0q3bz3slnRLVbqNRoEDAGDE9KvAsSr90t\\/K\\/eXpF\\/hSj\\/rQqVEocKRPk1v5pb5fw8tvHZqvYpDy3A63v9xgm6NW4LgwY3tpGP5t19vZmrSd79W2+\\/zQv0\\/oB6HA8aSMPhz52v1cn\\/qTljdtZQ6Qbi\\/L3U6B42NdbrtbUtGi1X1Q4AAAGCL9LnCselxGu2vzVz3uQ7uGvcDxYzGXhcbH\\/F0xe3Po2x826VfKr3ew3eUG2xulAseWjG2lPLsbnV0jzQtxbpe32UzeBY4HZbR\\/5M+rRpOt9kKaPyRrbqC1uWMX22ynwJFyZhfb7oZizJeCAgcAwEjKq8CRpNEcjeYMSHlkH\\/rRqmEucMyH6mva6Fg\\/L7feVaVJaq8Ijft4jza3udxgW6NU4HhoxrZSju9GZ3OWZ4Hj9jFXZrSf8qOY+\\/ahH42kn5ONJsxMIz22dqmtdgscecyT0siB0F7\\/FTgAAIZIngWOJN2\\/3+iWlatC94bXr9cwFzjeEBr\\/Ev\\/Y\\/Lp2M+m1Tqu1ZPUz\\/d3mNra33GBbo1TgyLp9ol\\/v417Lq8CxGPM\\/GW2npHkc7tTjPrTq3qHxe\\/zCLrXTqMDx3Yw\\/P7pLbXdDu8tiK3AAAAyRvAscSVpy9JMZ\\/Riki7RhLXDcLzT+Bf6P8utaXWkSxUafmL+2jW0tN9jOKBU4np+xrfd1paf5y6vA8ecZ7aZcG\\/PTPW6\\/Xc1upXlYF9q4bYPtPyfjz7t9m1Sn0q069fqX5grJGk34O7n0FACAjgxCgSNJn\\/A1+uT+D\\/rcn3qGtcDR6BPof8yxX43cPzS+UDu7xe0sN9jGKBU4Xpmxrbd0paf5y6PAcauMNlfTq2VY1yvr51TKxTHT69x+owLH6aH+z\\/E0Me3UOtvthn8I9fudCkNZt\\/AZwQEAMEQGpcCR3DmjLyk\\/iDkmhz6tNYwFjnTrSdYxTRfSC\\/l1ral6nwZ\\/LrQ338FynW1spALHJ7vS0\\/zlUeB4fUabKW\\/qYbvd0GhlovUWixsVOPbHPDnj73qxZG07doX685Sk+UnSakAKHAAAI2CQChxJo6UY\\/zanPq0atgJH+qT2myH7eLY7YWce\\/iNU+3pJzCM6eP5y2BgFjmdnbOuKrvQ0f\\/0ucPxERnsp34\\/Z1qN2uyVN4JzV\\/zSaYnEd2240B8dpobqyS71bzNLKJcV1tLteWe+RJ9X+XoEDAGAEDFqBoxKy74VOn77lsYTpqmErcDRaevWVOfarHSfHPDV0Pqx+OWyMAsfvZGwr5axudDZn\\/S5wvCujvZROlivOw5+F7H14+jq226zAkbwk4+\\/vs4521yPdHvO9Ov1JhZhNte9R4AAAGAGDVuBI7pXRp5QX5tivYStwNBq9cVSO\\/eqn5bAxChz3zNhWypu70dmc9bPA0egWjI\\/1oL1emY35Vqi\\/H99ex3ZbKXCcnPH371xHu+uR9e\\/c2n9PFDgAAEbAIBY4kg+H+v26LFRHeeRhmAocaRLOrIuQ5+TYr35bDhujwDEWqkuWZu3r\\/bvQ3zz1s8DxJxltpZzTg\\/Z66fdD9r7cs8NttlLgSN6e8T39XvY73RbzpTr9uCHc\\/GeAAgcAwAgY1ALHz4fsX6J\\/Iac+DVOB42Uh+\\/gN+vwB3bQcNkaBI\\/mnjO2t5vR19jdP\\/Sxw1LsYThnGCVtnQvb50OmcRq0WOM7J+J6\\/67DdTt03ox9HThSrwAEAMAIGtcCRRmnUu2c6j1+Ql8ahIgAAGoxJREFUVw1LgaMQqhMh1uvrG3PsVx6Ww8YpcNw9Y3tr84vr63Ju+lXg2J\\/RTsrvdbmtfnl5qL8\\/l4bqz4p2tVrgSNv+XJ3vuSZmawftdiprPpW7HvF9ChwAACNgUAscyV+F+n37Yk79GZYCR6MVIH4px37lYTlsnAJHkrVc7NqkCSD7eYHZDf0qcDwxo52UYZ235mdCawWJVrVa4Egek\\/F9f9xBu53Imk\\/l03W+V4EDAGAEDHKB40DI\\/kV6dw79GZYCx1NC9nHbnmO\\/8rAcNlaBIxUuLsnY7tqk+TrS8pgz62irn\\/pV4Lgwo53PdLmdfmp0m8rvd7C9dgocWauXpMlPxztou12vyOjnw+p8rwIHAMAIGOQCR1q+L+sX6Z\\/PoT\\/DUuA4P9Tv50V5diony2FjFTiS0zK2Wy+pGJIu4Dpdhrdf+lXguCyjnb\\/scjv99pFQf79e0cG22ilwJM\\/N+N5f66DtduwK1dthWi2uKHAAAIyAQS5wJBeH7n3yuF7DUuD4RKjfz1fm2amcLIeNV+BIfilj21lJF31PjdnchbZ7oR8Fji0ZbaQ8oovt5CHdllRvvz7YwbbaLXDsCdUVS4783nq3iXTT\\/8vo4x9mfL8CBwDACBj0Asc7Q\\/3+dboCwHoMS4HjylC\\/n0\\/Ls1M5WQ4bs8CRnBWqE0m2U+i4IlQLYWkJ0WKX+tEN\\/ShwnJHRRspZXWwnD08I9ffr2x1sq90CR\\/LajO\\/\\/6Q7ab0XWrTHpZ+OmjOcocAAAjIBBL3D8Tajfv7fn0JdhKHDMhuyLj4fm2K+8LIeNW+BIjo15c0Y7zZL68dhQvVjMWz8KHD+b0UbKsV1sJw9pae2sfWv39e2kwPFTGd\\/\\/5jbbbtWjMtp7SYPnKHAAAIyAQS9w\\/Emo379eD2+uZxgKHI3mLTmQY7\\/yshw2doFj1U+G7Ak0m+Xbtb5u6UG\\/WtWPAsd9M9pIGbZVZ45055C9bye0ua1OChzJpzKe0+33YdbytM3aUuAAABgBg17g+L1Qv3+X5tCXYShwpAuxrIuP++bYr7wsBwWOtdI58N8Z7TbLD2KeHfIZ0dGPAkejVZuybmsYFvtC9r7dpc1tdVrg+OWM53R7AtdzMtp5S5PnKXAAAIyAQS9wPDrU79\\/lOfRlGAociyH74sMIDgWOVefGvCOj\\/Wb5bMz+PvRxrX4UOO6T0UbKsI\\/gSBN9Zu3b3drcVqcFjrRyybfqPKfRvBidyDqv79nkeQocAAAjYNALHE8K9fv3tRz6MgwFjjQxZNbFx6\\/k2K+8LAcFjkaODtXzut6EjM3y233sZz8KHHfLaCPl+C62k4fbhux9O73NbXVa4EielvG8J7XZhyxZ+5luaSw0ea4CBwDACBj0AkfWHBwX5dCXYShwJINwQTooloMCRytmQnWlja9n9Ckrr+hT\\/\\/JeReX2XWwnD43m4Di5zW2tp8CxLeaaOs9L5125zX7U87KMfv1aC89V4AAAGAGDXuBIFzD1+ndhDn0ZlgJHukCu18\\/n59mpnCwHBY52pYvBz4fWixzpvTjR4z71o8CxN6ONlJ\\/vYjt5ODdk71u7k8eup8CR\\/F3Gcx\\/cZj+OlG4jqlc8SbfFjLfwfAUOAIARMOgFjn8P9fv3whz6MiwFjqx70P81z07lZDkocHQifZqebmlqtdDxzzGlHvanHwWO1P9rM9r5\\/S62k4esn12XdbCt9RY4sp7\\/sQ76slbW++mPWny+AgcAwAgY5AJH+tSt3idyKb+VQ3+GpcDxolC\\/n9\\/Ks1M5WQ4KHOtRCdVbm74Tmhc5Ht3DfvSjwJH8Z0Y7r+lyO\\/329lB\\/v97bwbbWW+BI3pXx\\/Lt00J8kawLT9O9HqxPEKnAAAIyAQS5w3D1k\\/yL9kzn0Z1gKHI8K2cft1Bz7lYfloMDRDek2hjQCqFGBI03826tbVfpV4PjHjHbyWJa6W9Kyvlmv2Qs62F43Chz3y3j++R30J3l4xvZe2sY2FDgAAEbAIBc4nh3q9+2KnPozLAWOW4fsC5An5tivPCwHBY5uynpPruYJPWq3XwWO38hoJ+UnutxWv5wTsvfpfh1srxsFjrTa05fqPP+GUF3Sth1pdZTPZfTntm1sR4EDAGAEDGqBI\\/3SmrWiw1tz6tOwFDiSesO1Uz6XZ6dysBwUOLrtDSH7mH6qR232q8DRqDh4Xpfb6pd0e03WPi10sL1uFDiS383YxvPa7M\\/ZGdt5R5vbUeAAABgBg1rguEfI\\/iX6N3Lq0zAVOP4uZB+\\/H8+xX\\/22HLKPw23y69aKrCWQB73AsTk0Xk72+B602a8CR\\/LFjLa+3YO2ei3dWpT1On2gw212q8AxG3N5nW1cXvu7Vl2Q0Zdz2thGosABADACBrXA8b5Qv19Xhc4+deyGYSpw3DVkX4S8Msd+9duZIfs43DXHfiVZRajP59mpFj02ZB\\/Xx\\/agvX4WOLJG1qQ8vAft9dJTQ\\/a+PKrDbXarwJG8IGM7v93i82+V8fw0Uq3QZl8UOAAARsAgFjjultGnXl3QtGqYChxJ1ifRKbty7Fc\\/NboYe1CO\\/UqyVrb4eJ6datFMzPdD\\/f6\\/pAft9bPAsTejrZTP9KC9XkmTi6ZRJ1n70mmhuJsFjjTfxg11tpPm5yi28PyXZPSjk+KNAgcAwAgYtAJHKebTGX1KaWfSuG4btgLH48NgForasRxzYcwJHT5\\/d8g+Bk9af\\/fW5fOhfr\\/anTsgL1lLfV7Qg7b6WeBI\\/iWjvZS8bpFrV9bPq5S\\/Wcd2u1ngSN6Usa1mE6BuirmyzvO+F6rFnXYpcAAAjIBBK3A8IaM\\/Ka\\/LqU+rhq3Ake5jT7\\/sZx3Pe+bXtZakJUf\\/Oxzub5p8cK7NbaSC2bWh\\/v6\\/t1sd7cBtMvqU8pc59qsdWZ+e\\/2cP2up3gePOGe2tXkBv61G73XJyyO5\\/ynom2O12gSNrOfD3NHneUzKe98wO+pAocAAAjIBBKnA0uqhIuXUOfVpr2AocSaP5BL4ZBvtWlaeHW\\/b5azEPbnM7H6uzndXs6FZn23SwQZ+GZYTAH4b6\\/f9qD9rqd4EjeW9Gmynv6mG765UKmxeF7L6v95h1u8CRfCpje1kj9sZD\\/ZWirgmd\\/0xT4AAAGAGDUuBInzg2Wpnh2X3uTz0vDPX7NshLr6a5Ei4O2cf1Q6E6UmLQpPkxGhW77tXGtp7bYDtP7l6X2\\/KlBn36sXVsNxVsnrHu3rXm+aF+\\/z\\/cg7byKHDsz2hzNS\\/qYdvr8cbQuN\\/HrXP7vShwPDxje6\\/I+P5fafP7W6HAAQAwAgahwLEv5hsZ\\/UhJF+gzbW5zMeasUP3l9O9jjupCP8\\/P6N\\/7u7DtXvqF0PiCJ803UMqtd7eUhqxn3VaS8uY2t3evBtu6InTn3GjHkxv0p9PRD9Ph5qNC+rFCzOtC\\/X14fQ\\/ayqPAkWSt8rGaJ\\/S4\\/Xb9VWjc3yd2oY1eFDgajcjYWuf7s+ZpWs8cTQocAAAjIO8Cxxkx38noQ0q60L1ji9tK35eKEF+os52f7kJfv5LRx3\\/uwrZ77TWh8YXPP+TXtZtJ84L8IGT389LQ2fwHlzbY5t+uu9et2xmqRZWsvvy\\/Drb5q6F6687a7by3C31tJI36yZrf5YU9aC+vAkea8+VzGW2v5jE97kOr\\/jw07ueHutROLwocyTMytnnknBpZq2yt97YhBQ4AgBGQZ4Gj2W0IKY9tY3tnNdhOJxeOa53QYNvDMClkGgHTaHWalHeGzpeO7Ib7ZPRrbe7b4baf12S7v7KejrcojbL49yb9OLHNbTba3m91pdf13b9Bu+f2oL28ChxJumWoUVEq5bl96EeWdF69NqNfq7kkVItr3dCrAkeaO+O6Ots8clWUrBVuOv3ZsEqBAwBgBORV4Ph\\/Ge2uzUvb3ObmBtv67x7292Hr3Ha\\/nBQar6qyepxuk0Pf\\/qBJv1LWczvA9pgfNdh2Gil0l3Vsv5l0C9AFDdpP+fsOtvuiBttL+7u8zn7XMxayl7i9KlQnuey2PAscyQMy2l+bt4T+FwiPjfl4C327Uxfb7FWBI3llxnYfWfv7tPrLDXX+Ps1pU1xn2wocAAAjoN8FjvSL6sUZba7NWzvcfqPh5J1+op0++byswXb7PYfDejRbqSbl+6F\\/w+7Tp+MfaqFPL+5CW1lD4FeTbo15eBfaOVI6P97RQtvHdLDtY5tsN4086ObFbXJeg\\/be0OW2VuVd4EgaLWG9mlT4uVuf+pNGHTW69Wo1D+hyu70scNwxY7vp53ohZBf0ujFaSYEDAGAE9KPAMR\\/zmyF7Dosj84FQvfe9E41GAqSLyHZ\\/AU+3djS6DeA\\/Ouxnnlr5NDrlg6F6208vnBmqIxZa6cfrutTmZMwXW2gvfYrcrU\\/i0wSn9SZP7OZFVL3ldI\\/Mvdex\\/bX+uEk77axu045BKHAkf5nRjyOTVvPY26M+pCLAO1vsRy8uzntZ4Eg+mrHtrFsaj7yFpVMKHAAAI6BXBY5U1Ei3brwpY\\/tZScP4J9fR7s4m209L0e5vcVupyPK+Jtv7tXX0NU\\/pfvVWX5NU6EivZadFp1XpdU2fOn+4jbZfts42j3SHmCtbaDcVJdJ7o9JhO+ki8MIW2klJtzasZ3h9OVQnFW3URprb4O9iju6wjbSMc7P9ubDTHWjBoBQ4kudk9KVeXhWqE+euV5pn48Ex726j7d\\/oQrv19LrA0Wh+l3p5VhfaTBQ4AABGQFaB49sxT2kz6RaAdBHV6oXdkenW6gsvbKGtNMw+a3WWtMRsKyNOvtKl\\/ublp2K+G9p7jdISoOeG6jFqJs3F8BO170\\/LbTa6zade\\/mz9u1hXqyNYUv4nVCeQvF\\/MpibbTfv6+FAtWLS6\\/fRpdbtLINeT5hipt3pQvbwxVI\\/BUgvbfGjM21rc7q27sB9ZBqnAkTw+oz9ZSe+ztFrPz7TRRnqPPSRkL8fbKA9cz8410esCRyrYHbkqUFZS4W5XF9pMFDgAAEZAVoGjn0lzPvxiF\\/cp3V7w9RbbTpPTpYukVJz569B8xMba9GPljV7bHfNvobPXLa3M8LFQXdUgHbvVY5iGz3+jw22mpFuJHtHDfQ617XfSt6+GagHvJaE68WxaIrjZ6jRZ+VSoTozbLWn00n+22Yc0qWyaNyPNcfLHtcc06qqVW3n6eRE4aAWOJN2+9c2MfjXLl0P1Z00qXqSCbDr2fxWqxz7dEndJh9tNc1Wc2sudDr0vcCRPbNDG2ryqS+0lChwAACMg7wJHGhHQ6bD5Ru7Z4353suLFIGs2AWe\\/8p5QLbr0QxoK38rtKr1IKpLM92CftoXsOQx6lfWsbtOqQSxwJOl4vybk\\/75JSaPSujEXRTP9KHCk0VKtvDfP6FJ7iQIHAMAIyKvAkSbnbGe4dic6\\/ZS+WdIcEuuZJ2RQnRCyLyR7nXT7ymN7v4u3cNvQeOWdXuRJPd6ndJH72j7ty2\\/2eF9WDWqBY1UazdHv82g1aRWi2\\/Z+F2\\/SjwJH0mxC1\\/d3sa1EgQMAYAT0u8CRPrn+2b7sWdXDu9z\\/NCR6uo\\/9z0N6fT4T+nM+XBPz56G7t2q0KxUEXhB6v6+fCNV5OvrlyaH9OVZaTZrv4\\/T+7crAFziSNCFtKtKl+Yv68d5J88P8Uqgun9pP\\/SpwnNygnZT7d7GtRIEDAGAE9KPAkeZpSMu3HtenfTpS+kW5nbk16iXN6fGofnc8Z2l\\/PxJ6c06ki8AXxRzft71pLvUlzSFyRejuvqZz70F93I+10kSvaULMVicgbZY00uZ5oTsTo7ZjGAocq9LkoGnp3q+E3rx30pwvv92vnamjXwWO5IKMdtLcSetZeageBQ4AgBHQjQLH5TGfD9WlKtOEhX8Tqr\\/gp5n8m63U0E9pidB0Afud0Pq+pU\\/dfz1mIof+DooTY54a866wvvPk46E6WuOs\\/na\\/beniPa0eknVx1UrS++FpoXrsBkUaPfL8mItC+\\/uTVlJJK3rkdWvWMBU41rpLqBaE0s+R9bx3UpHsYOjvrShZ+lng+JmMdnpRdFDgAABgaKVix+NC9YL7laF6MZvmLUgrGaQVDVpZRnMjSrdzpOVlHxOqqz+kC88L1yQtQfqKmL8I1QuyXw39vZWhF9LcJHcN1bkz0qoXFx6RdO48K+Y+oXoB2mw52UGQloBNtzekQmRaOeX8UC1i\\/FOovgf+NOaRMbfPq4MjKP08Sbd\\/pUlZXxbzjnDLcyklvafS6Kb0HkvFwFG\\/JQ4AAAAAAAAAAAAAAAAAAAAAAACANvxDzJUiIiLStbw0AADQd2nlh\\/UuBSsiIiKH86oAAEDfKXCIiIh0NwocAAA5UOAQERHpbhQ4AAByoMAhIiLS3ShwAADkQIFDRESku1HgAADIwdNi3i0iIiJdy5MDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD\\/vz04JAAAAAAQ9P+1wRsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAL6JKIFTUgrE4AAAAASUVORK5CYII=\\\",\\\"alt\\\":\\\"Imagen\\\",\\\"id\\\":\\\"igyb\\\"}}]}]}]}]},{\\\"type\\\":\\\"table\\\",\\\"droppable\\\":[\\\"tbody\\\",\\\"thead\\\",\\\"tfoot\\\"],\\\"attributes\\\":{\\\"width\\\":\\\"100%\\\",\\\"cellpadding\\\":\\\"0\\\",\\\"cellspacing\\\":\\\"0\\\",\\\"border\\\":\\\"0\\\"},\\\"components\\\":[{\\\"type\\\":\\\"tbody\\\",\\\"draggable\\\":[\\\"table\\\"],\\\"droppable\\\":[\\\"tr\\\"],\\\"components\\\":[{\\\"type\\\":\\\"row\\\",\\\"draggable\\\":[\\\"thead\\\",\\\"tbody\\\",\\\"tfoot\\\"],\\\"droppable\\\":[\\\"th\\\",\\\"td\\\"],\\\"components\\\":[{\\\"type\\\":\\\"cell\\\",\\\"draggable\\\":[\\\"tr\\\"],\\\"attributes\\\":{\\\"id\\\":\\\"iibsm\\\"},\\\"components\\\":[{\\\"tagName\\\":\\\"p\\\",\\\"type\\\":\\\"text\\\",\\\"attributes\\\":{\\\"id\\\":\\\"ie5ff\\\"},\\\"components\\\":[{\\\"type\\\":\\\"textnode\\\",\\\"content\\\":\\\"Prueba 1\\\"}]}]}]}]}]}],\\\"head\\\":{\\\"type\\\":\\\"head\\\"},\\\"docEl\\\":{\\\"tagName\\\":\\\"html\\\"}},\\\"id\\\":\\\"fvxLD11derVi2LBM\\\"}],\\\"type\\\":\\\"main\\\",\\\"id\\\":\\\"dVyhBv3QpOKozLiB\\\"}],\\\"symbols\\\":[]}\",\"estado\":\"borrador\",\"usuario_id\":1,\"id\":2}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/email-builder/campaigns',200,'2026-06-04 01:33:59'),(156,1,'updated','email_campaigns','Modificó EmailCampaign #2',2,'App\\Models\\EmailCampaign','{\"html_content\":\"* { box-sizing: border-box; } body {margin: 0;}#igyb{max-width:100%;display:block;border-radius:8px;width:177px;height:222px;}#i1uk{padding:0;text-align:center;}#iosh{background-color:#bdeae7;}#ie5ff{margin:0;}#iibsm{padding:20px;font-family:Arial,sans-serif;font-size:16px;line-height:1.7;color:#374151;}<table width=\\\"100%\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" border=\\\"0\\\"><tbody><tr><td id=\\\"i1uk\\\"><img src=\\\"data:image\\/png;base64,iVBORw0KGgoAAAANSUhEUgAABDgAAAVGCAYAAAB7TwuKAAAAtGVYSWZJSSoACAAAAAYAEgEDAAEAAAABAAAAGgEFAAEAAABWAAAAGwEFAAEAAABeAAAAKAEDAAEAAAACAAAAEwIDAAEAAAABAAAAaYcEAAEAAABmAAAAAAAAAGAAAAABAAAAYAAAAAEAAAAGAACQBwAEAAAAMDIxMAGRBwAEAAAAAQIDAACgBwAEAAAAMDEwMAGgAwABAAAA\\/\\/8AAAKgBAABAAAAOAQAAAOgBAABAAAARgUAAAAAAADTyGbmAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAFXGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSfvu78nIGlkPSdXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQnPz4KPHg6eG1wbWV0YSB4bWxuczp4PSdhZG9iZTpuczptZXRhLyc+CjxyZGY6UkRGIHhtbG5zOnJkZj0naHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyc+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczpBdHRyaWI9J2h0dHA6Ly9ucy5hdHRyaWJ1dGlvbi5jb20vYWRzLzEuMC8nPgogIDxBdHRyaWI6QWRzPgogICA8cmRmOlNlcT4KICAgIDxyZGY6bGkgcmRmOnBhcnNlVHlwZT0nUmVzb3VyY2UnPgogICAgIDxBdHRyaWI6Q3JlYXRlZD4yMDI2LTA1LTA3PC9BdHRyaWI6Q3JlYXRlZD4KICAgICA8QXR0cmliOkRhdGE+eyZxdW90O2RvYyZxdW90OzomcXVvdDtEQUhHWXBzZmxSTSZxdW90OywmcXVvdDt1c2VyJnF1b3Q7OiZxdW90O1VBRU9OVndMYVdZJnF1b3Q7LCZxdW90O2JyYW5kJnF1b3Q7OiZxdW90O1RlY25vRmlicmFzIFMuQSYjMzk7cyB0ZWFtJnF1b3Q7fTwvQXR0cmliOkRhdGE+CiAgICAgPEF0dHJpYjpFeHRJZD44NGRkMzJmMy0yNzZiLTQ3ZjctYWZmYS04NTM0YmMzM2VhMDA8L0F0dHJpYjpFeHRJZD4KICAgICA8QXR0cmliOkZiSWQ+NTI1MjY1OTE0MTc5NTgwPC9BdHRyaWI6RmJJZD4KICAgICA8QXR0cmliOlRvdWNoVHlwZT4yPC9BdHRyaWI6VG91Y2hUeXBlPgogICAgPC9yZGY6bGk+CiAgIDwvcmRmOlNlcT4KICA8L0F0dHJpYjpBZHM+CiA8L3JkZjpEZXNjcmlwdGlvbj4KCiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0nJwogIHhtbG5zOmRjPSdodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyc+CiAgPGRjOnRpdGxlPgogICA8cmRmOkFsdD4KICAgIDxyZGY6bGkgeG1sOmxhbmc9J3gtZGVmYXVsdCc+MjAwMCAyMDAwIC0gNDwvcmRmOmxpPgogICA8L3JkZjpBbHQ+CiAgPC9kYzp0aXRsZT4KIDwvcmRmOkRlc2NyaXB0aW9uPgoKIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PScnCiAgeG1sbnM6cGRmPSdodHRwOi8vbnMuYWRvYmUuY29tL3BkZi8xLjMvJz4KICA8cGRmOkF1dGhvcj5EYXZpZCBBbHBpemFyPC9wZGY6QXV0aG9yPgogPC9yZGY6RGVzY3JpcHRpb24+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczp4bXA9J2h0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8nPgogIDx4bXA6Q3JlYXRvclRvb2w+Q2FudmEgZG9jPURBSEdZcHNmbFJNIHVzZXI9VUFFT05Wd0xhV1kgYnJhbmQ9VGVjbm9GaWJyYXMgUy5BJiMzOTtzIHRlYW08L3htcDpDcmVhdG9yVG9vbD4KIDwvcmRmOkRlc2NyaXB0aW9uPgo8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSdyJz8+6JVLDgAAIABJREFUeJzs3QucXXlBH\\/D\\/edzHzL137ryTzWZD2KRsG2GXNaIuIAQBEVrUVlNFtFItW6VKX7i2aCUisKw8FlAei0qrFNQtSq20FC2syMpredR3axUtoPtxLbC47DPJTM+5904yj3snyZw5c2fu\\/X4\\/n1\\/ObDaEzf+ef3LOL\\/\\/zPyEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAnPPkLB8V2eHcMTE19fwAAAAA2yJJTkYhPpt9dUZkB7PUaLVfHgAAAGA7JEnyrSFES9mXeZZFdiCd822i1boxAAAAwHZIqsm3KThkh6PgAAAAYHspOGQIWSk4PKICAADA9lBwyBCi4AAAAGB7JUnyrNC74QzDv\\/GV8YhHVAAAANheSZJ8e1BwyM6mW3C02woOAAAAtkeSJM8OCg7Z2XTOt8l2+2UBAAAAtkOSJN8RFByys1FwAAAMQbTFsDO2+vn47KAnSZLvDAoO2dl0zrdmq\\/3SAABAeZaXl6NVifPcurycrGS5m\\/gCiQZl2L++vWazsVw\\/7iuf0anbbktXcv0tt1ROnjpVXZ\\/8+\\/PkP+bWtZ+pz4ixouCQIaRzvjVaVnAAAJSi0m5\\/RbXZ\\/HeN6embW9Ozr27Nz7+6Obfwuqm5xTe0Zxff3J5ffHNrsZNbphYX35jlp6YWsn+fJftxr82Tff2aZjc3t+YXX5X92Fe2s2Rf\\/0SWm9oLiy9vLSzcmOWl2Y99ydTcwo9nP8+Lp+bnT2V50dTs7I\\/mac7O\\/rtO5uZ+JMsPd48LK\\/nh1tzcC1szc\\/+2NTPzQwNyQ5YfLDk39LL6\\/3P9f8e\\/WUmj+8\\/5f3P+3\\/7C3q\\/tR\\/Jf58qve2q2Mw4\\/lo9L9u9e0ppbeGmWG1tz8zdln0c+hq\\/ojeurm\\/MLN2c\\/5rXNmXz8536qOTf\\/hsmZuTc2Z+ZvmZyd\\/eksPzs5Pf3vJ6dnfm5ievqt9ZmZt2d5W+fYnnnbxPTMW7Pv\\/\\/nJ6dl\\/35ie\\/ZnJmdk3NWfmXt\\/IP\\/u5uRubs\\/M\\/lv+3NmZnX5CdE\\/98cmrqnzWbzesbjcZ3TTSb31prtb6h0W4\\/uX3Z\\/Je39+17+OTk5IHQbC5MHz48ffC66ybCyZNJsCqEPUDBIUNI9xEVKzgAALbfrbfemlQnW2\\/Jvnwwy+ksZ1bl7CY5UzCnZWAudSw3+5wuJX0+m+ih7JgnPz8eyHJflnuyfCHLXVk+G6Lo\\/0ZR9EdprfaBSrX+C3G1emM6MfGvJxqNZ03Mzj52\\/qqrrrr2cU89cP2pU5MBdhEFhwwh3YKjqeAAANh2J289Va01Wu8OnRvcaOVC\\/2Iu+Nf\\/WNnhRN3kz5Vs64X3Bf9\\/o2hDBvzYvBD5Yoiiv4zS9Pertfp7klrtJ6uTkz\\/cnF34h3P79z9mcXHxynzlx+HDh+vhVIgD7CQFh+x8egVHS8EBALDdTt56a7XWaL4ndP8Gf9gXfrJ306\\/gGPT9+bmWrxC5P8tfRXH8sbSavqM1N3fD\\/OWXP+nqr\\/zKh5\\/sPuYCpbKCQ4YQBQcAQFlO5QVHc0rBITuZ86s\\/wpoVIA+FKPpCFMd\\/GiXJ+2r1+ptrzeb3ziweeNyRI0cWr7\\/++kqAbZQkyT8KCg7Z2Sg4AADKkhcc9ebU\\/wgu8GV3ZN1qj0758aXs+Pu1yebrpxcWnvPwL7v2mhMnTjSz71\\/ZzBS2Jkm+Kyg4ZGfTLThaCg4AgG33A697Xa3eaL0vuMCX3ZUN+35kx7PZ8YEoiv8iSpIPJ7Xam5szM9fPzu4\\/dtVVV7UCXCoFh+x8FBwAAGXpFBxNBYfs7kRRtHJcv7lpvpfHnVGU\\/Hp9svmimcWZxy0sLOw\\/fvy4x1m4sCT5x0HBITsbBQcAQFme3ik4mu8NLvBlb6Xf5qV52XF3FEWfrExMvKY9O\\/vUr3r2s6cCDJIk\\/zhScMjORsEBAFCW7gqOqd8INhmVPZ4Nr62NorvTNL2tWq\\/\\/WKPdfsq+I0cWw6lTXkXLOUmSfLeCQ3Y4nfOt0Wq\\/LAAAsL3y18TWp9p5weECX0YtK5uU5l8\\/GKLod6r1yRcefeTxI8vLyyubk9qkdIwlSfI9Cg7Z4Sg4AADKkr9FZbI9\\/evBCg4Z0USdTUrjXtkRPZR936eTSvUXq43Gd1x+9OjBwNhScMgQouAAAChLXnA0ZmffExQcMh5ZvWfH2ShNPzw5NfW8K44+8kj2z9VgRcdYSZLKP1FwyA6nc741W217cAAAbLdewfHfg4JDxiurXkEb3xfF8R8ntdot7X2XP\\/nqr\\/u6RmA8VCrPVXDIDkfBAQBQlltuuaXSmpl9d1BwyNgm35g0WXmE5Z4kTd\\/dmJl51uyBA1ecOHEiDYysOI6vV3DIDkfBAQBQlk7BMTv7X4OCQ8Y6UX7s3ehGZ0MU5as6fq\\/ZnHr+tdd+zUJgJMWVyvcqOGSHo+AAACjLLbd8rNKamX9XUHDImCbq5dw\\/d141u7Ipabg3SZKPTDSb33\\/ZZZc9LASvmR0llUrl+xQcssPpnG+TrZaCAwBgu93ysU7B8V\\/CuYIjGvbFn8huyrkNSbP82exlB5\\/7zOuvnwxdNiTd4yqVyvPiSMEhOxoFBwBAWW67bTlVcIhsnnxVR+g+vnJvlCR3TEw0\\/vllD3\\/4wwJ7Wl5wRAoO2dkoOAAAytJ7REXBIXJROffoyukoiu5ozMw8+8AjHjEf2IuiSqXy\\/R5RkR2OPTgAAMpy23JnBcevhnMX+AoOkQtkqbtPR7SyouO97dmFf3j8mc9ceXSFvaFTcOSPqEQKDtm5dAqORqv9sgAAwPa67bbb0tbc\\/DuDgkPkUrPyatl87tyTVCr\\/YWpu7jHHjh2rBvaCvOD4AQWH7HCs4AAAKMup225L23OLCg6RradzwxJFUf6Y111prXrTw44fvyyw250rOIKCQ3YuVnAAAJTltk7BsfArQcEhUjQrj62ciaLkQ\\/VG47uuvPLKdmC3imIFh+x8FBwAAGW5dXk5ac8t\\/nJQcIhsV1ZumE8nlcovTh84cO3JkyeTwG7TWcGRKDhkZ6PgAAAoi4JDpJSs3DSfyfKptDpxw\\/6jRxcCu4lHVGQYUXAAAJSlV3C8I3Q3TFxWcIhsa5ai7g30mSiK3jc1u++rg01Id4vuW1RiBYfsaHoFR0vBAQCw3fKCY3p+\\/629t0EsKzhEtjf5vhxxHOc3NfkmpHemtdoLTp46peQYvk7BkSg4ZGfjLSoAAGXpFBwLCg6RHcjKjfSXoiR5x2S7fTwsL0eBYckLjn\\/mERXZ4Sg4AADKkhccM\\/P7f0nBIbJj6b1tJfxFa27um3obkCo6hqBSqTyvW3BECg7ZqSg4AADK0i049v1SsAeHyE5mZdXAXXGavmT+iisOBCXHjqtUKt9nBYfscGwyCgBQlk7BsbC\\/V3DkF18KDpGdSm8lx5koSd4ze+josezrOLBjFBwyhCg4AADKouAQGWpWHlc5E6Lojyanp78hsGPiSuV784IjUnDIzkXBAQBQFgWHyK7IStFxZ21i4gWHDh2aCZROwSFDiIIDAKAsy8vLsYJDZLiJomg5juKlOO6UHPcnSeXnrrr2WvtylCyuxB5RkZ2OggMAoCwKDpFdl3wunk7S9L\\/PX375IwKlie3BITufXsHRUnAAAGw3BYfIrk0+Jz+8\\/9ChLwuUQsEhQ0jnfJtUcAAAbD8Fh8iuTedGKIqiT07Pzz\\/x1KlT3rCyzeJK5XlRUHDIjkbBAQBQll7B8YtBwSGyW7MUovDpyZmZZwSvkd1W+QoOBYfscHoFhz04AAC2nRUcIrs+3RvwKPrURLP5zSGcSAPbIq5Uro9DpOCQnYyCAwCgLJ2CY58VHCJ7IPkc\\/Wy12TwZTig5tkWl8k8iBYfsbBQcAABlyQuOWQWHyB5IfiOe5PP08\\/XJye\\/OjkmgkCRJvlvBITucbsHRVnAAAGy77gqOfQoOkT2Rczfjf1lvNJ5z\\/PjxSmDLkiR5TrAHh+xsFBwAAGXp7sGx7xeCgkNkD6VTdHx+dmHh6wNbliTJPwrnCw4pJ7tgvuyqKDgAAMqi4BDZk1l5hewnLjvyt48HtiRJkmeHVTfj2XiubOi69p\\/XfX2h5D92fS72fzvo59nK\\/77fz7fx+7rZrp9\\/1VtpluLuf\\/uw58pui4IDAKAsCg6RvZveDev\\/nplZfFxgKx6d5U1ZXt\\/LLVl+Osube1\\/n\\/+6NWd6Q5aey\\/GSW12V5bZbXZLm5l1evOuZ51eDEeV65Kr3v2+x\\/08kFft5zeeUF\\/l2eV\\/TyE9n\\/d56bsq9fnuXGLC\\/r5cd7efGqr1\\/SS\\/bv4xu7\\/\\/tOXtH7+W\\/ujU8+Zj8TouiD2fFs2AVzZRdFwQEAUBYFh8jeTXR+pcEd+6448sjApYqyVLNUeqn2SWVV0gFJRiDxFrP651gZj3zcatXW9Ddmxwet4lgTBQcAQFk6BcfivreHzkVXfrPkQlRkD+ZslCS3z19+5SMC7BJpvf7E7HBvsBfH6ig4AADK0nlN7OJlnYIj8ry0yF7O2ZAkH2nNz18VYBdIJyYemx3+JnQL9GHPj92STsEx0W7fWGhwAQDYaF3BsazgENmzWXlc5Tcuu+yyhwUYsjStPz47fMnqwI3ztKHgAADYfgoOkVFK50bydFKpvP3w4UdPBxiiNE2fkB3uU3CsiYIDAKAsq\\/fgUHCI7PVEKxuPPpRWq6ey+Z1voglDkabpE7PDAwqONVFwAACUpVdwvC0oOERGIt15HOc3lJ+vN6a+PXTfagE7rreC434Fx5ooOAAAyrJmBUd+czT8iz8R2ZZ0VnLcOTE7+9UBhmBtwREU6N0oOAAAyqLgEBnNxHGcr8rKXx9724ErrzwUYIelafo1QcGxPgoOAICyrHlEJSg4REYsndc\\/x0nylgMHDkwG2EG9guM+BcfaORkUHAAA5VBwiIx2uvtxhHtqExPPP3XqVBxgh6RpPS847lVwrImCAwCgLKsfUell2Bd\\/IrKtyW8qu\\/txNKennxRgh6Rp+vjscG+vZFu20WgnCg4AgLKsKziGfeEnIuWkc1MVJcl7H\\/3oE9MBdoCCY\\/BcVHAAAJTACo6Luxgdgwx7nKXk5HtxZHkgrVZvOnjddRMBSpbWu4+oKDjWRMEBAFCWvOCY6+3BEdzonkv+rHgv2U1hd6PGlTHq3SieS+juX9JJGJDN\\/l2\\/H3uhn2\\/1zxldKH3+ewf9OjbJ0D8T2Zbkn+WD9ampbw9Qsl7BcZ+CY8McVHAAAJRh9SajwY3sufQ2w\\/tClKa\\/HOL4lhAnb8yOb87yM71k3xe\\/KcsbsvxUltdleW2W12S5uZdX9\\/KqVXnlqrxiXX5iVVb9c3pTLy\\/P\\/jnPTef+Xej8PK\\/Kjnlu7uW1vbwu+zW8Pssbs7wpy09neUuWn8+Sr9r5pSy\\/kuW\\/ZXlfltuzfCjL\\/8zyZ1k+FzpvQAhnwgXKlmF\\/XnLRWSm3Pnrg2LFDAUqk4Bg8BxUcAAAl8BaVtYmipLtyI9+UMQqfPHjNNZcXH+U9Iw4nQhpmZtqhVjsaKuGrQxKemX3\\/92d5VZZ3hG4J8r+y3JPldHa+nA0h9FsBMvTPUjbNmaRS+VmPqlCmlYJj5S0qCo5OFBwAAGVRcKxNFMXnC458JUOjsS87RkXHeQTkY5BmyW+IF0O1enWoJt+Uff2jobsi5HeyfDH0X+0x9M9V1iaOO3+jfu9Ee\\/Zb1n\\/QsF0UHH2zUnC8vNjoAgCwwaqC46yCI0\\/cO3YuyD\\/eWFzcV3SMx0ASJsNlIQ0nsq9\\/MMtbs\\/xhlrtDXnhs3ONjF3zOEvI5H0UfOnDkyBUDPlcoRMHRNwoOAICy9AqO\\/xgUHL2sKTg+oeC4ZHGWepa88Hha9k\\/5Rfzvhc6bFJQcuyz553A6rVRuDkeP1gZ+orBFaZo+ITvcr+DYMO8UHAAAZVBwrE0Uot4YdJbwf7KxsLC\\/8CCPt7jRaOwPSfL3Qhznm53+QZa\\/Cave4hJ2wec+rumN\\/53N+f1PvMDnCJcsTdP8vHpQwbEm9uAAACjL6oIjDP\\/CbxelW3CEhYaCo7jze5gcW2jWGrWnZd\\/zqyHfsyNaWdGRj7ebn2EkiqKzIUl+\\/dCjHjWz2YcIl6perz8pm9cPBqu2VkfBAQBQFgVH\\/\\/T+ZvuTwQqOcuzb1wiVyvE4jl8Uuq+lvT94fGUY5\\/nKuf5AZWIif1uODXXZNmm34DgdzOvVUXAAAJRFwTEokUdUdkir1ZoLcXhe9uXvhm7RcbZz0x25KdrB5I8L\\/c7hxxxzvrNt0nr9ayMFx4a5FhQcAADlUHAMSm+TUQXHTkmyXB6S5Huy4weyPHD+8ZVhnwujn95+KA+m1dpPhGPHqhf1icEFpPX6k6MQnTm\\/B4cEBQcAQHk6Bcf8SsGR74FgH4RuvEVlaA5OzWbfPjfL+7N8IZx\\/dMVNUnnn+8o5\\/7mJiamvvqjPCS4grdefEvJXRdtkdHUUHAAAZVFwbHoR+nEFx9DEs7OzU9VW6+9nX38iKDh26pxfiuPkl06ePGUVB4WdLziCgmPdPFNwAACUYO0jKgqOVekWHI2GgmPIaq3WI0Ic5zcDnwm918uG4Z8fo5p8bO9OJie\\/KdhwlILSRuOpkYKj3xxTcAAAlMEKjk0vQj\\/ebDYXi40w26U+0\\/qa7PDBLGd6JYeio4T0xvb20GrNX\\/SHA330Co58fycFx\\/msFBwvLza6AABsoODY9CJUwbG7RNnnsRDHcf460z8OK29bGf65MlLpjel9SbX6bZfw2cAGaa32dQqODbGCAwCgLN6isulF6CcUHLtTZXLy2uzwrixfCvbnKOf8j6L\\/sm\\/fvsbFfyqwloJjwNxScAAAlKO7gmNRwdH\\/IlTBsXvl+0NMx5XK87PjXUHJUcb5f9fE3NxXXvxHAmv1Co5V81LBETyiAgBQHgXHoEQKjr3g1Km43mo9PvvqtiwPxXH2uUXDPndGIvn5fzau1l+cHZNL+kygJ63VnhYUHP3mloIDAKAMCo5BiezBsXdErcsvnwtx\\/MYohAciKzm2I0tRFOdvrPndw49+9PQlfyIQugWHFRwb51ZQcAAAlGPtJqNDv\\/DbRVFw7DWzs7NTcRy\\/IPvyL8OqR1aym\\/RdcD7tyeTj96XW3Nw3XuJHAR0bV3BIUHAAAJRHwTEoCo69KqlW8xvyO4N9ObYjS1GSvvPEiRP10N33BC5aWqt9fTAHN8ypoOAAACiHgmNQFBx7WDoxMfHYEEUfzJfHR8GrZAskH7vPTczOXnfpHwPjTsExcE4pOAAAyqDgGBSbjO51jUbjUdnhN6MQHgpusraafB+OpThNX3TpnwDjLqnVnh7MvQ1zKig4AADK0Sk4Fm0yujEKjhEQTczOHsyOvxY8rrLVdMYtipL3H37Oc+qX\\/Akw1hQcg+dUo92+scjYAgDQh4JjUBQco6Jer1+ZHX41CuHB4Gbr0hN15sJftxYXPabCJVFw9I2CAwCgLAqOQVFwjJL9R48uhCi8J3TPczdcl56lOKm8IZw8mWxh+BlTCo7+cykoOAAAyqHgGBQFx6hpzc9fFaLot6IoOhtFNh69xOTj9b8mJycPbGnwGUsKjoFzScEBAFCG7iajCo6NUXCMonpr5vHZ4dPerHLJycfrbL3dfspWxp3xVKvVnhGGf+7utthkFACgLAqOQVFwjKi0NjmV\\/63yn\\/dWcuyCc21PpFMIpdXqy7Y27IwjBcfAuaTgAAAoQ\\/cRFa+J3RgFxyiLK5Xrs8O9HlW5+ERRvBSi6IPXXXfdxBaHnTGj4OgbBQcAQFnswTEoCo5RduD48cmQpq\\/Mvnwo2CPgopKveMmOd1Xm5h6ztVFn3Cg4+kbBAQBQFgXHoCg4Rl3rwIH5EEXvz1dxWMlx4fTG6Eyc1v5Vdoy3Ou6Mj17BsRSUiKuj4AAAKIuCY1A6N3MfV3CMtqRW+4bscL+C48LJ9yvpjFMUvTMsLDS3POiMjVqt9nfDLjh3d1kUHAAAZVFwDIqCY0zUs+Sva3wg+Fvmi0k+Rn8SpusP29JoM1YUHAPnkIIDAKAMCo5BUXCMjXo4lH17e+jOASXH5snH54u1RuNpWxtsxomCY+AcUnAAAJShV3C8NSg41kXBMUaiyXb7K7LjpzyqcsHk43M6rlZfstXBZnwoOAbOobzguLHI2AIA0IeCY1AUHOMmraX55pm9VRzRcjfDPg93ZfJ9ON5z+MSJ+tZHm3Gg4BgwfxQcAADlUHBsehH68WZzn4JjTDQajf3Z4XejKORvVVlWcPRPb5XLn4dW66rsGG19xBl1ecER7YJzdpelW3C0FBwAANtOwbHpRejHFBxjJapOTn5jdvzrYC+OPukWPr2C46GkNvmMrQ8140DB0TcKDgCAsig4Nr0IVXCMozh+e34Tbz+O9emuaumNy1Kcpj+Sj1ahsWakeUSlbxQcAABlUXBsehFqD44xlKbpY7PDXcEqjnVZs4Ij34fjP2XH2tZHmlGn4OgbBQcAQFkUHJtehH5MwTF+jh07Vo3T+DXZlw8GJceGRJ0NeDslx4dDmG8VGGpGnIKjb2wyCgBQFgXHphehCo4xNTU19beyw\\/\\/xmMqm8+Mz9cX2lVsfZUadgmPg3FFwAACUQcGx6UWogmN8VeKl49ykAAAgAElEQVQ4fm12PKvkGDg\\/7q412k8tMMaMOAXHwLmj4AAAKIOCY9OLUAXHGGs0Go\\/KDp8NHlMZND9OhzQ9tdXxZfQpOAbOHQUHAEAZFBybXoQqOMZbGsfxG7LjmaDk6D9H4vhtx48frxQYY0aYgmPAvFFwAACUQ8Gx6UWogmPMpfX647PD3d3XxsbDPid3W\\/LNRr1KmYEUHIPmjYIDAKAUCo5NL0LvCAqO8TYz0w5R9N+yr5aiKBr2Obnbks+Rv6rVWlcVGWJGl4Jj4LxRcAAAlGFdwWEZ\\/tqL0LzgWCgyvux91YmJb84OX7LZaN85cm9lYuKriowvoysvOKLhn6e7LQoOAICyKDgGJVJw0HHl8ePt7HB7HMfmx9p0NhpNqtVvKzK+jK7eCo6l4M+W9fNGwQEAUAYFx6AoODgvTuMbovM3J7vg\\/NwV6dyoxXF8Q6HBZWQpOAbPGwUHAEAJFBybXoTeEfbvV3AQJiYmvjI7fDGYI2vmSNR5k0r6qkKDy8iyB0f\\/eZNnst1+WZGxBQCgDwXHphehCg46ZvLNRkP4tWCOrJkjnX1Joug\\/Z7+RRIUGmJFkBUf\\/eROs4AAAKEen4JhXcPSJgoM1qtXqt2aH+2w2umGefOTo059eKzS4jKRarfaMSMHRb84oOAAAytArOH4+KDj6XYQqODjn2HXXzWaH\\/6PgOJ98LLIb2D9qHzo0U3B4GUG9gmPo5+kui4IDAKAsecExreAYdBGq4GCNOI7fHoXOYxlL3Ru3aNjn6VDTK3vuDDMzj8yOHlNhDQVH3yg4AADK0tuDQ8HR\\/yJUwcEaSaXyndl9\\/OkoWpkr8bDP02EnH4f7QpI8Myg4WCcvOMLwz9Hdlk7BMaHgAADYfgqOTS9C72h6TSznRdkN29Hs+CehO1+Wx30FR+jOk7NxpfJ9xYaWUZQoOAbNGW9RAQAog4JjUDpL7z8aFBysdvx4Jfv2zVnOhBCbL93kr4p9dQgn0mKDy6hJPKLSf74oOAAAymEPjkFRcNBfUq3+g+zwN1GIl9y8dZLPlfeG2dmpgkPLiFFwDJwvCg4AgDIoOAZFwUF\\/tVbrEdnhzzubjVrFkScfg983V1gvqdWeHoZ\\/fu62KDgAAMqi4BgUBQcD5CsVoug3os588crYXsnz2TAxcbDw2DJSFBx9o+AAACiLgmPTi1AFB\\/1UQxy\\/Ji84osgKjt6bZO6uNptfVnhkGSm9gsMcWRsFBwBAWboFx7yCo\\/9F6B2h1ZovMr6MpqSafHMUwkNRZAVHbwXHA2m9eaLouDJaFBx9o+AAACiLgmPTi1CviaWvynTjmuzwWQVHnk7B8VBSrX5T0XFltCg4+qZbcLQUHAAA207BselF6B0eUaGffVdf3cgO77cHR1juvk0mOh2S6ncUHlhGSlJLFBwbo+AAACiLgmPTi1AFB4PF8VuCebOcv00mCuF0Nh7\\/tPCYMlLygiMa8\\/nRJx5RAQAoi01GN70IvSM09ys46Cuu1Z6XHc6EMZ83vYLjTIjjFxceVEZKWku\\/Poz5\\/OiTTsEx0W7fWGRsAQDoQ8Gx6UXoHSHYZJT+0kYjv3l7KIz5vOkWHNHZEMc\\/W3hQGSlpquDoEys4AADKouDY9CJUwcFA1UbjUdnhi8G8We7uRRL92qlTp9Ki48roSNPa04L5sT6dgqNhBQcAwPZTcGx6EargYLDJycuybz8TzJvlzptUougD4diJZtFhZXQoOPpGwQEAUBYFx6YXoQoOBmu3Z7JvPxrMm86bVEKIfi\\/MXn6w6LAyOhQcfaPgAAAoi4Jj04tQBQeDHT5cjyuVnwvmTa\\/gCJ8NlckvLzqsjA4FR98oOAAAyqLg2PQiVMHBZqI0TW8I3bkz7PN1yMn34AhfDGn9RMExZYQoOPqmW3C0WgoOAIDt1i045hUc5xKvvghVcLCppF5\\/dna4L4z53Imizq8\\/G4fa04uOKaMjTWtfF7rnxnLUOU+ioZ+ruyArr4l9ecHhBQBgPQXH+qwtOFotBQeD1ZvNJ2aHvw5jPneyG9f81\\/9ACMm3FB1TRkea1p6aFxydciMoOHrpFhwtBQcAwLZTcKzPSsHRuWHLN5BUcDBQfWbmUHb40zDmc6dXcDwU4vh5RceU0dErOM5G2e+nCo5zUXAAAJTFHhzrs3IBvlJwWMHBYO1Dh\\/I3qfxh6MyfaNX5M17pFRxnQohvyo5x4YFlJKRp\\/Smh92eLguNcegVHS8EBALDdrODY9CLUHhxs6vCJE\\/XscHswd5Z6+Q9ZKkXGlNHRKzjOhHPzQ8ERzhccNhkFANhuy8vL0fTCQv6qSwXHxotQBQebu\\/VkEiXJO3srGMZ5\\/vR+\\/dF\\/zo61osPKaEjrCo4+sYIDAKAs3YJjUcHR\\/yLUHhxcUJwkb1BwnCs43psdJ4uOKaMhrdefHBQcfeeKFRwAACXwiMqmF6EKDi4oTtMbFRznHlH5RJaZgkPKiEjr9a\\/NDqeDgmPDXFFwAACUIC84phQcq3LuAjwfi4+0Wq25QgPMyEvr1VPR+Rv8XXAOD\\/XG7dOT8\\/MHio4poyGt158UOgVHpOBYO08UHAAAZbCCY31WXhPbGYsPBwUHFxCn6atD9\\/GMcZ8\\/+a\\/\\/c6FWO1J0TBkNaZo+MTs8GKzgWD9PFBwAAGVQcKyPgoNLkr8x5DfG+RWxq5LPmS9Um81HFh1URkOapk8ICo5+80TBAQBQhm7BsajgOJeVgqPzt\\/EfUnBwAXGWX+7uwWEFR5Z70nrzCUUHldGQ1utfkx0eCAqO9fNEwQEAUAYFx\\/qsWcHxoTA1NVtogBl5cRq\\/TMFxbs48kFQnnlV4UBkJadopOO4PCo7182RpstV6WaHBBQBgI4+obHoRquDgguI0\\/mFvUTk3Z07Hae1fFx1TRkOa1h+fHe4L5sb6eaLgAAAog4Jj04tQBQcXFKfxixUc53I2Tqs3FR1TRkOapnnBsWoFh4TzBcdLi4wtAAB9KDg2vQhVcHBhcfyTCo5V8yapvCn7fSUqOqzsfWndCo4+6RYczaaCAwBguyk4Nr0I\\/WAICg42l1Sr35EdTofhn7O7IUshit517NixZsFhZQT0Cg4rONbPkW7B8eNFxhYAgD4UHOtzbhO8fCx+W8HBhVQbjUdlhy+Ezjkz9q+LzefNH07Mzh4sOq7sfQqOgXNkaXJqWsEBALDdFBzrs\\/o1sdHtod2eKTjEjLpa+0j27WeC+bPcG4O7qtXq3yk2qIyCXsGx6jWxEs4XHC8uMrYAAPSh4FgfBQeXqF4\\/nH37Z8H86c2bcG92Y\\/uEYoPKKEjTznmg4FibXsEx9WNFxhYAgD4UHOuzuuAIHwjtQwoONlefflj27ad658wuOIeHmc7jOWdDtfqsosPK3pemaV5wPBj82bI6vT04pl5UZGwBAOhDwbE+a1Zw\\/FaYnp4uOMSMuInZ2Suywx8rOFbmTViK4\\/hfZUdvUhlzab1+Iig41mflEZUfLTC0AAD0o+DYmKibfCzePz19WMHBphqHD+\\/PDr+bZal37gz9HB5i8jFYitP05dnXcdGxZW9L6\\/WvjaIof8OQP1tWzZHQLTh+pNDgAgCwUbfgWFRwrMqqguM3reDgQg4eO5a\\/aee3g4Kjc\\/MWRZ0VHD+TfZ0UHVv2trRWe2p2OBP82bJmjuSZbLdfWGRsAQDoQ8GxMasLDis4uJB9V1\\/dyA7vDgqOczdvIYrekx2rBYeWPS5t1J4W\\/NnSd4402u0fKjK2AAD0oeDYmNWPqFjBwYUcv\\/76Sna4NctZBce5fPzA8eOTBYeWPa5Wqz0j+HNlfVYKjhcUGVsAAPpQcGyMgoNLcfLWk0mI458LVnCsvoH70zB7+cGiY8veltRqzwwrq3qGf17ulnQLjunZf1lkbAEA6EPBsT4rb1HpFRxeE8sFZHMoCkn8pmD+9NJ5k8rnQ73+5IJDyx6XVKvfHBQc69MZj+bc3A8UGVsAAPpQcKzPmoLjN9vttoKDTeUFR1qr3BzcyPXSKTjuTyr17yw4tOxxSbX67cG8WJ\\/OeLTm9z23yNgCANCHgmN9FBxcump98qXB2yJWz53TcRzfUGxU2esqtdo\\/DQqOfvNjaWpxUQEIALDdFBzrs6bg+K2g4OAiTHSfp38gmENZovx4NsTx28LRo7WCQ8seFler+atQFRxr0xmP9v7931JkbAEA6EPBsT5R7xh3C46g4ODCpvbt+7bs8KVgDq3MoXwc7piaOjhbbGTZ0+L45qj7yJJ5cT6d8ZjZd+CZhcYWAICNFBxrE0UrBUfnovzDrVZrrtgIMw6mr7jsCdnh7mAOrSQfh8\\/Wpqb+VqGBZY+LfzaK8rK48\\/vpqt9fxzndwmf24MGvLzq6AACso+BYm5UL8O5FefidMDl5WbERZhzMHjp0LDv8dTCHVpKPw4Nprfa0QgPLXveL2e+pq1ZwxMM8J3dJuuMxt2\\/f1xYcWwAA1lNwrE0UxcvR+YvQT4TQXCw4xIyBhYNHjmaHO4M5tJLOTVylXvemiPH2rvz31POP\\/lnBsVJwTC8sPKHo4AIAsI6CY23OFxyxR1S4aAeOHLkiO3wmmEPL3ZvYeCmbR0txnL6m6NiyR504Uc++vb27gkOxsSrd18TOzDyu0PgCALCRgmNtOgVH528cO2PxkdBqzRcbYcbBviNH8pU+n+otxx\\/6eTy8RJ3HvHpZClH0ruKjy57Ufbzvj4I\\/V9anU3BMTE19VYHRBQCgHwXH2qwvOFoHDig4uKCZ48fb2c387ys4ouW1byKK7ggLx5rFR5g9p1a7Kvv2L4I\\/V9anU3BMTk09psDoAgDQj4JjbdYVHPkjKgoOLujw4cP1EEW\\/vXZDxXHM6oKjMxZ3VRqNawoPMHtPpXJt9u3nw1jPh77pFhzt9pcXGF0AAPpRcKxNn4LDHhxcjEoURe9WcGwoOB5KJia+tfDoshfle0zcE8Z6PvRNPh4PNGdmHllgbAEA6EfBsT7nbtDysfiQgoOLlIYo+hUFx4YshTi+JTtWC40ue9GzstwfzIeNcyKEu9qLi1cWGFsAAPrpFByLCo6Niazg4FKkcRz\\/QnZcsg\\/HmuRj8b4s7SKDy54ThTj+wex4Ovhzpd+c+IMDj3iExx8BALabgmNQIis4uBRJUqm9Pig41icfi\\/9bq9WOFhpd9po0xPGrQvfPlWGfg7stZ7PfLd53uPsaXQAAtpOCY2AUHFyKuDrZ\\/NHQ20AwDP\\/83S3Jx+KetNl8UpHBZc\\/Jb97fHsyFfjmb1mrvPHnrrUmB8QUAoB8Fx6B0\\/hb+g2FqarbQADM26q3W9wQFx\\/rkY3E6pOkPFRlb9pzFLB8O5sK6dPZ3OtOYnr25yOACADCATUYHRsHBJalNTn5DdngomEfr51G+0Wi+P0laYHjZW\\/5Olv8XzIU1iaI4G4\\/o\\/vlDh55baHQBAOivt4LjrUHBsS5WcHBp0nrnMYx77MGxNlH395U\\/mT1w4IpCA8xe8vQsDwZ\\/pqydC1E2HlH0xYUrrnhCodEFAKC\\/vOCYUXD0Sa\\/gCAoOLk5zZuaR2eHTkXm0Jr3C50vVyclvLDTA7CUvzHImmAvrk4\\/HX+0\\/dOjLCowtAACDKDgGpXNT9tsKDi7W4sMfvi87fFzBsTbdZflhKY7jVwSPqYyDbAqEd\\/SKLXNhzVyI8rcsfergNddcXmiEAQDob13BMfQLwN2TXsHhERUu0r6rr26EKHpfMJfWpHNT17nRjT6S\\/bP5NPLaM9k3f+BRrX5zIc7nw0cPHDgwWWiIAQDoT8ExMN2Co925WIcLOnHiRBrH8VuCpfmD5tNdlXb7ywsMMXvDU7LcHcyBfnNgKUnT\\/5odK1sfXgAABlJwDErnbx9v7\\/1tJFyUuFb7F8Hmiv2Sj8eDlVrt+wsML7tfkuXHg9clD5oDS5VG41XZMd7yCAMAMJiCY1A8osKlS6rJP8gO9wY3d\\/2SP6byP2ZnZ6dCd58GRk87yweCgmPA+R+W6pOt79768AIAsCkFx6D03qLiERUuQdqaeGx2+FwY+vm7+9Lbk+HzoVL5igJDzO52TZY7g3KjX\\/IxuX9yZuYZWx9eAAA2peAYFAUHWzAxcUX27ad6b0twk7cq596qEVeeX2iM2a3yVTk3BI9oDUo+Jn8xffniNVseYQAANqfg2PRi9IMeUeGSdM+XDwVL9PukV3BE4VeDR1RGUX7u\\/2bwZ8mgZOd+9Mmj1\\/5\\/9u4EXs6rrh\\/wme3ua5KbpEnapmna0gilkGKpFbiWRSoWQQygLBUVEAVxAQQUiAJ\\/BQTEgogKIohgAQGRspQdZBPZLCIIFFkKFKS0ULo3\\/3PuzG1u03lnuzPzzsx9ns\\/n27lN7rznvO+8c3Pf35z3nNstdXyEAQBoTIEjK7U5OIICByvSvBHNL0x2754IxeJLgwJHvffU6iiOr4\\/Pzp7Y9FgyXEqle8X\\/\\/jA472+ReN6n3FCZmvr7AwcPjq3nMAMA0IACR1ZWCxxuUSFdu5XODcViK7dWFOL3\\/X4hvp\\/conKL91R6TMfkuniMnhcfyy0cT4ZDei1fERT26qZ2y9o1s\\/PzD1\\/HMQYAoBkFjqxYRYWqU5eXF+LFybtXRmYcOFBq9v2lycn7x4cfKnDc4j11aE2R46sxe5odS4ZEde6Z9JoqcNTJys+CQuGynccff9Y6jjIAAM0ocGTGCA6S4sTs7Lnx8QfxAuVtYceOqWZP2LJz54nxQv4rChwN31vp8UHNjiVDoRyKxT+Kj9cGxY265\\/vKCI5i8cs79+7dtY7jDABAMwoc2b+UBgWODW9mZnuad+Mjheo58dXJycmmFyhLy\\/tm4sNHg4u9zPdWtfhTfFUw2egoOD7mGwp62ed7Sqlcfs+mvXvnOj\\/MAAA0pcCRFZOMEsLU7Ox9Cmn0Rm3uiOnFxVNaeFqhWCqZaLRBahfDX1w46qhjWzieDLTio8NNRav8z60BzMrPgcrk5PMPtHCLGwAA66DAkRUFjo1ux\\/79U8Vi8fxC9b2xcvE2Njn5Cy09uVz8\\/fjf64MCR90UCsV0XK4OxcqjglEcw2t+ZYTb+2qTaOZ+Xg1oVs71zdu3n9v5gQYAoCUKHFlR4NjgCqWpqXPi42WF6rmwUqgoFotPaeXJpamxn4sPV9eeOwDn80AmHZsP1y6SGT6FUKqcGywN2yQrxZ+v7N1\\/6+M7P9QAALREgSP7l9KgwLFhbdq0Kd0r\\/9ZweOh9NcXia+Jjsdnzx2Zm9sWHS4MCR6OkY3NlaXz87GbHkwE0GXYGc820cI4XbiyNjb397LPPHu\\/4WAMA0BoFjqwocGxklUrl3PhwZbj5xduNhRA+vbB790Kz589sT5OTFj6kwNE0afnMNx04cGCs2TFl0BR\\/Pf7nGnNvNDm\\/47+tY5OTf9rxYQYAoHUKHFlR4NioxsfHT4gPF4VbfjKd3iPfqszPn9ZsG\\/v27RsrFosvUuBonNrF8Q9KY2P3D+biGB7j43vjfz9l7o2Wzu9rZjZv\\/vnODzYAAC1T4MiKAsdGVSwW\\/yRkrwpxXfyG32hlO2OTkw+I59GRo0BkTW66\\/adQeHt8nG3luJK7SszzY25Q4GiadH5\\/Y3x2y0mdHmwAANqwUuDYsu0fggLHEUkXXoV\\/C3MKHBvJ9PTKMrBfyhp2X\\/3z4stDmoGgibldS2kkyNdDQYGjSdLx+X5pbKy1FWrI2\\/6YS4JlkFtI4cZCufyWk848SfEOAKAfagUOIzjq\\/GK6UuAIVnjYMKqreaSJRdMn04fqfTJdK3x8Kmap2eb2P2J\\/JX7\\/u4MLwaapHdePhcXFY5odV3JTCNPT2+PjBaH2HgkDcO4McNI5fd3k\\/OzjDxw4UOrwmAMA0A63qGRFgWOjKVUnFr0+NChG1C7ELwljY7ducbMvDgocTVMsrhzX64vF4uNbPK7k449Ck\\/eI3JR0jC5d2rf3dp0dagAA2qbAkRUFjo2ktqzrRfECu+GFW63AcWXLt1NUKo8JChxNU5vLIR2jz05u3ryzpWNLPxXK5fIZ8fF\\/g3O5lay858uVyoVn\\/8VjLA8LANAvChxZWZ1kVIFjA0jLvr4+tHbhtrLsYyiW0siMpqt+lEqlnwlpYtLqpKV1b3uRlGJ6zx2qHtvii8LevS4KB8uemM8FS8K2mpUCx8TMzDM6O9wAAHREgSMrtQKHSUZH24EDpWKx+Lvxqx+G1j+Zrs4XMbtzc7PNTywsHBsf\\/mt12wocme+3Q7Xjk47TZaXx8Z9tdmzpky1b0gSZr4i5PmvyXblF0nG6em5p6eyOjjkAAJ2xikpWFDg2gvLExF3iw6WhvWH36XuviM\\/+ydBsFMf+\\/ZVQXFl15YY229jIScvGviPs2uW9l7+ZUAzPio\\/XBOdvW+dwoVj4+PGnnLK1o6MOAEBnFDiysnqLigLHqDrjwIHJYrF4fqjePtJugSMtF\\/uE0MptKpNjDwjtjRDZ6EnH6ZpQLD4zPk40O770TDm+Br8THy83cqPt8\\/e6qbm5p8bHYicHHgCADilwZEWBY6Tt2jVZHh9PK3ZcWZvgstXzYuUCplBYuYhJS8qWm7Y1MbE7\\/vcLBZONtpPqrSpjY\\/drenzphbSs6cNivtve+2OjJx2nlYmKv33sXqunAAD0nQJH5i+q6ZfUD4V5k4yOorHJmQPx4YedfDJdKBRX54r43zAz08oQ9IlQDP8UFDjayeqomv+cmJjY08IxpptKpXPif78ZnLNtZuWcvbFQKr0\\/PpooFwCg36qTjCpw1Em1wGEEx6gpTszO3ik+fnbN0qRtnx8rz023nZTGfq6FNgvFSuUR8fHa4GKxvWNcWFlV5eVhaWmmhePM+hVCqZTO6a8budFJVkZv3DA2PfHE0MLtawAAdJkRHJlR4BhB09PTp8SHL4TuFBrSNl4W9u0ba9bu7OzsSSGN+FDg6OQY\\/ygUiwf3Wjq214qhXP7p+HhxcJ62ndoy0DeGQvjO4nG7TunkBQAAYJ0UODKjwDFaCvHi7cz4+O+heyuapG18K+bHWmi\\/UqxUXhAfr68NY8\\/7\\/B6SpNuBSul4XRWKxWcHw\\/57Jd2K98cxlxYKRednB6mNeLlucn722fvT6kkAAPSfAkdmagUOc3CMgEKoTN0+Pn46dHdOgdVt\\/WYrnZiYnUi3xvygesFu6H8Hx\\/qqmD+PWQiG\\/3dLOo5HxbwyuIVqXVkpDBUK3916\\/LE\\/0e6LAABAlyhwZMYIjlFRqZwW\\/\\/vpQqFwfZeXu6wVOAr\\/3FI\\/ZmaW4n8\\/VVgZwaHA0W5qr93VMeeZ\\/LdrTo15W8w1teOrwNF5biyXy+\\/etW+ffzMAAPJiktHsX1ZjPjQ3p8AxxEqhUrljfPx46N1qEOl989UQxk9qqT\\/lcroN4LouF1o2UtJxuy7mdTEnhzRvBJ1It1DcOeaTwUop3Tovr1rcuvVR4eBB5yQAQF4UOBr+wvqhoMAxtMrVCRPTUpc9PLfTSIzCjaFY\\/IPQwm0T04uLt4kP3wguKNeb9Jp+uXR4FRu3rLRqebkcz9cnxa++X5sY85DVUtadG4vl8ifPvPfdd7T9egAA0D0KHFkpGMExvCZKlcqvxMcvx3S8FGxrWbkwTNv\\/TMy2pj1Lkw8Wi\\/8UfGq+rlTnO6hN8losPj1MTu5qeuxZHdF0fswPV5dJVuBYd1bex1MLc09t9wUBAKDLFDiyUjCCYziNFSvjj4qPl\\/fxNpDUzjUhlO\\/ZSgdLY2P3iw83uE1l\\/SkcLhS9P5TLZ8XHpkv2bkDplontMWmU0SVBca3bScfyh0cff\\/StW35FAADoDQWOrNQKHNXlExkCC7sXFlY+zQ\\/he6ufTof+XeDcENt+bksdnZzcGf\\/72eAis2vHP77W6efXpSuvwfj4icEtK6vSz69Hxnwi5moTifYk10\\/Nz77sjAMHJlt\\/WQAA6AkFjqy4RWWYjKeL2mLxVaG6ykYeF3Cpzc+GiYljW+husTK+Msrkqpz6OqqpFppC+Fw8F34vvhZ7wsYsdBTDZDg6VAsbqUi7ep4513pwzhWKxf+93Z1O39fqiwMAQA8pcGT\\/4hrzYbeoDLiD8WJuYuInQ3qtQuj2MrDtni\\/XhlD6tdDCRfX+u91tPn7XZ4KLzi6mcGNagrdYHc0RX4vwuVAq\\/WrYWKOw0lLEvx7z+fheWC32KW70JivHdWxq6mVhYxbSAAAGjwJHVgoKHINuYWGhWCz+bvzq2yH\\/i7jVW2LeHjPXSveL5fIzQvV95+Kzy1lzK0YqdPx7TJoA8vSYUXs\\/pwvrzTF3iklLEH8qrMwHk\\/v7YSMkTXT7nc3H7jyrhdcJAIB+UODISrXAMTs7u3ldB5heKEwsLOwOhcLrwuGLudzPmdpF9ffK1RElTY1NT58S0iogA9L\\/UU2an6P22vwopMlIQ\\/jNmJNipkJaWaSqEAb\\/U\\/jV\\/qVJQ6dj9sc8LVRHL6V9U9ToX9Jxvm5mdvYlB88\\/aGJbAIBBocCRFQWOgbRr12QolX4xVD+pzvOWlFuk2pfC9fHrl8SMt7A3lWKplL43PWdg9mNEc+OaUR1pTopvxnwk5q9i0vm0vzZaq9jsRctJOp\\/S5Kn3jTkvVPv+nZjrgttQ8jmfioUvH3\\/aKVZOAQAYJAoc2b\\/AhupFhALHYCiF6enbhGrx4IpQu6CLF615nyf1zpvvxtyxlZ2anJu7YyiEb1rdor+vUaGWcDiXxXw05qUxvxKTbjs4OWZLqN5ylFbISKM9ejnKI227EqqjM9K8ISfEnB2qy7v+a8xXw8377JzJ6fyJuWF6dvZ5+\\/fvr2S8lgAA5EGBo+EvsanAMWr37A+f+fnFUCz+dvzqCzHXF4vFQb6wW5noMj6+IBy+\\/SHbjh1TxerqL4O8T6OVQhptc9N7fOX1WlNgij8HVybnvDzmGzFpIth0W8urY\\/40hJXz8KEhlO8ZH1PBLS35uzkshZn4OBGqBYpSRsq1v0+3xqQCxo6YtPrGXUN1FEna9p\\/H\\/EvMf8T8b8wPQnUekRsKNx+Fkv9x3Li5Ib5nv7T3dgvKnm0AACAASURBVLezcgoAwKBR4MhMdZJRBY787No1WR4fv3v86sIwRBMn1i5CPx+vd49pZTcnN206I1Qvpgd+3zZI6o2SWJt0S9EPQ3Vy24tj\\/jvmEzEfDNVz9YJQLVKkvKn2mEZgvC3mPTEfqz0nPTfNwZKKKdc2aTPvYyKh+t4uhMI1s4vzT47\\/dg76nC0AABuPAkdWqnNwzFlFJRdjY2P7Qij+Tfzy++HwSiNDcaFXK3CkgsyTQ2u3NBSKlUr65N5cHIOXxsWO6pK0Nxzx5zdkfH3k92T93dCc6xswNxaLhYtOOuWk4wIAAINHgSP7F9mYjyhw9NG+fWOhXE6jGZ4XVkZADPUFf+p3uqXm6FZ2vTI1dbv48NVBmjRVRG6W9N78weJRWx65vLycbjcCAGDQrBQ4tihw1Ik5OPpnLF7g3z4Uiy+LX\\/9fOPzp+DBf7K\\/sw9jY2M+1dAT27RsrlsvPCjetijFwk6eKbORU38\\/j42\\/+iwsuaGWFJAAA8qDAcWRuurC0ikqvTUzsKVaKvxG\\/ekfMpeHIIfuDt0JKO+fRjbXbnF67MjKlBZt27twVqsvfxucVDylyiAxGaiOrLtt2zDFpQlgAAAZVrcCRVnFQ4FhJcfXr9AvtR2dnZ7es6wCzVlpJYksol+8SisU\\/iV9fFG45ueIAnAPduiiqLRlbDmmi1JYmJCxWKr8TH65zq4rIwOTG+F6+Znrz4p8uLy+nlXIAABhUtTk4VpepzPsXyQHIzUZwpNUOFDjWa8eOqdrcGn8aqqNivhdz\\/cqKBCO87OWapUjT6hmLrRyqrVu3bosPH0jFkdrzRSS\\/rPx8KlfKH7\\/rbz7UaD4AgEGnwNHwF9uPBiM42lUMW7bMhvHxvaFU+pn4\\/88IofDO+PidsDFXiUj7eXk8Fj\\/b6gGcmJ9Ow+C\\/uYGOkcigJr0Hr5jevPDQAADA4FPgyEpxZZnYsH1maV0HePgV6uRm4jlUCPPHLIZy+W6hWHxK\\/KN3x1xaKBQO1bKRChr1kvb9HWFpaabFY14K5eJzwuE5SfLuv8hGTHrvXTs5N\\/e8g+ef39I8OgAA5GzNHBwupG6WlYvyD4VtM1tDi\\/MnjKjStm3bpsP09LaJiYnj4v\\/fIeaBMb8b82chTaIZwgdDdVnXK8KRE4U6r1YKPPEEuip+\\/QehOg9JU0u7d28vlEpvjs+9wXwcIv1Nofaza3xq4oJ9d7jD9gAAwHBQ4MhMOh6f3HLMMfunjj56x+Tk5p1h06ZdYXIyZedKpqZ23JQwdVR8rGZ6enst20JImdkaZmqJ167x8XDCakIta79emf8jZrZBjtzGytdbq+3GpH5M3dS3HSv9DmFXCJNHT0wsHBsm5veMj8\\/tHZ+dPakyOXl6CGM\\/H0qlh4di8fHx+54e8+KYN4fq6h7\\/G\\/P9EAo3pALQ2jk0jNLIzppRLN+IOTG0aG7z3I+H6kgYIzlE+psbC8XiJcecetKZAQCA4VG7ReUfgwuoW\\/yCG9Kn7oXC\\/8THz4XqCIUvxVxcy5dr\\/\\/\\/FWv6nli\\/Uvndt\\/ruN1Hve55qk3nNX+\\/PFWj+\\/VOtz6vtXakkFi6\\/GfC2EQrr4Tku1XhGqow2uC7ccidEoeb9eg550jK6P+euYqdCaSrFcflp8vMYxFulb0oir6zdt3\\/q45eXlcgAAYHgocDT5Rffw7QHtXOyPSvI+\\/iOWlXPphzH3DS2a3blzc6FUSCNojOIQ6U\\/SbWGf3rRz564AAMBwWSlwLG17dXDxJB0k3X6Rdx+GIWnJ1+rSrytFjveFXbsmQ4vm5uZOjw\\/fDt6jIj1Kuo2suHor2dd37d19l7Cx514CABhOqcCxSYFDpC+pXUBdFcLKajPjoRX791eKExOPCCvzn3ifivQihcLKylnXTM5O\\/\\/7KylAAAAwfBQ6R\\/qZW5Lg6lMt3D20oVUp\\/G25+25SIdCG199R15bGx1526fOpCAABgOLlFRaTvuTENhw+hcEFYWGj5YmpuaemEUCh8oraqSt77IDISKRaL1ZWgSqV\\/O+7k444NAAAMLwUOkf6nUCilx6tDsfik+DgWWjS9devdQnXlGxPBinQnN4RC+OqmHVvbGlEFAMAAUuAQyS3pPfetMDFxVmjV8nJ5fHryt+NXV7lVRaTz1CZITu+h7y8sbT73wIEDpQAAwHBT4BDJNel2k\\/eHycmjQ4v2n3POVHly8rlhZbJS71uRDpPeOz+YmJt6+q4zWl\\/VCACAAWaSUZH8UhuFkYocLwpt3Koyu3Pn5kKp9MZQnXQ09\\/0QGbKsvO\\/GJiZe+pDHPW46AAAwGhQ4RHJPeu9dFkqlh8XHYmjRntve6sRCufzvxWLxkNtVRFrOyooppXL5jccff3zLI6cAABgCChwi+adWoPhaCGO3CW0Ym5h4UHy4rpBGcoSb5hUQkTpZHTFVKpfev3zOOVsCAACjRYFDJP\\/ULrxS3hAzG1q1e\\/fE5MLC78WvLjOKQ6RhVoobhXLpIws7d942AAAweqoFju0KHCI5Zs2KDtfGvCBs2dJykSO+h0tj4+PPil9ercghUjfV4kax+Mmd+044NQAAMJoUOEQGKul9+KOY3whtOPXUUxdK4+PnxS+vCd7LIkcmFTc+vfWYY86MXxcCAACjSYFDZJCSJgwtpvfixaFc\\/qnQxsXYrX78xzeXKpVXheooEO9nkcMjNz6zdceOVNwAAGCUKXCIDFxW5+P4fExbqzyc+sv3WSiNjb2qkC7qLCErGzs3FovFVNz4xGlnnnlSAABg9ClwiAxk0vvx+pi3xuwObdh0\\/PFHlyqVV8Yvrw7e17Jxc32hVPrQ5u3b7xAAANgYFDhEBjarIzlevWnTprnQhjPvfe\\/ZUqXykrC6hGyhYAlZGekUi8WVx9pEu9cVSoV3nXDaaXsCAAAbR63A8ZqgwCEyiEnvyzQS4x9nZma2hjYcc8wxi2Pj48+OX\\/4gXfQpcMiop1bcuHpsYuzvd524a2cAAGBjqRY4thnBITKwKdyY5tQoFoupWDEe2nDgwIGx8tjYU+OX3425IZiXQ0YstdFJq6OdLi+NV\\/7yVnf98c0BAICNR4FDZOCzevH2fzE\\/Hdq0b9++sYmFhYfGL7+aLgSLxaL3uoxMagW7dE5\\/Z3x6+vH7lpdnAgAAG1OtwOEWFZHBTXXC0ULhLRPz88eFzpQWjlq6c6lceleojeQYgP0SWW9Win+lcvl9m3fuPCsV8wIAABuXSUZFBjO1eTPS+\\/KqUCy+ut05OOo5+eSTjyoWi6mg+aM1w\\/pz31eRdrM630Z5bOwtu0+91e4AAABGcIgMZmoXcFcWK+U\\/CwsLC6FL9u7dOzc+Pf178ctvhMO3v+S+vyItJp2vN8T3x7cm5mefdOL+\\/VsCAAAkKwWOLQocIoOSNEdGbZ6My8sTY8\\/cctJJs6HLDh48WJyfn79bKBQ+Xwjh+loxJfd9F2mQG0N1VFO6xerrizt2PDD9+xUAAGCVERwiA5XVC7hvTc7NPWbbKadMh94pbDnqqP2FUunt8etrg58BMthZmYumVCi8d3Hr4plh\\/\\/5KAACAtWpzcChwiOSYNUtdXl8oFi6aXJi97\\/LBg+XQB1uOPfao4tjYM+OXXyuE6rwflpKVQUg6D9NoppWiX6HwrfL42LN2HH\\/80QEAAOqpFTjODwocIrlldULRUrn83hPuePuT458VQv+ktkrzmzefFS8i\\/ytUR5H4eSC556aJcAvhK7PbNv9c\\/LoUAAAgy80LHOlTW5\\/civQrhcOTfP6gVKm8cmnPnhNCfgrz27YdVyqVXhS\\/\\/r8QCgodkkvWrPDz3fi+ePGm7dv3xX+r+ln0AwBgGClwiOSWldUgYr5Znhh74j0eco9ezrfRsvPPP780Mz9\\/v\\/jlRaHaPyutSL+yeq5dn0YTzWya\\/4Xl97ynL7dqAQAwAlKBY2Fp+2uDAodIP1Odb6NQePvs4kBOmFhc2rXrhPTpefz6qqDAIb3PTaM2xqYmnrHtpGOPi19bJQUAgNYpcIj0L6tD7+PjFcVK6SXHnnzyUWGAnXLKKdOV8fFHFkL4ZMw1q3OFhAE4ljISWZ3UNo0UuqJQLv3r5h077tavCXYBABgxtQLH64ICh0ivs\\/oJ9acn5+fv3+MlYLupOL91656xiYk\\/iV9fEtyyIt3L6u0on5hbXHzQMbe5zWLo7wS7AACMEgUOkd5mzaiHNGrjHxaWlk4NQ+jA+eeXpufn714old4Q\\/\\/f\\/Coc\\/fVfskBZTWPt+uC4UCl8qT4w9c2nPrjS5rsIGAADrs1Lg2Lz99UGBQ6QXWR3t8KWJhdlfDtVlLof1Qq7a7wMHSpuWlu4Zv\\/pASPOIBAUOaTmr74crKpPjz7\\/DPe58dKga1vcEAACDpFbgMIJDpEspFGqfUlcv5C4tVSp\\/Pb2wcOqBAwdScWNUFLZt27Z1Ynri3LivqdCxMhFpbd9XEgbgtZD83wth5byo3YoSwtcq4+MvWdy6eOYZZ5wxGQAAoJvOP3R+aWFpqxEcIt3J6vD7a2O+NDkz84B0a0cYYfvOOGPT5Nz0Y0MhfCbu+9VpwsjVyVRD\\/q+H5PQ+CCvvheJqYeOS0ljl7446ac9pB84fqUIfAACDZKXAsVmBQ6Tz3PSeSRdzaTWI7xZLpfPmdi3tDRtlmctDobC0e\\/f26bm5BxcKhffHP7kyrJmM1IiOjZKbClvpfZAmD\\/3c2MzUH2\\/avv3H9u7dOx4AAKCXzj90qLSween11V9MFThE2k1ttEK6oLs8fv220tTU2bt3L0+EDWrnrW61eWxm5gGlcumC+L+XxmNy3eGJJVd\\/zuT\\/uklXszJao7bc65WhUPjM2MTEwS17dp548ODBjVHkAwAgf9U5OJb+WYFDpO2sflp9XcxnS1MTv7pnz575YMLEJB2DqcVjdvxkZWLspfHrbxUOHy+3roxWVl\\/TH4VC4QNTm+YfvuXoo3fE\\/y8HAADopzSCY37TSoHjBgUOkZZyeJnLEL5cHBv744mt83vCwQ1yO0qb9h04MDa\\/ZcvtyxMTTyyUS2lC0stCdcTLjebqGL6sec1Srk5LvZYqlb8bn5299759+zYFBT4AAPKSChyzi1veEFYuOBQ4RBpk9aIuTZr4nWKp+Bfbjj32uOCCrmX3eNxDpheOOurOlfHx58cL5S+F6mSsNwajOwY9N59bI4QrCqXS+6cW5x+1Z\\/\\/+Y+q81AAA0H+pwDG3uOVNofqL6yEFDpFbZs2n1l8rVSrnTc7NnR527bLMZYf2P+IRlfmtW\\/eMTUw8KB7P18Q\\/+kLMtek2lmIoHiqEtPpG8VA1+b\\/+GyWF9JgmhC0U02N12d\\/qvwkrk+cWSqX3xdfsyXObNt1x+\\/btS0FxDwCAQaLAIVI3a0cUpFtRLol52dzmzXc4dOiQi7ouOnjoYHHbScceV5ya+vV4Uf3GeMl8caiuwpJGChw5usMoj96e6yujNAqFQjr2V8d8M+aDxXL56Qvbtyyfc845U01eTgAAyE8qcEwvbv6XoMAhsprVC71r44XeRfHi7vmTm2bPMGKjD5aWZpZ27dpbmpj4pWKp9DelUundoVi8OFQvthU6upI0KmbldsQbCzefByUVNS4vFAufKBaL\\/1gZH3\\/U\\/FFbTpubm9sUlk0YCgDAEFgpcMwpcMiGzsoF3uGlTMOlpXL5LROz0+ceddxxx1rmMieHDhXu8ZCHTO85+eQTpjfP321iaurJpUrl1YVi8RPxby8phMJVwQiPls\\/vcNN5XqyO0gjhh\\/F8\\/99SpfzeyuTkC2Y3bXrYpp3b7njr00\\/fdvDQIec8AADDZ6XAsbD5zUGBQzZkbrYixHeLpdKrNx+786y9e\\/eOB\\/MLDJr0epRPOvPM2eNPOfnWM5sXH12qlF4e\\/+y\\/Yq4ItZVZ6mQAzrO+Jqvok261uiwexU+UKpW\\/XlhaOnffmWces3t5eSL+uYIGAADD7+B73lOeXlhcU+AQGcWsLdwVVj7FLlSLG2k1iH8rj409fW7btjsu\\/\\/Ivp4s9hsTy8nJ5aWlp+\\/yWLadNzE79arFcflqxUnpZoVD4YCgULg5r5vI4fCtGGsFQGNZCyC36fMRtJiu3VsV8L\\/7Zf8dz+z2lSunFxbHyE2e2LD5wcevWU7bv3bt04MCBUrdeAwAAGBi1Ase\\/BgUOGencdFG7uszl5fEC+MMTs7MPu8297rUYGCm\\/fPDgxOYTT7zV2PzM\\/cbHJx9TmZp4cbzYvzC+5p+Nf\\/2tmB+FaiEgjWpI58MNa9Ko+JE1OqJbadTG2j6mfl8T84OYr8f9uqhUKl1QmZx8bmVi4lfnt269+97TT9\\/1iI+\\/pNLVAwsAAIOsWuDYpMAhI5nD82oU0vn9\\/Xgh+MHyxMQzJjfPnb6we\\/dCMDR\\/Q0gjPbadsm16btfcpon5+ePmt8yfNjM\\/c9bk\\/PwvTM7OPr40Pn5esVI5P5RKF4Ri8ePxPPlyfNq3QyqEVSc4XS2EHJ7Lov4okPVktfiWCi+pcPGd2I+vhDTnSKn0tkK5\\/PrYz78dm519Uur3xMLMnacXFm47sbh4zNyuXZt27N8\\/ZWQGAAAb2kqBY37xrUGBQ0YjR845kIoan4oXiX89PjV19uytbrU5QIaDBw+W997udktLu3adkIoH5cnZM6c2L\\/zczOL8Iyfm5v5wbHz8OaVK6W+LldKrQ7n0unhu\\/UuhVLggjQ6JeW+hXPpAzIdK5dJHYj5WTfmj6f\\/j338g5n0x7ywU0nMKb4zf+9rSWOkVlfHKeVMzU380s3nzb80tLj5wYnb2TpXp6VNTP44\\/5ZStj3jEI4zEAACAZt6TChxzi28LChwypCkUiocKK0teVpe9DNVP3L9SrFT+Znxh4d6bdu7cFf\\/fpKF07lA8d9LoiOXlctgfKmFvPJ92hzRfy+S2bduml5aWZjZt2jS3uLg4v7B7YWH+mGMWj8zinsX59D1btmyZDfE5YVeYXNnOvn1jabsroy8OHTryHHXOAgBAq1KBY2p+8e1heCbZkw2dNFlo4cbDCTcUCitzEXy7UCh8slKp\\/OXY9OQvzu1aOmHv2WenogYAAAAbQbXAMa\\/AIQOZQqGwklBdKSKN1DhUWxEljThKkyu+bXxx7tFLu3efmm63CocVgk+\\/AQAANg4jOGTAUm\\/yxTTx4hWhUPivUrn82vLE2NMnZ2fvOz47e1Ia8n\\/olsP6AQAA2Ghqk4ymAkfW8oiyoXPTrSBdz00rnBRutv10HqZVJK4MaRWLQuHC4tjYM6eX5u65Y9++Yw4dOmTVEwAAAG5pZZLR+fl3BgUOqZvuFjgOL9saVicETeddWorzfwql0tvL4+PPqoyPP2piYeanJiYmjksjNIKlXAEAAGgmDe+fnFt8dPzyvJgXivQo6fz6i5g\\/j3lOzMGYx8Q8uDwz81MT27Ydt2nv3rlw8KBiBgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADDbF\\/Mz8c8Keb5Ma+MuSDmjTGviDkv5mDMQ2N25NNFGjgz5nExz4t5ecy\\/xLwh5sUxT415eMzZMZty6t+omoo5LeYhoXqcXxjzmpi3xry69v\\/pzx8csz9mMp9uAgDAcPqtmEPrzOUxX4j5t5g3xbw05hmh+kv89v7tys28PKx\\/v1rNF\\/qzS7n6iZgnx7wjdH6M0nnxgJjpPvZ7uUGfbtXHftTzR6F+v77co\\/bShfWbMtpslHTx\\/eB1tPuADtrsZ356HfvWinvFPCfmIx3270Mxz+pDP1t1asju66dz7Nd6PCFk79Pv5tgvAADa1I0CR7N8MlQ\\/zd\\/bn11a8fIu9r9ZRrXAcVLMM2P+J3T\\/mL0+5kF92IflBn3YKAWOtJ+vzmirnXwx5pEdtL8RCxxnhWpB77Iu9\\/XSmL8K1RE4eWlU4Ei5W35d60g55ushe38UOAAAhkg\\/Chxr895QvbWh117ex30atQLHT8a8LuaG0Ptj99WYx4beDcVfbtD2Rihw\\/E5GG+vJxaG94tRGKXCUYh4YOh+p0W7eG3PvmEKX+t+qZgWON\\/a5P+v1S6Hx\\/ihwAAAMkX4XOFbznzH36+F+vbyP+zIqBY49oXpxksf58O2YR\\/dgn5YbtDnKBY4018O\\/Zmy\\/W0nzrsy00JeNUOC4S8xFOfX\\/Y6E6X0e\\/NCtwpMLonj72Z73S8Wu0PwocAABDJK8Cx2reHLO7B\\/v18j7uwygUOA6GfM+D1bw7dPfiaLlBW6Na4EhD7judK6XdfDBmrkl\\/RrnAsSVUCz1570NKmiC2lYLTejUrcKSc14d+dMOdQvN9UeAAABgieRc4Uq6I+cUu79fL+9j\\/YS5wHBPz\\/tDZfn825lWhuurDU2r5s5iXhepIkE92uN10Pvxal\\/ZvuUE7o1rgeHnGdusd50+F6mt1Xq0\\/LwrVVT3aOSfSJJizDfozqgWO5dB47oZGSbex\\/EU4\\/L5Zm\\/TnH+1wu+ln0e063J9WtVLgSBNPD8MKPOeH5vuiwAEAMESyChwXh+ov8O0kLSv5h6F6wfStjO02ygu7uF8nd9D\\/ZnlFRr+HtcBxl5jvhNZfn6+F6kVwmkSw2af2q9JFzs+G6ioSX2yjrZRnrXP\\/kuUG2x\\/FAsfPZGxzbS6ofV8zR4Xqz4ePt7jNLFvD+t97H85o98IubLuTC\\/HHZvQnK\\/8RqvOhnNFmO2fWnvepNtt7YAf71KpWChwpT+hhH7ohjRS7LihwAACMlKwCx391Ydsnxjwm5j0ZbdTLW0LvJpxcr7SiyKgUOO4TWn9N0nwpD+1Su3eIeW4bbb9kne0tN9j2KBY4PpuxzZRLQvV178RTGmw39fe0dfS5FW\\/NaPvVPW63nj\\/J6Eu9pMl6z+pSu6mw+OY22n5Ul9o9UqsFjjS6pdyjPnTD80Jr+6HAAQAwRHpZ4FgrXUz+fUZbRyYVRPpxL3m7RqXA0eotA6mwcU6P+rAjVEfstNKP9VzELjfY7qgVOH4lY3spXwnVguN6\\/Hi45cisd8YsrXO7rRiUAseLM\\/pxZP455jY96kO6BeUtLfbjMT1ov9UCR0q3bz3slnRLVbqNRoEDAGDE9KvAsSr90t\\/K\\/eXpF\\/hSj\\/rQqVEocKRPk1v5pb5fw8tvHZqvYpDy3A63v9xgm6NW4LgwY3tpGP5t19vZmrSd79W2+\\/zQv0\\/oB6HA8aSMPhz52v1cn\\/qTljdtZQ6Qbi\\/L3U6B42NdbrtbUtGi1X1Q4AAAGCL9LnCselxGu2vzVz3uQ7uGvcDxYzGXhcbH\\/F0xe3Po2x826VfKr3ew3eUG2xulAseWjG2lPLsbnV0jzQtxbpe32UzeBY4HZbR\\/5M+rRpOt9kKaPyRrbqC1uWMX22ynwJFyZhfb7oZizJeCAgcAwEjKq8CRpNEcjeYMSHlkH\\/rRqmEucMyH6mva6Fg\\/L7feVaVJaq8Ijft4jza3udxgW6NU4HhoxrZSju9GZ3OWZ4Hj9jFXZrSf8qOY+\\/ahH42kn5ONJsxMIz22dqmtdgscecyT0siB0F7\\/FTgAAIZIngWOJN2\\/3+iWlatC94bXr9cwFzjeEBr\\/Ev\\/Y\\/Lp2M+m1Tqu1ZPUz\\/d3mNra33GBbo1TgyLp9ol\\/v417Lq8CxGPM\\/GW2npHkc7tTjPrTq3qHxe\\/zCLrXTqMDx3Yw\\/P7pLbXdDu8tiK3AAAAyRvAscSVpy9JMZ\\/Riki7RhLXDcLzT+Bf6P8utaXWkSxUafmL+2jW0tN9jOKBU4np+xrfd1paf5y6vA8ecZ7aZcG\\/PTPW6\\/Xc1upXlYF9q4bYPtPyfjz7t9m1Sn0q069fqX5grJGk34O7n0FACAjgxCgSNJn\\/A1+uT+D\\/rcn3qGtcDR6BPof8yxX43cPzS+UDu7xe0sN9jGKBU4Xpmxrbd0paf5y6PAcauMNlfTq2VY1yvr51TKxTHT69x+owLH6aH+z\\/E0Me3UOtvthn8I9fudCkNZt\\/AZwQEAMEQGpcCR3DmjLyk\\/iDkmhz6tNYwFjnTrSdYxTRfSC\\/l1ral6nwZ\\/LrQ338FynW1spALHJ7vS0\\/zlUeB4fUabKW\\/qYbvd0GhlovUWixsVOPbHPDnj73qxZG07doX685Sk+UnSakAKHAAAI2CQChxJo6UY\\/zanPq0atgJH+qT2myH7eLY7YWce\\/iNU+3pJzCM6eP5y2BgFjmdnbOuKrvQ0f\\/0ucPxERnsp34\\/Z1qN2uyVN4JzV\\/zSaYnEd2240B8dpobqyS71bzNLKJcV1tLteWe+RJ9X+XoEDAGAEDFqBoxKy74VOn77lsYTpqmErcDRaevWVOfarHSfHPDV0Pqx+OWyMAsfvZGwr5axudDZn\\/S5wvCujvZROlivOw5+F7H14+jq226zAkbwk4+\\/vs4521yPdHvO9Ov1JhZhNte9R4AAAGAGDVuBI7pXRp5QX5tivYStwNBq9cVSO\\/eqn5bAxChz3zNhWypu70dmc9bPA0egWjI\\/1oL1emY35Vqi\\/H99ex3ZbKXCcnPH371xHu+uR9e\\/c2n9PFDgAAEbAIBY4kg+H+v26LFRHeeRhmAocaRLOrIuQ5+TYr35bDhujwDEWqkuWZu3r\\/bvQ3zz1s8DxJxltpZzTg\\/Z66fdD9r7cs8NttlLgSN6e8T39XvY73RbzpTr9uCHc\\/GeAAgcAwAgY1ALHz4fsX6J\\/Iac+DVOB42Uh+\\/gN+vwB3bQcNkaBI\\/mnjO2t5vR19jdP\\/Sxw1LsYThnGCVtnQvb50OmcRq0WOM7J+J6\\/67DdTt03ox9HThSrwAEAMAIGtcCRRmnUu2c6j1+Ql8ahIgAAGoxJREFUVw1LgaMQqhMh1uvrG3PsVx6Ww8YpcNw9Y3tr84vr63Ju+lXg2J\\/RTsrvdbmtfnl5qL8\\/l4bqz4p2tVrgSNv+XJ3vuSZmawftdiprPpW7HvF9ChwAACNgUAscyV+F+n37Yk79GZYCR6MVIH4px37lYTlsnAJHkrVc7NqkCSD7eYHZDf0qcDwxo52UYZ235mdCawWJVrVa4Egek\\/F9f9xBu53Imk\\/l03W+V4EDAGAEDHKB40DI\\/kV6dw79GZYCx1NC9nHbnmO\\/8rAcNlaBIxUuLsnY7tqk+TrS8pgz62irn\\/pV4Lgwo53PdLmdfmp0m8rvd7C9dgocWauXpMlPxztou12vyOjnw+p8rwIHAMAIGOQCR1q+L+sX6Z\\/PoT\\/DUuA4P9Tv50V5diony2FjFTiS0zK2Wy+pGJIu4Dpdhrdf+lXguCyjnb\\/scjv99pFQf79e0cG22ilwJM\\/N+N5f66DtduwK1dthWi2uKHAAAIyAQS5wJBeH7n3yuF7DUuD4RKjfz1fm2amcLIeNV+BIfilj21lJF31PjdnchbZ7oR8Fji0ZbaQ8oovt5CHdllRvvz7YwbbaLXDsCdUVS4783nq3iXTT\\/8vo4x9mfL8CBwDACBj0Asc7Q\\/3+dboCwHoMS4HjylC\\/n0\\/Ls1M5WQ4bs8CRnBWqE0m2U+i4IlQLYWkJ0WKX+tEN\\/ShwnJHRRspZXWwnD08I9ffr2x1sq90CR\\/LajO\\/\\/6Q7ab0XWrTHpZ+OmjOcocAAAjIBBL3D8Tajfv7fn0JdhKHDMhuyLj4fm2K+8LIeNW+BIjo15c0Y7zZL68dhQvVjMWz8KHD+b0UbKsV1sJw9pae2sfWv39e2kwPFTGd\\/\\/5jbbbtWjMtp7SYPnKHAAAIyAQS9w\\/Emo379eD2+uZxgKHI3mLTmQY7\\/yshw2doFj1U+G7Ak0m+Xbtb5u6UG\\/WtWPAsd9M9pIGbZVZ45055C9bye0ua1OChzJpzKe0+33YdbytM3aUuAAABgBg17g+L1Qv3+X5tCXYShwpAuxrIuP++bYr7wsBwWOtdI58N8Z7TbLD2KeHfIZ0dGPAkejVZuybmsYFvtC9r7dpc1tdVrg+OWM53R7AtdzMtp5S5PnKXAAAIyAQS9wPDrU79\\/lOfRlGAociyH74sMIDgWOVefGvCOj\\/Wb5bMz+PvRxrX4UOO6T0UbKsI\\/gSBN9Zu3b3drcVqcFjrRyybfqPKfRvBidyDqv79nkeQocAAAjYNALHE8K9fv3tRz6MgwFjjQxZNbFx6\\/k2K+8LAcFjkaODtXzut6EjM3y233sZz8KHHfLaCPl+C62k4fbhux9O73NbXVa4EielvG8J7XZhyxZ+5luaSw0ea4CBwDACBj0AkfWHBwX5dCXYShwJINwQTooloMCRytmQnWlja9n9Ckrr+hT\\/\\/JeReX2XWwnD43m4Di5zW2tp8CxLeaaOs9L5125zX7U87KMfv1aC89V4AAAGAGDXuBIFzD1+ndhDn0ZlgJHukCu18\\/n59mpnCwHBY52pYvBz4fWixzpvTjR4z71o8CxN6ONlJ\\/vYjt5ODdk71u7k8eup8CR\\/F3Gcx\\/cZj+OlG4jqlc8SbfFjLfwfAUOAIARMOgFjn8P9fv3whz6MiwFjqx70P81z07lZDkocHQifZqebmlqtdDxzzGlHvanHwWO1P9rM9r5\\/S62k4esn12XdbCt9RY4sp7\\/sQ76slbW++mPWny+AgcAwAgY5AJH+tSt3idyKb+VQ3+GpcDxolC\\/n9\\/Ks1M5WQ4KHOtRCdVbm74Tmhc5Ht3DfvSjwJH8Z0Y7r+lyO\\/329lB\\/v97bwbbWW+BI3pXx\\/Lt00J8kawLT9O9HqxPEKnAAAIyAQS5w3D1k\\/yL9kzn0Z1gKHI8K2cft1Bz7lYfloMDRDek2hjQCqFGBI03826tbVfpV4PjHjHbyWJa6W9Kyvlmv2Qs62F43Chz3y3j++R30J3l4xvZe2sY2FDgAAEbAIBc4nh3q9+2KnPozLAWOW4fsC5An5tivPCwHBY5uynpPruYJPWq3XwWO38hoJ+UnutxWv5wTsvfpfh1srxsFjrTa05fqPP+GUF3Sth1pdZTPZfTntm1sR4EDAGAEDGqBI\\/3SmrWiw1tz6tOwFDiSesO1Uz6XZ6dysBwUOLrtDSH7mH6qR232q8DRqDh4Xpfb6pd0e03WPi10sL1uFDiS383YxvPa7M\\/ZGdt5R5vbUeAAABgBg1rguEfI\\/iX6N3Lq0zAVOP4uZB+\\/H8+xX\\/22HLKPw23y69aKrCWQB73AsTk0Xk72+B602a8CR\\/LFjLa+3YO2ei3dWpT1On2gw212q8AxG3N5nW1cXvu7Vl2Q0Zdz2thGosABADACBrXA8b5Qv19Xhc4+deyGYSpw3DVkX4S8Msd+9duZIfs43DXHfiVZRajP59mpFj02ZB\\/Xx\\/agvX4WOLJG1qQ8vAft9dJTQ\\/a+PKrDbXarwJG8IGM7v93i82+V8fw0Uq3QZl8UOAAARsAgFjjultGnXl3QtGqYChxJ1ifRKbty7Fc\\/NboYe1CO\\/UqyVrb4eJ6datFMzPdD\\/f6\\/pAft9bPAsTejrZTP9KC9XkmTi6ZRJ1n70mmhuJsFjjTfxg11tpPm5yi28PyXZPSjk+KNAgcAwAgYtAJHKebTGX1KaWfSuG4btgLH48NgForasRxzYcwJHT5\\/d8g+Bk9af\\/fW5fOhfr\\/anTsgL1lLfV7Qg7b6WeBI\\/iWjvZS8bpFrV9bPq5S\\/Wcd2u1ngSN6Usa1mE6BuirmyzvO+F6rFnXYpcAAAjIBBK3A8IaM\\/Ka\\/LqU+rhq3Ake5jT7\\/sZx3Pe+bXtZakJUf\\/Oxzub5p8cK7NbaSC2bWh\\/v6\\/t1sd7cBtMvqU8pc59qsdWZ+e\\/2cP2up3gePOGe2tXkBv61G73XJyyO5\\/ynom2O12gSNrOfD3NHneUzKe98wO+pAocAAAjIBBKnA0uqhIuXUOfVpr2AocSaP5BL4ZBvtWlaeHW\\/b5azEPbnM7H6uzndXs6FZn23SwQZ+GZYTAH4b6\\/f9qD9rqd4EjeW9Gmynv6mG765UKmxeF7L6v95h1u8CRfCpje1kj9sZD\\/ZWirgmd\\/0xT4AAAGAGDUuBInzg2Wpnh2X3uTz0vDPX7NshLr6a5Ei4O2cf1Q6E6UmLQpPkxGhW77tXGtp7bYDtP7l6X2\\/KlBn36sXVsNxVsnrHu3rXm+aF+\\/z\\/cg7byKHDsz2hzNS\\/qYdvr8cbQuN\\/HrXP7vShwPDxje6\\/I+P5fafP7W6HAAQAwAgahwLEv5hsZ\\/UhJF+gzbW5zMeasUP3l9O9jjupCP8\\/P6N\\/7u7DtXvqF0PiCJ803UMqtd7eUhqxn3VaS8uY2t3evBtu6InTn3GjHkxv0p9PRD9Ph5qNC+rFCzOtC\\/X14fQ\\/ayqPAkWSt8rGaJ\\/S4\\/Xb9VWjc3yd2oY1eFDgajcjYWuf7s+ZpWs8cTQocAAAjIO8Cxxkx38noQ0q60L1ji9tK35eKEF+os52f7kJfv5LRx3\\/uwrZ77TWh8YXPP+TXtZtJ84L8IGT389LQ2fwHlzbY5t+uu9et2xmqRZWsvvy\\/Drb5q6F6687a7by3C31tJI36yZrf5YU9aC+vAkea8+VzGW2v5jE97kOr\\/jw07ueHutROLwocyTMytnnknBpZq2yt97YhBQ4AgBGQZ4Gj2W0IKY9tY3tnNdhOJxeOa53QYNvDMClkGgHTaHWalHeGzpeO7Ib7ZPRrbe7b4baf12S7v7KejrcojbL49yb9OLHNbTba3m91pdf13b9Bu+f2oL28ChxJumWoUVEq5bl96EeWdF69NqNfq7kkVItr3dCrAkeaO+O6Ots8clWUrBVuOv3ZsEqBAwBgBORV4Ph\\/Ge2uzUvb3ObmBtv67x7292Hr3Ha\\/nBQar6qyepxuk0Pf\\/qBJv1LWczvA9pgfNdh2Gil0l3Vsv5l0C9AFDdpP+fsOtvuiBttL+7u8zn7XMxayl7i9KlQnuey2PAscyQMy2l+bt4T+FwiPjfl4C327Uxfb7FWBI3llxnYfWfv7tPrLDXX+Ps1pU1xn2wocAAAjoN8FjvSL6sUZba7NWzvcfqPh5J1+op0++byswXb7PYfDejRbqSbl+6F\\/w+7Tp+MfaqFPL+5CW1lD4FeTbo15eBfaOVI6P97RQtvHdLDtY5tsN4086ObFbXJeg\\/be0OW2VuVd4EgaLWG9mlT4uVuf+pNGHTW69Wo1D+hyu70scNwxY7vp53ohZBf0ujFaSYEDAGAE9KPAMR\\/zmyF7Dosj84FQvfe9E41GAqSLyHZ\\/AU+3djS6DeA\\/Ouxnnlr5NDrlg6F6208vnBmqIxZa6cfrutTmZMwXW2gvfYrcrU\\/i0wSn9SZP7OZFVL3ldI\\/Mvdex\\/bX+uEk77axu045BKHAkf5nRjyOTVvPY26M+pCLAO1vsRy8uzntZ4Eg+mrHtrFsaj7yFpVMKHAAAI6BXBY5U1Ei3brwpY\\/tZScP4J9fR7s4m209L0e5vcVupyPK+Jtv7tXX0NU\\/pfvVWX5NU6EivZadFp1XpdU2fOn+4jbZfts42j3SHmCtbaDcVJdJ7o9JhO+ki8MIW2klJtzasZ3h9OVQnFW3URprb4O9iju6wjbSMc7P9ubDTHWjBoBQ4kudk9KVeXhWqE+euV5pn48Ex726j7d\\/oQrv19LrA0Wh+l3p5VhfaTBQ4AABGQFaB49sxT2kz6RaAdBHV6oXdkenW6gsvbKGtNMw+a3WWtMRsKyNOvtKl\\/ublp2K+G9p7jdISoOeG6jFqJs3F8BO170\\/LbTa6zade\\/mz9u1hXqyNYUv4nVCeQvF\\/MpibbTfv6+FAtWLS6\\/fRpdbtLINeT5hipt3pQvbwxVI\\/BUgvbfGjM21rc7q27sB9ZBqnAkTw+oz9ZSe+ztFrPz7TRRnqPPSRkL8fbKA9cz8410esCRyrYHbkqUFZS4W5XF9pMFDgAAEZAVoGjn0lzPvxiF\\/cp3V7w9RbbTpPTpYukVJz569B8xMba9GPljV7bHfNvobPXLa3M8LFQXdUgHbvVY5iGz3+jw22mpFuJHtHDfQ617XfSt6+GagHvJaE68WxaIrjZ6jRZ+VSoTozbLWn00n+22Yc0qWyaNyPNcfLHtcc06qqVW3n6eRE4aAWOJN2+9c2MfjXLl0P1Z00qXqSCbDr2fxWqxz7dEndJh9tNc1Wc2sudDr0vcCRPbNDG2ryqS+0lChwAACMg7wJHGhHQ6bD5Ru7Z4353suLFIGs2AWe\\/8p5QLbr0QxoK38rtKr1IKpLM92CftoXsOQx6lfWsbtOqQSxwJOl4vybk\\/75JSaPSujEXRTP9KHCk0VKtvDfP6FJ7iQIHAMAIyKvAkSbnbGe4dic6\\/ZS+WdIcEuuZJ2RQnRCyLyR7nXT7ymN7v4u3cNvQeOWdXuRJPd6ndJH72j7ty2\\/2eF9WDWqBY1UazdHv82g1aRWi2\\/Z+F2\\/SjwJH0mxC1\\/d3sa1EgQMAYAT0u8CRPrn+2b7sWdXDu9z\\/NCR6uo\\/9z0N6fT4T+nM+XBPz56G7t2q0KxUEXhB6v6+fCNV5OvrlyaH9OVZaTZrv4\\/T+7crAFziSNCFtKtKl+Yv68d5J88P8Uqgun9pP\\/SpwnNygnZT7d7GtRIEDAGAE9KPAkeZpSMu3HtenfTpS+kW5nbk16iXN6fGofnc8Z2l\\/PxJ6c06ki8AXxRzft71pLvUlzSFyRejuvqZz70F93I+10kSvaULMVicgbZY00uZ5oTsTo7ZjGAocq9LkoGnp3q+E3rx30pwvv92vnamjXwWO5IKMdtLcSetZeageBQ4AgBHQjQLH5TGfD9WlKtOEhX8Tqr\\/gp5n8m63U0E9pidB0Afud0Pq+pU\\/dfz1mIof+DooTY54a866wvvPk46E6WuOs\\/na\\/beniPa0eknVx1UrS++FpoXrsBkUaPfL8mItC+\\/uTVlJJK3rkdWvWMBU41rpLqBaE0s+R9bx3UpHsYOjvrShZ+lng+JmMdnpRdFDgAABgaKVix+NC9YL7laF6MZvmLUgrGaQVDVpZRnMjSrdzpOVlHxOqqz+kC88L1yQtQfqKmL8I1QuyXw39vZWhF9LcJHcN1bkz0qoXFx6RdO48K+Y+oXoB2mw52UGQloBNtzekQmRaOeX8UC1i\\/FOovgf+NOaRMbfPq4MjKP08Sbd\\/pUlZXxbzjnDLcyklvafS6Kb0HkvFwFG\\/JQ4AAAAAAAAAAAAAAAAAAAAAAACANvxDzJUiIiLStbw0AADQd2nlh\\/UuBSsiIiKH86oAAEDfKXCIiIh0NwocAAA5UOAQERHpbhQ4AAByoMAhIiLS3ShwAADkQIFDRESku1HgAADIwdNi3i0iIiJdy5MDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD\\/vz04JAAAAAAQ9P+1wRsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAL6JKIFTUgrE4AAAAASUVORK5CYII=\\\" alt=\\\"Imagen\\\" id=\\\"igyb\\\"\\/><\\/td><\\/tr><\\/tbody><\\/table><table width=\\\"100%\\\" cellpadding=\\\"0\\\" cellspacing=\\\"0\\\" border=\\\"0\\\"><tbody><tr><td id=\\\"iibsm\\\"><p id=\\\"ie5ff\\\">Prueba 1<\\/p><\\/td><\\/tr><\\/tbody><\\/table>\",\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[{\\\"type\\\":\\\"image\\\",\\\"src\\\":\\\"data:image\\/png;base64,iVBORw0KGgoAAAANSUhEUgAABDgAAAVGCAYAAAB7TwuKAAAAtGVYSWZJSSoACAAAAAYAEgEDAAEAAAABAAAAGgEFAAEAAABWAAAAGwEFAAEAAABeAAAAKAEDAAEAAAACAAAAEwIDAAEAAAABAAAAaYcEAAEAAABmAAAAAAAAAGAAAAABAAAAYAAAAAEAAAAGAACQBwAEAAAAMDIxMAGRBwAEAAAAAQIDAACgBwAEAAAAMDEwMAGgAwABAAAA\\/\\/8AAAKgBAABAAAAOAQAAAOgBAABAAAARgUAAAAAAADTyGbmAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAFXGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSfvu78nIGlkPSdXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQnPz4KPHg6eG1wbWV0YSB4bWxuczp4PSdhZG9iZTpuczptZXRhLyc+CjxyZGY6UkRGIHhtbG5zOnJkZj0naHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyc+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczpBdHRyaWI9J2h0dHA6Ly9ucy5hdHRyaWJ1dGlvbi5jb20vYWRzLzEuMC8nPgogIDxBdHRyaWI6QWRzPgogICA8cmRmOlNlcT4KICAgIDxyZGY6bGkgcmRmOnBhcnNlVHlwZT0nUmVzb3VyY2UnPgogICAgIDxBdHRyaWI6Q3JlYXRlZD4yMDI2LTA1LTA3PC9BdHRyaWI6Q3JlYXRlZD4KICAgICA8QXR0cmliOkRhdGE+eyZxdW90O2RvYyZxdW90OzomcXVvdDtEQUhHWXBzZmxSTSZxdW90OywmcXVvdDt1c2VyJnF1b3Q7OiZxdW90O1VBRU9OVndMYVdZJnF1b3Q7LCZxdW90O2JyYW5kJnF1b3Q7OiZxdW90O1RlY25vRmlicmFzIFMuQSYjMzk7cyB0ZWFtJnF1b3Q7fTwvQXR0cmliOkRhdGE+CiAgICAgPEF0dHJpYjpFeHRJZD44NGRkMzJmMy0yNzZiLTQ3ZjctYWZmYS04NTM0YmMzM2VhMDA8L0F0dHJpYjpFeHRJZD4KICAgICA8QXR0cmliOkZiSWQ+NTI1MjY1OTE0MTc5NTgwPC9BdHRyaWI6RmJJZD4KICAgICA8QXR0cmliOlRvdWNoVHlwZT4yPC9BdHRyaWI6VG91Y2hUeXBlPgogICAgPC9yZGY6bGk+CiAgIDwvcmRmOlNlcT4KICA8L0F0dHJpYjpBZHM+CiA8L3JkZjpEZXNjcmlwdGlvbj4KCiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0nJwogIHhtbG5zOmRjPSdodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyc+CiAgPGRjOnRpdGxlPgogICA8cmRmOkFsdD4KICAgIDxyZGY6bGkgeG1sOmxhbmc9J3gtZGVmYXVsdCc+MjAwMCAyMDAwIC0gNDwvcmRmOmxpPgogICA8L3JkZjpBbHQ+CiAgPC9kYzp0aXRsZT4KIDwvcmRmOkRlc2NyaXB0aW9uPgoKIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PScnCiAgeG1sbnM6cGRmPSdodHRwOi8vbnMuYWRvYmUuY29tL3BkZi8xLjMvJz4KICA8cGRmOkF1dGhvcj5EYXZpZCBBbHBpemFyPC9wZGY6QXV0aG9yPgogPC9yZGY6RGVzY3JpcHRpb24+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczp4bXA9J2h0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8nPgogIDx4bXA6Q3JlYXRvclRvb2w+Q2FudmEgZG9jPURBSEdZcHNmbFJNIHVzZXI9VUFFT05Wd0xhV1kgYnJhbmQ9VGVjbm9GaWJyYXMgUy5BJiMzOTtzIHRlYW08L3htcDpDcmVhdG9yVG9vbD4KIDwvcmRmOkRlc2NyaXB0aW9uPgo8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSdyJz8+6JVLDgAAIABJREFUeJzs3QucXXlBH\\/D\\/edzHzL137ryTzWZD2KRsG2GXNaIuIAQBEVrUVlNFtFItW6VKX7i2aCUisKw8FlAei0qrFNQtSq20FC2syMpredR3axUtoPtxLbC47DPJTM+5904yj3snyZw5c2fu\\/X4\\/n1\\/ObDaEzf+ef3LOL\\/\\/zPyEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAnPPkLB8V2eHcMTE19fwAAAAA2yJJTkYhPpt9dUZkB7PUaLVfHgAAAGA7JEnyrSFES9mXeZZFdiCd822i1boxAAAAwHZIqsm3KThkh6PgAAAAYHspOGQIWSk4PKICAADA9lBwyBCi4AAAAGB7JUnyrNC74QzDv\\/GV8YhHVAAAANheSZJ8e1BwyM6mW3C02woOAAAAtkeSJM8OCg7Z2XTOt8l2+2UBAAAAtkOSJN8RFByys1FwAAAMQbTFsDO2+vn47KAnSZLvDAoO2dl0zrdmq\\/3SAABAeZaXl6NVifPcurycrGS5m\\/gCiQZl2L++vWazsVw\\/7iuf0anbbktXcv0tt1ROnjpVXZ\\/8+\\/PkP+bWtZ+pz4ixouCQIaRzvjVaVnAAAJSi0m5\\/RbXZ\\/HeN6embW9Ozr27Nz7+6Obfwuqm5xTe0Zxff3J5ffHNrsZNbphYX35jlp6YWsn+fJftxr82Tff2aZjc3t+YXX5X92Fe2s2Rf\\/0SWm9oLiy9vLSzcmOWl2Y99ydTcwo9nP8+Lp+bnT2V50dTs7I\\/mac7O\\/rtO5uZ+JMsPd48LK\\/nh1tzcC1szc\\/+2NTPzQwNyQ5YfLDk39LL6\\/3P9f8e\\/WUmj+8\\/5f3P+3\\/7C3q\\/tR\\/Jf58qve2q2Mw4\\/lo9L9u9e0ppbeGmWG1tz8zdln0c+hq\\/ojeurm\\/MLN2c\\/5rXNmXz8536qOTf\\/hsmZuTc2Z+ZvmZyd\\/eksPzs5Pf3vJ6dnfm5ievqt9ZmZt2d5W+fYnnnbxPTMW7Pv\\/\\/nJ6dl\\/35ie\\/ZnJmdk3NWfmXt\\/IP\\/u5uRubs\\/M\\/lv+3NmZnX5CdE\\/98cmrqnzWbzesbjcZ3TTSb31prtb6h0W4\\/uX3Z\\/Je39+17+OTk5IHQbC5MHz48ffC66ybCyZNJsCqEPUDBIUNI9xEVKzgAALbfrbfemlQnW2\\/Jvnwwy+ksZ1bl7CY5UzCnZWAudSw3+5wuJX0+m+ih7JgnPz8eyHJflnuyfCHLXVk+G6Lo\\/0ZR9EdprfaBSrX+C3G1emM6MfGvJxqNZ03Mzj52\\/qqrrrr2cU89cP2pU5MBdhEFhwwh3YKjqeAAANh2J289Va01Wu8OnRvcaOVC\\/2Iu+Nf\\/WNnhRN3kz5Vs64X3Bf9\\/o2hDBvzYvBD5Yoiiv4zS9Pertfp7klrtJ6uTkz\\/cnF34h3P79z9mcXHxynzlx+HDh+vhVIgD7CQFh+x8egVHS8EBALDdTt56a7XWaL4ndP8Gf9gXfrJ306\\/gGPT9+bmWrxC5P8tfRXH8sbSavqM1N3fD\\/OWXP+nqr\\/zKh5\\/sPuYCpbKCQ4YQBQcAQFlO5QVHc0rBITuZ86s\\/wpoVIA+FKPpCFMd\\/GiXJ+2r1+ptrzeb3ziweeNyRI0cWr7\\/++kqAbZQkyT8KCg7Z2Sg4AADKkhcc9ebU\\/wgu8GV3ZN1qj0758aXs+Pu1yebrpxcWnvPwL7v2mhMnTjSz71\\/ZzBS2Jkm+Kyg4ZGfTLThaCg4AgG33A697Xa3eaL0vuMCX3ZUN+35kx7PZ8YEoiv8iSpIPJ7Xam5szM9fPzu4\\/dtVVV7UCXCoFh+x8FBwAAGXpFBxNBYfs7kRRtHJcv7lpvpfHnVGU\\/Hp9svmimcWZxy0sLOw\\/fvy4x1m4sCT5x0HBITsbBQcAQFme3ik4mu8NLvBlb6Xf5qV52XF3FEWfrExMvKY9O\\/vUr3r2s6cCDJIk\\/zhScMjORsEBAFCW7gqOqd8INhmVPZ4Nr62NorvTNL2tWq\\/\\/WKPdfsq+I0cWw6lTXkXLOUmSfLeCQ3Y4nfOt0Wq\\/LAAAsL3y18TWp9p5weECX0YtK5uU5l8\\/GKLod6r1yRcefeTxI8vLyyubk9qkdIwlSfI9Cg7Z4Sg4AADKkr9FZbI9\\/evBCg4Z0USdTUrjXtkRPZR936eTSvUXq43Gd1x+9OjBwNhScMgQouAAAChLXnA0ZmffExQcMh5ZvWfH2ShNPzw5NfW8K44+8kj2z9VgRcdYSZLKP1FwyA6nc741W217cAAAbLdewfHfg4JDxiurXkEb3xfF8R8ntdot7X2XP\\/nqr\\/u6RmA8VCrPVXDIDkfBAQBQlltuuaXSmpl9d1BwyNgm35g0WXmE5Z4kTd\\/dmJl51uyBA1ecOHEiDYysOI6vV3DIDkfBAQBQlk7BMTv7X4OCQ8Y6UX7s3ehGZ0MU5as6fq\\/ZnHr+tdd+zUJgJMWVyvcqOGSHo+AAACjLLbd8rNKamX9XUHDImCbq5dw\\/d141u7Ipabg3SZKPTDSb33\\/ZZZc9LASvmR0llUrl+xQcssPpnG+TrZaCAwBgu93ysU7B8V\\/CuYIjGvbFn8huyrkNSbP82exlB5\\/7zOuvnwxdNiTd4yqVyvPiSMEhOxoFBwBAWW67bTlVcIhsnnxVR+g+vnJvlCR3TEw0\\/vllD3\\/4wwJ7Wl5wRAoO2dkoOAAAytJ7REXBIXJROffoyukoiu5ozMw8+8AjHjEf2IuiSqXy\\/R5RkR2OPTgAAMpy23JnBcevhnMX+AoOkQtkqbtPR7SyouO97dmFf3j8mc9ceXSFvaFTcOSPqEQKDtm5dAqORqv9sgAAwPa67bbb0tbc\\/DuDgkPkUrPyatl87tyTVCr\\/YWpu7jHHjh2rBvaCvOD4AQWH7HCs4AAAKMup225L23OLCg6RradzwxJFUf6Y111prXrTw44fvyyw250rOIKCQ3YuVnAAAJTltk7BsfArQcEhUjQrj62ciaLkQ\\/VG47uuvPLKdmC3imIFh+x8FBwAAGW5dXk5ac8t\\/nJQcIhsV1ZumE8nlcovTh84cO3JkyeTwG7TWcGRKDhkZ6PgAAAoi4JDpJSs3DSfyfKptDpxw\\/6jRxcCu4lHVGQYUXAAAJSlV3C8I3Q3TFxWcIhsa5ai7g30mSiK3jc1u++rg01Id4vuW1RiBYfsaHoFR0vBAQCw3fKCY3p+\\/629t0EsKzhEtjf5vhxxHOc3NfkmpHemtdoLTp46peQYvk7BkSg4ZGfjLSoAAGXpFBwLCg6RHcjKjfSXoiR5x2S7fTwsL0eBYckLjn\\/mERXZ4Sg4AADKkhccM\\/P7f0nBIbJj6b1tJfxFa27um3obkCo6hqBSqTyvW3BECg7ZqSg4AADK0i049v1SsAeHyE5mZdXAXXGavmT+iisOBCXHjqtUKt9nBYfscGwyCgBQlk7BsbC\\/V3DkF18KDpGdSm8lx5koSd4ze+josezrOLBjFBwyhCg4AADKouAQGWpWHlc5E6Lojyanp78hsGPiSuV784IjUnDIzkXBAQBQFgWHyK7IStFxZ21i4gWHDh2aCZROwSFDiIIDAKAsy8vLsYJDZLiJomg5juKlOO6UHPcnSeXnrrr2WvtylCyuxB5RkZ2OggMAoCwKDpFdl3wunk7S9L\\/PX375IwKlie3BITufXsHRUnAAAGw3BYfIrk0+Jz+8\\/9ChLwuUQsEhQ0jnfJtUcAAAbD8Fh8iuTedGKIqiT07Pzz\\/x1KlT3rCyzeJK5XlRUHDIjkbBAQBQll7B8YtBwSGyW7MUovDpyZmZZwSvkd1W+QoOBYfscHoFhz04AAC2nRUcIrs+3RvwKPrURLP5zSGcSAPbIq5Uro9DpOCQnYyCAwCgLJ2CY58VHCJ7IPkc\\/Wy12TwZTig5tkWl8k8iBYfsbBQcAABlyQuOWQWHyB5IfiOe5PP08\\/XJye\\/OjkmgkCRJvlvBITucbsHRVnAAAGy77gqOfQoOkT2Rczfjf1lvNJ5z\\/PjxSmDLkiR5TrAHh+xsFBwAAGXp7sGx7xeCgkNkD6VTdHx+dmHh6wNbliTJPwrnCw4pJ7tgvuyqKDgAAMqi4BDZk1l5hewnLjvyt48HtiRJkmeHVTfj2XiubOi69p\\/XfX2h5D92fS72fzvo59nK\\/77fz7fx+7rZrp9\\/1VtpluLuf\\/uw58pui4IDAKAsCg6RvZveDev\\/nplZfFxgKx6d5U1ZXt\\/LLVl+Osube1\\/n\\/+6NWd6Q5aey\\/GSW12V5bZbXZLm5l1evOuZ51eDEeV65Kr3v2+x\\/08kFft5zeeUF\\/l2eV\\/TyE9n\\/d56bsq9fnuXGLC\\/r5cd7efGqr1\\/SS\\/bv4xu7\\/\\/tOXtH7+W\\/ujU8+Zj8TouiD2fFs2AVzZRdFwQEAUBYFh8jeTXR+pcEd+6448sjApYqyVLNUeqn2SWVV0gFJRiDxFrP651gZj3zcatXW9Ddmxwet4lgTBQcAQFk6BcfivreHzkVXfrPkQlRkD+ZslCS3z19+5SMC7BJpvf7E7HBvsBfH6ig4AADK0nlN7OJlnYIj8ry0yF7O2ZAkH2nNz18VYBdIJyYemx3+JnQL9GHPj92STsEx0W7fWGhwAQDYaF3BsazgENmzWXlc5Tcuu+yyhwUYsjStPz47fMnqwI3ztKHgAADYfgoOkVFK50bydFKpvP3w4UdPBxiiNE2fkB3uU3CsiYIDAKAsq\\/fgUHCI7PVEKxuPPpRWq6ey+Z1voglDkabpE7PDAwqONVFwAACUpVdwvC0oOERGIt15HOc3lJ+vN6a+PXTfagE7rreC434Fx5ooOAAAyrJmBUd+czT8iz8R2ZZ0VnLcOTE7+9UBhmBtwREU6N0oOAAAyqLgEBnNxHGcr8rKXx9724ErrzwUYIelafo1QcGxPgoOAICyrHlEJSg4REYsndc\\/x0nylgMHDkwG2EG9guM+BcfaORkUHAAA5VBwiIx2uvtxhHtqExPPP3XqVBxgh6RpPS847lVwrImCAwCgLKsfUell2Bd\\/IrKtyW8qu\\/txNKennxRgh6Rp+vjscG+vZFu20WgnCg4AgLKsKziGfeEnIuWkc1MVJcl7H\\/3oE9MBdoCCY\\/BcVHAAAJTACo6Luxgdgwx7nKXk5HtxZHkgrVZvOnjddRMBSpbWu4+oKDjWRMEBAFCWvOCY6+3BEdzonkv+rHgv2U1hd6PGlTHq3SieS+juX9JJGJDN\\/l2\\/H3uhn2\\/1zxldKH3+ewf9OjbJ0D8T2Zbkn+WD9ampbw9Qsl7BcZ+CY8McVHAAAJRh9SajwY3sufQ2w\\/tClKa\\/HOL4lhAnb8yOb87yM71k3xe\\/KcsbsvxUltdleW2W12S5uZdX9\\/KqVXnlqrxiXX5iVVb9c3pTLy\\/P\\/jnPTef+Xej8PK\\/Kjnlu7uW1vbwu+zW8Pssbs7wpy09neUuWn8+Sr9r5pSy\\/kuW\\/ZXlfltuzfCjL\\/8zyZ1k+FzpvQAhnwgXKlmF\\/XnLRWSm3Pnrg2LFDAUqk4Bg8BxUcAAAl8BaVtYmipLtyI9+UMQqfPHjNNZcXH+U9Iw4nQhpmZtqhVjsaKuGrQxKemX3\\/92d5VZZ3hG4J8r+y3JPldHa+nA0h9FsBMvTPUjbNmaRS+VmPqlCmlYJj5S0qCo5OFBwAAGVRcKxNFMXnC458JUOjsS87RkXHeQTkY5BmyW+IF0O1enWoJt+Uff2jobsi5HeyfDH0X+0x9M9V1iaOO3+jfu9Ee\\/Zb1n\\/QsF0UHH2zUnC8vNjoAgCwwaqC46yCI0\\/cO3YuyD\\/eWFzcV3SMx0ASJsNlIQ0nsq9\\/MMtbs\\/xhlrtDXnhs3ONjF3zOEvI5H0UfOnDkyBUDPlcoRMHRNwoOAICy9AqO\\/xgUHL2sKTg+oeC4ZHGWepa88Hha9k\\/5Rfzvhc6bFJQcuyz553A6rVRuDkeP1gZ+orBFaZo+ITvcr+DYMO8UHAAAZVBwrE0Uot4YdJbwf7KxsLC\\/8CCPt7jRaOwPSfL3Qhznm53+QZa\\/Cave4hJ2wec+rumN\\/53N+f1PvMDnCJcsTdP8vHpQwbEm9uAAACjL6oIjDP\\/CbxelW3CEhYaCo7jze5gcW2jWGrWnZd\\/zqyHfsyNaWdGRj7ebn2EkiqKzIUl+\\/dCjHjWz2YcIl6perz8pm9cPBqu2VkfBAQBQFgVH\\/\\/T+ZvuTwQqOcuzb1wiVyvE4jl8Uuq+lvT94fGUY5\\/nKuf5AZWIif1uODXXZNmm34DgdzOvVUXAAAJRFwTEokUdUdkir1ZoLcXhe9uXvhm7RcbZz0x25KdrB5I8L\\/c7hxxxzvrNt0nr9ayMFx4a5FhQcAADlUHAMSm+TUQXHTkmyXB6S5Huy4weyPHD+8ZVhnwujn95+KA+m1dpPhGPHqhf1icEFpPX6k6MQnTm\\/B4cEBQcAQHk6Bcf8SsGR74FgH4RuvEVlaA5OzWbfPjfL+7N8IZx\\/dMVNUnnn+8o5\\/7mJiamvvqjPCS4grdefEvJXRdtkdHUUHAAAZVFwbHoR+nEFx9DEs7OzU9VW6+9nX38iKDh26pxfiuPkl06ePGUVB4WdLziCgmPdPFNwAACUYO0jKgqOVekWHI2GgmPIaq3WI0Ic5zcDnwm918uG4Z8fo5p8bO9OJie\\/KdhwlILSRuOpkYKj3xxTcAAAlMEKjk0vQj\\/ebDYXi40w26U+0\\/qa7PDBLGd6JYeio4T0xvb20GrNX\\/SHA330Co58fycFx\\/msFBwvLza6AABsoODY9CJUwbG7RNnnsRDHcf460z8OK29bGf65MlLpjel9SbX6bZfw2cAGaa32dQqODbGCAwCgLN6isulF6CcUHLtTZXLy2uzwrixfCvbnKOf8j6L\\/sm\\/fvsbFfyqwloJjwNxScAAAlKO7gmNRwdH\\/IlTBsXvl+0NMx5XK87PjXUHJUcb5f9fE3NxXXvxHAmv1Co5V81LBETyiAgBQHgXHoEQKjr3g1Km43mo9PvvqtiwPxXH2uUXDPndGIvn5fzau1l+cHZNL+kygJ63VnhYUHP3mloIDAKAMCo5BiezBsXdErcsvnwtx\\/MYohAciKzm2I0tRFOdvrPndw49+9PQlfyIQugWHFRwb51ZQcAAAlGPtJqNDv\\/DbRVFw7DWzs7NTcRy\\/IPvyL8OqR1aym\\/RdcD7tyeTj96XW3Nw3XuJHAR0bV3BIUHAAAJRHwTEoCo69KqlW8xvyO4N9ObYjS1GSvvPEiRP10N33BC5aWqt9fTAHN8ypoOAAACiHgmNQFBx7WDoxMfHYEEUfzJfHR8GrZAskH7vPTczOXnfpHwPjTsExcE4pOAAAyqDgGBSbjO51jUbjUdnhN6MQHgpusraafB+OpThNX3TpnwDjLqnVnh7MvQ1zKig4AADK0Sk4Fm0yujEKjhEQTczOHsyOvxY8rrLVdMYtipL3H37Oc+qX\\/Akw1hQcg+dUo92+scjYAgDQh4JjUBQco6Jer1+ZHX41CuHB4Gbr0hN15sJftxYXPabCJVFw9I2CAwCgLAqOQVFwjJL9R48uhCi8J3TPczdcl56lOKm8IZw8mWxh+BlTCo7+cykoOAAAyqHgGBQFx6hpzc9fFaLot6IoOhtFNh69xOTj9b8mJycPbGnwGUsKjoFzScEBAFCG7iajCo6NUXCMonpr5vHZ4dPerHLJycfrbL3dfspWxp3xVKvVnhGGf+7utthkFACgLAqOQVFwjKi0NjmV\\/63yn\\/dWcuyCc21PpFMIpdXqy7Y27IwjBcfAuaTgAAAoQ\\/cRFa+J3RgFxyiLK5Xrs8O9HlW5+ERRvBSi6IPXXXfdxBaHnTGj4OgbBQcAQFnswTEoCo5RduD48cmQpq\\/Mvnwo2CPgopKveMmOd1Xm5h6ztVFn3Cg4+kbBAQBQFgXHoCg4Rl3rwIH5EEXvz1dxWMlx4fTG6Eyc1v5Vdoy3Ou6Mj17BsRSUiKuj4AAAKIuCY1A6N3MfV3CMtqRW+4bscL+C48LJ9yvpjFMUvTMsLDS3POiMjVqt9nfDLjh3d1kUHAAAZVFwDIqCY0zUs+Sva3wg+Fvmi0k+Rn8SpusP29JoM1YUHAPnkIIDAKAMCo5BUXCMjXo4lH17e+jOASXH5snH54u1RuNpWxtsxomCY+AcUnAAAJShV3C8NSg41kXBMUaiyXb7K7LjpzyqcsHk43M6rlZfstXBZnwoOAbOobzguLHI2AIA0IeCY1AUHOMmraX55pm9VRzRcjfDPg93ZfJ9ON5z+MSJ+tZHm3Gg4BgwfxQcAADlUHBsehH68WZzn4JjTDQajf3Z4XejKORvVVlWcPRPb5XLn4dW66rsGG19xBl1ecER7YJzdpelW3C0FBwAANtOwbHpRejHFBxjJapOTn5jdvzrYC+OPukWPr2C46GkNvmMrQ8140DB0TcKDgCAsig4Nr0IVXCMozh+e34Tbz+O9emuaumNy1Kcpj+Sj1ahsWakeUSlbxQcAABlUXBsehFqD44xlKbpY7PDXcEqjnVZs4Ij34fjP2XH2tZHmlGn4OgbBQcAQFkUHJtehH5MwTF+jh07Vo3T+DXZlw8GJceGRJ0NeDslx4dDmG8VGGpGnIKjb2wyCgBQFgXHphehCo4xNTU19beyw\\/\\/xmMqm8+Mz9cX2lVsfZUadgmPg3FFwAACUQcGx6UWogmN8VeKl49ykAAAgAElEQVQ4fm12PKvkGDg\\/7q412k8tMMaMOAXHwLmj4AAAKIOCY9OLUAXHGGs0Go\\/KDp8NHlMZND9OhzQ9tdXxZfQpOAbOHQUHAEAZFBybXoQqOMZbGsfxG7LjmaDk6D9H4vhtx48frxQYY0aYgmPAvFFwAACUQ8Gx6UWogmPMpfX647PD3d3XxsbDPid3W\\/LNRr1KmYEUHIPmjYIDAKAUCo5NL0LvCAqO8TYz0w5R9N+yr5aiKBr2Obnbks+Rv6rVWlcVGWJGl4Jj4LxRcAAAlGFdwWEZ\\/tqL0LzgWCgyvux91YmJb84OX7LZaN85cm9lYuKriowvoysvOKLhn6e7LQoOAICyKDgGJVJw0HHl8ePt7HB7HMfmx9p0NhpNqtVvKzK+jK7eCo6l4M+W9fNGwQEAUAYFx6AoODgvTuMbovM3J7vg\\/NwV6dyoxXF8Q6HBZWQpOAbPGwUHAEAJFBybXoTeEfbvV3AQJiYmvjI7fDGYI2vmSNR5k0r6qkKDy8iyB0f\\/eZNnst1+WZGxBQCgDwXHphehCg46ZvLNRkP4tWCOrJkjnX1Joug\\/Z7+RRIUGmJFkBUf\\/eROs4AAAKEen4JhXcPSJgoM1qtXqt2aH+2w2umGefOTo059eKzS4jKRarfaMSMHRb84oOAAAytArOH4+KDj6XYQqODjn2HXXzWaH\\/6PgOJ98LLIb2D9qHzo0U3B4GUG9gmPo5+kui4IDAKAsecExreAYdBGq4GCNOI7fHoXOYxlL3Ru3aNjn6VDTK3vuDDMzj8yOHlNhDQVH3yg4AADK0tuDQ8HR\\/yJUwcEaSaXyndl9\\/OkoWpkr8bDP02EnH4f7QpI8Myg4WCcvOMLwz9Hdlk7BMaHgAADYfgqOTS9C72h6TSznRdkN29Hs+CehO1+Wx30FR+jOk7NxpfJ9xYaWUZQoOAbNGW9RAQAog4JjUDpL7z8aFBysdvx4Jfv2zVnOhBCbL93kr4p9dQgn0mKDy6hJPKLSf74oOAAAymEPjkFRcNBfUq3+g+zwN1GIl9y8dZLPlfeG2dmpgkPLiFFwDJwvCg4AgDIoOAZFwUF\\/tVbrEdnhzzubjVrFkScfg983V1gvqdWeHoZ\\/fu62KDgAAMqi4BgUBQcD5CsVoug3os588crYXsnz2TAxcbDw2DJSFBx9o+AAACiLgmPTi1AFB\\/1UQxy\\/Ji84osgKjt6bZO6uNptfVnhkGSm9gsMcWRsFBwBAWboFx7yCo\\/9F6B2h1ZovMr6MpqSafHMUwkNRZAVHbwXHA2m9eaLouDJaFBx9o+AAACiLgmPTi1CviaWvynTjmuzwWQVHnk7B8VBSrX5T0XFltCg4+qZbcLQUHAAA207BselF6B0eUaGffVdf3cgO77cHR1juvk0mOh2S6ncUHlhGSlJLFBwbo+AAACiLgmPTi1AFB4PF8VuCebOcv00mCuF0Nh7\\/tPCYMlLygiMa8\\/nRJx5RAQAoi01GN70IvSM09ys46Cuu1Z6XHc6EMZ83vYLjTIjjFxceVEZKWku\\/Poz5\\/OiTTsEx0W7fWGRsAQDoQ8Gx6UXoHSHYZJT+0kYjv3l7KIz5vOkWHNHZEMc\\/W3hQGSlpquDoEys4AADKouDY9CJUwcFA1UbjUdnhi8G8We7uRRL92qlTp9Ki48roSNPa04L5sT6dgqNhBQcAwPZTcGx6EargYLDJycuybz8TzJvlzptUougD4diJZtFhZXQoOPpGwQEAUBYFx6YXoQoOBmu3Z7JvPxrMm86bVEKIfi\\/MXn6w6LAyOhQcfaPgAAAoi4Jj04tQBQeDHT5cjyuVnwvmTa\\/gCJ8NlckvLzqsjA4FR98oOAAAyqLg2PQiVMHBZqI0TW8I3bkz7PN1yMn34AhfDGn9RMExZYQoOPqmW3C0WgoOAIDt1i045hUc5xKvvghVcLCppF5\\/dna4L4z53Imizq8\\/G4fa04uOKaMjTWtfF7rnxnLUOU+ioZ+ruyArr4l9ecHhBQBgPQXH+qwtOFotBQeD1ZvNJ2aHvw5jPneyG9f81\\/9ACMm3FB1TRkea1p6aFxydciMoOHrpFhwtBQcAwLZTcKzPSsHRuWHLN5BUcDBQfWbmUHb40zDmc6dXcDwU4vh5RceU0dErOM5G2e+nCo5zUXAAAJTFHhzrs3IBvlJwWMHBYO1Dh\\/I3qfxh6MyfaNX5M17pFRxnQohvyo5x4YFlJKRp\\/Smh92eLguNcegVHS8EBALDdrODY9CLUHhxs6vCJE\\/XscHswd5Z6+Q9ZKkXGlNHRKzjOhHPzQ8ERzhccNhkFANhuy8vL0fTCQv6qSwXHxotQBQebu\\/VkEiXJO3srGMZ5\\/vR+\\/dF\\/zo61osPKaEjrCo4+sYIDAKAs3YJjUcHR\\/yLUHhxcUJwkb1BwnCs43psdJ4uOKaMhrdefHBQcfeeKFRwAACXwiMqmF6EKDi4oTtMbFRznHlH5RJaZgkPKiEjr9a\\/NDqeDgmPDXFFwAACUIC84phQcq3LuAjwfi4+0Wq25QgPMyEvr1VPR+Rv8XXAOD\\/XG7dOT8\\/MHio4poyGt158UOgVHpOBYO08UHAAAZbCCY31WXhPbGYsPBwUHFxCn6atD9\\/GMcZ8\\/+a\\/\\/c6FWO1J0TBkNaZo+MTs8GKzgWD9PFBwAAGVQcKyPgoNLkr8x5DfG+RWxq5LPmS9Um81HFh1URkOapk8ICo5+80TBAQBQhm7BsajgOJeVgqPzt\\/EfUnBwAXGWX+7uwWEFR5Z70nrzCUUHldGQ1utfkx0eCAqO9fNEwQEAUAYFx\\/qsWcHxoTA1NVtogBl5cRq\\/TMFxbs48kFQnnlV4UBkJadopOO4PCo7182RpstV6WaHBBQBgI4+obHoRquDgguI0\\/mFvUTk3Z07Hae1fFx1TRkOa1h+fHe4L5sb6eaLgAAAog4Jj04tQBQcXFKfxixUc53I2Tqs3FR1TRkOapnnBsWoFh4TzBcdLi4wtAAB9KDg2vQhVcHBhcfyTCo5V8yapvCn7fSUqOqzsfWndCo4+6RYczaaCAwBguyk4Nr0I\\/WAICg42l1Sr35EdTofhn7O7IUshit517NixZsFhZQT0Cg4rONbPkW7B8eNFxhYAgD4UHOtzbhO8fCx+W8HBhVQbjUdlhy+Ezjkz9q+LzefNH07Mzh4sOq7sfQqOgXNkaXJqWsEBALDdFBzrs\\/o1sdHtod2eKTjEjLpa+0j27WeC+bPcG4O7qtXq3yk2qIyCXsGx6jWxEs4XHC8uMrYAAPSh4FgfBQeXqF4\\/nH37Z8H86c2bcG92Y\\/uEYoPKKEjTznmg4FibXsEx9WNFxhYAgD4UHOuzuuAIHwjtQwoONlefflj27ad658wuOIeHmc7jOWdDtfqsosPK3pemaV5wPBj82bI6vT04pl5UZGwBAOhDwbE+a1Zw\\/FaYnp4uOMSMuInZ2Suywx8rOFbmTViK4\\/hfZUdvUhlzab1+Iig41mflEZUfLTC0AAD0o+DYmKibfCzePz19WMHBphqHD+\\/PDr+bZal37gz9HB5i8jFYitP05dnXcdGxZW9L6\\/WvjaIof8OQP1tWzZHQLTh+pNDgAgCwUbfgWFRwrMqqguM3reDgQg4eO5a\\/aee3g4Kjc\\/MWRZ0VHD+TfZ0UHVv2trRWe2p2OBP82bJmjuSZbLdfWGRsAQDoQ8GxMasLDis4uJB9V1\\/dyA7vDgqOczdvIYrekx2rBYeWPS5t1J4W\\/NnSd4402u0fKjK2AAD0oeDYmNWPqFjBwYUcv\\/76Sna4NctZBce5fPzA8eOTBYeWPa5Wqz0j+HNlfVYKjhcUGVsAAPpQcGyMgoNLcfLWk0mI458LVnCsvoH70zB7+cGiY8veltRqzwwrq3qGf17ulnQLjunZf1lkbAEA6EPBsT4rb1HpFRxeE8sFZHMoCkn8pmD+9NJ5k8rnQ73+5IJDyx6XVKvfHBQc69MZj+bc3A8UGVsAAPpQcKzPmoLjN9vttoKDTeUFR1qr3BzcyPXSKTjuTyr17yw4tOxxSbX67cG8WJ\\/OeLTm9z23yNgCANCHgmN9FBxcump98qXB2yJWz53TcRzfUGxU2esqtdo\\/DQqOfvNjaWpxUQEIALDdFBzrs6bg+K2g4OAiTHSfp38gmENZovx4NsTx28LRo7WCQ8seFler+atQFRxr0xmP9v7931JkbAEA6EPBsT5R7xh3C46g4ODCpvbt+7bs8KVgDq3MoXwc7piaOjhbbGTZ0+L45qj7yJJ5cT6d8ZjZd+CZhcYWAICNFBxrE0UrBUfnovzDrVZrrtgIMw6mr7jsCdnh7mAOrSQfh8\\/Wpqb+VqGBZY+LfzaK8rK48\\/vpqt9fxzndwmf24MGvLzq6AACso+BYm5UL8O5FefidMDl5WbERZhzMHjp0LDv8dTCHVpKPw4Nprfa0QgPLXveL2e+pq1ZwxMM8J3dJuuMxt2\\/f1xYcWwAA1lNwrE0UxcvR+YvQT4TQXCw4xIyBhYNHjmaHO4M5tJLOTVylXvemiPH2rvz31POP\\/lnBsVJwTC8sPKHo4AIAsI6CY23OFxyxR1S4aAeOHLkiO3wmmEPL3ZvYeCmbR0txnL6m6NiyR504Uc++vb27gkOxsSrd18TOzDyu0PgCALCRgmNtOgVH528cO2PxkdBqzRcbYcbBviNH8pU+n+otxx\\/6eTy8RJ3HvHpZClH0ruKjy57Ufbzvj4I\\/V9anU3BMTE19VYHRBQCgHwXH2qwvOFoHDig4uKCZ48fb2c387ys4ouW1byKK7ggLx5rFR5g9p1a7Kvv2L4I\\/V9anU3BMTk09psDoAgDQj4JjbdYVHPkjKgoOLujw4cP1EEW\\/vXZDxXHM6oKjMxZ3VRqNawoPMHtPpXJt9u3nw1jPh77pFhzt9pcXGF0AAPpRcKxNn4LDHhxcjEoURe9WcGwoOB5KJia+tfDoshfle0zcE8Z6PvRNPh4PNGdmHllgbAEA6EfBsT7nbtDysfiQgoOLlIYo+hUFx4YshTi+JTtWC40ue9GzstwfzIeNcyKEu9qLi1cWGFsAAPrpFByLCo6Niazg4FKkcRz\\/QnZcsg\\/HmuRj8b4s7SKDy54ThTj+wex4Ovhzpd+c+IMDj3iExx8BALabgmNQIis4uBRJUqm9Pig41icfi\\/9bq9WOFhpd9po0xPGrQvfPlWGfg7stZ7PfLd53uPsaXQAAtpOCY2AUHFyKuDrZ\\/NHQ20AwDP\\/83S3Jx+KetNl8UpHBZc\\/Jb97fHsyFfjmb1mrvPHnrrUmB8QUAoB8Fx6B0\\/hb+g2FqarbQADM26q3W9wQFx\\/rkY3E6pOkPFRlb9pzFLB8O5sK6dPZ3OtOYnr25yOACADCATUYHRsHBJalNTn5DdngomEfr51G+0Wi+P0laYHjZW\\/5Olv8XzIU1iaI4G4\\/o\\/vlDh55baHQBAOivt4LjrUHBsS5WcHBp0nrnMYx77MGxNlH395U\\/mT1w4IpCA8xe8vQsDwZ\\/pqydC1E2HlH0xYUrrnhCodEFAKC\\/vOCYUXD0Sa\\/gCAoOLk5zZuaR2eHTkXm0Jr3C50vVyclvLDTA7CUvzHImmAvrk4\\/HX+0\\/dOjLCowtAACDKDgGpXNT9tsKDi7W4sMfvi87fFzBsTbdZflhKY7jVwSPqYyDbAqEd\\/SKLXNhzVyI8rcsfergNddcXmiEAQDob13BMfQLwN2TXsHhERUu0r6rr26EKHpfMJfWpHNT17nRjT6S\\/bP5NPLaM9k3f+BRrX5zIc7nw0cPHDgwWWiIAQDoT8ExMN2Co925WIcLOnHiRBrH8VuCpfmD5tNdlXb7ywsMMXvDU7LcHcyBfnNgKUnT\\/5odK1sfXgAABlJwDErnbx9v7\\/1tJFyUuFb7F8Hmiv2Sj8eDlVrt+wsML7tfkuXHg9clD5oDS5VG41XZMd7yCAMAMJiCY1A8osKlS6rJP8gO9wY3d\\/2SP6byP2ZnZ6dCd58GRk87yweCgmPA+R+W6pOt79768AIAsCkFx6D03qLiERUuQdqaeGx2+FwY+vm7+9Lbk+HzoVL5igJDzO52TZY7g3KjX\\/IxuX9yZuYZWx9eAAA2peAYFAUHWzAxcUX27ad6b0twk7cq596qEVeeX2iM2a3yVTk3BI9oDUo+Jn8xffniNVseYQAANqfg2PRi9IMeUeGSdM+XDwVL9PukV3BE4VeDR1RGUX7u\\/2bwZ8mgZOd+9Mmj1\\/5\\/9u4EXs6rrh\\/wme3ua5KbpEnapmna0gilkGKpFbiWRSoWQQygLBUVEAVxAQQUiAJ\\/BQTEgogKIohgAQGRspQdZBPZLCIIFFkKFKS0ULo3\\/3PuzG1u03lnuzPzzsx9ns\\/n27lN7rznvO+8c3Pf35z3nNstdXyEAQBoTIEjK7U5OIICByvSvBHNL0x2754IxeJLgwJHvffU6iiOr4\\/Pzp7Y9FgyXEqle8X\\/\\/jA472+ReN6n3FCZmvr7AwcPjq3nMAMA0IACR1ZWCxxuUSFdu5XODcViK7dWFOL3\\/X4hvp\\/conKL91R6TMfkuniMnhcfyy0cT4ZDei1fERT26qZ2y9o1s\\/PzD1\\/HMQYAoBkFjqxYRYWqU5eXF+LFybtXRmYcOFBq9v2lycn7x4cfKnDc4j11aE2R46sxe5odS4ZEde6Z9JoqcNTJys+CQuGynccff9Y6jjIAAM0ocGTGCA6S4sTs7Lnx8QfxAuVtYceOqWZP2LJz54nxQv4rChwN31vp8UHNjiVDoRyKxT+Kj9cGxY265\\/vKCI5i8cs79+7dtY7jDABAMwoc2b+UBgWODW9mZnuad+Mjheo58dXJycmmFyhLy\\/tm4sNHg4u9zPdWtfhTfFUw2egoOD7mGwp62ed7Sqlcfs+mvXvnOj\\/MAAA0pcCRFZOMEsLU7Ox9Cmn0Rm3uiOnFxVNaeFqhWCqZaLRBahfDX1w46qhjWzieDLTio8NNRav8z60BzMrPgcrk5PMPtHCLGwAA66DAkRUFjo1ux\\/79U8Vi8fxC9b2xcvE2Njn5Cy09uVz8\\/fjf64MCR90UCsV0XK4OxcqjglEcw2t+ZYTb+2qTaOZ+Xg1oVs71zdu3n9v5gQYAoCUKHFlR4NjgCqWpqXPi42WF6rmwUqgoFotPaeXJpamxn4sPV9eeOwDn80AmHZsP1y6SGT6FUKqcGywN2yQrxZ+v7N1\\/6+M7P9QAALREgSP7l9KgwLFhbdq0Kd0r\\/9ZweOh9NcXia+Jjsdnzx2Zm9sWHS4MCR6OkY3NlaXz87GbHkwE0GXYGc820cI4XbiyNjb397LPPHu\\/4WAMA0BoFjqwocGxklUrl3PhwZbj5xduNhRA+vbB790Kz589sT5OTFj6kwNE0afnMNx04cGCs2TFl0BR\\/Pf7nGnNvNDm\\/47+tY5OTf9rxYQYAoHUKHFlR4NioxsfHT4gPF4VbfjKd3iPfqszPn9ZsG\\/v27RsrFosvUuBonNrF8Q9KY2P3D+biGB7j43vjfz9l7o2Wzu9rZjZv\\/vnODzYAAC1T4MiKAsdGVSwW\\/yRkrwpxXfyG32hlO2OTkw+I59GRo0BkTW66\\/adQeHt8nG3luJK7SszzY25Q4GiadH5\\/Y3x2y0mdHmwAANqwUuDYsu0fggLHEUkXXoV\\/C3MKHBvJ9PTKMrBfyhp2X\\/3z4stDmoGgibldS2kkyNdDQYGjSdLx+X5pbKy1FWrI2\\/6YS4JlkFtI4cZCufyWk848SfEOAKAfagUOIzjq\\/GK6UuAIVnjYMKqreaSJRdMn04fqfTJdK3x8Kmap2eb2P2J\\/JX7\\/u4MLwaapHdePhcXFY5odV3JTCNPT2+PjBaH2HgkDcO4McNI5fd3k\\/OzjDxw4UOrwmAMA0A63qGRFgWOjKVUnFr0+NChG1C7ELwljY7ducbMvDgocTVMsrhzX64vF4uNbPK7k449Ck\\/eI3JR0jC5d2rf3dp0dagAA2qbAkRUFjo2ktqzrRfECu+GFW63AcWXLt1NUKo8JChxNU5vLIR2jz05u3ryzpWNLPxXK5fIZ8fF\\/g3O5lay858uVyoVn\\/8VjLA8LANAvChxZWZ1kVIFjA0jLvr4+tHbhtrLsYyiW0siMpqt+lEqlnwlpYtLqpKV1b3uRlGJ6zx2qHtvii8LevS4KB8uemM8FS8K2mpUCx8TMzDM6O9wAAHREgSMrtQKHSUZH24EDpWKx+Lvxqx+G1j+Zrs4XMbtzc7PNTywsHBsf\\/mt12wocme+3Q7Xjk47TZaXx8Z9tdmzpky1b0gSZr4i5PmvyXblF0nG6em5p6eyOjjkAAJ2xikpWFDg2gvLExF3iw6WhvWH36XuviM\\/+ydBsFMf+\\/ZVQXFl15YY229jIScvGviPs2uW9l7+ZUAzPio\\/XBOdvW+dwoVj4+PGnnLK1o6MOAEBnFDiysnqLigLHqDrjwIHJYrF4fqjePtJugSMtF\\/uE0MptKpNjDwjtjRDZ6EnH6ZpQLD4zPk40O770TDm+Br8THy83cqPt8\\/e6qbm5p8bHYicHHgCADilwZEWBY6Tt2jVZHh9PK3ZcWZvgstXzYuUCplBYuYhJS8qWm7Y1MbE7\\/vcLBZONtpPqrSpjY\\/drenzphbSs6cNivtve+2OjJx2nlYmKv33sXqunAAD0nQJH5i+q6ZfUD4V5k4yOorHJmQPx4YedfDJdKBRX54r43zAz08oQ9IlQDP8UFDjayeqomv+cmJjY08IxpptKpXPif78ZnLNtZuWcvbFQKr0\\/PpooFwCg36qTjCpw1Em1wGEEx6gpTszO3ik+fnbN0qRtnx8rz023nZTGfq6FNgvFSuUR8fHa4GKxvWNcWFlV5eVhaWmmhePM+hVCqZTO6a8budFJVkZv3DA2PfHE0MLtawAAdJkRHJlR4BhB09PTp8SHL4TuFBrSNl4W9u0ba9bu7OzsSSGN+FDg6OQY\\/ygUiwf3Wjq214qhXP7p+HhxcJ62ndoy0DeGQvjO4nG7TunkBQAAYJ0UODKjwDFaCvHi7cz4+O+heyuapG18K+bHWmi\\/UqxUXhAfr68NY8\\/7\\/B6SpNuBSul4XRWKxWcHw\\/57Jd2K98cxlxYKRednB6mNeLlucn722fvT6kkAAPSfAkdmagUOc3CMgEKoTN0+Pn46dHdOgdVt\\/WYrnZiYnUi3xvygesFu6H8Hx\\/qqmD+PWQiG\\/3dLOo5HxbwyuIVqXVkpDBUK3916\\/LE\\/0e6LAABAlyhwZMYIjlFRqZwW\\/\\/vpQqFwfZeXu6wVOAr\\/3FI\\/ZmaW4n8\\/VVgZwaHA0W5qr93VMeeZ\\/LdrTo15W8w1teOrwNF5biyXy+\\/etW+ffzMAAPJiktHsX1ZjPjQ3p8AxxEqhUrljfPx46N1qEOl989UQxk9qqT\\/lcroN4LouF1o2UtJxuy7mdTEnhzRvBJ1It1DcOeaTwUop3Tovr1rcuvVR4eBB5yQAQF4UOBr+wvqhoMAxtMrVCRPTUpc9PLfTSIzCjaFY\\/IPQwm0T04uLt4kP3wguKNeb9Jp+uXR4FRu3rLRqebkcz9cnxa++X5sY85DVUtadG4vl8ifPvPfdd7T9egAA0D0KHFkpGMExvCZKlcqvxMcvx3S8FGxrWbkwTNv\\/TMy2pj1Lkw8Wi\\/8UfGq+rlTnO6hN8losPj1MTu5qeuxZHdF0fswPV5dJVuBYd1bex1MLc09t9wUBAKDLFDiyUjCCYziNFSvjj4qPl\\/fxNpDUzjUhlO\\/ZSgdLY2P3iw83uE1l\\/SkcLhS9P5TLZ8XHpkv2bkDplontMWmU0SVBca3bScfyh0cff\\/StW35FAADoDQWOrNQKHNXlExkCC7sXFlY+zQ\\/he6ufTof+XeDcENt+bksdnZzcGf\\/72eAis2vHP77W6efXpSuvwfj4icEtK6vSz69Hxnwi5moTifYk10\\/Nz77sjAMHJlt\\/WQAA6AkFjqy4RWWYjKeL2mLxVaG6ykYeF3Cpzc+GiYljW+husTK+Msrkqpz6OqqpFppC+Fw8F34vvhZ7wsYsdBTDZDg6VAsbqUi7ep4513pwzhWKxf+93Z1O39fqiwMAQA8pcGT\\/4hrzYbeoDLiD8WJuYuInQ3qtQuj2MrDtni\\/XhlD6tdDCRfX+u91tPn7XZ4KLzi6mcGNagrdYHc0RX4vwuVAq\\/WrYWKOw0lLEvx7z+fheWC32KW70JivHdWxq6mVhYxbSAAAGjwJHVgoKHINuYWGhWCz+bvzq2yH\\/i7jVW2LeHjPXSveL5fIzQvV95+Kzy1lzK0YqdPx7TJoA8vSYUXs\\/pwvrzTF3iklLEH8qrMwHk\\/v7YSMkTXT7nc3H7jyrhdcJAIB+UODISrXAMTs7u3ldB5heKEwsLOwOhcLrwuGLudzPmdpF9ffK1RElTY1NT58S0iogA9L\\/UU2an6P22vwopMlIQ\\/jNmJNipkJaWaSqEAb\\/U\\/jV\\/qVJQ6dj9sc8LVRHL6V9U9ToX9Jxvm5mdvYlB88\\/aGJbAIBBocCRFQWOgbRr12QolX4xVD+pzvOWlFuk2pfC9fHrl8SMt7A3lWKplL43PWdg9mNEc+OaUR1pTopvxnwk5q9i0vm0vzZaq9jsRctJOp\\/S5Kn3jTkvVPv+nZjrgttQ8jmfioUvH3\\/aKVZOAQAYJAoc2b\\/AhupFhALHYCiF6enbhGrx4IpQu6CLF615nyf1zpvvxtyxlZ2anJu7YyiEb1rdor+vUaGWcDiXxXw05qUxvxKTbjs4OWZLqN5ylFbISKM9ejnKI227EqqjM9K8ISfEnB2qy7v+a8xXw8377JzJ6fyJuWF6dvZ5+\\/fvr2S8lgAA5EGBo+EvsanAMWr37A+f+fnFUCz+dvzqCzHXF4vFQb6wW5noMj6+IBy+\\/SHbjh1TxerqL4O8T6OVQhptc9N7fOX1WlNgij8HVybnvDzmGzFpIth0W8urY\\/40hJXz8KEhlO8ZH1PBLS35uzkshZn4OBGqBYpSRsq1v0+3xqQCxo6YtPrGXUN1FEna9p\\/H\\/EvMf8T8b8wPQnUekRsKNx+Fkv9x3Li5Ib5nv7T3dgvKnm0AACAASURBVLezcgoAwKBR4MhMdZJRBY787No1WR4fv3v86sIwRBMn1i5CPx+vd49pZTcnN206I1Qvpgd+3zZI6o2SWJt0S9EPQ3Vy24tj\\/jvmEzEfDNVz9YJQLVKkvKn2mEZgvC3mPTEfqz0nPTfNwZKKKdc2aTPvYyKh+t4uhMI1s4vzT47\\/dg76nC0AABuPAkdWqnNwzFlFJRdjY2P7Qij+Tfzy++HwSiNDcaFXK3CkgsyTQ2u3NBSKlUr65N5cHIOXxsWO6pK0Nxzx5zdkfH3k92T93dCc6xswNxaLhYtOOuWk4wIAAINHgSP7F9mYjyhw9NG+fWOhXE6jGZ4XVkZADPUFf+p3uqXm6FZ2vTI1dbv48NVBmjRVRG6W9N78weJRWx65vLycbjcCAGDQrBQ4tihw1Ik5OPpnLF7g3z4Uiy+LX\\/9fOPzp+DBf7K\\/sw9jY2M+1dAT27RsrlsvPCjetijFwk6eKbORU38\\/j42\\/+iwsuaGWFJAAA8qDAcWRuurC0ikqvTUzsKVaKvxG\\/ekfMpeHIIfuDt0JKO+fRjbXbnF67MjKlBZt27twVqsvfxucVDylyiAxGaiOrLtt2zDFpQlgAAAZVrcCRVnFQ4FhJcfXr9AvtR2dnZ7es6wCzVlpJYksol+8SisU\\/iV9fFG45ueIAnAPduiiqLRlbDmmi1JYmJCxWKr8TH65zq4rIwOTG+F6+Znrz4p8uLy+nlXIAABhUtTk4VpepzPsXyQHIzUZwpNUOFDjWa8eOqdrcGn8aqqNivhdz\\/cqKBCO87OWapUjT6hmLrRyqrVu3bosPH0jFkdrzRSS\\/rPx8KlfKH7\\/rbz7UaD4AgEGnwNHwF9uPBiM42lUMW7bMhvHxvaFU+pn4\\/88IofDO+PidsDFXiUj7eXk8Fj\\/b6gGcmJ9Ow+C\\/uYGOkcigJr0Hr5jevPDQAADA4FPgyEpxZZnYsH1maV0HePgV6uRm4jlUCPPHLIZy+W6hWHxK\\/KN3x1xaKBQO1bKRChr1kvb9HWFpaabFY14K5eJzwuE5SfLuv8hGTHrvXTs5N\\/e8g+ef39I8OgAA5GzNHBwupG6WlYvyD4VtM1tDi\\/MnjKjStm3bpsP09LaJiYnj4v\\/fIeaBMb8b82chTaIZwgdDdVnXK8KRE4U6r1YKPPEEuip+\\/QehOg9JU0u7d28vlEpvjs+9wXwcIv1Nofaza3xq4oJ9d7jD9gAAwHBQ4MhMOh6f3HLMMfunjj56x+Tk5p1h06ZdYXIyZedKpqZ23JQwdVR8rGZ6enst20JImdkaZmqJ167x8XDCakIta79emf8jZrZBjtzGytdbq+3GpH5M3dS3HSv9DmFXCJNHT0wsHBsm5veMj8\\/tHZ+dPakyOXl6CGM\\/H0qlh4di8fHx+54e8+KYN4fq6h7\\/G\\/P9EAo3pALQ2jk0jNLIzppRLN+IOTG0aG7z3I+H6kgYIzlE+psbC8XiJcecetKZAQCA4VG7ReUfgwuoW\\/yCG9Kn7oXC\\/8THz4XqCIUvxVxcy5dr\\/\\/\\/FWv6nli\\/Uvndt\\/ruN1Hve55qk3nNX+\\/PFWj+\\/VOtz6vtXakkFi6\\/GfC2EQrr4Tku1XhGqow2uC7ccidEoeb9eg550jK6P+euYqdCaSrFcflp8vMYxFulb0oir6zdt3\\/q45eXlcgAAYHgocDT5Rffw7QHtXOyPSvI+\\/iOWlXPphzH3DS2a3blzc6FUSCNojOIQ6U\\/SbWGf3rRz564AAMBwWSlwLG17dXDxJB0k3X6Rdx+GIWnJ1+rSrytFjveFXbsmQ4vm5uZOjw\\/fDt6jIj1Kuo2suHor2dd37d19l7Cx514CABhOqcCxSYFDpC+pXUBdFcLKajPjoRX791eKExOPCCvzn3ifivQihcLKylnXTM5O\\/\\/7KylAAAAwfBQ6R\\/qZW5Lg6lMt3D20oVUp\\/G25+25SIdCG199R15bGx1526fOpCAABgOLlFRaTvuTENhw+hcEFYWGj5YmpuaemEUCh8oraqSt77IDISKRaL1ZWgSqV\\/O+7k444NAAAMLwUOkf6nUCilx6tDsfik+DgWWjS9devdQnXlGxPBinQnN4RC+OqmHVvbGlEFAMAAUuAQyS3pPfetMDFxVmjV8nJ5fHryt+NXV7lVRaTz1CZITu+h7y8sbT73wIEDpQAAwHBT4BDJNel2k\\/eHycmjQ4v2n3POVHly8rlhZbJS71uRDpPeOz+YmJt6+q4zWl\\/VCACAAWaSUZH8UhuFkYocLwpt3Koyu3Pn5kKp9MZQnXQ09\\/0QGbKsvO\\/GJiZe+pDHPW46AAAwGhQ4RHJPeu9dFkqlh8XHYmjRntve6sRCufzvxWLxkNtVRFrOyooppXL5jccff3zLI6cAABgCChwi+adWoPhaCGO3CW0Ym5h4UHy4rpBGcoSb5hUQkTpZHTFVKpfev3zOOVsCAACjRYFDJP\\/ULrxS3hAzG1q1e\\/fE5MLC78WvLjOKQ6RhVoobhXLpIws7d942AAAweqoFju0KHCI5Zs2KDtfGvCBs2dJykSO+h0tj4+PPil9ercghUjfV4kax+Mmd+044NQAAMJoUOEQGKul9+KOY3whtOPXUUxdK4+PnxS+vCd7LIkcmFTc+vfWYY86MXxcCAACjSYFDZJCSJgwtpvfixaFc\\/qnQxsXYrX78xzeXKpVXheooEO9nkcMjNz6zdceOVNwAAGCUKXCIDFxW5+P4fExbqzyc+sv3WSiNjb2qkC7qLCErGzs3FovFVNz4xGlnnnlSAABg9ClwiAxk0vvx+pi3xuwObdh0\\/PFHlyqVV8Yvrw7e17Jxc32hVPrQ5u3b7xAAANgYFDhEBjarIzlevWnTprnQhjPvfe\\/ZUqXykrC6hGyhYAlZGekUi8WVx9pEu9cVSoV3nXDaaXsCAAAbR63A8ZqgwCEyiEnvyzQS4x9nZma2hjYcc8wxi2Pj48+OX\\/4gXfQpcMiop1bcuHpsYuzvd524a2cAAGBjqRY4thnBITKwKdyY5tQoFoupWDEe2nDgwIGx8tjYU+OX3425IZiXQ0YstdFJq6OdLi+NV\\/7yVnf98c0BAICNR4FDZOCzevH2fzE\\/Hdq0b9++sYmFhYfGL7+aLgSLxaL3uoxMagW7dE5\\/Z3x6+vH7lpdnAgAAG1OtwOEWFZHBTXXC0ULhLRPz88eFzpQWjlq6c6lceleojeQYgP0SWW9Win+lcvl9m3fuPCsV8wIAABuXSUZFBjO1eTPS+\\/KqUCy+ut05OOo5+eSTjyoWi6mg+aM1w\\/pz31eRdrM630Z5bOwtu0+91e4AAABGcIgMZmoXcFcWK+U\\/CwsLC6FL9u7dOzc+Pf178ctvhMO3v+S+vyItJp2vN8T3x7cm5mefdOL+\\/VsCAAAkKwWOLQocIoOSNEdGbZ6My8sTY8\\/cctJJs6HLDh48WJyfn79bKBQ+Xwjh+loxJfd9F2mQG0N1VFO6xerrizt2PDD9+xUAAGCVERwiA5XVC7hvTc7NPWbbKadMh94pbDnqqP2FUunt8etrg58BMthZmYumVCi8d3Hr4plh\\/\\/5KAACAtWpzcChwiOSYNUtdXl8oFi6aXJi97\\/LBg+XQB1uOPfao4tjYM+OXXyuE6rwflpKVQUg6D9NoppWiX6HwrfL42LN2HH\\/80QEAAOqpFTjODwocIrlldULRUrn83hPuePuT458VQv+ktkrzmzefFS8i\\/ytUR5H4eSC556aJcAvhK7PbNv9c\\/LoUAAAgy80LHOlTW5\\/civQrhcOTfP6gVKm8cmnPnhNCfgrz27YdVyqVXhS\\/\\/r8QCgodkkvWrPDz3fi+ePGm7dv3xX+r+ln0AwBgGClwiOSWldUgYr5Znhh74j0eco9ezrfRsvPPP780Mz9\\/v\\/jlRaHaPyutSL+yeq5dn0YTzWya\\/4Xl97ynL7dqAQAwAlKBY2Fp+2uDAodIP1Odb6NQePvs4kBOmFhc2rXrhPTpefz6qqDAIb3PTaM2xqYmnrHtpGOPi19bJQUAgNYpcIj0L6tD7+PjFcVK6SXHnnzyUWGAnXLKKdOV8fFHFkL4ZMw1q3OFhAE4ljISWZ3UNo0UuqJQLv3r5h077tavCXYBABgxtQLH64ICh0ivs\\/oJ9acn5+fv3+MlYLupOL91656xiYk\\/iV9fEtyyIt3L6u0on5hbXHzQMbe5zWLo7wS7AACMEgUOkd5mzaiHNGrjHxaWlk4NQ+jA+eeXpufn714old4Q\\/\\/f\\/Coc\\/fVfskBZTWPt+uC4UCl8qT4w9c2nPrjS5rsIGAADrs1Lg2Lz99UGBQ6QXWR3t8KWJhdlfDtVlLof1Qq7a7wMHSpuWlu4Zv\\/pASPOIBAUOaTmr74crKpPjz7\\/DPe58dKga1vcEAACDpFbgMIJDpEspFGqfUlcv5C4tVSp\\/Pb2wcOqBAwdScWNUFLZt27Z1Ynri3LivqdCxMhFpbd9XEgbgtZD83wth5byo3YoSwtcq4+MvWdy6eOYZZ5wxGQAAoJvOP3R+aWFpqxEcIt3J6vD7a2O+NDkz84B0a0cYYfvOOGPT5Nz0Y0MhfCbu+9VpwsjVyVRD\\/q+H5PQ+CCvvheJqYeOS0ljl7446ac9pB84fqUIfAACDZKXAsVmBQ6Tz3PSeSRdzaTWI7xZLpfPmdi3tDRtlmctDobC0e\\/f26bm5BxcKhffHP7kyrJmM1IiOjZKbClvpfZAmD\\/3c2MzUH2\\/avv3H9u7dOx4AAKCXzj90qLSween11V9MFThE2k1ttEK6oLs8fv220tTU2bt3L0+EDWrnrW61eWxm5gGlcumC+L+XxmNy3eGJJVd\\/zuT\\/uklXszJao7bc65WhUPjM2MTEwS17dp548ODBjVHkAwAgf9U5OJb+WYFDpO2sflp9XcxnS1MTv7pnz575YMLEJB2DqcVjdvxkZWLspfHrbxUOHy+3roxWVl\\/TH4VC4QNTm+YfvuXoo3fE\\/y8HAADopzSCY37TSoHjBgUOkZZyeJnLEL5cHBv744mt83vCwQ1yO0qb9h04MDa\\/ZcvtyxMTTyyUS2lC0stCdcTLjebqGL6sec1Srk5LvZYqlb8bn5299759+zYFBT4AAPKSChyzi1veEFYuOBQ4RBpk9aIuTZr4nWKp+Bfbjj32uOCCrmX3eNxDpheOOurOlfHx58cL5S+F6mSsNwajOwY9N59bI4QrCqXS+6cW5x+1Z\\/\\/+Y+q81AAA0H+pwDG3uOVNofqL6yEFDpFbZs2n1l8rVSrnTc7NnR527bLMZYf2P+IRlfmtW\\/eMTUw8KB7P18Q\\/+kLMtek2lmIoHiqEtPpG8VA1+b\\/+GyWF9JgmhC0U02N12d\\/qvwkrk+cWSqX3xdfsyXObNt1x+\\/btS0FxDwCAQaLAIVI3a0cUpFtRLol52dzmzXc4dOiQi7ouOnjoYHHbScceV5ya+vV4Uf3GeMl8caiuwpJGChw5usMoj96e6yujNAqFQjr2V8d8M+aDxXL56Qvbtyyfc845U01eTgAAyE8qcEwvbv6XoMAhsprVC71r44XeRfHi7vmTm2bPMGKjD5aWZpZ27dpbmpj4pWKp9DelUundoVi8OFQvthU6upI0KmbldsQbCzefByUVNS4vFAufKBaL\\/1gZH3\\/U\\/FFbTpubm9sUlk0YCgDAEFgpcMwpcMiGzsoF3uGlTMOlpXL5LROz0+ceddxxx1rmMieHDhXu8ZCHTO85+eQTpjfP321iaurJpUrl1YVi8RPxby8phMJVwQiPls\\/vcNN5XqyO0gjhh\\/F8\\/99SpfzeyuTkC2Y3bXrYpp3b7njr00\\/fdvDQIec8AADDZ6XAsbD5zUGBQzZkbrYixHeLpdKrNx+786y9e\\/eOB\\/MLDJr0epRPOvPM2eNPOfnWM5sXH12qlF4e\\/+y\\/Yq4ItZVZ6mQAzrO+Jqvok261uiwexU+UKpW\\/XlhaOnffmWces3t5eSL+uYIGAADD7+B73lOeXlhcU+AQGcWsLdwVVj7FLlSLG2k1iH8rj409fW7btjsu\\/\\/Ivp4s9hsTy8nJ5aWlp+\\/yWLadNzE79arFcflqxUnpZoVD4YCgULg5r5vI4fCtGGsFQGNZCyC36fMRtJiu3VsV8L\\/7Zf8dz+z2lSunFxbHyE2e2LD5wcevWU7bv3bt04MCBUrdeAwAAGBi1Ase\\/BgUOGencdFG7uszl5fEC+MMTs7MPu8297rUYGCm\\/fPDgxOYTT7zV2PzM\\/cbHJx9TmZp4cbzYvzC+5p+Nf\\/2tmB+FaiEgjWpI58MNa9Ko+JE1OqJbadTG2j6mfl8T84OYr8f9uqhUKl1QmZx8bmVi4lfnt269+97TT9\\/1iI+\\/pNLVAwsAAIOsWuDYpMAhI5nD82oU0vn9\\/Xgh+MHyxMQzJjfPnb6we\\/dCMDR\\/Q0gjPbadsm16btfcpon5+ePmt8yfNjM\\/c9bk\\/PwvTM7OPr40Pn5esVI5P5RKF4Ri8ePxPPlyfNq3QyqEVSc4XS2EHJ7Lov4okPVktfiWCi+pcPGd2I+vhDTnSKn0tkK5\\/PrYz78dm519Uur3xMLMnacXFm47sbh4zNyuXZt27N8\\/ZWQGAAAb2kqBY37xrUGBQ0YjR845kIoan4oXiX89PjV19uytbrU5QIaDBw+W997udktLu3adkIoH5cnZM6c2L\\/zczOL8Iyfm5v5wbHz8OaVK6W+LldKrQ7n0unhu\\/UuhVLggjQ6JeW+hXPpAzIdK5dJHYj5WTfmj6f\\/j338g5n0x7ywU0nMKb4zf+9rSWOkVlfHKeVMzU380s3nzb80tLj5wYnb2TpXp6VNTP44\\/5ZStj3jEI4zEAACAZt6TChxzi28LChwypCkUiocKK0teVpe9DNVP3L9SrFT+Znxh4d6bdu7cFf\\/fpKF07lA8d9LoiOXlctgfKmFvPJ92hzRfy+S2bduml5aWZjZt2jS3uLg4v7B7YWH+mGMWj8zinsX59D1btmyZDfE5YVeYXNnOvn1jabsroy8OHTryHHXOAgBAq1KBY2p+8e1heCbZkw2dNFlo4cbDCTcUCitzEXy7UCh8slKp\\/OXY9OQvzu1aOmHv2WenogYAAAAbQbXAMa\\/AIQOZQqGwklBdKSKN1DhUWxEljThKkyu+bXxx7tFLu3efmm63CocVgk+\\/AQAANg4jOGTAUm\\/yxTTx4hWhUPivUrn82vLE2NMnZ2fvOz47e1Ia8n\\/olsP6AQAA2Ghqk4ymAkfW8oiyoXPTrSBdz00rnBRutv10HqZVJK4MaRWLQuHC4tjYM6eX5u65Y9++Yw4dOmTVEwAAAG5pZZLR+fl3BgUOqZvuFjgOL9saVicETeddWorzfwql0tvL4+PPqoyPP2piYeanJiYmjksjNIKlXAEAAGgmDe+fnFt8dPzyvJgXivQo6fz6i5g\\/j3lOzMGYx8Q8uDwz81MT27Ydt2nv3rlw8KBiBgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADDbF\\/Mz8c8Keb5Ma+MuSDmjTGviDkv5mDMQ2N25NNFGjgz5nExz4t5ecy\\/xLwh5sUxT415eMzZMZty6t+omoo5LeYhoXqcXxjzmpi3xry69v\\/pzx8csz9mMp9uAgDAcPqtmEPrzOUxX4j5t5g3xbw05hmh+kv89v7tys28PKx\\/v1rNF\\/qzS7n6iZgnx7wjdH6M0nnxgJjpPvZ7uUGfbtXHftTzR6F+v77co\\/bShfWbMtpslHTx\\/eB1tPuADtrsZ356HfvWinvFPCfmIx3270Mxz+pDP1t1asju66dz7Nd6PCFk79Pv5tgvAADa1I0CR7N8MlQ\\/zd\\/bn11a8fIu9r9ZRrXAcVLMM2P+J3T\\/mL0+5kF92IflBn3YKAWOtJ+vzmirnXwx5pEdtL8RCxxnhWpB77Iu9\\/XSmL8K1RE4eWlU4Ei5W35d60g55ushe38UOAAAhkg\\/Chxr895QvbWh117ex30atQLHT8a8LuaG0Ptj99WYx4beDcVfbtD2Rihw\\/E5GG+vJxaG94tRGKXCUYh4YOh+p0W7eG3PvmEKX+t+qZgWON\\/a5P+v1S6Hx\\/ihwAAAMkX4XOFbznzH36+F+vbyP+zIqBY49oXpxksf58O2YR\\/dgn5YbtDnKBY4018O\\/Zmy\\/W0nzrsy00JeNUOC4S8xFOfX\\/Y6E6X0e\\/NCtwpMLonj72Z73S8Wu0PwocAABDJK8Cx2reHLO7B\\/v18j7uwygUOA6GfM+D1bw7dPfiaLlBW6Na4EhD7judK6XdfDBmrkl\\/RrnAsSVUCz1570NKmiC2lYLTejUrcKSc14d+dMOdQvN9UeAAABgieRc4Uq6I+cUu79fL+9j\\/YS5wHBPz\\/tDZfn825lWhuurDU2r5s5iXhepIkE92uN10Pvxal\\/ZvuUE7o1rgeHnGdusd50+F6mt1Xq0\\/LwrVVT3aOSfSJJizDfozqgWO5dB47oZGSbex\\/EU4\\/L5Zm\\/TnH+1wu+ln0e063J9WtVLgSBNPD8MKPOeH5vuiwAEAMESyChwXh+ov8O0kLSv5h6F6wfStjO02ygu7uF8nd9D\\/ZnlFRr+HtcBxl5jvhNZfn6+F6kVwmkSw2af2q9JFzs+G6ioSX2yjrZRnrXP\\/kuUG2x\\/FAsfPZGxzbS6ofV8zR4Xqz4ePt7jNLFvD+t97H85o98IubLuTC\\/HHZvQnK\\/8RqvOhnNFmO2fWnvepNtt7YAf71KpWChwpT+hhH7ohjRS7LihwAACMlKwCx391Ydsnxjwm5j0ZbdTLW0LvJpxcr7SiyKgUOO4TWn9N0nwpD+1Su3eIeW4bbb9kne0tN9j2KBY4PpuxzZRLQvV178RTGmw39fe0dfS5FW\\/NaPvVPW63nj\\/J6Eu9pMl6z+pSu6mw+OY22n5Ul9o9UqsFjjS6pdyjPnTD80Jr+6HAAQAwRHpZ4FgrXUz+fUZbRyYVRPpxL3m7RqXA0eotA6mwcU6P+rAjVEfstNKP9VzELjfY7qgVOH4lY3spXwnVguN6\\/Hi45cisd8YsrXO7rRiUAseLM\\/pxZP455jY96kO6BeUtLfbjMT1ov9UCR0q3bz3slnRLVbqNRoEDAGDE9KvAsSr90t\\/K\\/eXpF\\/hSj\\/rQqVEocKRPk1v5pb5fw8tvHZqvYpDy3A63v9xgm6NW4LgwY3tpGP5t19vZmrSd79W2+\\/zQv0\\/oB6HA8aSMPhz52v1cn\\/qTljdtZQ6Qbi\\/L3U6B42NdbrtbUtGi1X1Q4AAAGCL9LnCselxGu2vzVz3uQ7uGvcDxYzGXhcbH\\/F0xe3Po2x826VfKr3ew3eUG2xulAseWjG2lPLsbnV0jzQtxbpe32UzeBY4HZbR\\/5M+rRpOt9kKaPyRrbqC1uWMX22ynwJFyZhfb7oZizJeCAgcAwEjKq8CRpNEcjeYMSHlkH\\/rRqmEucMyH6mva6Fg\\/L7feVaVJaq8Ijft4jza3udxgW6NU4HhoxrZSju9GZ3OWZ4Hj9jFXZrSf8qOY+\\/ahH42kn5ONJsxMIz22dqmtdgscecyT0siB0F7\\/FTgAAIZIngWOJN2\\/3+iWlatC94bXr9cwFzjeEBr\\/Ev\\/Y\\/Lp2M+m1Tqu1ZPUz\\/d3mNra33GBbo1TgyLp9ol\\/v417Lq8CxGPM\\/GW2npHkc7tTjPrTq3qHxe\\/zCLrXTqMDx3Yw\\/P7pLbXdDu8tiK3AAAAyRvAscSVpy9JMZ\\/Riki7RhLXDcLzT+Bf6P8utaXWkSxUafmL+2jW0tN9jOKBU4np+xrfd1paf5y6vA8ecZ7aZcG\\/PTPW6\\/Xc1upXlYF9q4bYPtPyfjz7t9m1Sn0q069fqX5grJGk34O7n0FACAjgxCgSNJn\\/A1+uT+D\\/rcn3qGtcDR6BPof8yxX43cPzS+UDu7xe0sN9jGKBU4Xpmxrbd0paf5y6PAcauMNlfTq2VY1yvr51TKxTHT69x+owLH6aH+z\\/E0Me3UOtvthn8I9fudCkNZt\\/AZwQEAMEQGpcCR3DmjLyk\\/iDkmhz6tNYwFjnTrSdYxTRfSC\\/l1ral6nwZ\\/LrQ338FynW1spALHJ7vS0\\/zlUeB4fUabKW\\/qYbvd0GhlovUWixsVOPbHPDnj73qxZG07doX685Sk+UnSakAKHAAAI2CQChxJo6UY\\/zanPq0atgJH+qT2myH7eLY7YWce\\/iNU+3pJzCM6eP5y2BgFjmdnbOuKrvQ0f\\/0ucPxERnsp34\\/Z1qN2uyVN4JzV\\/zSaYnEd2240B8dpobqyS71bzNLKJcV1tLteWe+RJ9X+XoEDAGAEDFqBoxKy74VOn77lsYTpqmErcDRaevWVOfarHSfHPDV0Pqx+OWyMAsfvZGwr5axudDZn\\/S5wvCujvZROlivOw5+F7H14+jq226zAkbwk4+\\/vs4521yPdHvO9Ov1JhZhNte9R4AAAGAGDVuBI7pXRp5QX5tivYStwNBq9cVSO\\/eqn5bAxChz3zNhWypu70dmc9bPA0egWjI\\/1oL1emY35Vqi\\/H99ex3ZbKXCcnPH371xHu+uR9e\\/c2n9PFDgAAEbAIBY4kg+H+v26LFRHeeRhmAocaRLOrIuQ5+TYr35bDhujwDEWqkuWZu3r\\/bvQ3zz1s8DxJxltpZzTg\\/Z66fdD9r7cs8NttlLgSN6e8T39XvY73RbzpTr9uCHc\\/GeAAgcAwAgY1ALHz4fsX6J\\/Iac+DVOB42Uh+\\/gN+vwB3bQcNkaBI\\/mnjO2t5vR19jdP\\/Sxw1LsYThnGCVtnQvb50OmcRq0WOM7J+J6\\/67DdTt03ox9HThSrwAEAMAIGtcCRRmnUu2c6j1+Ql8ahIgAAGoxJREFUVw1LgaMQqhMh1uvrG3PsVx6Ww8YpcNw9Y3tr84vr63Ju+lXg2J\\/RTsrvdbmtfnl5qL8\\/l4bqz4p2tVrgSNv+XJ3vuSZmawftdiprPpW7HvF9ChwAACNgUAscyV+F+n37Yk79GZYCR6MVIH4px37lYTlsnAJHkrVc7NqkCSD7eYHZDf0qcDwxo52UYZ235mdCawWJVrVa4Egek\\/F9f9xBu53Imk\\/l03W+V4EDAGAEDHKB40DI\\/kV6dw79GZYCx1NC9nHbnmO\\/8rAcNlaBIxUuLsnY7tqk+TrS8pgz62irn\\/pV4Lgwo53PdLmdfmp0m8rvd7C9dgocWauXpMlPxztou12vyOjnw+p8rwIHAMAIGOQCR1q+L+sX6Z\\/PoT\\/DUuA4P9Tv50V5diony2FjFTiS0zK2Wy+pGJIu4Dpdhrdf+lXguCyjnb\\/scjv99pFQf79e0cG22ilwJM\\/N+N5f66DtduwK1dthWi2uKHAAAIyAQS5wJBeH7n3yuF7DUuD4RKjfz1fm2amcLIeNV+BIfilj21lJF31PjdnchbZ7oR8Fji0ZbaQ8oovt5CHdllRvvz7YwbbaLXDsCdUVS4783nq3iXTT\\/8vo4x9mfL8CBwDACBj0Asc7Q\\/3+dboCwHoMS4HjylC\\/n0\\/Ls1M5WQ4bs8CRnBWqE0m2U+i4IlQLYWkJ0WKX+tEN\\/ShwnJHRRspZXWwnD08I9ffr2x1sq90CR\\/LajO\\/\\/6Q7ab0XWrTHpZ+OmjOcocAAAjIBBL3D8Tajfv7fn0JdhKHDMhuyLj4fm2K+8LIeNW+BIjo15c0Y7zZL68dhQvVjMWz8KHD+b0UbKsV1sJw9pae2sfWv39e2kwPFTGd\\/\\/5jbbbtWjMtp7SYPnKHAAAIyAQS9w\\/Emo379eD2+uZxgKHI3mLTmQY7\\/yshw2doFj1U+G7Ak0m+Xbtb5u6UG\\/WtWPAsd9M9pIGbZVZ45055C9bye0ua1OChzJpzKe0+33YdbytM3aUuAAABgBg17g+L1Qv3+X5tCXYShwpAuxrIuP++bYr7wsBwWOtdI58N8Z7TbLD2KeHfIZ0dGPAkejVZuybmsYFvtC9r7dpc1tdVrg+OWM53R7AtdzMtp5S5PnKXAAAIyAQS9wPDrU79\\/lOfRlGAociyH74sMIDgWOVefGvCOj\\/Wb5bMz+PvRxrX4UOO6T0UbKsI\\/gSBN9Zu3b3drcVqcFjrRyybfqPKfRvBidyDqv79nkeQocAAAjYNALHE8K9fv3tRz6MgwFjjQxZNbFx6\\/k2K+8LAcFjkaODtXzut6EjM3y233sZz8KHHfLaCPl+C62k4fbhux9O73NbXVa4EielvG8J7XZhyxZ+5luaSw0ea4CBwDACBj0AkfWHBwX5dCXYShwJINwQTooloMCRytmQnWlja9n9Ckrr+hT\\/\\/JeReX2XWwnD43m4Di5zW2tp8CxLeaaOs9L5125zX7U87KMfv1aC89V4AAAGAGDXuBIFzD1+ndhDn0ZlgJHukCu18\\/n59mpnCwHBY52pYvBz4fWixzpvTjR4z71o8CxN6ONlJ\\/vYjt5ODdk71u7k8eup8CR\\/F3Gcx\\/cZj+OlG4jqlc8SbfFjLfwfAUOAIARMOgFjn8P9fv3whz6MiwFjqx70P81z07lZDkocHQifZqebmlqtdDxzzGlHvanHwWO1P9rM9r5\\/S62k4esn12XdbCt9RY4sp7\\/sQ76slbW++mPWny+AgcAwAgY5AJH+tSt3idyKb+VQ3+GpcDxolC\\/n9\\/Ks1M5WQ4KHOtRCdVbm74Tmhc5Ht3DfvSjwJH8Z0Y7r+lyO\\/329lB\\/v97bwbbWW+BI3pXx\\/Lt00J8kawLT9O9HqxPEKnAAAIyAQS5w3D1k\\/yL9kzn0Z1gKHI8K2cft1Bz7lYfloMDRDek2hjQCqFGBI03826tbVfpV4PjHjHbyWJa6W9Kyvlmv2Qs62F43Chz3y3j++R30J3l4xvZe2sY2FDgAAEbAIBc4nh3q9+2KnPozLAWOW4fsC5An5tivPCwHBY5uynpPruYJPWq3XwWO38hoJ+UnutxWv5wTsvfpfh1srxsFjrTa05fqPP+GUF3Sth1pdZTPZfTntm1sR4EDAGAEDGqBI\\/3SmrWiw1tz6tOwFDiSesO1Uz6XZ6dysBwUOLrtDSH7mH6qR232q8DRqDh4Xpfb6pd0e03WPi10sL1uFDiS383YxvPa7M\\/ZGdt5R5vbUeAAABgBg1rguEfI\\/iX6N3Lq0zAVOP4uZB+\\/H8+xX\\/22HLKPw23y69aKrCWQB73AsTk0Xk72+B602a8CR\\/LFjLa+3YO2ei3dWpT1On2gw212q8AxG3N5nW1cXvu7Vl2Q0Zdz2thGosABADACBrXA8b5Qv19Xhc4+deyGYSpw3DVkX4S8Msd+9duZIfs43DXHfiVZRajP59mpFj02ZB\\/Xx\\/agvX4WOLJG1qQ8vAft9dJTQ\\/a+PKrDbXarwJG8IGM7v93i82+V8fw0Uq3QZl8UOAAARsAgFjjultGnXl3QtGqYChxJ1ifRKbty7Fc\\/NboYe1CO\\/UqyVrb4eJ6datFMzPdD\\/f6\\/pAft9bPAsTejrZTP9KC9XkmTi6ZRJ1n70mmhuJsFjjTfxg11tpPm5yi28PyXZPSjk+KNAgcAwAgYtAJHKebTGX1KaWfSuG4btgLH48NgForasRxzYcwJHT5\\/d8g+Bk9af\\/fW5fOhfr\\/anTsgL1lLfV7Qg7b6WeBI\\/iWjvZS8bpFrV9bPq5S\\/Wcd2u1ngSN6Usa1mE6BuirmyzvO+F6rFnXYpcAAAjIBBK3A8IaM\\/Ka\\/LqU+rhq3Ake5jT7\\/sZx3Pe+bXtZakJUf\\/Oxzub5p8cK7NbaSC2bWh\\/v6\\/t1sd7cBtMvqU8pc59qsdWZ+e\\/2cP2up3gePOGe2tXkBv61G73XJyyO5\\/ynom2O12gSNrOfD3NHneUzKe98wO+pAocAAAjIBBKnA0uqhIuXUOfVpr2AocSaP5BL4ZBvtWlaeHW\\/b5azEPbnM7H6uzndXs6FZn23SwQZ+GZYTAH4b6\\/f9qD9rqd4EjeW9Gmynv6mG765UKmxeF7L6v95h1u8CRfCpje1kj9sZD\\/ZWirgmd\\/0xT4AAAGAGDUuBInzg2Wpnh2X3uTz0vDPX7NshLr6a5Ei4O2cf1Q6E6UmLQpPkxGhW77tXGtp7bYDtP7l6X2\\/KlBn36sXVsNxVsnrHu3rXm+aF+\\/z\\/cg7byKHDsz2hzNS\\/qYdvr8cbQuN\\/HrXP7vShwPDxje6\\/I+P5fafP7W6HAAQAwAgahwLEv5hsZ\\/UhJF+gzbW5zMeasUP3l9O9jjupCP8\\/P6N\\/7u7DtXvqF0PiCJ803UMqtd7eUhqxn3VaS8uY2t3evBtu6InTn3GjHkxv0p9PRD9Ph5qNC+rFCzOtC\\/X14fQ\\/ayqPAkWSt8rGaJ\\/S4\\/Xb9VWjc3yd2oY1eFDgajcjYWuf7s+ZpWs8cTQocAAAjIO8Cxxkx38noQ0q60L1ji9tK35eKEF+os52f7kJfv5LRx3\\/uwrZ77TWh8YXPP+TXtZtJ84L8IGT389LQ2fwHlzbY5t+uu9et2xmqRZWsvvy\\/Drb5q6F6687a7by3C31tJI36yZrf5YU9aC+vAkea8+VzGW2v5jE97kOr\\/jw07ueHutROLwocyTMytnnknBpZq2yt97YhBQ4AgBGQZ4Gj2W0IKY9tY3tnNdhOJxeOa53QYNvDMClkGgHTaHWalHeGzpeO7Ib7ZPRrbe7b4baf12S7v7KejrcojbL49yb9OLHNbTba3m91pdf13b9Bu+f2oL28ChxJumWoUVEq5bl96EeWdF69NqNfq7kkVItr3dCrAkeaO+O6Ots8clWUrBVuOv3ZsEqBAwBgBORV4Ph\\/Ge2uzUvb3ObmBtv67x7292Hr3Ha\\/nBQar6qyepxuk0Pf\\/qBJv1LWczvA9pgfNdh2Gil0l3Vsv5l0C9AFDdpP+fsOtvuiBttL+7u8zn7XMxayl7i9KlQnuey2PAscyQMy2l+bt4T+FwiPjfl4C327Uxfb7FWBI3llxnYfWfv7tPrLDXX+Ps1pU1xn2wocAAAjoN8FjvSL6sUZba7NWzvcfqPh5J1+op0++byswXb7PYfDejRbqSbl+6F\\/w+7Tp+MfaqFPL+5CW1lD4FeTbo15eBfaOVI6P97RQtvHdLDtY5tsN4086ObFbXJeg\\/be0OW2VuVd4EgaLWG9mlT4uVuf+pNGHTW69Wo1D+hyu70scNwxY7vp53ohZBf0ujFaSYEDAGAE9KPAMR\\/zmyF7Dosj84FQvfe9E41GAqSLyHZ\\/AU+3djS6DeA\\/Ouxnnlr5NDrlg6F6208vnBmqIxZa6cfrutTmZMwXW2gvfYrcrU\\/i0wSn9SZP7OZFVL3ldI\\/Mvdex\\/bX+uEk77axu045BKHAkf5nRjyOTVvPY26M+pCLAO1vsRy8uzntZ4Eg+mrHtrFsaj7yFpVMKHAAAI6BXBY5U1Ei3brwpY\\/tZScP4J9fR7s4m209L0e5vcVupyPK+Jtv7tXX0NU\\/pfvVWX5NU6EivZadFp1XpdU2fOn+4jbZfts42j3SHmCtbaDcVJdJ7o9JhO+ki8MIW2klJtzasZ3h9OVQnFW3URprb4O9iju6wjbSMc7P9ubDTHWjBoBQ4kudk9KVeXhWqE+euV5pn48Ex726j7d\\/oQrv19LrA0Wh+l3p5VhfaTBQ4AABGQFaB49sxT2kz6RaAdBHV6oXdkenW6gsvbKGtNMw+a3WWtMRsKyNOvtKl\\/ublp2K+G9p7jdISoOeG6jFqJs3F8BO170\\/LbTa6zade\\/mz9u1hXqyNYUv4nVCeQvF\\/MpibbTfv6+FAtWLS6\\/fRpdbtLINeT5hipt3pQvbwxVI\\/BUgvbfGjM21rc7q27sB9ZBqnAkTw+oz9ZSe+ztFrPz7TRRnqPPSRkL8fbKA9cz8410esCRyrYHbkqUFZS4W5XF9pMFDgAAEZAVoGjn0lzPvxiF\\/cp3V7w9RbbTpPTpYukVJz569B8xMba9GPljV7bHfNvobPXLa3M8LFQXdUgHbvVY5iGz3+jw22mpFuJHtHDfQ617XfSt6+GagHvJaE68WxaIrjZ6jRZ+VSoTozbLWn00n+22Yc0qWyaNyPNcfLHtcc06qqVW3n6eRE4aAWOJN2+9c2MfjXLl0P1Z00qXqSCbDr2fxWqxz7dEndJh9tNc1Wc2sudDr0vcCRPbNDG2ryqS+0lChwAACMg7wJHGhHQ6bD5Ru7Z4353suLFIGs2AWe\\/8p5QLbr0QxoK38rtKr1IKpLM92CftoXsOQx6lfWsbtOqQSxwJOl4vybk\\/75JSaPSujEXRTP9KHCk0VKtvDfP6FJ7iQIHAMAIyKvAkSbnbGe4dic6\\/ZS+WdIcEuuZJ2RQnRCyLyR7nXT7ymN7v4u3cNvQeOWdXuRJPd6ndJH72j7ty2\\/2eF9WDWqBY1UazdHv82g1aRWi2\\/Z+F2\\/SjwJH0mxC1\\/d3sa1EgQMAYAT0u8CRPrn+2b7sWdXDu9z\\/NCR6uo\\/9z0N6fT4T+nM+XBPz56G7t2q0KxUEXhB6v6+fCNV5OvrlyaH9OVZaTZrv4\\/T+7crAFziSNCFtKtKl+Yv68d5J88P8Uqgun9pP\\/SpwnNygnZT7d7GtRIEDAGAE9KPAkeZpSMu3HtenfTpS+kW5nbk16iXN6fGofnc8Z2l\\/PxJ6c06ki8AXxRzft71pLvUlzSFyRejuvqZz70F93I+10kSvaULMVicgbZY00uZ5oTsTo7ZjGAocq9LkoGnp3q+E3rx30pwvv92vnamjXwWO5IKMdtLcSetZeageBQ4AgBHQjQLH5TGfD9WlKtOEhX8Tqr\\/gp5n8m63U0E9pidB0Afud0Pq+pU\\/dfz1mIof+DooTY54a866wvvPk46E6WuOs\\/na\\/beniPa0eknVx1UrS++FpoXrsBkUaPfL8mItC+\\/uTVlJJK3rkdWvWMBU41rpLqBaE0s+R9bx3UpHsYOjvrShZ+lng+JmMdnpRdFDgAABgaKVix+NC9YL7laF6MZvmLUgrGaQVDVpZRnMjSrdzpOVlHxOqqz+kC88L1yQtQfqKmL8I1QuyXw39vZWhF9LcJHcN1bkz0qoXFx6RdO48K+Y+oXoB2mw52UGQloBNtzekQmRaOeX8UC1i\\/FOovgf+NOaRMbfPq4MjKP08Sbd\\/pUlZXxbzjnDLcyklvafS6Kb0HkvFwFG\\/JQ4AAAAAAAAAAAAAAAAAAAAAAACANvxDzJUiIiLStbw0AADQd2nlh\\/UuBSsiIiKH86oAAEDfKXCIiIh0NwocAAA5UOAQERHpbhQ4AAByoMAhIiLS3ShwAADkQIFDRESku1HgAADIwdNi3i0iIiJdy5MDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD\\/vz04JAAAAAAQ9P+1wRsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAL6JKIFTUgrE4AAAAASUVORK5CYII=\\\",\\\"unitDim\\\":\\\"px\\\",\\\"height\\\":1350,\\\"width\\\":1080,\\\"name\\\":\\\"2000 2000 (2).png\\\"}],\\\"styles\\\":[{\\\"selectors\\\":[\\\"#igyb\\\"],\\\"style\\\":{\\\"max-width\\\":\\\"100%\\\",\\\"display\\\":\\\"block\\\",\\\"border-radius\\\":\\\"8px\\\",\\\"width\\\":\\\"177px\\\",\\\"height\\\":\\\"222px\\\"}},{\\\"selectors\\\":[\\\"#i1uk\\\"],\\\"style\\\":{\\\"padding\\\":\\\"0\\\",\\\"text-align\\\":\\\"center\\\"}},{\\\"selectors\\\":[\\\"#iosh\\\"],\\\"style\\\":{\\\"background-color\\\":\\\"#bdeae7\\\"},\\\"wrapper\\\":1},{\\\"selectors\\\":[\\\"#ie5ff\\\"],\\\"style\\\":{\\\"margin\\\":\\\"0\\\"}},{\\\"selectors\\\":[\\\"#iibsm\\\"],\\\"style\\\":{\\\"padding\\\":\\\"20px\\\",\\\"font-family\\\":\\\"Arial,sans-serif\\\",\\\"font-size\\\":\\\"16px\\\",\\\"line-height\\\":\\\"1.7\\\",\\\"color\\\":\\\"#374151\\\"}}],\\\"pages\\\":[{\\\"frames\\\":[{\\\"component\\\":{\\\"type\\\":\\\"wrapper\\\",\\\"stylable\\\":[\\\"background\\\",\\\"background-color\\\",\\\"background-image\\\",\\\"background-repeat\\\",\\\"background-attachment\\\",\\\"background-position\\\",\\\"background-size\\\"],\\\"attributes\\\":{\\\"id\\\":\\\"iosh\\\"},\\\"components\\\":[{\\\"type\\\":\\\"table\\\",\\\"droppable\\\":[\\\"tbody\\\",\\\"thead\\\",\\\"tfoot\\\"],\\\"attributes\\\":{\\\"width\\\":\\\"100%\\\",\\\"cellpadding\\\":\\\"0\\\",\\\"cellspacing\\\":\\\"0\\\",\\\"border\\\":\\\"0\\\"},\\\"components\\\":[{\\\"type\\\":\\\"tbody\\\",\\\"draggable\\\":[\\\"table\\\"],\\\"droppable\\\":[\\\"tr\\\"],\\\"components\\\":[{\\\"type\\\":\\\"row\\\",\\\"draggable\\\":[\\\"thead\\\",\\\"tbody\\\",\\\"tfoot\\\"],\\\"droppable\\\":[\\\"th\\\",\\\"td\\\"],\\\"components\\\":[{\\\"type\\\":\\\"cell\\\",\\\"draggable\\\":[\\\"tr\\\"],\\\"attributes\\\":{\\\"id\\\":\\\"i1uk\\\"},\\\"components\\\":[{\\\"type\\\":\\\"image\\\",\\\"resizable\\\":{\\\"ratioDefault\\\":1},\\\"attributes\\\":{\\\"src\\\":\\\"data:image\\/png;base64,iVBORw0KGgoAAAANSUhEUgAABDgAAAVGCAYAAAB7TwuKAAAAtGVYSWZJSSoACAAAAAYAEgEDAAEAAAABAAAAGgEFAAEAAABWAAAAGwEFAAEAAABeAAAAKAEDAAEAAAACAAAAEwIDAAEAAAABAAAAaYcEAAEAAABmAAAAAAAAAGAAAAABAAAAYAAAAAEAAAAGAACQBwAEAAAAMDIxMAGRBwAEAAAAAQIDAACgBwAEAAAAMDEwMAGgAwABAAAA\\/\\/8AAAKgBAABAAAAOAQAAAOgBAABAAAARgUAAAAAAADTyGbmAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAFXGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSfvu78nIGlkPSdXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQnPz4KPHg6eG1wbWV0YSB4bWxuczp4PSdhZG9iZTpuczptZXRhLyc+CjxyZGY6UkRGIHhtbG5zOnJkZj0naHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyc+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczpBdHRyaWI9J2h0dHA6Ly9ucy5hdHRyaWJ1dGlvbi5jb20vYWRzLzEuMC8nPgogIDxBdHRyaWI6QWRzPgogICA8cmRmOlNlcT4KICAgIDxyZGY6bGkgcmRmOnBhcnNlVHlwZT0nUmVzb3VyY2UnPgogICAgIDxBdHRyaWI6Q3JlYXRlZD4yMDI2LTA1LTA3PC9BdHRyaWI6Q3JlYXRlZD4KICAgICA8QXR0cmliOkRhdGE+eyZxdW90O2RvYyZxdW90OzomcXVvdDtEQUhHWXBzZmxSTSZxdW90OywmcXVvdDt1c2VyJnF1b3Q7OiZxdW90O1VBRU9OVndMYVdZJnF1b3Q7LCZxdW90O2JyYW5kJnF1b3Q7OiZxdW90O1RlY25vRmlicmFzIFMuQSYjMzk7cyB0ZWFtJnF1b3Q7fTwvQXR0cmliOkRhdGE+CiAgICAgPEF0dHJpYjpFeHRJZD44NGRkMzJmMy0yNzZiLTQ3ZjctYWZmYS04NTM0YmMzM2VhMDA8L0F0dHJpYjpFeHRJZD4KICAgICA8QXR0cmliOkZiSWQ+NTI1MjY1OTE0MTc5NTgwPC9BdHRyaWI6RmJJZD4KICAgICA8QXR0cmliOlRvdWNoVHlwZT4yPC9BdHRyaWI6VG91Y2hUeXBlPgogICAgPC9yZGY6bGk+CiAgIDwvcmRmOlNlcT4KICA8L0F0dHJpYjpBZHM+CiA8L3JkZjpEZXNjcmlwdGlvbj4KCiA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0nJwogIHhtbG5zOmRjPSdodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyc+CiAgPGRjOnRpdGxlPgogICA8cmRmOkFsdD4KICAgIDxyZGY6bGkgeG1sOmxhbmc9J3gtZGVmYXVsdCc+MjAwMCAyMDAwIC0gNDwvcmRmOmxpPgogICA8L3JkZjpBbHQ+CiAgPC9kYzp0aXRsZT4KIDwvcmRmOkRlc2NyaXB0aW9uPgoKIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PScnCiAgeG1sbnM6cGRmPSdodHRwOi8vbnMuYWRvYmUuY29tL3BkZi8xLjMvJz4KICA8cGRmOkF1dGhvcj5EYXZpZCBBbHBpemFyPC9wZGY6QXV0aG9yPgogPC9yZGY6RGVzY3JpcHRpb24+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczp4bXA9J2h0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8nPgogIDx4bXA6Q3JlYXRvclRvb2w+Q2FudmEgZG9jPURBSEdZcHNmbFJNIHVzZXI9VUFFT05Wd0xhV1kgYnJhbmQ9VGVjbm9GaWJyYXMgUy5BJiMzOTtzIHRlYW08L3htcDpDcmVhdG9yVG9vbD4KIDwvcmRmOkRlc2NyaXB0aW9uPgo8L3JkZjpSREY+CjwveDp4bXBtZXRhPgo8P3hwYWNrZXQgZW5kPSdyJz8+6JVLDgAAIABJREFUeJzs3QucXXlBH\\/D\\/edzHzL137ryTzWZD2KRsG2GXNaIuIAQBEVrUVlNFtFItW6VKX7i2aCUisKw8FlAei0qrFNQtSq20FC2syMpredR3axUtoPtxLbC47DPJTM+5904yj3snyZw5c2fu\\/X4\\/n1\\/ObDaEzf+ef3LOL\\/\\/zPyEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAnPPkLB8V2eHcMTE19fwAAAAA2yJJTkYhPpt9dUZkB7PUaLVfHgAAAGA7JEnyrSFES9mXeZZFdiCd822i1boxAAAAwHZIqsm3KThkh6PgAAAAYHspOGQIWSk4PKICAADA9lBwyBCi4AAAAGB7JUnyrNC74QzDv\\/GV8YhHVAAAANheSZJ8e1BwyM6mW3C02woOAAAAtkeSJM8OCg7Z2XTOt8l2+2UBAAAAtkOSJN8RFByys1FwAAAMQbTFsDO2+vn47KAnSZLvDAoO2dl0zrdmq\\/3SAABAeZaXl6NVifPcurycrGS5m\\/gCiQZl2L++vWazsVw\\/7iuf0anbbktXcv0tt1ROnjpVXZ\\/8+\\/PkP+bWtZ+pz4ixouCQIaRzvjVaVnAAAJSi0m5\\/RbXZ\\/HeN6embW9Ozr27Nz7+6Obfwuqm5xTe0Zxff3J5ffHNrsZNbphYX35jlp6YWsn+fJftxr82Tff2aZjc3t+YXX5X92Fe2s2Rf\\/0SWm9oLiy9vLSzcmOWl2Y99ydTcwo9nP8+Lp+bnT2V50dTs7I\\/mac7O\\/rtO5uZ+JMsPd48LK\\/nh1tzcC1szc\\/+2NTPzQwNyQ5YfLDk39LL6\\/3P9f8e\\/WUmj+8\\/5f3P+3\\/7C3q\\/tR\\/Jf58qve2q2Mw4\\/lo9L9u9e0ppbeGmWG1tz8zdln0c+hq\\/ojeurm\\/MLN2c\\/5rXNmXz8536qOTf\\/hsmZuTc2Z+ZvmZyd\\/eksPzs5Pf3vJ6dnfm5ievqt9ZmZt2d5W+fYnnnbxPTMW7Pv\\/\\/nJ6dl\\/35ie\\/ZnJmdk3NWfmXt\\/IP\\/u5uRubs\\/M\\/lv+3NmZnX5CdE\\/98cmrqnzWbzesbjcZ3TTSb31prtb6h0W4\\/uX3Z\\/Je39+17+OTk5IHQbC5MHz48ffC66ybCyZNJsCqEPUDBIUNI9xEVKzgAALbfrbfemlQnW2\\/Jvnwwy+ksZ1bl7CY5UzCnZWAudSw3+5wuJX0+m+ih7JgnPz8eyHJflnuyfCHLXVk+G6Lo\\/0ZR9EdprfaBSrX+C3G1emM6MfGvJxqNZ03Mzj52\\/qqrrrr2cU89cP2pU5MBdhEFhwwh3YKjqeAAANh2J289Va01Wu8OnRvcaOVC\\/2Iu+Nf\\/WNnhRN3kz5Vs64X3Bf9\\/o2hDBvzYvBD5Yoiiv4zS9Pertfp7klrtJ6uTkz\\/cnF34h3P79z9mcXHxynzlx+HDh+vhVIgD7CQFh+x8egVHS8EBALDdTt56a7XWaL4ndP8Gf9gXfrJ306\\/gGPT9+bmWrxC5P8tfRXH8sbSavqM1N3fD\\/OWXP+nqr\\/zKh5\\/sPuYCpbKCQ4YQBQcAQFlO5QVHc0rBITuZ86s\\/wpoVIA+FKPpCFMd\\/GiXJ+2r1+ptrzeb3ziweeNyRI0cWr7\\/++kqAbZQkyT8KCg7Z2Sg4AADKkhcc9ebU\\/wgu8GV3ZN1qj0758aXs+Pu1yebrpxcWnvPwL7v2mhMnTjSz71\\/ZzBS2Jkm+Kyg4ZGfTLThaCg4AgG33A697Xa3eaL0vuMCX3ZUN+35kx7PZ8YEoiv8iSpIPJ7Xam5szM9fPzu4\\/dtVVV7UCXCoFh+x8FBwAAGXpFBxNBYfs7kRRtHJcv7lpvpfHnVGU\\/Hp9svmimcWZxy0sLOw\\/fvy4x1m4sCT5x0HBITsbBQcAQFme3ik4mu8NLvBlb6Xf5qV52XF3FEWfrExMvKY9O\\/vUr3r2s6cCDJIk\\/zhScMjORsEBAFCW7gqOqd8INhmVPZ4Nr62NorvTNL2tWq\\/\\/WKPdfsq+I0cWw6lTXkXLOUmSfLeCQ3Y4nfOt0Wq\\/LAAAsL3y18TWp9p5weECX0YtK5uU5l8\\/GKLod6r1yRcefeTxI8vLyyubk9qkdIwlSfI9Cg7Z4Sg4AADKkr9FZbI9\\/evBCg4Z0USdTUrjXtkRPZR936eTSvUXq43Gd1x+9OjBwNhScMgQouAAAChLXnA0ZmffExQcMh5ZvWfH2ShNPzw5NfW8K44+8kj2z9VgRcdYSZLKP1FwyA6nc741W217cAAAbLdewfHfg4JDxiurXkEb3xfF8R8ntdot7X2XP\\/nqr\\/u6RmA8VCrPVXDIDkfBAQBQlltuuaXSmpl9d1BwyNgm35g0WXmE5Z4kTd\\/dmJl51uyBA1ecOHEiDYysOI6vV3DIDkfBAQBQlk7BMTv7X4OCQ8Y6UX7s3ehGZ0MU5as6fq\\/ZnHr+tdd+zUJgJMWVyvcqOGSHo+AAACjLLbd8rNKamX9XUHDImCbq5dw\\/d141u7Ipabg3SZKPTDSb33\\/ZZZc9LASvmR0llUrl+xQcssPpnG+TrZaCAwBgu93ysU7B8V\\/CuYIjGvbFn8huyrkNSbP82exlB5\\/7zOuvnwxdNiTd4yqVyvPiSMEhOxoFBwBAWW67bTlVcIhsnnxVR+g+vnJvlCR3TEw0\\/vllD3\\/4wwJ7Wl5wRAoO2dkoOAAAytJ7REXBIXJROffoyukoiu5ozMw8+8AjHjEf2IuiSqXy\\/R5RkR2OPTgAAMpy23JnBcevhnMX+AoOkQtkqbtPR7SyouO97dmFf3j8mc9ceXSFvaFTcOSPqEQKDtm5dAqORqv9sgAAwPa67bbb0tbc\\/DuDgkPkUrPyatl87tyTVCr\\/YWpu7jHHjh2rBvaCvOD4AQWH7HCs4AAAKMup225L23OLCg6RradzwxJFUf6Y111prXrTw44fvyyw250rOIKCQ3YuVnAAAJTltk7BsfArQcEhUjQrj62ciaLkQ\\/VG47uuvPLKdmC3imIFh+x8FBwAAGW5dXk5ac8t\\/nJQcIhsV1ZumE8nlcovTh84cO3JkyeTwG7TWcGRKDhkZ6PgAAAoi4JDpJSs3DSfyfKptDpxw\\/6jRxcCu4lHVGQYUXAAAJSlV3C8I3Q3TFxWcIhsa5ai7g30mSiK3jc1u++rg01Id4vuW1RiBYfsaHoFR0vBAQCw3fKCY3p+\\/629t0EsKzhEtjf5vhxxHOc3NfkmpHemtdoLTp46peQYvk7BkSg4ZGfjLSoAAGXpFBwLCg6RHcjKjfSXoiR5x2S7fTwsL0eBYckLjn\\/mERXZ4Sg4AADKkhccM\\/P7f0nBIbJj6b1tJfxFa27um3obkCo6hqBSqTyvW3BECg7ZqSg4AADK0i049v1SsAeHyE5mZdXAXXGavmT+iisOBCXHjqtUKt9nBYfscGwyCgBQlk7BsbC\\/V3DkF18KDpGdSm8lx5koSd4ze+josezrOLBjFBwyhCg4AADKouAQGWpWHlc5E6Lojyanp78hsGPiSuV784IjUnDIzkXBAQBQFgWHyK7IStFxZ21i4gWHDh2aCZROwSFDiIIDAKAsy8vLsYJDZLiJomg5juKlOO6UHPcnSeXnrrr2WvtylCyuxB5RkZ2OggMAoCwKDpFdl3wunk7S9L\\/PX375IwKlie3BITufXsHRUnAAAGw3BYfIrk0+Jz+8\\/9ChLwuUQsEhQ0jnfJtUcAAAbD8Fh8iuTedGKIqiT07Pzz\\/x1KlT3rCyzeJK5XlRUHDIjkbBAQBQll7B8YtBwSGyW7MUovDpyZmZZwSvkd1W+QoOBYfscHoFhz04AAC2nRUcIrs+3RvwKPrURLP5zSGcSAPbIq5Uro9DpOCQnYyCAwCgLJ2CY58VHCJ7IPkc\\/Wy12TwZTig5tkWl8k8iBYfsbBQcAABlyQuOWQWHyB5IfiOe5PP08\\/XJye\\/OjkmgkCRJvlvBITucbsHRVnAAAGy77gqOfQoOkT2Rczfjf1lvNJ5z\\/PjxSmDLkiR5TrAHh+xsFBwAAGXp7sGx7xeCgkNkD6VTdHx+dmHh6wNbliTJPwrnCw4pJ7tgvuyqKDgAAMqi4BDZk1l5hewnLjvyt48HtiRJkmeHVTfj2XiubOi69p\\/XfX2h5D92fS72fzvo59nK\\/77fz7fx+7rZrp9\\/1VtpluLuf\\/uw58pui4IDAKAsCg6RvZveDev\\/nplZfFxgKx6d5U1ZXt\\/LLVl+Osube1\\/n\\/+6NWd6Q5aey\\/GSW12V5bZbXZLm5l1evOuZ51eDEeV65Kr3v2+x\\/08kFft5zeeUF\\/l2eV\\/TyE9n\\/d56bsq9fnuXGLC\\/r5cd7efGqr1\\/SS\\/bv4xu7\\/\\/tOXtH7+W\\/ujU8+Zj8TouiD2fFs2AVzZRdFwQEAUBYFh8jeTXR+pcEd+6448sjApYqyVLNUeqn2SWVV0gFJRiDxFrP651gZj3zcatXW9Ddmxwet4lgTBQcAQFk6BcfivreHzkVXfrPkQlRkD+ZslCS3z19+5SMC7BJpvf7E7HBvsBfH6ig4AADK0nlN7OJlnYIj8ry0yF7O2ZAkH2nNz18VYBdIJyYemx3+JnQL9GHPj92STsEx0W7fWGhwAQDYaF3BsazgENmzWXlc5Tcuu+yyhwUYsjStPz47fMnqwI3ztKHgAADYfgoOkVFK50bydFKpvP3w4UdPBxiiNE2fkB3uU3CsiYIDAKAsq\\/fgUHCI7PVEKxuPPpRWq6ey+Z1voglDkabpE7PDAwqONVFwAACUpVdwvC0oOERGIt15HOc3lJ+vN6a+PXTfagE7rreC434Fx5ooOAAAyrJmBUd+czT8iz8R2ZZ0VnLcOTE7+9UBhmBtwREU6N0oOAAAyqLgEBnNxHGcr8rKXx9724ErrzwUYIelafo1QcGxPgoOAICyrHlEJSg4REYsndc\\/x0nylgMHDkwG2EG9guM+BcfaORkUHAAA5VBwiIx2uvtxhHtqExPPP3XqVBxgh6RpPS847lVwrImCAwCgLKsfUell2Bd\\/IrKtyW8qu\\/txNKennxRgh6Rp+vjscG+vZFu20WgnCg4AgLKsKziGfeEnIuWkc1MVJcl7H\\/3oE9MBdoCCY\\/BcVHAAAJTACo6Luxgdgwx7nKXk5HtxZHkgrVZvOnjddRMBSpbWu4+oKDjWRMEBAFCWvOCY6+3BEdzonkv+rHgv2U1hd6PGlTHq3SieS+juX9JJGJDN\\/l2\\/H3uhn2\\/1zxldKH3+ewf9OjbJ0D8T2Zbkn+WD9ampbw9Qsl7BcZ+CY8McVHAAAJRh9SajwY3sufQ2w\\/tClKa\\/HOL4lhAnb8yOb87yM71k3xe\\/KcsbsvxUltdleW2W12S5uZdX9\\/KqVXnlqrxiXX5iVVb9c3pTLy\\/P\\/jnPTef+Xej8PK\\/Kjnlu7uW1vbwu+zW8Pssbs7wpy09neUuWn8+Sr9r5pSy\\/kuW\\/ZXlfltuzfCjL\\/8zyZ1k+FzpvQAhnwgXKlmF\\/XnLRWSm3Pnrg2LFDAUqk4Bg8BxUcAAAl8BaVtYmipLtyI9+UMQqfPHjNNZcXH+U9Iw4nQhpmZtqhVjsaKuGrQxKemX3\\/92d5VZZ3hG4J8r+y3JPldHa+nA0h9FsBMvTPUjbNmaRS+VmPqlCmlYJj5S0qCo5OFBwAAGVRcKxNFMXnC458JUOjsS87RkXHeQTkY5BmyW+IF0O1enWoJt+Uff2jobsi5HeyfDH0X+0x9M9V1iaOO3+jfu9Ee\\/Zb1n\\/QsF0UHH2zUnC8vNjoAgCwwaqC46yCI0\\/cO3YuyD\\/eWFzcV3SMx0ASJsNlIQ0nsq9\\/MMtbs\\/xhlrtDXnhs3ONjF3zOEvI5H0UfOnDkyBUDPlcoRMHRNwoOAICy9AqO\\/xgUHL2sKTg+oeC4ZHGWepa88Hha9k\\/5Rfzvhc6bFJQcuyz553A6rVRuDkeP1gZ+orBFaZo+ITvcr+DYMO8UHAAAZVBwrE0Uot4YdJbwf7KxsLC\\/8CCPt7jRaOwPSfL3Qhznm53+QZa\\/Cave4hJ2wec+rumN\\/53N+f1PvMDnCJcsTdP8vHpQwbEm9uAAACjL6oIjDP\\/CbxelW3CEhYaCo7jze5gcW2jWGrWnZd\\/zqyHfsyNaWdGRj7ebn2EkiqKzIUl+\\/dCjHjWz2YcIl6perz8pm9cPBqu2VkfBAQBQFgVH\\/\\/T+ZvuTwQqOcuzb1wiVyvE4jl8Uuq+lvT94fGUY5\\/nKuf5AZWIif1uODXXZNmm34DgdzOvVUXAAAJRFwTEokUdUdkir1ZoLcXhe9uXvhm7RcbZz0x25KdrB5I8L\\/c7hxxxzvrNt0nr9ayMFx4a5FhQcAADlUHAMSm+TUQXHTkmyXB6S5Huy4weyPHD+8ZVhnwujn95+KA+m1dpPhGPHqhf1icEFpPX6k6MQnTm\\/B4cEBQcAQHk6Bcf8SsGR74FgH4RuvEVlaA5OzWbfPjfL+7N8IZx\\/dMVNUnnn+8o5\\/7mJiamvvqjPCS4grdefEvJXRdtkdHUUHAAAZVFwbHoR+nEFx9DEs7OzU9VW6+9nX38iKDh26pxfiuPkl06ePGUVB4WdLziCgmPdPFNwAACUYO0jKgqOVekWHI2GgmPIaq3WI0Ic5zcDnwm918uG4Z8fo5p8bO9OJie\\/KdhwlILSRuOpkYKj3xxTcAAAlMEKjk0vQj\\/ebDYXi40w26U+0\\/qa7PDBLGd6JYeio4T0xvb20GrNX\\/SHA330Co58fycFx\\/msFBwvLza6AABsoODY9CJUwbG7RNnnsRDHcf460z8OK29bGf65MlLpjel9SbX6bZfw2cAGaa32dQqODbGCAwCgLN6isulF6CcUHLtTZXLy2uzwrixfCvbnKOf8j6L\\/sm\\/fvsbFfyqwloJjwNxScAAAlKO7gmNRwdH\\/IlTBsXvl+0NMx5XK87PjXUHJUcb5f9fE3NxXXvxHAmv1Co5V81LBETyiAgBQHgXHoEQKjr3g1Km43mo9PvvqtiwPxXH2uUXDPndGIvn5fzau1l+cHZNL+kygJ63VnhYUHP3mloIDAKAMCo5BiezBsXdErcsvnwtx\\/MYohAciKzm2I0tRFOdvrPndw49+9PQlfyIQugWHFRwb51ZQcAAAlGPtJqNDv\\/DbRVFw7DWzs7NTcRy\\/IPvyL8OqR1aym\\/RdcD7tyeTj96XW3Nw3XuJHAR0bV3BIUHAAAJRHwTEoCo69KqlW8xvyO4N9ObYjS1GSvvPEiRP10N33BC5aWqt9fTAHN8ypoOAAACiHgmNQFBx7WDoxMfHYEEUfzJfHR8GrZAskH7vPTczOXnfpHwPjTsExcE4pOAAAyqDgGBSbjO51jUbjUdnhN6MQHgpusraafB+OpThNX3TpnwDjLqnVnh7MvQ1zKig4AADK0Sk4Fm0yujEKjhEQTczOHsyOvxY8rrLVdMYtipL3H37Oc+qX\\/Akw1hQcg+dUo92+scjYAgDQh4JjUBQco6Jer1+ZHX41CuHB4Gbr0hN15sJftxYXPabCJVFw9I2CAwCgLAqOQVFwjJL9R48uhCi8J3TPczdcl56lOKm8IZw8mWxh+BlTCo7+cykoOAAAyqHgGBQFx6hpzc9fFaLot6IoOhtFNh69xOTj9b8mJycPbGnwGUsKjoFzScEBAFCG7iajCo6NUXCMonpr5vHZ4dPerHLJycfrbL3dfspWxp3xVKvVnhGGf+7utthkFACgLAqOQVFwjKi0NjmV\\/63yn\\/dWcuyCc21PpFMIpdXqy7Y27IwjBcfAuaTgAAAoQ\\/cRFa+J3RgFxyiLK5Xrs8O9HlW5+ERRvBSi6IPXXXfdxBaHnTGj4OgbBQcAQFnswTEoCo5RduD48cmQpq\\/Mvnwo2CPgopKveMmOd1Xm5h6ztVFn3Cg4+kbBAQBQFgXHoCg4Rl3rwIH5EEXvz1dxWMlx4fTG6Eyc1v5Vdoy3Ou6Mj17BsRSUiKuj4AAAKIuCY1A6N3MfV3CMtqRW+4bscL+C48LJ9yvpjFMUvTMsLDS3POiMjVqt9nfDLjh3d1kUHAAAZVFwDIqCY0zUs+Sva3wg+Fvmi0k+Rn8SpusP29JoM1YUHAPnkIIDAKAMCo5BUXCMjXo4lH17e+jOASXH5snH54u1RuNpWxtsxomCY+AcUnAAAJShV3C8NSg41kXBMUaiyXb7K7LjpzyqcsHk43M6rlZfstXBZnwoOAbOobzguLHI2AIA0IeCY1AUHOMmraX55pm9VRzRcjfDPg93ZfJ9ON5z+MSJ+tZHm3Gg4BgwfxQcAADlUHBsehH68WZzn4JjTDQajf3Z4XejKORvVVlWcPRPb5XLn4dW66rsGG19xBl1ecER7YJzdpelW3C0FBwAANtOwbHpRejHFBxjJapOTn5jdvzrYC+OPukWPr2C46GkNvmMrQ8140DB0TcKDgCAsig4Nr0IVXCMozh+e34Tbz+O9emuaumNy1Kcpj+Sj1ahsWakeUSlbxQcAABlUXBsehFqD44xlKbpY7PDXcEqjnVZs4Ij34fjP2XH2tZHmlGn4OgbBQcAQFkUHJtehH5MwTF+jh07Vo3T+DXZlw8GJceGRJ0NeDslx4dDmG8VGGpGnIKjb2wyCgBQFgXHphehCo4xNTU19beyw\\/\\/xmMqm8+Mz9cX2lVsfZUadgmPg3FFwAACUQcGx6UWogmN8VeKl49ykAAAgAElEQVQ4fm12PKvkGDg\\/7q412k8tMMaMOAXHwLmj4AAAKIOCY9OLUAXHGGs0Go\\/KDp8NHlMZND9OhzQ9tdXxZfQpOAbOHQUHAEAZFBybXoQqOMZbGsfxG7LjmaDk6D9H4vhtx48frxQYY0aYgmPAvFFwAACUQ8Gx6UWogmPMpfX647PD3d3XxsbDPid3W\\/LNRr1KmYEUHIPmjYIDAKAUCo5NL0LvCAqO8TYz0w5R9N+yr5aiKBr2Obnbks+Rv6rVWlcVGWJGl4Jj4LxRcAAAlGFdwWEZ\\/tqL0LzgWCgyvux91YmJb84OX7LZaN85cm9lYuKriowvoysvOKLhn6e7LQoOAICyKDgGJVJw0HHl8ePt7HB7HMfmx9p0NhpNqtVvKzK+jK7eCo6l4M+W9fNGwQEAUAYFx6AoODgvTuMbovM3J7vg\\/NwV6dyoxXF8Q6HBZWQpOAbPGwUHAEAJFBybXoTeEfbvV3AQJiYmvjI7fDGYI2vmSNR5k0r6qkKDy8iyB0f\\/eZNnst1+WZGxBQCgDwXHphehCg46ZvLNRkP4tWCOrJkjnX1Joug\\/Z7+RRIUGmJFkBUf\\/eROs4AAAKEen4JhXcPSJgoM1qtXqt2aH+2w2umGefOTo059eKzS4jKRarfaMSMHRb84oOAAAytArOH4+KDj6XYQqODjn2HXXzWaH\\/6PgOJ98LLIb2D9qHzo0U3B4GUG9gmPo5+kui4IDAKAsecExreAYdBGq4GCNOI7fHoXOYxlL3Ru3aNjn6VDTK3vuDDMzj8yOHlNhDQVH3yg4AADK0tuDQ8HR\\/yJUwcEaSaXyndl9\\/OkoWpkr8bDP02EnH4f7QpI8Myg4WCcvOMLwz9Hdlk7BMaHgAADYfgqOTS9C72h6TSznRdkN29Hs+CehO1+Wx30FR+jOk7NxpfJ9xYaWUZQoOAbNGW9RAQAog4JjUDpL7z8aFBysdvx4Jfv2zVnOhBCbL93kr4p9dQgn0mKDy6hJPKLSf74oOAAAymEPjkFRcNBfUq3+g+zwN1GIl9y8dZLPlfeG2dmpgkPLiFFwDJwvCg4AgDIoOAZFwUF\\/tVbrEdnhzzubjVrFkScfg983V1gvqdWeHoZ\\/fu62KDgAAMqi4BgUBQcD5CsVoug3os588crYXsnz2TAxcbDw2DJSFBx9o+AAACiLgmPTi1AFB\\/1UQxy\\/Ji84osgKjt6bZO6uNptfVnhkGSm9gsMcWRsFBwBAWboFx7yCo\\/9F6B2h1ZovMr6MpqSafHMUwkNRZAVHbwXHA2m9eaLouDJaFBx9o+AAACiLgmPTi1CviaWvynTjmuzwWQVHnk7B8VBSrX5T0XFltCg4+qZbcLQUHAAA207BselF6B0eUaGffVdf3cgO77cHR1juvk0mOh2S6ncUHlhGSlJLFBwbo+AAACiLgmPTi1AFB4PF8VuCebOcv00mCuF0Nh7\\/tPCYMlLygiMa8\\/nRJx5RAQAoi01GN70IvSM09ys46Cuu1Z6XHc6EMZ83vYLjTIjjFxceVEZKWku\\/Poz5\\/OiTTsEx0W7fWGRsAQDoQ8Gx6UXoHSHYZJT+0kYjv3l7KIz5vOkWHNHZEMc\\/W3hQGSlpquDoEys4AADKouDY9CJUwcFA1UbjUdnhi8G8We7uRRL92qlTp9Ki48roSNPa04L5sT6dgqNhBQcAwPZTcGx6EargYLDJycuybz8TzJvlzptUougD4diJZtFhZXQoOPpGwQEAUBYFx6YXoQoOBmu3Z7JvPxrMm86bVEKIfi\\/MXn6w6LAyOhQcfaPgAAAoi4Jj04tQBQeDHT5cjyuVnwvmTa\\/gCJ8NlckvLzqsjA4FR98oOAAAyqLg2PQiVMHBZqI0TW8I3bkz7PN1yMn34AhfDGn9RMExZYQoOPqmW3C0WgoOAIDt1i045hUc5xKvvghVcLCppF5\\/dna4L4z53Imizq8\\/G4fa04uOKaMjTWtfF7rnxnLUOU+ioZ+ruyArr4l9ecHhBQBgPQXH+qwtOFotBQeD1ZvNJ2aHvw5jPneyG9f81\\/9ACMm3FB1TRkea1p6aFxydciMoOHrpFhwtBQcAwLZTcKzPSsHRuWHLN5BUcDBQfWbmUHb40zDmc6dXcDwU4vh5RceU0dErOM5G2e+nCo5zUXAAAJTFHhzrs3IBvlJwWMHBYO1Dh\\/I3qfxh6MyfaNX5M17pFRxnQohvyo5x4YFlJKRp\\/Smh92eLguNcegVHS8EBALDdrODY9CLUHhxs6vCJE\\/XscHswd5Z6+Q9ZKkXGlNHRKzjOhHPzQ8ERzhccNhkFANhuy8vL0fTCQv6qSwXHxotQBQebu\\/VkEiXJO3srGMZ5\\/vR+\\/dF\\/zo61osPKaEjrCo4+sYIDAKAs3YJjUcHR\\/yLUHhxcUJwkb1BwnCs43psdJ4uOKaMhrdefHBQcfeeKFRwAACXwiMqmF6EKDi4oTtMbFRznHlH5RJaZgkPKiEjr9a\\/NDqeDgmPDXFFwAACUIC84phQcq3LuAjwfi4+0Wq25QgPMyEvr1VPR+Rv8XXAOD\\/XG7dOT8\\/MHio4poyGt158UOgVHpOBYO08UHAAAZbCCY31WXhPbGYsPBwUHFxCn6atD9\\/GMcZ8\\/+a\\/\\/c6FWO1J0TBkNaZo+MTs8GKzgWD9PFBwAAGVQcKyPgoNLkr8x5DfG+RWxq5LPmS9Um81HFh1URkOapk8ICo5+80TBAQBQhm7BsajgOJeVgqPzt\\/EfUnBwAXGWX+7uwWEFR5Z70nrzCUUHldGQ1utfkx0eCAqO9fNEwQEAUAYFx\\/qsWcHxoTA1NVtogBl5cRq\\/TMFxbs48kFQnnlV4UBkJadopOO4PCo7182RpstV6WaHBBQBgI4+obHoRquDgguI0\\/mFvUTk3Z07Hae1fFx1TRkOa1h+fHe4L5sb6eaLgAAAog4Jj04tQBQcXFKfxixUc53I2Tqs3FR1TRkOapnnBsWoFh4TzBcdLi4wtAAB9KDg2vQhVcHBhcfyTCo5V8yapvCn7fSUqOqzsfWndCo4+6RYczaaCAwBguyk4Nr0I\\/WAICg42l1Sr35EdTofhn7O7IUshit517NixZsFhZQT0Cg4rONbPkW7B8eNFxhYAgD4UHOtzbhO8fCx+W8HBhVQbjUdlhy+Ezjkz9q+LzefNH07Mzh4sOq7sfQqOgXNkaXJqWsEBALDdFBzrs\\/o1sdHtod2eKTjEjLpa+0j27WeC+bPcG4O7qtXq3yk2qIyCXsGx6jWxEs4XHC8uMrYAAPSh4FgfBQeXqF4\\/nH37Z8H86c2bcG92Y\\/uEYoPKKEjTznmg4FibXsEx9WNFxhYAgD4UHOuzuuAIHwjtQwoONlefflj27ad658wuOIeHmc7jOWdDtfqsosPK3pemaV5wPBj82bI6vT04pl5UZGwBAOhDwbE+a1Zw\\/FaYnp4uOMSMuInZ2Suywx8rOFbmTViK4\\/hfZUdvUhlzab1+Iig41mflEZUfLTC0AAD0o+DYmKibfCzePz19WMHBphqHD+\\/PDr+bZal37gz9HB5i8jFYitP05dnXcdGxZW9L6\\/WvjaIof8OQP1tWzZHQLTh+pNDgAgCwUbfgWFRwrMqqguM3reDgQg4eO5a\\/aee3g4Kjc\\/MWRZ0VHD+TfZ0UHVv2trRWe2p2OBP82bJmjuSZbLdfWGRsAQDoQ8GxMasLDis4uJB9V1\\/dyA7vDgqOczdvIYrekx2rBYeWPS5t1J4W\\/NnSd4402u0fKjK2AAD0oeDYmNWPqFjBwYUcv\\/76Sna4NctZBce5fPzA8eOTBYeWPa5Wqz0j+HNlfVYKjhcUGVsAAPpQcGyMgoNLcfLWk0mI458LVnCsvoH70zB7+cGiY8veltRqzwwrq3qGf17ulnQLjunZf1lkbAEA6EPBsT4rb1HpFRxeE8sFZHMoCkn8pmD+9NJ5k8rnQ73+5IJDyx6XVKvfHBQc69MZj+bc3A8UGVsAAPpQcKzPmoLjN9vttoKDTeUFR1qr3BzcyPXSKTjuTyr17yw4tOxxSbX67cG8WJ\\/OeLTm9z23yNgCANCHgmN9FBxcump98qXB2yJWz53TcRzfUGxU2esqtdo\\/DQqOfvNjaWpxUQEIALDdFBzrs6bg+K2g4OAiTHSfp38gmENZovx4NsTx28LRo7WCQ8seFler+atQFRxr0xmP9v7931JkbAEA6EPBsT5R7xh3C46g4ODCpvbt+7bs8KVgDq3MoXwc7piaOjhbbGTZ0+L45qj7yJJ5cT6d8ZjZd+CZhcYWAICNFBxrE0UrBUfnovzDrVZrrtgIMw6mr7jsCdnh7mAOrSQfh8\\/Wpqb+VqGBZY+LfzaK8rK48\\/vpqt9fxzndwmf24MGvLzq6AACso+BYm5UL8O5FefidMDl5WbERZhzMHjp0LDv8dTCHVpKPw4Nprfa0QgPLXveL2e+pq1ZwxMM8J3dJuuMxt2\\/f1xYcWwAA1lNwrE0UxcvR+YvQT4TQXCw4xIyBhYNHjmaHO4M5tJLOTVylXvemiPH2rvz31POP\\/lnBsVJwTC8sPKHo4AIAsI6CY23OFxyxR1S4aAeOHLkiO3wmmEPL3ZvYeCmbR0txnL6m6NiyR504Uc++vb27gkOxsSrd18TOzDyu0PgCALCRgmNtOgVH528cO2PxkdBqzRcbYcbBviNH8pU+n+otxx\\/6eTy8RJ3HvHpZClH0ruKjy57Ufbzvj4I\\/V9anU3BMTE19VYHRBQCgHwXH2qwvOFoHDig4uKCZ48fb2c387ys4ouW1byKK7ggLx5rFR5g9p1a7Kvv2L4I\\/V9anU3BMTk09psDoAgDQj4JjbdYVHPkjKgoOLujw4cP1EEW\\/vXZDxXHM6oKjMxZ3VRqNawoPMHtPpXJt9u3nw1jPh77pFhzt9pcXGF0AAPpRcKxNn4LDHhxcjEoURe9WcGwoOB5KJia+tfDoshfle0zcE8Z6PvRNPh4PNGdmHllgbAEA6EfBsT7nbtDysfiQgoOLlIYo+hUFx4YshTi+JTtWC40ue9GzstwfzIeNcyKEu9qLi1cWGFsAAPrpFByLCo6Niazg4FKkcRz\\/QnZcsg\\/HmuRj8b4s7SKDy54ThTj+wex4Ovhzpd+c+IMDj3iExx8BALabgmNQIis4uBRJUqm9Pig41icfi\\/9bq9WOFhpd9po0xPGrQvfPlWGfg7stZ7PfLd53uPsaXQAAtpOCY2AUHFyKuDrZ\\/NHQ20AwDP\\/83S3Jx+KetNl8UpHBZc\\/Jb97fHsyFfjmb1mrvPHnrrUmB8QUAoB8Fx6B0\\/hb+g2FqarbQADM26q3W9wQFx\\/rkY3E6pOkPFRlb9pzFLB8O5sK6dPZ3OtOYnr25yOACADCATUYHRsHBJalNTn5DdngomEfr51G+0Wi+P0laYHjZW\\/5Olv8XzIU1iaI4G4\\/o\\/vlDh55baHQBAOivt4LjrUHBsS5WcHBp0nrnMYx77MGxNlH395U\\/mT1w4IpCA8xe8vQsDwZ\\/pqydC1E2HlH0xYUrrnhCodEFAKC\\/vOCYUXD0Sa\\/gCAoOLk5zZuaR2eHTkXm0Jr3C50vVyclvLDTA7CUvzHImmAvrk4\\/HX+0\\/dOjLCowtAACDKDgGpXNT9tsKDi7W4sMfvi87fFzBsTbdZflhKY7jVwSPqYyDbAqEd\\/SKLXNhzVyI8rcsfergNddcXmiEAQDob13BMfQLwN2TXsHhERUu0r6rr26EKHpfMJfWpHNT17nRjT6S\\/bP5NPLaM9k3f+BRrX5zIc7nw0cPHDgwWWiIAQDoT8ExMN2Co925WIcLOnHiRBrH8VuCpfmD5tNdlXb7ywsMMXvDU7LcHcyBfnNgKUnT\\/5odK1sfXgAABlJwDErnbx9v7\\/1tJFyUuFb7F8Hmiv2Sj8eDlVrt+wsML7tfkuXHg9clD5oDS5VG41XZMd7yCAMAMJiCY1A8osKlS6rJP8gO9wY3d\\/2SP6byP2ZnZ6dCd58GRk87yweCgmPA+R+W6pOt79768AIAsCkFx6D03qLiERUuQdqaeGx2+FwY+vm7+9Lbk+HzoVL5igJDzO52TZY7g3KjX\\/IxuX9yZuYZWx9eAAA2peAYFAUHWzAxcUX27ad6b0twk7cq596qEVeeX2iM2a3yVTk3BI9oDUo+Jn8xffniNVseYQAANqfg2PRi9IMeUeGSdM+XDwVL9PukV3BE4VeDR1RGUX7u\\/2bwZ8mgZOd+9Mmj1\\/5\\/9u4EXs6rrh\\/wme3ua5KbpEnapmna0gilkGKpFbiWRSoWQQygLBUVEAVxAQQUiAJ\\/BQTEgogKIohgAQGRspQdZBPZLCIIFFkKFKS0ULo3\\/3PuzG1u03lnuzPzzsx9ns\\/n27lN7rznvO+8c3Pf35z3nNstdXyEAQBoTIEjK7U5OIICByvSvBHNL0x2754IxeJLgwJHvffU6iiOr4\\/Pzp7Y9FgyXEqle8X\\/\\/jA472+ReN6n3FCZmvr7AwcPjq3nMAMA0IACR1ZWCxxuUSFdu5XODcViK7dWFOL3\\/X4hvp\\/conKL91R6TMfkuniMnhcfyy0cT4ZDei1fERT26qZ2y9o1s\\/PzD1\\/HMQYAoBkFjqxYRYWqU5eXF+LFybtXRmYcOFBq9v2lycn7x4cfKnDc4j11aE2R46sxe5odS4ZEde6Z9JoqcNTJys+CQuGynccff9Y6jjIAAM0ocGTGCA6S4sTs7Lnx8QfxAuVtYceOqWZP2LJz54nxQv4rChwN31vp8UHNjiVDoRyKxT+Kj9cGxY265\\/vKCI5i8cs79+7dtY7jDABAMwoc2b+UBgWODW9mZnuad+Mjheo58dXJycmmFyhLy\\/tm4sNHg4u9zPdWtfhTfFUw2egoOD7mGwp62ed7Sqlcfs+mvXvnOj\\/MAAA0pcCRFZOMEsLU7Ox9Cmn0Rm3uiOnFxVNaeFqhWCqZaLRBahfDX1w46qhjWzieDLTio8NNRav8z60BzMrPgcrk5PMPtHCLGwAA66DAkRUFjo1ux\\/79U8Vi8fxC9b2xcvE2Njn5Cy09uVz8\\/fjf64MCR90UCsV0XK4OxcqjglEcw2t+ZYTb+2qTaOZ+Xg1oVs71zdu3n9v5gQYAoCUKHFlR4NjgCqWpqXPi42WF6rmwUqgoFotPaeXJpamxn4sPV9eeOwDn80AmHZsP1y6SGT6FUKqcGywN2yQrxZ+v7N1\\/6+M7P9QAALREgSP7l9KgwLFhbdq0Kd0r\\/9ZweOh9NcXia+Jjsdnzx2Zm9sWHS4MCR6OkY3NlaXz87GbHkwE0GXYGc820cI4XbiyNjb397LPPHu\\/4WAMA0BoFjqwocGxklUrl3PhwZbj5xduNhRA+vbB790Kz589sT5OTFj6kwNE0afnMNx04cGCs2TFl0BR\\/Pf7nGnNvNDm\\/47+tY5OTf9rxYQYAoHUKHFlR4NioxsfHT4gPF4VbfjKd3iPfqszPn9ZsG\\/v27RsrFosvUuBonNrF8Q9KY2P3D+biGB7j43vjfz9l7o2Wzu9rZjZv\\/vnODzYAAC1T4MiKAsdGVSwW\\/yRkrwpxXfyG32hlO2OTkw+I59GRo0BkTW66\\/adQeHt8nG3luJK7SszzY25Q4GiadH5\\/Y3x2y0mdHmwAANqwUuDYsu0fggLHEUkXXoV\\/C3MKHBvJ9PTKMrBfyhp2X\\/3z4stDmoGgibldS2kkyNdDQYGjSdLx+X5pbKy1FWrI2\\/6YS4JlkFtI4cZCufyWk848SfEOAKAfagUOIzjq\\/GK6UuAIVnjYMKqreaSJRdMn04fqfTJdK3x8Kmap2eb2P2J\\/JX7\\/u4MLwaapHdePhcXFY5odV3JTCNPT2+PjBaH2HgkDcO4McNI5fd3k\\/OzjDxw4UOrwmAMA0A63qGRFgWOjKVUnFr0+NChG1C7ELwljY7ducbMvDgocTVMsrhzX64vF4uNbPK7k449Ck\\/eI3JR0jC5d2rf3dp0dagAA2qbAkRUFjo2ktqzrRfECu+GFW63AcWXLt1NUKo8JChxNU5vLIR2jz05u3ryzpWNLPxXK5fIZ8fF\\/g3O5lay858uVyoVn\\/8VjLA8LANAvChxZWZ1kVIFjA0jLvr4+tHbhtrLsYyiW0siMpqt+lEqlnwlpYtLqpKV1b3uRlGJ6zx2qHtvii8LevS4KB8uemM8FS8K2mpUCx8TMzDM6O9wAAHREgSMrtQKHSUZH24EDpWKx+Lvxqx+G1j+Zrs4XMbtzc7PNTywsHBsf\\/mt12wocme+3Q7Xjk47TZaXx8Z9tdmzpky1b0gSZr4i5PmvyXblF0nG6em5p6eyOjjkAAJ2xikpWFDg2gvLExF3iw6WhvWH36XuviM\\/+ydBsFMf+\\/ZVQXFl15YY229jIScvGviPs2uW9l7+ZUAzPio\\/XBOdvW+dwoVj4+PGnnLK1o6MOAEBnFDiysnqLigLHqDrjwIHJYrF4fqjePtJugSMtF\\/uE0MptKpNjDwjtjRDZ6EnH6ZpQLD4zPk40O770TDm+Br8THy83cqPt8\\/e6qbm5p8bHYicHHgCADilwZEWBY6Tt2jVZHh9PK3ZcWZvgstXzYuUCplBYuYhJS8qWm7Y1MbE7\\/vcLBZONtpPqrSpjY\\/drenzphbSs6cNivtve+2OjJx2nlYmKv33sXqunAAD0nQJH5i+q6ZfUD4V5k4yOorHJmQPx4YedfDJdKBRX54r43zAz08oQ9IlQDP8UFDjayeqomv+cmJjY08IxpptKpXPif78ZnLNtZuWcvbFQKr0\\/PpooFwCg36qTjCpw1Em1wGEEx6gpTszO3ik+fnbN0qRtnx8rz023nZTGfq6FNgvFSuUR8fHa4GKxvWNcWFlV5eVhaWmmhePM+hVCqZTO6a8budFJVkZv3DA2PfHE0MLtawAAdJkRHJlR4BhB09PTp8SHL4TuFBrSNl4W9u0ba9bu7OzsSSGN+FDg6OQY\\/ygUiwf3Wjq214qhXP7p+HhxcJ62ndoy0DeGQvjO4nG7TunkBQAAYJ0UODKjwDFaCvHi7cz4+O+heyuapG18K+bHWmi\\/UqxUXhAfr68NY8\\/7\\/B6SpNuBSul4XRWKxWcHw\\/57Jd2K98cxlxYKRednB6mNeLlucn722fvT6kkAAPSfAkdmagUOc3CMgEKoTN0+Pn46dHdOgdVt\\/WYrnZiYnUi3xvygesFu6H8Hx\\/qqmD+PWQiG\\/3dLOo5HxbwyuIVqXVkpDBUK3916\\/LE\\/0e6LAABAlyhwZMYIjlFRqZwW\\/\\/vpQqFwfZeXu6wVOAr\\/3FI\\/ZmaW4n8\\/VVgZwaHA0W5qr93VMeeZ\\/LdrTo15W8w1teOrwNF5biyXy+\\/etW+ffzMAAPJiktHsX1ZjPjQ3p8AxxEqhUrljfPx46N1qEOl989UQxk9qqT\\/lcroN4LouF1o2UtJxuy7mdTEnhzRvBJ1It1DcOeaTwUop3Tovr1rcuvVR4eBB5yQAQF4UOBr+wvqhoMAxtMrVCRPTUpc9PLfTSIzCjaFY\\/IPQwm0T04uLt4kP3wguKNeb9Jp+uXR4FRu3rLRqebkcz9cnxa++X5sY85DVUtadG4vl8ifPvPfdd7T9egAA0D0KHFkpGMExvCZKlcqvxMcvx3S8FGxrWbkwTNv\\/TMy2pj1Lkw8Wi\\/8UfGq+rlTnO6hN8losPj1MTu5qeuxZHdF0fswPV5dJVuBYd1bex1MLc09t9wUBAKDLFDiyUjCCYziNFSvjj4qPl\\/fxNpDUzjUhlO\\/ZSgdLY2P3iw83uE1l\\/SkcLhS9P5TLZ8XHpkv2bkDplontMWmU0SVBca3bScfyh0cff\\/StW35FAADoDQWOrNQKHNXlExkCC7sXFlY+zQ\\/he6ufTof+XeDcENt+bksdnZzcGf\\/72eAis2vHP77W6efXpSuvwfj4icEtK6vSz69Hxnwi5moTifYk10\\/Nz77sjAMHJlt\\/WQAA6AkFjqy4RWWYjKeL2mLxVaG6ykYeF3Cpzc+GiYljW+husTK+Msrkqpz6OqqpFppC+Fw8F34vvhZ7wsYsdBTDZDg6VAsbqUi7ep4513pwzhWKxf+93Z1O39fqiwMAQA8pcGT\\/4hrzYbeoDLiD8WJuYuInQ3qtQuj2MrDtni\\/XhlD6tdDCRfX+u91tPn7XZ4KLzi6mcGNagrdYHc0RX4vwuVAq\\/WrYWKOw0lLEvx7z+fheWC32KW70JivHdWxq6mVhYxbSAAAGjwJHVgoKHINuYWGhWCz+bvzq2yH\\/i7jVW2LeHjPXSveL5fIzQvV95+Kzy1lzK0YqdPx7TJoA8vSYUXs\\/pwvrzTF3iklLEH8qrMwHk\\/v7YSMkTXT7nc3H7jyrhdcJAIB+UODISrXAMTs7u3ldB5heKEwsLOwOhcLrwuGLudzPmdpF9ffK1RElTY1NT58S0iogA9L\\/UU2an6P22vwopMlIQ\\/jNmJNipkJaWaSqEAb\\/U\\/jV\\/qVJQ6dj9sc8LVRHL6V9U9ToX9Jxvm5mdvYlB88\\/aGJbAIBBocCRFQWOgbRr12QolX4xVD+pzvOWlFuk2pfC9fHrl8SMt7A3lWKplL43PWdg9mNEc+OaUR1pTopvxnwk5q9i0vm0vzZaq9jsRctJOp\\/S5Kn3jTkvVPv+nZjrgttQ8jmfioUvH3\\/aKVZOAQAYJAoc2b\\/AhupFhALHYCiF6enbhGrx4IpQu6CLF615nyf1zpvvxtyxlZ2anJu7YyiEb1rdor+vUaGWcDiXxXw05qUxvxKTbjs4OWZLqN5ylFbISKM9ejnKI227EqqjM9K8ISfEnB2qy7v+a8xXw8377JzJ6fyJuWF6dvZ5+\\/fvr2S8lgAA5EGBo+EvsanAMWr37A+f+fnFUCz+dvzqCzHXF4vFQb6wW5noMj6+IBy+\\/SHbjh1TxerqL4O8T6OVQhptc9N7fOX1WlNgij8HVybnvDzmGzFpIth0W8urY\\/40hJXz8KEhlO8ZH1PBLS35uzkshZn4OBGqBYpSRsq1v0+3xqQCxo6YtPrGXUN1FEna9p\\/H\\/EvMf8T8b8wPQnUekRsKNx+Fkv9x3Li5Ib5nv7T3dgvKnm0AACAASURBVLezcgoAwKBR4MhMdZJRBY787No1WR4fv3v86sIwRBMn1i5CPx+vd49pZTcnN206I1Qvpgd+3zZI6o2SWJt0S9EPQ3Vy24tj\\/jvmEzEfDNVz9YJQLVKkvKn2mEZgvC3mPTEfqz0nPTfNwZKKKdc2aTPvYyKh+t4uhMI1s4vzT47\\/dg76nC0AABuPAkdWqnNwzFlFJRdjY2P7Qij+Tfzy++HwSiNDcaFXK3CkgsyTQ2u3NBSKlUr65N5cHIOXxsWO6pK0Nxzx5zdkfH3k92T93dCc6xswNxaLhYtOOuWk4wIAAINHgSP7F9mYjyhw9NG+fWOhXE6jGZ4XVkZADPUFf+p3uqXm6FZ2vTI1dbv48NVBmjRVRG6W9N78weJRWx65vLycbjcCAGDQrBQ4tihw1Ik5OPpnLF7g3z4Uiy+LX\\/9fOPzp+DBf7K\\/sw9jY2M+1dAT27RsrlsvPCjetijFwk6eKbORU38\\/j42\\/+iwsuaGWFJAAA8qDAcWRuurC0ikqvTUzsKVaKvxG\\/ekfMpeHIIfuDt0JKO+fRjbXbnF67MjKlBZt27twVqsvfxucVDylyiAxGaiOrLtt2zDFpQlgAAAZVrcCRVnFQ4FhJcfXr9AvtR2dnZ7es6wCzVlpJYksol+8SisU\\/iV9fFG45ueIAnAPduiiqLRlbDmmi1JYmJCxWKr8TH65zq4rIwOTG+F6+Znrz4p8uLy+nlXIAABhUtTk4VpepzPsXyQHIzUZwpNUOFDjWa8eOqdrcGn8aqqNivhdz\\/cqKBCO87OWapUjT6hmLrRyqrVu3bosPH0jFkdrzRSS\\/rPx8KlfKH7\\/rbz7UaD4AgEGnwNHwF9uPBiM42lUMW7bMhvHxvaFU+pn4\\/88IofDO+PidsDFXiUj7eXk8Fj\\/b6gGcmJ9Ow+C\\/uYGOkcigJr0Hr5jevPDQAADA4FPgyEpxZZnYsH1maV0HePgV6uRm4jlUCPPHLIZy+W6hWHxK\\/KN3x1xaKBQO1bKRChr1kvb9HWFpaabFY14K5eJzwuE5SfLuv8hGTHrvXTs5N\\/e8g+ef39I8OgAA5GzNHBwupG6WlYvyD4VtM1tDi\\/MnjKjStm3bpsP09LaJiYnj4v\\/fIeaBMb8b82chTaIZwgdDdVnXK8KRE4U6r1YKPPEEuip+\\/QehOg9JU0u7d28vlEpvjs+9wXwcIv1Nofaza3xq4oJ9d7jD9gAAwHBQ4MhMOh6f3HLMMfunjj56x+Tk5p1h06ZdYXIyZedKpqZ23JQwdVR8rGZ6enst20JImdkaZmqJ167x8XDCakIta79emf8jZrZBjtzGytdbq+3GpH5M3dS3HSv9DmFXCJNHT0wsHBsm5veMj8\\/tHZ+dPakyOXl6CGM\\/H0qlh4di8fHx+54e8+KYN4fq6h7\\/G\\/P9EAo3pALQ2jk0jNLIzppRLN+IOTG0aG7z3I+H6kgYIzlE+psbC8XiJcecetKZAQCA4VG7ReUfgwuoW\\/yCG9Kn7oXC\\/8THz4XqCIUvxVxcy5dr\\/\\/\\/FWv6nli\\/Uvndt\\/ruN1Hve55qk3nNX+\\/PFWj+\\/VOtz6vtXakkFi6\\/GfC2EQrr4Tku1XhGqow2uC7ccidEoeb9eg550jK6P+euYqdCaSrFcflp8vMYxFulb0oir6zdt3\\/q45eXlcgAAYHgocDT5Rffw7QHtXOyPSvI+\\/iOWlXPphzH3DS2a3blzc6FUSCNojOIQ6U\\/SbWGf3rRz564AAMBwWSlwLG17dXDxJB0k3X6Rdx+GIWnJ1+rSrytFjveFXbsmQ4vm5uZOjw\\/fDt6jIj1Kuo2suHor2dd37d19l7Cx514CABhOqcCxSYFDpC+pXUBdFcLKajPjoRX791eKExOPCCvzn3ifivQihcLKylnXTM5O\\/\\/7KylAAAAwfBQ6R\\/qZW5Lg6lMt3D20oVUp\\/G25+25SIdCG199R15bGx1526fOpCAABgOLlFRaTvuTENhw+hcEFYWGj5YmpuaemEUCh8oraqSt77IDISKRaL1ZWgSqV\\/O+7k444NAAAMLwUOkf6nUCilx6tDsfik+DgWWjS9devdQnXlGxPBinQnN4RC+OqmHVvbGlEFAMAAUuAQyS3pPfetMDFxVmjV8nJ5fHryt+NXV7lVRaTz1CZITu+h7y8sbT73wIEDpQAAwHBT4BDJNel2k\\/eHycmjQ4v2n3POVHly8rlhZbJS71uRDpPeOz+YmJt6+q4zWl\\/VCACAAWaSUZH8UhuFkYocLwpt3Koyu3Pn5kKp9MZQnXQ09\\/0QGbKsvO\\/GJiZe+pDHPW46AAAwGhQ4RHJPeu9dFkqlh8XHYmjRntve6sRCufzvxWLxkNtVRFrOyooppXL5jccff3zLI6cAABgCChwi+adWoPhaCGO3CW0Ym5h4UHy4rpBGcoSb5hUQkTpZHTFVKpfev3zOOVsCAACjRYFDJP\\/ULrxS3hAzG1q1e\\/fE5MLC78WvLjOKQ6RhVoobhXLpIws7d942AAAweqoFju0KHCI5Zs2KDtfGvCBs2dJykSO+h0tj4+PPil9ercghUjfV4kax+Mmd+044NQAAMJoUOEQGKul9+KOY3whtOPXUUxdK4+PnxS+vCd7LIkcmFTc+vfWYY86MXxcCAACjSYFDZJCSJgwtpvfixaFc\\/qnQxsXYrX78xzeXKpVXheooEO9nkcMjNz6zdceOVNwAAGCUKXCIDFxW5+P4fExbqzyc+sv3WSiNjb2qkC7qLCErGzs3FovFVNz4xGlnnnlSAABg9ClwiAxk0vvx+pi3xuwObdh0\\/PFHlyqVV8Yvrw7e17Jxc32hVPrQ5u3b7xAAANgYFDhEBjarIzlevWnTprnQhjPvfe\\/ZUqXykrC6hGyhYAlZGekUi8WVx9pEu9cVSoV3nXDaaXsCAAAbR63A8ZqgwCEyiEnvyzQS4x9nZma2hjYcc8wxi2Pj48+OX\\/4gXfQpcMiop1bcuHpsYuzvd524a2cAAGBjqRY4thnBITKwKdyY5tQoFoupWDEe2nDgwIGx8tjYU+OX3425IZiXQ0YstdFJq6OdLi+NV\\/7yVnf98c0BAICNR4FDZOCzevH2fzE\\/Hdq0b9++sYmFhYfGL7+aLgSLxaL3uoxMagW7dE5\\/Z3x6+vH7lpdnAgAAG1OtwOEWFZHBTXXC0ULhLRPz88eFzpQWjlq6c6lceleojeQYgP0SWW9Win+lcvl9m3fuPCsV8wIAABuXSUZFBjO1eTPS+\\/KqUCy+ut05OOo5+eSTjyoWi6mg+aM1w\\/pz31eRdrM630Z5bOwtu0+91e4AAABGcIgMZmoXcFcWK+U\\/CwsLC6FL9u7dOzc+Pf178ctvhMO3v+S+vyItJp2vN8T3x7cm5mefdOL+\\/VsCAAAkKwWOLQocIoOSNEdGbZ6My8sTY8\\/cctJJs6HLDh48WJyfn79bKBQ+Xwjh+loxJfd9F2mQG0N1VFO6xerrizt2PDD9+xUAAGCVERwiA5XVC7hvTc7NPWbbKadMh94pbDnqqP2FUunt8etrg58BMthZmYumVCi8d3Hr4plh\\/\\/5KAACAtWpzcChwiOSYNUtdXl8oFi6aXJi97\\/LBg+XQB1uOPfao4tjYM+OXXyuE6rwflpKVQUg6D9NoppWiX6HwrfL42LN2HH\\/80QEAAOqpFTjODwocIrlldULRUrn83hPuePuT458VQv+ktkrzmzefFS8i\\/ytUR5H4eSC556aJcAvhK7PbNv9c\\/LoUAAAgy80LHOlTW5\\/civQrhcOTfP6gVKm8cmnPnhNCfgrz27YdVyqVXhS\\/\\/r8QCgodkkvWrPDz3fi+ePGm7dv3xX+r+ln0AwBgGClwiOSWldUgYr5Znhh74j0eco9ezrfRsvPPP780Mz9\\/v\\/jlRaHaPyutSL+yeq5dn0YTzWya\\/4Xl97ynL7dqAQAwAlKBY2Fp+2uDAodIP1Odb6NQePvs4kBOmFhc2rXrhPTpefz6qqDAIb3PTaM2xqYmnrHtpGOPi19bJQUAgNYpcIj0L6tD7+PjFcVK6SXHnnzyUWGAnXLKKdOV8fFHFkL4ZMw1q3OFhAE4ljISWZ3UNo0UuqJQLv3r5h077tavCXYBABgxtQLH64ICh0ivs\\/oJ9acn5+fv3+MlYLupOL91656xiYk\\/iV9fEtyyIt3L6u0on5hbXHzQMbe5zWLo7wS7AACMEgUOkd5mzaiHNGrjHxaWlk4NQ+jA+eeXpufn714old4Q\\/\\/f\\/Coc\\/fVfskBZTWPt+uC4UCl8qT4w9c2nPrjS5rsIGAADrs1Lg2Lz99UGBQ6QXWR3t8KWJhdlfDtVlLof1Qq7a7wMHSpuWlu4Zv\\/pASPOIBAUOaTmr74crKpPjz7\\/DPe58dKga1vcEAACDpFbgMIJDpEspFGqfUlcv5C4tVSp\\/Pb2wcOqBAwdScWNUFLZt27Z1Ynri3LivqdCxMhFpbd9XEgbgtZD83wth5byo3YoSwtcq4+MvWdy6eOYZZ5wxGQAAoJvOP3R+aWFpqxEcIt3J6vD7a2O+NDkz84B0a0cYYfvOOGPT5Nz0Y0MhfCbu+9VpwsjVyVRD\\/q+H5PQ+CCvvheJqYeOS0ljl7446ac9pB84fqUIfAACDZKXAsVmBQ6Tz3PSeSRdzaTWI7xZLpfPmdi3tDRtlmctDobC0e\\/f26bm5BxcKhffHP7kyrJmM1IiOjZKbClvpfZAmD\\/3c2MzUH2\\/avv3H9u7dOx4AAKCXzj90qLSween11V9MFThE2k1ttEK6oLs8fv220tTU2bt3L0+EDWrnrW61eWxm5gGlcumC+L+XxmNy3eGJJVd\\/zuT\\/uklXszJao7bc65WhUPjM2MTEwS17dp548ODBjVHkAwAgf9U5OJb+WYFDpO2sflp9XcxnS1MTv7pnz575YMLEJB2DqcVjdvxkZWLspfHrbxUOHy+3roxWVl\\/TH4VC4QNTm+YfvuXoo3fE\\/y8HAADopzSCY37TSoHjBgUOkZZyeJnLEL5cHBv744mt83vCwQ1yO0qb9h04MDa\\/ZcvtyxMTTyyUS2lC0stCdcTLjebqGL6sec1Srk5LvZYqlb8bn5299759+zYFBT4AAPKSChyzi1veEFYuOBQ4RBpk9aIuTZr4nWKp+Bfbjj32uOCCrmX3eNxDpheOOurOlfHx58cL5S+F6mSsNwajOwY9N59bI4QrCqXS+6cW5x+1Z\\/\\/+Y+q81AAA0H+pwDG3uOVNofqL6yEFDpFbZs2n1l8rVSrnTc7NnR527bLMZYf2P+IRlfmtW\\/eMTUw8KB7P18Q\\/+kLMtek2lmIoHiqEtPpG8VA1+b\\/+GyWF9JgmhC0U02N12d\\/qvwkrk+cWSqX3xdfsyXObNt1x+\\/btS0FxDwCAQaLAIVI3a0cUpFtRLol52dzmzXc4dOiQi7ouOnjoYHHbScceV5ya+vV4Uf3GeMl8caiuwpJGChw5usMoj96e6yujNAqFQjr2V8d8M+aDxXL56Qvbtyyfc845U01eTgAAyE8qcEwvbv6XoMAhsprVC71r44XeRfHi7vmTm2bPMGKjD5aWZpZ27dpbmpj4pWKp9DelUundoVi8OFQvthU6upI0KmbldsQbCzefByUVNS4vFAufKBaL\\/1gZH3\\/U\\/FFbTpubm9sUlk0YCgDAEFgpcMwpcMiGzsoF3uGlTMOlpXL5LROz0+ceddxxx1rmMieHDhXu8ZCHTO85+eQTpjfP321iaurJpUrl1YVi8RPxby8phMJVwQiPls\\/vcNN5XqyO0gjhh\\/F8\\/99SpfzeyuTkC2Y3bXrYpp3b7njr00\\/fdvDQIec8AADDZ6XAsbD5zUGBQzZkbrYixHeLpdKrNx+786y9e\\/eOB\\/MLDJr0epRPOvPM2eNPOfnWM5sXH12qlF4e\\/+y\\/Yq4ItZVZ6mQAzrO+Jqvok261uiwexU+UKpW\\/XlhaOnffmWces3t5eSL+uYIGAADD7+B73lOeXlhcU+AQGcWsLdwVVj7FLlSLG2k1iH8rj409fW7btjsu\\/\\/Ivp4s9hsTy8nJ5aWlp+\\/yWLadNzE79arFcflqxUnpZoVD4YCgULg5r5vI4fCtGGsFQGNZCyC36fMRtJiu3VsV8L\\/7Zf8dz+z2lSunFxbHyE2e2LD5wcevWU7bv3bt04MCBUrdeAwAAGBi1Ase\\/BgUOGencdFG7uszl5fEC+MMTs7MPu8297rUYGCm\\/fPDgxOYTT7zV2PzM\\/cbHJx9TmZp4cbzYvzC+5p+Nf\\/2tmB+FaiEgjWpI58MNa9Ko+JE1OqJbadTG2j6mfl8T84OYr8f9uqhUKl1QmZx8bmVi4lfnt269+97TT9\\/1iI+\\/pNLVAwsAAIOsWuDYpMAhI5nD82oU0vn9\\/Xgh+MHyxMQzJjfPnb6we\\/dCMDR\\/Q0gjPbadsm16btfcpon5+ePmt8yfNjM\\/c9bk\\/PwvTM7OPr40Pn5esVI5P5RKF4Ri8ePxPPlyfNq3QyqEVSc4XS2EHJ7Lov4okPVktfiWCi+pcPGd2I+vhDTnSKn0tkK5\\/PrYz78dm519Uur3xMLMnacXFm47sbh4zNyuXZt27N8\\/ZWQGAAAb2kqBY37xrUGBQ0YjR845kIoan4oXiX89PjV19uytbrU5QIaDBw+W997udktLu3adkIoH5cnZM6c2L\\/zczOL8Iyfm5v5wbHz8OaVK6W+LldKrQ7n0unhu\\/UuhVLggjQ6JeW+hXPpAzIdK5dJHYj5WTfmj6f\\/j338g5n0x7ywU0nMKb4zf+9rSWOkVlfHKeVMzU380s3nzb80tLj5wYnb2TpXp6VNTP44\\/5ZStj3jEI4zEAACAZt6TChxzi28LChwypCkUiocKK0teVpe9DNVP3L9SrFT+Znxh4d6bdu7cFf\\/fpKF07lA8d9LoiOXlctgfKmFvPJ92hzRfy+S2bduml5aWZjZt2jS3uLg4v7B7YWH+mGMWj8zinsX59D1btmyZDfE5YVeYXNnOvn1jabsroy8OHTryHHXOAgBAq1KBY2p+8e1heCbZkw2dNFlo4cbDCTcUCitzEXy7UCh8slKp\\/OXY9OQvzu1aOmHv2WenogYAAAAbQbXAMa\\/AIQOZQqGwklBdKSKN1DhUWxEljThKkyu+bXxx7tFLu3efmm63CocVgk+\\/AQAANg4jOGTAUm\\/yxTTx4hWhUPivUrn82vLE2NMnZ2fvOz47e1Ia8n\\/olsP6AQAA2Ghqk4ymAkfW8oiyoXPTrSBdz00rnBRutv10HqZVJK4MaRWLQuHC4tjYM6eX5u65Y9++Yw4dOmTVEwAAAG5pZZLR+fl3BgUOqZvuFjgOL9saVicETeddWorzfwql0tvL4+PPqoyPP2piYeanJiYmjksjNIKlXAEAAGgmDe+fnFt8dPzyvJgXivQo6fz6i5g\\/j3lOzMGYx8Q8uDwz81MT27Ydt2nv3rlw8KBiBgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADDbF\\/Mz8c8Keb5Ma+MuSDmjTGviDkv5mDMQ2N25NNFGjgz5nExz4t5ecy\\/xLwh5sUxT415eMzZMZty6t+omoo5LeYhoXqcXxjzmpi3xry69v\\/pzx8csz9mMp9uAgDAcPqtmEPrzOUxX4j5t5g3xbw05hmh+kv89v7tys28PKx\\/v1rNF\\/qzS7n6iZgnx7wjdH6M0nnxgJjpPvZ7uUGfbtXHftTzR6F+v77co\\/bShfWbMtpslHTx\\/eB1tPuADtrsZ356HfvWinvFPCfmIx3270Mxz+pDP1t1asju66dz7Nd6PCFk79Pv5tgvAADa1I0CR7N8MlQ\\/zd\\/bn11a8fIu9r9ZRrXAcVLMM2P+J3T\\/mL0+5kF92IflBn3YKAWOtJ+vzmirnXwx5pEdtL8RCxxnhWpB77Iu9\\/XSmL8K1RE4eWlU4Ei5W35d60g55ushe38UOAAAhkg\\/Chxr895QvbWh117ex30atQLHT8a8LuaG0Ptj99WYx4beDcVfbtD2Rihw\\/E5GG+vJxaG94tRGKXCUYh4YOh+p0W7eG3PvmEKX+t+qZgWON\\/a5P+v1S6Hx\\/ihwAAAMkX4XOFbznzH36+F+vbyP+zIqBY49oXpxksf58O2YR\\/dgn5YbtDnKBY4018O\\/Zmy\\/W0nzrsy00JeNUOC4S8xFOfX\\/Y6E6X0e\\/NCtwpMLonj72Z73S8Wu0PwocAABDJK8Cx2reHLO7B\\/v18j7uwygUOA6GfM+D1bw7dPfiaLlBW6Na4EhD7judK6XdfDBmrkl\\/RrnAsSVUCz1570NKmiC2lYLTejUrcKSc14d+dMOdQvN9UeAAABgieRc4Uq6I+cUu79fL+9j\\/YS5wHBPz\\/tDZfn825lWhuurDU2r5s5iXhepIkE92uN10Pvxal\\/ZvuUE7o1rgeHnGdusd50+F6mt1Xq0\\/LwrVVT3aOSfSJJizDfozqgWO5dB47oZGSbex\\/EU4\\/L5Zm\\/TnH+1wu+ln0e063J9WtVLgSBNPD8MKPOeH5vuiwAEAMESyChwXh+ov8O0kLSv5h6F6wfStjO02ygu7uF8nd9D\\/ZnlFRr+HtcBxl5jvhNZfn6+F6kVwmkSw2af2q9JFzs+G6ioSX2yjrZRnrXP\\/kuUG2x\\/FAsfPZGxzbS6ofV8zR4Xqz4ePt7jNLFvD+t97H85o98IubLuTC\\/HHZvQnK\\/8RqvOhnNFmO2fWnvepNtt7YAf71KpWChwpT+hhH7ohjRS7LihwAACMlKwCx391Ydsnxjwm5j0ZbdTLW0LvJpxcr7SiyKgUOO4TWn9N0nwpD+1Su3eIeW4bbb9kne0tN9j2KBY4PpuxzZRLQvV178RTGmw39fe0dfS5FW\\/NaPvVPW63nj\\/J6Eu9pMl6z+pSu6mw+OY22n5Ul9o9UqsFjjS6pdyjPnTD80Jr+6HAAQAwRHpZ4FgrXUz+fUZbRyYVRPpxL3m7RqXA0eotA6mwcU6P+rAjVEfstNKP9VzELjfY7qgVOH4lY3spXwnVguN6\\/Hi45cisd8YsrXO7rRiUAseLM\\/pxZP455jY96kO6BeUtLfbjMT1ov9UCR0q3bz3slnRLVbqNRoEDAGDE9KvAsSr90t\\/K\\/eXpF\\/hSj\\/rQqVEocKRPk1v5pb5fw8tvHZqvYpDy3A63v9xgm6NW4LgwY3tpGP5t19vZmrSd79W2+\\/zQv0\\/oB6HA8aSMPhz52v1cn\\/qTljdtZQ6Qbi\\/L3U6B42NdbrtbUtGi1X1Q4AAAGCL9LnCselxGu2vzVz3uQ7uGvcDxYzGXhcbH\\/F0xe3Po2x826VfKr3ew3eUG2xulAseWjG2lPLsbnV0jzQtxbpe32UzeBY4HZbR\\/5M+rRpOt9kKaPyRrbqC1uWMX22ynwJFyZhfb7oZizJeCAgcAwEjKq8CRpNEcjeYMSHlkH\\/rRqmEucMyH6mva6Fg\\/L7feVaVJaq8Ijft4jza3udxgW6NU4HhoxrZSju9GZ3OWZ4Hj9jFXZrSf8qOY+\\/ahH42kn5ONJsxMIz22dqmtdgscecyT0siB0F7\\/FTgAAIZIngWOJN2\\/3+iWlatC94bXr9cwFzjeEBr\\/Ev\\/Y\\/Lp2M+m1Tqu1ZPUz\\/d3mNra33GBbo1TgyLp9ol\\/v417Lq8CxGPM\\/GW2npHkc7tTjPrTq3qHxe\\/zCLrXTqMDx3Yw\\/P7pLbXdDu8tiK3AAAAyRvAscSVpy9JMZ\\/Riki7RhLXDcLzT+Bf6P8utaXWkSxUafmL+2jW0tN9jOKBU4np+xrfd1paf5y6vA8ecZ7aZcG\\/PTPW6\\/Xc1upXlYF9q4bYPtPyfjz7t9m1Sn0q069fqX5grJGk34O7n0FACAjgxCgSNJn\\/A1+uT+D\\/rcn3qGtcDR6BPof8yxX43cPzS+UDu7xe0sN9jGKBU4Xpmxrbd0paf5y6PAcauMNlfTq2VY1yvr51TKxTHT69x+owLH6aH+z\\/E0Me3UOtvthn8I9fudCkNZt\\/AZwQEAMEQGpcCR3DmjLyk\\/iDkmhz6tNYwFjnTrSdYxTRfSC\\/l1ral6nwZ\\/LrQ338FynW1spALHJ7vS0\\/zlUeB4fUabKW\\/qYbvd0GhlovUWixsVOPbHPDnj73qxZG07doX685Sk+UnSakAKHAAAI2CQChxJo6UY\\/zanPq0atgJH+qT2myH7eLY7YWce\\/iNU+3pJzCM6eP5y2BgFjmdnbOuKrvQ0f\\/0ucPxERnsp34\\/Z1qN2uyVN4JzV\\/zSaYnEd2240B8dpobqyS71bzNLKJcV1tLteWe+RJ9X+XoEDAGAEDFqBoxKy74VOn77lsYTpqmErcDRaevWVOfarHSfHPDV0Pqx+OWyMAsfvZGwr5axudDZn\\/S5wvCujvZROlivOw5+F7H14+jq226zAkbwk4+\\/vs4521yPdHvO9Ov1JhZhNte9R4AAAGAGDVuBI7pXRp5QX5tivYStwNBq9cVSO\\/eqn5bAxChz3zNhWypu70dmc9bPA0egWjI\\/1oL1emY35Vqi\\/H99ex3ZbKXCcnPH371xHu+uR9e\\/c2n9PFDgAAEbAIBY4kg+H+v26LFRHeeRhmAocaRLOrIuQ5+TYr35bDhujwDEWqkuWZu3r\\/bvQ3zz1s8DxJxltpZzTg\\/Z66fdD9r7cs8NttlLgSN6e8T39XvY73RbzpTr9uCHc\\/GeAAgcAwAgY1ALHz4fsX6J\\/Iac+DVOB42Uh+\\/gN+vwB3bQcNkaBI\\/mnjO2t5vR19jdP\\/Sxw1LsYThnGCVtnQvb50OmcRq0WOM7J+J6\\/67DdTt03ox9HThSrwAEAMAIGtcCRRmnUu2c6j1+Ql8ahIgAAGoxJREFUVw1LgaMQqhMh1uvrG3PsVx6Ww8YpcNw9Y3tr84vr63Ju+lXg2J\\/RTsrvdbmtfnl5qL8\\/l4bqz4p2tVrgSNv+XJ3vuSZmawftdiprPpW7HvF9ChwAACNgUAscyV+F+n37Yk79GZYCR6MVIH4px37lYTlsnAJHkrVc7NqkCSD7eYHZDf0qcDwxo52UYZ235mdCawWJVrVa4Egek\\/F9f9xBu53Imk\\/l03W+V4EDAGAEDHKB40DI\\/kV6dw79GZYCx1NC9nHbnmO\\/8rAcNlaBIxUuLsnY7tqk+TrS8pgz62irn\\/pV4Lgwo53PdLmdfmp0m8rvd7C9dgocWauXpMlPxztou12vyOjnw+p8rwIHAMAIGOQCR1q+L+sX6Z\\/PoT\\/DUuA4P9Tv50V5diony2FjFTiS0zK2Wy+pGJIu4Dpdhrdf+lXguCyjnb\\/scjv99pFQf79e0cG22ilwJM\\/N+N5f66DtduwK1dthWi2uKHAAAIyAQS5wJBeH7n3yuF7DUuD4RKjfz1fm2amcLIeNV+BIfilj21lJF31PjdnchbZ7oR8Fji0ZbaQ8oovt5CHdllRvvz7YwbbaLXDsCdUVS4783nq3iXTT\\/8vo4x9mfL8CBwDACBj0Asc7Q\\/3+dboCwHoMS4HjylC\\/n0\\/Ls1M5WQ4bs8CRnBWqE0m2U+i4IlQLYWkJ0WKX+tEN\\/ShwnJHRRspZXWwnD08I9ffr2x1sq90CR\\/LajO\\/\\/6Q7ab0XWrTHpZ+OmjOcocAAAjIBBL3D8Tajfv7fn0JdhKHDMhuyLj4fm2K+8LIeNW+BIjo15c0Y7zZL68dhQvVjMWz8KHD+b0UbKsV1sJw9pae2sfWv39e2kwPFTGd\\/\\/5jbbbtWjMtp7SYPnKHAAAIyAQS9w\\/Emo379eD2+uZxgKHI3mLTmQY7\\/yshw2doFj1U+G7Ak0m+Xbtb5u6UG\\/WtWPAsd9M9pIGbZVZ45055C9bye0ua1OChzJpzKe0+33YdbytM3aUuAAABgBg17g+L1Qv3+X5tCXYShwpAuxrIuP++bYr7wsBwWOtdI58N8Z7TbLD2KeHfIZ0dGPAkejVZuybmsYFvtC9r7dpc1tdVrg+OWM53R7AtdzMtp5S5PnKXAAAIyAQS9wPDrU79\\/lOfRlGAociyH74sMIDgWOVefGvCOj\\/Wb5bMz+PvRxrX4UOO6T0UbKsI\\/gSBN9Zu3b3drcVqcFjrRyybfqPKfRvBidyDqv79nkeQocAAAjYNALHE8K9fv3tRz6MgwFjjQxZNbFx6\\/k2K+8LAcFjkaODtXzut6EjM3y233sZz8KHHfLaCPl+C62k4fbhux9O73NbXVa4EielvG8J7XZhyxZ+5luaSw0ea4CBwDACBj0AkfWHBwX5dCXYShwJINwQTooloMCRytmQnWlja9n9Ckrr+hT\\/\\/JeReX2XWwnD43m4Di5zW2tp8CxLeaaOs9L5125zX7U87KMfv1aC89V4AAAGAGDXuBIFzD1+ndhDn0ZlgJHukCu18\\/n59mpnCwHBY52pYvBz4fWixzpvTjR4z71o8CxN6ONlJ\\/vYjt5ODdk71u7k8eup8CR\\/F3Gcx\\/cZj+OlG4jqlc8SbfFjLfwfAUOAIARMOgFjn8P9fv3whz6MiwFjqx70P81z07lZDkocHQifZqebmlqtdDxzzGlHvanHwWO1P9rM9r5\\/S62k4esn12XdbCt9RY4sp7\\/sQ76slbW++mPWny+AgcAwAgY5AJH+tSt3idyKb+VQ3+GpcDxolC\\/n9\\/Ks1M5WQ4KHOtRCdVbm74Tmhc5Ht3DfvSjwJH8Z0Y7r+lyO\\/329lB\\/v97bwbbWW+BI3pXx\\/Lt00J8kawLT9O9HqxPEKnAAAIyAQS5w3D1k\\/yL9kzn0Z1gKHI8K2cft1Bz7lYfloMDRDek2hjQCqFGBI03826tbVfpV4PjHjHbyWJa6W9Kyvlmv2Qs62F43Chz3y3j++R30J3l4xvZe2sY2FDgAAEbAIBc4nh3q9+2KnPozLAWOW4fsC5An5tivPCwHBY5uynpPruYJPWq3XwWO38hoJ+UnutxWv5wTsvfpfh1srxsFjrTa05fqPP+GUF3Sth1pdZTPZfTntm1sR4EDAGAEDGqBI\\/3SmrWiw1tz6tOwFDiSesO1Uz6XZ6dysBwUOLrtDSH7mH6qR232q8DRqDh4Xpfb6pd0e03WPi10sL1uFDiS383YxvPa7M\\/ZGdt5R5vbUeAAABgBg1rguEfI\\/iX6N3Lq0zAVOP4uZB+\\/H8+xX\\/22HLKPw23y69aKrCWQB73AsTk0Xk72+B602a8CR\\/LFjLa+3YO2ei3dWpT1On2gw212q8AxG3N5nW1cXvu7Vl2Q0Zdz2thGosABADACBrXA8b5Qv19Xhc4+deyGYSpw3DVkX4S8Msd+9duZIfs43DXHfiVZRajP59mpFj02ZB\\/Xx\\/agvX4WOLJG1qQ8vAft9dJTQ\\/a+PKrDbXarwJG8IGM7v93i82+V8fw0Uq3QZl8UOAAARsAgFjjultGnXl3QtGqYChxJ1ifRKbty7Fc\\/NboYe1CO\\/UqyVrb4eJ6datFMzPdD\\/f6\\/pAft9bPAsTejrZTP9KC9XkmTi6ZRJ1n70mmhuJsFjjTfxg11tpPm5yi28PyXZPSjk+KNAgcAwAgYtAJHKebTGX1KaWfSuG4btgLH48NgForasRxzYcwJHT5\\/d8g+Bk9af\\/fW5fOhfr\\/anTsgL1lLfV7Qg7b6WeBI\\/iWjvZS8bpFrV9bPq5S\\/Wcd2u1ngSN6Usa1mE6BuirmyzvO+F6rFnXYpcAAAjIBBK3A8IaM\\/Ka\\/LqU+rhq3Ake5jT7\\/sZx3Pe+bXtZakJUf\\/Oxzub5p8cK7NbaSC2bWh\\/v6\\/t1sd7cBtMvqU8pc59qsdWZ+e\\/2cP2up3gePOGe2tXkBv61G73XJyyO5\\/ynom2O12gSNrOfD3NHneUzKe98wO+pAocAAAjIBBKnA0uqhIuXUOfVpr2AocSaP5BL4ZBvtWlaeHW\\/b5azEPbnM7H6uzndXs6FZn23SwQZ+GZYTAH4b6\\/f9qD9rqd4EjeW9Gmynv6mG765UKmxeF7L6v95h1u8CRfCpje1kj9sZD\\/ZWirgmd\\/0xT4AAAGAGDUuBInzg2Wpnh2X3uTz0vDPX7NshLr6a5Ei4O2cf1Q6E6UmLQpPkxGhW77tXGtp7bYDtP7l6X2\\/KlBn36sXVsNxVsnrHu3rXm+aF+\\/z\\/cg7byKHDsz2hzNS\\/qYdvr8cbQuN\\/HrXP7vShwPDxje6\\/I+P5fafP7W6HAAQAwAgahwLEv5hsZ\\/UhJF+gzbW5zMeasUP3l9O9jjupCP8\\/P6N\\/7u7DtXvqF0PiCJ803UMqtd7eUhqxn3VaS8uY2t3evBtu6InTn3GjHkxv0p9PRD9Ph5qNC+rFCzOtC\\/X14fQ\\/ayqPAkWSt8rGaJ\\/S4\\/Xb9VWjc3yd2oY1eFDgajcjYWuf7s+ZpWs8cTQocAAAjIO8Cxxkx38noQ0q60L1ji9tK35eKEF+os52f7kJfv5LRx3\\/uwrZ77TWh8YXPP+TXtZtJ84L8IGT389LQ2fwHlzbY5t+uu9et2xmqRZWsvvy\\/Drb5q6F6687a7by3C31tJI36yZrf5YU9aC+vAkea8+VzGW2v5jE97kOr\\/jw07ueHutROLwocyTMytnnknBpZq2yt97YhBQ4AgBGQZ4Gj2W0IKY9tY3tnNdhOJxeOa53QYNvDMClkGgHTaHWalHeGzpeO7Ib7ZPRrbe7b4baf12S7v7KejrcojbL49yb9OLHNbTba3m91pdf13b9Bu+f2oL28ChxJumWoUVEq5bl96EeWdF69NqNfq7kkVItr3dCrAkeaO+O6Ots8clWUrBVuOv3ZsEqBAwBgBORV4Ph\\/Ge2uzUvb3ObmBtv67x7292Hr3Ha\\/nBQar6qyepxuk0Pf\\/qBJv1LWczvA9pgfNdh2Gil0l3Vsv5l0C9AFDdpP+fsOtvuiBttL+7u8zn7XMxayl7i9KlQnuey2PAscyQMy2l+bt4T+FwiPjfl4C327Uxfb7FWBI3llxnYfWfv7tPrLDXX+Ps1pU1xn2wocAAAjoN8FjvSL6sUZba7NWzvcfqPh5J1+op0++byswXb7PYfDejRbqSbl+6F\\/w+7Tp+MfaqFPL+5CW1lD4FeTbo15eBfaOVI6P97RQtvHdLDtY5tsN4086ObFbXJeg\\/be0OW2VuVd4EgaLWG9mlT4uVuf+pNGHTW69Wo1D+hyu70scNwxY7vp53ohZBf0ujFaSYEDAGAE9KPAMR\\/zmyF7Dosj84FQvfe9E41GAqSLyHZ\\/AU+3djS6DeA\\/Ouxnnlr5NDrlg6F6208vnBmqIxZa6cfrutTmZMwXW2gvfYrcrU\\/i0wSn9SZP7OZFVL3ldI\\/Mvdex\\/bX+uEk77axu045BKHAkf5nRjyOTVvPY26M+pCLAO1vsRy8uzntZ4Eg+mrHtrFsaj7yFpVMKHAAAI6BXBY5U1Ei3brwpY\\/tZScP4J9fR7s4m209L0e5vcVupyPK+Jtv7tXX0NU\\/pfvVWX5NU6EivZadFp1XpdU2fOn+4jbZfts42j3SHmCtbaDcVJdJ7o9JhO+ki8MIW2klJtzasZ3h9OVQnFW3URprb4O9iju6wjbSMc7P9ubDTHWjBoBQ4kudk9KVeXhWqE+euV5pn48Ex726j7d\\/oQrv19LrA0Wh+l3p5VhfaTBQ4AABGQFaB49sxT2kz6RaAdBHV6oXdkenW6gsvbKGtNMw+a3WWtMRsKyNOvtKl\\/ublp2K+G9p7jdISoOeG6jFqJs3F8BO170\\/LbTa6zade\\/mz9u1hXqyNYUv4nVCeQvF\\/MpibbTfv6+FAtWLS6\\/fRpdbtLINeT5hipt3pQvbwxVI\\/BUgvbfGjM21rc7q27sB9ZBqnAkTw+oz9ZSe+ztFrPz7TRRnqPPSRkL8fbKA9cz8410esCRyrYHbkqUFZS4W5XF9pMFDgAAEZAVoGjn0lzPvxiF\\/cp3V7w9RbbTpPTpYukVJz569B8xMba9GPljV7bHfNvobPXLa3M8LFQXdUgHbvVY5iGz3+jw22mpFuJHtHDfQ617XfSt6+GagHvJaE68WxaIrjZ6jRZ+VSoTozbLWn00n+22Yc0qWyaNyPNcfLHtcc06qqVW3n6eRE4aAWOJN2+9c2MfjXLl0P1Z00qXqSCbDr2fxWqxz7dEndJh9tNc1Wc2sudDr0vcCRPbNDG2ryqS+0lChwAACMg7wJHGhHQ6bD5Ru7Z4353suLFIGs2AWe\\/8p5QLbr0QxoK38rtKr1IKpLM92CftoXsOQx6lfWsbtOqQSxwJOl4vybk\\/75JSaPSujEXRTP9KHCk0VKtvDfP6FJ7iQIHAMAIyKvAkSbnbGe4dic6\\/ZS+WdIcEuuZJ2RQnRCyLyR7nXT7ymN7v4u3cNvQeOWdXuRJPd6ndJH72j7ty2\\/2eF9WDWqBY1UazdHv82g1aRWi2\\/Z+F2\\/SjwJH0mxC1\\/d3sa1EgQMAYAT0u8CRPrn+2b7sWdXDu9z\\/NCR6uo\\/9z0N6fT4T+nM+XBPz56G7t2q0KxUEXhB6v6+fCNV5OvrlyaH9OVZaTZrv4\\/T+7crAFziSNCFtKtKl+Yv68d5J88P8Uqgun9pP\\/SpwnNygnZT7d7GtRIEDAGAE9KPAkeZpSMu3HtenfTpS+kW5nbk16iXN6fGofnc8Z2l\\/PxJ6c06ki8AXxRzft71pLvUlzSFyRejuvqZz70F93I+10kSvaULMVicgbZY00uZ5oTsTo7ZjGAocq9LkoGnp3q+E3rx30pwvv92vnamjXwWO5IKMdtLcSetZeageBQ4AgBHQjQLH5TGfD9WlKtOEhX8Tqr\\/gp5n8m63U0E9pidB0Afud0Pq+pU\\/dfz1mIof+DooTY54a866wvvPk46E6WuOs\\/na\\/beniPa0eknVx1UrS++FpoXrsBkUaPfL8mItC+\\/uTVlJJK3rkdWvWMBU41rpLqBaE0s+R9bx3UpHsYOjvrShZ+lng+JmMdnpRdFDgAABgaKVix+NC9YL7laF6MZvmLUgrGaQVDVpZRnMjSrdzpOVlHxOqqz+kC88L1yQtQfqKmL8I1QuyXw39vZWhF9LcJHcN1bkz0qoXFx6RdO48K+Y+oXoB2mw52UGQloBNtzekQmRaOeX8UC1i\\/FOovgf+NOaRMbfPq4MjKP08Sbd\\/pUlZXxbzjnDLcyklvafS6Kb0HkvFwFG\\/JQ4AAAAAAAAAAAAAAAAAAAAAAACANvxDzJUiIiLStbw0AADQd2nlh\\/UuBSsiIiKH86oAAEDfKXCIiIh0NwocAAA5UOAQERHpbhQ4AAByoMAhIiLS3ShwAADkQIFDRESku1HgAADIwdNi3i0iIiJdy5MDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD\\/vz04JAAAAAAQ9P+1wRsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAL6JKIFTUgrE4AAAAASUVORK5CYII=\\\",\\\"alt\\\":\\\"Imagen\\\",\\\"id\\\":\\\"igyb\\\"}}]}]}]}]},{\\\"type\\\":\\\"table\\\",\\\"droppable\\\":[\\\"tbody\\\",\\\"thead\\\",\\\"tfoot\\\"],\\\"attributes\\\":{\\\"width\\\":\\\"100%\\\",\\\"cellpadding\\\":\\\"0\\\",\\\"cellspacing\\\":\\\"0\\\",\\\"border\\\":\\\"0\\\"},\\\"components\\\":[{\\\"type\\\":\\\"tbody\\\",\\\"draggable\\\":[\\\"table\\\"],\\\"droppable\\\":[\\\"tr\\\"],\\\"components\\\":[{\\\"type\\\":\\\"row\\\",\\\"draggable\\\":[\\\"thead\\\",\\\"tbody\\\",\\\"tfoot\\\"],\\\"droppable\\\":[\\\"th\\\",\\\"td\\\"],\\\"components\\\":[{\\\"type\\\":\\\"cell\\\",\\\"draggable\\\":[\\\"tr\\\"],\\\"attributes\\\":{\\\"id\\\":\\\"iibsm\\\"},\\\"components\\\":[{\\\"tagName\\\":\\\"p\\\",\\\"type\\\":\\\"text\\\",\\\"attributes\\\":{\\\"id\\\":\\\"ie5ff\\\"},\\\"components\\\":[{\\\"type\\\":\\\"textnode\\\",\\\"content\\\":\\\"Prueba 1\\\"}]}]}]}]}]}],\\\"head\\\":{\\\"type\\\":\\\"head\\\"},\\\"docEl\\\":{\\\"tagName\\\":\\\"html\\\"}},\\\"id\\\":\\\"fvxLD11derVi2LBM\\\"}],\\\"type\\\":\\\"main\\\",\\\"id\\\":\\\"dVyhBv3QpOKozLiB\\\"}],\\\"symbols\\\":[]}\"}','{\"html_content\":\"\",\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[],\\\"pages\\\":[],\\\"symbols\\\":[]}\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/email-builder/campaigns/2',200,'2026-06-04 01:34:13'),(157,1,'updated','chats','Modificó Chat #1',1,'App\\Models\\Chat','{\"estado\":\"abierto\",\"cerrado_por\":null,\"cerrado_en\":null}','{\"estado\":\"cerrado\",\"cerrado_por\":1,\"cerrado_en\":\"2026-06-04T01:38:39.256366Z\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/1/cerrar',200,'2026-06-04 01:38:39'),(158,1,'updated','email_campaigns','Modificó EmailCampaign #2',2,'App\\Models\\EmailCampaign','{\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[],\\\"pages\\\":[],\\\"symbols\\\":[]}\"}','{\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[{\\\"selectors\\\":[\\\"#icel\\\"],\\\"style\\\":{\\\"background-color\\\":\\\"#c20000\\\"},\\\"wrapper\\\":1}],\\\"pages\\\":[],\\\"symbols\\\":[]}\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/email-builder/campaigns/2',200,'2026-06-04 02:02:34'),(159,1,'updated','email_campaigns','Modificó EmailCampaign #2',2,'App\\Models\\EmailCampaign','{\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[{\\\"selectors\\\":[\\\"#icel\\\"],\\\"style\\\":{\\\"background-color\\\":\\\"#c20000\\\"},\\\"wrapper\\\":1}],\\\"pages\\\":[],\\\"symbols\\\":[]}\"}','{\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[{\\\"selectors\\\":[\\\"#i24v\\\"],\\\"style\\\":{\\\"background-color\\\":\\\"#c5b4b4\\\"},\\\"wrapper\\\":1}],\\\"pages\\\":[],\\\"symbols\\\":[]}\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/email-builder/campaigns/2',200,'2026-06-04 02:10:59'),(160,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-04 03:15:26'),(161,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-04 03:15:29'),(162,1,'updated','email_campaigns','Modificó EmailCampaign #2',2,'App\\Models\\EmailCampaign','{\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[{\\\"selectors\\\":[\\\"#i24v\\\"],\\\"style\\\":{\\\"background-color\\\":\\\"#c5b4b4\\\"},\\\"wrapper\\\":1}],\\\"pages\\\":[],\\\"symbols\\\":[]}\"}','{\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[{\\\"selectors\\\":[\\\"#ixwb\\\"],\\\"style\\\":{\\\"background-color\\\":\\\"#794e4e\\\"},\\\"wrapper\\\":1}],\\\"pages\\\":[],\\\"symbols\\\":[]}\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/email-builder/campaigns/2',200,'2026-06-04 03:55:42'),(163,1,'created','chats','Creó Chat #3',3,'App\\Models\\Chat',NULL,'{\"titulo\":\"das\",\"descripcion\":\"asd\",\"creador_id\":1,\"estado\":\"abierto\",\"id\":3}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats',200,'2026-06-04 17:55:25'),(164,1,'created','chat_mensajes','Creó ChatMensaje #7',7,'App\\Models\\ChatMensaje',NULL,'{\"chat_id\":\"3\",\"usuario_id\":1,\"contenido\":\"Hola\",\"id\":7,\"archivo_url_completa\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/3/mensajes',200,'2026-06-04 17:55:30'),(165,1,'created','chat_mensajes','Creó ChatMensaje #8',8,'App\\Models\\ChatMensaje',NULL,'{\"chat_id\":\"3\",\"usuario_id\":1,\"contenido\":\"😄\",\"id\":8,\"archivo_url_completa\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/3/mensajes',200,'2026-06-04 17:55:35'),(166,1,'created','chat_mensajes','Creó ChatMensaje #9',9,'App\\Models\\ChatMensaje',NULL,'{\"chat_id\":\"3\",\"usuario_id\":1,\"contenido\":\"\",\"archivo_url\":\"chat_adjuntos\\/b86e21a1-c01d-4da5-963b-2a08687f3f93.jpg\",\"archivo_nombre\":\"SaveClip.App_520760025_18364275244150378_1536036571569026107_n.jpg\",\"archivo_tipo\":\"image\\/jpeg\",\"archivo_size\":149200,\"id\":9,\"archivo_url_completa\":\"http:\\/\\/127.0.0.1:8000\\/storage\\/chat_adjuntos\\/b86e21a1-c01d-4da5-963b-2a08687f3f93.jpg\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/3/mensajes',200,'2026-06-04 17:55:45'),(167,1,'created','ventas','Creó Venta #5',5,'App\\Models\\Venta',NULL,'{\"numero_factura\":\"VTA-20260605-0001\",\"cliente_id\":null,\"usuario_id\":1,\"ubicacion_id\":1,\"subtotal\":\"8000.00\",\"descuento_total\":\"0.00\",\"impuesto_total\":\"1040.00\",\"total\":\"9040.00\",\"metodo_pago\":\"efectivo\",\"monto_efectivo\":10000,\"monto_tarjeta\":0,\"monto_sinpe\":0,\"referencia_sinpe\":\"\",\"dinero_recibido\":10000,\"cambio\":960,\"estado\":\"completada\",\"notas\":\"\",\"id\":5}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ventas',200,'2026-06-05 08:40:36'),(168,1,'created','venta_detalle','Creó VentaDetalle #5',5,'App\\Models\\VentaDetalle',NULL,'{\"venta_id\":5,\"producto_id\":1,\"cantidad\":1,\"precio_unitario\":\"8000.00\",\"descuento\":0,\"impuesto\":1040,\"subtotal\":8000,\"id\":5}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ventas',200,'2026-06-05 08:40:36'),(169,1,'created','ventas','Creó Venta #6',6,'App\\Models\\Venta',NULL,'{\"numero_factura\":\"VTA-20260605-0002\",\"cliente_id\":1,\"usuario_id\":1,\"ubicacion_id\":1,\"subtotal\":\"4500.00\",\"descuento_total\":\"0.00\",\"impuesto_total\":\"585.00\",\"total\":\"5085.00\",\"metodo_pago\":\"efectivo\",\"monto_efectivo\":6000,\"monto_tarjeta\":0,\"monto_sinpe\":0,\"referencia_sinpe\":\"\",\"dinero_recibido\":6000,\"cambio\":915,\"estado\":\"completada\",\"notas\":\"\",\"id\":6}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ventas',200,'2026-06-05 08:44:14'),(170,1,'created','venta_detalle','Creó VentaDetalle #6',6,'App\\Models\\VentaDetalle',NULL,'{\"venta_id\":6,\"producto_id\":2,\"cantidad\":1,\"precio_unitario\":\"4500.00\",\"descuento\":0,\"impuesto\":585,\"subtotal\":4500,\"id\":6}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ventas',200,'2026-06-05 08:44:14'),(171,1,'created','ventas','Creó Venta #7',7,'App\\Models\\Venta',NULL,'{\"numero_factura\":\"VTA-20260605-0003\",\"cliente_id\":1,\"usuario_id\":1,\"ubicacion_id\":1,\"subtotal\":\"4500.00\",\"descuento_total\":\"0.00\",\"impuesto_total\":\"585.00\",\"total\":\"5085.00\",\"metodo_pago\":\"efectivo\",\"monto_efectivo\":6000,\"monto_tarjeta\":0,\"monto_sinpe\":0,\"referencia_sinpe\":\"\",\"dinero_recibido\":6000,\"cambio\":915,\"estado\":\"completada\",\"notas\":\"\",\"id\":7}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ventas',200,'2026-06-05 08:50:20'),(172,1,'created','venta_detalle','Creó VentaDetalle #7',7,'App\\Models\\VentaDetalle',NULL,'{\"venta_id\":7,\"producto_id\":2,\"cantidad\":1,\"precio_unitario\":\"4500.00\",\"descuento\":0,\"impuesto\":585,\"subtotal\":4500,\"id\":7}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ventas',200,'2026-06-05 08:50:20'),(173,1,'created','ventas','Creó Venta #8',8,'App\\Models\\Venta',NULL,'{\"numero_factura\":\"VTA-20260605-0004\",\"cliente_id\":null,\"usuario_id\":1,\"ubicacion_id\":2,\"subtotal\":\"16000.00\",\"descuento_total\":\"0.00\",\"impuesto_total\":\"2080.00\",\"total\":\"18080.00\",\"metodo_pago\":\"tarjeta\",\"monto_efectivo\":0,\"monto_tarjeta\":18080,\"monto_sinpe\":0,\"referencia_sinpe\":\"\",\"dinero_recibido\":0,\"cambio\":0,\"estado\":\"completada\",\"notas\":\"\",\"id\":8}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ventas',200,'2026-06-05 08:55:33'),(174,1,'created','venta_detalle','Creó VentaDetalle #8',8,'App\\Models\\VentaDetalle',NULL,'{\"venta_id\":8,\"producto_id\":1,\"cantidad\":2,\"precio_unitario\":\"8000.00\",\"descuento\":0,\"impuesto\":2080,\"subtotal\":16000,\"id\":8}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/ventas',200,'2026-06-05 08:55:33'),(175,1,'created','chats','Creó Chat #4',4,'App\\Models\\Chat',NULL,'{\"titulo\":\"sdfgdxg\",\"descripcion\":null,\"creador_id\":1,\"estado\":\"abierto\",\"id\":4}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats',200,'2026-06-05 09:57:18'),(176,1,'created','chat_mensajes','Creó ChatMensaje #10',10,'App\\Models\\ChatMensaje',NULL,'{\"chat_id\":\"4\",\"usuario_id\":1,\"contenido\":\"Holas\",\"id\":10,\"archivo_url_completa\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/4/mensajes',200,'2026-06-05 09:57:26'),(177,1,'created','chat_mensajes','Creó ChatMensaje #11',11,'App\\Models\\ChatMensaje',NULL,'{\"chat_id\":\"4\",\"usuario_id\":1,\"contenido\":\"Como estan lol\",\"id\":11,\"archivo_url_completa\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/4/mensajes',200,'2026-06-05 09:57:36'),(178,1,'updated','chats','Modificó Chat #4',4,'App\\Models\\Chat','{\"estado\":\"abierto\",\"cerrado_por\":null,\"cerrado_en\":null}','{\"estado\":\"cerrado\",\"cerrado_por\":1,\"cerrado_en\":\"2026-06-05T09:57:42.055813Z\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/4/cerrar',200,'2026-06-05 09:57:42'),(179,1,'created','email_campaigns','Creó EmailCampaign #3',3,'App\\Models\\EmailCampaign',NULL,'{\"nombre\":\"Lol (copia)\",\"asunto\":\"xd\",\"html_content\":null,\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[{\\\"selectors\\\":[\\\"#ixwb\\\"],\\\"style\\\":{\\\"background-color\\\":\\\"#794e4e\\\"},\\\"wrapper\\\":1}],\\\"pages\\\":[],\\\"symbols\\\":[]}\",\"estado\":\"borrador\",\"usuario_id\":1,\"id\":3}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/email-builder/campaigns',200,'2026-06-06 20:23:20'),(180,1,'deleted','email_campaigns','Eliminó EmailCampaign #3',3,'App\\Models\\EmailCampaign','{\"id\":3,\"nombre\":\"Lol (copia)\",\"asunto\":\"xd\",\"html_content\":null,\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[{\\\"selectors\\\":[\\\"#ixwb\\\"],\\\"style\\\":{\\\"background-color\\\":\\\"#794e4e\\\"},\\\"wrapper\\\":1}],\\\"pages\\\":[],\\\"symbols\\\":[]}\",\"thumbnail\":null,\"estado\":\"borrador\",\"usuario_id\":1,\"programada_para\":null,\"enviada_en\":null,\"total_recipients\":0,\"total_enviados\":0,\"total_abiertos\":0,\"total_clicks\":0,\"total_rebotes\":0}',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/email-builder/campaigns/3',200,'2026-06-06 20:23:24'),(181,1,'updated','productos','Modificó Producto #1',1,'App\\Models\\Producto','{\"categoria_id\":null}','{\"categoria_id\":1}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productos/1',200,'2026-06-06 20:24:47'),(182,2,'updated','usuarios','Modificó User #2',2,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-06 22:57:43'),(183,1,'created','roles','Creó Role #3',3,'App\\Models\\Role',NULL,'{\"nombre\":\"David\",\"descripcion\":null,\"permisos\":[\"crm_editar_pipeline\",\"clientes\"],\"activo\":true,\"id\":3}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/roles',200,'2026-06-06 22:59:27'),(184,1,'updated','usuarios','Modificó User #2',2,'App\\Models\\User','{\"rol_id\":2}','{\"rol_id\":3}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/usuarios/2',200,'2026-06-06 22:59:34'),(185,1,'created','clientes','Creó Cliente #2',2,'App\\Models\\Cliente',NULL,'{\"nombre\":\"David aa\",\"cedula\":null,\"empresa\":null,\"cedula_juridica\":null,\"telefono\":null,\"email\":null,\"direccion\":null,\"ciudad\":null,\"cliente_categoria_id\":null,\"credito_tienda\":\"0.00\",\"activo\":true,\"clasificacion\":\"\",\"id\":2}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/clientes',200,'2026-06-06 23:27:38'),(186,1,'created','clientes','Creó Cliente #3',3,'App\\Models\\Cliente',NULL,'{\"nombre\":\"David aa\",\"cedula\":null,\"empresa\":null,\"cedula_juridica\":null,\"telefono\":null,\"email\":null,\"direccion\":null,\"ciudad\":null,\"cliente_categoria_id\":null,\"credito_tienda\":\"0.00\",\"activo\":true,\"clasificacion\":\"\",\"id\":3}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/clientes',200,'2026-06-06 23:27:39'),(187,1,'created','productos','Creó Producto #3',3,'App\\Models\\Producto',NULL,'{\"codigo\":\"lolo\",\"codigo_barras\":null,\"nombre\":\"lllll\",\"categoria_id\":null,\"proveedor_id\":null,\"precio_compra\":\"2000.00\",\"precio_venta\":\"6000.00\",\"stock\":0,\"stock_minimo\":5,\"impuesto\":\"13.00\",\"activo\":true,\"id\":3}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productos',200,'2026-06-11 18:54:36'),(188,1,'deleted','productos','Eliminó Producto #3',3,'App\\Models\\Producto','{\"id\":3,\"codigo\":\"lolo\",\"codigo_barras\":null,\"nombre\":\"lllll\",\"descripcion\":null,\"categoria_id\":null,\"proveedor_id\":null,\"precio_compra\":\"2000.00\",\"precio_venta\":\"6000.00\",\"stock\":0,\"stock_minimo\":5,\"stock_maximo\":null,\"unidad\":null,\"imagen\":null,\"impuesto\":\"13.00\",\"margen_ganancia\":null,\"peso\":null,\"costo_envio\":null,\"costo_marketing\":null,\"costo_logistica\":null,\"visible_web\":false,\"activo\":true}',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productos/3',200,'2026-06-11 18:54:42'),(189,1,'created','clientes','Creó Cliente #4',4,'App\\Models\\Cliente',NULL,'{\"nombre\":\"Daniel Morales\",\"cedula\":\"234534534\",\"empresa\":null,\"cedula_juridica\":null,\"telefono\":null,\"email\":null,\"direccion\":null,\"ciudad\":null,\"cliente_categoria_id\":null,\"credito_tienda\":\"0.00\",\"activo\":true,\"clasificacion\":\"\",\"id\":4}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/clientes',200,'2026-06-11 19:47:37'),(190,1,'updated','clientes','Modificó Cliente #4',4,'App\\Models\\Cliente','{\"clasificacion\":\"\",\"cliente_categoria_id\":null}','{\"clasificacion\":\"Frecuente\",\"cliente_categoria_id\":1}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/clientes/4',200,'2026-06-11 19:51:26'),(191,1,'deleted','clientes','Eliminó Cliente #2',2,'App\\Models\\Cliente','{\"id\":2,\"nombre\":\"David aa\",\"cedula\":null,\"empresa\":null,\"cedula_juridica\":null,\"telefono\":null,\"email\":null,\"direccion\":null,\"ciudad\":null,\"pais\":null,\"clasificacion\":\"\",\"datos_fiscales\":null,\"credito_tienda\":\"0.00\",\"notas\":null,\"activo\":true,\"puntos_acumulados\":0,\"puntos_canjeados\":0,\"portal_activo\":false,\"origen\":null,\"lat\":null,\"lng\":null,\"total_compras\":\"0.00\",\"cliente_categoria_id\":null}',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/clientes/2',200,'2026-06-11 20:10:38'),(192,1,'deleted','clientes','Eliminó Cliente #3',3,'App\\Models\\Cliente','{\"id\":3,\"nombre\":\"David aa\",\"cedula\":null,\"empresa\":null,\"cedula_juridica\":null,\"telefono\":null,\"email\":null,\"direccion\":null,\"ciudad\":null,\"pais\":null,\"clasificacion\":\"\",\"datos_fiscales\":null,\"credito_tienda\":\"0.00\",\"notas\":null,\"activo\":true,\"puntos_acumulados\":0,\"puntos_canjeados\":0,\"portal_activo\":false,\"origen\":null,\"lat\":null,\"lng\":null,\"total_compras\":\"0.00\",\"cliente_categoria_id\":null}',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/clientes/3',200,'2026-06-11 20:10:40'),(193,1,'updated','roles','Modificó Role #3',3,'App\\Models\\Role','{\"permisos\":[\"crm_editar_pipeline\",\"clientes\"]}','{\"permisos\":\"[\\\"crm_editar_pipeline\\\",\\\"clientes\\\",\\\"chats\\\",\\\"geo_business\\\",\\\"catalogo\\\"]\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/roles/3',200,'2026-06-11 23:11:03'),(194,1,'created','chats','Creó Chat #5',5,'App\\Models\\Chat',NULL,'{\"titulo\":\"Hola\",\"descripcion\":\"DDD\",\"creador_id\":1,\"estado\":\"abierto\",\"id\":5}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats',200,'2026-06-11 23:11:21'),(195,1,'created','chat_mensajes','Creó ChatMensaje #12',12,'App\\Models\\ChatMensaje',NULL,'{\"chat_id\":\"5\",\"usuario_id\":1,\"contenido\":\"Como estas\",\"id\":12,\"archivo_url_completa\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/5/mensajes',200,'2026-06-11 23:11:32'),(196,1,'created','chat_mensajes','Creó ChatMensaje #13',13,'App\\Models\\ChatMensaje',NULL,'{\"chat_id\":\"5\",\"usuario_id\":1,\"contenido\":\"\",\"archivo_url\":\"chat_adjuntos\\/cb28f88f-df5e-455d-b18d-6d20231992f1.jpg\",\"archivo_nombre\":\"SaveClip.App_660518487_18183044797379150_6705360117344007585_n.jpg\",\"archivo_tipo\":\"image\\/jpeg\",\"archivo_size\":120035,\"id\":13,\"archivo_url_completa\":\"http:\\/\\/127.0.0.1:8000\\/storage\\/chat_adjuntos\\/cb28f88f-df5e-455d-b18d-6d20231992f1.jpg\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/5/mensajes',200,'2026-06-11 23:12:02'),(197,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-11 23:32:26'),(198,1,'created','chat_mensajes','Creó ChatMensaje #14',14,'App\\Models\\ChatMensaje',NULL,'{\"chat_id\":\"5\",\"usuario_id\":1,\"contenido\":\"\",\"archivo_url\":\"chat_adjuntos\\/27ac97bd-fc6a-4fb8-93f5-1c3ec8950ef8.jpg\",\"archivo_nombre\":\"SaveClip.App_623547804_18099155842859258_4775479409922334502_n.jpg\",\"archivo_tipo\":\"image\\/jpeg\",\"archivo_size\":111635,\"id\":14,\"archivo_url_completa\":\"http:\\/\\/127.0.0.1:8000\\/storage\\/chat_adjuntos\\/27ac97bd-fc6a-4fb8-93f5-1c3ec8950ef8.jpg\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/5/mensajes',200,'2026-06-11 23:32:34'),(199,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-11 23:36:04'),(200,1,'created','chat_mensajes','Creó ChatMensaje #15',15,'App\\Models\\ChatMensaje',NULL,'{\"chat_id\":\"5\",\"usuario_id\":1,\"contenido\":\"\",\"archivo_url\":\"chat_adjuntos\\/61faa57d-8fbf-4ffe-a07f-b6040040acc3.webp\",\"archivo_nombre\":\"Ni-Cafe-Molido-1820-Arabica-400Gr-2-7746.webp\",\"archivo_tipo\":\"image\\/webp\",\"archivo_size\":295646,\"id\":15,\"archivo_url_completa\":\"http:\\/\\/127.0.0.1:8000\\/storage\\/chat_adjuntos\\/61faa57d-8fbf-4ffe-a07f-b6040040acc3.webp\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/5/mensajes',200,'2026-06-11 23:36:27'),(201,1,'updated','chats','Modificó Chat #5',5,'App\\Models\\Chat','{\"estado\":\"abierto\",\"cerrado_por\":null,\"cerrado_en\":null}','{\"estado\":\"cerrado\",\"cerrado_por\":1,\"cerrado_en\":\"2026-06-11T23:41:54.965427Z\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/5/cerrar',200,'2026-06-11 23:41:54'),(202,1,'created','chats','Creó Chat #6',6,'App\\Models\\Chat',NULL,'{\"titulo\":\"Reunion\",\"descripcion\":null,\"creador_id\":1,\"estado\":\"abierto\",\"id\":6}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats',200,'2026-06-12 04:14:57'),(203,1,'created','chat_mensajes','Creó ChatMensaje #16',16,'App\\Models\\ChatMensaje',NULL,'{\"chat_id\":\"6\",\"usuario_id\":1,\"contenido\":\"\",\"archivo_url\":\"chat_adjuntos\\/a11b8703-2369-4fd2-879a-d7a3c420f843.jpg\",\"archivo_nombre\":\"Categoria3.jpg\",\"archivo_tipo\":\"image\\/jpeg\",\"archivo_size\":314600,\"id\":16,\"archivo_url_completa\":\"http:\\/\\/127.0.0.1:8000\\/storage\\/chat_adjuntos\\/a11b8703-2369-4fd2-879a-d7a3c420f843.jpg\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/6/mensajes',200,'2026-06-12 04:15:11'),(204,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-15 16:10:44'),(205,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-15 16:10:48'),(206,1,'updated','productos','Modificó Producto #2',2,'App\\Models\\Producto','{\"codigo\":\"Botella1\"}','{\"codigo\":\"Botella Negra\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/productos/2',200,'2026-06-15 16:19:27'),(207,1,'updated','email_campaigns','Modificó EmailCampaign #2',2,'App\\Models\\EmailCampaign','{\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[{\\\"selectors\\\":[\\\"#ixwb\\\"],\\\"style\\\":{\\\"background-color\\\":\\\"#794e4e\\\"},\\\"wrapper\\\":1}],\\\"pages\\\":[],\\\"symbols\\\":[]}\"}','{\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[],\\\"pages\\\":[],\\\"symbols\\\":[]}\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/email-builder/campaigns/2',200,'2026-06-15 16:24:49'),(208,1,'created','chat_mensajes','Creó ChatMensaje #17',17,'App\\Models\\ChatMensaje',NULL,'{\"chat_id\":\"6\",\"usuario_id\":1,\"contenido\":\"Hola buenos dias, tenemos reunion hoy a las 10\",\"id\":17,\"archivo_url_completa\":null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/6/mensajes',200,'2026-06-15 16:33:50'),(209,1,'updated','chats','Modificó Chat #6',6,'App\\Models\\Chat','{\"estado\":\"abierto\",\"cerrado_por\":null,\"cerrado_en\":null}','{\"estado\":\"cerrado\",\"cerrado_por\":1,\"cerrado_en\":\"2026-06-15T16:35:07.717463Z\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats/6/cerrar',200,'2026-06-15 16:35:07'),(210,1,'created','notificaciones','Creó Notificacion #6',6,'App\\Models\\Notificacion',NULL,'{\"titulo\":\"Reunion\",\"mensaje\":\"Hoy reunion a las 10am\",\"color\":\"#ecf014\",\"icono\":\"fas fa-info-circle\",\"tipo\":\"informativa\",\"prioridad\":\"alta\",\"creador_id\":1,\"global\":true,\"enviada_en\":\"2026-06-15T16:37:16.000000Z\",\"id\":6}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones',200,'2026-06-15 16:37:16'),(211,1,'created','notificaciones','Creó Notificacion #7',7,'App\\Models\\Notificacion',NULL,'{\"titulo\":\"Reunion\",\"mensaje\":\"Hoy reunion a las 10am\",\"color\":\"#ecf014\",\"icono\":\"fas fa-info-circle\",\"tipo\":\"informativa\",\"prioridad\":\"alta\",\"creador_id\":1,\"global\":true,\"enviada_en\":\"2026-06-15T16:37:18.000000Z\",\"id\":7}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/notificaciones',200,'2026-06-15 16:37:18'),(212,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-15 16:42:59'),(213,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-15 16:43:07'),(214,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-29 18:53:17'),(215,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-06-29 18:53:23'),(216,1,'deleted','email_campaigns','Eliminó EmailCampaign #2',2,'App\\Models\\EmailCampaign','{\"id\":2,\"nombre\":\"Lol\",\"asunto\":\"xd\",\"html_content\":\"\",\"json_content\":\"{\\\"dataSources\\\":[],\\\"assets\\\":[],\\\"styles\\\":[],\\\"pages\\\":[],\\\"symbols\\\":[]}\",\"thumbnail\":null,\"estado\":\"borrador\",\"usuario_id\":1,\"programada_para\":null,\"enviada_en\":null,\"total_recipients\":0,\"total_enviados\":0,\"total_abiertos\":0,\"total_clicks\":0,\"total_rebotes\":0}',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/email-builder/campaigns/2',200,'2026-06-29 19:20:22'),(217,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-02 18:41:35'),(218,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-02 18:41:36'),(219,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 00:31:17'),(220,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 00:31:23'),(221,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 00:31:24'),(222,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 00:33:26'),(223,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 00:33:27'),(224,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 00:33:28'),(225,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 00:33:29'),(226,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 00:38:24'),(227,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 00:38:30'),(228,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 00:48:09'),(229,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 00:48:10'),(230,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 00:48:11'),(231,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 00:48:12'),(232,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 01:02:00'),(233,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 01:15:42'),(234,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 01:15:43'),(235,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"dark\"}','{\"theme_mode\":\"light\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 01:20:19'),(236,1,'updated','usuarios','Modificó User #1',1,'App\\Models\\User','{\"theme_mode\":\"light\"}','{\"theme_mode\":\"dark\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/auth/toggle-theme',200,'2026-07-04 01:20:27'),(237,1,'created','empleados','Creó Empleado #1',1,'App\\Models\\Empleado',NULL,'{\"nombre\":\"David\",\"cedula\":\"2987327942\",\"puesto\":\"Vendedor\",\"departamento\":null,\"salario_base\":\"360000.00\",\"fecha_ingreso\":\"2026-07-03T06:00:00.000000Z\",\"tipo_contrato\":\"indefinido\",\"cuenta_banco\":null,\"id\":1}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/planilla/empleados',200,'2026-07-04 02:32:57'),(238,1,'created','chats','Creó Chat #7',7,'App\\Models\\Chat',NULL,'{\"titulo\":\"das\",\"descripcion\":null,\"creador_id\":1,\"estado\":\"abierto\",\"id\":7}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/chats',200,'2026-07-04 02:43:38'),(239,1,'updated','clientes','Modificó Cliente #4',4,'App\\Models\\Cliente','{\"notas\":null}','{\"notas\":\"Hola\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/clientes/4',200,'2026-07-13 17:29:14'),(240,1,'updated','clientes','Modificó Cliente #4',4,'App\\Models\\Cliente','{\"notas\":\"Hola\"}','{\"notas\":\"Hola esta pendiente\"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/clientes/4',200,'2026-07-13 17:29:39'),(241,1,'created','cliente_notas','Creó ClienteNota #1',1,'App\\Models\\ClienteNota',NULL,'{\"cliente_id\":\"4\",\"usuario_id\":1,\"tipo\":\"nota\",\"contenido\":\"hola\",\"id\":1}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','http://127.0.0.1:8000/api/clientes/4/notas',200,'2026-07-13 17:40:30');
/*!40000 ALTER TABLE `auditoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` bigint(20) NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
INSERT INTO `cache` VALUES ('laravel-cache-5c785c036466adea360111aa28563bfd556b5fba','i:1;',1784049087),('laravel-cache-5c785c036466adea360111aa28563bfd556b5fba:timer','i:1784049087;',1784049087),('laravel-cache-idempotency::1781219370493-0xilhkqnc','s:19:\"2026-06-11 17:09:31\";',1781219401),('laravel-cache-idempotency::1781220691671-ql75a7mja','s:19:\"2026-06-11 17:31:32\";',1781220722),('laravel-cache-idempotency::1781220743379-ejsjx7w4o','s:19:\"2026-06-11 17:32:23\";',1781220773),('laravel-cache-idempotency::1781539840164-nwaiw8ndv','s:19:\"2026-06-15 10:10:41\";',1781539871),('laravel-cache-idempotency::1781541160070-rnqzmvyjn','s:19:\"2026-06-15 10:32:40\";',1781541190),('laravel-cache-idempotency::1781541448872-nksofvl4a','s:19:\"2026-06-15 10:37:29\";',1781541479),('laravel-cache-idempotency::1782756450007-p76hhc8d8','s:19:\"2026-06-29 12:07:31\";',1782756481),('laravel-cache-idempotency::1782756874249-hgdb3odvz','s:19:\"2026-06-29 12:14:34\";',1782756904),('laravel-cache-idempotency::1782759083696-6lib674vz','s:19:\"2026-06-29 12:51:25\";',1782759115),('laravel-cache-idempotency::1782769964273-fqpu48bla','s:19:\"2026-06-29 15:52:44\";',1782769994),('laravel-cache-idempotency::1782997187399-zm33f4she','s:19:\"2026-07-02 06:59:50\";',1782997220),('laravel-cache-idempotency::1783002350724-e53p4xu34','s:19:\"2026-07-02 08:25:51\";',1783002381),('laravel-cache-idempotency::1783005652656-2gfcw3692','s:19:\"2026-07-02 09:20:53\";',1783005683),('laravel-cache-idempotency::1783005662060-lshs26c8p','s:19:\"2026-07-02 09:21:02\";',1783005692),('laravel-cache-idempotency::1783006120227-w6b1brvqy','s:19:\"2026-07-02 09:28:40\";',1783006150),('laravel-cache-idempotency::1783006231149-iuc0z3tmr','s:19:\"2026-07-02 09:30:31\";',1783006261),('laravel-cache-idempotency::1783006423302-7lezi3frq','s:19:\"2026-07-02 09:33:43\";',1783006453),('laravel-cache-idempotency::1783006442315-iqnw7qnhc','s:19:\"2026-07-02 09:34:02\";',1783006472),('laravel-cache-idempotency::1783006507670-og4jpd0kb','s:19:\"2026-07-02 09:35:08\";',1783006538),('laravel-cache-idempotency::1783006526604-w24oc5yi3','s:19:\"2026-07-02 09:35:27\";',1783006557),('laravel-cache-idempotency::1783006818183-zxv1n2sli','s:19:\"2026-07-02 09:40:18\";',1783006823),('laravel-cache-idempotency::1783006821251-3htzhlplm','s:19:\"2026-07-02 09:40:21\";',1783006826),('laravel-cache-idempotency::1783006833476-oq5du4xpf','s:19:\"2026-07-02 09:40:33\";',1783006838),('laravel-cache-idempotency::1783010759284-t5lvuwna3','s:19:\"2026-07-02 10:45:59\";',1783010789),('laravel-cache-idempotency::1783010775137-izrt7242y','s:19:\"2026-07-02 10:46:15\";',1783010805),('laravel-cache-idempotency::1783010789518-i7dfdu9eb','s:19:\"2026-07-02 10:46:30\";',1783010820),('laravel-cache-idempotency::1783010983524-qzciu4gfw','s:19:\"2026-07-02 10:49:44\";',1783011014),('laravel-cache-idempotency::1783011241054-j7g1q006z','s:19:\"2026-07-02 10:54:01\";',1783011271),('laravel-cache-idempotency::1783017637751-sq13ci1bn','s:19:\"2026-07-02 12:40:51\";',1783017681),('laravel-cache-idempotency::1783017655689-xtababzta','s:19:\"2026-07-02 12:40:56\";',1783017686),('laravel-cache-idempotency::1783124222321-6hvnex6er','s:19:\"2026-07-03 18:17:05\";',1783124255),('laravel-cache-idempotency::1783124688401-fafdd041b','s:19:\"2026-07-03 18:24:48\";',1783124718),('laravel-cache-idempotency::1783125069190-pv4gbocpz','s:19:\"2026-07-03 18:31:09\";',1783125099),('laravel-cache-idempotency::1783125197052-vv8occ3uz','s:19:\"2026-07-03 18:33:17\";',1783125227),('laravel-cache-idempotency::1783125619849-q1igs8hnh','s:19:\"2026-07-03 18:40:20\";',1783125650),('laravel-cache-idempotency::1783126045751-0x30ovcbw','s:19:\"2026-07-03 18:47:26\";',1783126076),('laravel-cache-idempotency::1783126402972-89lubsm1b','s:19:\"2026-07-03 18:53:23\";',1783126433),('laravel-cache-idempotency::1783127008588-uac45owv9','s:19:\"2026-07-03 19:03:29\";',1783127039),('laravel-cache-idempotency::1783127632513-lgeega71a','s:19:\"2026-07-03 19:13:53\";',1783127663),('laravel-cache-idempotency::1783129100771-0gz5k65kn','s:19:\"2026-07-03 19:38:21\";',1783129131),('laravel-cache-idempotency::1783129465214-bku38yr8h','s:19:\"2026-07-03 19:44:25\";',1783129495),('laravel-cache-idempotency::1783129669229-d3gkjr6g4','s:19:\"2026-07-03 19:47:49\";',1783129674),('laravel-cache-idempotency::1783129697300-lv5ssfy01','s:19:\"2026-07-03 19:48:17\";',1783129702),('laravel-cache-idempotency::1783129699807-dj00cqcw5','s:19:\"2026-07-03 19:48:20\";',1783129705),('laravel-cache-idempotency::1783129873864-tyoew767y','s:19:\"2026-07-03 19:51:14\";',1783129879),('laravel-cache-idempotency::1783130020208-jkhf38qsv','s:19:\"2026-07-03 19:53:40\";',1783130050),('laravel-cache-idempotency::1783131416296-loo5uvrh2','s:19:\"2026-07-03 20:16:57\";',1783131447),('laravel-cache-idempotency::1783131596772-4ubbde0j6','s:19:\"2026-07-03 20:19:57\";',1783131627),('laravel-cache-idempotency::1783131620899-035cuqeci','s:19:\"2026-07-03 20:20:21\";',1783131651),('laravel-cache-idempotency::1783131636874-twqm8ojna','s:19:\"2026-07-03 20:20:37\";',1783131667),('laravel-cache-idempotency::1783131688299-ad8gzcnuv','s:19:\"2026-07-03 20:21:28\";',1783131718),('laravel-cache-idempotency::1783132240805-9how9kbuo','s:19:\"2026-07-03 20:30:41\";',1783132271),('laravel-cache-idempotency::1783132248363-ay6udql12','s:19:\"2026-07-03 20:30:48\";',1783132278),('laravel-cache-idempotency::1783132268124-gtdjev9kq','s:19:\"2026-07-03 20:31:08\";',1783132298),('laravel-cache-idempotency::1783132387060-28m1ma6kq','s:19:\"2026-07-03 20:33:07\";',1783132417),('laravel-cache-idempotency::1783132399884-ihwa6skn2','s:19:\"2026-07-03 20:33:20\";',1783132430),('laravel-cache-idempotency::1783132436999-se8f0gnm9','s:19:\"2026-07-03 20:33:57\";',1783132467),('laravel-cache-idempotency::1783132474428-w8fnfy16q','s:19:\"2026-07-03 20:34:34\";',1783132504),('laravel-cache-idempotency::1783132809653-qnfrc65k5','s:19:\"2026-07-03 20:40:10\";',1783132840),('laravel-cache-idempotency::1783132927804-ml3qiptts','s:19:\"2026-07-03 20:42:09\";',1783132959),('laravel-cache-idempotency::1783207493420-fzb7zhtwp','s:19:\"2026-07-04 17:25:02\";',1783207532),('laravel-cache-idempotency::1783207817489-a3iktnmva','s:19:\"2026-07-04 17:30:22\";',1783207852),('laravel-cache-idempotency::1783207822695-c1iesgef3','s:19:\"2026-07-04 17:30:24\";',1783207854),('laravel-cache-idempotency::1783230447576-v9cre4mvk','s:19:\"2026-07-04 23:47:29\";',1783230479),('laravel-cache-idempotency::1783963173707-rd0duv6x7','s:19:\"2026-07-13 11:19:36\";',1783963206),('laravel-cache-idempotency::1783963679285-b5lwan1ji','s:19:\"2026-07-13 11:27:59\";',1783963709),('laravel-cache-idempotency::1783963737019-mirtd7n1p','s:19:\"2026-07-13 11:28:57\";',1783963767),('laravel-cache-idempotency::1783963761180-fzhdpqbvi','s:19:\"2026-07-13 11:29:21\";',1783963791),('laravel-cache-idempotency::1783964400198-c7yatow9c','s:19:\"2026-07-13 11:40:00\";',1783964430),('laravel-cache-idempotency::1783965620911-1gfawxmcr','s:19:\"2026-07-13 12:00:21\";',1783965651),('laravel-cache-idempotency::1783965899665-zxwvuap5s','s:19:\"2026-07-13 12:05:00\";',1783965930),('laravel-cache-idempotency::1783968482983-l52c9t0ax','s:19:\"2026-07-13 12:48:03\";',1783968513),('laravel-cache-idempotency::1784049026933-5bjdfhd6y','s:19:\"2026-07-14 11:10:29\";',1784049059),('laravel-cache-idempotency:1:1780787372703-ibgr0n7sb','s:19:\"2026-06-06 17:09:33\";',1780787403),('laravel-cache-idempotency:1:1780788458116-efy7u6mmr','s:19:\"2026-06-06 17:27:38\";',1780788488),('laravel-cache-idempotency:1:1780788458664-42lgqlqc8','s:19:\"2026-06-06 17:27:39\";',1780788489),('laravel-cache-idempotency:1:1780788800167-3biw1269x','s:19:\"2026-06-06 17:33:21\";',1780788831),('laravel-cache-idempotency:1:1780789559231-akkbvsi3x','s:19:\"2026-06-06 17:46:00\";',1780789590),('laravel-cache-idempotency:1:1780789563483-pe64mzjd5','s:19:\"2026-06-06 17:46:04\";',1780789594),('laravel-cache-idempotency:1:1781202554019-zwumwr3uf','s:19:\"2026-06-11 12:29:14\";',1781202584),('laravel-cache-idempotency:1:1781202818282-vgbyma7j5','s:19:\"2026-06-11 12:33:38\";',1781202848),('laravel-cache-idempotency:1:1781202834749-l9p5duod5','s:19:\"2026-06-11 12:33:55\";',1781202865),('laravel-cache-idempotency:1:1781203077787-qfv181ih4','s:19:\"2026-06-11 12:37:58\";',1781203108),('laravel-cache-idempotency:1:1781203087691-2lr9ynhh8','s:19:\"2026-06-11 12:38:07\";',1781203117),('laravel-cache-idempotency:1:1781204076510-ml5g4k307','s:19:\"2026-06-11 12:54:36\";',1781204106),('laravel-cache-idempotency:1:1781204081860-uj8sxu4vv','s:19:\"2026-06-11 12:54:42\";',1781204112),('laravel-cache-idempotency:1:1781205193087-tkr1lysjw','s:19:\"2026-06-11 13:13:13\";',1781205223),('laravel-cache-idempotency:1:1781207256638-0jr8pffv0','s:19:\"2026-06-11 13:47:37\";',1781207287),('laravel-cache-idempotency:1:1781207257321-c5a9n3wm8','s:19:\"2026-06-11 13:47:37\";',1781207262),('laravel-cache-idempotency:1:1781207456327-v7gf066p8','s:19:\"2026-06-11 13:50:56\";',1781207486),('laravel-cache-idempotency:1:1781207477095-i08wv2a5i','s:19:\"2026-06-11 13:51:17\";',1781207507),('laravel-cache-idempotency:1:1781207486292-bbb9n7ify','s:19:\"2026-06-11 13:51:26\";',1781207516),('laravel-cache-idempotency:1:1781207865348-tfpa1alc3','s:19:\"2026-06-11 13:57:45\";',1781207895),('laravel-cache-idempotency:1:1781207909789-0k8daz8xo','s:19:\"2026-06-11 13:58:30\";',1781207915),('laravel-cache-idempotency:1:1781207928811-kq8td7kjw','s:19:\"2026-06-11 13:58:49\";',1781207959),('laravel-cache-idempotency:1:1781208322530-ne3sieivn','s:19:\"2026-06-11 14:05:22\";',1781208352),('laravel-cache-idempotency:1:1781208456186-d6ps8d5sa','s:19:\"2026-06-11 14:07:36\";',1781208486),('laravel-cache-idempotency:1:1781208569859-vp71pvmzk','s:19:\"2026-06-11 14:09:30\";',1781208600),('laravel-cache-idempotency:1:1781208615318-0u7t2hvk9','s:19:\"2026-06-11 14:10:15\";',1781208645),('laravel-cache-idempotency:1:1781208638037-aknyyi0am','s:19:\"2026-06-11 14:10:38\";',1781208668),('laravel-cache-idempotency:1:1781208640576-0qw6nv2h8','s:19:\"2026-06-11 14:10:40\";',1781208670),('laravel-cache-idempotency:1:1781209283114-1vd2m9u3l','s:19:\"2026-06-11 14:21:23\";',1781209313),('laravel-cache-idempotency:1:1781209294448-ufs19zhc7','s:19:\"2026-06-11 14:21:34\";',1781209324),('laravel-cache-idempotency:1:1781209296384-qstss4l2q','s:19:\"2026-06-11 14:21:36\";',1781209326),('laravel-cache-idempotency:1:1781209297696-pqq3yeneb','s:19:\"2026-06-11 14:21:38\";',1781209328),('laravel-cache-idempotency:1:1781209298546-rqfw7okt3','s:19:\"2026-06-11 14:21:38\";',1781209328),('laravel-cache-idempotency:1:1781209454596-xx6h1kuta','s:19:\"2026-06-11 14:24:14\";',1781209484),('laravel-cache-idempotency:1:1781209461089-217yn0mx7','s:19:\"2026-06-11 14:24:21\";',1781209491),('laravel-cache-idempotency:1:1781209664052-sbdo8rpyn','s:19:\"2026-06-11 14:27:45\";',1781209695),('laravel-cache-idempotency:1:1781209774965-xchhpuas7','s:19:\"2026-06-11 14:29:35\";',1781209805),('laravel-cache-idempotency:1:1781210119300-efnomqi4s','s:19:\"2026-06-11 14:35:21\";',1781210151),('laravel-cache-idempotency:1:1781210145403-519jkp576','s:19:\"2026-06-11 14:35:45\";',1781210150),('laravel-cache-idempotency:1:1781210629616-42ar75o78','s:19:\"2026-06-11 14:43:49\";',1781210659),('laravel-cache-idempotency:1:1781210639006-3fa99fkqo','s:19:\"2026-06-11 14:43:59\";',1781210644),('laravel-cache-idempotency:1:1781210811034-50q5j2yxt','s:19:\"2026-06-11 14:46:51\";',1781210841),('laravel-cache-idempotency:1:1781210827882-90byf5iqp','s:19:\"2026-06-11 14:47:08\";',1781210858),('laravel-cache-idempotency:1:1781211348118-lroqymem4','s:19:\"2026-06-11 14:55:48\";',1781211378),('laravel-cache-idempotency:1:1781211355966-xuxi5xnli','s:19:\"2026-06-11 14:55:56\";',1781211386),('laravel-cache-idempotency:1:1781213994958-19o3qa37h','s:19:\"2026-06-11 15:39:55\";',1781214025),('laravel-cache-idempotency:1:1781213997621-qwa9hnlgf','s:19:\"2026-06-11 15:39:57\";',1781214027),('laravel-cache-idempotency:1:1781214007862-750gdd91v','s:19:\"2026-06-11 15:40:08\";',1781214013),('laravel-cache-idempotency:1:1781214414094-6oj5t6jh1','s:19:\"2026-06-11 15:46:54\";',1781214444),('laravel-cache-idempotency:1:1781215338491-qp7u72vaa','s:19:\"2026-06-11 16:02:19\";',1781215369),('laravel-cache-idempotency:1:1781215351865-z8onh7udo','s:19:\"2026-06-11 16:02:32\";',1781215382),('laravel-cache-idempotency:1:1781215517722-gc8h0cbhz','s:19:\"2026-06-11 16:05:18\";',1781215548),('laravel-cache-idempotency:1:1781215518890-42erou2zl','s:19:\"2026-06-11 16:05:19\";',1781215549),('laravel-cache-idempotency:1:1781215519532-51fboxn7y','s:19:\"2026-06-11 16:05:19\";',1781215549),('laravel-cache-idempotency:1:1781219116027-2p8q48j03','s:19:\"2026-06-11 17:05:16\";',1781219146),('laravel-cache-idempotency:1:1781219337710-72kvvy9a0','s:19:\"2026-06-11 17:08:58\";',1781219368),('laravel-cache-idempotency:1:1781219341608-s7u7kzip2','s:19:\"2026-06-11 17:09:01\";',1781219371),('laravel-cache-idempotency:1:1781219354577-z7qf9b5b7','s:19:\"2026-06-11 17:09:14\";',1781219384),('laravel-cache-idempotency:1:1781219355628-sas18szph','s:19:\"2026-06-11 17:09:15\";',1781219385),('laravel-cache-idempotency:1:1781219357007-ztr8pm7d4','s:19:\"2026-06-11 17:09:17\";',1781219387),('laravel-cache-idempotency:1:1781219415388-7edkyx2a6','s:19:\"2026-06-11 17:10:15\";',1781219445),('laravel-cache-idempotency:1:1781219462730-z3o0agpd4','s:19:\"2026-06-11 17:11:03\";',1781219493),('laravel-cache-idempotency:1:1781219481288-bk6t8p2bx','s:19:\"2026-06-11 17:11:21\";',1781219511),('laravel-cache-idempotency:1:1781219488496-ctk82zpub','s:19:\"2026-06-11 17:11:28\";',1781219518),('laravel-cache-idempotency:1:1781219492149-93sg72i9d','s:19:\"2026-06-11 17:11:35\";',1781219525),('laravel-cache-idempotency:1:1781219508307-c50jpgx7p','s:19:\"2026-06-11 17:11:48\";',1781219538),('laravel-cache-idempotency:1:1781219520289-n3gevey8h','s:19:\"2026-06-11 17:12:04\";',1781219554),('laravel-cache-idempotency:1:1781220692233-mvh0746wk','s:19:\"2026-06-11 17:31:32\";',1781220722),('laravel-cache-idempotency:1:1781220693764-786vgq35p','s:19:\"2026-06-11 17:31:34\";',1781220724),('laravel-cache-idempotency:1:1781220725909-loi234v4g','s:19:\"2026-06-11 17:32:06\";',1781220756),('laravel-cache-idempotency:1:1781220730128-ohk7jpui','s:19:\"2026-06-11 17:32:10\";',1781220760),('laravel-cache-idempotency:1:1781220743881-k0easc4c2','s:19:\"2026-06-11 17:32:24\";',1781220774),('laravel-cache-idempotency:1:1781220745671-mx1e9e1st','s:19:\"2026-06-11 17:32:25\";',1781220775),('laravel-cache-idempotency:1:1781220746301-q9hh5ri76','s:19:\"2026-06-11 17:32:26\";',1781220776),('laravel-cache-idempotency:1:1781220748373-vh4a2gzfi','s:19:\"2026-06-11 17:32:28\";',1781220778),('laravel-cache-idempotency:1:1781220754574-mbwpy90pz','s:19:\"2026-06-11 17:32:37\";',1781220787),('laravel-cache-idempotency:1:1781220831843-o7yctr5tq','s:19:\"2026-06-11 17:33:53\";',1781220863),('laravel-cache-idempotency:1:1781220964650-v7907ek5n','s:19:\"2026-06-11 17:36:04\";',1781220994),('laravel-cache-idempotency:1:1781220967047-zrrn1x1pa','s:19:\"2026-06-11 17:36:07\";',1781220997),('laravel-cache-idempotency:1:1781220978047-jtb4zxdsp','s:19:\"2026-06-11 17:36:18\";',1781221008),('laravel-cache-idempotency:1:1781220979522-ukwbi9p5w','s:19:\"2026-06-11 17:36:20\";',1781221010),('laravel-cache-idempotency:1:1781220987062-lzvqsures','s:19:\"2026-06-11 17:36:29\";',1781221019),('laravel-cache-idempotency:1:1781221180247-pdb1todlf','s:19:\"2026-06-11 17:39:41\";',1781221211),('laravel-cache-idempotency:1:1781221181801-xytfv3pep','s:19:\"2026-06-11 17:39:43\";',1781221213),('laravel-cache-idempotency:1:1781221300007-0dvqi38p7','s:19:\"2026-06-11 17:41:40\";',1781221330),('laravel-cache-idempotency:1:1781221301741-sg8b7fxm7','s:19:\"2026-06-11 17:41:42\";',1781221332),('laravel-cache-idempotency:1:1781221314674-pguqdk24a','s:19:\"2026-06-11 17:41:54\";',1781221344),('laravel-cache-idempotency:1:1781237099531-1seuc1hiw','s:19:\"2026-06-11 22:04:59\";',1781237129),('laravel-cache-idempotency:1:1781237346607-7sxnlc1x9','s:19:\"2026-06-11 22:09:06\";',1781237376),('laravel-cache-idempotency:1:1781237697323-hspk4mo48','s:19:\"2026-06-11 22:14:57\";',1781237727),('laravel-cache-idempotency:1:1781237699540-0ldaoqx8f','s:19:\"2026-06-11 22:14:59\";',1781237729),('laravel-cache-idempotency:1:1781237711055-t4dd5zmze','s:19:\"2026-06-11 22:15:13\";',1781237743),('laravel-cache-idempotency:1:1781237833122-e7cpn0am2','s:19:\"2026-06-11 22:17:13\";',1781237863),('laravel-cache-idempotency:1:1781237927438-smpc8y0p4','s:19:\"2026-06-11 22:18:47\";',1781237957),('laravel-cache-idempotency:1:1781237931542-4ngk4s9d0','s:19:\"2026-06-11 22:18:51\";',1781237961),('laravel-cache-idempotency:1:1781237933557-nmpq1rrg1','s:19:\"2026-06-11 22:18:53\";',1781237963),('laravel-cache-idempotency:1:1781237936931-lxw3l9k32','s:19:\"2026-06-11 22:18:57\";',1781237967),('laravel-cache-idempotency:1:1781238168210-xyz425a4d','s:19:\"2026-06-11 22:22:48\";',1781238198),('laravel-cache-idempotency:1:1781238201682-c2qwhdyzc','s:19:\"2026-06-11 22:23:22\";',1781238232),('laravel-cache-idempotency:1:1781239375330-wq1f85kh2','s:19:\"2026-06-11 22:42:55\";',1781239405),('laravel-cache-idempotency:1:1781239746473-cseijitcu','s:19:\"2026-06-11 22:49:06\";',1781239776),('laravel-cache-idempotency:1:1781239753241-dz7txfohl','s:19:\"2026-06-11 22:49:13\";',1781239783),('laravel-cache-idempotency:1:1781239759787-f9efcp4va','s:19:\"2026-06-11 22:49:20\";',1781239790),('laravel-cache-idempotency:1:1781239759888-tdnpznzu2','s:19:\"2026-06-11 22:49:20\";',1781239790),('laravel-cache-idempotency:1:1781240019312-yfqc9i0tm','s:19:\"2026-06-11 22:53:39\";',1781240049),('laravel-cache-idempotency:1:1781240021711-3ghls9pe2','s:19:\"2026-06-11 22:53:42\";',1781240052),('laravel-cache-idempotency:1:1781240082193-6qowsg2rv','s:19:\"2026-06-11 22:54:42\";',1781240112),('laravel-cache-idempotency:1:1781240102202-ekjllqnnj','s:19:\"2026-06-11 22:55:02\";',1781240132),('laravel-cache-idempotency:1:1781240102982-nlbplftdy','s:19:\"2026-06-11 22:55:03\";',1781240133),('laravel-cache-idempotency:1:1781240159467-qajeooe4u','s:19:\"2026-06-11 22:56:00\";',1781240190),('laravel-cache-idempotency:1:1781240286902-88rx683jr','s:19:\"2026-06-11 22:58:07\";',1781240317),('laravel-cache-idempotency:1:1781539829036-g7z8buvjp','s:19:\"2026-06-15 10:10:30\";',1781539860),('laravel-cache-idempotency:1:1781539830002-4vm8n7aeq','s:19:\"2026-06-15 10:10:31\";',1781539836),('laravel-cache-idempotency:1:1781539830003-o0xkpdg01','s:19:\"2026-06-15 10:10:31\";',1781539861),('laravel-cache-idempotency:1:1781539841839-6oi6pf3mp','s:19:\"2026-06-15 10:10:42\";',1781539872),('laravel-cache-idempotency:1:1781539843665-djhspqpuw','s:19:\"2026-06-15 10:10:44\";',1781539874),('laravel-cache-idempotency:1:1781539843725-3hg5sh4m1','s:19:\"2026-06-15 10:10:44\";',1781539874),('laravel-cache-idempotency:1:1781539848458-juq0mht0i','s:19:\"2026-06-15 10:10:48\";',1781539878),('laravel-cache-idempotency:1:1781539933805-t73gzztzi','s:19:\"2026-06-15 10:12:14\";',1781539964),('laravel-cache-idempotency:1:1781540035322-pqhwe9qmy','s:19:\"2026-06-15 10:13:55\";',1781540065),('laravel-cache-idempotency:1:1781540048234-5p2y85doh','s:19:\"2026-06-15 10:14:08\";',1781540078),('laravel-cache-idempotency:1:1781540245815-meaxmwor9','s:19:\"2026-06-15 10:17:26\";',1781540276),('laravel-cache-idempotency:1:1781540366653-p542vsdwf','s:19:\"2026-06-15 10:19:27\";',1781540397),('laravel-cache-idempotency:1:1781540422899-l2cs7qhfh','s:19:\"2026-06-15 10:20:23\";',1781540453),('laravel-cache-idempotency:1:1781540489124-s0n4cj0gd','s:19:\"2026-06-15 10:21:29\";',1781540519),('laravel-cache-idempotency:1:1781540553670-acekqyir9','s:19:\"2026-06-15 10:22:34\";',1781540584),('laravel-cache-idempotency:1:1781540556429-f1uacs5ih','s:19:\"2026-06-15 10:22:36\";',1781540586),('laravel-cache-idempotency:1:1781540677167-vuqj8ry12','s:19:\"2026-06-15 10:24:38\";',1781540708),('laravel-cache-idempotency:1:1781540689374-rgd5xi1mi','s:19:\"2026-06-15 10:24:49\";',1781540719),('laravel-cache-idempotency:1:1781541207998-gab2bpydx','s:19:\"2026-06-15 10:33:30\";',1781541240),('laravel-cache-idempotency:1:1781541208441-acojn1m29','s:19:\"2026-06-15 10:33:30\";',1781541240),('laravel-cache-idempotency:1:1781541230081-v9e3tjnic','s:19:\"2026-06-15 10:33:53\";',1781541263),('laravel-cache-idempotency:1:1781541307387-ihkavtl7r','s:19:\"2026-06-15 10:35:07\";',1781541337),('laravel-cache-idempotency:1:1781541436093-n4ifatgc3','s:19:\"2026-06-15 10:37:17\";',1781541467),('laravel-cache-idempotency:1:1781541437590-g21qa8dwj','s:19:\"2026-06-15 10:37:18\";',1781541468),('laravel-cache-idempotency:1:1781541467964-rvdugftuq','s:19:\"2026-06-15 10:37:48\";',1781541498),('laravel-cache-idempotency:1:1781541470076-sronw9e4r','s:19:\"2026-06-15 10:37:50\";',1781541500),('laravel-cache-idempotency:1:1781541662543-99dp5p3oy','s:19:\"2026-06-15 10:41:02\";',1781541692),('laravel-cache-idempotency:1:1781541665987-kwg9d5kmb','s:19:\"2026-06-15 10:41:06\";',1781541696),('laravel-cache-idempotency:1:1781541778717-adn7ckb9r','s:19:\"2026-06-15 10:42:59\";',1781541809),('laravel-cache-idempotency:1:1781541787041-0v5yagers','s:19:\"2026-06-15 10:43:07\";',1781541817),('laravel-cache-idempotency:1:1781542486500-latmxjjyk','s:19:\"2026-06-15 10:54:46\";',1781542516),('laravel-cache-idempotency:1:1781542555345-6heypv97x','s:19:\"2026-06-15 10:55:55\";',1781542585),('laravel-cache-idempotency:1:1781542557397-c1rzm5jhc','s:19:\"2026-06-15 10:55:57\";',1781542587),('laravel-cache-idempotency:1:1781542610137-tf22zjhwt','s:19:\"2026-06-15 10:56:50\";',1781542640),('laravel-cache-idempotency:1:1781542644742-wpga08gqk','s:19:\"2026-06-15 10:57:25\";',1781542675),('laravel-cache-idempotency:1:1781542664298-72nk9gwww','s:19:\"2026-06-15 10:57:44\";',1781542694),('laravel-cache-idempotency:1:1781561113277-n1omboqu8','s:19:\"2026-06-15 16:05:13\";',1781561143),('laravel-cache-idempotency:1:1781569567167-drc7s2e0a','s:19:\"2026-06-15 18:26:08\";',1781569598),('laravel-cache-idempotency:1:1782756434267-6t3utvdyo','s:19:\"2026-06-29 12:07:14\";',1782756464),('laravel-cache-idempotency:1:1782756647159-uoiiqv8gu','s:19:\"2026-06-29 12:10:47\";',1782756677),('laravel-cache-idempotency:1:1782756874768-ebr6mz2a6','s:19:\"2026-06-29 12:14:35\";',1782756905),('laravel-cache-idempotency:1:1782756876290-w743pf4z1','s:19:\"2026-06-29 12:14:36\";',1782756906),('laravel-cache-idempotency:1:1782757041504-per5u6r0t','s:19:\"2026-06-29 12:17:22\";',1782757072),('laravel-cache-idempotency:1:1782757060615-2ezsm1mno','s:19:\"2026-06-29 12:17:41\";',1782757091),('laravel-cache-idempotency:1:1782757342036-pjv5t1j42','s:19:\"2026-06-29 12:22:23\";',1782757373),('laravel-cache-idempotency:1:1782757350765-4sj2tivey','s:19:\"2026-06-29 12:22:32\";',1782757382),('laravel-cache-idempotency:1:1782758955176-ba04ep7hb','s:19:\"2026-06-29 12:49:15\";',1782758985),('laravel-cache-idempotency:1:1782759019341-qes9wvfzt','s:19:\"2026-06-29 12:50:19\";',1782759049),('laravel-cache-idempotency:1:1782759019652-va39r6wy3','s:19:\"2026-06-29 12:50:19\";',1782759049),('laravel-cache-idempotency:1:1782759085078-a7rgru3fc','s:19:\"2026-06-29 12:51:25\";',1782759115),('laravel-cache-idempotency:1:1782759087060-eqfal8ldr','s:19:\"2026-06-29 12:51:27\";',1782759117),('laravel-cache-idempotency:1:1782759175359-sa0t0b5y7','s:19:\"2026-06-29 12:52:55\";',1782759205),('laravel-cache-idempotency:1:1782759191420-o1m7zu0s4','s:19:\"2026-06-29 12:53:11\";',1782759221),('laravel-cache-idempotency:1:1782759196868-lui1gzgga','s:19:\"2026-06-29 12:53:17\";',1782759227),('laravel-cache-idempotency:1:1782759202691-yzvm7fkax','s:19:\"2026-06-29 12:53:23\";',1782759233),('laravel-cache-idempotency:1:1782759304388-0hvr0bqox','s:19:\"2026-06-29 12:55:04\";',1782759334),('laravel-cache-idempotency:1:1782759352028-clmgvxewq','s:19:\"2026-06-29 12:55:52\";',1782759382),('laravel-cache-idempotency:1:1782760250253-nr4xkd9p2','s:19:\"2026-06-29 13:10:50\";',1782760280),('laravel-cache-idempotency:1:1782760251125-g0irlcfwe','s:19:\"2026-06-29 13:10:51\";',1782760281),('laravel-cache-idempotency:1:1782760252217-9civ79nmg','s:19:\"2026-06-29 13:10:52\";',1782760282),('laravel-cache-idempotency:1:1782760268959-454zt5im4','s:19:\"2026-06-29 13:11:09\";',1782760299),('laravel-cache-idempotency:1:1782760492371-gp96hql0r','s:19:\"2026-06-29 13:14:53\";',1782760523),('laravel-cache-idempotency:1:1782760497042-nbk0k9epr','s:19:\"2026-06-29 13:14:57\";',1782760527),('laravel-cache-idempotency:1:1782760502306-kg5pqntga','s:19:\"2026-06-29 13:15:03\";',1782760533),('laravel-cache-idempotency:1:1782760822363-1khrjw6le','s:19:\"2026-06-29 13:20:22\";',1782760852),('laravel-cache-idempotency:1:1782761283257-2poh9pxce','s:19:\"2026-06-29 13:28:03\";',1782761313),('laravel-cache-idempotency:1:1782762659753-hfk1r4avi','s:19:\"2026-06-29 13:51:00\";',1782762690),('laravel-cache-idempotency:1:1782763079251-h1bdbwf1l','s:19:\"2026-06-29 13:57:59\";',1782763109),('laravel-cache-idempotency:1:1782763135239-5qausrj5d','s:19:\"2026-06-29 13:58:56\";',1782763141),('laravel-cache-idempotency:1:1782763143795-zxqfss7ue','s:19:\"2026-06-29 13:59:06\";',1782763151),('laravel-cache-idempotency:1:1782763182492-uzns6vgko','s:19:\"2026-06-29 13:59:42\";',1782763187),('laravel-cache-idempotency:1:1782763227067-7l59928mn','s:19:\"2026-06-29 14:00:27\";',1782763232),('laravel-cache-idempotency:1:1782764245467-wkowmpp36','s:19:\"2026-06-29 14:17:25\";',1782764275),('laravel-cache-idempotency:1:1782769926547-pzdz4rkf0','s:19:\"2026-06-29 15:52:06\";',1782769956),('laravel-cache-idempotency:1:1782769959596-b141137vs','s:19:\"2026-06-29 15:52:39\";',1782769989),('laravel-cache-idempotency:1:1782769959921-zqvqfqnyn','s:19:\"2026-06-29 15:52:40\";',1782769990),('laravel-cache-idempotency:1:1782769964945-p6igd22x2','s:19:\"2026-06-29 15:52:45\";',1782769995),('laravel-cache-idempotency:1:1782769966572-i85xh9hrv','s:19:\"2026-06-29 15:52:46\";',1782769996),('laravel-cache-idempotency:1:1782769983114-u8sb3irz7','s:19:\"2026-06-29 15:53:03\";',1782770013),('laravel-cache-idempotency:1:1782769989692-3qsgo6wwi','s:19:\"2026-06-29 15:53:10\";',1782770020),('laravel-cache-idempotency:1:1782770032303-fd7f3o32s','s:19:\"2026-06-29 15:53:52\";',1782770062),('laravel-cache-idempotency:1:1782770139772-3vuglgdre','s:19:\"2026-06-29 15:55:40\";',1782770170),('laravel-cache-idempotency:1:1782770270960-xsv5bb8qb','s:19:\"2026-06-29 15:57:52\";',1782770302),('laravel-cache-idempotency:1:1782771005772-mqx7g30hl','s:19:\"2026-06-29 16:10:06\";',1782771036),('laravel-cache-idempotency:1:1782771792263-u8nztjflg','s:19:\"2026-06-29 16:23:12\";',1782771822),('laravel-cache-idempotency:1:1782772072616-a1lo6vtwt','s:19:\"2026-06-29 16:27:53\";',1782772103),('laravel-cache-idempotency:1:1782852776934-ian3o40kj','s:19:\"2026-06-30 14:52:57\";',1782852807),('laravel-cache-idempotency:1:1782997215438-0gtgb8dtp','s:19:\"2026-07-02 07:00:15\";',1782997245),('laravel-cache-idempotency:1:1782997820641-uclrjik62','s:19:\"2026-07-02 07:10:20\";',1782997850),('laravel-cache-idempotency:1:1782998293675-li2uf3nv3','s:19:\"2026-07-02 07:18:13\";',1782998323),('laravel-cache-idempotency:1:1783002326123-kr2a70abw','s:19:\"2026-07-02 08:25:26\";',1783002356),('laravel-cache-idempotency:1:1783002331430-zfljtvype','s:19:\"2026-07-02 08:25:31\";',1783002361),('laravel-cache-idempotency:1:1783002341034-1tk24ydx1','s:19:\"2026-07-02 08:25:41\";',1783002371),('laravel-cache-idempotency:1:1783002347974-nrvp805sa','s:19:\"2026-07-02 08:25:48\";',1783002378),('laravel-cache-idempotency:1:1783002348270-8fn9h18mx','s:19:\"2026-07-02 08:25:48\";',1783002378),('laravel-cache-idempotency:1:1783002351270-wvo625sqt','s:19:\"2026-07-02 08:25:51\";',1783002381),('laravel-cache-idempotency:1:1783002352752-4pf72jo4s','s:19:\"2026-07-02 08:25:53\";',1783002383),('laravel-cache-idempotency:1:1783002358170-rai4wz0xu','s:19:\"2026-07-02 08:25:58\";',1783002388),('laravel-cache-idempotency:1:1783002490027-qrjvla5id','s:19:\"2026-07-02 08:28:10\";',1783002520),('laravel-cache-idempotency:1:1783005653281-podhvb67g','s:19:\"2026-07-02 09:20:53\";',1783005683),('laravel-cache-idempotency:1:1783005655338-ix9mr1bs3','s:19:\"2026-07-02 09:20:55\";',1783005685),('laravel-cache-idempotency:1:1783005662581-iu2cyyona','s:19:\"2026-07-02 09:21:02\";',1783005692),('laravel-cache-idempotency:1:1783005664358-lhqq8je95','s:19:\"2026-07-02 09:21:04\";',1783005694),('laravel-cache-idempotency:1:1783006120781-qeu1rtv7p','s:19:\"2026-07-02 09:28:41\";',1783006151),('laravel-cache-idempotency:1:1783006122623-kmnaam1v4','s:19:\"2026-07-02 09:28:42\";',1783006152),('laravel-cache-idempotency:1:1783006423901-dcoynezd0','s:19:\"2026-07-02 09:33:44\";',1783006454),('laravel-cache-idempotency:1:1783006425785-f1o8tozuy','s:19:\"2026-07-02 09:33:46\";',1783006456),('laravel-cache-idempotency:1:1783006454201-zxexm1gbm','s:19:\"2026-07-02 09:34:14\";',1783006484),('laravel-cache-idempotency:1:1783006508203-u2rufgvgp','s:19:\"2026-07-02 09:35:08\";',1783006538),('laravel-cache-idempotency:1:1783006510118-u6zw4rroc','s:19:\"2026-07-02 09:35:10\";',1783006540),('laravel-cache-idempotency:1:1783006538544-vh9aw5sv1','s:19:\"2026-07-02 09:35:38\";',1783006568),('laravel-cache-idempotency:1:1783010759947-wmqr6v5so','s:19:\"2026-07-02 10:46:00\";',1783010790),('laravel-cache-idempotency:1:1783010761695-bjbrnegny','s:19:\"2026-07-02 10:46:01\";',1783010791),('laravel-cache-idempotency:1:1783010775651-cxpl8im5t','s:19:\"2026-07-02 10:46:15\";',1783010805),('laravel-cache-idempotency:1:1783010777384-fgt8occni','s:19:\"2026-07-02 10:46:17\";',1783010807),('laravel-cache-idempotency:1:1783010805940-ind0wu7ci','s:19:\"2026-07-02 10:46:46\";',1783010836),('laravel-cache-idempotency:1:1783010984068-llccuw6ay','s:19:\"2026-07-02 10:49:44\";',1783011014),('laravel-cache-idempotency:1:1783010986035-g3nmfk5n3','s:19:\"2026-07-02 10:49:46\";',1783011016),('laravel-cache-idempotency:1:1783011108617-9z7ls35vw','s:19:\"2026-07-02 10:51:48\";',1783011138),('laravel-cache-idempotency:1:1783011241593-tjo1a0bpg','s:19:\"2026-07-02 10:54:01\";',1783011271),('laravel-cache-idempotency:1:1783011243411-drwjczeb8','s:19:\"2026-07-02 10:54:03\";',1783011273),('laravel-cache-idempotency:1:1783011296719-n8g7artzd','s:19:\"2026-07-02 10:54:56\";',1783011326),('laravel-cache-idempotency:1:1783011302539-npojs1lct','s:19:\"2026-07-02 10:55:02\";',1783011332),('laravel-cache-idempotency:1:1783011307933-150g07ib3','s:19:\"2026-07-02 10:55:08\";',1783011338),('laravel-cache-idempotency:1:1783011451897-duyjcnv54','s:19:\"2026-07-02 10:57:32\";',1783011482),('laravel-cache-idempotency:1:1783011677536-z4swh3p7m','s:19:\"2026-07-02 11:01:17\";',1783011707),('laravel-cache-idempotency:1:1783011901894-4hjm8be0g','s:19:\"2026-07-02 11:05:02\";',1783011932),('laravel-cache-idempotency:1:1783017651684-kvdpfowv8','s:19:\"2026-07-02 12:40:53\";',1783017683),('laravel-cache-idempotency:1:1783017656236-yuexv4gzn','s:19:\"2026-07-02 12:40:56\";',1783017686),('laravel-cache-idempotency:1:1783017658669-g0qtiur6s','s:19:\"2026-07-02 12:40:58\";',1783017688),('laravel-cache-idempotency:1:1783017686557-gobfwfx6j','s:19:\"2026-07-02 12:41:26\";',1783017716),('laravel-cache-idempotency:1:1783017695603-1n6kbf03t','s:19:\"2026-07-02 12:41:35\";',1783017725),('laravel-cache-idempotency:1:1783017696489-giw376hty','s:19:\"2026-07-02 12:41:36\";',1783017726),('laravel-cache-idempotency:1:1783018378803-f3gseg5oy','s:19:\"2026-07-02 12:52:59\";',1783018409),('laravel-cache-idempotency:1:1783018576113-nurfw4v6s','s:19:\"2026-07-02 12:56:16\";',1783018606),('laravel-cache-idempotency:1:1783019474943-8qk0zv4f2','s:19:\"2026-07-02 13:11:15\";',1783019505),('laravel-cache-idempotency:1:1783020042051-swwg656kj','s:19:\"2026-07-02 13:20:42\";',1783020072),('laravel-cache-idempotency:1:1783020836524-328hf8qmf','s:19:\"2026-07-02 13:33:56\";',1783020866),('laravel-cache-idempotency:1:1783124225255-pvejxiz6x','s:19:\"2026-07-03 18:17:05\";',1783124255),('laravel-cache-idempotency:1:1783124227727-sz6pzyasd','s:19:\"2026-07-03 18:17:08\";',1783124258),('laravel-cache-idempotency:1:1783124255653-qtqlj6kyl','s:19:\"2026-07-03 18:17:35\";',1783124285),('laravel-cache-idempotency:1:1783124314009-qg8aeqyu6','s:19:\"2026-07-03 18:18:34\";',1783124344),('laravel-cache-idempotency:1:1783124315651-3gpcjwpl1','s:19:\"2026-07-03 18:18:35\";',1783124345),('laravel-cache-idempotency:1:1783124316253-vwxxgw8a0','s:19:\"2026-07-03 18:18:36\";',1783124346),('laravel-cache-idempotency:1:1783124688978-30v0dws1w','s:19:\"2026-07-03 18:24:49\";',1783124719),('laravel-cache-idempotency:1:1783124691011-ni2vmdq01','s:19:\"2026-07-03 18:24:51\";',1783124721),('laravel-cache-idempotency:1:1783124719264-t0kwizcum','s:19:\"2026-07-03 18:25:19\";',1783124749),('laravel-cache-idempotency:1:1783124749776-70u9uo90t','s:19:\"2026-07-03 18:25:50\";',1783124780),('laravel-cache-idempotency:1:1783125063418-cjqc3d3o2','s:19:\"2026-07-03 18:31:03\";',1783125093),('laravel-cache-idempotency:1:1783125069722-yd6368i8s','s:19:\"2026-07-03 18:31:10\";',1783125100),('laravel-cache-idempotency:1:1783125071798-utwfimo8a','s:19:\"2026-07-03 18:31:12\";',1783125102),('laravel-cache-idempotency:1:1783125076980-28je4nlst','s:19:\"2026-07-03 18:31:17\";',1783125107),('laravel-cache-idempotency:1:1783125082856-uwi24nl3h','s:19:\"2026-07-03 18:31:23\";',1783125113),('laravel-cache-idempotency:1:1783125083912-t2a5elqsb','s:19:\"2026-07-03 18:31:24\";',1783125114),('laravel-cache-idempotency:1:1783125100013-odo1ssfle','s:19:\"2026-07-03 18:31:40\";',1783125130),('laravel-cache-idempotency:1:1783125190015-hwyk8sv35','s:19:\"2026-07-03 18:33:10\";',1783125220),('laravel-cache-idempotency:1:1783125197572-t3tbzlv3l','s:19:\"2026-07-03 18:33:17\";',1783125227),('laravel-cache-idempotency:1:1783125199828-ux6422xi7','s:19:\"2026-07-03 18:33:20\";',1783125230),('laravel-cache-idempotency:1:1783125206094-hnldpxux2','s:19:\"2026-07-03 18:33:26\";',1783125236),('laravel-cache-idempotency:1:1783125206915-4cxrh2rf6','s:19:\"2026-07-03 18:33:27\";',1783125237),('laravel-cache-idempotency:1:1783125207714-cto2le6m2','s:19:\"2026-07-03 18:33:28\";',1783125238),('laravel-cache-idempotency:1:1783125209036-l2jkbehnf','s:19:\"2026-07-03 18:33:29\";',1783125239),('laravel-cache-idempotency:1:1783125227863-fehc0700m','s:19:\"2026-07-03 18:33:48\";',1783125258),('laravel-cache-idempotency:1:1783125497863-abt480ulv','s:19:\"2026-07-03 18:38:18\";',1783125528),('laravel-cache-idempotency:1:1783125504069-9fgsgoy1u','s:19:\"2026-07-03 18:38:24\";',1783125534),('laravel-cache-idempotency:1:1783125509792-ako5o2awh','s:19:\"2026-07-03 18:38:30\";',1783125540),('laravel-cache-idempotency:1:1783125527863-t8r3f52n2','s:19:\"2026-07-03 18:38:48\";',1783125558),('laravel-cache-idempotency:1:1783125620425-ozan6udjc','s:19:\"2026-07-03 18:40:20\";',1783125650),('laravel-cache-idempotency:1:1783125622704-zqe1h2a6g','s:19:\"2026-07-03 18:40:22\";',1783125652),('laravel-cache-idempotency:1:1783125650750-zsbcnmnm2','s:19:\"2026-07-03 18:40:51\";',1783125681),('laravel-cache-idempotency:1:1783125680744-eihjeo3ly','s:19:\"2026-07-03 18:41:21\";',1783125711),('laravel-cache-idempotency:1:1783125860747-whi45qulj','s:19:\"2026-07-03 18:44:21\";',1783125891),('laravel-cache-idempotency:1:1783125920745-uz0emvul6','s:19:\"2026-07-03 18:45:21\";',1783125951),('laravel-cache-idempotency:1:1783125980749-o65pjknj1','s:19:\"2026-07-03 18:46:21\";',1783126011),('laravel-cache-idempotency:1:1783126010749-scmkl4aka','s:19:\"2026-07-03 18:46:51\";',1783126041),('laravel-cache-idempotency:1:1783126046411-w8d8o3wix','s:19:\"2026-07-03 18:47:26\";',1783126076),('laravel-cache-idempotency:1:1783126048584-gp77twfo9','s:19:\"2026-07-03 18:47:28\";',1783126078),('laravel-cache-idempotency:1:1783126076728-yctb46tk2','s:19:\"2026-07-03 18:47:57\";',1783126107),('laravel-cache-idempotency:1:1783126089037-7dinc8c1t','s:19:\"2026-07-03 18:48:09\";',1783126119),('laravel-cache-idempotency:1:1783126090161-h3yqx5t47','s:19:\"2026-07-03 18:48:10\";',1783126120),('laravel-cache-idempotency:1:1783126091255-4w0i8qa8w','s:19:\"2026-07-03 18:48:11\";',1783126121),('laravel-cache-idempotency:1:1783126092335-rnhxjui1q','s:19:\"2026-07-03 18:48:12\";',1783126122),('laravel-cache-idempotency:1:1783126106727-f5jhbsrsc','s:19:\"2026-07-03 18:48:27\";',1783126137),('laravel-cache-idempotency:1:1783126136728-o04satpoa','s:19:\"2026-07-03 18:48:57\";',1783126167),('laravel-cache-idempotency:1:1783126166728-r1culmbzr','s:19:\"2026-07-03 18:49:27\";',1783126197),('laravel-cache-idempotency:1:1783126196727-pvtuhkux0','s:19:\"2026-07-03 18:49:57\";',1783126227),('laravel-cache-idempotency:1:1783126226731-y4mu9yyr0','s:19:\"2026-07-03 18:50:27\";',1783126257),('laravel-cache-idempotency:1:1783126376731-ax8vs55t3','s:19:\"2026-07-03 18:52:57\";',1783126407),('laravel-cache-idempotency:1:1783126403528-1fssz2tw0','s:19:\"2026-07-03 18:53:23\";',1783126433),('laravel-cache-idempotency:1:1783126405716-3ndaxfuj4','s:19:\"2026-07-03 18:53:26\";',1783126436),('laravel-cache-idempotency:1:1783126463842-grxghhvj4','s:19:\"2026-07-03 18:54:24\";',1783126494),('laravel-cache-idempotency:1:1783126493837-sobvhdryt','s:19:\"2026-07-03 18:54:54\";',1783126524),('laravel-cache-idempotency:1:1783126724058-47aja5w8p','s:19:\"2026-07-03 18:58:44\";',1783126754),('laravel-cache-idempotency:1:1783126780342-sxy60dgsj','s:19:\"2026-07-03 18:59:40\";',1783126810),('laravel-cache-idempotency:1:1783126793842-d2r0v6vnt','s:19:\"2026-07-03 18:59:54\";',1783126824),('laravel-cache-idempotency:1:1783126823836-9ooglnqoq','s:19:\"2026-07-03 19:00:24\";',1783126854),('laravel-cache-idempotency:1:1783126844050-mlgqquipy','s:19:\"2026-07-03 19:00:44\";',1783126874),('laravel-cache-idempotency:1:1783126853842-zctwajejo','s:19:\"2026-07-03 19:00:54\";',1783126884),('laravel-cache-idempotency:1:1783126862046-086lnc8px','s:19:\"2026-07-03 19:01:02\";',1783126892),('laravel-cache-idempotency:1:1783126883505-8a2f3y5um','s:19:\"2026-07-03 19:01:23\";',1783126913),('laravel-cache-idempotency:1:1783126883836-s9xr5tbom','s:19:\"2026-07-03 19:01:24\";',1783126914),('laravel-cache-idempotency:1:1783126920620-o35i54pq9','s:19:\"2026-07-03 19:02:00\";',1783126950),('laravel-cache-idempotency:1:1783126943838-77xeud1f2','s:19:\"2026-07-03 19:02:24\";',1783126974),('laravel-cache-idempotency:1:1783127003840-jebpmcj8w','s:19:\"2026-07-03 19:03:24\";',1783127034),('laravel-cache-idempotency:1:1783127009179-ltds3eisr','s:19:\"2026-07-03 19:03:29\";',1783127039),('laravel-cache-idempotency:1:1783127011494-vs6exbhwx','s:19:\"2026-07-03 19:03:31\";',1783127041),('laravel-cache-idempotency:1:1783127039471-mvy0uhfj6','s:19:\"2026-07-03 19:03:59\";',1783127069),('laravel-cache-idempotency:1:1783127069399-run7ti2p4','s:19:\"2026-07-03 19:04:29\";',1783127099),('laravel-cache-idempotency:1:1783127069471-gp2ysxnr5','s:19:\"2026-07-03 19:04:30\";',1783127100),('laravel-cache-idempotency:1:1783127085804-kcr09hwv9','s:19:\"2026-07-03 19:04:50\";',1783127120),('laravel-cache-idempotency:1:1783127099470-6ii8d88t2','s:19:\"2026-07-03 19:04:59\";',1783127129),('laravel-cache-idempotency:1:1783127471814-gy5lwesje','s:19:\"2026-07-03 19:11:12\";',1783127502),('laravel-cache-idempotency:1:1783127633099-3gps14to4','s:19:\"2026-07-03 19:13:53\";',1783127663),('laravel-cache-idempotency:1:1783127635057-osudsylqw','s:19:\"2026-07-03 19:13:55\";',1783127665),('laravel-cache-idempotency:1:1783127742324-6uqbn7ydk','s:19:\"2026-07-03 19:15:42\";',1783127772),('laravel-cache-idempotency:1:1783127743540-1pv0d8c3a','s:19:\"2026-07-03 19:15:43\";',1783127773),('laravel-cache-idempotency:1:1783127753384-14f0238bp','s:19:\"2026-07-03 19:15:53\";',1783127783),('laravel-cache-idempotency:1:1783127992044-e60d3veta','s:19:\"2026-07-03 19:19:52\";',1783128022),('laravel-cache-idempotency:1:1783128019717-8l8can3vc','s:19:\"2026-07-03 19:20:19\";',1783128049),('laravel-cache-idempotency:1:1783128023390-t8pfmegh4','s:19:\"2026-07-03 19:20:23\";',1783128053),('laravel-cache-idempotency:1:1783128027526-eqopmlye7','s:19:\"2026-07-03 19:20:27\";',1783128057),('laravel-cache-idempotency:1:1783128138314-c6yf1svi2','s:19:\"2026-07-03 19:22:18\";',1783128168),('laravel-cache-idempotency:1:1783128173385-ci8bd1zvy','s:19:\"2026-07-03 19:22:53\";',1783128203),('laravel-cache-idempotency:1:1783128203386-xssk2ur5s','s:19:\"2026-07-03 19:23:23\";',1783128233),('laravel-cache-idempotency:1:1783129073637-hex6ms656','s:19:\"2026-07-03 19:37:53\";',1783129103),('laravel-cache-idempotency:1:1783129101310-1p15cvoy8','s:19:\"2026-07-03 19:38:21\";',1783129131),('laravel-cache-idempotency:1:1783129103327-9xjn4w0ke','s:19:\"2026-07-03 19:38:23\";',1783129133),('laravel-cache-idempotency:1:1783129131590-ygmld9i17','s:19:\"2026-07-03 19:38:51\";',1783129161),('laravel-cache-idempotency:1:1783129465820-fsmmtnffy','s:19:\"2026-07-03 19:44:26\";',1783129496),('laravel-cache-idempotency:1:1783129468216-dm9wqhfgz','s:19:\"2026-07-03 19:44:28\";',1783129498),('laravel-cache-idempotency:1:1783130020740-fcvwosdn5','s:19:\"2026-07-03 19:53:41\";',1783130051),('laravel-cache-idempotency:1:1783130051036-9gzly95zw','s:19:\"2026-07-03 19:54:11\";',1783130081),('laravel-cache-idempotency:1:1783130067389-fi6kv1unc','s:19:\"2026-07-03 19:54:27\";',1783130097),('laravel-cache-idempotency:1:1783130069991-gaolfxcaw','s:19:\"2026-07-03 19:54:30\";',1783130100),('laravel-cache-idempotency:1:1783130070710-9m9xpzlw8','s:19:\"2026-07-03 19:54:31\";',1783130101),('laravel-cache-idempotency:1:1783130089854-gp3bloxtw','s:19:\"2026-07-03 19:54:50\";',1783130120),('laravel-cache-idempotency:1:1783130090375-11wh94rfk','s:19:\"2026-07-03 19:54:50\";',1783130120),('laravel-cache-idempotency:1:1783130091531-s75hrgi3s','s:19:\"2026-07-03 19:54:51\";',1783130121),('laravel-cache-idempotency:1:1783130092053-zypi2p7ne','s:19:\"2026-07-03 19:54:52\";',1783130122),('laravel-cache-idempotency:1:1783130934477-3t8tmdexq','s:19:\"2026-07-03 20:08:55\";',1783130965),('laravel-cache-idempotency:1:1783130934485-6ecyn0m1g','s:19:\"2026-07-03 20:08:55\";',1783130965),('laravel-cache-idempotency:1:1783130938633-3thyh656u','s:19:\"2026-07-03 20:08:59\";',1783130969),('laravel-cache-idempotency:1:1783130938652-jccslgyhk','s:19:\"2026-07-03 20:08:59\";',1783130969),('laravel-cache-idempotency:1:1783130939862-x17x65iwd','s:19:\"2026-07-03 20:09:00\";',1783130970),('laravel-cache-idempotency:1:1783130940285-prngbxi9c','s:19:\"2026-07-03 20:09:00\";',1783130970),('laravel-cache-idempotency:1:1783130941080-yl1fpvjk0','s:19:\"2026-07-03 20:09:01\";',1783130971),('laravel-cache-idempotency:1:1783130942245-ecen57s1u','s:19:\"2026-07-03 20:09:02\";',1783130972),('laravel-cache-idempotency:1:1783130942326-h0xaxhjge','s:19:\"2026-07-03 20:09:02\";',1783130972),('laravel-cache-idempotency:1:1783130951033-j9nwnys8m','s:19:\"2026-07-03 20:09:11\";',1783130981),('laravel-cache-idempotency:1:1783130955289-28mekmwa1','s:19:\"2026-07-03 20:09:15\";',1783130985),('laravel-cache-idempotency:1:1783130961190-2dus2wa0b','s:19:\"2026-07-03 20:09:21\";',1783130991),('laravel-cache-idempotency:1:1783130967473-dm8df9324','s:19:\"2026-07-03 20:09:27\";',1783130997),('laravel-cache-idempotency:1:1783130969626-egp5otvtm','s:19:\"2026-07-03 20:09:29\";',1783130999),('laravel-cache-idempotency:1:1783130970113-sue5ke28n','s:19:\"2026-07-03 20:09:30\";',1783131000),('laravel-cache-idempotency:1:1783130970802-261z59iy0','s:19:\"2026-07-03 20:09:31\";',1783131001),('laravel-cache-idempotency:1:1783130975624-nvx2nw0wm','s:19:\"2026-07-03 20:09:35\";',1783131005),('laravel-cache-idempotency:1:1783130985904-ud9iohgbp','s:19:\"2026-07-03 20:09:46\";',1783131016),('laravel-cache-idempotency:1:1783131002533-myi2lnu6q','s:19:\"2026-07-03 20:10:02\";',1783131032),('laravel-cache-idempotency:1:1783131300177-xbq0hd175','s:19:\"2026-07-03 20:15:00\";',1783131330),('laravel-cache-idempotency:1:1783131311036-7h3wz4cdt','s:19:\"2026-07-03 20:15:11\";',1783131341),('laravel-cache-idempotency:1:1783131321533-7jjqxp07d','s:19:\"2026-07-03 20:15:21\";',1783131351),('laravel-cache-idempotency:1:1783131417073-itv594lfs','s:19:\"2026-07-03 20:16:57\";',1783131447),('laravel-cache-idempotency:1:1783131427639-la4jfjv9q','s:19:\"2026-07-03 20:17:07\";',1783131457),('laravel-cache-idempotency:1:1783131432479-2ns585ds6','s:19:\"2026-07-03 20:17:12\";',1783131462),('laravel-cache-idempotency:1:1783131433212-jay7lgtgd','s:19:\"2026-07-03 20:17:13\";',1783131463),('laravel-cache-idempotency:1:1783131441447-b6ob86570','s:19:\"2026-07-03 20:17:21\";',1783131471),('laravel-cache-idempotency:1:1783131445000-oe7fo5xh3','s:19:\"2026-07-03 20:17:25\";',1783131475),('laravel-cache-idempotency:1:1783131446593-qpj293jtf','s:19:\"2026-07-03 20:17:26\";',1783131476),('laravel-cache-idempotency:1:1783131447383-69hixcxgo','s:19:\"2026-07-03 20:17:27\";',1783131477),('laravel-cache-idempotency:1:1783131448754-8i3r0ysqp','s:19:\"2026-07-03 20:17:29\";',1783131479),('laravel-cache-idempotency:1:1783131455436-w9xx3kw26','s:19:\"2026-07-03 20:17:35\";',1783131485),('laravel-cache-idempotency:1:1783131456901-uag1m3c74','s:19:\"2026-07-03 20:17:37\";',1783131487),('laravel-cache-idempotency:1:1783131471097-3xvn1qazo','s:19:\"2026-07-03 20:17:51\";',1783131501),('laravel-cache-idempotency:1:1783131471574-166juwr3v','s:19:\"2026-07-03 20:17:52\";',1783131502),('laravel-cache-idempotency:1:1783131505941-r5yo3v42r','s:19:\"2026-07-03 20:18:26\";',1783131536),('laravel-cache-idempotency:1:1783131506220-pzqlscoii','s:19:\"2026-07-03 20:18:26\";',1783131536),('laravel-cache-idempotency:1:1783131591622-vsq1xdy1i','s:19:\"2026-07-03 20:19:51\";',1783131621),('laravel-cache-idempotency:1:1783131591664-92gfhmmyk','s:19:\"2026-07-03 20:19:52\";',1783131622),('laravel-cache-idempotency:1:1783131591718-lkv49twwl','s:19:\"2026-07-03 20:19:52\";',1783131622),('laravel-cache-idempotency:1:1783131597397-wt57u1ud1','s:19:\"2026-07-03 20:19:57\";',1783131627),('laravel-cache-idempotency:1:1783131605463-vv211r21v','s:19:\"2026-07-03 20:20:05\";',1783131635),('laravel-cache-idempotency:1:1783131613146-bxokz8jnn','s:19:\"2026-07-03 20:20:13\";',1783131643),('laravel-cache-idempotency:1:1783131614851-rem6avz8c','s:19:\"2026-07-03 20:20:15\";',1783131645),('laravel-cache-idempotency:1:1783131615541-xbwp3rrha','s:19:\"2026-07-03 20:20:15\";',1783131645),('laravel-cache-idempotency:1:1783131627706-uvr3jje2o','s:19:\"2026-07-03 20:20:28\";',1783131658),('laravel-cache-idempotency:1:1783131637461-u1kk89ozs','s:19:\"2026-07-03 20:20:37\";',1783131667),('laravel-cache-idempotency:1:1783131649098-yg1kga5o4','s:19:\"2026-07-03 20:20:49\";',1783131679),('laravel-cache-idempotency:1:1783131651224-gcwx1tqci','s:19:\"2026-07-03 20:20:51\";',1783131681),('laravel-cache-idempotency:1:1783131663887-rs3aazwwz','s:19:\"2026-07-03 20:21:04\";',1783131694),('laravel-cache-idempotency:1:1783131671805-nyqxutu28','s:19:\"2026-07-03 20:21:12\";',1783131702),('laravel-cache-idempotency:1:1783131672879-6amd9qsnc','s:19:\"2026-07-03 20:21:13\";',1783131703),('laravel-cache-idempotency:1:1783131678697-33lswg7bb','s:19:\"2026-07-03 20:21:19\";',1783131709),('laravel-cache-idempotency:1:1783131682238-z6fbpqkz7','s:19:\"2026-07-03 20:21:22\";',1783131712),('laravel-cache-idempotency:1:1783131684049-ykwe3mvgm','s:19:\"2026-07-03 20:21:24\";',1783131714),('laravel-cache-idempotency:1:1783131688852-7n4a7t9ux','s:19:\"2026-07-03 20:21:29\";',1783131719),('laravel-cache-idempotency:1:1783131695663-hz2d10e80','s:19:\"2026-07-03 20:21:36\";',1783131726),('laravel-cache-idempotency:1:1783131695779-y73e1xzh0','s:19:\"2026-07-03 20:21:36\";',1783131726),('laravel-cache-idempotency:1:1783131714932-haurha69e','s:19:\"2026-07-03 20:21:55\";',1783131745),('laravel-cache-idempotency:1:1783131715540-p7t2irylb','s:19:\"2026-07-03 20:21:55\";',1783131745),('laravel-cache-idempotency:1:1783131716641-eyvu3lr8d','s:19:\"2026-07-03 20:21:57\";',1783131747),('laravel-cache-idempotency:1:1783131717161-ze2pbjs43','s:19:\"2026-07-03 20:21:57\";',1783131747),('laravel-cache-idempotency:1:1783131719174-jmzws9yoc','s:19:\"2026-07-03 20:21:59\";',1783131749),('laravel-cache-idempotency:1:1783131728959-nm76p5x4p','s:19:\"2026-07-03 20:22:09\";',1783131759),('laravel-cache-idempotency:1:1783132241366-f1h87fxfw','s:19:\"2026-07-03 20:30:41\";',1783132271),('laravel-cache-idempotency:1:1783132241656-6ivdnqe4z','s:19:\"2026-07-03 20:30:41\";',1783132271),('laravel-cache-idempotency:1:1783132246955-gbvnwsy26','s:19:\"2026-07-03 20:30:47\";',1783132277),('laravel-cache-idempotency:1:1783132247164-z535zju6o','s:19:\"2026-07-03 20:30:47\";',1783132277),('laravel-cache-idempotency:1:1783132257331-ljo4st286','s:19:\"2026-07-03 20:30:57\";',1783132287),('laravel-cache-idempotency:1:1783132257655-hhsed4073','s:19:\"2026-07-03 20:30:58\";',1783132288),('laravel-cache-idempotency:1:1783132268623-wd7gs52xr','s:19:\"2026-07-03 20:31:08\";',1783132298),('laravel-cache-idempotency:1:1783132268905-38ydt2fmp','s:19:\"2026-07-03 20:31:09\";',1783132299),('laravel-cache-idempotency:1:1783132285154-9jgbjw4gz','s:19:\"2026-07-03 20:31:25\";',1783132315),('laravel-cache-idempotency:1:1783132298724-gagrzdkgj','s:19:\"2026-07-03 20:31:39\";',1783132329),('laravel-cache-idempotency:1:1783132298906-q4papihxn','s:19:\"2026-07-03 20:31:39\";',1783132329),('laravel-cache-idempotency:1:1783132301792-6ta4wru7c','s:19:\"2026-07-03 20:31:42\";',1783132332),('laravel-cache-idempotency:1:1783132302238-6qvbcvmuu','s:19:\"2026-07-03 20:31:42\";',1783132332),('laravel-cache-idempotency:1:1783132305076-dcsr5uhi9','s:19:\"2026-07-03 20:31:45\";',1783132335),('laravel-cache-idempotency:1:1783132308899-y83syqm3y','s:19:\"2026-07-03 20:31:49\";',1783132339),('laravel-cache-idempotency:1:1783132313331-un3fubsbd','s:19:\"2026-07-03 20:31:53\";',1783132343),('laravel-cache-idempotency:1:1783132314573-2vs2c1u9a','s:19:\"2026-07-03 20:31:54\";',1783132344),('laravel-cache-idempotency:1:1783132315521-6fd18p1py','s:19:\"2026-07-03 20:31:55\";',1783132345),('laravel-cache-idempotency:1:1783132335499-xv3v1jo5v','s:19:\"2026-07-03 20:32:15\";',1783132365),('laravel-cache-idempotency:1:1783132358906-i48suhb75','s:19:\"2026-07-03 20:32:39\";',1783132389),('laravel-cache-idempotency:1:1783132376699-whx4c5es9','s:19:\"2026-07-03 20:32:57\";',1783132407),('laravel-cache-idempotency:1:1783132387703-yacqwzqww','s:19:\"2026-07-03 20:33:08\";',1783132418),('laravel-cache-idempotency:1:1783132388058-szau2gim1','s:19:\"2026-07-03 20:33:08\";',1783132418),('laravel-cache-idempotency:1:1783132400418-i2qa4u81c','s:19:\"2026-07-03 20:33:20\";',1783132430),('laravel-cache-idempotency:1:1783132400721-vk8vysrzi','s:19:\"2026-07-03 20:33:21\";',1783132431),('laravel-cache-idempotency:1:1783132430725-yudmjwe1f','s:19:\"2026-07-03 20:33:51\";',1783132461),('laravel-cache-idempotency:1:1783132434906-qhw7g50c8','s:19:\"2026-07-03 20:33:55\";',1783132465),('laravel-cache-idempotency:1:1783132434917-pqfzj8m3u','s:19:\"2026-07-03 20:33:55\";',1783132465),('laravel-cache-idempotency:1:1783132447974-pbvg9ukop','s:19:\"2026-07-03 20:34:08\";',1783132478),('laravel-cache-idempotency:1:1783132460725-fh62wvcxn','s:19:\"2026-07-03 20:34:20\";',1783132490),('laravel-cache-idempotency:1:1783132466987-1ie2hyzdb','s:19:\"2026-07-03 20:34:27\";',1783132497),('laravel-cache-idempotency:1:1783132474930-k869o6yvz','s:19:\"2026-07-03 20:34:35\";',1783132505),('laravel-cache-idempotency:1:1783132475224-nbqvfnhlz','s:19:\"2026-07-03 20:34:35\";',1783132505),('laravel-cache-idempotency:1:1783132481643-2a6771zg8','s:19:\"2026-07-03 20:34:41\";',1783132511),('laravel-cache-idempotency:1:1783132535224-gkfi7rkbm','s:19:\"2026-07-03 20:35:35\";',1783132565),('laravel-cache-idempotency:1:1783132537549-tv11pxri2','s:19:\"2026-07-03 20:35:37\";',1783132567),('laravel-cache-idempotency:1:1783132622754-dypid2dos','s:19:\"2026-07-03 20:37:03\";',1783132653),('laravel-cache-idempotency:1:1783132623287-uwev98nfp','s:19:\"2026-07-03 20:37:03\";',1783132653),('laravel-cache-idempotency:1:1783132630360-u5jiz79hk','s:19:\"2026-07-03 20:37:10\";',1783132660),('laravel-cache-idempotency:1:1783132637339-x9ubtjtn9','s:19:\"2026-07-03 20:37:17\";',1783132667),('laravel-cache-idempotency:1:1783132644972-4uqjidsy9','s:19:\"2026-07-03 20:37:25\";',1783132675),('laravel-cache-idempotency:1:1783132671343-qc16qbut5','s:19:\"2026-07-03 20:37:52\";',1783132702),('laravel-cache-idempotency:1:1783132679626-i0z5pdr4u','s:19:\"2026-07-03 20:38:00\";',1783132710),('laravel-cache-idempotency:1:1783132716187-imspo1tz1','s:19:\"2026-07-03 20:38:36\";',1783132746),('laravel-cache-idempotency:1:1783132730378-ni4dz7s5b','s:19:\"2026-07-03 20:38:53\";',1783132763),('laravel-cache-idempotency:1:1783132735218-q0ylasxv5','s:19:\"2026-07-03 20:38:56\";',1783132766),('laravel-cache-idempotency:1:1783132736703-oek6lflts','s:19:\"2026-07-03 20:38:58\";',1783132768),('laravel-cache-idempotency:1:1783132737513-d4ad02esr','s:19:\"2026-07-03 20:38:59\";',1783132769),('laravel-cache-idempotency:1:1783132738249-14w5tc2a5','s:19:\"2026-07-03 20:38:59\";',1783132769),('laravel-cache-idempotency:1:1783132738804-dh3wex1c9','s:19:\"2026-07-03 20:39:00\";',1783132770),('laravel-cache-idempotency:1:1783132743880-n5zu2f5e0','s:19:\"2026-07-03 20:39:04\";',1783132774),('laravel-cache-idempotency:1:1783132744047-v8yguvw47','s:19:\"2026-07-03 20:39:04\";',1783132774),('laravel-cache-idempotency:1:1783132768791-8yf0q1n32','s:19:\"2026-07-03 20:39:29\";',1783132799),('laravel-cache-idempotency:1:1783132769408-02zklip9b','s:19:\"2026-07-03 20:39:30\";',1783132800),('laravel-cache-idempotency:1:1783132769513-kano9pyss','s:19:\"2026-07-03 20:39:31\";',1783132801),('laravel-cache-idempotency:1:1783132770372-5s0bnnwb7','s:19:\"2026-07-03 20:39:31\";',1783132801),('laravel-cache-idempotency:1:1783132796946-u5ui50i9q','s:19:\"2026-07-03 20:39:58\";',1783132828),('laravel-cache-idempotency:1:1783132805225-kq4tsnluj','s:19:\"2026-07-03 20:40:05\";',1783132835),('laravel-cache-idempotency:1:1783132810687-n0pu6nszh','s:19:\"2026-07-03 20:40:11\";',1783132841),('laravel-cache-idempotency:1:1783132811334-e8zuzxu3t','s:19:\"2026-07-03 20:40:11\";',1783132841),('laravel-cache-idempotency:1:1783132812326-mowuzgijt','s:19:\"2026-07-03 20:40:12\";',1783132842),('laravel-cache-idempotency:1:1783132812525-annb8ss63','s:19:\"2026-07-03 20:40:15\";',1783132845),('laravel-cache-idempotency:1:1783132832038-am0k4ll6g','s:19:\"2026-07-03 20:40:32\";',1783132862),('laravel-cache-idempotency:1:1783132836904-95ik1newi','s:19:\"2026-07-03 20:40:37\";',1783132867),('laravel-cache-idempotency:1:1783132860732-5n6uenxg7','s:19:\"2026-07-03 20:41:01\";',1783132891),('laravel-cache-idempotency:1:1783132886149-46nsvbjx9','s:19:\"2026-07-03 20:41:26\";',1783132916),('laravel-cache-idempotency:1:1783132886280-yb0enxh7z','s:19:\"2026-07-03 20:41:27\";',1783132917),('laravel-cache-idempotency:1:1783132919958-roxwieb4r','s:19:\"2026-07-03 20:42:00\";',1783132950),('laravel-cache-idempotency:1:1783132929023-56xtj1a0f','s:19:\"2026-07-03 20:42:09\";',1783132959),('laravel-cache-idempotency:1:1783132929681-k989q1sg9','s:19:\"2026-07-03 20:42:10\";',1783132960),('laravel-cache-idempotency:1:1783132934713-1on8yxvv1','s:19:\"2026-07-03 20:42:15\";',1783132965),('laravel-cache-idempotency:1:1783132948560-q8wzhqs9m','s:19:\"2026-07-03 20:42:29\";',1783132979),('laravel-cache-idempotency:1:1783132951172-ubqnyxjj9','s:19:\"2026-07-03 20:42:31\";',1783132981),('laravel-cache-idempotency:1:1783132977871-wrkxeca2z','s:19:\"2026-07-03 20:42:58\";',1783133008),('laravel-cache-idempotency:1:1783132985487-3h0gar8lc','s:19:\"2026-07-03 20:43:06\";',1783133016),('laravel-cache-idempotency:1:1783133011650-v3vi1v638','s:19:\"2026-07-03 20:43:32\";',1783133042),('laravel-cache-idempotency:1:1783133017919-442q0mgor','s:19:\"2026-07-03 20:43:38\";',1783133048),('laravel-cache-idempotency:1:1783133019682-qqzyrgcfm','s:19:\"2026-07-03 20:43:40\";',1783133050),('laravel-cache-idempotency:1:1783133020812-9d1n9sfnu','s:19:\"2026-07-03 20:43:41\";',1783133051),('laravel-cache-idempotency:1:1783133022470-l5xao2rig','s:19:\"2026-07-03 20:43:43\";',1783133053),('laravel-cache-idempotency:1:1783133025112-pz2pmpydb','s:19:\"2026-07-03 20:43:46\";',1783133056),('laravel-cache-idempotency:1:1783133066710-li0aqdp18','s:19:\"2026-07-03 20:44:28\";',1783133098),('laravel-cache-idempotency:1:1783133067012-h5njtxgfn','s:19:\"2026-07-03 20:44:28\";',1783133098),('laravel-cache-idempotency:1:1783133107142-ozz4drya9','s:19:\"2026-07-03 20:45:08\";',1783133138),('laravel-cache-idempotency:1:1783133109686-zdc6isb7f','s:19:\"2026-07-03 20:45:11\";',1783133141),('laravel-cache-idempotency:1:1783133112108-z7i9dkrum','s:19:\"2026-07-03 20:45:13\";',1783133143),('laravel-cache-idempotency:1:1783133113035-q6l633zly','s:19:\"2026-07-03 20:45:14\";',1783133144),('laravel-cache-idempotency:1:1783133131548-2noy6lvsg','s:19:\"2026-07-03 20:45:32\";',1783133162),('laravel-cache-idempotency:1:1783133136679-50ehxjhcj','s:19:\"2026-07-03 20:45:38\";',1783133168),('laravel-cache-idempotency:1:1783133138775-wur92m0oi','s:19:\"2026-07-03 20:45:39\";',1783133169),('laravel-cache-idempotency:1:1783133160295-7hb94e9v3','s:19:\"2026-07-03 20:46:01\";',1783133191),('laravel-cache-idempotency:1:1783133162347-wrs630n2n','s:19:\"2026-07-03 20:46:03\";',1783133193),('laravel-cache-idempotency:1:1783133187544-qp55ddqfh','s:19:\"2026-07-03 20:46:29\";',1783133219),('laravel-cache-idempotency:1:1783133190900-eeatfa0i3','s:19:\"2026-07-03 20:46:32\";',1783133222),('laravel-cache-idempotency:1:1783133204925-azs2dm1n0','s:19:\"2026-07-03 20:46:45\";',1783133235),('laravel-cache-idempotency:1:1783133205224-mb1o3ha94','s:19:\"2026-07-03 20:46:45\";',1783133235),('laravel-cache-idempotency:1:1783133233412-lu89jctps','s:19:\"2026-07-03 20:47:16\";',1783133266),('laravel-cache-idempotency:1:1783133238313-58p653dd1','s:19:\"2026-07-03 20:47:18\";',1783133268),('laravel-cache-idempotency:1:1783133247463-4zwda66qf','s:19:\"2026-07-03 20:47:28\";',1783133278),('laravel-cache-idempotency:1:1783133436585-4chhy0efi','s:19:\"2026-07-03 20:50:37\";',1783133467),('laravel-cache-idempotency:1:1783133870768-3fafe3f0d','s:19:\"2026-07-03 20:57:51\";',1783133901),('laravel-cache-idempotency:1:1783133874461-ri8i6ody7','s:19:\"2026-07-03 20:57:54\";',1783133904),('laravel-cache-idempotency:1:1783133882035-sn5t1pkga','s:19:\"2026-07-03 20:58:02\";',1783133912),('laravel-cache-idempotency:1:1783133884849-y3ei8uob7','s:19:\"2026-07-03 20:58:05\";',1783133915),('laravel-cache-idempotency:1:1783133949675-b47le5yz4','s:19:\"2026-07-03 20:59:10\";',1783133980),('laravel-cache-idempotency:1:1783133960675-ovamdcr5z','s:19:\"2026-07-03 20:59:21\";',1783133991),('laravel-cache-idempotency:1:1783133974837-07dwcyphm','s:19:\"2026-07-03 20:59:36\";',1783134006),('laravel-cache-idempotency:1:1783133979672-ucqtgb8q4','s:19:\"2026-07-03 20:59:40\";',1783134010),('laravel-cache-idempotency:1:1783133998574-2w2b1t0z0','s:19:\"2026-07-03 20:59:59\";',1783134029),('laravel-cache-idempotency:1:1783134119698-oe3tc7xaz','s:19:\"2026-07-03 21:02:00\";',1783134150),('laravel-cache-idempotency:1:1783134459599-79azor6q3','s:19:\"2026-07-03 21:07:42\";',1783134492),('laravel-cache-idempotency:1:1783134462117-yitjx7li3','s:19:\"2026-07-03 21:07:43\";',1783134493),('laravel-cache-idempotency:1:1783134480089-c99hjw7yc','s:19:\"2026-07-03 21:08:03\";',1783134513),('laravel-cache-idempotency:1:1783135323199-o8fkjryqy','s:19:\"2026-07-03 21:22:03\";',1783135353),('laravel-cache-idempotency:1:1783136182669-405w053an','s:19:\"2026-07-03 21:36:24\";',1783136214),('laravel-cache-idempotency:1:1783207502490-niixfbl31','s:19:\"2026-07-04 17:25:04\";',1783207534),('laravel-cache-idempotency:1:1783207504208-0w2ii5wi5','s:19:\"2026-07-04 17:25:04\";',1783207534),('laravel-cache-idempotency:1:1783207524451-9iu8cl56v','s:19:\"2026-07-04 17:25:25\";',1783207555),('laravel-cache-idempotency:1:1783207532254-lqbeqbywy','s:19:\"2026-07-04 17:25:32\";',1783207562),('laravel-cache-idempotency:1:1783207534235-0nkxznkg9','s:19:\"2026-07-04 17:25:34\";',1783207564),('laravel-cache-idempotency:1:1783207547916-zju8h96et','s:19:\"2026-07-04 17:25:48\";',1783207578),('laravel-cache-idempotency:1:1783207580492-6ynas4m9z','s:19:\"2026-07-04 17:26:21\";',1783207611),('laravel-cache-idempotency:1:1783207594213-bzfvaipzy','s:19:\"2026-07-04 17:26:35\";',1783207625),('laravel-cache-idempotency:1:1783207594729-5liyllb54','s:19:\"2026-07-04 17:26:35\";',1783207625),('laravel-cache-idempotency:1:1783207624208-xd5bznfa1','s:19:\"2026-07-04 17:27:04\";',1783207654),('laravel-cache-idempotency:1:1783207654209-vo5dulco1','s:19:\"2026-07-04 17:27:34\";',1783207684),('laravel-cache-idempotency:1:1783207663377-ye77psjxb','s:19:\"2026-07-04 17:27:44\";',1783207694),('laravel-cache-idempotency:1:1783207684310-wgo456odi','s:19:\"2026-07-04 17:28:05\";',1783207715),('laravel-cache-idempotency:1:1783207714208-vf57fvu3s','s:19:\"2026-07-04 17:28:35\";',1783207745),('laravel-cache-idempotency:1:1783207743792-ns7sf7ezl','s:19:\"2026-07-04 17:29:04\";',1783207774),('laravel-cache-idempotency:1:1783207744988-yf0dbj5al','s:19:\"2026-07-04 17:29:05\";',1783207775),('laravel-cache-idempotency:1:1783207765020-uouvytz1n','s:19:\"2026-07-04 17:29:25\";',1783207795),('laravel-cache-idempotency:1:1783207765022-a4g1lfnns','s:19:\"2026-07-04 17:29:26\";',1783207796),('laravel-cache-idempotency:1:1783207770077-ra7o621aq','s:19:\"2026-07-04 17:29:30\";',1783207800),('laravel-cache-idempotency:1:1783207780378-a35ggr2o1','s:19:\"2026-07-04 17:29:41\";',1783207811),('laravel-cache-idempotency:1:1783207789336-rgc01hmzj','s:19:\"2026-07-04 17:29:55\";',1783207825),('laravel-cache-idempotency:1:1783207790370-ayxjy0ynz','s:19:\"2026-07-04 17:30:03\";',1783207833),('laravel-cache-idempotency:1:1783207796131-8oppondhe','s:19:\"2026-07-04 17:30:04\";',1783207834),('laravel-cache-idempotency:1:1783207804208-8tfu7l6re','s:19:\"2026-07-04 17:30:07\";',1783207837),('laravel-cache-idempotency:1:1783207824047-y4k1e5wm5','s:19:\"2026-07-04 17:30:25\";',1783207855),('laravel-cache-idempotency:1:1783207825224-6oo8el6r4','s:19:\"2026-07-04 17:30:25\";',1783207855),('laravel-cache-idempotency:1:1783207853992-ybbhcf5nx','s:19:\"2026-07-04 17:31:03\";',1783207893),('laravel-cache-idempotency:1:1783207856602-9xyauzqdr','s:19:\"2026-07-04 17:31:04\";',1783207894),('laravel-cache-idempotency:1:1783230450017-8vczyiao8','s:19:\"2026-07-04 23:47:30\";',1783230480),('laravel-cache-idempotency:1:1783230451005-q8de34vfs','s:19:\"2026-07-04 23:47:31\";',1783230481),('laravel-cache-idempotency:1:1783230466749-9kceowr9h','s:19:\"2026-07-04 23:47:47\";',1783230497),('laravel-cache-idempotency:1:1783231156310-nataejcsi','s:19:\"2026-07-04 23:59:17\";',1783231187),('laravel-cache-idempotency:1:1783231158267-0sz288ecg','s:19:\"2026-07-04 23:59:18\";',1783231188),('laravel-cache-idempotency:1:1783231575765-5bqu8nw24','s:19:\"2026-07-05 00:06:16\";',1783231606),('laravel-cache-idempotency:1:1783231575781-h1wtez3no','s:19:\"2026-07-05 00:06:16\";',1783231606),('laravel-cache-idempotency:1:1783231580690-i5uld381s','s:19:\"2026-07-05 00:06:21\";',1783231611),('laravel-cache-idempotency:1:1783231581146-r0kwaip3l','s:19:\"2026-07-05 00:06:22\";',1783231612),('laravel-cache-idempotency:1:1783231581883-6ng87raf6','s:19:\"2026-07-05 00:06:22\";',1783231612),('laravel-cache-idempotency:1:1783231582740-ngb5kw6rw','s:19:\"2026-07-05 00:06:23\";',1783231613),('laravel-cache-idempotency:1:1783231614730-hkv1yf4z2','s:19:\"2026-07-05 00:06:55\";',1783231645),('laravel-cache-idempotency:1:1783231615307-qdbwhpxwh','s:19:\"2026-07-05 00:06:56\";',1783231646),('laravel-cache-idempotency:1:1783231615980-a6sj3r7bc','s:19:\"2026-07-05 00:06:56\";',1783231646),('laravel-cache-idempotency:1:1783231616269-pwgnnl5z0','s:19:\"2026-07-05 00:06:56\";',1783231646),('laravel-cache-idempotency:1:1783231646595-3s8ic3407','s:19:\"2026-07-05 00:07:27\";',1783231677),('laravel-cache-idempotency:1:1783231648861-4o06t6hq7','s:19:\"2026-07-05 00:07:29\";',1783231679),('laravel-cache-idempotency:1:1783231648946-1nyf22vs9','s:19:\"2026-07-05 00:07:29\";',1783231679),('laravel-cache-idempotency:1:1783231651186-swacqqn11','s:19:\"2026-07-05 00:07:31\";',1783231681),('laravel-cache-idempotency:1:1783231651761-dfg33xjrh','s:19:\"2026-07-05 00:07:32\";',1783231682),('laravel-cache-idempotency:1:1783231651879-726guhc0e','s:19:\"2026-07-05 00:07:32\";',1783231682),('laravel-cache-idempotency:1:1783231652136-45cocj16j','s:19:\"2026-07-05 00:07:33\";',1783231683),('laravel-cache-idempotency:1:1783231826822-y036g9wad','s:19:\"2026-07-05 00:10:27\";',1783231857),('laravel-cache-idempotency:1:1783231827526-jjmn4gc2q','s:19:\"2026-07-05 00:10:27\";',1783231857),('laravel-cache-idempotency:1:1783231850922-gqi4vm4y8','s:19:\"2026-07-05 00:10:51\";',1783231881),('laravel-cache-idempotency:1:1783231853841-pw4j4jky0','s:19:\"2026-07-05 00:10:54\";',1783231884),('laravel-cache-idempotency:1:1783231853945-5suins2xp','s:19:\"2026-07-05 00:10:54\";',1783231884),('laravel-cache-idempotency:1:1783231854878-t6uovhh4k','s:19:\"2026-07-05 00:10:55\";',1783231885),('laravel-cache-idempotency:1:1783231864393-ma7xclsy1','s:19:\"2026-07-05 00:11:04\";',1783231894),('laravel-cache-idempotency:1:1783231866647-v6y0j68c7','s:19:\"2026-07-05 00:11:06\";',1783231896),('laravel-cache-idempotency:1:1783231884167-uw7o8xcqp','s:19:\"2026-07-05 00:11:24\";',1783231914),('laravel-cache-idempotency:1:1783231884464-2ozoojbwo','s:19:\"2026-07-05 00:11:25\";',1783231915),('laravel-cache-idempotency:1:1783231885332-zkas9bij','s:19:\"2026-07-05 00:11:25\";',1783231915),('laravel-cache-idempotency:1:1783231891448-doyj50vd1','s:19:\"2026-07-05 00:11:31\";',1783231921),('laravel-cache-idempotency:1:1783231893339-oziqenvnm','s:19:\"2026-07-05 00:11:33\";',1783231923),('laravel-cache-idempotency:1:1783231894035-kq8yks1u2','s:19:\"2026-07-05 00:11:34\";',1783231924),('laravel-cache-idempotency:1:1783231894160-ir1n6qsla','s:19:\"2026-07-05 00:11:34\";',1783231924),('laravel-cache-idempotency:1:1783231894418-rjg158gcu','s:19:\"2026-07-05 00:11:35\";',1783231925),('laravel-cache-idempotency:1:1783232069095-i7tr7ag0t','s:19:\"2026-07-05 00:14:29\";',1783232099),('laravel-cache-idempotency:1:1783232070477-ciox2hc2h','s:19:\"2026-07-05 00:14:30\";',1783232100),('laravel-cache-idempotency:1:1783232114696-13uvw0m7t','s:19:\"2026-07-05 00:15:15\";',1783232145),('laravel-cache-idempotency:1:1783232114922-acfk8pe1p','s:19:\"2026-07-05 00:15:15\";',1783232145),('laravel-cache-idempotency:1:1783232119290-4287z9ahy','s:19:\"2026-07-05 00:15:19\";',1783232149),('laravel-cache-idempotency:1:1783232120077-4f4zzrlbc','s:19:\"2026-07-05 00:15:20\";',1783232150),('laravel-cache-idempotency:1:1783232132826-cipkkagzw','s:19:\"2026-07-05 00:15:33\";',1783232163),('laravel-cache-idempotency:1:1783232134057-upzcnpuhu','s:19:\"2026-07-05 00:15:34\";',1783232164),('laravel-cache-idempotency:1:1783232134793-zi7awnn9m','s:19:\"2026-07-05 00:15:35\";',1783232165),('laravel-cache-idempotency:1:1783232136054-6z5bjo4w6','s:19:\"2026-07-05 00:15:36\";',1783232166),('laravel-cache-idempotency:1:1783232136127-uismg1z47','s:19:\"2026-07-05 00:15:36\";',1783232166),('laravel-cache-idempotency:1:1783232137516-gowrshl26','s:19:\"2026-07-05 00:15:37\";',1783232167),('laravel-cache-idempotency:1:1783232139513-0vlzvhf18','s:19:\"2026-07-05 00:15:40\";',1783232170),('laravel-cache-idempotency:1:1783232140140-ga20p7jgr','s:19:\"2026-07-05 00:15:40\";',1783232170),('laravel-cache-idempotency:1:1783232140515-6imr3o05h','s:19:\"2026-07-05 00:15:40\";',1783232170),('laravel-cache-idempotency:1:1783232141679-vlhcoqbef','s:19:\"2026-07-05 00:15:42\";',1783232172),('laravel-cache-idempotency:1:1783232200501-v43g7barn','s:19:\"2026-07-05 00:16:41\";',1783232231),('laravel-cache-idempotency:1:1783232200909-00lqelmik','s:19:\"2026-07-05 00:16:41\";',1783232231),('laravel-cache-idempotency:1:1783232236925-hzicdr1ac','s:19:\"2026-07-05 00:17:17\";',1783232267),('laravel-cache-idempotency:1:1783232237662-vrimpunxh','s:19:\"2026-07-05 00:17:18\";',1783232268),('laravel-cache-idempotency:1:1783232736042-vfmn5xc85','s:19:\"2026-07-05 00:25:36\";',1783232766),('laravel-cache-idempotency:1:1783232737800-ypw0z9733','s:19:\"2026-07-05 00:25:38\";',1783232768),('laravel-cache-idempotency:1:1783232738305-0b5i08e10','s:19:\"2026-07-05 00:25:38\";',1783232768),('laravel-cache-idempotency:1:1783232738539-4hgqqx2py','s:19:\"2026-07-05 00:25:39\";',1783232769),('laravel-cache-idempotency:1:1783232747496-lfljxkv0j','s:19:\"2026-07-05 00:25:48\";',1783232778),('laravel-cache-idempotency:1:1783232748582-49p019czz','s:19:\"2026-07-05 00:25:49\";',1783232779),('laravel-cache-idempotency:1:1783233048830-ozf1mngkj','s:19:\"2026-07-05 00:30:49\";',1783233079),('laravel-cache-idempotency:1:1783233054995-6zw4uhm45','s:19:\"2026-07-05 00:30:55\";',1783233085),('laravel-cache-idempotency:1:1783233128455-v41vjhq8l','s:19:\"2026-07-05 00:32:09\";',1783233159),('laravel-cache-idempotency:1:1783233129383-os260qv97','s:19:\"2026-07-05 00:32:09\";',1783233159),('laravel-cache-idempotency:1:1783233194786-6f0sfu76p','s:19:\"2026-07-05 00:33:15\";',1783233225),('laravel-cache-idempotency:1:1783233195864-ndwmby8a9','s:19:\"2026-07-05 00:33:16\";',1783233226),('laravel-cache-idempotency:1:1783233196052-8ct83nojf','s:19:\"2026-07-05 00:33:16\";',1783233226),('laravel-cache-idempotency:1:1783233197028-1ntgx2vzn','s:19:\"2026-07-05 00:33:17\";',1783233227),('laravel-cache-idempotency:1:1783233267595-x5t9rldvm','s:19:\"2026-07-05 00:34:28\";',1783233298),('laravel-cache-idempotency:1:1783233267969-a8j59kgu2','s:19:\"2026-07-05 00:34:28\";',1783233298),('laravel-cache-idempotency:1:1783233273188-6mnqcup9g','s:19:\"2026-07-05 00:34:33\";',1783233303),('laravel-cache-idempotency:1:1783233273387-1eb1klfgq','s:19:\"2026-07-05 00:34:33\";',1783233303),('laravel-cache-idempotency:1:1783233274002-czub8nqv7','s:19:\"2026-07-05 00:34:34\";',1783233304),('laravel-cache-idempotency:1:1783233274111-dsun6m6or','s:19:\"2026-07-05 00:34:34\";',1783233304),('laravel-cache-idempotency:1:1783233334893-solo4p9mv','s:19:\"2026-07-05 00:35:35\";',1783233365),('laravel-cache-idempotency:1:1783233335782-0qucbj086','s:19:\"2026-07-05 00:35:36\";',1783233366),('laravel-cache-idempotency:1:1783233379187-givhebys9','s:19:\"2026-07-05 00:36:19\";',1783233409),('laravel-cache-idempotency:1:1783233379453-yym4hk9dn','s:19:\"2026-07-05 00:36:20\";',1783233410),('laravel-cache-idempotency:1:1783233379494-8ug05la4z','s:19:\"2026-07-05 00:36:21\";',1783233411),('laravel-cache-idempotency:1:1783233380461-3a00w2jwg','s:19:\"2026-07-05 00:36:21\";',1783233411),('laravel-cache-idempotency:1:1783233441496-9rhpkzv69','s:19:\"2026-07-05 00:37:21\";',1783233471),('laravel-cache-idempotency:1:1783233443129-59gnptwno','s:19:\"2026-07-05 00:37:23\";',1783233473),('laravel-cache-idempotency:1:1783233446271-xd474tiwi','s:19:\"2026-07-05 00:37:26\";',1783233476),('laravel-cache-idempotency:1:1783233446558-nmgywc920','s:19:\"2026-07-05 00:37:27\";',1783233477),('laravel-cache-idempotency:1:1783233446725-wj74celgl','s:19:\"2026-07-05 00:37:27\";',1783233477),('laravel-cache-idempotency:1:1783233446893-csbc3afhs','s:19:\"2026-07-05 00:37:28\";',1783233478),('laravel-cache-idempotency:1:1783233464966-b797qjbr7','s:19:\"2026-07-05 00:37:45\";',1783233495),('laravel-cache-idempotency:1:1783233465746-ngn7bsoe0','s:19:\"2026-07-05 00:37:46\";',1783233496),('laravel-cache-idempotency:1:1783233465859-s61i5ie2b','s:19:\"2026-07-05 00:37:47\";',1783233497),('laravel-cache-idempotency:1:1783233467577-k93f8o912','s:19:\"2026-07-05 00:37:48\";',1783233498),('laravel-cache-idempotency:1:1783233467655-9z7laibw0','s:19:\"2026-07-05 00:37:48\";',1783233498),('laravel-cache-idempotency:1:1783233467881-7dhxwmt3h','s:19:\"2026-07-05 00:37:49\";',1783233499),('laravel-cache-idempotency:1:1783233569154-1096cpust','s:19:\"2026-07-05 00:39:30\";',1783233600),('laravel-cache-idempotency:1:1783233569547-svr5m6bxr','s:19:\"2026-07-05 00:39:31\";',1783233601),('laravel-cache-idempotency:1:1783233570584-jupyx2u8t','s:19:\"2026-07-05 00:39:31\";',1783233601),('laravel-cache-idempotency:1:1783233572516-vaspicd9f','s:19:\"2026-07-05 00:39:32\";',1783233602),('laravel-cache-idempotency:1:1783233584835-e6ysu1r88','s:19:\"2026-07-05 00:39:45\";',1783233615),('laravel-cache-idempotency:1:1783233588530-plyl066n1','s:19:\"2026-07-05 00:39:49\";',1783233619),('laravel-cache-idempotency:1:1783233605105-0tbk68jq6','s:19:\"2026-07-05 00:40:05\";',1783233635),('laravel-cache-idempotency:1:1783233606187-1xqj2rzcf','s:19:\"2026-07-05 00:40:06\";',1783233636),('laravel-cache-idempotency:1:1783233606349-lkku8mg80','s:19:\"2026-07-05 00:40:07\";',1783233637),('laravel-cache-idempotency:1:1783233606714-7ulmjxxui','s:19:\"2026-07-05 00:40:08\";',1783233638),('laravel-cache-idempotency:1:1783234890344-3fg3nsvoq','s:19:\"2026-07-05 01:01:30\";',1783234920),('laravel-cache-idempotency:1:1783234890497-7wjc7p5qa','s:19:\"2026-07-05 01:01:31\";',1783234921),('laravel-cache-idempotency:1:1783234901264-fbustj45d','s:19:\"2026-07-05 01:01:41\";',1783234931),('laravel-cache-idempotency:1:1783234901536-q40fgptsn','s:19:\"2026-07-05 01:01:42\";',1783234932),('laravel-cache-idempotency:1:1783235391628-2tbjpb3iw','s:19:\"2026-07-05 01:09:52\";',1783235422),('laravel-cache-idempotency:1:1783235392199-5cn7wtysm','s:19:\"2026-07-05 01:09:52\";',1783235422),('laravel-cache-idempotency:1:1783235392337-2mlzb0zq9','s:19:\"2026-07-05 01:09:53\";',1783235423),('laravel-cache-idempotency:1:1783235392851-lu5wtk33s','s:19:\"2026-07-05 01:09:53\";',1783235423),('laravel-cache-idempotency:1:1783235583187-m8oi1p5mp','s:19:\"2026-07-05 01:13:03\";',1783235613),('laravel-cache-idempotency:1:1783235583456-tnifvcs05','s:19:\"2026-07-05 01:13:04\";',1783235614),('laravel-cache-idempotency:1:1783235938190-myuc627yy','s:19:\"2026-07-05 01:18:58\";',1783235968),('laravel-cache-idempotency:1:1783235938340-jkr5l7i0t','s:19:\"2026-07-05 01:18:59\";',1783235969),('laravel-cache-idempotency:1:1783235973880-5ie99vowq','s:19:\"2026-07-05 01:19:34\";',1783236004),('laravel-cache-idempotency:1:1783235975069-rtcjr0azb','s:19:\"2026-07-05 01:19:35\";',1783236005),('laravel-cache-idempotency:1:1783235977378-qkuoo3njc','s:19:\"2026-07-05 01:19:37\";',1783236007),('laravel-cache-idempotency:1:1783235978521-693u546rf','s:19:\"2026-07-05 01:19:39\";',1783236009),('laravel-cache-idempotency:1:1783235996244-i42n3p74h','s:19:\"2026-07-05 01:19:56\";',1783236026),('laravel-cache-idempotency:1:1783235998093-ujez1m8b2','s:19:\"2026-07-05 01:19:58\";',1783236028),('laravel-cache-idempotency:1:1783963176693-no2a4fvph','s:19:\"2026-07-13 11:19:37\";',1783963207),('laravel-cache-idempotency:1:1783963177392-koifzlxg4','s:19:\"2026-07-13 11:19:37\";',1783963207),('laravel-cache-idempotency:1:1783963195793-qg09gxgn2','s:19:\"2026-07-13 11:19:56\";',1783963226),('laravel-cache-idempotency:1:1783963199432-37i3me2go','s:19:\"2026-07-13 11:19:59\";',1783963229),('laravel-cache-idempotency:1:1783963199553-tfdhywki7','s:19:\"2026-07-13 11:20:00\";',1783963230),('laravel-cache-idempotency:1:1783963218515-f421dupbf','s:19:\"2026-07-13 11:20:18\";',1783963248),('laravel-cache-idempotency:1:1783963237387-cmzo4xpl1','s:19:\"2026-07-13 11:20:37\";',1783963267),('laravel-cache-idempotency:1:1783963267386-2ki85uew5','s:19:\"2026-07-13 11:21:07\";',1783963297),('laravel-cache-idempotency:1:1783963297373-1glvfpnke','s:19:\"2026-07-13 11:21:37\";',1783963327),('laravel-cache-idempotency:1:1783963327377-9pd4qtn83','s:19:\"2026-07-13 11:22:07\";',1783963357),('laravel-cache-idempotency:1:1783963329774-jlopky2mz','s:19:\"2026-07-13 11:22:10\";',1783963360),('laravel-cache-idempotency:1:1783963333628-oht2rkirs','s:19:\"2026-07-13 11:22:13\";',1783963363),('laravel-cache-idempotency:1:1783963333629-7tkyuu6vl','s:19:\"2026-07-13 11:22:14\";',1783963364),('laravel-cache-idempotency:1:1783963357367-it16g1i9r','s:19:\"2026-07-13 11:22:37\";',1783963387),('laravel-cache-idempotency:1:1783963374896-3kdax91ks','s:19:\"2026-07-13 11:22:55\";',1783963405),('laravel-cache-idempotency:1:1783963374897-m4qf9ala0','s:19:\"2026-07-13 11:22:55\";',1783963405),('laravel-cache-idempotency:1:1783963376701-6eb0ovv21','s:19:\"2026-07-13 11:22:56\";',1783963406),('laravel-cache-idempotency:1:1783963413608-b81hufxtq','s:19:\"2026-07-13 11:23:33\";',1783963443),('laravel-cache-idempotency:1:1783963672094-ea4iog2je','s:19:\"2026-07-13 11:27:52\";',1783963702),('laravel-cache-idempotency:1:1783963679854-6l3lxxvfb','s:19:\"2026-07-13 11:28:00\";',1783963710),('laravel-cache-idempotency:1:1783963680155-3tmnsiv2t','s:19:\"2026-07-13 11:28:00\";',1783963710),('laravel-cache-idempotency:1:1783963710162-4f550wb75','s:19:\"2026-07-13 11:28:30\";',1783963740),('laravel-cache-idempotency:1:1783963726472-04oxfjk1a','s:19:\"2026-07-13 11:28:46\";',1783963756),('laravel-cache-idempotency:1:1783963737578-ayumtt7gp','s:19:\"2026-07-13 11:28:57\";',1783963767),('laravel-cache-idempotency:1:1783963737879-v7oa4j92k','s:19:\"2026-07-13 11:28:58\";',1783963768),('laravel-cache-idempotency:1:1783963754139-jlkgeie7q','s:19:\"2026-07-13 11:29:14\";',1783963784),('laravel-cache-idempotency:1:1783963761769-wrothbxpv','s:19:\"2026-07-13 11:29:22\";',1783963792),('laravel-cache-idempotency:1:1783963762067-0906nh51z','s:19:\"2026-07-13 11:29:22\";',1783963792),('laravel-cache-idempotency:1:1783963779480-lq1ywalu3','s:19:\"2026-07-13 11:29:39\";',1783963809),('laravel-cache-idempotency:1:1783963782898-xko1dk3bz','s:19:\"2026-07-13 11:29:43\";',1783963813),('laravel-cache-idempotency:1:1783963785074-l60mtkv7x','s:19:\"2026-07-13 11:29:45\";',1783963815),('laravel-cache-idempotency:1:1783963788115-aydpeyuc6','s:19:\"2026-07-13 11:29:48\";',1783963818),('laravel-cache-idempotency:1:1783963890574-fxzor7z7f','s:19:\"2026-07-13 11:31:31\";',1783963921),('laravel-cache-idempotency:1:1783963915097-1r98c1d5d','s:19:\"2026-07-13 11:31:55\";',1783963945),('laravel-cache-idempotency:1:1783963924328-m4xmumvhe','s:19:\"2026-07-13 11:32:04\";',1783963954),('laravel-cache-idempotency:1:1783963967724-ueu3556kk','s:19:\"2026-07-13 11:32:48\";',1783963998),('laravel-cache-idempotency:1:1783964401001-hnmape8g7','s:19:\"2026-07-13 11:40:01\";',1783964431),('laravel-cache-idempotency:1:1783964401303-h0hvevwrr','s:19:\"2026-07-13 11:40:01\";',1783964431),('laravel-cache-idempotency:1:1783964429688-yvleqeu1e','s:19:\"2026-07-13 11:40:29\";',1783964459),('laravel-cache-idempotency:1:1783964429996-carjqr80r','s:19:\"2026-07-13 11:40:30\";',1783964460),('laravel-cache-idempotency:1:1783964431296-c0e38nf9m','s:19:\"2026-07-13 11:40:31\";',1783964461),('laravel-cache-idempotency:1:1783964437676-q63vca6d7','s:19:\"2026-07-13 11:40:37\";',1783964467),('laravel-cache-idempotency:1:1783964441160-eiawdmlfe','s:19:\"2026-07-13 11:40:41\";',1783964471),('laravel-cache-idempotency:1:1783964480503-ryiog0z2i','s:19:\"2026-07-13 11:41:20\";',1783964510),('laravel-cache-idempotency:1:1783964616646-daeuvfseg','s:19:\"2026-07-13 11:43:37\";',1783964647),('laravel-cache-idempotency:1:1783964627460-lpimp9za6','s:19:\"2026-07-13 11:43:47\";',1783964657),('laravel-cache-idempotency:1:1783964628406-4chuyu9iw','s:19:\"2026-07-13 11:43:48\";',1783964658),('laravel-cache-idempotency:1:1783964630122-353bwpi0c','s:19:\"2026-07-13 11:43:50\";',1783964660),('laravel-cache-idempotency:1:1783964630123-0ukaajd9t','s:19:\"2026-07-13 11:43:50\";',1783964660),('laravel-cache-idempotency:1:1783964641273-z8tny0vyl','s:19:\"2026-07-13 11:44:01\";',1783964671),('laravel-cache-idempotency:1:1783964651501-pycmszhts','s:19:\"2026-07-13 11:44:11\";',1783964681),('laravel-cache-idempotency:1:1783964895635-41dglbrio','s:19:\"2026-07-13 11:48:17\";',1783964927),('laravel-cache-idempotency:1:1783964902505-r4ooqnced','s:19:\"2026-07-13 11:48:22\";',1783964932),('laravel-cache-idempotency:1:1783964903771-mexnucffa','s:19:\"2026-07-13 11:48:24\";',1783964934),('laravel-cache-idempotency:1:1783964911241-qq8q1hoom','s:19:\"2026-07-13 11:48:31\";',1783964941),('laravel-cache-idempotency:1:1783964923912-7kh9tkiqo','s:19:\"2026-07-13 11:48:44\";',1783964954),('laravel-cache-idempotency:1:1783964931513-zf1ro5uhg','s:19:\"2026-07-13 11:48:51\";',1783964961),('laravel-cache-idempotency:1:1783964936319-idilt5cg8','s:19:\"2026-07-13 11:48:56\";',1783964966),('laravel-cache-idempotency:1:1783964940951-8z5qq543j','s:19:\"2026-07-13 11:49:01\";',1783964971),('laravel-cache-idempotency:1:1783964944490-ubu2d8s4f','s:19:\"2026-07-13 11:49:04\";',1783964974),('laravel-cache-idempotency:1:1783964962100-1t0d8y4gp','s:19:\"2026-07-13 11:49:22\";',1783964992),('laravel-cache-idempotency:1:1783964971231-2vcjtkpxv','s:19:\"2026-07-13 11:49:31\";',1783965001),('laravel-cache-idempotency:1:1783964973277-w8seanpu4','s:19:\"2026-07-13 11:49:33\";',1783965003),('laravel-cache-idempotency:1:1783964983990-dh12vif98','s:19:\"2026-07-13 11:49:44\";',1783965014),('laravel-cache-idempotency:1:1783964997466-kdbienlks','s:19:\"2026-07-13 11:49:57\";',1783965027),('laravel-cache-idempotency:1:1783965006187-3a753nnks','s:19:\"2026-07-13 11:50:06\";',1783965036),('laravel-cache-idempotency:1:1783965014851-z5es434lg','s:19:\"2026-07-13 11:50:15\";',1783965045),('laravel-cache-idempotency:1:1783965020771-4qb4qtct2','s:19:\"2026-07-13 11:50:21\";',1783965051),('laravel-cache-idempotency:1:1783965023214-e70de9woq','s:19:\"2026-07-13 11:50:23\";',1783965053),('laravel-cache-idempotency:1:1783965031221-9q01hxzaw','s:19:\"2026-07-13 11:50:31\";',1783965061),('laravel-cache-idempotency:1:1783965035662-gorzn9c6z','s:19:\"2026-07-13 11:50:35\";',1783965065),('laravel-cache-idempotency:1:1783965044460-oyqblqk8x','s:19:\"2026-07-13 11:50:44\";',1783965074),('laravel-cache-idempotency:1:1783965061220-rvgxxi3tc','s:19:\"2026-07-13 11:51:01\";',1783965091),('laravel-cache-idempotency:1:1783965072564-cudqg92j0','s:19:\"2026-07-13 11:51:14\";',1783965104),('laravel-cache-idempotency:1:1783965079244-g5v117bzq','s:19:\"2026-07-13 11:51:19\";',1783965109),('laravel-cache-idempotency:1:1783965091215-qch2gcg2b','s:19:\"2026-07-13 11:51:31\";',1783965121),('laravel-cache-idempotency:1:1783965116343-blpkz9a0i','s:19:\"2026-07-13 11:51:56\";',1783965146),('laravel-cache-idempotency:1:1783965117926-1hf5mj3rb','s:19:\"2026-07-13 11:51:58\";',1783965148),('laravel-cache-idempotency:1:1783965120583-z73oiif6z','s:19:\"2026-07-13 11:52:01\";',1783965151),('laravel-cache-idempotency:1:1783965122566-tpqb6p7z4','s:19:\"2026-07-13 11:52:03\";',1783965153),('laravel-cache-idempotency:1:1783965180732-u0i9t8wjr','s:19:\"2026-07-13 11:53:01\";',1783965211),('laravel-cache-idempotency:1:1783965616068-wde5blgmb','s:19:\"2026-07-13 12:00:17\";',1783965647),('laravel-cache-idempotency:1:1783965616112-95zpn85c8','s:19:\"2026-07-13 12:00:17\";',1783965647),('laravel-cache-idempotency:1:1783965621621-ccbhdlp39','s:19:\"2026-07-13 12:00:21\";',1783965651),('laravel-cache-idempotency:1:1783965622004-p396hsinm','s:19:\"2026-07-13 12:00:22\";',1783965652),('laravel-cache-idempotency:1:1783965652007-y0y2ncocc','s:19:\"2026-07-13 12:00:52\";',1783965682),('laravel-cache-idempotency:1:1783965677232-ylpkqj8ru','s:19:\"2026-07-13 12:01:17\";',1783965707),('laravel-cache-idempotency:1:1783965679130-0mzywkq11','s:19:\"2026-07-13 12:01:19\";',1783965709),('laravel-cache-idempotency:1:1783965679244-s6jw7ymw5','s:19:\"2026-07-13 12:01:19\";',1783965709),('laravel-cache-idempotency:1:1783965682003-wi4qplk9x','s:19:\"2026-07-13 12:01:22\";',1783965712),('laravel-cache-idempotency:1:1783965688800-pm2xp8sn6','s:19:\"2026-07-13 12:01:29\";',1783965719),('laravel-cache-idempotency:1:1783965711999-uf82n4hu2','s:19:\"2026-07-13 12:01:52\";',1783965742),('laravel-cache-idempotency:1:1783965720228-xkf2ejnqa','s:19:\"2026-07-13 12:02:00\";',1783965750),('laravel-cache-idempotency:1:1783965725376-e82m0zeao','s:19:\"2026-07-13 12:02:05\";',1783965755),('laravel-cache-idempotency:1:1783965732035-bv8svjlaf','s:19:\"2026-07-13 12:02:12\";',1783965762),('laravel-cache-idempotency:1:1783965732036-rau30rv8a','s:19:\"2026-07-13 12:02:12\";',1783965762),('laravel-cache-idempotency:1:1783965735116-2arisabdh','s:19:\"2026-07-13 12:02:15\";',1783965765),('laravel-cache-idempotency:1:1783965735503-amtvaf38r','s:19:\"2026-07-13 12:02:15\";',1783965765),('laravel-cache-idempotency:1:1783965885043-7c14s85ug','s:19:\"2026-07-13 12:04:45\";',1783965915),('laravel-cache-idempotency:1:1783965889825-e9c70fsah','s:19:\"2026-07-13 12:04:50\";',1783965920),('laravel-cache-idempotency:1:1783965891029-elksb9e9p','s:19:\"2026-07-13 12:04:51\";',1783965921),('laravel-cache-idempotency:1:1783965892951-8i6339nj2','s:19:\"2026-07-13 12:04:53\";',1783965923),('laravel-cache-idempotency:1:1783965893575-0gzpdr0uo','s:19:\"2026-07-13 12:04:53\";',1783965923),('laravel-cache-idempotency:1:1783965894145-xr53a0wrx','s:19:\"2026-07-13 12:04:54\";',1783965924),('laravel-cache-idempotency:1:1783965896130-bqw6fcisu','s:19:\"2026-07-13 12:04:56\";',1783965926),('laravel-cache-idempotency:1:1783965900194-u4vasxul6','s:19:\"2026-07-13 12:05:00\";',1783965930),('laravel-cache-idempotency:1:1783965900497-bik5td4bi','s:19:\"2026-07-13 12:05:00\";',1783965930),('laravel-cache-idempotency:1:1783965910045-w3l8ycur8','s:19:\"2026-07-13 12:05:10\";',1783965940),('laravel-cache-idempotency:1:1783965918228-w8tcr6fo0','s:19:\"2026-07-13 12:05:18\";',1783965948),('laravel-cache-idempotency:1:1783965918229-1m7jue84c','s:19:\"2026-07-13 12:05:18\";',1783965948),('laravel-cache-idempotency:1:1783965918634-g54i58gg2','s:19:\"2026-07-13 12:05:19\";',1783965949),('laravel-cache-idempotency:1:1783965956707-mlv0ae68o','s:19:\"2026-07-13 12:05:57\";',1783965987),('laravel-cache-idempotency:1:1783965960494-orealye43','s:19:\"2026-07-13 12:06:00\";',1783965990),('laravel-cache-idempotency:1:1783965990489-c4qy50vd9','s:19:\"2026-07-13 12:06:30\";',1783966020),('laravel-cache-idempotency:1:1783966009678-bx9jafyfb','s:19:\"2026-07-13 12:06:50\";',1783966040),('laravel-cache-idempotency:1:1783966020489-ac16a835t','s:19:\"2026-07-13 12:07:00\";',1783966050),('laravel-cache-idempotency:1:1783966037308-wnwqm8hvc','s:19:\"2026-07-13 12:07:17\";',1783966067),('laravel-cache-idempotency:1:1783966048730-i29apzqqf','s:19:\"2026-07-13 12:07:29\";',1783966079),('laravel-cache-idempotency:1:1783966050485-sxkjadcyn','s:19:\"2026-07-13 12:07:30\";',1783966080),('laravel-cache-idempotency:1:1783966062685-exr0wrp4m','s:19:\"2026-07-13 12:07:42\";',1783966092),('laravel-cache-idempotency:1:1783966080485-l40uzb00x','s:19:\"2026-07-13 12:08:00\";',1783966110),('laravel-cache-idempotency:1:1783966080537-dg5nqv0q0','s:19:\"2026-07-13 12:08:01\";',1783966111),('laravel-cache-idempotency:1:1783966081684-ms1j4c3bx','s:19:\"2026-07-13 12:08:01\";',1783966111),('laravel-cache-idempotency:1:1783966093607-wxr001xh6','s:19:\"2026-07-13 12:08:13\";',1783966123),('laravel-cache-idempotency:1:1783966103909-t7fpnvup5','s:19:\"2026-07-13 12:08:24\";',1783966134),('laravel-cache-idempotency:1:1783966110479-q09yf4jwi','s:19:\"2026-07-13 12:08:30\";',1783966140),('laravel-cache-idempotency:1:1783966118845-9jge8p0g6','s:19:\"2026-07-13 12:08:39\";',1783966149),('laravel-cache-idempotency:1:1783966131677-gxz5qp2x1','s:19:\"2026-07-13 12:08:52\";',1783966162),('laravel-cache-idempotency:1:1783966140478-6vfknesvh','s:19:\"2026-07-13 12:09:00\";',1783966170),('laravel-cache-idempotency:1:1783966145360-kzo3l6o2p','s:19:\"2026-07-13 12:09:05\";',1783966175),('laravel-cache-idempotency:1:1783966146291-7ssg4xg9i','s:19:\"2026-07-13 12:09:06\";',1783966176),('laravel-cache-idempotency:1:1783966147265-lvobup50v','s:19:\"2026-07-13 12:09:07\";',1783966177),('laravel-cache-idempotency:1:1783966147429-oqi1g2yry','s:19:\"2026-07-13 12:09:08\";',1783966178),('laravel-cache-idempotency:1:1783966177286-5nzxlz6t9','s:19:\"2026-07-13 12:09:37\";',1783966207),('laravel-cache-idempotency:1:1783966177841-36ji3b124','s:19:\"2026-07-13 12:09:38\";',1783966208),('laravel-cache-idempotency:1:1783966197179-185qzg32w','s:19:\"2026-07-13 12:09:57\";',1783966227),('laravel-cache-idempotency:1:1783966197614-iaaf0p30m','s:19:\"2026-07-13 12:09:57\";',1783966227),('laravel-cache-idempotency:1:1783968483573-l9uw2g2or','s:19:\"2026-07-13 12:48:03\";',1783968513),('laravel-cache-idempotency:1:1783968483917-zrz45xtz8','s:19:\"2026-07-13 12:48:04\";',1783968514),('laravel-cache-idempotency:1:1783968484746-fso1f5m7f','s:19:\"2026-07-13 12:48:06\";',1783968516),('laravel-cache-idempotency:1:1783968496471-utj3oqp3g','s:19:\"2026-07-13 12:48:16\";',1783968526),('laravel-cache-idempotency:1:1783968543921-batpf25cb','s:19:\"2026-07-13 12:49:04\";',1783968574),('laravel-cache-idempotency:1:1783968567835-oj699c06o','s:19:\"2026-07-13 12:49:28\";',1783968598),('laravel-cache-idempotency:1:1783968571039-4b5xhyxbk','s:19:\"2026-07-13 12:49:31\";',1783968601),('laravel-cache-idempotency:1:1783968573914-xgm2i0eju','s:19:\"2026-07-13 12:49:34\";',1783968604),('laravel-cache-idempotency:1:1784049029901-jwpitjwdd','s:19:\"2026-07-14 11:10:30\";',1784049060),('laravel-cache-idempotency:1:1784049030599-28zohtp9t','s:19:\"2026-07-14 11:10:30\";',1784049060),('laravel-cache-idempotency:2:1781219371652-aq4qth4ht','s:19:\"2026-06-11 17:09:31\";',1781219401),('laravel-cache-idempotency:2:1781219373728-rfxke3gzn','s:19:\"2026-06-11 17:09:34\";',1781219404),('laravel-cache-idempotency:2:1781219468702-g573ceim2','s:19:\"2026-06-11 17:11:09\";',1781219499),('laravel-cache-idempotency:2:1781219486672-kume5qc5k','s:19:\"2026-06-11 17:11:27\";',1781219517),('laravel-cache-idempotency:2:1781219499691-7hqyh605j','s:19:\"2026-06-11 17:11:40\";',1781219530),('laravel-cache-idempotency:2:1781220832709-7x99ea2hw','s:19:\"2026-06-11 17:33:53\";',1781220863),('laravel-cache-idempotency:2:1781221519013-z4e1o3ana','s:19:\"2026-06-11 17:45:19\";',1781221549),('laravel-cache-idempotency:2:1781237084505-oe4worfzl','s:19:\"2026-06-11 22:04:45\";',1781237115),('laravel-cache-idempotency:2:1781237650522-46g8538m4','s:19:\"2026-06-11 22:14:11\";',1781237681),('laravel-cache-idempotency:2:1781238491094-01opizu9n','s:19:\"2026-06-11 22:28:11\";',1781238521),('laravel-cache-idempotency:2:1781541160891-pqi7p5n52','s:19:\"2026-06-15 10:32:41\";',1781541191),('laravel-cache-idempotency:2:1781541163128-7i94v4igp','s:19:\"2026-06-15 10:32:43\";',1781541193),('laravel-cache-idempotency:2:1781541216784-67sj2xxe7','s:19:\"2026-06-15 10:33:37\";',1781541247),('laravel-cache-idempotency:2:1781541237871-jwq3s8w0d','s:19:\"2026-06-15 10:33:58\";',1781541268),('laravel-cache-idempotency:2:1781541449701-0ogjfg013','s:19:\"2026-06-15 10:37:30\";',1781541480),('laravel-cache-idempotency:2:1781541452347-wyfebpfd2','s:19:\"2026-06-15 10:37:32\";',1781541482),('laravel-cache-idempotency:2:1781541458057-w2ljwom1c','s:19:\"2026-06-15 10:37:38\";',1781541488),('laravel-cache-idempotency:2:1781541460888-b6qrshfyt','s:19:\"2026-06-15 10:37:41\";',1781541491),('laravel-cache-idempotency:2:1781541462074-mqr9qr2gq','s:19:\"2026-06-15 10:37:42\";',1781541492),('laravel-cache-idempotency:2:1782756451544-qje9z1ej3','s:19:\"2026-06-29 12:07:31\";',1782756481),('laravel-cache-idempotency:2:1782756453366-u9lmg14sp','s:19:\"2026-06-29 12:07:33\";',1782756483),('laravel-cache-idempotency:2:1782756645738-30cdk6p0t','s:19:\"2026-06-29 12:10:47\";',1782756677),('laravel-cache-idempotency:2:1782756881338-mwbkmone9','s:19:\"2026-06-29 12:14:41\";',1782756911),('laravel-cache-idempotency:2:1782757040342-f5xn0xn7n','s:19:\"2026-06-29 12:17:21\";',1782757071),('laravel-cache-idempotency:2:1782757059511-4kvshdghm','s:19:\"2026-06-29 12:17:40\";',1782757090),('laravel-cache-idempotency:2:1782757343319-50jakchf5','s:19:\"2026-06-29 12:22:23\";',1782757373),('laravel-cache-idempotency:2:1782757351981-1pfaeu6ue','s:19:\"2026-06-29 12:22:32\";',1782757382),('laravel-cache-idempotency:2:1782759058630-vmj30nyc4','s:19:\"2026-06-29 12:50:58\";',1782759088),('laravel-cache-idempotency:2:1782760491791-522up0qqt','s:19:\"2026-06-29 13:14:53\";',1782760523),('laravel-cache-idempotency:2:1782760495831-emm1z9eht','s:19:\"2026-06-29 13:14:57\";',1782760527),('laravel-cache-idempotency:2:1782760503457-c4u8iyk8r','s:19:\"2026-06-29 13:15:04\";',1782760534),('laravel-cache-idempotency:2:1782760879933-hk4fgbeon','s:19:\"2026-06-29 13:21:20\";',1782760910),('laravel-cache-idempotency:2:1782770271517-0yhladleb','s:19:\"2026-06-29 15:57:52\";',1782770302),('laravel-cache-idempotency:2:1782997190568-zwisz89s7','s:19:\"2026-07-02 06:59:50\";',1782997220),('laravel-cache-idempotency:2:1782997193031-v8n0cf6ai','s:19:\"2026-07-02 06:59:53\";',1782997223),('laravel-cache-idempotency:2:1782997195834-50n776ip1','s:19:\"2026-07-02 06:59:56\";',1782997226),('laravel-cache-idempotency:2:1782997196165-sv22iy47k','s:19:\"2026-07-02 06:59:56\";',1782997226),('laravel-cache-idempotency:2:1783006442869-8b3io79dw','s:19:\"2026-07-02 09:34:03\";',1783006473),('laravel-cache-idempotency:2:1783006444892-a0qteazmn','s:19:\"2026-07-02 09:34:05\";',1783006475),('laravel-cache-idempotency:2:1783006473270-p2ub2f7st','s:19:\"2026-07-02 09:34:33\";',1783006503),('laravel-cache-idempotency:2:1783006494014-i9j2xngq2','s:19:\"2026-07-02 09:34:54\";',1783006524),('laravel-cache-idempotency:2:1783006494494-t026xkfyv','s:19:\"2026-07-02 09:34:54\";',1783006524),('laravel-cache-idempotency:2:1783006527185-t7f0ne4u1','s:19:\"2026-07-02 09:35:27\";',1783006557),('laravel-cache-idempotency:2:1783006529291-7c5r68nmz','s:19:\"2026-07-02 09:35:29\";',1783006559),('laravel-cache-idempotency:2:1783006826948-hnc2nrwt2','s:19:\"2026-07-02 09:40:27\";',1783006857),('laravel-cache-idempotency:2:1783010790107-0t342qhxb','s:19:\"2026-07-02 10:46:30\";',1783010820),('laravel-cache-idempotency:2:1783010792131-u5bjs72us','s:19:\"2026-07-02 10:46:32\";',1783010822),('laravel-cache-idempotency:2:1783131621493-9pyxyurke','s:19:\"2026-07-03 20:20:21\";',1783131651),('laravel-cache-idempotency:2:1783131624327-215cgix2q','s:19:\"2026-07-03 20:20:24\";',1783131654),('laravel-cache-idempotency:2:1783131629184-qqu4la0xf','s:19:\"2026-07-03 20:20:29\";',1783131659),('laravel-cache-idempotency:2:1783131651839-mgl8ng7fs','s:19:\"2026-07-03 20:20:52\";',1783131682),('laravel-cache-idempotency:2:1783131660433-tnaxvaz9g','s:19:\"2026-07-03 20:21:00\";',1783131690),('laravel-cache-idempotency:2:1783131714078-uy1icx41y','s:19:\"2026-07-03 20:21:54\";',1783131744),('laravel-cache-idempotency:2:1783131714221-ewt58shuq','s:19:\"2026-07-03 20:21:54\";',1783131744),('laravel-cache-idempotency:2:1783131716406-160gwz9g4','s:19:\"2026-07-03 20:21:56\";',1783131746),('laravel-cache-idempotency:2:1783131721545-6x9r6j21k','s:19:\"2026-07-03 20:22:01\";',1783131751),('laravel-cache-idempotency:2:1783131756860-k0mue7wa2','s:19:\"2026-07-03 20:22:37\";',1783131787),('laravel-cache-idempotency:2:1783131759007-76o84khwr','s:19:\"2026-07-03 20:22:39\";',1783131789),('laravel-cache-idempotency:2:1783132248901-03b6clpnl','s:19:\"2026-07-03 20:30:49\";',1783132279),('laravel-cache-idempotency:2:1783132249231-ct8d9jsn8','s:19:\"2026-07-03 20:30:49\";',1783132279),('laravel-cache-idempotency:2:1783132251753-2ads4zu4t','s:19:\"2026-07-03 20:30:52\";',1783132282),('laravel-cache-idempotency:2:1783132257449-2qpwmkubh','s:19:\"2026-07-03 20:30:57\";',1783132287),('laravel-cache-idempotency:2:1783132262460-il46yrpo8','s:19:\"2026-07-03 20:31:02\";',1783132292),('laravel-cache-idempotency:2:1783132264701-2y9q0l7tq','s:19:\"2026-07-03 20:31:05\";',1783132295),('laravel-cache-idempotency:2:1783132264762-edailk6gw','s:19:\"2026-07-03 20:31:05\";',1783132295),('laravel-cache-idempotency:2:1783132279270-qillvb28a','s:19:\"2026-07-03 20:31:19\";',1783132309),('laravel-cache-idempotency:2:1783132279271-02prmt7sz','s:19:\"2026-07-03 20:31:19\";',1783132309),('laravel-cache-idempotency:2:1783132280096-ss9m81ey8','s:19:\"2026-07-03 20:31:20\";',1783132310),('laravel-cache-idempotency:2:1783132301749-k60msbp83','s:19:\"2026-07-03 20:31:42\";',1783132332),('laravel-cache-idempotency:2:1783132309235-6jydf14n6','s:19:\"2026-07-03 20:31:49\";',1783132339),('laravel-cache-idempotency:2:1783132309786-cyqwwo1gy','s:19:\"2026-07-03 20:31:50\";',1783132340),('laravel-cache-idempotency:2:1783132437552-ivw7bzdbt','s:19:\"2026-07-03 20:33:57\";',1783132467),('laravel-cache-idempotency:2:1783132437868-e2hmvqixv','s:19:\"2026-07-03 20:33:58\";',1783132468),('laravel-cache-idempotency:2:1783132441346-rfo8xr1t7','s:19:\"2026-07-03 20:34:01\";',1783132471),('laravel-cache-idempotency:2:1783132441370-cy0eza1wl','s:19:\"2026-07-03 20:34:01\";',1783132471),('laravel-cache-idempotency:2:1783132446174-artimmalb','s:19:\"2026-07-03 20:34:06\";',1783132476);
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` bigint(20) NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `caja_movimientos`
--

DROP TABLE IF EXISTS `caja_movimientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `caja_movimientos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tipo` varchar(255) NOT NULL,
  `monto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `concepto` varchar(255) DEFAULT NULL,
  `referencia_tipo` varchar(255) DEFAULT NULL,
  `referencia_id` bigint(20) unsigned DEFAULT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `caja_movimientos_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `caja_movimientos_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `caja_movimientos`
--

LOCK TABLES `caja_movimientos` WRITE;
/*!40000 ALTER TABLE `caja_movimientos` DISABLE KEYS */;
INSERT INTO `caja_movimientos` VALUES (1,'ingreso',9040.00,'Venta VTA-20260522-0001','venta',1,1,'2026-05-22 23:53:11'),(2,'ingreso',18080.00,'Venta VTA-20260529-0001','venta',2,1,'2026-05-30 01:28:26'),(3,'ingreso',18080.00,'Venta VTA-20260529-0002','venta',3,1,'2026-05-30 01:28:26'),(4,'ingreso',9040.00,'Venta VTA-20260605-0001','venta',5,1,'2026-06-05 08:40:36'),(5,'ingreso',5085.00,'Venta VTA-20260605-0002','venta',6,1,'2026-06-05 08:44:14'),(6,'ingreso',5085.00,'Venta VTA-20260605-0003','venta',7,1,'2026-06-05 08:50:20'),(7,'ingreso',18080.00,'Venta VTA-20260605-0004','venta',8,1,'2026-06-05 08:55:33');
/*!40000 ALTER TABLE `caja_movimientos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `caja_retiros`
--

DROP TABLE IF EXISTS `caja_retiros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `caja_retiros` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `sesion_id` bigint(20) unsigned NOT NULL,
  `usuario_id` bigint(20) unsigned NOT NULL,
  `monto` decimal(12,2) NOT NULL,
  `motivo` varchar(255) DEFAULT NULL,
  `notas` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `caja_retiros_sesion_id_foreign` (`sesion_id`),
  KEY `caja_retiros_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `caja_retiros_sesion_id_foreign` FOREIGN KEY (`sesion_id`) REFERENCES `caja_sesiones` (`id`) ON DELETE CASCADE,
  CONSTRAINT `caja_retiros_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `caja_retiros`
--

LOCK TABLES `caja_retiros` WRITE;
/*!40000 ALTER TABLE `caja_retiros` DISABLE KEYS */;
/*!40000 ALTER TABLE `caja_retiros` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `caja_sesiones`
--

DROP TABLE IF EXISTS `caja_sesiones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `caja_sesiones` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `caja_id` bigint(20) unsigned NOT NULL,
  `usuario_id` bigint(20) unsigned NOT NULL,
  `monto_apertura` decimal(12,2) NOT NULL DEFAULT 0.00,
  `monto_cierre` decimal(12,2) DEFAULT NULL,
  `monto_esperado` decimal(12,2) DEFAULT NULL,
  `diferencia` decimal(12,2) DEFAULT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'abierta',
  `apertura_at` timestamp NULL DEFAULT NULL,
  `cierre_at` timestamp NULL DEFAULT NULL,
  `notas_cierre` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `caja_sesiones_caja_id_foreign` (`caja_id`),
  KEY `caja_sesiones_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `caja_sesiones_caja_id_foreign` FOREIGN KEY (`caja_id`) REFERENCES `cajas` (`id`) ON DELETE CASCADE,
  CONSTRAINT `caja_sesiones_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `caja_sesiones`
--

LOCK TABLES `caja_sesiones` WRITE;
/*!40000 ALTER TABLE `caja_sesiones` DISABLE KEYS */;
INSERT INTO `caja_sesiones` VALUES (1,1,1,50000.00,50000.00,50000.00,0.00,'cerrada','2026-05-22 23:49:06','2026-05-22 23:49:35','No se vendio','2026-05-22 23:49:06','2026-05-22 23:49:35'),(2,1,1,50000.00,50000.00,50000.00,0.00,'cerrada','2026-05-30 01:28:27','2026-06-02 06:46:00',NULL,'2026-05-30 01:28:27','2026-06-02 06:46:00'),(3,1,1,50000.00,50000.00,50000.00,0.00,'cerrada','2026-06-12 04:17:13','2026-06-12 04:58:07',NULL,'2026-06-12 04:17:13','2026-06-12 04:58:07'),(4,1,1,50000.00,42000.00,50000.00,-8000.00,'cerrada','2026-06-15 16:12:14','2026-06-29 18:55:04',NULL,'2026-06-15 16:12:14','2026-06-29 18:55:04'),(5,1,1,5000.00,5000.00,5000.00,0.00,'cerrada','2026-06-29 21:53:03','2026-06-29 21:53:10',NULL,'2026-06-29 21:53:03','2026-06-29 21:53:10');
/*!40000 ALTER TABLE `caja_sesiones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cajas`
--

DROP TABLE IF EXISTS `cajas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cajas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `ubicacion_id` bigint(20) unsigned DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cajas_ubicacion_id_foreign` (`ubicacion_id`),
  KEY `cajas_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `cajas_ubicacion_id_foreign` FOREIGN KEY (`ubicacion_id`) REFERENCES `ubicaciones` (`id`) ON DELETE SET NULL,
  CONSTRAINT `cajas_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cajas`
--

LOCK TABLES `cajas` WRITE;
/*!40000 ALTER TABLE `cajas` DISABLE KEYS */;
INSERT INTO `cajas` VALUES (1,'Caja principal',1,1,'2026-05-22 23:48:48','2026-05-22 23:48:48',NULL),(2,'Caja Principal',2,1,'2026-06-11 22:02:32','2026-06-11 22:02:32',1);
/*!40000 ALTER TABLE `cajas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campanas_email`
--

DROP TABLE IF EXISTS `campanas_email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campanas_email` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `asunto` varchar(255) NOT NULL,
  `contenido_html` text DEFAULT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'borrador',
  `enviados` int(11) NOT NULL DEFAULT 0,
  `abiertos` int(11) NOT NULL DEFAULT 0,
  `clicks` int(11) NOT NULL DEFAULT 0,
  `enviado_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campanas_email`
--

LOCK TABLES `campanas_email` WRITE;
/*!40000 ALTER TABLE `campanas_email` DISABLE KEYS */;
/*!40000 ALTER TABLE `campanas_email` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categorias` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `color` varchar(255) DEFAULT NULL,
  `icono` varchar(255) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
INSERT INTO `categorias` VALUES (1,'Ropa',NULL,'#3bf796',NULL,1);
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_mensajes`
--

DROP TABLE IF EXISTS `chat_mensajes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chat_mensajes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `chat_id` bigint(20) unsigned NOT NULL,
  `usuario_id` bigint(20) unsigned NOT NULL,
  `contenido` text NOT NULL,
  `archivo_url` varchar(255) DEFAULT NULL,
  `archivo_nombre` varchar(255) DEFAULT NULL,
  `archivo_tipo` varchar(255) DEFAULT NULL,
  `archivo_size` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `chat_mensajes_chat_id_foreign` (`chat_id`),
  KEY `chat_mensajes_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `chat_mensajes_chat_id_foreign` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chat_mensajes_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_mensajes`
--

LOCK TABLES `chat_mensajes` WRITE;
/*!40000 ALTER TABLE `chat_mensajes` DISABLE KEYS */;
INSERT INTO `chat_mensajes` VALUES (12,5,1,'Como estas',NULL,NULL,NULL,NULL,'2026-06-11 23:11:32'),(13,5,1,'','chat_adjuntos/cb28f88f-df5e-455d-b18d-6d20231992f1.jpg','SaveClip.App_660518487_18183044797379150_6705360117344007585_n.jpg','image/jpeg',120035,'2026-06-11 23:12:00'),(14,5,1,'','chat_adjuntos/27ac97bd-fc6a-4fb8-93f5-1c3ec8950ef8.jpg','SaveClip.App_623547804_18099155842859258_4775479409922334502_n.jpg','image/jpeg',111635,'2026-06-11 23:32:34'),(15,5,1,'','chat_adjuntos/61faa57d-8fbf-4ffe-a07f-b6040040acc3.webp','Ni-Cafe-Molido-1820-Arabica-400Gr-2-7746.webp','image/webp',295646,'2026-06-11 23:36:27'),(16,6,1,'','chat_adjuntos/a11b8703-2369-4fd2-879a-d7a3c420f843.jpg','Categoria3.jpg','image/jpeg',314600,'2026-06-12 04:15:11'),(17,6,1,'Hola buenos dias, tenemos reunion hoy a las 10',NULL,NULL,NULL,NULL,'2026-06-15 16:33:50');
/*!40000 ALTER TABLE `chat_mensajes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_participantes`
--

DROP TABLE IF EXISTS `chat_participantes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chat_participantes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `chat_id` bigint(20) unsigned NOT NULL,
  `usuario_id` bigint(20) unsigned NOT NULL,
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_read_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chat_participantes_chat_id_usuario_id_unique` (`chat_id`,`usuario_id`),
  KEY `chat_participantes_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `chat_participantes_chat_id_foreign` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chat_participantes_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_participantes`
--

LOCK TABLES `chat_participantes` WRITE;
/*!40000 ALTER TABLE `chat_participantes` DISABLE KEYS */;
INSERT INTO `chat_participantes` VALUES (9,5,3,'2026-06-11 23:11:21',NULL),(10,5,1,'2026-06-11 23:11:21','2026-06-11 23:41:42'),(11,6,2,'2026-06-12 04:14:57','2026-06-15 16:33:58'),(12,6,1,'2026-06-12 04:14:57','2026-06-15 16:33:30'),(13,7,2,'2026-07-04 02:43:38',NULL),(14,7,1,'2026-07-04 02:43:38','2026-07-04 23:25:32');
/*!40000 ALTER TABLE `chat_participantes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chats`
--

DROP TABLE IF EXISTS `chats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chats` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `titulo` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `creador_id` bigint(20) unsigned NOT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'abierto',
  `cerrado_por` bigint(20) unsigned DEFAULT NULL,
  `cerrado_en` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `chats_creador_id_foreign` (`creador_id`),
  KEY `chats_cerrado_por_foreign` (`cerrado_por`),
  CONSTRAINT `chats_cerrado_por_foreign` FOREIGN KEY (`cerrado_por`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  CONSTRAINT `chats_creador_id_foreign` FOREIGN KEY (`creador_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chats`
--

LOCK TABLES `chats` WRITE;
/*!40000 ALTER TABLE `chats` DISABLE KEYS */;
INSERT INTO `chats` VALUES (5,'Hola','DDD',1,'cerrado',1,'2026-06-11 23:41:54','2026-06-11 23:11:21','2026-06-11 23:41:54'),(6,'Reunion',NULL,1,'cerrado',1,'2026-06-15 16:35:07','2026-06-12 04:14:57','2026-06-15 16:35:07'),(7,'das',NULL,1,'abierto',NULL,NULL,'2026-07-04 02:43:38','2026-07-04 02:43:38');
/*!40000 ALTER TABLE `chats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cliente_categorias`
--

DROP TABLE IF EXISTS `cliente_categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cliente_categorias` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `color` varchar(20) DEFAULT '#3b82f6',
  `icono` varchar(255) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente_categorias`
--

LOCK TABLES `cliente_categorias` WRITE;
/*!40000 ALTER TABLE `cliente_categorias` DISABLE KEYS */;
INSERT INTO `cliente_categorias` VALUES (1,'Frecuente',NULL,'#3b82f6',NULL,1,'2026-06-11 19:51:17','2026-06-11 19:51:17');
/*!40000 ALTER TABLE `cliente_categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cliente_etiquetas`
--

DROP TABLE IF EXISTS `cliente_etiquetas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cliente_etiquetas` (
  `cliente_id` bigint(20) unsigned NOT NULL,
  `etiqueta_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`cliente_id`,`etiqueta_id`),
  KEY `cliente_etiquetas_etiqueta_id_foreign` (`etiqueta_id`),
  CONSTRAINT `cliente_etiquetas_cliente_id_foreign` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cliente_etiquetas_etiqueta_id_foreign` FOREIGN KEY (`etiqueta_id`) REFERENCES `etiquetas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente_etiquetas`
--

LOCK TABLES `cliente_etiquetas` WRITE;
/*!40000 ALTER TABLE `cliente_etiquetas` DISABLE KEYS */;
INSERT INTO `cliente_etiquetas` VALUES (1,1);
/*!40000 ALTER TABLE `cliente_etiquetas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cliente_notas`
--

DROP TABLE IF EXISTS `cliente_notas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cliente_notas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `cliente_id` bigint(20) unsigned NOT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `tipo` varchar(255) DEFAULT NULL,
  `contenido` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cliente_notas_cliente_id_foreign` (`cliente_id`),
  KEY `cliente_notas_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `cliente_notas_cliente_id_foreign` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cliente_notas_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente_notas`
--

LOCK TABLES `cliente_notas` WRITE;
/*!40000 ALTER TABLE `cliente_notas` DISABLE KEYS */;
INSERT INTO `cliente_notas` VALUES (1,4,1,'nota','hola',NULL);
/*!40000 ALTER TABLE `cliente_notas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `clientes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `cedula` varchar(255) DEFAULT NULL,
  `empresa` varchar(150) DEFAULT NULL,
  `cedula_juridica` varchar(50) DEFAULT NULL,
  `telefono` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `ciudad` varchar(100) DEFAULT NULL,
  `pais` varchar(100) DEFAULT NULL,
  `clasificacion` varchar(50) DEFAULT 'regular',
  `datos_fiscales` varchar(500) DEFAULT NULL,
  `credito_tienda` decimal(12,2) DEFAULT 0.00,
  `notas` varchar(500) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `puntos_acumulados` int(11) NOT NULL DEFAULT 0,
  `puntos_canjeados` int(11) NOT NULL DEFAULT 0,
  `portal_activo` tinyint(1) NOT NULL DEFAULT 0,
  `origen` varchar(255) DEFAULT NULL,
  `lat` decimal(10,7) DEFAULT NULL,
  `lng` decimal(10,7) DEFAULT NULL,
  `total_compras` decimal(12,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `cliente_categoria_id` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `clientes_cliente_categoria_id_foreign` (`cliente_categoria_id`),
  CONSTRAINT `clientes_cliente_categoria_id_foreign` FOREIGN KEY (`cliente_categoria_id`) REFERENCES `cliente_categorias` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
INSERT INTO `clientes` VALUES (1,'Jose Hernandez','512341234',NULL,NULL,'88778877',NULL,NULL,NULL,NULL,NULL,'regular',NULL,0.00,NULL,1,0,0,0,NULL,NULL,NULL,0.00,'2026-06-03 22:35:50','2026-06-03 22:35:50',NULL),(4,'Daniel Morales','234534534',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Frecuente',NULL,0.00,'Hola esta pendiente',1,0,0,0,NULL,NULL,NULL,0.00,'2026-06-11 19:47:37','2026-07-13 17:29:39',1);
/*!40000 ALTER TABLE `clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `combo_productos`
--

DROP TABLE IF EXISTS `combo_productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `combo_productos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `combo_id` bigint(20) unsigned NOT NULL,
  `producto_id` bigint(20) unsigned NOT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `combo_productos_combo_id_foreign` (`combo_id`),
  KEY `combo_productos_producto_id_foreign` (`producto_id`),
  CONSTRAINT `combo_productos_combo_id_foreign` FOREIGN KEY (`combo_id`) REFERENCES `combos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `combo_productos_producto_id_foreign` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `combo_productos`
--

LOCK TABLES `combo_productos` WRITE;
/*!40000 ALTER TABLE `combo_productos` DISABLE KEYS */;
/*!40000 ALTER TABLE `combo_productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `combos`
--

DROP TABLE IF EXISTS `combos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `combos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `precio_combo` decimal(12,2) NOT NULL,
  `ahorro_total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `precio_normal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `precio_regular` decimal(12,2) NOT NULL DEFAULT 0.00,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `combos`
--

LOCK TABLES `combos` WRITE;
/*!40000 ALTER TABLE `combos` DISABLE KEYS */;
/*!40000 ALTER TABLE `combos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `compra_detalle`
--

DROP TABLE IF EXISTS `compra_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `compra_detalle` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `compra_id` bigint(20) unsigned NOT NULL,
  `producto_id` bigint(20) unsigned NOT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 1,
  `precio_unitario` decimal(12,2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `compra_detalle_compra_id_foreign` (`compra_id`),
  KEY `compra_detalle_producto_id_foreign` (`producto_id`),
  CONSTRAINT `compra_detalle_compra_id_foreign` FOREIGN KEY (`compra_id`) REFERENCES `compras` (`id`) ON DELETE CASCADE,
  CONSTRAINT `compra_detalle_producto_id_foreign` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compra_detalle`
--

LOCK TABLES `compra_detalle` WRITE;
/*!40000 ALTER TABLE `compra_detalle` DISABLE KEYS */;
INSERT INTO `compra_detalle` VALUES (1,1,1,10,2000.00,20000.00,'2026-06-15 16:22:34');
/*!40000 ALTER TABLE `compra_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `compras`
--

DROP TABLE IF EXISTS `compras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `compras` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `numero_compra` varchar(255) DEFAULT NULL,
  `proveedor_id` bigint(20) unsigned DEFAULT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `impuesto_total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `estado` varchar(255) NOT NULL DEFAULT 'pendiente',
  `fecha_compra` date DEFAULT NULL,
  `fecha_entrega` date DEFAULT NULL,
  `factura_proveedor` varchar(255) DEFAULT NULL,
  `archivo_factura` varchar(255) DEFAULT NULL,
  `notas` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `compras_numero_compra_unique` (`numero_compra`),
  KEY `compras_proveedor_id_foreign` (`proveedor_id`),
  KEY `compras_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `compras_proveedor_id_foreign` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedores` (`id`) ON DELETE SET NULL,
  CONSTRAINT `compras_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `compras`
--

LOCK TABLES `compras` WRITE;
/*!40000 ALTER TABLE `compras` DISABLE KEYS */;
INSERT INTO `compras` VALUES (1,'OC-20260615-0001',1,1,20000.00,0.00,20000.00,'recibida','2026-06-15','2026-06-15',NULL,NULL,NULL,'2026-06-15 16:22:34','2026-06-15 16:22:36');
/*!40000 ALTER TABLE `compras` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `configuracion`
--

DROP TABLE IF EXISTS `configuracion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `configuracion` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `clave` varchar(255) NOT NULL,
  `valor` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `configuracion_clave_unique` (`clave`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `configuracion`
--

LOCK TABLES `configuracion` WRITE;
/*!40000 ALTER TABLE `configuracion` DISABLE KEYS */;
INSERT INTO `configuracion` VALUES (1,'tasa_usd','520','2026-06-11 20:21:38','2026-07-04 01:04:29'),(2,'idioma','es','2026-06-29 19:11:09','2026-07-04 01:04:29'),(3,'tasa_eur','570','2026-06-11 20:21:38','2026-07-04 01:04:29'),(4,'divisa','CRC','2026-06-12 04:53:42','2026-07-04 01:04:29'),(5,'nombre_negocio','Pepito Shopy',NULL,'2026-07-04 01:04:29'),(6,'telefono','70594071',NULL,'2026-07-04 01:04:29'),(7,'direccion','https://dj-custom.website/',NULL,'2026-07-04 01:04:29'),(8,'moneda',NULL,NULL,'2026-07-04 01:04:29'),(9,'simbolo_moneda',NULL,NULL,'2026-07-04 01:04:29'),(10,'impuesto_default','15',NULL,'2026-07-04 01:04:29'),(11,'ticket_footer',NULL,NULL,'2026-07-04 01:04:29'),(12,'sinpe_numero','88888888',NULL,'2026-07-04 01:04:29'),(13,'email_negocio','dj.custom.contact@gmail.com',NULL,'2026-07-04 01:04:29'),(14,'email_remitente','dj.custom.contact@gmail.com',NULL,'2026-07-04 01:04:29'),(15,'cedula_juridica',NULL,NULL,'2026-07-04 01:04:29'),(16,'logo_path',NULL,NULL,'2026-07-04 01:04:29'),(17,'website',NULL,NULL,'2026-07-04 01:04:29'),(18,'requerir_caja_abierta','1',NULL,'2026-07-04 01:04:29'),(19,'smtp_host','smtp.gmail.com','2026-07-04 00:47:54','2026-07-04 01:04:29'),(20,'smtp_port','587','2026-07-04 00:47:54','2026-07-04 01:04:29'),(21,'smtp_username','transjym1@gmail.com','2026-07-04 00:47:54','2026-07-04 01:04:29'),(22,'smtp_password','zjkxdvnqbrwduxph','2026-07-04 00:47:54','2026-07-04 01:04:29'),(23,'smtp_encryption','tls','2026-07-04 00:47:54','2026-07-04 01:04:29'),(24,'smtp_activo','1','2026-07-04 00:47:54','2026-07-04 01:04:29');
/*!40000 ALTER TABLE `configuracion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cotizacion_configuracion`
--

DROP TABLE IF EXISTS `cotizacion_configuracion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cotizacion_configuracion` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL DEFAULT 'default',
  `ancho_mm` int(11) NOT NULL DEFAULT 80,
  `tamano_papel` varchar(20) NOT NULL DEFAULT 'A4',
  `orientacion` varchar(20) NOT NULL DEFAULT 'portrait',
  `estilo_layout` varchar(30) NOT NULL DEFAULT 'moderno',
  `fuente` varchar(100) NOT NULL DEFAULT 'Courier New',
  `fuente_size` int(11) NOT NULL DEFAULT 12,
  `logo_path` varchar(255) DEFAULT NULL,
  `logo_x` int(11) NOT NULL DEFAULT 0,
  `logo_y` int(11) NOT NULL DEFAULT 0,
  `logo_width` int(11) NOT NULL DEFAULT 200,
  `mostrar_logo` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_nombre_negocio` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_direccion` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_telefono` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_cedula` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_vendedor` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_cliente` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_fecha` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_fecha_vencimiento` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_detalle_impuesto` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_descuento` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_condiciones` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_notas` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_codigo_producto` tinyint(1) NOT NULL DEFAULT 0,
  `mostrar_validez` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_subtitulo` tinyint(1) NOT NULL DEFAULT 1,
  `subtitulo_text` varchar(255) NOT NULL DEFAULT 'Cotización Profesional',
  `mostrar_lineas_firma` tinyint(1) NOT NULL DEFAULT 1,
  `texto_firma_cliente` varchar(100) NOT NULL DEFAULT 'Firma del Cliente',
  `texto_firma_empresa` varchar(100) NOT NULL DEFAULT 'Firma Autorizada',
  `mostrar_marca_agua` tinyint(1) NOT NULL DEFAULT 0,
  `marca_agua_texto` varchar(100) NOT NULL DEFAULT 'COTIZACIÓN',
  `mostrar_info_bancaria` tinyint(1) NOT NULL DEFAULT 0,
  `info_bancaria` text DEFAULT NULL,
  `mostrar_totales_desglosados` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_numero_pagina` tinyint(1) NOT NULL DEFAULT 0,
  `header_text` text DEFAULT NULL,
  `footer_text` text DEFAULT NULL,
  `condiciones_default` text DEFAULT NULL,
  `notas_default` text DEFAULT NULL,
  `texto_terminos` text DEFAULT NULL,
  `estilos_custom` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`estilos_custom`)),
  `color_fondo` varchar(7) NOT NULL DEFAULT '#ffffff',
  `color_texto` varchar(7) NOT NULL DEFAULT '#000000',
  `color_acento` varchar(7) NOT NULL DEFAULT '#000000',
  `color_encabezado` varchar(7) NOT NULL DEFAULT '#01234e',
  `color_borde` varchar(7) NOT NULL DEFAULT '#01234e',
  `padding_general` int(11) NOT NULL DEFAULT 10,
  `borde_redondeado` int(11) NOT NULL DEFAULT 0,
  `mostrar_separadores` tinyint(1) NOT NULL DEFAULT 1,
  `formato_moneda` varchar(10) NOT NULL DEFAULT '₡',
  `elementos_orden` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`elementos_orden`)),
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cotizacion_configuracion`
--

LOCK TABLES `cotizacion_configuracion` WRITE;
/*!40000 ALTER TABLE `cotizacion_configuracion` DISABLE KEYS */;
INSERT INTO `cotizacion_configuracion` VALUES (1,'default',80,'A4','portrait','moderno','Helvetica',12,'cotizacion-logos/V8oGBxSYa0kT1ncC8SfgBhtvkLax1kvDXLKxvvXR.png',0,0,200,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,'Cotización Profesional',1,'Firma del Cliente','Firma Autorizada',0,'COTIZACIÓN',0,NULL,1,0,NULL,'¡Gracias por su preferencia!',NULL,NULL,NULL,NULL,'#ffffff','#000000','#000000','#01234e','#01234e',10,0,1,'₡',NULL,1,'2026-06-04 04:29:36','2026-06-04 04:39:54');
/*!40000 ALTER TABLE `cotizacion_configuracion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cotizacion_detalle`
--

DROP TABLE IF EXISTS `cotizacion_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cotizacion_detalle` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `cotizacion_id` bigint(20) unsigned NOT NULL,
  `producto_id` bigint(20) unsigned NOT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 1,
  `precio_unitario` decimal(12,2) NOT NULL DEFAULT 0.00,
  `descuento` decimal(12,2) NOT NULL DEFAULT 0.00,
  `impuesto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cotizacion_detalle_cotizacion_id_foreign` (`cotizacion_id`),
  KEY `cotizacion_detalle_producto_id_foreign` (`producto_id`),
  CONSTRAINT `cotizacion_detalle_cotizacion_id_foreign` FOREIGN KEY (`cotizacion_id`) REFERENCES `cotizaciones` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cotizacion_detalle_producto_id_foreign` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cotizacion_detalle`
--

LOCK TABLES `cotizacion_detalle` WRITE;
/*!40000 ALTER TABLE `cotizacion_detalle` DISABLE KEYS */;
INSERT INTO `cotizacion_detalle` VALUES (1,1,1,1,8000.00,0.00,1040.00,8000.00,'2026-05-22 23:55:51'),(2,2,1,2,8000.00,0.00,2080.00,16000.00,'2026-06-04 05:00:31'),(3,3,1,3,8000.00,0.00,3120.00,24000.00,'2026-06-12 04:22:48'),(4,4,1,1,8000.00,0.00,1040.00,8000.00,'2026-06-15 16:54:46'),(5,5,2,1,4500.00,0.00,585.00,4500.00,'2026-06-15 16:56:50');
/*!40000 ALTER TABLE `cotizacion_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cotizaciones`
--

DROP TABLE IF EXISTS `cotizaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cotizaciones` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `numero_cotizacion` varchar(255) DEFAULT NULL,
  `cliente_id` bigint(20) unsigned DEFAULT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `descuento_total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `impuesto_total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `estado` varchar(255) NOT NULL DEFAULT 'borrador',
  `estado_aprobacion` varchar(20) NOT NULL DEFAULT 'pendiente',
  `fecha_vencimiento` date DEFAULT NULL,
  `condiciones` text DEFAULT NULL,
  `notas` text DEFAULT NULL,
  `venta_id` bigint(20) unsigned DEFAULT NULL,
  `pedido_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `aprobado_en` timestamp NULL DEFAULT NULL,
  `aprobado_por` bigint(20) unsigned DEFAULT NULL,
  `motivo_rechazo` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cotizaciones_numero_cotizacion_unique` (`numero_cotizacion`),
  KEY `cotizaciones_cliente_id_foreign` (`cliente_id`),
  KEY `cotizaciones_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `cotizaciones_cliente_id_foreign` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE SET NULL,
  CONSTRAINT `cotizaciones_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cotizaciones`
--

LOCK TABLES `cotizaciones` WRITE;
/*!40000 ALTER TABLE `cotizaciones` DISABLE KEYS */;
INSERT INTO `cotizaciones` VALUES (1,'COT-20260522-0001',NULL,1,8000.00,0.00,1040.00,9040.00,'facturada','aprobada','2026-05-29',NULL,'Producto prueba',NULL,NULL,'2026-05-22 23:55:51','2026-06-04 00:57:07','2026-06-04 00:55:02',1,NULL),(2,'COT-20260603-0001',1,1,16000.00,0.00,2080.00,18080.00,'rechazada','rechazada','2026-06-27',NULL,'lol',NULL,NULL,'2026-06-04 05:00:31','2026-06-05 08:58:21',NULL,NULL,'S'),(3,'COT-20260611-0001',1,1,24000.00,0.00,3120.00,27120.00,'rechazada','rechazada','2026-06-19',NULL,'sdas',NULL,NULL,'2026-06-12 04:22:48','2026-06-12 04:23:22',NULL,NULL,'No se'),(4,'COT-20260615-0001',1,1,8000.00,0.00,1040.00,9040.00,'facturada','aprobada',NULL,NULL,'No se aceptan devoluciones',NULL,NULL,'2026-06-15 16:54:46','2026-06-15 16:55:57','2026-06-15 16:55:55',1,NULL),(5,'COT-20260615-0002',1,1,4500.00,0.00,585.00,5085.00,'facturada','aprobada','2026-06-30',NULL,'...',NULL,NULL,'2026-06-15 16:56:50','2026-06-15 16:57:44','2026-06-15 16:57:25',1,NULL);
/*!40000 ALTER TABLE `cotizaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_actividades`
--

DROP TABLE IF EXISTS `crm_actividades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crm_actividades` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `oportunidad_id` bigint(20) unsigned DEFAULT NULL,
  `cliente_id` bigint(20) unsigned DEFAULT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `tipo` varchar(50) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha_programada` timestamp NULL DEFAULT NULL,
  `fecha_completada` timestamp NULL DEFAULT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'pendiente',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `crm_actividades_oportunidad_id_foreign` (`oportunidad_id`),
  KEY `crm_actividades_cliente_id_foreign` (`cliente_id`),
  KEY `crm_actividades_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `crm_actividades_cliente_id_foreign` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE SET NULL,
  CONSTRAINT `crm_actividades_oportunidad_id_foreign` FOREIGN KEY (`oportunidad_id`) REFERENCES `crm_oportunidades` (`id`) ON DELETE CASCADE,
  CONSTRAINT `crm_actividades_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_actividades`
--

LOCK TABLES `crm_actividades` WRITE;
/*!40000 ALTER TABLE `crm_actividades` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_actividades` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_etapas`
--

DROP TABLE IF EXISTS `crm_etapas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crm_etapas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `color` varchar(7) NOT NULL DEFAULT '#3b82f6',
  `orden` int(11) NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_etapas`
--

LOCK TABLES `crm_etapas` WRITE;
/*!40000 ALTER TABLE `crm_etapas` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_etapas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `crm_oportunidades`
--

DROP TABLE IF EXISTS `crm_oportunidades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `crm_oportunidades` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `titulo` varchar(255) NOT NULL,
  `cliente_id` bigint(20) unsigned DEFAULT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `etapa_id` bigint(20) unsigned DEFAULT NULL,
  `valor_estimado` decimal(14,2) NOT NULL DEFAULT 0.00,
  `probabilidad` int(11) NOT NULL DEFAULT 50,
  `fecha_cierre_estimada` date DEFAULT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'abierta',
  `notas` text DEFAULT NULL,
  `origen` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `crm_oportunidades_cliente_id_foreign` (`cliente_id`),
  KEY `crm_oportunidades_usuario_id_foreign` (`usuario_id`),
  KEY `crm_oportunidades_etapa_id_foreign` (`etapa_id`),
  KEY `crm_oportunidades_estado_index` (`estado`),
  CONSTRAINT `crm_oportunidades_cliente_id_foreign` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE SET NULL,
  CONSTRAINT `crm_oportunidades_etapa_id_foreign` FOREIGN KEY (`etapa_id`) REFERENCES `crm_etapas` (`id`) ON DELETE SET NULL,
  CONSTRAINT `crm_oportunidades_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `crm_oportunidades`
--

LOCK TABLES `crm_oportunidades` WRITE;
/*!40000 ALTER TABLE `crm_oportunidades` DISABLE KEYS */;
/*!40000 ALTER TABLE `crm_oportunidades` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cuentas_cobrar`
--

DROP TABLE IF EXISTS `cuentas_cobrar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cuentas_cobrar` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `cliente_id` bigint(20) unsigned NOT NULL,
  `venta_id` bigint(20) unsigned DEFAULT NULL,
  `monto_total` decimal(12,2) NOT NULL,
  `monto_pagado` decimal(12,2) NOT NULL DEFAULT 0.00,
  `saldo_pendiente` decimal(12,2) NOT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'pendiente',
  `notas` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cuentas_cobrar_cliente_id_foreign` (`cliente_id`),
  KEY `cuentas_cobrar_venta_id_foreign` (`venta_id`),
  CONSTRAINT `cuentas_cobrar_cliente_id_foreign` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cuentas_cobrar_venta_id_foreign` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cuentas_cobrar`
--

LOCK TABLES `cuentas_cobrar` WRITE;
/*!40000 ALTER TABLE `cuentas_cobrar` DISABLE KEYS */;
/*!40000 ALTER TABLE `cuentas_cobrar` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cuentas_cobrar_pagos`
--

DROP TABLE IF EXISTS `cuentas_cobrar_pagos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cuentas_cobrar_pagos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `cuenta_id` bigint(20) unsigned NOT NULL,
  `monto` decimal(12,2) NOT NULL,
  `metodo_pago` varchar(255) NOT NULL,
  `referencia` varchar(255) DEFAULT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cuentas_cobrar_pagos_cuenta_id_foreign` (`cuenta_id`),
  KEY `cuentas_cobrar_pagos_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `cuentas_cobrar_pagos_cuenta_id_foreign` FOREIGN KEY (`cuenta_id`) REFERENCES `cuentas_cobrar` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cuentas_cobrar_pagos_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cuentas_cobrar_pagos`
--

LOCK TABLES `cuentas_cobrar_pagos` WRITE;
/*!40000 ALTER TABLE `cuentas_cobrar_pagos` DISABLE KEYS */;
/*!40000 ALTER TABLE `cuentas_cobrar_pagos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cuentas_contables`
--

DROP TABLE IF EXISTS `cuentas_contables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cuentas_contables` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(255) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `tipo` varchar(255) NOT NULL,
  `cuenta_padre_id` bigint(20) unsigned DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cuentas_contables_codigo_unique` (`codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cuentas_contables`
--

LOCK TABLES `cuentas_contables` WRITE;
/*!40000 ALTER TABLE `cuentas_contables` DISABLE KEYS */;
/*!40000 ALTER TABLE `cuentas_contables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cuentas_pagar`
--

DROP TABLE IF EXISTS `cuentas_pagar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cuentas_pagar` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `proveedor_id` bigint(20) unsigned NOT NULL,
  `compra_id` bigint(20) unsigned DEFAULT NULL,
  `monto_total` decimal(12,2) NOT NULL,
  `monto_pagado` decimal(12,2) NOT NULL DEFAULT 0.00,
  `saldo_pendiente` decimal(12,2) NOT NULL,
  `fecha_vencimiento` date DEFAULT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'pendiente',
  `notas` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cuentas_pagar_proveedor_id_foreign` (`proveedor_id`),
  KEY `cuentas_pagar_compra_id_foreign` (`compra_id`),
  CONSTRAINT `cuentas_pagar_compra_id_foreign` FOREIGN KEY (`compra_id`) REFERENCES `compras` (`id`) ON DELETE SET NULL,
  CONSTRAINT `cuentas_pagar_proveedor_id_foreign` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedores` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cuentas_pagar`
--

LOCK TABLES `cuentas_pagar` WRITE;
/*!40000 ALTER TABLE `cuentas_pagar` DISABLE KEYS */;
/*!40000 ALTER TABLE `cuentas_pagar` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cuentas_pagar_pagos`
--

DROP TABLE IF EXISTS `cuentas_pagar_pagos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cuentas_pagar_pagos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `cuenta_id` bigint(20) unsigned NOT NULL,
  `monto` decimal(12,2) NOT NULL,
  `metodo_pago` varchar(255) NOT NULL,
  `referencia` varchar(255) DEFAULT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cuentas_pagar_pagos_cuenta_id_foreign` (`cuenta_id`),
  KEY `cuentas_pagar_pagos_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `cuentas_pagar_pagos_cuenta_id_foreign` FOREIGN KEY (`cuenta_id`) REFERENCES `cuentas_pagar` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cuentas_pagar_pagos_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cuentas_pagar_pagos`
--

LOCK TABLES `cuentas_pagar_pagos` WRITE;
/*!40000 ALTER TABLE `cuentas_pagar_pagos` DISABLE KEYS */;
/*!40000 ALTER TABLE `cuentas_pagar_pagos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cupon_usos`
--

DROP TABLE IF EXISTS `cupon_usos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cupon_usos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `cupon_id` bigint(20) unsigned NOT NULL,
  `venta_id` bigint(20) unsigned NOT NULL,
  `cliente_id` bigint(20) unsigned DEFAULT NULL,
  `descuento_aplicado` decimal(12,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cupon_usos_cupon_id_foreign` (`cupon_id`),
  KEY `cupon_usos_venta_id_foreign` (`venta_id`),
  KEY `cupon_usos_cliente_id_foreign` (`cliente_id`),
  CONSTRAINT `cupon_usos_cliente_id_foreign` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE SET NULL,
  CONSTRAINT `cupon_usos_cupon_id_foreign` FOREIGN KEY (`cupon_id`) REFERENCES `cupones` (`id`) ON DELETE CASCADE,
  CONSTRAINT `cupon_usos_venta_id_foreign` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cupon_usos`
--

LOCK TABLES `cupon_usos` WRITE;
/*!40000 ALTER TABLE `cupon_usos` DISABLE KEYS */;
/*!40000 ALTER TABLE `cupon_usos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cupones`
--

DROP TABLE IF EXISTS `cupones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cupones` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(255) NOT NULL,
  `tipo_descuento` varchar(255) NOT NULL,
  `valor_descuento` decimal(12,2) NOT NULL,
  `compra_minima` decimal(12,2) NOT NULL DEFAULT 0.00,
  `usos_maximos` int(11) DEFAULT NULL,
  `limite_por_cliente` int(11) DEFAULT NULL,
  `usos_actuales` int(11) NOT NULL DEFAULT 0,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `cupones_codigo_unique` (`codigo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cupones`
--

LOCK TABLES `cupones` WRITE;
/*!40000 ALTER TABLE `cupones` DISABLE KEYS */;
/*!40000 ALTER TABLE `cupones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `devolucion_detalle`
--

DROP TABLE IF EXISTS `devolucion_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `devolucion_detalle` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `devolucion_id` bigint(20) unsigned NOT NULL,
  `producto_id` bigint(20) unsigned NOT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 1,
  `precio_unitario` decimal(12,2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `estado_producto` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `devolucion_detalle_devolucion_id_foreign` (`devolucion_id`),
  KEY `devolucion_detalle_producto_id_foreign` (`producto_id`),
  CONSTRAINT `devolucion_detalle_devolucion_id_foreign` FOREIGN KEY (`devolucion_id`) REFERENCES `devoluciones` (`id`) ON DELETE CASCADE,
  CONSTRAINT `devolucion_detalle_producto_id_foreign` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `devolucion_detalle`
--

LOCK TABLES `devolucion_detalle` WRITE;
/*!40000 ALTER TABLE `devolucion_detalle` DISABLE KEYS */;
INSERT INTO `devolucion_detalle` VALUES (1,1,2,3,4500.00,13500.00,'bueno','2026-06-05 08:45:06'),(2,2,2,1,4500.00,4500.00,'bueno','2026-06-05 08:51:10'),(3,3,1,1,8000.00,8000.00,'danado','2026-06-15 16:13:55');
/*!40000 ALTER TABLE `devolucion_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `devoluciones`
--

DROP TABLE IF EXISTS `devoluciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `devoluciones` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `numero_devolucion` varchar(255) DEFAULT NULL,
  `venta_id` bigint(20) unsigned NOT NULL,
  `cliente_id` bigint(20) unsigned DEFAULT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `aprobado_por` bigint(20) unsigned DEFAULT NULL,
  `tipo` varchar(255) DEFAULT NULL,
  `tipo_reembolso` varchar(255) DEFAULT NULL,
  `monto_total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `motivo` text DEFAULT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'pendiente',
  `notas` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `devoluciones_numero_devolucion_unique` (`numero_devolucion`),
  KEY `devoluciones_venta_id_foreign` (`venta_id`),
  KEY `devoluciones_cliente_id_foreign` (`cliente_id`),
  KEY `devoluciones_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `devoluciones_cliente_id_foreign` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE SET NULL,
  CONSTRAINT `devoluciones_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  CONSTRAINT `devoluciones_venta_id_foreign` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `devoluciones`
--

LOCK TABLES `devoluciones` WRITE;
/*!40000 ALTER TABLE `devoluciones` DISABLE KEYS */;
INSERT INTO `devoluciones` VALUES (1,'DEV-20260605-0001',6,1,1,1,'parcial','efectivo',13500.00,'Error','completada',NULL,'2026-06-05 08:45:06','2026-06-05 08:45:14'),(2,'DEV-20260605-0002',7,1,1,1,'parcial','efectivo',4500.00,'Si','completada',NULL,'2026-06-05 08:51:10','2026-06-05 08:51:15'),(3,'DEV-20260615-0001',8,NULL,1,1,'parcial','efectivo',8000.00,'Esta malo','completada',NULL,'2026-06-15 16:13:55','2026-06-15 16:14:08');
/*!40000 ALTER TABLE `devoluciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_analytics`
--

DROP TABLE IF EXISTS `email_analytics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_analytics` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `campaign_id` bigint(20) unsigned NOT NULL,
  `fecha` date NOT NULL,
  `aperturas` int(11) NOT NULL DEFAULT 0,
  `clics` int(11) NOT NULL DEFAULT 0,
  `rebotes` int(11) NOT NULL DEFAULT 0,
  `enviados` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email_analytics_campaign_id_fecha_unique` (`campaign_id`,`fecha`),
  CONSTRAINT `email_analytics_campaign_id_foreign` FOREIGN KEY (`campaign_id`) REFERENCES `email_campaigns` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_analytics`
--

LOCK TABLES `email_analytics` WRITE;
/*!40000 ALTER TABLE `email_analytics` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_analytics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_campaigns`
--

DROP TABLE IF EXISTS `email_campaigns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_campaigns` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `asunto` varchar(255) DEFAULT NULL,
  `html_content` longtext DEFAULT NULL,
  `json_content` longtext DEFAULT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'borrador',
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `programada_para` timestamp NULL DEFAULT NULL,
  `enviada_en` timestamp NULL DEFAULT NULL,
  `total_recipients` int(11) NOT NULL DEFAULT 0,
  `total_enviados` int(11) NOT NULL DEFAULT 0,
  `total_abiertos` int(11) NOT NULL DEFAULT 0,
  `total_clicks` int(11) NOT NULL DEFAULT 0,
  `total_rebotes` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `email_campaigns_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `email_campaigns_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_campaigns`
--

LOCK TABLES `email_campaigns` WRITE;
/*!40000 ALTER TABLE `email_campaigns` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_campaigns` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_destinatarios`
--

DROP TABLE IF EXISTS `email_destinatarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_destinatarios` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `campana_id` bigint(20) unsigned NOT NULL,
  `email` varchar(255) NOT NULL,
  `nombre` varchar(255) DEFAULT NULL,
  `cliente_id` bigint(20) unsigned DEFAULT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'pendiente',
  `enviado_at` timestamp NULL DEFAULT NULL,
  `abierto_at` timestamp NULL DEFAULT NULL,
  `error_mensaje` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `email_destinatarios_cliente_id_foreign` (`cliente_id`),
  KEY `email_destinatarios_campana_id_index` (`campana_id`),
  CONSTRAINT `email_destinatarios_campana_id_foreign` FOREIGN KEY (`campana_id`) REFERENCES `campanas_email` (`id`) ON DELETE CASCADE,
  CONSTRAINT `email_destinatarios_cliente_id_foreign` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_destinatarios`
--

LOCK TABLES `email_destinatarios` WRITE;
/*!40000 ALTER TABLE `email_destinatarios` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_destinatarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_recipients`
--

DROP TABLE IF EXISTS `email_recipients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_recipients` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `campaign_id` bigint(20) unsigned NOT NULL,
  `email` varchar(255) NOT NULL,
  `nombre` varchar(255) DEFAULT NULL,
  `cliente_id` bigint(20) unsigned DEFAULT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'pendiente',
  `enviado_at` timestamp NULL DEFAULT NULL,
  `abierto_at` timestamp NULL DEFAULT NULL,
  `click_at` timestamp NULL DEFAULT NULL,
  `device` varchar(255) DEFAULT NULL,
  `error_mensaje` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `email_recipients_cliente_id_foreign` (`cliente_id`),
  KEY `email_recipients_campaign_id_index` (`campaign_id`),
  KEY `email_recipients_estado_index` (`estado`),
  CONSTRAINT `email_recipients_campaign_id_foreign` FOREIGN KEY (`campaign_id`) REFERENCES `email_campaigns` (`id`) ON DELETE CASCADE,
  CONSTRAINT `email_recipients_cliente_id_foreign` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_recipients`
--

LOCK TABLES `email_recipients` WRITE;
/*!40000 ALTER TABLE `email_recipients` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_recipients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_templates`
--

DROP TABLE IF EXISTS `email_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_templates` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `asunto` varchar(255) DEFAULT NULL,
  `categoria` varchar(50) DEFAULT NULL,
  `html_content` longtext DEFAULT NULL,
  `json_content` longtext DEFAULT NULL,
  `thumbnail` varchar(255) DEFAULT NULL,
  `es_publico` tinyint(1) NOT NULL DEFAULT 0,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `email_templates_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `email_templates_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_templates`
--

LOCK TABLES `email_templates` WRITE;
/*!40000 ALTER TABLE `email_templates` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `empleados`
--

DROP TABLE IF EXISTS `empleados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `empleados` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `cedula` varchar(255) DEFAULT NULL,
  `puesto` varchar(255) DEFAULT NULL,
  `departamento` varchar(255) DEFAULT NULL,
  `fecha_ingreso` date DEFAULT NULL,
  `salario_base` decimal(12,2) NOT NULL DEFAULT 0.00,
  `tipo_contrato` varchar(255) NOT NULL DEFAULT 'indefinido',
  `cuenta_banco` varchar(255) DEFAULT NULL,
  `telefono` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `empleados_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `empleados_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `empleados`
--

LOCK TABLES `empleados` WRITE;
/*!40000 ALTER TABLE `empleados` DISABLE KEYS */;
INSERT INTO `empleados` VALUES (1,'David','2987327942','Vendedor',NULL,'2026-07-03',360000.00,'indefinido',NULL,NULL,NULL,1,NULL,'2026-07-04 02:32:57','2026-07-04 02:32:57');
/*!40000 ALTER TABLE `empleados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `etiquetas`
--

DROP TABLE IF EXISTS `etiquetas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `etiquetas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `color` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `etiquetas`
--

LOCK TABLES `etiquetas` WRITE;
/*!40000 ALTER TABLE `etiquetas` DISABLE KEYS */;
INSERT INTO `etiquetas` VALUES (1,'Cliente David','#25b136','2026-05-23 00:05:52'),(2,'Cliente Alajuela','#c4cf20','2026-06-15 16:20:23');
/*!40000 ALTER TABLE `etiquetas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `facturacion_electronica`
--

DROP TABLE IF EXISTS `facturacion_electronica`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `facturacion_electronica` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `venta_id` bigint(20) unsigned DEFAULT NULL,
  `clave_numerica` varchar(50) DEFAULT NULL,
  `numero_consecutivo` varchar(20) DEFAULT NULL,
  `tipo_documento` varchar(10) NOT NULL DEFAULT 'FE',
  `estado_hacienda` varchar(20) NOT NULL DEFAULT 'pendiente',
  `xml_enviado` text DEFAULT NULL,
  `xml_respuesta` text DEFAULT NULL,
  `mensaje_hacienda` varchar(255) DEFAULT NULL,
  `fecha_emision` timestamp NULL DEFAULT NULL,
  `fecha_respuesta` timestamp NULL DEFAULT NULL,
  `email_enviado_a` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `facturacion_electronica_clave_numerica_index` (`clave_numerica`),
  KEY `facturacion_electronica_venta_id_index` (`venta_id`),
  CONSTRAINT `facturacion_electronica_venta_id_foreign` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `facturacion_electronica`
--

LOCK TABLES `facturacion_electronica` WRITE;
/*!40000 ALTER TABLE `facturacion_electronica` DISABLE KEYS */;
/*!40000 ALTER TABLE `facturacion_electronica` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `failed_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `connection` varchar(255) NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`),
  KEY `failed_jobs_connection_queue_failed_at_index` (`connection`,`queue`,`failed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `formulario_respuestas`
--

DROP TABLE IF EXISTS `formulario_respuestas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `formulario_respuestas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `formulario_id` bigint(20) unsigned NOT NULL,
  `datos` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`datos`)),
  `ip` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `formulario_respuestas_formulario_id_foreign` (`formulario_id`),
  CONSTRAINT `formulario_respuestas_formulario_id_foreign` FOREIGN KEY (`formulario_id`) REFERENCES `formularios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `formulario_respuestas`
--

LOCK TABLES `formulario_respuestas` WRITE;
/*!40000 ALTER TABLE `formulario_respuestas` DISABLE KEYS */;
/*!40000 ALTER TABLE `formulario_respuestas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `formularios`
--

DROP TABLE IF EXISTS `formularios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `formularios` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `campos` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`campos`)),
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `slug` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `formularios_slug_unique` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `formularios`
--

LOCK TABLES `formularios` WRITE;
/*!40000 ALTER TABLE `formularios` DISABLE KEYS */;
/*!40000 ALTER TABLE `formularios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventario_movimientos`
--

DROP TABLE IF EXISTS `inventario_movimientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventario_movimientos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `producto_id` bigint(20) unsigned NOT NULL,
  `ubicacion_id` bigint(20) unsigned DEFAULT NULL,
  `ubicacion_destino_id` bigint(20) unsigned DEFAULT NULL,
  `tipo` varchar(255) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `stock_anterior` int(11) NOT NULL,
  `stock_nuevo` int(11) NOT NULL,
  `referencia_tipo` varchar(255) DEFAULT NULL,
  `referencia_id` bigint(20) unsigned DEFAULT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `notas` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `inventario_movimientos_producto_id_foreign` (`producto_id`),
  KEY `inventario_movimientos_usuario_id_foreign` (`usuario_id`),
  KEY `inventario_movimientos_ubicacion_id_foreign` (`ubicacion_id`),
  KEY `inventario_movimientos_ubicacion_destino_id_foreign` (`ubicacion_destino_id`),
  CONSTRAINT `inventario_movimientos_producto_id_foreign` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `inventario_movimientos_ubicacion_destino_id_foreign` FOREIGN KEY (`ubicacion_destino_id`) REFERENCES `ubicaciones` (`id`) ON DELETE SET NULL,
  CONSTRAINT `inventario_movimientos_ubicacion_id_foreign` FOREIGN KEY (`ubicacion_id`) REFERENCES `ubicaciones` (`id`) ON DELETE SET NULL,
  CONSTRAINT `inventario_movimientos_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventario_movimientos`
--

LOCK TABLES `inventario_movimientos` WRITE;
/*!40000 ALTER TABLE `inventario_movimientos` DISABLE KEYS */;
INSERT INTO `inventario_movimientos` VALUES (1,1,NULL,NULL,'salida',1,10,9,'venta',1,1,NULL,'2026-05-22 23:53:11'),(2,1,NULL,NULL,'salida',2,9,7,'venta',2,1,NULL,'2026-05-30 01:28:26'),(3,1,NULL,NULL,'salida',2,7,5,'venta',3,1,NULL,'2026-05-30 01:28:26'),(4,1,NULL,NULL,'entrada',30,52,52,'ajuste',1,1,'Ajuste: AJ-20260603-7046','2026-06-04 01:39:48'),(5,2,NULL,NULL,'entrada',30,18,18,'ajuste',1,1,'Ajuste: AJ-20260603-7046','2026-06-04 01:39:48'),(6,1,NULL,NULL,'entrada',0,52,52,'ajuste',2,1,'Ajuste: AJ-20260603-4509','2026-06-04 02:04:27'),(7,1,NULL,NULL,'salida',20,52,32,'ajuste',2,1,'Ajuste: AJ-20260603-4509','2026-06-04 02:04:27'),(8,1,NULL,NULL,'salida',1,30,29,'venta',5,1,NULL,'2026-06-05 08:40:36'),(9,2,NULL,NULL,'salida',1,15,14,'venta',6,1,NULL,'2026-06-05 08:44:14'),(10,2,NULL,NULL,'salida',1,17,16,'venta',7,1,NULL,'2026-06-05 08:50:20'),(11,1,NULL,NULL,'salida',2,2,0,'venta',8,1,NULL,'2026-06-05 08:55:33'),(12,1,NULL,NULL,'entrada',10,29,39,'compra',1,1,'Recepción de compra','2026-06-15 16:22:36');
/*!40000 ALTER TABLE `inventario_movimientos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inventario_ubicacion`
--

DROP TABLE IF EXISTS `inventario_ubicacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventario_ubicacion` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `producto_id` bigint(20) unsigned NOT NULL,
  `ubicacion_id` bigint(20) unsigned NOT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 0,
  `cantidad_reservada` int(11) NOT NULL DEFAULT 0,
  `stock_minimo` int(11) DEFAULT NULL,
  `stock_maximo` int(11) DEFAULT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'activo',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `inventario_ubicacion_producto_id_ubicacion_id_unique` (`producto_id`,`ubicacion_id`),
  KEY `inventario_ubicacion_ubicacion_id_foreign` (`ubicacion_id`),
  CONSTRAINT `inventario_ubicacion_producto_id_foreign` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `inventario_ubicacion_ubicacion_id_foreign` FOREIGN KEY (`ubicacion_id`) REFERENCES `ubicaciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inventario_ubicacion`
--

LOCK TABLES `inventario_ubicacion` WRITE;
/*!40000 ALTER TABLE `inventario_ubicacion` DISABLE KEYS */;
INSERT INTO `inventario_ubicacion` VALUES (1,1,1,39,0,NULL,NULL,'activo','2026-05-22 23:51:43','2026-06-15 16:22:36'),(2,1,2,0,0,NULL,NULL,'activo','2026-06-04 00:34:21','2026-06-06 20:24:47'),(3,2,1,17,0,NULL,NULL,'activo','2026-06-04 00:47:11','2026-06-15 16:19:27'),(4,2,2,3,0,NULL,NULL,'activo','2026-06-04 00:47:11','2026-06-15 16:19:27');
/*!40000 ALTER TABLE `inventario_ubicacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
  `finished_at` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` smallint(5) unsigned NOT NULL,
  `reserved_at` int(10) unsigned DEFAULT NULL,
  `available_at` int(10) unsigned NOT NULL,
  `created_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
INSERT INTO `jobs` VALUES (1,'default','{\"uuid\":\"795eb15c-d943-4bbc-8b34-426c335c07ca\",\"displayName\":\"App\\\\Events\\\\NuevaNotificacion\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:28:\\\"App\\\\Events\\\\NuevaNotificacion\\\":2:{s:16:\\\"notificacionData\\\";a:8:{s:2:\\\"id\\\";i:1;s:6:\\\"titulo\\\";s:14:\\\"Nuevo Producto\\\";s:7:\\\"mensaje\\\";s:33:\\\"Ingreso nueva camisa color negra!\\\";s:4:\\\"tipo\\\";s:11:\\\"informativa\\\";s:9:\\\"prioridad\\\";s:6:\\\"normal\\\";s:5:\\\"color\\\";s:7:\\\"#049014\\\";s:5:\\\"icono\\\";s:18:\\\"fas fa-info-circle\\\";s:10:\\\"enviada_en\\\";s:27:\\\"2026-05-22T18:37:23.000000Z\\\";}s:10:\\\"usuarioIds\\\";a:2:{i:0;i:1;i:1;i:2;}}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1779475045,\"delay\":null}',0,NULL,1779475045,1779475045),(2,'default','{\"uuid\":\"7be26332-27cc-4531-8f37-1142e739afe4\",\"displayName\":\"App\\\\Events\\\\NuevaNotificacion\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:28:\\\"App\\\\Events\\\\NuevaNotificacion\\\":2:{s:16:\\\"notificacionData\\\";a:8:{s:2:\\\"id\\\";i:4;s:6:\\\"titulo\\\";s:15:\\\"Reunion a las 3\\\";s:7:\\\"mensaje\\\";s:4:\\\"Hola\\\";s:4:\\\"tipo\\\";s:12:\\\"recordatorio\\\";s:9:\\\"prioridad\\\";s:6:\\\"normal\\\";s:5:\\\"color\\\";s:7:\\\"#00ff04\\\";s:5:\\\"icono\\\";s:12:\\\"fas fa-clock\\\";s:10:\\\"enviada_en\\\";s:27:\\\"2026-05-29T20:02:30.000000Z\\\";}s:10:\\\"usuarioIds\\\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1780084953,\"delay\":null}',0,NULL,1780084953,1780084953),(3,'default','{\"uuid\":\"b984caef-d7ec-43e6-8214-07973e0e3059\",\"displayName\":\"App\\\\Events\\\\NuevaNotificacion\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:28:\\\"App\\\\Events\\\\NuevaNotificacion\\\":2:{s:16:\\\"notificacionData\\\";a:8:{s:2:\\\"id\\\";i:5;s:6:\\\"titulo\\\";s:15:\\\"Reunion a las 3\\\";s:7:\\\"mensaje\\\";s:4:\\\"Hola\\\";s:4:\\\"tipo\\\";s:12:\\\"recordatorio\\\";s:9:\\\"prioridad\\\";s:6:\\\"normal\\\";s:5:\\\"color\\\";s:7:\\\"#00ff04\\\";s:5:\\\"icono\\\";s:12:\\\"fas fa-clock\\\";s:10:\\\"enviada_en\\\";s:27:\\\"2026-05-29T20:02:34.000000Z\\\";}s:10:\\\"usuarioIds\\\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1780084954,\"delay\":null}',0,NULL,1780084954,1780084954),(4,'default','{\"uuid\":\"ebc53ca1-f2fc-4dc3-b84e-4457fb9b454f\",\"displayName\":\"App\\\\Events\\\\NuevaNotificacion\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:28:\\\"App\\\\Events\\\\NuevaNotificacion\\\":2:{s:16:\\\"notificacionData\\\";a:8:{s:2:\\\"id\\\";i:6;s:6:\\\"titulo\\\";s:7:\\\"Reunion\\\";s:7:\\\"mensaje\\\";s:22:\\\"Hoy reunion a las 10am\\\";s:4:\\\"tipo\\\";s:11:\\\"informativa\\\";s:9:\\\"prioridad\\\";s:4:\\\"alta\\\";s:5:\\\"color\\\";s:7:\\\"#ecf014\\\";s:5:\\\"icono\\\";s:18:\\\"fas fa-info-circle\\\";s:10:\\\"enviada_en\\\";s:27:\\\"2026-06-15T16:37:16.000000Z\\\";}s:10:\\\"usuarioIds\\\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1781541437,\"delay\":null}',0,NULL,1781541437,1781541437),(5,'default','{\"uuid\":\"a2dbf571-6018-44d5-b101-47a9fad8a175\",\"displayName\":\"App\\\\Events\\\\NuevaNotificacion\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\",\"command\":\"O:38:\\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\\":17:{s:5:\\\"event\\\";O:28:\\\"App\\\\Events\\\\NuevaNotificacion\\\":2:{s:16:\\\"notificacionData\\\";a:8:{s:2:\\\"id\\\";i:7;s:6:\\\"titulo\\\";s:7:\\\"Reunion\\\";s:7:\\\"mensaje\\\";s:22:\\\"Hoy reunion a las 10am\\\";s:4:\\\"tipo\\\";s:11:\\\"informativa\\\";s:9:\\\"prioridad\\\";s:4:\\\"alta\\\";s:5:\\\"color\\\";s:7:\\\"#ecf014\\\";s:5:\\\"icono\\\";s:18:\\\"fas fa-info-circle\\\";s:10:\\\"enviada_en\\\";s:27:\\\"2026-06-15T16:37:18.000000Z\\\";}s:10:\\\"usuarioIds\\\";a:3:{i:0;i:1;i:1;i:2;i:2;i:3;}}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:7:\\\"backoff\\\";N;s:13:\\\"maxExceptions\\\";N;s:23:\\\"deleteWhenMissingModels\\\";b:1;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;}\",\"batchId\":null},\"createdAt\":1781541438,\"delay\":null}',0,NULL,1781541438,1781541438);
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lista_precio_productos`
--

DROP TABLE IF EXISTS `lista_precio_productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lista_precio_productos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `lista_id` bigint(20) unsigned NOT NULL,
  `producto_id` bigint(20) unsigned NOT NULL,
  `precio` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lista_precio_productos_lista_id_producto_id_unique` (`lista_id`,`producto_id`),
  KEY `lista_precio_productos_producto_id_foreign` (`producto_id`),
  CONSTRAINT `lista_precio_productos_lista_id_foreign` FOREIGN KEY (`lista_id`) REFERENCES `listas_precios` (`id`) ON DELETE CASCADE,
  CONSTRAINT `lista_precio_productos_producto_id_foreign` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lista_precio_productos`
--

LOCK TABLES `lista_precio_productos` WRITE;
/*!40000 ALTER TABLE `lista_precio_productos` DISABLE KEYS */;
/*!40000 ALTER TABLE `lista_precio_productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lista_precios_clientes`
--

DROP TABLE IF EXISTS `lista_precios_clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lista_precios_clientes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `lista_id` bigint(20) unsigned NOT NULL,
  `cliente_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lista_precios_clientes_lista_id_cliente_id_unique` (`lista_id`,`cliente_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lista_precios_clientes`
--

LOCK TABLES `lista_precios_clientes` WRITE;
/*!40000 ALTER TABLE `lista_precios_clientes` DISABLE KEYS */;
INSERT INTO `lista_precios_clientes` VALUES (2,1,1,'2026-06-04 01:32:01'),(3,2,1,'2026-06-12 04:49:06');
/*!40000 ALTER TABLE `lista_precios_clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lista_precios_productos`
--

DROP TABLE IF EXISTS `lista_precios_productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lista_precios_productos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `lista_id` bigint(20) unsigned NOT NULL,
  `producto_id` bigint(20) unsigned NOT NULL,
  `precio_especial` decimal(12,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `lista_precios_productos_lista_id_producto_id_unique` (`lista_id`,`producto_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lista_precios_productos`
--

LOCK TABLES `lista_precios_productos` WRITE;
/*!40000 ALTER TABLE `lista_precios_productos` DISABLE KEYS */;
INSERT INTO `lista_precios_productos` VALUES (1,1,1,5000.00,'2026-06-04 01:32:09');
/*!40000 ALTER TABLE `lista_precios_productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `listas_precios`
--

DROP TABLE IF EXISTS `listas_precios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `listas_precios` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `descuento_porcentaje` decimal(5,2) NOT NULL DEFAULT 0.00,
  `tipo` varchar(255) NOT NULL DEFAULT 'porcentaje',
  `valor` decimal(8,2) NOT NULL DEFAULT 0.00,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `listas_precios`
--

LOCK TABLES `listas_precios` WRITE;
/*!40000 ALTER TABLE `listas_precios` DISABLE KEYS */;
INSERT INTO `listas_precios` VALUES (1,'sdxc',NULL,10.00,'porcentaje',0.00,1,'2026-06-04 00:05:41','2026-06-04 00:07:04'),(2,'Precios a don Jose','lista especial',0.00,'porcentaje',0.00,1,'2026-06-12 04:49:06','2026-06-12 04:49:06');
/*!40000 ALTER TABLE `listas_precios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2026_05_16_040815_create_personal_access_tokens_table',1),(5,'2026_05_17_000000_create_erp_tables',1),(6,'2026_05_17_000001_create_additional_erp_tables',1),(7,'2026_05_17_000002_create_extended_erp_tables',1),(8,'2026_05_19_000000_add_proveedor_id_to_productos',1),(9,'2026_05_19_100000_create_chat_tables',1),(10,'2026_05_19_100001_add_cerrado_fields_to_chats',1),(11,'2026_05_19_110000_create_notificaciones_tables',1),(12,'2026_05_19_120000_create_email_builder_tables',1),(13,'2026_05_20_160600_add_descartado_at_to_notificacion_usuarios',1),(14,'2026_05_20_230158_create_inventario_ubicacion_table',1),(15,'2026_05_20_230200_migrate_stock_to_inventario_ubicacion',1),(16,'2026_05_20_240000_enhance_inventario_ubicacion',1),(17,'2026_05_20_240001_enhance_inventario_movimientos',1),(18,'2026_05_21_100000_add_adjunto_to_chat_mensajes',1),(19,'2026_05_21_130401_update_auditoria_table_add_model_tracking',1),(20,'2026_06_03_033254_add_activo_to_roles_table',2),(21,'2026_06_03_040000_create_listas_precios_tables',3),(22,'2026_06_03_040100_create_formularios_tables',3),(23,'2026_06_03_040200_add_aprobacion_to_cotizaciones',4),(24,'2026_06_03_162153_add_empresa_cedula_juridica_to_clientes',5),(25,'2026_06_03_163111_fix_clientes_credito_tienda_nullable',6),(26,'2026_06_03_181000_add_descuento_to_listas_precios',7),(27,'2026_06_03_191000_add_cotizacion_id_to_ventas',8),(28,'2026_06_03_200001_create_cotizacion_configuracion_table',9),(29,'2026_06_05_040000_create_cliente_categorias_table',10),(30,'2026_06_11_000000_create_all_tables_consolidated',11),(31,'2026_06_11_154832_add_usuario_id_to_cajas_table',12),(32,'2026_06_29_141922_alter_asunto_nullable_in_email_campaigns_table',13),(33,'2026_07_02_000000_enhance_productividad',14),(34,'2026_07_03_000000_add_smtp_config_to_configuracion_table',15),(35,'2026_07_03_000000_add_active_time_tracking_to_productividad',16),(36,'2026_07_03_000000_create_planilla_avanzada_tables',16);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nota_credito_detalle`
--

DROP TABLE IF EXISTS `nota_credito_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nota_credito_detalle` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nota_credito_id` bigint(20) unsigned NOT NULL,
  `producto_id` bigint(20) unsigned NOT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 1,
  `precio_unitario` decimal(12,2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `devolver_inventario` tinyint(1) NOT NULL DEFAULT 0,
  `estado_producto` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `nota_credito_detalle_nota_credito_id_foreign` (`nota_credito_id`),
  KEY `nota_credito_detalle_producto_id_foreign` (`producto_id`),
  CONSTRAINT `nota_credito_detalle_nota_credito_id_foreign` FOREIGN KEY (`nota_credito_id`) REFERENCES `notas_credito` (`id`) ON DELETE CASCADE,
  CONSTRAINT `nota_credito_detalle_producto_id_foreign` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nota_credito_detalle`
--

LOCK TABLES `nota_credito_detalle` WRITE;
/*!40000 ALTER TABLE `nota_credito_detalle` DISABLE KEYS */;
/*!40000 ALTER TABLE `nota_credito_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nota_credito_usos`
--

DROP TABLE IF EXISTS `nota_credito_usos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nota_credito_usos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nota_credito_id` bigint(20) unsigned NOT NULL,
  `venta_id` bigint(20) unsigned DEFAULT NULL,
  `monto_usado` decimal(12,2) NOT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `concepto` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `nota_credito_usos_nota_credito_id_foreign` (`nota_credito_id`),
  KEY `nota_credito_usos_venta_id_foreign` (`venta_id`),
  KEY `nota_credito_usos_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `nota_credito_usos_nota_credito_id_foreign` FOREIGN KEY (`nota_credito_id`) REFERENCES `notas_credito` (`id`) ON DELETE CASCADE,
  CONSTRAINT `nota_credito_usos_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  CONSTRAINT `nota_credito_usos_venta_id_foreign` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nota_credito_usos`
--

LOCK TABLES `nota_credito_usos` WRITE;
/*!40000 ALTER TABLE `nota_credito_usos` DISABLE KEYS */;
/*!40000 ALTER TABLE `nota_credito_usos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notas_credito`
--

DROP TABLE IF EXISTS `notas_credito`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notas_credito` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `numero_nota` varchar(255) DEFAULT NULL,
  `venta_id` bigint(20) unsigned DEFAULT NULL,
  `cliente_id` bigint(20) unsigned DEFAULT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `tipo` varchar(255) DEFAULT NULL,
  `tipo_credito` varchar(255) DEFAULT NULL,
  `monto_total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `saldo_restante` decimal(12,2) NOT NULL DEFAULT 0.00,
  `motivo` text DEFAULT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'activa',
  `notas` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `notas_credito_numero_nota_unique` (`numero_nota`),
  KEY `notas_credito_venta_id_foreign` (`venta_id`),
  KEY `notas_credito_cliente_id_foreign` (`cliente_id`),
  KEY `notas_credito_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `notas_credito_cliente_id_foreign` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE SET NULL,
  CONSTRAINT `notas_credito_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL,
  CONSTRAINT `notas_credito_venta_id_foreign` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notas_credito`
--

LOCK TABLES `notas_credito` WRITE;
/*!40000 ALTER TABLE `notas_credito` DISABLE KEYS */;
/*!40000 ALTER TABLE `notas_credito` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notificacion_usuarios`
--

DROP TABLE IF EXISTS `notificacion_usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notificacion_usuarios` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `notificacion_id` bigint(20) unsigned NOT NULL,
  `usuario_id` bigint(20) unsigned NOT NULL,
  `leido_at` timestamp NULL DEFAULT NULL,
  `descartado_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `notificacion_usuarios_notificacion_id_usuario_id_unique` (`notificacion_id`,`usuario_id`),
  KEY `notificacion_usuarios_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `notificacion_usuarios_notificacion_id_foreign` FOREIGN KEY (`notificacion_id`) REFERENCES `notificaciones` (`id`) ON DELETE CASCADE,
  CONSTRAINT `notificacion_usuarios_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notificacion_usuarios`
--

LOCK TABLES `notificacion_usuarios` WRITE;
/*!40000 ALTER TABLE `notificacion_usuarios` DISABLE KEYS */;
INSERT INTO `notificacion_usuarios` VALUES (1,1,1,'2026-05-23 00:42:33','2026-05-23 00:42:36','2026-05-23 00:42:36'),(2,1,2,'2026-06-15 16:37:38','2026-05-23 00:37:55','2026-05-23 00:37:55'),(3,4,1,NULL,'2026-05-30 02:04:05','2026-05-30 02:04:05'),(4,4,2,'2026-06-15 16:37:38','2026-06-02 07:14:51','2026-06-02 07:14:51'),(5,4,3,NULL,'2026-05-30 02:03:01','2026-05-30 02:03:01'),(6,5,1,NULL,'2026-05-30 02:04:07','2026-05-30 02:04:07'),(7,5,2,'2026-06-15 16:37:38','2026-06-02 07:14:49','2026-06-02 07:14:49'),(8,5,3,NULL,'2026-05-30 02:02:56','2026-05-30 02:02:56'),(9,1,3,NULL,'2026-05-30 02:03:00','2026-05-30 02:03:00'),(10,6,1,NULL,'2026-06-15 16:37:50','2026-06-15 16:37:50'),(11,6,2,'2026-06-15 16:37:38','2026-06-15 16:37:42','2026-06-15 16:37:42'),(12,6,3,NULL,NULL,'2026-06-15 16:37:16'),(13,7,1,NULL,'2026-06-15 16:37:48','2026-06-15 16:37:48'),(14,7,2,'2026-06-15 16:37:38','2026-06-15 16:37:41','2026-06-15 16:37:41'),(15,7,3,NULL,NULL,'2026-06-15 16:37:18');
/*!40000 ALTER TABLE `notificacion_usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notificaciones`
--

DROP TABLE IF EXISTS `notificaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notificaciones` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `titulo` varchar(255) NOT NULL,
  `mensaje` text NOT NULL,
  `color` varchar(255) NOT NULL DEFAULT '#ef4444',
  `icono` varchar(255) NOT NULL DEFAULT 'fas fa-bell',
  `tipo` varchar(255) NOT NULL DEFAULT 'informativa',
  `prioridad` varchar(255) NOT NULL DEFAULT 'normal',
  `creador_id` bigint(20) unsigned NOT NULL,
  `global` tinyint(1) NOT NULL DEFAULT 0,
  `enviada_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `notificaciones_creador_id_foreign` (`creador_id`),
  CONSTRAINT `notificaciones_creador_id_foreign` FOREIGN KEY (`creador_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notificaciones`
--

LOCK TABLES `notificaciones` WRITE;
/*!40000 ALTER TABLE `notificaciones` DISABLE KEYS */;
INSERT INTO `notificaciones` VALUES (1,'Nuevo Producto','Ingreso nueva camisa color negra!','#049014','fas fa-info-circle','informativa','normal',1,1,'2026-05-23 00:37:23','2026-05-23 00:37:23','2026-05-23 00:37:23'),(4,'Reunion a las 3','Hola','#00ff04','fas fa-clock','recordatorio','normal',1,1,'2026-05-30 02:02:30','2026-05-30 02:02:30','2026-05-30 02:02:30'),(5,'Reunion a las 3','Hola','#00ff04','fas fa-clock','recordatorio','normal',1,1,'2026-05-30 02:02:34','2026-05-30 02:02:34','2026-05-30 02:02:34'),(6,'Reunion','Hoy reunion a las 10am','#ecf014','fas fa-info-circle','informativa','alta',1,1,'2026-06-15 16:37:16','2026-06-15 16:37:16','2026-06-15 16:37:16'),(7,'Reunion','Hoy reunion a las 10am','#ecf014','fas fa-info-circle','informativa','alta',1,1,'2026-06-15 16:37:18','2026-06-15 16:37:18','2026-06-15 16:37:18');
/*!40000 ALTER TABLE `notificaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedido_detalle`
--

DROP TABLE IF EXISTS `pedido_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pedido_detalle` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pedido_id` bigint(20) unsigned NOT NULL,
  `producto_id` bigint(20) unsigned NOT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 1,
  `precio_unitario` decimal(12,2) NOT NULL DEFAULT 0.00,
  `descuento` decimal(12,2) NOT NULL DEFAULT 0.00,
  `impuesto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `reservado` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pedido_detalle_pedido_id_foreign` (`pedido_id`),
  KEY `pedido_detalle_producto_id_foreign` (`producto_id`),
  CONSTRAINT `pedido_detalle_pedido_id_foreign` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `pedido_detalle_producto_id_foreign` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedido_detalle`
--

LOCK TABLES `pedido_detalle` WRITE;
/*!40000 ALTER TABLE `pedido_detalle` DISABLE KEYS */;
INSERT INTO `pedido_detalle` VALUES (1,1,1,1,8000.00,0.00,1040.00,8000.00,0,'2026-07-13 18:49:28');
/*!40000 ALTER TABLE `pedido_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedido_pagos`
--

DROP TABLE IF EXISTS `pedido_pagos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pedido_pagos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `pedido_id` bigint(20) unsigned NOT NULL,
  `monto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `metodo_pago` varchar(255) DEFAULT NULL,
  `referencia` varchar(255) DEFAULT NULL,
  `tipo` varchar(255) DEFAULT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `notas` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pedido_pagos_pedido_id_foreign` (`pedido_id`),
  CONSTRAINT `pedido_pagos_pedido_id_foreign` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedido_pagos`
--

LOCK TABLES `pedido_pagos` WRITE;
/*!40000 ALTER TABLE `pedido_pagos` DISABLE KEYS */;
/*!40000 ALTER TABLE `pedido_pagos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedidos`
--

DROP TABLE IF EXISTS `pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pedidos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `numero_pedido` varchar(255) DEFAULT NULL,
  `cliente_id` bigint(20) unsigned DEFAULT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `cotizacion_id` bigint(20) unsigned DEFAULT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `descuento_total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `impuesto_total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `monto_adelanto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `monto_pendiente` decimal(12,2) NOT NULL DEFAULT 0.00,
  `estado` varchar(255) NOT NULL DEFAULT 'pendiente',
  `tipo_entrega` varchar(255) DEFAULT NULL,
  `direccion_entrega` text DEFAULT NULL,
  `fecha_entrega_estimada` date DEFAULT NULL,
  `fecha_entrega_real` date DEFAULT NULL,
  `reservar_inventario` tinyint(1) NOT NULL DEFAULT 0,
  `notas` text DEFAULT NULL,
  `venta_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pedidos_numero_pedido_unique` (`numero_pedido`),
  KEY `pedidos_cliente_id_foreign` (`cliente_id`),
  KEY `pedidos_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `pedidos_cliente_id_foreign` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE SET NULL,
  CONSTRAINT `pedidos_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedidos`
--

LOCK TABLES `pedidos` WRITE;
/*!40000 ALTER TABLE `pedidos` DISABLE KEYS */;
INSERT INTO `pedidos` VALUES (1,'PED-20260713-0001',NULL,1,NULL,8000.00,0.00,1040.00,9040.00,0.00,9040.00,'en_proceso','domicilio',NULL,'2026-07-29',NULL,0,NULL,NULL,'2026-07-13 18:49:28','2026-07-13 18:49:31');
/*!40000 ALTER TABLE `pedidos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permisos`
--

DROP TABLE IF EXISTS `permisos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permisos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `slug` varchar(255) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `permisos_slug_unique` (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permisos`
--

LOCK TABLES `permisos` WRITE;
/*!40000 ALTER TABLE `permisos` DISABLE KEYS */;
/*!40000 ALTER TABLE `permisos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) unsigned NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (8,'App\\Models\\User',3,'auth-token','8ff64650e65c428630dd46c5bc72176701bd50c0287a11fdc81c4efdb5609dec','[\"*\"]','2026-05-30 02:13:07',NULL,'2026-05-30 01:59:52','2026-05-30 02:13:07'),(62,'App\\Models\\User',2,'auth-token','852f3764b5724571a128d65d6d552d2b66c5677312945a6ff647bf87d4cefcbb','[\"*\"]','2026-07-04 02:34:06',NULL,'2026-07-04 02:33:57','2026-07-04 02:34:06'),(78,'App\\Models\\User',1,'auth-token','fb54262818983410263a50d13f1acd05e5fe9a3556292d8c148b05c56329612e','[\"*\"]','2026-07-14 17:10:33',NULL,'2026-07-14 17:10:29','2026-07-14 17:10:33');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `planilla_configuraciones`
--

DROP TABLE IF EXISTS `planilla_configuraciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `planilla_configuraciones` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `empleado_id` bigint(20) unsigned NOT NULL,
  `plantilla_id` bigint(20) unsigned DEFAULT NULL,
  `formula_texto` text DEFAULT NULL,
  `formula_tokens` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`formula_tokens`)),
  `tipo_salario` enum('fijo','por_hora','por_comision','mixto') NOT NULL DEFAULT 'fijo',
  `jornada_laboral` decimal(4,1) NOT NULL DEFAULT 8.0,
  `pago_por_hora` decimal(12,2) DEFAULT NULL,
  `pago_diario` decimal(12,2) DEFAULT NULL,
  `pago_semanal` decimal(12,2) DEFAULT NULL,
  `pago_quincenal` decimal(12,2) DEFAULT NULL,
  `pago_mensual` decimal(12,2) DEFAULT NULL,
  `metodo_pago` enum('diario','semanal','quincenal','mensual') NOT NULL DEFAULT 'quincenal',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `configuracion_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`configuracion_json`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `planilla_configuraciones_empleado_id_unique` (`empleado_id`),
  KEY `planilla_configuraciones_plantilla_id_foreign` (`plantilla_id`),
  CONSTRAINT `planilla_configuraciones_empleado_id_foreign` FOREIGN KEY (`empleado_id`) REFERENCES `empleados` (`id`) ON DELETE CASCADE,
  CONSTRAINT `planilla_configuraciones_plantilla_id_foreign` FOREIGN KEY (`plantilla_id`) REFERENCES `planilla_plantillas` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `planilla_configuraciones`
--

LOCK TABLES `planilla_configuraciones` WRITE;
/*!40000 ALTER TABLE `planilla_configuraciones` DISABLE KEYS */;
INSERT INTO `planilla_configuraciones` VALUES (1,1,NULL,'salario_base + monto_horas_extra + bonificaciones + comisiones + incentivos - ccss - impuesto_renta - rebajos - embargos - otras_deducciones + otros_ingresos',NULL,'fijo',8.0,NULL,NULL,NULL,NULL,NULL,'quincenal',1,NULL,'2026-07-04 02:32:57','2026-07-04 02:32:57');
/*!40000 ALTER TABLE `planilla_configuraciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `planilla_historial`
--

DROP TABLE IF EXISTS `planilla_historial`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `planilla_historial` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `empleado_id` bigint(20) unsigned NOT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `tipo_cambio` enum('formula','configuracion','plantilla') NOT NULL,
  `formula_anterior` text DEFAULT NULL,
  `formula_nueva` text DEFAULT NULL,
  `configuracion_anterior` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`configuracion_anterior`)),
  `configuracion_nueva` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`configuracion_nueva`)),
  `motivo` text DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `user_agent` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `planilla_historial_usuario_id_foreign` (`usuario_id`),
  KEY `planilla_historial_empleado_id_created_at_index` (`empleado_id`,`created_at`),
  CONSTRAINT `planilla_historial_empleado_id_foreign` FOREIGN KEY (`empleado_id`) REFERENCES `empleados` (`id`) ON DELETE CASCADE,
  CONSTRAINT `planilla_historial_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `planilla_historial`
--

LOCK TABLES `planilla_historial` WRITE;
/*!40000 ALTER TABLE `planilla_historial` DISABLE KEYS */;
/*!40000 ALTER TABLE `planilla_historial` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `planilla_pagos`
--

DROP TABLE IF EXISTS `planilla_pagos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `planilla_pagos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `periodo` varchar(255) NOT NULL,
  `fecha_pago` date NOT NULL,
  `empleado_id` bigint(20) unsigned NOT NULL,
  `salario_base` decimal(12,2) NOT NULL,
  `horas_extra` decimal(12,2) NOT NULL DEFAULT 0.00,
  `comisiones` decimal(12,2) NOT NULL DEFAULT 0.00,
  `bonificaciones` decimal(12,2) NOT NULL DEFAULT 0.00,
  `ccss_patronal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `ccss_obrero` decimal(12,2) NOT NULL DEFAULT 0.00,
  `impuesto_renta` decimal(12,2) NOT NULL DEFAULT 0.00,
  `salario_neto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `incentivos` decimal(12,2) NOT NULL DEFAULT 0.00,
  `rebajos` decimal(12,2) NOT NULL DEFAULT 0.00,
  `embargos` decimal(12,2) NOT NULL DEFAULT 0.00,
  `vacaciones` decimal(12,2) NOT NULL DEFAULT 0.00,
  `aguinaldo` decimal(12,2) NOT NULL DEFAULT 0.00,
  `horas_dobles_cantidad` decimal(10,2) NOT NULL DEFAULT 0.00,
  `horas_dobles_monto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `horas_nocturnas_cantidad` decimal(10,2) NOT NULL DEFAULT 0.00,
  `horas_nocturnas_monto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `otros_ingresos` decimal(12,2) NOT NULL DEFAULT 0.00,
  `otras_deducciones` decimal(12,2) NOT NULL DEFAULT 0.00,
  `detalle_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`detalle_json`)),
  `deducciones` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total_pagar` decimal(12,2) NOT NULL,
  `detalle_deducciones` text DEFAULT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'pendiente',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `planilla_pagos_empleado_id_foreign` (`empleado_id`),
  CONSTRAINT `planilla_pagos_empleado_id_foreign` FOREIGN KEY (`empleado_id`) REFERENCES `empleados` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `planilla_pagos`
--

LOCK TABLES `planilla_pagos` WRITE;
/*!40000 ALTER TABLE `planilla_pagos` DISABLE KEYS */;
/*!40000 ALTER TABLE `planilla_pagos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `planilla_plantilla_empleados`
--

DROP TABLE IF EXISTS `planilla_plantilla_empleados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `planilla_plantilla_empleados` (
  `plantilla_id` bigint(20) unsigned NOT NULL,
  `empleado_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`plantilla_id`,`empleado_id`),
  KEY `planilla_plantilla_empleados_empleado_id_foreign` (`empleado_id`),
  CONSTRAINT `planilla_plantilla_empleados_empleado_id_foreign` FOREIGN KEY (`empleado_id`) REFERENCES `empleados` (`id`) ON DELETE CASCADE,
  CONSTRAINT `planilla_plantilla_empleados_plantilla_id_foreign` FOREIGN KEY (`plantilla_id`) REFERENCES `planilla_plantillas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `planilla_plantilla_empleados`
--

LOCK TABLES `planilla_plantilla_empleados` WRITE;
/*!40000 ALTER TABLE `planilla_plantilla_empleados` DISABLE KEYS */;
/*!40000 ALTER TABLE `planilla_plantilla_empleados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `planilla_plantillas`
--

DROP TABLE IF EXISTS `planilla_plantillas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `planilla_plantillas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `formula_texto` text NOT NULL,
  `formula_tokens` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`formula_tokens`)),
  `configuracion_base` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`configuracion_base`)),
  `es_sistema` tinyint(1) NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `planilla_plantillas_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `planilla_plantillas_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `planilla_plantillas`
--

LOCK TABLES `planilla_plantillas` WRITE;
/*!40000 ALTER TABLE `planilla_plantillas` DISABLE KEYS */;
/*!40000 ALTER TABLE `planilla_plantillas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `planilla_variables`
--

DROP TABLE IF EXISTS `planilla_variables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `planilla_variables` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `clave` varchar(255) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `tipo` enum('ingreso','deduccion','operacion','custom') NOT NULL DEFAULT 'custom',
  `es_sistema` tinyint(1) NOT NULL DEFAULT 0,
  `formula_default` text DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `planilla_variables_clave_unique` (`clave`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `planilla_variables`
--

LOCK TABLES `planilla_variables` WRITE;
/*!40000 ALTER TABLE `planilla_variables` DISABLE KEYS */;
/*!40000 ALTER TABLE `planilla_variables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plantillas_email`
--

DROP TABLE IF EXISTS `plantillas_email`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plantillas_email` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `asunto` varchar(255) DEFAULT NULL,
  `contenido_html` longtext NOT NULL,
  `contenido_json` longtext DEFAULT NULL,
  `categoria` varchar(50) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `plantillas_email_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `plantillas_email_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plantillas_email`
--

LOCK TABLES `plantillas_email` WRITE;
/*!40000 ALTER TABLE `plantillas_email` DISABLE KEYS */;
/*!40000 ALTER TABLE `plantillas_email` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `presupuesto_detalle`
--

DROP TABLE IF EXISTS `presupuesto_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `presupuesto_detalle` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `presupuesto_id` bigint(20) unsigned NOT NULL,
  `categoria` varchar(255) NOT NULL,
  `monto_asignado` decimal(14,2) NOT NULL DEFAULT 0.00,
  `monto_ejecutado` decimal(14,2) NOT NULL DEFAULT 0.00,
  `notas` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `presupuesto_detalle_presupuesto_id_foreign` (`presupuesto_id`),
  CONSTRAINT `presupuesto_detalle_presupuesto_id_foreign` FOREIGN KEY (`presupuesto_id`) REFERENCES `presupuestos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `presupuesto_detalle`
--

LOCK TABLES `presupuesto_detalle` WRITE;
/*!40000 ALTER TABLE `presupuesto_detalle` DISABLE KEYS */;
/*!40000 ALTER TABLE `presupuesto_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `presupuestos`
--

DROP TABLE IF EXISTS `presupuestos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `presupuestos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `periodo` varchar(20) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `monto_total` decimal(14,2) NOT NULL DEFAULT 0.00,
  `monto_ejecutado` decimal(14,2) NOT NULL DEFAULT 0.00,
  `estado` varchar(255) NOT NULL DEFAULT 'activo',
  `notas` text DEFAULT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `presupuestos_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `presupuestos_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `presupuestos`
--

LOCK TABLES `presupuestos` WRITE;
/*!40000 ALTER TABLE `presupuestos` DISABLE KEYS */;
/*!40000 ALTER TABLE `presupuestos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productividad_resumen`
--

DROP TABLE IF EXISTS `productividad_resumen`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `productividad_resumen` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint(20) unsigned NOT NULL,
  `fecha` date NOT NULL,
  `periodo` enum('dia','semana','mes','historico') NOT NULL,
  `total_minutos` int(10) unsigned NOT NULL DEFAULT 0,
  `total_sesiones` int(10) unsigned NOT NULL DEFAULT 0,
  `ventas_generadas` decimal(12,2) NOT NULL DEFAULT 0.00,
  `cantidad_ventas` int(10) unsigned NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `productividad_resumen_usuario_id_fecha_periodo_unique` (`usuario_id`,`fecha`,`periodo`),
  KEY `productividad_resumen_fecha_periodo_index` (`fecha`,`periodo`),
  CONSTRAINT `productividad_resumen_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productividad_resumen`
--

LOCK TABLES `productividad_resumen` WRITE;
/*!40000 ALTER TABLE `productividad_resumen` DISABLE KEYS */;
INSERT INTO `productividad_resumen` VALUES (1,2,'2026-07-02','dia',0,1,0.00,0,NULL,'2026-07-02 15:34:54'),(2,2,'2026-06-29','semana',2,3,0.00,0,NULL,'2026-07-04 02:39:39'),(3,2,'2026-07-01','mes',2,3,0.00,0,NULL,'2026-07-04 02:39:39'),(4,2,'1970-01-01','historico',2,3,0.00,0,NULL,'2026-07-04 02:39:39'),(5,2,'2026-07-03','dia',2,2,0.00,0,NULL,'2026-07-04 02:39:39'),(6,1,'2026-07-03','dia',9,3,0.00,0,NULL,'2026-07-04 03:41:53'),(7,1,'2026-06-29','semana',9,3,0.00,0,NULL,'2026-07-04 03:41:53'),(8,1,'2026-07-01','mes',9,3,0.00,0,NULL,'2026-07-04 03:41:53'),(9,1,'1970-01-01','historico',9,3,0.00,0,NULL,'2026-07-04 03:41:53');
/*!40000 ALTER TABLE `productividad_resumen` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productividad_sesiones`
--

DROP TABLE IF EXISTS `productividad_sesiones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `productividad_sesiones` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint(20) unsigned NOT NULL,
  `inicio_sesion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `fin_sesion` timestamp NULL DEFAULT NULL,
  `ultima_actividad` timestamp NULL DEFAULT NULL,
  `tiempo_activo` int(10) unsigned NOT NULL DEFAULT 0 COMMENT 'Accumulated active time in seconds',
  `en_pausa` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Whether the session is currently paused',
  `tab_id` varchar(36) DEFAULT NULL COMMENT 'Unique browser tab identifier',
  `duracion_minutos` int(11) DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `user_agent` varchar(500) DEFAULT NULL,
  `ventas_generadas` decimal(12,2) NOT NULL DEFAULT 0.00,
  `cantidad_ventas` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `productividad_sesiones_usuario_id_index` (`usuario_id`),
  CONSTRAINT `productividad_sesiones_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=229 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productividad_sesiones`
--

LOCK TABLES `productividad_sesiones` WRITE;
/*!40000 ALTER TABLE `productividad_sesiones` DISABLE KEYS */;
INSERT INTO `productividad_sesiones` VALUES (1,1,'2026-05-22 05:31:25','2026-05-22 11:31:25',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(2,1,'2026-05-22 18:32:24','2026-05-23 00:32:24',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',9040.00,1),(3,2,'2026-05-22 21:55:11','2026-05-23 03:55:11',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(4,1,'2026-05-22 18:41:54','2026-05-23 00:41:54',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(5,1,'2026-05-29 19:22:16','2026-05-30 01:22:16',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(6,2,'2026-06-02 01:14:40','2026-06-02 07:14:40',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(7,1,'2026-06-03 16:41:13','2026-06-03 22:41:13',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(8,3,'2026-07-04 02:19:01','2026-07-04 02:19:01',NULL,0,1,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(9,2,'2026-06-06 22:57:38','2026-06-06 22:57:38',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(10,1,'2026-06-03 16:46:37','2026-06-03 22:46:37',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(11,1,'2026-06-03 16:46:53','2026-06-03 22:46:53',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(12,1,'2026-06-03 16:47:00','2026-06-03 22:47:00',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(13,1,'2026-06-03 16:48:01','2026-06-03 22:48:01',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(14,1,'2026-06-03 16:49:55','2026-06-03 22:49:55',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(15,1,'2026-06-03 17:55:30','2026-06-03 23:55:30',NULL,0,0,NULL,66,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(16,1,'2026-06-03 18:05:18','2026-06-04 00:05:18',NULL,0,0,NULL,10,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(17,1,'2026-06-03 18:31:02','2026-06-04 00:31:02',NULL,0,0,NULL,26,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(18,1,'2026-06-03 18:37:25','2026-06-04 00:37:25',NULL,0,0,NULL,6,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(19,1,'2026-06-03 18:38:57','2026-06-04 00:38:57',NULL,0,0,NULL,2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(20,1,'2026-06-03 18:40:48','2026-06-04 00:40:48',NULL,0,0,NULL,2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(21,1,'2026-06-03 19:03:46','2026-06-04 01:03:46',NULL,0,0,NULL,23,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(22,1,'2026-06-03 19:11:36','2026-06-04 01:11:36',NULL,0,0,NULL,8,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(23,1,'2026-06-03 19:11:59','2026-06-04 01:11:59',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(24,1,'2026-06-03 20:13:20','2026-06-04 02:13:20',NULL,0,0,NULL,61,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(25,1,'2026-06-03 20:14:59','2026-06-04 02:14:59',NULL,0,0,NULL,2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(26,1,'2026-06-03 20:15:21','2026-06-04 02:15:21',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(27,1,'2026-06-03 22:04:28','2026-06-04 04:04:28',NULL,0,0,NULL,109,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(28,1,'2026-06-03 22:39:38','2026-06-04 04:39:38',NULL,0,0,NULL,35,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(29,1,'2026-06-04 00:29:22','2026-06-04 06:29:22',NULL,0,0,NULL,110,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(30,1,'2026-06-04 00:29:28','2026-06-04 06:29:28',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(31,1,'2026-06-04 00:42:07','2026-06-04 06:42:07',NULL,0,0,NULL,13,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(32,1,'2026-06-04 00:42:15','2026-06-04 06:42:15',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36',0.00,0),(33,1,'2026-06-04 00:42:50','2026-06-04 06:42:50',NULL,0,0,NULL,1,'127.0.0.1','Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36',0.00,0),(34,1,'2026-06-04 00:47:46','2026-06-04 00:47:46',NULL,0,0,NULL,480,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(35,1,'2026-06-04 00:48:11','2026-06-04 00:48:11',NULL,0,0,NULL,480,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(36,1,'2026-06-04 00:48:18','2026-06-04 00:48:18',NULL,0,0,NULL,480,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(37,1,'2026-06-04 00:49:58','2026-06-04 00:49:58',NULL,0,0,NULL,480,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(38,1,'2026-06-04 00:50:02','2026-06-04 00:50:02',NULL,0,0,NULL,480,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(39,1,'2026-06-04 00:50:09','2026-06-04 00:50:09',NULL,0,0,NULL,480,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(40,1,'2026-06-04 01:05:13','2026-06-04 01:05:13',NULL,0,0,NULL,480,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(41,1,'2026-06-04 01:07:15','2026-06-04 01:07:15',NULL,0,0,NULL,480,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(42,1,'2026-06-04 01:20:26','2026-06-04 01:20:26',NULL,0,0,NULL,480,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(43,1,'2026-06-04 01:23:04','2026-06-04 01:23:04',NULL,0,0,NULL,480,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(44,1,'2026-06-04 01:25:04','2026-06-04 01:25:04',NULL,0,0,NULL,480,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(45,1,'2026-06-04 01:30:42','2026-06-04 01:30:42',NULL,0,0,NULL,480,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(46,1,'2026-06-04 01:35:07','2026-06-04 01:35:07',NULL,0,0,NULL,480,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(47,1,'2026-06-04 01:44:08','2026-06-04 01:44:08',NULL,0,0,NULL,480,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(48,1,'2026-06-04 01:50:11','2026-06-04 01:50:11',NULL,0,0,NULL,480,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(49,1,'2026-06-04 01:52:52','2026-06-04 01:52:52',NULL,0,0,NULL,480,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(50,1,'2026-06-04 01:56:42','2026-06-04 01:56:42',NULL,0,0,NULL,1196,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(51,1,'2026-06-04 02:02:24','2026-06-04 02:02:24',NULL,0,0,NULL,1202,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(52,1,'2026-06-04 02:09:21','2026-06-04 02:09:21',NULL,0,0,NULL,1209,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(53,1,'2026-06-04 02:44:14','2026-06-04 02:44:14',NULL,0,0,NULL,1244,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(54,1,'2026-06-04 03:07:25','2026-06-04 03:07:25',NULL,0,0,NULL,1267,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(55,1,'2026-06-04 03:32:01','2026-06-04 03:32:01',NULL,0,0,NULL,1292,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(56,1,'2026-06-04 03:46:10','2026-06-04 03:46:10',NULL,0,0,NULL,1306,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(57,1,'2026-06-04 03:55:04','2026-06-04 03:55:04',NULL,0,0,NULL,1315,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(58,1,'2026-06-04 17:54:29','2026-06-04 17:54:29',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(59,1,'2026-06-05 08:36:58','2026-06-05 08:36:58',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36',0.00,0),(60,1,'2026-06-05 08:57:07','2026-06-05 08:57:07',NULL,0,0,NULL,177,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(61,1,'2026-06-05 09:27:06','2026-06-05 09:27:06',NULL,0,0,NULL,207,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(62,1,'2026-06-05 10:08:28','2026-06-05 10:08:28',NULL,0,0,NULL,248,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(63,1,'2026-06-05 10:17:47','2026-06-05 10:17:47',NULL,0,0,NULL,257,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(64,1,'2026-06-05 10:21:37','2026-06-05 10:21:37',NULL,0,0,NULL,261,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(65,1,'2026-06-05 10:26:03','2026-06-05 10:26:03',NULL,0,0,NULL,266,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(66,1,'2026-06-05 10:30:53','2026-06-05 10:30:53',NULL,0,0,NULL,270,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(67,1,'2026-06-05 11:59:04','2026-06-05 11:59:04',NULL,0,0,NULL,359,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(68,1,'2026-06-05 15:11:13','2026-06-05 15:11:13',NULL,0,0,NULL,551,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(69,1,'2026-06-06 20:18:07','2026-06-06 20:18:07',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(70,1,'2026-06-06 22:19:32','2026-06-06 22:19:32',NULL,0,0,NULL,979,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(71,1,'2026-06-06 22:21:48','2026-06-06 22:21:48',NULL,0,0,NULL,981,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(72,1,'2026-06-06 23:03:39','2026-06-06 23:03:39',NULL,0,0,NULL,1023,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(73,2,'2026-06-06 22:59:44','2026-06-06 22:59:44',NULL,0,0,NULL,1019,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(74,2,'2026-06-11 23:09:31','2026-06-11 23:09:31',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(75,1,'2026-06-06 23:09:13','2026-06-06 23:09:13',NULL,0,0,NULL,1029,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(76,1,'2026-06-06 23:33:21','2026-06-06 23:33:21',NULL,0,0,NULL,1053,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(77,1,'2026-06-06 23:46:00','2026-06-06 23:46:00',NULL,0,0,NULL,1066,'127.0.0.1','Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36',0.00,0),(78,1,'2026-06-11 18:29:14','2026-06-11 18:29:14',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(79,1,'2026-06-11 18:33:38','2026-06-11 18:33:38',NULL,0,0,NULL,753,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(80,1,'2026-06-11 18:37:58','2026-06-11 18:37:58',NULL,0,0,NULL,757,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(81,1,'2026-06-11 19:13:13','2026-06-11 19:13:13',NULL,0,0,NULL,793,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(82,1,'2026-06-11 19:50:56','2026-06-11 19:50:56',NULL,0,0,NULL,830,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(83,1,'2026-06-11 19:57:45','2026-06-11 19:57:45',NULL,0,0,NULL,837,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(84,1,'2026-06-11 20:05:22','2026-06-11 20:05:22',NULL,0,0,NULL,845,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(85,1,'2026-06-11 20:07:36','2026-06-11 20:07:36',NULL,0,0,NULL,847,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(86,1,'2026-06-11 20:10:15','2026-06-11 20:10:15',NULL,0,0,NULL,850,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(87,1,'2026-06-11 20:21:23','2026-06-11 20:21:23',NULL,0,0,NULL,861,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(88,1,'2026-06-11 20:24:14','2026-06-11 20:24:14',NULL,0,0,NULL,864,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(89,1,'2026-06-11 20:27:45','2026-06-11 20:27:45',NULL,0,0,NULL,867,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(90,1,'2026-06-11 20:35:21','2026-06-11 20:35:21',NULL,0,0,NULL,875,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(91,1,'2026-06-11 20:43:49','2026-06-11 20:43:49',NULL,0,0,NULL,883,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(92,1,'2026-06-11 20:46:51','2026-06-11 20:46:51',NULL,0,0,NULL,886,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(93,1,'2026-06-11 20:55:48','2026-06-11 20:55:48',NULL,0,0,NULL,895,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(94,1,'2026-06-11 21:39:55','2026-06-11 21:39:55',NULL,0,0,NULL,939,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(95,1,'2026-06-11 21:46:54','2026-06-11 21:46:54',NULL,0,0,NULL,946,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(96,1,'2026-06-11 22:02:19','2026-06-11 22:02:19',NULL,0,0,NULL,962,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(97,1,'2026-06-11 23:05:16','2026-06-11 23:05:16',NULL,0,0,NULL,1025,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(98,1,'2026-06-11 23:08:58','2026-06-11 23:08:58',NULL,0,0,NULL,1028,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(99,1,'2026-06-11 23:31:32','2026-06-11 23:31:32',NULL,0,0,NULL,1051,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(100,2,'2026-06-11 23:11:40','2026-06-11 23:11:40',NULL,0,0,NULL,1031,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(101,2,'2026-06-11 23:33:53','2026-06-11 23:33:53',NULL,0,0,NULL,1053,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(102,1,'2026-06-11 23:33:53','2026-06-11 23:33:53',NULL,0,0,NULL,1053,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(103,1,'2026-06-11 23:36:18','2026-06-11 23:36:18',NULL,0,0,NULL,1056,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(104,2,'2026-06-11 23:45:19','2026-06-11 23:45:19',NULL,0,0,NULL,1065,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(105,1,'2026-06-11 23:41:40','2026-06-11 23:41:40',NULL,0,0,NULL,1061,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(106,1,'2026-06-12 04:04:59','2026-06-12 04:04:59',NULL,0,0,NULL,1324,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(107,2,'2026-06-12 04:04:45','2026-06-12 04:04:45',NULL,0,0,NULL,1324,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(108,2,'2026-06-12 04:14:11','2026-06-12 04:14:11',NULL,0,0,NULL,1334,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(109,1,'2026-06-12 04:09:06','2026-06-12 04:09:06',NULL,0,0,NULL,1329,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(110,1,'2026-06-15 16:10:30','2026-06-15 16:10:30',NULL,0,0,NULL,5041,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(111,2,'2026-06-15 16:32:41','2026-06-15 16:32:41',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(112,1,'2026-06-15 22:05:13','2026-06-15 22:05:13',NULL,0,0,NULL,965,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(113,2,'2026-06-15 16:37:30','2026-06-15 16:37:30',NULL,0,0,NULL,637,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(114,2,'2026-06-29 18:07:31','2026-06-29 18:07:31',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(115,1,'2026-06-16 00:26:08','2026-06-16 00:26:08',NULL,0,0,NULL,1106,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(116,1,'2026-06-29 18:07:14','2026-06-29 18:07:14',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(117,1,'2026-06-29 18:10:47','2026-06-29 18:10:47',NULL,0,0,NULL,730,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(118,2,'2026-06-29 18:10:47','2026-06-29 18:10:47',NULL,0,0,NULL,730,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(119,2,'2026-06-29 18:14:41','2026-06-29 18:14:41',NULL,0,0,NULL,734,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(120,1,'2026-06-29 18:14:35','2026-06-29 18:14:35',NULL,0,0,NULL,734,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(121,1,'2026-06-29 18:17:22','2026-06-29 18:17:22',NULL,0,0,NULL,737,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(122,2,'2026-06-29 18:17:21','2026-06-29 18:17:21',NULL,0,0,NULL,737,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(123,2,'2026-06-29 18:22:23','2026-06-29 18:22:23',NULL,0,0,NULL,742,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(124,1,'2026-06-29 18:22:23','2026-06-29 18:22:23',NULL,0,0,NULL,742,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(125,1,'2026-06-29 18:49:15','2026-06-29 18:49:15',NULL,0,0,NULL,769,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(126,2,'2026-06-29 18:50:58','2026-06-29 18:50:58',NULL,0,0,NULL,770,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(127,1,'2026-06-29 18:50:19','2026-06-29 18:50:19',NULL,0,0,NULL,1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(128,2,'2026-06-29 19:14:53','2026-06-29 19:14:53',NULL,0,0,NULL,794,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(129,1,'2026-06-29 18:55:52','2026-06-29 18:55:52',NULL,0,0,NULL,775,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(130,1,'2026-06-29 19:14:53','2026-06-29 19:14:53',NULL,0,0,NULL,794,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(131,2,'2026-06-29 19:21:20','2026-06-29 19:21:20',NULL,0,0,NULL,801,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(132,1,'2026-06-29 19:28:03','2026-06-29 19:28:03',NULL,0,0,NULL,808,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(133,2,'2026-06-29 21:57:52','2026-06-29 21:57:52',NULL,0,0,NULL,957,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(134,1,'2026-06-29 19:51:00','2026-06-29 19:51:00',NULL,0,0,NULL,831,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(135,1,'2026-06-29 19:57:59','2026-06-29 19:57:59',NULL,0,0,NULL,837,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(136,1,'2026-06-29 20:17:25','2026-06-29 20:17:25',NULL,0,0,NULL,857,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(137,1,'2026-06-29 21:52:06','2026-06-29 21:52:06',NULL,0,0,NULL,952,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(138,1,'2026-06-29 21:52:39','2026-06-29 21:52:39',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(139,1,'2026-06-29 21:55:40','2026-06-29 21:55:40',NULL,0,0,NULL,955,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(140,1,'2026-06-29 21:57:52','2026-06-29 21:57:52',NULL,0,0,NULL,957,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(141,1,'2026-06-29 22:10:06','2026-06-29 22:10:06',NULL,0,0,NULL,970,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(142,2,'2026-07-02 12:59:50','2026-07-02 12:59:50',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(143,1,'2026-06-29 22:23:12','2026-06-29 22:23:12',NULL,0,0,NULL,983,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(144,1,'2026-06-29 22:27:53','2026-06-29 22:27:53',NULL,0,0,NULL,987,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(145,1,'2026-06-30 20:52:57','2026-06-30 20:52:57',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(146,1,'2026-07-02 13:00:15','2026-07-02 13:00:15',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(147,2,'2026-07-02 12:59:56','2026-07-02 12:59:56',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(148,1,'2026-07-02 13:10:20','2026-07-02 13:10:20',NULL,0,0,NULL,430,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(149,1,'2026-07-02 13:18:13','2026-07-02 13:18:13',NULL,0,0,NULL,438,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(150,1,'2026-07-02 14:25:26','2026-07-02 14:25:26',NULL,0,0,NULL,505,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(151,1,'2026-07-02 14:25:48','2026-07-02 14:25:48',NULL,0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(152,1,'2026-07-02 14:28:10','2026-07-02 14:28:10',NULL,0,0,NULL,508,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(153,1,'2026-07-02 15:20:53','2026-07-02 15:20:53',NULL,0,0,NULL,560,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(154,1,'2026-07-02 15:28:41','2026-07-02 15:28:41',NULL,0,0,NULL,568,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(155,1,'2026-07-02 15:33:44','2026-07-02 15:33:44',NULL,0,0,NULL,5,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(156,1,'2026-07-02 16:45:59','2026-07-02 16:45:59','2026-07-02 15:35:38',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(157,2,'2026-07-02 15:34:54','2026-07-02 15:34:54','2026-07-02 15:34:33',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(158,2,'2026-07-02 16:46:30','2026-07-02 16:46:30','2026-07-02 15:40:27',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(159,1,'2026-07-02 16:46:01','2026-07-02 16:46:01','2026-07-02 16:46:00',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(160,1,'2026-07-02 16:46:15','2026-07-02 16:46:15','2026-07-02 16:46:01',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(161,1,'2026-07-02 16:46:17','2026-07-02 16:46:17','2026-07-02 16:46:15',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(162,1,'2026-07-02 16:49:44','2026-07-02 16:49:44','2026-07-02 16:46:46',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(163,2,'2026-07-02 16:46:32','2026-07-02 16:46:32','2026-07-02 16:46:30',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(164,2,'2026-07-04 02:19:01','2026-07-04 02:19:01','2026-07-02 16:46:32',0,1,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(165,1,'2026-07-02 16:49:46','2026-07-02 16:49:46','2026-07-02 16:49:44',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(166,1,'2026-07-02 16:51:48','2026-07-02 16:51:48','2026-07-02 16:49:46',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(167,1,'2026-07-02 16:54:01','2026-07-02 16:54:01','2026-07-02 16:51:48',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(168,1,'2026-07-02 16:54:03','2026-07-02 16:54:03','2026-07-02 16:54:01',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(169,1,'2026-07-02 16:54:56','2026-07-02 16:54:56','2026-07-02 16:54:03',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(170,1,'2026-07-02 16:55:02','2026-07-02 16:55:02','2026-07-02 16:54:56',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(171,1,'2026-07-02 16:55:08','2026-07-02 16:55:08','2026-07-02 16:55:02',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(172,1,'2026-07-02 18:40:50','2026-07-02 18:40:50','2026-07-02 17:05:02',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(173,1,'2026-07-02 18:40:56','2026-07-02 18:40:56','2026-07-02 18:40:53',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(174,1,'2026-07-02 18:40:58','2026-07-02 18:40:58','2026-07-02 18:40:56',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(175,1,'2026-07-04 00:17:04','2026-07-04 00:17:04','2026-07-02 19:33:56',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(176,1,'2026-07-04 00:17:08','2026-07-04 00:17:08','2026-07-04 00:17:05',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(177,1,'2026-07-04 00:18:34','2026-07-04 00:18:34','2026-07-04 00:17:35',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(178,1,'2026-07-04 00:18:36','2026-07-04 00:18:36','2026-07-04 00:18:35',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(179,1,'2026-07-04 00:24:48','2026-07-04 00:24:48','2026-07-04 00:18:36',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(180,1,'2026-07-04 00:24:51','2026-07-04 00:24:51','2026-07-04 00:24:49',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(181,1,'2026-07-04 00:31:09','2026-07-04 00:31:09','2026-07-04 00:25:50',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(182,1,'2026-07-04 00:31:12','2026-07-04 00:31:12','2026-07-04 00:31:09',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(183,1,'2026-07-04 00:33:17','2026-07-04 00:33:17','2026-07-04 00:33:10',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(184,1,'2026-07-04 00:33:20','2026-07-04 00:33:20','2026-07-04 00:33:17',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(185,1,'2026-07-04 00:40:20','2026-07-04 00:40:20','2026-07-04 00:38:48',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(186,1,'2026-07-04 00:40:22','2026-07-04 00:40:22','2026-07-04 00:40:20',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(187,1,'2026-07-04 00:47:26','2026-07-04 00:47:26','2026-07-04 00:46:51',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(188,1,'2026-07-04 00:47:28','2026-07-04 00:47:28','2026-07-04 00:47:26',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(189,1,'2026-07-04 00:53:23','2026-07-04 00:53:23','2026-07-04 00:52:57',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(190,1,'2026-07-04 00:53:26','2026-07-04 00:53:26','2026-07-04 00:53:23',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(191,1,'2026-07-04 01:03:29','2026-07-04 01:03:29','2026-07-04 01:03:24',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(192,1,'2026-07-04 01:03:31','2026-07-04 01:03:31','2026-07-04 01:03:29',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(193,1,'2026-07-04 01:13:53','2026-07-04 01:13:53','2026-07-04 01:11:12',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(194,1,'2026-07-04 01:13:55','2026-07-04 01:13:55','2026-07-04 01:13:53',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(195,1,'2026-07-04 01:38:21','2026-07-04 01:38:21','2026-07-04 01:37:53',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(196,1,'2026-07-04 01:38:23','2026-07-04 01:38:23','2026-07-04 01:38:21',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(197,1,'2026-07-04 01:44:25','2026-07-04 01:44:25','2026-07-04 01:38:51',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(198,1,'2026-07-04 01:44:28','2026-07-04 01:44:28','2026-07-04 01:44:26',0,0,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(199,1,'2026-07-04 01:53:40','2026-07-04 01:53:40','2026-07-04 01:44:28',0,1,NULL,0,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(200,1,'2026-07-04 02:16:57','2026-07-04 02:16:57','2026-07-04 02:15:21',32,1,'tab_mr5pknkf_lkkvuo',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(201,1,'2026-07-04 02:19:57','2026-07-04 02:19:57','2026-07-04 02:19:52',5,1,'tab_mr5qd91d_m28s3m',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(202,1,'2026-07-04 02:20:37','2026-07-04 02:20:37','2026-07-04 02:20:28',18,1,'tab_mr5qigeq_ko7vpr',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(203,2,'2026-07-04 02:30:44','2026-07-04 02:30:44','2026-07-04 02:22:39',32,1,'tab_mr5qiy8n_p83iiv',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(204,1,'2026-07-04 02:21:28','2026-07-04 02:21:28','2026-07-04 02:21:24',11,1,'tab_mr5qj9n2_2nqrke',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(205,1,'2026-07-04 02:30:41','2026-07-04 02:30:41','2026-07-04 02:22:09',21,1,'tab_mr5qkevd_m81ry0',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(206,1,'2026-07-04 02:31:08','2026-07-04 02:31:08','2026-07-04 02:30:58',11,1,'tab_mr5qn17u_k1qvym',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(207,2,'2026-07-04 02:33:57','2026-07-04 02:33:57','2026-07-04 02:31:50',3,1,'tab_mr5qn1go_qnelg8',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(208,1,'2026-07-04 02:33:07','2026-07-04 02:33:07','2026-07-04 02:32:39',36,1,'tab_mr5qwuge_lfkwmw',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(209,1,'2026-07-04 02:33:20','2026-07-04 02:33:20','2026-07-04 02:33:08',12,1,'tab_mr5qzdzo_uge933',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(210,1,'2026-07-04 02:34:34','2026-07-04 02:34:34','2026-07-04 02:34:27',64,1,'tab_mr5qznu4_xrthet',2,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(211,2,'2026-07-04 02:39:39','2026-07-04 02:39:39','2026-07-04 02:34:06',3,1,'tab_mr5qzojj_bbx5q5',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36',0.00,0),(212,1,'2026-07-04 02:40:10','2026-07-04 02:40:10','2026-07-04 02:40:05',34,1,'tab_mr5r19rg_grfpfo',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(213,1,'2026-07-04 02:42:08','2026-07-04 02:42:08','2026-07-04 02:42:00',34,1,'tab_mr5r8fm6_rfj5nv',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(214,1,'2026-07-04 03:13:53','2026-07-04 03:13:53','2026-07-04 03:08:03',175,1,'tab_mr5rayyw_e9audg',3,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(215,1,'2026-07-04 03:27:53','2026-07-04 03:27:53','2026-07-04 03:22:03',176,1,'tab_mr5rayyw_e9audg',3,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(216,1,'2026-07-04 03:41:53','2026-07-04 03:41:53','2026-07-04 03:36:24',176,1,'tab_mr5rayyw_e9audg',3,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(217,1,'2026-07-04 23:30:22','2026-07-04 23:30:22','2026-07-04 23:30:07',181,1,'tab_mr6zp1gp_4jzvkm',4,'127.0.0.1','Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36',0.00,0),(218,1,'2026-07-05 05:47:29','2026-07-05 05:47:29','2026-07-04 23:31:04',29,1,'tab_mr6zw88q_0gdnim',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(219,1,'2026-07-13 17:19:36','2026-07-13 17:19:36','2026-07-05 07:19:58',5,1,'tab_mr7damk1_v9t6a0',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(220,1,'2026-07-13 17:27:59','2026-07-13 17:27:59','2026-07-13 17:27:52',162,1,'tab_mrjhm0z0_5wradq',3,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(221,1,'2026-07-13 17:28:57','2026-07-13 17:28:57','2026-07-13 17:28:46',57,1,'tab_mrjhwv31_6vdi0a',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(222,1,'2026-07-13 17:29:21','2026-07-13 17:29:21','2026-07-13 17:28:58',23,1,'tab_mrjhy35e_7ssbek',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(223,1,'2026-07-13 17:40:00','2026-07-13 17:40:00','2026-07-13 17:32:48',30,1,'tab_mrjhymkl_4m4t3z',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(224,1,'2026-07-13 18:00:21','2026-07-13 18:00:21','2026-07-13 18:00:17',218,1,'tab_mrji3kcz_qvo4un',4,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(225,1,'2026-07-13 18:05:00','2026-07-13 18:05:00','2026-07-13 18:04:56',106,1,'tab_mrjj2h3h_w86awi',2,'127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',0.00,0),(226,1,'2026-07-13 18:48:03','2026-07-13 18:48:03','2026-07-13 18:09:57',167,1,'tab_mrjj8g7s_pbkkrg',3,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(227,1,'2026-07-14 17:10:29','2026-07-14 17:10:29','2026-07-13 18:49:34',33,1,'tab_mrjkrtwo_zrea0w',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0),(228,1,'2026-07-14 17:10:30',NULL,'2026-07-14 17:10:30',0,0,'tab_mrkwq5wd_efqbn3',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36',0.00,0);
/*!40000 ALTER TABLE `productividad_sesiones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `producto_imagenes`
--

DROP TABLE IF EXISTS `producto_imagenes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `producto_imagenes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `producto_id` bigint(20) unsigned NOT NULL,
  `ruta` varchar(255) NOT NULL,
  `es_principal` tinyint(1) NOT NULL DEFAULT 0,
  `orden` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `producto_imagenes_producto_id_foreign` (`producto_id`),
  CONSTRAINT `producto_imagenes_producto_id_foreign` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `producto_imagenes`
--

LOCK TABLES `producto_imagenes` WRITE;
/*!40000 ALTER TABLE `producto_imagenes` DISABLE KEYS */;
/*!40000 ALTER TABLE `producto_imagenes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `producto_variantes`
--

DROP TABLE IF EXISTS `producto_variantes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `producto_variantes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `producto_id` bigint(20) unsigned NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `tipo` varchar(255) DEFAULT NULL,
  `valor` varchar(255) DEFAULT NULL,
  `sku` varchar(255) DEFAULT NULL,
  `precio_adicional` decimal(12,2) NOT NULL DEFAULT 0.00,
  `stock` int(11) NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `producto_variantes_producto_id_foreign` (`producto_id`),
  CONSTRAINT `producto_variantes_producto_id_foreign` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `producto_variantes`
--

LOCK TABLES `producto_variantes` WRITE;
/*!40000 ALTER TABLE `producto_variantes` DISABLE KEYS */;
/*!40000 ALTER TABLE `producto_variantes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productos`
--

DROP TABLE IF EXISTS `productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `productos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `codigo` varchar(255) DEFAULT NULL,
  `codigo_barras` varchar(255) DEFAULT NULL,
  `nombre` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `categoria_id` bigint(20) unsigned DEFAULT NULL,
  `proveedor_id` bigint(20) unsigned DEFAULT NULL,
  `precio_compra` decimal(12,2) NOT NULL DEFAULT 0.00,
  `precio_venta` decimal(12,2) NOT NULL DEFAULT 0.00,
  `stock` int(11) NOT NULL DEFAULT 0,
  `stock_minimo` int(11) NOT NULL DEFAULT 0,
  `stock_maximo` int(11) DEFAULT NULL,
  `unidad` varchar(255) DEFAULT NULL,
  `imagen` varchar(255) DEFAULT NULL,
  `impuesto` decimal(5,2) NOT NULL DEFAULT 0.00,
  `margen_ganancia` decimal(5,2) DEFAULT NULL,
  `peso` decimal(8,2) DEFAULT NULL,
  `costo_envio` decimal(12,2) DEFAULT NULL,
  `costo_marketing` decimal(12,2) DEFAULT NULL,
  `costo_logistica` decimal(12,2) DEFAULT NULL,
  `visible_web` tinyint(1) NOT NULL DEFAULT 0,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `productos_codigo_unique` (`codigo`),
  KEY `productos_categoria_id_foreign` (`categoria_id`),
  KEY `productos_proveedor_id_foreign` (`proveedor_id`),
  CONSTRAINT `productos_categoria_id_foreign` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`) ON DELETE SET NULL,
  CONSTRAINT `productos_proveedor_id_foreign` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedores` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productos`
--

LOCK TABLES `productos` WRITE;
/*!40000 ALTER TABLE `productos` DISABLE KEYS */;
INSERT INTO `productos` VALUES (1,'camisa1',NULL,'Camisa',NULL,1,NULL,2000.00,8000.00,39,10,NULL,NULL,NULL,13.00,NULL,NULL,NULL,NULL,NULL,0,1,'2026-05-22 23:51:43','2026-06-06 20:24:47'),(2,'Botella Negra',NULL,'Botella de metal',NULL,NULL,1,1500.00,4500.00,20,10,NULL,NULL,NULL,13.00,NULL,NULL,NULL,NULL,NULL,0,1,'2026-06-04 00:47:11','2026-06-15 16:19:27');
/*!40000 ALTER TABLE `productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `promociones`
--

DROP TABLE IF EXISTS `promociones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `promociones` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `tipo_descuento` varchar(255) NOT NULL,
  `valor_descuento` decimal(12,2) NOT NULL,
  `aplica_a` varchar(255) NOT NULL DEFAULT 'todos',
  `aplica_id` bigint(20) unsigned DEFAULT NULL,
  `compra_minima` decimal(12,2) NOT NULL DEFAULT 0.00,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_fin` date DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `etiquetas_clientes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`etiquetas_clientes`)),
  `limite_usos` int(11) NOT NULL DEFAULT 0,
  `no_combinable` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `promociones`
--

LOCK TABLES `promociones` WRITE;
/*!40000 ALTER TABLE `promociones` DISABLE KEYS */;
/*!40000 ALTER TABLE `promociones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedor_productos`
--

DROP TABLE IF EXISTS `proveedor_productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proveedor_productos` (
  `proveedor_id` bigint(20) unsigned NOT NULL,
  `producto_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`proveedor_id`,`producto_id`),
  KEY `proveedor_productos_producto_id_foreign` (`producto_id`),
  CONSTRAINT `proveedor_productos_producto_id_foreign` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `proveedor_productos_proveedor_id_foreign` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedores` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedor_productos`
--

LOCK TABLES `proveedor_productos` WRITE;
/*!40000 ALTER TABLE `proveedor_productos` DISABLE KEYS */;
/*!40000 ALTER TABLE `proveedor_productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `proveedores`
--

DROP TABLE IF EXISTS `proveedores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `proveedores` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `contacto_nombre` varchar(255) DEFAULT NULL,
  `empresa` varchar(255) DEFAULT NULL,
  `telefono` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `notas` text DEFAULT NULL,
  `notas_internas` text DEFAULT NULL,
  `calificacion` int(11) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `proveedores`
--

LOCK TABLES `proveedores` WRITE;
/*!40000 ALTER TABLE `proveedores` DISABLE KEYS */;
INSERT INTO `proveedores` VALUES (1,'Atesa',NULL,'Atesa CORP',NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-06-04 02:25:00','2026-06-04 02:25:00');
/*!40000 ALTER TABLE `proveedores` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rentabilidad_productos`
--

DROP TABLE IF EXISTS `rentabilidad_productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rentabilidad_productos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `producto_id` bigint(20) unsigned NOT NULL,
  `periodo` varchar(7) NOT NULL,
  `unidades_vendidas` int(11) NOT NULL DEFAULT 0,
  `ingresos` decimal(14,2) NOT NULL DEFAULT 0.00,
  `costo_total` decimal(14,2) NOT NULL DEFAULT 0.00,
  `ganancia` decimal(14,2) NOT NULL DEFAULT 0.00,
  `margen_porcentaje` decimal(5,2) NOT NULL DEFAULT 0.00,
  `devoluciones` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `rentabilidad_productos_producto_id_periodo_unique` (`producto_id`,`periodo`),
  CONSTRAINT `rentabilidad_productos_producto_id_foreign` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rentabilidad_productos`
--

LOCK TABLES `rentabilidad_productos` WRITE;
/*!40000 ALTER TABLE `rentabilidad_productos` DISABLE KEYS */;
/*!40000 ALTER TABLE `rentabilidad_productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rol_permisos`
--

DROP TABLE IF EXISTS `rol_permisos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rol_permisos` (
  `rol_id` bigint(20) unsigned NOT NULL,
  `permiso_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`rol_id`,`permiso_id`),
  KEY `rol_permisos_permiso_id_foreign` (`permiso_id`),
  CONSTRAINT `rol_permisos_permiso_id_foreign` FOREIGN KEY (`permiso_id`) REFERENCES `permisos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `rol_permisos_rol_id_foreign` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rol_permisos`
--

LOCK TABLES `rol_permisos` WRITE;
/*!40000 ALTER TABLE `rol_permisos` DISABLE KEYS */;
/*!40000 ALTER TABLE `rol_permisos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `permisos` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permisos`)),
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Administrador','Acceso total al sistema',NULL,1,NULL),(2,'Vendedor',NULL,'[\"ventas\",\"chats\",\"listas_precios\",\"clientes\",\"caja\"]',1,NULL),(3,'David',NULL,'[\"crm_editar_pipeline\",\"clientes\",\"chats\",\"geo_business\",\"catalogo\"]',1,NULL);
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sesiones_log`
--

DROP TABLE IF EXISTS `sesiones_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sesiones_log` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint(20) unsigned NOT NULL,
  `accion` varchar(255) NOT NULL,
  `ip` varchar(255) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sesiones_log_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `sesiones_log_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sesiones_log`
--

LOCK TABLES `sesiones_log` WRITE;
/*!40000 ALTER TABLE `sesiones_log` DISABLE KEYS */;
INSERT INTO `sesiones_log` VALUES (1,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 09:55:46'),(2,1,'logout','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 11:31:26'),(3,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-22 23:43:45'),(4,2,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 00:30:39'),(5,1,'logout','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 00:32:24'),(6,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 00:32:27'),(7,1,'logout','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 00:41:54'),(8,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 00:42:01'),(9,2,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 03:55:11'),(10,1,'logout','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-30 01:22:16'),(11,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-30 01:27:18'),(12,3,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-30 01:59:52'),(13,2,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-02 07:14:39'),(14,1,'logout','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-03 22:46:54'),(15,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-03 22:46:59'),(16,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-06-04 03:55:04'),(17,2,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-06 22:57:37'),(18,2,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-11 23:09:31'),(19,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-11 23:31:32'),(20,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-11 23:32:23'),(21,1,'logout','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-15 16:10:31'),(22,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-15 16:10:41'),(23,2,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-15 16:32:40'),(24,2,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-15 16:37:29'),(25,2,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-29 18:07:31'),(26,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-29 18:14:34'),(27,1,'logout','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-29 18:50:19'),(28,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-29 18:51:25'),(29,1,'logout','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-29 21:52:40'),(30,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-29 21:52:44'),(31,2,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 12:59:50'),(32,2,'logout','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 12:59:56'),(33,1,'logout','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 14:25:48'),(34,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 14:25:51'),(35,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 15:20:53'),(36,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 15:21:02'),(37,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 15:28:40'),(38,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 15:30:31'),(39,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 15:33:43'),(40,2,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 15:34:02'),(41,2,'logout','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 15:34:54'),(42,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 15:35:08'),(43,2,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 15:35:27'),(44,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 16:45:59'),(45,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 16:46:15'),(46,2,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 16:46:30'),(47,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 16:49:44'),(48,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 16:54:01'),(49,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 18:40:50'),(50,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-02 18:40:56'),(51,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 00:17:05'),(52,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 00:24:48'),(53,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 00:31:09'),(54,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 00:33:17'),(55,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 00:40:20'),(56,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 00:47:26'),(57,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 00:53:23'),(58,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 01:03:29'),(59,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 01:13:53'),(60,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 01:38:21'),(61,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 01:44:25'),(62,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 01:53:40'),(63,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 02:16:57'),(64,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 02:19:57'),(65,2,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-04 02:20:21'),(66,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 02:20:37'),(67,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 02:21:28'),(68,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 02:30:41'),(69,2,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-04 02:30:48'),(70,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 02:31:08'),(71,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 02:33:07'),(72,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 02:33:20'),(73,2,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-04 02:33:57'),(74,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 02:34:34'),(75,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 02:40:10'),(76,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 02:42:08'),(77,1,'login','127.0.0.1','Mozilla/5.0 (Linux; Android 15; Pixel 9) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36','2026-07-04 23:25:02'),(78,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 23:30:22'),(79,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-04 23:30:23'),(80,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-05 05:47:29'),(81,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 17:19:36'),(82,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 17:27:59'),(83,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 17:28:57'),(84,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 17:29:21'),(85,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 17:40:00'),(86,1,'login','127.0.0.1','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1','2026-07-13 18:00:21'),(87,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 18:05:00'),(88,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-13 18:48:03'),(89,1,'login','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-14 17:10:29');
/*!40000 ALTER TABLE `sesiones_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('e428ZuacBdTkMyeSVAkHmnbxbZ3rAb7SZ676N3s2',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJyYXkxVFJYUXdDVFhTcTV6QnVXTzZvZnRWYmZqQjRhYjNGNjJyRG9VIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwIiwicm91dGUiOm51bGx9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19',1784055772);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_ubicacion`
--

DROP TABLE IF EXISTS `stock_ubicacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stock_ubicacion` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `producto_id` bigint(20) unsigned NOT NULL,
  `ubicacion_id` bigint(20) unsigned NOT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stock_ubicacion_producto_id_ubicacion_id_unique` (`producto_id`,`ubicacion_id`),
  KEY `stock_ubicacion_ubicacion_id_foreign` (`ubicacion_id`),
  CONSTRAINT `stock_ubicacion_producto_id_foreign` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `stock_ubicacion_ubicacion_id_foreign` FOREIGN KEY (`ubicacion_id`) REFERENCES `ubicaciones` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_ubicacion`
--

LOCK TABLES `stock_ubicacion` WRITE;
/*!40000 ALTER TABLE `stock_ubicacion` DISABLE KEYS */;
/*!40000 ALTER TABLE `stock_ubicacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tesoreria_movimientos`
--

DROP TABLE IF EXISTS `tesoreria_movimientos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tesoreria_movimientos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tipo` varchar(20) NOT NULL,
  `categoria` varchar(100) DEFAULT NULL,
  `monto` decimal(14,2) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `referencia` varchar(255) DEFAULT NULL,
  `metodo_pago` varchar(50) DEFAULT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `ubicacion_id` bigint(20) unsigned DEFAULT NULL,
  `fecha` date NOT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'confirmado',
  `notas` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tesoreria_movimientos_usuario_id_foreign` (`usuario_id`),
  KEY `tesoreria_movimientos_tipo_fecha_index` (`tipo`,`fecha`),
  CONSTRAINT `tesoreria_movimientos_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tesoreria_movimientos`
--

LOCK TABLES `tesoreria_movimientos` WRITE;
/*!40000 ALTER TABLE `tesoreria_movimientos` DISABLE KEYS */;
INSERT INTO `tesoreria_movimientos` VALUES (1,'ingreso','da',500000.00,NULL,NULL,'efectivo',1,NULL,'2026-07-13','confirmado',NULL,'2026-07-13 18:07:17','2026-07-13 18:07:29');
/*!40000 ALTER TABLE `tesoreria_movimientos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ticket_configuracion`
--

DROP TABLE IF EXISTS `ticket_configuracion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ticket_configuracion` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL DEFAULT 'default',
  `ancho_mm` int(11) NOT NULL DEFAULT 80,
  `fuente` varchar(100) NOT NULL DEFAULT 'Courier New',
  `fuente_size` int(11) NOT NULL DEFAULT 12,
  `logo_path` varchar(255) DEFAULT NULL,
  `logo_x` int(11) NOT NULL DEFAULT 0,
  `logo_y` int(11) NOT NULL DEFAULT 0,
  `logo_width` int(11) NOT NULL DEFAULT 200,
  `mostrar_logo` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_nombre_negocio` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_direccion` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_telefono` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_cedula` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_vendedor` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_cliente` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_fecha` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_detalle_impuesto` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_descuento` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_metodo_pago` tinyint(1) NOT NULL DEFAULT 1,
  `mostrar_codigo_producto` tinyint(1) NOT NULL DEFAULT 0,
  `mostrar_sinpe_info` tinyint(1) NOT NULL DEFAULT 1,
  `header_text` text DEFAULT NULL,
  `footer_text` text DEFAULT NULL,
  `estilos_custom` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`estilos_custom`)),
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket_configuracion`
--

LOCK TABLES `ticket_configuracion` WRITE;
/*!40000 ALTER TABLE `ticket_configuracion` DISABLE KEYS */;
INSERT INTO `ticket_configuracion` VALUES (1,'default',80,'monospace',16,'ticket-logos/Mm08cXJX1Z18HQBBJ7sSX5HNNGyb3w6RjD92uv7O.png',0,0,200,1,1,1,1,1,1,1,1,1,1,1,0,1,NULL,'¡Gracias por su compra!',NULL,1,'2026-05-22 23:58:14','2026-06-15 16:17:26');
/*!40000 ALTER TABLE `ticket_configuracion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `traspaso_detalle`
--

DROP TABLE IF EXISTS `traspaso_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `traspaso_detalle` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `traspaso_id` bigint(20) unsigned NOT NULL,
  `producto_id` bigint(20) unsigned NOT NULL,
  `cantidad_enviada` int(11) NOT NULL DEFAULT 0,
  `cantidad_recibida` int(11) NOT NULL DEFAULT 0,
  `diferencia` int(11) NOT NULL DEFAULT 0,
  `notas_diferencia` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `traspaso_detalle_traspaso_id_foreign` (`traspaso_id`),
  KEY `traspaso_detalle_producto_id_foreign` (`producto_id`),
  CONSTRAINT `traspaso_detalle_producto_id_foreign` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `traspaso_detalle_traspaso_id_foreign` FOREIGN KEY (`traspaso_id`) REFERENCES `traspasos` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `traspaso_detalle`
--

LOCK TABLES `traspaso_detalle` WRITE;
/*!40000 ALTER TABLE `traspaso_detalle` DISABLE KEYS */;
/*!40000 ALTER TABLE `traspaso_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `traspasos`
--

DROP TABLE IF EXISTS `traspasos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `traspasos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `numero_traspaso` varchar(255) DEFAULT NULL,
  `ubicacion_origen_id` bigint(20) unsigned DEFAULT NULL,
  `ubicacion_destino_id` bigint(20) unsigned DEFAULT NULL,
  `usuario_envio_id` bigint(20) unsigned DEFAULT NULL,
  `usuario_recepcion_id` bigint(20) unsigned DEFAULT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'pendiente',
  `fecha_envio` timestamp NULL DEFAULT NULL,
  `fecha_recepcion` timestamp NULL DEFAULT NULL,
  `fecha_estimada` timestamp NULL DEFAULT NULL,
  `transporte` varchar(255) DEFAULT NULL,
  `notas` text DEFAULT NULL,
  `notas_recepcion` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `traspasos_numero_traspaso_unique` (`numero_traspaso`),
  KEY `traspasos_ubicacion_origen_id_foreign` (`ubicacion_origen_id`),
  KEY `traspasos_ubicacion_destino_id_foreign` (`ubicacion_destino_id`),
  CONSTRAINT `traspasos_ubicacion_destino_id_foreign` FOREIGN KEY (`ubicacion_destino_id`) REFERENCES `ubicaciones` (`id`) ON DELETE SET NULL,
  CONSTRAINT `traspasos_ubicacion_origen_id_foreign` FOREIGN KEY (`ubicacion_origen_id`) REFERENCES `ubicaciones` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `traspasos`
--

LOCK TABLES `traspasos` WRITE;
/*!40000 ALTER TABLE `traspasos` DISABLE KEYS */;
/*!40000 ALTER TABLE `traspasos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ubicaciones`
--

DROP TABLE IF EXISTS `ubicaciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ubicaciones` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `tipo` varchar(255) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `telefono` varchar(255) DEFAULT NULL,
  `responsable` varchar(255) DEFAULT NULL,
  `lat` decimal(10,7) DEFAULT NULL,
  `lng` decimal(10,7) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `es_principal` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ubicaciones`
--

LOCK TABLES `ubicaciones` WRITE;
/*!40000 ALTER TABLE `ubicaciones` DISABLE KEYS */;
INSERT INTO `ubicaciones` VALUES (1,'Tienda Grecia','sucursal',NULL,'88888888','Jay',10.0723450,-84.3116335,1,0,'2026-05-22 23:48:35','2026-05-22 23:48:35'),(2,'Tienda Naranjo','almacen','Naranjo','00000000','David',10.0969844,-84.3797200,1,0,'2026-05-30 01:49:42','2026-05-30 01:49:42');
/*!40000 ALTER TABLE `ubicaciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usuarios` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `rol_id` bigint(20) unsigned DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `theme_mode` varchar(255) NOT NULL DEFAULT 'light',
  `pin_rapido` varchar(255) DEFAULT NULL,
  `auto_logout_min` int(11) DEFAULT NULL,
  `modulos_acceso` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`modulos_acceso`)),
  `secret_2fa` varchar(255) DEFAULT NULL,
  `two_fa_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `ip_whitelist` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`ip_whitelist`)),
  `intentos_fallidos` int(11) NOT NULL DEFAULT 0,
  `bloqueado_hasta` timestamp NULL DEFAULT NULL,
  `ultimo_login` timestamp NULL DEFAULT NULL,
  `token_recuperacion` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `usuarios_email_unique` (`email`),
  KEY `usuarios_rol_id_foreign` (`rol_id`),
  CONSTRAINT `usuarios_rol_id_foreign` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'Administrador','admin@sdj.com','$2y$12$ePrO.0bAquqHgSlGn5GAnOEF9T8iNNoHeAfrFwFlUpoi83ywuI5QO',1,NULL,1,'dark',NULL,NULL,NULL,NULL,0,NULL,0,NULL,NULL,NULL,'2026-05-22 09:20:42','2026-07-04 01:20:27'),(2,'David Alpizar','admin@david.com','$2y$12$JPzWAL.iv9cS4XVY235x3ey26qDMducPuPIEmob34J5z6uMrgWZye',3,NULL,1,'dark',NULL,NULL,NULL,NULL,0,NULL,3,NULL,NULL,NULL,'2026-05-23 00:30:15','2026-06-06 22:59:34'),(3,'Rodrigo','admin@gigroup.com','$2y$12$2z2rLNPxL9BYRFTLOoJmqeWVC6zyxQKwg7Sw1zZuJ6PezRC2qZ3r2',2,NULL,1,'light',NULL,NULL,NULL,NULL,0,NULL,0,NULL,NULL,NULL,'2026-05-30 01:59:34','2026-05-30 01:59:34');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `venta_detalle`
--

DROP TABLE IF EXISTS `venta_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `venta_detalle` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `venta_id` bigint(20) unsigned NOT NULL,
  `producto_id` bigint(20) unsigned NOT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 1,
  `precio_unitario` decimal(12,2) NOT NULL DEFAULT 0.00,
  `descuento` decimal(12,2) NOT NULL DEFAULT 0.00,
  `impuesto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `combo_id` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `venta_detalle_venta_id_foreign` (`venta_id`),
  KEY `venta_detalle_producto_id_foreign` (`producto_id`),
  CONSTRAINT `venta_detalle_producto_id_foreign` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE,
  CONSTRAINT `venta_detalle_venta_id_foreign` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venta_detalle`
--

LOCK TABLES `venta_detalle` WRITE;
/*!40000 ALTER TABLE `venta_detalle` DISABLE KEYS */;
INSERT INTO `venta_detalle` VALUES (1,1,1,1,8000.00,0.00,1040.00,8000.00,NULL,NULL),(2,2,1,2,8000.00,0.00,2080.00,16000.00,NULL,NULL),(3,3,1,2,8000.00,0.00,2080.00,16000.00,NULL,NULL),(4,4,1,1,8000.00,0.00,1040.00,8000.00,NULL,'2026-06-04 00:57:07'),(5,5,1,1,8000.00,0.00,1040.00,8000.00,NULL,NULL),(6,6,2,1,4500.00,0.00,585.00,4500.00,NULL,NULL),(7,7,2,1,4500.00,0.00,585.00,4500.00,NULL,NULL),(8,8,1,2,8000.00,0.00,2080.00,16000.00,NULL,NULL),(9,9,1,1,8000.00,0.00,1040.00,8000.00,NULL,'2026-06-15 16:55:57'),(10,10,2,1,4500.00,0.00,585.00,4500.00,NULL,'2026-06-15 16:57:44');
/*!40000 ALTER TABLE `venta_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `venta_ubicacion`
--

DROP TABLE IF EXISTS `venta_ubicacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `venta_ubicacion` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `venta_id` bigint(20) unsigned NOT NULL,
  `ubicacion_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `venta_ubicacion_venta_id_foreign` (`venta_id`),
  KEY `venta_ubicacion_ubicacion_id_foreign` (`ubicacion_id`),
  CONSTRAINT `venta_ubicacion_ubicacion_id_foreign` FOREIGN KEY (`ubicacion_id`) REFERENCES `ubicaciones` (`id`) ON DELETE CASCADE,
  CONSTRAINT `venta_ubicacion_venta_id_foreign` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venta_ubicacion`
--

LOCK TABLES `venta_ubicacion` WRITE;
/*!40000 ALTER TABLE `venta_ubicacion` DISABLE KEYS */;
/*!40000 ALTER TABLE `venta_ubicacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ventas`
--

DROP TABLE IF EXISTS `ventas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ventas` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `numero_factura` varchar(255) DEFAULT NULL,
  `cliente_id` bigint(20) unsigned DEFAULT NULL,
  `nombre_factura` varchar(255) DEFAULT NULL,
  `usuario_id` bigint(20) unsigned DEFAULT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `descuento_total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `impuesto_total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `metodo_pago` varchar(255) DEFAULT NULL,
  `monto_efectivo` decimal(12,2) DEFAULT NULL,
  `monto_tarjeta` decimal(12,2) DEFAULT NULL,
  `monto_sinpe` decimal(12,2) DEFAULT NULL,
  `referencia_sinpe` varchar(255) DEFAULT NULL,
  `comprobante_sinpe` varchar(255) DEFAULT NULL,
  `dinero_recibido` decimal(12,2) DEFAULT NULL,
  `cambio` decimal(12,2) DEFAULT NULL,
  `estado` varchar(255) NOT NULL DEFAULT 'completada',
  `cotizacion_id` bigint(20) unsigned DEFAULT NULL,
  `canal` varchar(255) DEFAULT NULL,
  `ubicacion_id` bigint(20) unsigned DEFAULT NULL,
  `notas` text DEFAULT NULL,
  `cancelada_por` bigint(20) unsigned DEFAULT NULL,
  `motivo_cancelacion` text DEFAULT NULL,
  `cupon_id` bigint(20) unsigned DEFAULT NULL,
  `descuento_cupon` decimal(12,2) DEFAULT NULL,
  `ip_compra` varchar(255) DEFAULT NULL,
  `latitud` decimal(10,7) DEFAULT NULL,
  `longitud` decimal(10,7) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ventas_numero_factura_unique` (`numero_factura`),
  KEY `ventas_cliente_id_foreign` (`cliente_id`),
  KEY `ventas_usuario_id_foreign` (`usuario_id`),
  CONSTRAINT `ventas_cliente_id_foreign` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id`) ON DELETE SET NULL,
  CONSTRAINT `ventas_usuario_id_foreign` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ventas`
--

LOCK TABLES `ventas` WRITE;
/*!40000 ALTER TABLE `ventas` DISABLE KEYS */;
INSERT INTO `ventas` VALUES (1,'VTA-20260522-0001',NULL,NULL,1,8000.00,0.00,1040.00,9040.00,'efectivo',10000.00,0.00,0.00,'',NULL,10000.00,960.00,'completada',NULL,NULL,1,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-05-22 23:53:11','2026-05-22 23:53:11'),(2,'VTA-20260529-0001',NULL,NULL,1,16000.00,0.00,2080.00,18080.00,'efectivo',19000.00,0.00,0.00,'',NULL,19000.00,920.00,'completada',NULL,NULL,1,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-05-30 01:28:26','2026-05-30 01:28:26'),(3,'VTA-20260529-0002',NULL,NULL,1,16000.00,0.00,2080.00,18080.00,'efectivo',19000.00,0.00,0.00,'',NULL,19000.00,920.00,'completada',NULL,NULL,1,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-05-30 01:28:26','2026-05-30 01:28:26'),(4,'FAC-20260603-0001',NULL,NULL,1,8000.00,0.00,1040.00,9040.00,'pendiente',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completada',1,NULL,NULL,'Generada desde cotización COT-20260522-0001',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-06-04 00:57:07','2026-06-04 00:57:07'),(5,'VTA-20260605-0001',NULL,NULL,1,8000.00,0.00,1040.00,9040.00,'efectivo',10000.00,0.00,0.00,'',NULL,10000.00,960.00,'completada',NULL,NULL,1,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-06-05 08:40:36','2026-06-05 08:40:36'),(6,'VTA-20260605-0002',1,NULL,1,4500.00,0.00,585.00,5085.00,'efectivo',6000.00,0.00,0.00,'',NULL,6000.00,915.00,'completada',NULL,NULL,1,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-06-05 08:44:14','2026-06-05 08:44:14'),(7,'VTA-20260605-0003',1,NULL,1,4500.00,0.00,585.00,5085.00,'efectivo',6000.00,0.00,0.00,'',NULL,6000.00,915.00,'completada',NULL,NULL,1,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-06-05 08:50:20','2026-06-05 08:50:20'),(8,'VTA-20260605-0004',NULL,NULL,1,16000.00,0.00,2080.00,18080.00,'tarjeta',0.00,18080.00,0.00,'',NULL,0.00,0.00,'completada',NULL,NULL,2,'',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-06-05 08:55:33','2026-06-05 08:55:33'),(9,'FAC-20260615-0001',1,NULL,1,8000.00,0.00,1040.00,9040.00,'pendiente',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completada',4,NULL,NULL,'Generada desde cotización COT-20260615-0001',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-06-15 16:55:57','2026-06-15 16:55:57'),(10,'FAC-20260615-0002',1,NULL,1,4500.00,0.00,585.00,5085.00,'pendiente',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'completada',5,NULL,NULL,'Generada desde cotización COT-20260615-0002',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-06-15 16:57:44','2026-06-15 16:57:44');
/*!40000 ALTER TABLE `ventas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'software_dj'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-14 14:00:59
