-- ==========================================================
-- BASE DE DATOS 
-- Proyecto: Registro de interacciones de Blockly Games
-- Fecha: 2025-09-11
-- ==========================================================

-- ----------------------------------------------------------
-- 1. Tabla de roles
-- Contiene los tipos de usuario del sistema (alumno, admin).
-- ----------------------------------------------------------
CREATE TABLE roles (
  rol_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL
);

-- ----------------------------------------------------------
-- 2. Tabla de usuarios
-- Almacena los datos de cada usuario.
-- Los alumnos no requieren contraseña; los administradores sí.
-- ----------------------------------------------------------
CREATE TABLE usuarios (
  usuario_id INT AUTO_INCREMENT PRIMARY KEY,
  usuario VARCHAR(50) NOT NULL UNIQUE,     
  nombre VARCHAR(100) NOT NULL,
  apellidos VARCHAR(100) NOT NULL,
  password VARCHAR(255) NULL,              
  fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
  rol_id INT NOT NULL,
  FOREIGN KEY (rol_id) REFERENCES roles(rol_id)
);

-- ----------------------------------------------------------
-- 3. Tabla de juegos
-- Catálogo de juegos disponibles 
-- ----------------------------------------------------------
CREATE TABLE juegos (
  juego_id INT AUTO_INCREMENT PRIMARY KEY,
  nombre_juego VARCHAR(100) NOT NULL
);

-- ----------------------------------------------------------
-- 4. Tabla de niveles
-- Define los niveles de cada juego.
-- ----------------------------------------------------------
CREATE TABLE niveles (
  nivel_id INT AUTO_INCREMENT PRIMARY KEY,
  juego_id INT NOT NULL,
  numero INT NOT NULL,                     
  FOREIGN KEY (juego_id) REFERENCES juegos(juego_id)
);

-- ----------------------------------------------------------
-- 5. Tabla de sesiones
-- Cada inicio/cierre de sesión de un usuario.
-- Una sesión puede abarcar múltiples partidas y juegos.
-- ----------------------------------------------------------
CREATE TABLE sesiones (
  session_id CHAR(36) PRIMARY KEY,         
  usuario_id INT NOT NULL,
  inicio_hora_fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fin_hora_fecha DATETIME NULL,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
);

-- ----------------------------------------------------------
-- 6. Tabla de partidas
-- Representa cada intento de un usuario en un juego/nivel dentro de una sesión.
-- Contiene métricas resumidas (tiempo total, movimientos, reinicios, estado).
-- ----------------------------------------------------------
CREATE TABLE partidas (
  partida_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  session_id CHAR(36) NOT NULL,
  juego_id INT NOT NULL,
  nivel_id INT NOT NULL,
  tiempo INT NULL,                         
  numero_movimientos INT DEFAULT 0,
  numero_reinicios INT DEFAULT 0,
  estado ENUM('en curso','completada','abandonada') DEFAULT 'en curso',
  FOREIGN KEY (session_id) REFERENCES sesiones(session_id),
  FOREIGN KEY (juego_id) REFERENCES juegos(juego_id),
  FOREIGN KEY (nivel_id) REFERENCES niveles(nivel_id)
);

-- ----------------------------------------------------------
-- 7. Tabla de eventos
-- Guarda el detalle fino de cada interacción durante la partida.
-- ----------------------------------------------------------
CREATE TABLE eventos (
  evento_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  partida_id BIGINT NOT NULL,
  tipo VARCHAR(50) NOT NULL,               
  secuencia INT NOT NULL,                  
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (partida_id) REFERENCES partidas(partida_id)
);
