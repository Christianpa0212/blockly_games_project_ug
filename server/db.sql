-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: db:3306
-- Generation Time: Sep 14, 2025 at 12:15 AM
-- Server version: 8.0.41
-- PHP Version: 8.2.29

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `blockly_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`%` PROCEDURE `sp_session_end` (IN `p_session_id` CHAR(36))   BEGIN
  UPDATE sesiones
     SET fin_hora_fecha = NOW()
   WHERE session_id = p_session_id
     AND fin_hora_fecha IS NULL;

  -- 1 si cerró, 0 si ya estaba cerrada o no existía
  SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `sp_session_start` (IN `p_usuario_id` INT)   BEGIN
  DECLARE v_session_id CHAR(36);
  SET v_session_id = UUID();  -- genera 36 chars (con guiones)

  -- (OPCIONAL) Si quieres evitar múltiples sesiones abiertas por usuario,
  -- descomenta este UPDATE:
  -- UPDATE sesiones
  --    SET fin_hora_fecha = NOW()
  --  WHERE usuario_id = p_usuario_id
  --    AND fin_hora_fecha IS NULL;

  INSERT INTO sesiones (session_id, usuario_id, inicio_hora_fecha)
  VALUES (v_session_id, p_usuario_id, NOW());

  -- Devuelve el identificador de la sesión creada
  SELECT v_session_id AS session_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `eventos`
--

CREATE TABLE `eventos` (
  `evento_id` bigint NOT NULL,
  `partida_id` bigint NOT NULL,
  `tipo` varchar(50) NOT NULL,
  `secuencia` int NOT NULL,
  `timestamp` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `eventos`
--

INSERT INTO `eventos` (`evento_id`, `partida_id`, `tipo`, `secuencia`, `timestamp`) VALUES
(1, 2, 'bloque.create', 1, '2025-09-13 22:44:14'),
(2, 2, 'ui.run', 2, '2025-09-13 22:45:03'),
(3, 2, 'bloque.create', 3, '2025-09-13 22:45:42'),
(4, 2, 'ui.reset', 4, '2025-09-13 22:59:27'),
(5, 2, 'ui.reset', 5, '2025-09-13 23:04:28'),
(6, 2, 'ui.reset', 6, '2025-09-13 23:04:33');

-- --------------------------------------------------------

--
-- Table structure for table `juegos`
--

CREATE TABLE `juegos` (
  `juego_id` int NOT NULL,
  `nombre_juego` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `juegos`
--

INSERT INTO `juegos` (`juego_id`, `nombre_juego`) VALUES
(1, 'maze'),
(2, 'puzzle');

-- --------------------------------------------------------

--
-- Table structure for table `niveles`
--

CREATE TABLE `niveles` (
  `nivel_id` int NOT NULL,
  `juego_id` int NOT NULL,
  `numero` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `niveles`
--

INSERT INTO `niveles` (`nivel_id`, `juego_id`, `numero`) VALUES
(1, 1, 1),
(2, 1, 2);

-- --------------------------------------------------------

--
-- Table structure for table `partidas`
--

CREATE TABLE `partidas` (
  `partida_id` bigint NOT NULL,
  `session_id` char(36) NOT NULL,
  `juego_id` int NOT NULL,
  `nivel_id` int NOT NULL,
  `tiempo` int DEFAULT NULL,
  `numero_movimientos` int DEFAULT '0',
  `numero_reinicios` int DEFAULT '0',
  `estado` enum('en curso','completada','abandonada') DEFAULT 'en curso'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `partidas`
--

INSERT INTO `partidas` (`partida_id`, `session_id`, `juego_id`, `nivel_id`, `tiempo`, `numero_movimientos`, `numero_reinicios`, `estado`) VALUES
(2, 'f1165f63-90ee-11f0-9fc0-a2bc3c50d43f', 1, 1, 1200, 3, 3, 'completada');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `rol_id` int NOT NULL,
  `nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`rol_id`, `nombre`) VALUES
(1, 'alumno'),
(2, 'admin');

-- --------------------------------------------------------

--
-- Table structure for table `sesiones`
--

