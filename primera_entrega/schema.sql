-- crafted | Esquema MySQL 8+ / MariaDB 10.5+
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS crafted CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER DATABASE crafted CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE crafted;

CREATE TABLE IF NOT EXISTS usuarios (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(120) NOT NULL,
 correo VARCHAR(190) NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL,
 fecha_nacimiento DATE NOT NULL,
 direccion_postal TEXT NOT NULL,
 tarjeta_ultimos4 CHAR(4) NULL COMMENT 'No almacenar PAN completo',
 rol ENUM('cliente','admin') NOT NULL DEFAULT 'cliente',
 creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS sesiones_persistentes (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 usuario_id BIGINT UNSIGNED NOT NULL,
 selector VARCHAR(24) NOT NULL UNIQUE,
 verificador_hash CHAR(64) NOT NULL,
 vence_en DATETIME NOT NULL,
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS perfiles (
 usuario_id BIGINT UNSIGNED PRIMARY KEY,
 peso_kg DECIMAL(5,2) NOT NULL,
 estatura_cm DECIMAL(5,1) NOT NULL,
 actividad ENUM('baja','ligera','moderada','alta') NOT NULL,
 dias_entrenamiento TINYINT UNSIGNED NOT NULL,
 tipo_ejercicio VARCHAR(90) NOT NULL,
 alimentacion ENUM('omnivora','vegetariana','vegana','otra') NOT NULL,
 alergias VARCHAR(255) NOT NULL DEFAULT '',
 prefiere_organico TINYINT(1) NOT NULL DEFAULT 0,
 consiente_datos TINYINT(1) NOT NULL DEFAULT 0,
 actualizado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS objetivos_usuarios (
 usuario_id BIGINT UNSIGNED NOT NULL,
 objetivo ENUM('masa','rendimiento','energia','sueno','digestion','bienestar') NOT NULL,
 PRIMARY KEY(usuario_id,objetivo),
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS ingredientes (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(120) NOT NULL,
 categoria ENUM('base','sabor','suplemento','fibra') NOT NULL,
 descripcion TEXT NOT NULL,
 beneficios TEXT NOT NULL,
 origen VARCHAR(100) NOT NULL,
 fabricante VARCHAR(120) NOT NULL,
 foto VARCHAR(255) NOT NULL DEFAULT 'assets/img/producto.svg',
 organico_certificado TINYINT(1) NOT NULL DEFAULT 0,
 numero_certificado VARCHAR(120) NULL,
 alergenos VARCHAR(255) NOT NULL DEFAULT 'Consultar fabricante',
 precio_por_gramo DECIMAL(10,4) NOT NULL,
 stock_gramos DECIMAL(12,2) NOT NULL DEFAULT 0,
 minimo_g DECIMAL(14,8) NOT NULL DEFAULT 0,
 maximo_g DECIMAL(14,8) NOT NULL DEFAULT 0,
 admite_barrita TINYINT(1) NOT NULL DEFAULT 1,
 activo TINYINT(1) NOT NULL DEFAULT 1,
 CHECK(stock_gramos>=0),CHECK(precio_por_gramo>=0),CHECK(maximo_g>=minimo_g)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS presentaciones (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(100) NOT NULL,
 formato ENUM('polvo','barrita') NOT NULL,
 porciones SMALLINT UNSIGNED NOT NULL,
 precio_base DECIMAL(10,2) NOT NULL,
 descripcion VARCHAR(250) NOT NULL,
 activo TINYINT(1) DEFAULT 1
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS productos (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(170) NOT NULL,
 descripcion TEXT NOT NULL,
 foto VARCHAR(255) NOT NULL DEFAULT 'assets/img/producto.svg',
 precio DECIMAL(10,2) NOT NULL,
 cantidad_almacen INT UNSIGNED NOT NULL DEFAULT 0,
 fabricante VARCHAR(120) NOT NULL,
 origen VARCHAR(120) NOT NULL,
 categoria ENUM('base','sabor','suplemento','fibra','pack') NOT NULL DEFAULT 'pack',
 activo TINYINT(1) NOT NULL DEFAULT 1,
 creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 CHECK(precio>=0)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS formulas (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 usuario_id BIGINT UNSIGNED NOT NULL,
 nombre VARCHAR(150) NOT NULL,
 base_id BIGINT UNSIGNED NOT NULL,
 sabor_id BIGINT UNSIGNED NOT NULL,
 presentacion_id INT UNSIGNED NOT NULL,
 peso_porcion_g DECIMAL(10,3) NOT NULL,
 precio DECIMAL(10,2) NOT NULL,
 creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
 FOREIGN KEY (base_id) REFERENCES ingredientes(id),
 FOREIGN KEY (sabor_id) REFERENCES ingredientes(id),
 FOREIGN KEY (presentacion_id) REFERENCES presentaciones(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS formula_ingredientes (
 formula_id BIGINT UNSIGNED NOT NULL,
 ingrediente_id BIGINT UNSIGNED NOT NULL,
 cantidad_por_porcion_g DECIMAL(14,8) NOT NULL,
 precio_por_gramo_snapshot DECIMAL(10,4) NOT NULL,
 PRIMARY KEY(formula_id,ingrediente_id),
 FOREIGN KEY (formula_id) REFERENCES formulas(id) ON DELETE CASCADE,
 FOREIGN KEY (ingrediente_id) REFERENCES ingredientes(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS carrito (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 usuario_id BIGINT UNSIGNED NOT NULL,
 producto_id BIGINT UNSIGNED NULL,
 formula_id BIGINT UNSIGNED NULL,
 cantidad SMALLINT UNSIGNED NOT NULL DEFAULT 1,
 agregado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
 FOREIGN KEY (producto_id) REFERENCES productos(id),
 FOREIGN KEY (formula_id) REFERENCES formulas(id),
 UNIQUE KEY uq_carrito_producto(usuario_id,producto_id),
 UNIQUE KEY uq_carrito_formula(usuario_id,formula_id),
 CHECK ((producto_id IS NULL) <> (formula_id IS NULL)),
 CHECK (cantidad BETWEEN 1 AND 99)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS compras (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 usuario_id BIGINT UNSIGNED NOT NULL,
 direccion_envio TEXT NOT NULL,
 total DECIMAL(12,2) NOT NULL,
 estado ENUM('simulado','pendiente','pagado','cancelado') NOT NULL DEFAULT 'simulado',
 creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(usuario_id) REFERENCES usuarios(id)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS detalle_compra (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 compra_id BIGINT UNSIGNED NOT NULL,
 producto_id BIGINT UNSIGNED NULL,
 formula_id BIGINT UNSIGNED NULL,
 nombre_snapshot VARCHAR(180) NOT NULL,
 cantidad SMALLINT UNSIGNED NOT NULL,
 precio_unitario DECIMAL(12,2) NOT NULL,
 subtotal DECIMAL(12,2) NOT NULL,
 FOREIGN KEY(compra_id) REFERENCES compras(id) ON DELETE CASCADE,
 FOREIGN KEY(producto_id) REFERENCES productos(id),
 FOREIGN KEY(formula_id) REFERENCES formulas(id),
 CHECK((producto_id IS NULL) <> (formula_id IS NULL))
) ENGINE=InnoDB;
CREATE OR REPLACE VIEW historial_compras AS
 SELECT c.id AS id_compra,c.usuario_id AS usuario,dc.producto_id AS producto,dc.formula_id,
 dc.nombre_snapshot,dc.cantidad,dc.subtotal,c.creado_en
 FROM compras c JOIN detalle_compra dc ON dc.compra_id=c.id;
