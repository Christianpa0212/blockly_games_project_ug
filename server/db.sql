
DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`%` PROCEDURE `sp_session_end` (IN `p_session_id` CHAR(36))   BEGIN
  UPDATE sesiones
     SET fin_hora_fecha = NOW()
   WHERE session_id = p_session_id
     AND fin_hora_fecha IS NULL;

  SELECT ROW_COUNT() AS affected_rows;
END$$

CREATE DEFINER=`root`@`%` PROCEDURE `sp_session_start` (IN `p_usuario_id` INT)   BEGIN
  DECLARE v_session_id CHAR(36);
  SET v_session_id = UUID(); 


  INSERT INTO sesiones (session_id, usuario_id, inicio_hora_fecha)
  VALUES (v_session_id, p_usuario_id, NOW());

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

-- --------------------------------------------------------

--
-- Table structure for table `juegos`
--

CREATE TABLE `juegos` (
  `juego_id` int NOT NULL,
  `nombre_juego` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `niveles`
--

CREATE TABLE `niveles` (
  `nivel_id` int NOT NULL,
  `juego_id` int NOT NULL,
  `numero` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `rol_id` int NOT NULL,
  `nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

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

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_auth_login`
-- (See below for the actual view)
--
CREATE TABLE `vw_auth_login` (
`password` varchar(255)
,`rol_id` int
,`rol_nombre` varchar(50)
,`usuario` varchar(50)
,`usuario_id` int
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
  MODIFY `evento_id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `juegos`
--
ALTER TABLE `juegos`
  MODIFY `juego_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `niveles`
--
ALTER TABLE `niveles`
  MODIFY `nivel_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `partidas`
--
ALTER TABLE `partidas`
  MODIFY `partida_id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `rol_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `usuario_id` int NOT NULL AUTO_INCREMENT;

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