CREATE TABLE `sesiones` (
  `session_id` char(36) NOT NULL,
  `usuario_id` int NOT NULL,
  `inicio_hora_fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fin_hora_fecha` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `sesiones`
--

INSERT INTO `sesiones` (`session_id`, `usuario_id`, `inicio_hora_fecha`, `fin_hora_fecha`) VALUES
('f1165f63-90ee-11f0-9fc0-a2bc3c50d43f', 1, '2025-09-13 22:13:56', '2025-09-13 23:11:05');

-- --------------------------------------------------------

--
-- Table structure for table `usuarios`
--

CREATE TABLE `usuarios` (
  `usuario_id` int NOT NULL,
  `usuario` varchar(50) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellidos` varchar(100) NOT NULL,
  `password` varchar(255) DEFAULT NULL,
  `fecha_creacion` datetime DEFAULT CURRENT_TIMESTAMP,
  `rol_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `usuarios`
--

INSERT INTO `usuarios` (`usuario_id`, `usuario`, `nombre`, `apellidos`, `password`, `fecha_creacion`, `rol_id`) VALUES
(1, '0001', 'Prueba', 'Prueba Uno', NULL, '2025-09-13 21:48:45', 1);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_auth_login`
-- (See below for the actual view)
--
CREATE TABLE `vw_auth_login` (
`usuario_id` int
,`usuario` varchar(50)
,`password` varchar(255)
,`rol_id` int
,`rol_nombre` varchar(50)
);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `eventos`
--
ALTER TABLE `eventos`
  ADD PRIMARY KEY (`evento_id`),
  ADD KEY `partida_id` (`partida_id`);

--
-- Indexes for table `juegos`
--
ALTER TABLE `juegos`
  ADD PRIMARY KEY (`juego_id`);

--
-- Indexes for table `niveles`
--
ALTER TABLE `niveles`
  ADD PRIMARY KEY (`nivel_id`),
  ADD KEY `juego_id` (`juego_id`);

--
-- Indexes for table `partidas`
--
ALTER TABLE `partidas`
  ADD PRIMARY KEY (`partida_id`),
  ADD KEY `session_id` (`session_id`),
  ADD KEY `juego_id` (`juego_id`),
  ADD KEY `nivel_id` (`nivel_id`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`rol_id`);

--
-- Indexes for table `sesiones`
--
ALTER TABLE `sesiones`
  ADD PRIMARY KEY (`session_id`),
  ADD KEY `usuario_id` (`usuario_id`);

--
-- Indexes for table `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`usuario_id`),
  ADD UNIQUE KEY `usuario` (`usuario`),
  ADD KEY `rol_id` (`rol_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `eventos`
--
ALTER TABLE `eventos`
  MODIFY `evento_id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `juegos`
--
ALTER TABLE `juegos`
  MODIFY `juego_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `niveles`
--
ALTER TABLE `niveles`
  MODIFY `nivel_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `partidas`
--
ALTER TABLE `partidas`
  MODIFY `partida_id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `rol_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `usuario_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

-- --------------------------------------------------------

--
-- Structure for view `vw_auth_login`
--
DROP TABLE IF EXISTS `vw_auth_login`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`%` SQL SECURITY DEFINER VIEW `vw_auth_login`  AS SELECT `u`.`usuario_id` AS `usuario_id`, `u`.`usuario` AS `usuario`, `u`.`password` AS `password`, `u`.`rol_id` AS `rol_id`, `r`.`nombre` AS `rol_nombre` FROM (`usuarios` `u` join `roles` `r` on((`r`.`rol_id` = `u`.`rol_id`))) ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `eventos`
--
ALTER TABLE `eventos`
  ADD CONSTRAINT `eventos_ibfk_1` FOREIGN KEY (`partida_id`) REFERENCES `partidas` (`partida_id`);

--
-- Constraints for table `niveles`
--
ALTER TABLE `niveles`
  ADD CONSTRAINT `niveles_ibfk_1` FOREIGN KEY (`juego_id`) REFERENCES `juegos` (`juego_id`);

--
-- Constraints for table `partidas`
--
ALTER TABLE `partidas`
  ADD CONSTRAINT `partidas_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `sesiones` (`session_id`),
  ADD CONSTRAINT `partidas_ibfk_2` FOREIGN KEY (`juego_id`) REFERENCES `juegos` (`juego_id`),
  ADD CONSTRAINT `partidas_ibfk_3` FOREIGN KEY (`nivel_id`) REFERENCES `niveles` (`nivel_id`);

--
-- Constraints for table `sesiones`
--
ALTER TABLE `sesiones`
  ADD CONSTRAINT `sesiones_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`usuario_id`);

--
-- Constraints for table `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`rol_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
