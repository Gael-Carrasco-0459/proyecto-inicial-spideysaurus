-- ============================================================
--  BASE DE DATOS: bdspideysaurus
--  Proyecto  : Tienda de Dinosaurios
--  Generado  : 2026-05-11
--  Motor     : MySQL 8.0+
-- ============================================================

CREATE DATABASE IF NOT EXISTS bdspideysaurus
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE bdspideysaurus;

-- ------------------------------------------------------------
-- 0. DESACTIVAR FOREIGN KEYS DURANTE LA CREACIÓN
-- ------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 0;

-- ============================================================
-- MÓDULO CORE
-- ============================================================

-- ------------------------------------------------------------
-- 1. CATEGORÍA
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS categoria (
  categoria_id      INT             NOT NULL AUTO_INCREMENT,
  nombre            VARCHAR(100)    NOT NULL,
  descripcion       TEXT                NULL,
  categoria_padre_id INT                NULL COMMENT 'Autorreferencia para subcategorías',
  activo            BOOLEAN         NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_categoria         PRIMARY KEY (categoria_id),
  CONSTRAINT uk_categoria_nombre  UNIQUE      (nombre),
  CONSTRAINT fk_categoria_padre   FOREIGN KEY (categoria_padre_id)
                                  REFERENCES  categoria (categoria_id)
                                  ON UPDATE CASCADE
                                  ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='Agrupación de productos (Figuras, Fósiles, Libros, etc.)';

-- ------------------------------------------------------------
-- 2. ESPECIE
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS especie (
  especie_id        INT             NOT NULL AUTO_INCREMENT,
  nombre_comun      VARCHAR(100)    NOT NULL,
  nombre_cientifico VARCHAR(150)    NOT NULL,
  era               ENUM('Triásico','Jurásico','Cretácico','Otro') NOT NULL,
  dieta             ENUM('Carnívoro','Herbívoro','Omnívoro','Desconocido') NOT NULL,
  longitud_m        DECIMAL(5,2)        NULL COMMENT 'Longitud estimada en metros',
  peso_ton          DECIMAL(6,2)        NULL COMMENT 'Peso estimado en toneladas',
  region_origen     VARCHAR(150)        NULL,
  descripcion       TEXT                NULL,
  imagen_url        VARCHAR(500)        NULL,
  CONSTRAINT pk_especie               PRIMARY KEY (especie_id),
  CONSTRAINT uk_especie_cientifico    UNIQUE      (nombre_cientifico)
) ENGINE=InnoDB COMMENT='Catálogo de especies de dinosaurios';

-- ------------------------------------------------------------
-- 3. PRODUCTO
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS producto (
  producto_id       INT             NOT NULL AUTO_INCREMENT,
  nombre            VARCHAR(150)    NOT NULL,
  descripcion       TEXT                NULL,
  precio            DECIMAL(10,2)   NOT NULL,
  precio_costo      DECIMAL(10,2)       NULL,
  categoria_id      INT             NOT NULL,
  especie_id        INT                 NULL,
  imagen_url        VARCHAR(500)        NULL,
  activo            BOOLEAN         NOT NULL DEFAULT TRUE,
  created_at        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_producto          PRIMARY KEY (producto_id),
  CONSTRAINT fk_producto_cat      FOREIGN KEY (categoria_id)
                                  REFERENCES  categoria (categoria_id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT,
  CONSTRAINT fk_producto_especie  FOREIGN KEY (especie_id)
                                  REFERENCES  especie (especie_id)
                                  ON UPDATE CASCADE
                                  ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='Artículos disponibles para venta';

-- ------------------------------------------------------------
-- 4. CLIENTE
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cliente (
  cliente_id        INT             NOT NULL AUTO_INCREMENT,
  nombre            VARCHAR(100)    NOT NULL,
  apellidos         VARCHAR(100)    NOT NULL,
  email             VARCHAR(200)    NOT NULL,
  telefono          VARCHAR(20)         NULL,
  fecha_nacimiento  DATE                NULL,
  activo            BOOLEAN         NOT NULL DEFAULT TRUE,
  created_at        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_cliente           PRIMARY KEY (cliente_id),
  CONSTRAINT uk_cliente_email     UNIQUE      (email)
) ENGINE=InnoDB COMMENT='Compradores registrados';

-- ------------------------------------------------------------
-- 5. DIRECCIÓN
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS direccion (
  direccion_id      INT             NOT NULL AUTO_INCREMENT,
  cliente_id        INT             NOT NULL,
  calle             VARCHAR(200)    NOT NULL,
  colonia           VARCHAR(100)        NULL,
  ciudad            VARCHAR(100)    NOT NULL,
  estado_region     VARCHAR(100)    NOT NULL,
  codigo_postal     VARCHAR(10)     NOT NULL,
  pais              VARCHAR(80)     NOT NULL DEFAULT 'México',
  es_principal      BOOLEAN         NOT NULL DEFAULT FALSE,
  CONSTRAINT pk_direccion         PRIMARY KEY (direccion_id),
  CONSTRAINT fk_direccion_cliente FOREIGN KEY (cliente_id)
                                  REFERENCES  cliente (cliente_id)
                                  ON UPDATE CASCADE
                                  ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Direcciones de entrega de clientes';

-- ============================================================
-- MÓDULO PERSONAS / SEGURIDAD
-- ============================================================

-- ------------------------------------------------------------
-- 6. EMPLEADO
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS empleado (
  empleado_id         INT             NOT NULL AUTO_INCREMENT,
  nombre              VARCHAR(100)    NOT NULL,
  apellidos           VARCHAR(100)    NOT NULL,
  puesto              VARCHAR(100)    NOT NULL,
  email_corporativo   VARCHAR(200)    NOT NULL,
  telefono            VARCHAR(20)         NULL,
  fecha_contratacion  DATE            NOT NULL,
  salario             DECIMAL(10,2)       NULL,
  activo              BOOLEAN         NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_empleado              PRIMARY KEY (empleado_id),
  CONSTRAINT uk_empleado_email        UNIQUE      (email_corporativo)
) ENGINE=InnoDB COMMENT='Personal de la tienda';

-- ------------------------------------------------------------
-- 7. USUARIO
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS usuario (
  usuario_id        INT             NOT NULL AUTO_INCREMENT,
  empleado_id       INT                 NULL,
  cliente_id        INT                 NULL,
  username          VARCHAR(80)     NOT NULL,
  password_hash     VARCHAR(255)    NOT NULL COMMENT 'Hash bcrypt',
  rol               ENUM('Admin','Cajero','Bodeguero','Cliente') NOT NULL,
  ultimo_login      TIMESTAMP           NULL,
  activo            BOOLEAN         NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_usuario           PRIMARY KEY (usuario_id),
  CONSTRAINT uk_usuario_username  UNIQUE      (username),
  CONSTRAINT fk_usuario_empleado  FOREIGN KEY (empleado_id)
                                  REFERENCES  empleado (empleado_id)
                                  ON UPDATE CASCADE
                                  ON DELETE SET NULL,
  CONSTRAINT fk_usuario_cliente   FOREIGN KEY (cliente_id)
                                  REFERENCES  cliente (cliente_id)
                                  ON UPDATE CASCADE
                                  ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='Credenciales y roles de acceso al sistema';

-- ============================================================
-- MÓDULO INVENTARIO
-- ============================================================

-- ------------------------------------------------------------
-- 8. INVENTARIO
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS inventario (
  inventario_id       INT             NOT NULL AUTO_INCREMENT,
  producto_id         INT             NOT NULL,
  stock_actual        INT             NOT NULL DEFAULT 0,
  stock_minimo        INT             NOT NULL DEFAULT 5,
  stock_maximo        INT                 NULL,
  ubicacion           VARCHAR(100)        NULL COMMENT 'Pasillo / estante / bodega',
  ultima_actualizacion TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
                                               ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT pk_inventario          PRIMARY KEY (inventario_id),
  CONSTRAINT uk_inventario_producto UNIQUE      (producto_id),
  CONSTRAINT fk_inventario_producto FOREIGN KEY (producto_id)
                                    REFERENCES  producto (producto_id)
                                    ON UPDATE CASCADE
                                    ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Control de existencias por producto';

-- ------------------------------------------------------------
-- 9. PROVEEDOR
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS proveedor (
  proveedor_id      INT             NOT NULL AUTO_INCREMENT,
  nombre            VARCHAR(150)    NOT NULL,
  contacto_nombre   VARCHAR(100)        NULL,
  email             VARCHAR(200)        NULL,
  telefono          VARCHAR(20)         NULL,
  pais              VARCHAR(80)         NULL,
  activo            BOOLEAN         NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_proveedor         PRIMARY KEY (proveedor_id)
) ENGINE=InnoDB COMMENT='Fabricantes y distribuidores';

-- ------------------------------------------------------------
-- 10. COMPRA (Orden de compra a proveedor)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS compra (
  compra_id         INT             NOT NULL AUTO_INCREMENT,
  proveedor_id      INT             NOT NULL,
  empleado_id       INT             NOT NULL,
  fecha_orden       DATE            NOT NULL,
  fecha_recepcion   DATE                NULL,
  estado            ENUM('Enviada','Recibida','Cancelada') NOT NULL DEFAULT 'Enviada',
  total             DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
  CONSTRAINT pk_compra            PRIMARY KEY (compra_id),
  CONSTRAINT fk_compra_proveedor  FOREIGN KEY (proveedor_id)
                                  REFERENCES  proveedor (proveedor_id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT,
  CONSTRAINT fk_compra_empleado   FOREIGN KEY (empleado_id)
                                  REFERENCES  empleado (empleado_id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT
) ENGINE=InnoDB COMMENT='Órdenes de reabastecimiento a proveedores';

-- ------------------------------------------------------------
-- 11. DETALLE_COMPRA
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS detalle_compra (
  detalle_compra_id INT             NOT NULL AUTO_INCREMENT,
  compra_id         INT             NOT NULL,
  producto_id       INT             NOT NULL,
  cantidad          INT             NOT NULL,
  precio_unitario   DECIMAL(10,2)   NOT NULL,
  subtotal          DECIMAL(10,2)   NOT NULL
                                    COMMENT 'cantidad × precio_unitario',
  CONSTRAINT pk_detalle_compra        PRIMARY KEY (detalle_compra_id),
  CONSTRAINT fk_detalle_compra_compra FOREIGN KEY (compra_id)
                                      REFERENCES  compra (compra_id)
                                      ON UPDATE CASCADE
                                      ON DELETE CASCADE,
  CONSTRAINT fk_detalle_compra_prod   FOREIGN KEY (producto_id)
                                      REFERENCES  producto (producto_id)
                                      ON UPDATE CASCADE
                                      ON DELETE RESTRICT
) ENGINE=InnoDB COMMENT='Líneas de cada orden de compra';

-- ============================================================
-- MÓDULO VENTAS
-- ============================================================

-- ------------------------------------------------------------
-- 12. PROMOCIÓN
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS promocion (
  promocion_id      INT             NOT NULL AUTO_INCREMENT,
  codigo            VARCHAR(50)         NULL COMMENT 'Código de cupón (opcional)',
  nombre            VARCHAR(150)    NOT NULL,
  tipo_descuento    ENUM('Porcentaje','Monto fijo','Envío gratis') NOT NULL,
  valor_descuento   DECIMAL(8,2)    NOT NULL,
  fecha_inicio      DATE            NOT NULL,
  fecha_fin         DATE            NOT NULL,
  usos_maximos      INT                 NULL COMMENT 'NULL = ilimitado',
  usos_actuales     INT             NOT NULL DEFAULT 0,
  activa            BOOLEAN         NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_promocion         PRIMARY KEY (promocion_id),
  CONSTRAINT uk_promocion_codigo  UNIQUE      (codigo)
) ENGINE=InnoDB COMMENT='Descuentos, cupones y ofertas';

-- ------------------------------------------------------------
-- 13. PEDIDO
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pedido (
  pedido_id         INT             NOT NULL AUTO_INCREMENT,
  cliente_id        INT             NOT NULL,
  empleado_id       INT                 NULL,
  promocion_id      INT                 NULL,
  fecha_pedido      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  estado            ENUM('Pendiente','Procesando','Enviado','Entregado','Cancelado')
                                    NOT NULL DEFAULT 'Pendiente',
  subtotal          DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
  descuento         DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
  impuesto          DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
  total             DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
  notas             TEXT                NULL,
  CONSTRAINT pk_pedido            PRIMARY KEY (pedido_id),
  CONSTRAINT fk_pedido_cliente    FOREIGN KEY (cliente_id)
                                  REFERENCES  cliente (cliente_id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT,
  CONSTRAINT fk_pedido_empleado   FOREIGN KEY (empleado_id)
                                  REFERENCES  empleado (empleado_id)
                                  ON UPDATE CASCADE
                                  ON DELETE SET NULL,
  CONSTRAINT fk_pedido_promocion  FOREIGN KEY (promocion_id)
                                  REFERENCES  promocion (promocion_id)
                                  ON UPDATE CASCADE
                                  ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='Cabecera de cada venta / transacción';

-- ------------------------------------------------------------
-- 14. DETALLE_PEDIDO
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS detalle_pedido (
  detalle_id        INT             NOT NULL AUTO_INCREMENT,
  pedido_id         INT             NOT NULL,
  producto_id       INT             NOT NULL,
  cantidad          INT             NOT NULL,
  precio_unitario   DECIMAL(10,2)   NOT NULL,
  descuento_linea   DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
  subtotal_linea    DECIMAL(10,2)   NOT NULL
                                    COMMENT 'cantidad × precio_unitario − descuento_linea',
  CONSTRAINT pk_detalle_pedido        PRIMARY KEY (detalle_id),
  CONSTRAINT fk_detalle_pedido_ped    FOREIGN KEY (pedido_id)
                                      REFERENCES  pedido (pedido_id)
                                      ON UPDATE CASCADE
                                      ON DELETE CASCADE,
  CONSTRAINT fk_detalle_pedido_prod   FOREIGN KEY (producto_id)
                                      REFERENCES  producto (producto_id)
                                      ON UPDATE CASCADE
                                      ON DELETE RESTRICT
) ENGINE=InnoDB COMMENT='Líneas de cada pedido de venta';

-- ============================================================
-- MÓDULO FINANZAS / LOGÍSTICA
-- ============================================================

-- ------------------------------------------------------------
-- 15. PAGO
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pago (
  pago_id           INT             NOT NULL AUTO_INCREMENT,
  pedido_id         INT             NOT NULL,
  metodo_pago       ENUM('Efectivo','Tarjeta crédito','Tarjeta débito',
                         'Transferencia','Cupón','Otro') NOT NULL,
  monto             DECIMAL(10,2)   NOT NULL,
  fecha_pago        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  referencia        VARCHAR(200)        NULL COMMENT 'Nro. de transacción / folio',
  estado            ENUM('Pendiente','Completado','Fallido','Reembolsado')
                                    NOT NULL DEFAULT 'Pendiente',
  CONSTRAINT pk_pago              PRIMARY KEY (pago_id),
  CONSTRAINT fk_pago_pedido       FOREIGN KEY (pedido_id)
                                  REFERENCES  pedido (pedido_id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT
) ENGINE=InnoDB COMMENT='Registro de pagos por pedido';

-- ------------------------------------------------------------
-- 16. ENVÍO
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS envio (
  envio_id          INT             NOT NULL AUTO_INCREMENT,
  pedido_id         INT             NOT NULL,
  direccion_id      INT             NOT NULL,
  transportista     VARCHAR(100)        NULL,
  numero_guia       VARCHAR(100)        NULL,
  fecha_estimada    DATE                NULL,
  fecha_entrega     DATE                NULL,
  estado            ENUM('Preparando','En camino','Entregado','Devuelto')
                                    NOT NULL DEFAULT 'Preparando',
  costo_envio       DECIMAL(8,2)    NOT NULL DEFAULT 0.00,
  CONSTRAINT pk_envio             PRIMARY KEY (envio_id),
  CONSTRAINT fk_envio_pedido      FOREIGN KEY (pedido_id)
                                  REFERENCES  pedido (pedido_id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT,
  CONSTRAINT fk_envio_direccion   FOREIGN KEY (direccion_id)
                                  REFERENCES  direccion (direccion_id)
                                  ON UPDATE CASCADE
                                  ON DELETE RESTRICT
) ENGINE=InnoDB COMMENT='Información logística de cada pedido';

-- ============================================================
-- MÓDULO MARKETING
-- ============================================================

-- ------------------------------------------------------------
-- 17. RESEÑA
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS resena (
  resena_id         INT             NOT NULL AUTO_INCREMENT,
  cliente_id        INT             NOT NULL,
  producto_id       INT             NOT NULL,
  calificacion      TINYINT         NOT NULL COMMENT '1 a 5 estrellas',
  titulo            VARCHAR(150)        NULL,
  comentario        TEXT                NULL,
  verificada        BOOLEAN         NOT NULL DEFAULT FALSE
                                    COMMENT 'TRUE si proviene de compra real',
  fecha_resena      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_resena            PRIMARY KEY (resena_id),
  CONSTRAINT fk_resena_cliente    FOREIGN KEY (cliente_id)
                                  REFERENCES  cliente (cliente_id)
                                  ON UPDATE CASCADE
                                  ON DELETE CASCADE,
  CONSTRAINT fk_resena_producto   FOREIGN KEY (producto_id)
                                  REFERENCES  producto (producto_id)
                                  ON UPDATE CASCADE
                                  ON DELETE CASCADE,
  CONSTRAINT chk_resena_calif     CHECK (calificacion BETWEEN 1 AND 5)
) ENGINE=InnoDB COMMENT='Valoraciones de clientes sobre productos';

-- ------------------------------------------------------------
-- 18. LISTA_DESEOS
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lista_deseos (
  deseo_id          INT             NOT NULL AUTO_INCREMENT,
  cliente_id        INT             NOT NULL,
  producto_id       INT             NOT NULL,
  fecha_agregado    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  notificar_precio  BOOLEAN         NOT NULL DEFAULT FALSE,
  CONSTRAINT pk_lista_deseos          PRIMARY KEY (deseo_id),
  CONSTRAINT uk_deseo_cliente_prod    UNIQUE      (cliente_id, producto_id),
  CONSTRAINT fk_deseos_cliente        FOREIGN KEY (cliente_id)
                                      REFERENCES  cliente (cliente_id)
                                      ON UPDATE CASCADE
                                      ON DELETE CASCADE,
  CONSTRAINT fk_deseos_producto       FOREIGN KEY (producto_id)
                                      REFERENCES  producto (producto_id)
                                      ON UPDATE CASCADE
                                      ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Productos guardados por el cliente para compra futura';

-- ------------------------------------------------------------
-- REACTIVAR FOREIGN KEYS
-- ------------------------------------------------------------
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- ÍNDICES ADICIONALES (rendimiento en consultas frecuentes)
-- ============================================================
CREATE INDEX idx_producto_categoria    ON producto     (categoria_id);
CREATE INDEX idx_producto_especie      ON producto     (especie_id);
CREATE INDEX idx_pedido_cliente        ON pedido       (cliente_id);
CREATE INDEX idx_pedido_estado         ON pedido       (estado);
CREATE INDEX idx_pedido_fecha          ON pedido       (fecha_pedido);
CREATE INDEX idx_detalle_pedido        ON detalle_pedido (pedido_id);
CREATE INDEX idx_detalle_producto      ON detalle_pedido (producto_id);
CREATE INDEX idx_pago_pedido           ON pago         (pedido_id);
CREATE INDEX idx_envio_pedido          ON envio        (pedido_id);
CREATE INDEX idx_resena_producto       ON resena       (producto_id);
CREATE INDEX idx_inventario_stock      ON inventario   (stock_actual);
CREATE INDEX idx_compra_proveedor      ON compra       (proveedor_id);
CREATE INDEX idx_direccion_cliente     ON direccion    (cliente_id);

-- ============================================================
-- DATOS SEMILLA (INSERT mínimo para pruebas)
-- ============================================================

-- Categorías raíz
INSERT INTO categoria (nombre, descripcion) VALUES
  ('Figuras y Juguetes',  'Réplicas en plástico, goma y resina'),
  ('Fósiles y Réplicas',  'Huesos, dientes y réplicas paleontológicas'),
  ('Libros y Educación',  'Literatura científica e infantil'),
  ('Ropa y Accesorios',   'Camisetas, gorras, tazas y más'),
  ('Kits Educativos',     'Excava tu propio dinosaurio y kits STEM');

-- Subcategoría ejemplo
INSERT INTO categoria (nombre, descripcion, categoria_padre_id) VALUES
  ('Figuras de acción', 'Articuladas y de colección', 1),
  ('Figuras de baño',   'Material de goma suave',    1);

-- Especies
INSERT INTO especie (nombre_comun, nombre_cientifico, era, dieta, longitud_m, peso_ton, region_origen) VALUES
  ('Tiranosaurio Rex',   'Tyrannosaurus rex',        'Cretácico', 'Carnívoro',  12.00, 8.40, 'Norteamérica'),
  ('Triceratops',        'Triceratops horridus',     'Cretácico', 'Herbívoro',  9.00,  12.00,'Norteamérica'),
  ('Velociraptor',       'Velociraptor mongoliensis','Cretácico', 'Carnívoro',  1.80,  0.02, 'Asia Central'),
  ('Brachiosaurus',      'Brachiosaurus altithorax', 'Jurásico',  'Herbívoro',  26.00, 56.00,'Norteamérica'),
  ('Stegosaurus',        'Stegosaurus stenops',      'Jurásico',  'Herbívoro',  9.00,  3.50, 'Norteamérica'),
  ('Pterodáctilo',       'Pterodactylus antiquus',   'Jurásico',  'Carnívoro',  1.00,  0.001,'Europa'),
  ('Ankylosaurus',       'Ankylosaurus magniventris','Cretácico', 'Herbívoro',  6.25,  6.00, 'Norteamérica');

-- Empleado y usuario admin de prueba
INSERT INTO empleado (nombre, apellidos, puesto, email_corporativo, fecha_contratacion, salario) VALUES
  ('Ana',   'García López',   'Administradora',  'ana.garcia@spideysaurus.com',   '2024-01-10', 25000.00),
  ('Pedro', 'Martínez Ruiz',  'Cajero',          'pedro.mtz@spideysaurus.com',    '2024-03-01', 14000.00),
  ('Lucía', 'Hernández Díaz', 'Bodeguera',       'lucia.hd@spideysaurus.com',     '2024-03-15', 13500.00);

INSERT INTO usuario (empleado_id, username, password_hash, rol) VALUES
  (1, 'admin',   '$2b$12$PLACEHOLDER_HASH_ADMIN',   'Admin'),
  (2, 'cajero1', '$2b$12$PLACEHOLDER_HASH_CAJERO',  'Cajero'),
  (3, 'bodega1', '$2b$12$PLACEHOLDER_HASH_BODEGA',  'Bodeguero');

-- Proveedor
INSERT INTO proveedor (nombre, contacto_nombre, email, pais) VALUES
  ('DinoFactory S.A.',    'Carlos Dino',  'ventas@dinofactory.mx',  'México'),
  ('Paleo Imports Ltd.',  'Sarah Stone',  'orders@paleoimports.com','Estados Unidos'),
  ('FósilesMX',           'Rogelio Vega', 'info@fosilesmx.com',     'México');

-- Productos de ejemplo
INSERT INTO producto (nombre, precio, precio_costo, categoria_id, especie_id) VALUES
  ('Figura T-Rex deluxe 30cm',       349.00, 120.00, 1, 1),
  ('Figura Triceratops articulada',  299.00, 100.00, 1, 2),
  ('Kit excava tu Velociraptor',     199.00,  65.00, 5, 3),
  ('Réplica diente T-Rex (yeso)',    450.00, 150.00, 2, 1),
  ('Libro: Guía completa dinosaurios',180.00, 70.00, 3, NULL),
  ('Camiseta Stegosaurus talla M',   120.00,  40.00, 4, 5),
  ('Figura Brachiosaurus 45cm',      520.00, 180.00, 1, 4);

-- Inventario inicial
INSERT INTO inventario (producto_id, stock_actual, stock_minimo, ubicacion) VALUES
  (1, 50, 10, 'A-01'),
  (2, 35, 10, 'A-02'),
  (3, 80, 15, 'B-01'),
  (4, 20,  5, 'C-01'),
  (5, 60, 10, 'D-01'),
  (6, 45, 10, 'E-01'),
  (7, 15,  5, 'A-03');

-- Cliente de prueba
INSERT INTO cliente (nombre, apellidos, email, telefono) VALUES
  ('Sofía',  'Ramírez Torres', 'sofia.ramirez@email.com', '6561234567'),
  ('Miguel', 'López Soto',     'miguel.lopez@email.com',  '6569876543');

INSERT INTO direccion (cliente_id, calle, colonia, ciudad, estado_region, codigo_postal, pais, es_principal) VALUES
  (1, 'Av. Juárez 456', 'Centro',     'Ciudad Juárez', 'Chihuahua', '32000', 'México', TRUE),
  (2, 'Calle Lerdo 89', 'Las Flores', 'Ciudad Juárez', 'Chihuahua', '32050', 'México', TRUE);

INSERT INTO usuario (cliente_id, username, password_hash, rol) VALUES
  (1, 'sofia_cliente',  '$2b$12$PLACEHOLDER_HASH_CLIENT1', 'Cliente'),
  (2, 'miguel_cliente', '$2b$12$PLACEHOLDER_HASH_CLIENT2', 'Cliente');

-- Promoción de prueba
INSERT INTO promocion (nombre, tipo_descuento, valor_descuento, fecha_inicio, fecha_fin, usos_maximos) VALUES
  ('Dino Fest 10% OFF', 'Porcentaje', 10.00, '2026-05-01', '2026-05-31', 500),
  ('Envío gratis Mayo',  'Envío gratis', 0.00, '2026-05-01', '2026-05-31', NULL);

-- Pedido de prueba
INSERT INTO pedido (cliente_id, empleado_id, promocion_id, estado, subtotal, descuento, impuesto, total) VALUES
  (1, 2, 1, 'Entregado', 648.00, 64.80, 0.00, 583.20);

INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario, descuento_linea, subtotal_linea) VALUES
  (1, 1, 1, 349.00, 34.90, 314.10),
  (1, 3, 1, 199.00, 19.90, 179.10),
  (1, 5, 1, 180.00, 10.00,  90.00);  -- descuento adicional por promo

INSERT INTO pago (pedido_id, metodo_pago, monto, estado, referencia) VALUES
  (1, 'Tarjeta crédito', 583.20, 'Completado', 'TXN-2026-001234');

INSERT INTO envio (pedido_id, direccion_id, transportista, numero_guia, fecha_estimada, fecha_entrega, estado, costo_envio) VALUES
  (1, 1, 'DHL', 'DHL-9876543210', '2026-05-08', '2026-05-07', 'Entregado', 0.00);

-- ============================================================
-- VISTAS ÚTILES
-- ============================================================

-- Resumen de stock por producto
CREATE OR REPLACE VIEW v_stock_productos AS
SELECT
  p.producto_id,
  p.nombre                      AS producto,
  c.nombre                      AS categoria,
  e.nombre_comun                AS especie,
  i.stock_actual,
  i.stock_minimo,
  i.ubicacion,
  (i.stock_actual <= i.stock_minimo) AS bajo_stock
FROM producto p
JOIN inventario i  ON i.producto_id  = p.producto_id
JOIN categoria  c  ON c.categoria_id = p.categoria_id
LEFT JOIN especie e ON e.especie_id  = p.especie_id;

-- Ventas por cliente
CREATE OR REPLACE VIEW v_ventas_cliente AS
SELECT
  cl.cliente_id,
  CONCAT(cl.nombre,' ',cl.apellidos) AS cliente,
  COUNT(p.pedido_id)                 AS total_pedidos,
  SUM(p.total)                       AS monto_total,
  MAX(p.fecha_pedido)                AS ultima_compra
FROM cliente cl
LEFT JOIN pedido p ON p.cliente_id = cl.cliente_id
GROUP BY cl.cliente_id, cl.nombre, cl.apellidos;

-- Productos más vendidos
CREATE OR REPLACE VIEW v_productos_mas_vendidos AS
SELECT
  pr.producto_id,
  pr.nombre                          AS producto,
  SUM(dp.cantidad)                   AS unidades_vendidas,
  SUM(dp.subtotal_linea)             AS ingresos_totales,
  AVG(r.calificacion)                AS calificacion_promedio
FROM producto pr
LEFT JOIN detalle_pedido dp ON dp.producto_id = pr.producto_id
LEFT JOIN resena          r  ON r.producto_id  = pr.producto_id
GROUP BY pr.producto_id, pr.nombre
ORDER BY unidades_vendidas DESC;

-- ============================================================
-- FIN DEL SCRIPT  –  bdspideysaurus.sql
-- ============================================================
