-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Creato il: Feb 26, 2022 alle 12:57
-- Versione del server: 10.4.20-MariaDB
-- Versione PHP: 8.0.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `progetto`
--

-- --------------------------------------------------------

--
-- Struttura della tabella `esiti`
--

CREATE TABLE `esiti` (
  `esito` varchar(16) NOT NULL CHECK (`esito` = 'Approvato' or `esito` = 'Rifiutato'),
  `id_partecipante` int(16) NOT NULL,
  `id` int(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dump dei dati per la tabella `esiti`
--

INSERT INTO `esiti` (`esito`, `id_partecipante`, `id`) VALUES
('Approvato', 1500, 754),
('Rifiutato', 1500, 755),
('Approvato', 1500, 756);

--
-- Trigger `esiti`
--
DELIMITER $$
CREATE TRIGGER `Modifica rating` AFTER INSERT ON `esiti` FOR EACH ROW BEGIN
    DECLARE somma_approvati FLOAT;
    DECLARE somma_rifiutati FLOAT;
    DECLARE rapporto FLOAT;

    SELECT COUNT(id_partecipante) INTO somma_approvati
    FROM esiti
    WHERE esito = "Approvato"
    AND id_partecipante = new.id_partecipante;

    SELECT COUNT(id_partecipante) INTO somma_rifiutati
    FROM esiti
    WHERE esito = "Rifiutato"
    AND id_partecipante = new.id_partecipante;
	
    SELECT ((somma_approvati)/(somma_approvati+somma_rifiutati)) INTO rapporto;
    UPDATE partecipante
    SET partecipante.rating = rapporto
    WHERE id_partecipante = new.id_partecipante;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `partecipante`
--

CREATE TABLE `partecipante` (
  `id_partecipante` int(16) NOT NULL,
  `nome` varchar(16) NOT NULL,
  `cognome` varchar(16) NOT NULL,
  `e_mail` varchar(64) NOT NULL,
  `rating` float NOT NULL,
  `eta` int(16) NOT NULL,
  `reddito` int(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dump dei dati per la tabella `partecipante`
--

INSERT INTO `partecipante` (`id_partecipante`, `nome`, `cognome`, `e_mail`, `rating`, `eta`, `reddito`) VALUES
(1500, 'Guido', 'Verdi', 'guidoverdi@gmail', 0.666667, 26, 25000),
(1501, 'Francesco', 'Gialli', 'francescogialli@gmail.com', 1, 18, 10000);

-- --------------------------------------------------------

--
-- Struttura della tabella `portafoglio`
--

CREATE TABLE `portafoglio` (
  `bilancio` float NOT NULL,
  `id_portafoglio` int(16) NOT NULL,
  `id_partecipante` int(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dump dei dati per la tabella `portafoglio`
--

INSERT INTO `portafoglio` (`bilancio`, `id_portafoglio`, `id_partecipante`) VALUES
(4, 523, 1500);

-- --------------------------------------------------------

--
-- Struttura della tabella `ricarica`
--

CREATE TABLE `ricarica` (
  `importo` float NOT NULL,
  `data_ricarica` datetime(6) NOT NULL,
  `id_portafoglio` int(16) NOT NULL,
  `id_ricercatore` int(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struttura della tabella `ricercatore`
--

CREATE TABLE `ricercatore` (
  `id_ricercatore` int(16) NOT NULL,
  `nome` varchar(16) NOT NULL,
  `cognome` varchar(16) NOT NULL,
  `e_mail` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dump dei dati per la tabella `ricercatore`
--

INSERT INTO `ricercatore` (`id_ricercatore`, `nome`, `cognome`, `e_mail`) VALUES
(523, 'Guido', 'Verdi', 'guidoverdi@gmail');

-- --------------------------------------------------------

--
-- Struttura della tabella `sondaggi`
--

CREATE TABLE `sondaggi` (
  `id` int(16) NOT NULL,
  `durata_stimata` int(16) NOT NULL,
  `retribuzione` int(16) NOT NULL,
  `posti_totali` int(16) NOT NULL,
  `eta_min` int(16) NOT NULL,
  `eta_max` int(16) NOT NULL,
  `reddito_min` int(16) NOT NULL,
  `reddito_max` int(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dump dei dati per la tabella `sondaggi`
--

INSERT INTO `sondaggi` (`id`, `durata_stimata`, `retribuzione`, `posti_totali`, `eta_min`, `eta_max`, `reddito_min`, `reddito_max`) VALUES
(754, 15, 3, 150, 18, 25, 15000, 45000),
(755, 12, 3, 140, 21, 50, 10000, 65000),
(756, 50, 5, 25, 25, 35, 18000, 40000),
(757, 12, 1, 250, 20, 30, 10000, 60000),
(758, 12, 1, 250, 29, 30, 10000, 60000),
(759, 15, 3, 150, 18, 25, 15000, 45000),
(761, 15, 3, 150, 18, 26, 15000, 45000);

--
-- Trigger `sondaggi`
--
DELIMITER $$
CREATE TRIGGER `Requisiti sondaggio` AFTER INSERT ON `sondaggi` FOR EACH ROW BEGIN
	DECLARE etamin INT;
    DECLARE etamax INT;
    DECLARE redditomin INT;
    DECLARE redditomax INT;
    DECLARE idp INT;
    
    SELECT new.eta_min, new.eta_max, new.reddito_min, new.reddito_max
    INTO etamin, etamax, redditomin, redditomax;
    
    SELECT id_partecipante INTO idp
    FROM partecipante
    WHERE eta>=etamin AND eta<=etamax
    AND reddito>=redditomin AND reddito<=redditomax
    LIMIT 1;
    
    IF (idp IS NOT NULL)
        THEN INSERT INTO sondaggi_proposti
            SELECT new.posti_totali, p.id_partecipante, new.id
            FROM partecipante p
            WHERE eta>=etamin AND eta<=etamax
            AND reddito>=redditomin AND reddito<=redditomax;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `sondaggi_partecipati`
--

CREATE TABLE `sondaggi_partecipati` (
  `data_svolgimento` datetime(6) NOT NULL,
  `id_partecipante` int(16) NOT NULL,
  `id` int(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struttura della tabella `sondaggi_proposti`
--

CREATE TABLE `sondaggi_proposti` (
  `posti_disponibili` int(16) NOT NULL,
  `id_partecipante` int(16) NOT NULL,
  `id` int(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dump dei dati per la tabella `sondaggi_proposti`
--

INSERT INTO `sondaggi_proposti` (`posti_disponibili`, `id_partecipante`, `id`) VALUES
(250, 1500, 757),
(150, 1500, 761);

-- --------------------------------------------------------

--
-- Struttura della tabella `transazioni`
--

CREATE TABLE `transazioni` (
  `importo` int(16) NOT NULL,
  `operazione` varchar(16) NOT NULL CHECK (`operazione` = 'Ricarica' or `operazione` = 'Prelievo'),
  `data_t` datetime(6) NOT NULL,
  `id_portafoglio` int(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dump dei dati per la tabella `transazioni`
--

INSERT INTO `transazioni` (`importo`, `operazione`, `data_t`, `id_portafoglio`) VALUES
(5, 'Prelievo', '2021-11-16 23:22:32.000000', 523),
(5, 'Prelievo', '2021-11-16 23:22:45.000000', 523);

--
-- Trigger `transazioni`
--
DELIMITER $$
CREATE TRIGGER `Aggiorna bilancio` BEFORE INSERT ON `transazioni` FOR EACH ROW BEGIN
DECLARE b FLOAT;

SELECT bilancio INTO b FROM portafoglio WHERE portafoglio.id_portafoglio = new.id_portafoglio;

IF new.operazione = "Ricarica"
	THEN UPDATE portafoglio SET portafoglio.bilancio = portafoglio.bilancio + new.importo
    WHERE portafoglio.id_portafoglio = new.id_portafoglio;
ELSEIF new.operazione = "Prelievo"
	THEN IF b < new.importo
    	 	THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Bilancio insufficiente";
         ELSEIF b < 5
        	THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Puoi prelevare un minimo di 5€";
         END IF;
    ELSE UPDATE portafoglio SET portafoglio.bilancio = portafoglio.bilancio - new.importo WHERE portafoglio.id_portafoglio = new.id_portafoglio;
END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `vede`
--

CREATE TABLE `vede` (
  `id_partecipante` int(16) NOT NULL,
  `id` int(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `esiti`
--
ALTER TABLE `esiti`
  ADD PRIMARY KEY (`id`,`id_partecipante`),
  ADD KEY `id_partecipante` (`id_partecipante`);

--
-- Indici per le tabelle `partecipante`
--
ALTER TABLE `partecipante`
  ADD PRIMARY KEY (`id_partecipante`);

--
-- Indici per le tabelle `portafoglio`
--
ALTER TABLE `portafoglio`
  ADD PRIMARY KEY (`id_portafoglio`),
  ADD KEY `id_partecipante` (`id_partecipante`);

--
-- Indici per le tabelle `ricarica`
--
ALTER TABLE `ricarica`
  ADD PRIMARY KEY (`id_portafoglio`,`id_ricercatore`,`importo`,`data_ricarica`),
  ADD KEY `id_ricercatore` (`id_ricercatore`);

--
-- Indici per le tabelle `ricercatore`
--
ALTER TABLE `ricercatore`
  ADD PRIMARY KEY (`id_ricercatore`);

--
-- Indici per le tabelle `sondaggi`
--
ALTER TABLE `sondaggi`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `sondaggi_partecipati`
--
ALTER TABLE `sondaggi_partecipati`
  ADD PRIMARY KEY (`id`,`id_partecipante`),
  ADD KEY `id_partecipante` (`id_partecipante`);

--
-- Indici per le tabelle `sondaggi_proposti`
--
ALTER TABLE `sondaggi_proposti`
  ADD PRIMARY KEY (`id`,`id_partecipante`),
  ADD KEY `sondaggi_proposti_ibfk_2` (`id_partecipante`);

--
-- Indici per le tabelle `transazioni`
--
ALTER TABLE `transazioni`
  ADD PRIMARY KEY (`id_portafoglio`,`operazione`,`importo`,`data_t`);

--
-- Indici per le tabelle `vede`
--
ALTER TABLE `vede`
  ADD PRIMARY KEY (`id_partecipante`,`id`),
  ADD KEY `id` (`id`);

--
-- AUTO_INCREMENT per le tabelle scaricate
--

--
-- AUTO_INCREMENT per la tabella `partecipante`
--
ALTER TABLE `partecipante`
  MODIFY `id_partecipante` int(16) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1502;

--
-- AUTO_INCREMENT per la tabella `portafoglio`
--
ALTER TABLE `portafoglio`
  MODIFY `id_portafoglio` int(16) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=524;

--
-- AUTO_INCREMENT per la tabella `ricercatore`
--
ALTER TABLE `ricercatore`
  MODIFY `id_ricercatore` int(16) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=524;

--
-- AUTO_INCREMENT per la tabella `sondaggi`
--
ALTER TABLE `sondaggi`
  MODIFY `id` int(16) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=766;

--
-- Limiti per le tabelle scaricate
--

--
-- Limiti per la tabella `esiti`
--
ALTER TABLE `esiti`
  ADD CONSTRAINT `esiti_ibfk_1` FOREIGN KEY (`id`) REFERENCES `sondaggi` (`id`),
  ADD CONSTRAINT `esiti_ibfk_2` FOREIGN KEY (`id_partecipante`) REFERENCES `partecipante` (`id_partecipante`);

--
-- Limiti per la tabella `portafoglio`
--
ALTER TABLE `portafoglio`
  ADD CONSTRAINT `portafoglio_ibfk_1` FOREIGN KEY (`id_partecipante`) REFERENCES `partecipante` (`id_partecipante`);

--
-- Limiti per la tabella `ricarica`
--
ALTER TABLE `ricarica`
  ADD CONSTRAINT `ricarica_ibfk_1` FOREIGN KEY (`id_portafoglio`) REFERENCES `portafoglio` (`id_portafoglio`),
  ADD CONSTRAINT `ricarica_ibfk_2` FOREIGN KEY (`id_ricercatore`) REFERENCES `ricercatore` (`id_ricercatore`);

--
-- Limiti per la tabella `sondaggi_partecipati`
--
ALTER TABLE `sondaggi_partecipati`
  ADD CONSTRAINT `sondaggi_partecipati_ibfk_1` FOREIGN KEY (`id`) REFERENCES `sondaggi` (`id`),
  ADD CONSTRAINT `sondaggi_partecipati_ibfk_2` FOREIGN KEY (`id_partecipante`) REFERENCES `partecipante` (`id_partecipante`);

--
-- Limiti per la tabella `sondaggi_proposti`
--
ALTER TABLE `sondaggi_proposti`
  ADD CONSTRAINT `sondaggi_proposti_ibfk_1` FOREIGN KEY (`id`) REFERENCES `sondaggi` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `sondaggi_proposti_ibfk_2` FOREIGN KEY (`id_partecipante`) REFERENCES `partecipante` (`id_partecipante`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limiti per la tabella `transazioni`
--
ALTER TABLE `transazioni`
  ADD CONSTRAINT `transazioni_ibfk_1` FOREIGN KEY (`id_portafoglio`) REFERENCES `portafoglio` (`id_portafoglio`);

--
-- Limiti per la tabella `vede`
--
ALTER TABLE `vede`
  ADD CONSTRAINT `vede_ibfk_1` FOREIGN KEY (`id_partecipante`) REFERENCES `partecipante` (`id_partecipante`),
  ADD CONSTRAINT `vede_ibfk_2` FOREIGN KEY (`id`) REFERENCES `sondaggi` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
