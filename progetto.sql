/* Pulizia */
DROP TABLE IF EXISTS Log;
DROP TABLE IF EXISTS Accesso;
DROP TABLE IF EXISTS Arma;
DROP TABLE IF EXISTS Armatura;
DROP TABLE IF EXISTS Lanciato;
DROP TABLE IF EXISTS Livello;
DROP TABLE IF EXISTS Posseduto;
DROP TABLE IF EXISTS Personaggio;
DROP TABLE IF EXISTS Classe;
DROP TABLE IF EXISTS Incantesimo;
DROP TABLE IF EXISTS Oggetto;
DROP TABLE IF EXISTS Razza;
DROP TABLE IF EXISTS Talento;

DROP VIEW IF EXISTS ElencoArmiUtilizzate;
DROP VIEW IF EXISTS ElencoArmatureUtilizzate;
DROP VIEW IF EXISTS ElencoScudiUtilizzati;
DROP VIEW IF EXISTS ElencoIncantesimiUtilizzati;
DROP VIEW IF EXISTS StatisticaClasseUsata;
DROP VIEW IF EXISTS RicchezzaPersonaggi;
/* Fine Pulizia */

/* Tabelle */
CREATE TABLE IF NOT EXISTS Log
(
ID smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT,
Descrizione varchar(190) DEFAULT NULL,
PRIMARY KEY (ID)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Classe
(
ID smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT,
Nome varchar(190) NOT NULL,
TagliaDadoVita ENUM ('12','10','8','6') NOT NULL,
BAB ENUM ('Full', 'ThreeQuarters', 'Half') NOT NULL,
Incanta ENUM ('Si', 'No') NOT NULL,
Tempra ENUM ('Good', 'Bad') NOT NULL,
Riflessi ENUM ('Good', 'Bad') NOT NULL,
Volontà ENUM ('Good', 'Bad') NOT NULL,
UNIQUE (Nome),
PRIMARY KEY (ID)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Incantesimo
(
ID smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT,
Nome varchar(190) NOT NULL,
Livello tinyint UNSIGNED NOT NULL,
Descrizione varchar(1024) DEFAULT NULL,
UNIQUE (Nome),
PRIMARY KEY (ID)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Oggetto
(
ID smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT,
Nome varchar(190) NOT NULL,
Descrizione varchar(1536) DEFAULT NULL,
Peso tinyint UNSIGNED NOT NULL,
Prezzo mediumint UNSIGNED NOT NULL,
LivelloIncantatore tinyint UNSIGNED DEFAULT NULL,
Slot ENUM ('Testa', 'Fronte', 'Occhi', 'Spalle', 'Collo', 'Torace', 'Corpo', 'Armatura', 'Cintura', 'Polsi', 'Anello', 'Mano', 'Non Equipaggiabile') NOT NULL DEFAULT 'Non Equipaggiabile',
UNIQUE (Nome),
PRIMARY KEY (ID)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Razza
(
ID smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT,
Nome varchar(190) NOT NULL,
Taglia ENUM ('Colossal', 'Gargantuan', 'Huge', 'Large', 'Medium', 'Small', 'Tiny', 'Diminutive', 'Fine') NOT NULL DEFAULT 'Medium',
Tipo varchar(190) NOT NULL,
UNIQUE (Nome),
PRIMARY KEY (ID)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Talento
(
ID smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT,
Nome varchar(190) NOT NULL,
Descrizione varchar(1024) DEFAULT NULL,
Tipologia ENUM ('DiClasse', 'DiRazza', 'Combat', 'General'),
UNIQUE (Nome),
PRIMARY KEY (ID)
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Personaggio
(
ID smallint(5) UNSIGNED NOT NULL AUTO_INCREMENT,
Nome varchar(190) NOT NULL,
NomeGiocatore varchar(190) NOT NULL,
Sesso ENUM ('M', 'F') NOT NULL,
Allineamento ENUM ('LB', 'NB', 'CB', 'LN', 'NN', 'CN', 'LM', 'NM', 'CM') DEFAULT 'NN',
Forza tinyint UNSIGNED NOT NULL DEFAULT 10,
Destrezza tinyint UNSIGNED NOT NULL DEFAULT 10,
Costituzione tinyint UNSIGNED NOT NULL DEFAULT 10,
Intelligenza tinyint UNSIGNED NOT NULL DEFAULT 10,
Saggezza tinyint UNSIGNED NOT NULL DEFAULT 10,
Carisma tinyint UNSIGNED NOT NULL DEFAULT 10,
IDRazza smallint(5) UNSIGNED NOT NULL,
UNIQUE (Nome, NomeGiocatore),
PRIMARY KEY (ID),
FOREIGN KEY (IDRazza) REFERENCES Razza(ID) ON DELETE CASCADE
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Accesso
(
IDPersonaggio smallint(5) UNSIGNED NOT NULL,
IDTalento smallint(5) UNSIGNED NOT NULL,
PRIMARY KEY (IDPersonaggio, IDTalento),
FOREIGN KEY (IDPersonaggio) REFERENCES Personaggio(ID) ON DELETE CASCADE,
FOREIGN KEY (IDTalento) REFERENCES Talento(ID) ON DELETE CASCADE
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Arma
(
IDOggetto smallint(5) UNSIGNED NOT NULL,
Danno varchar(9) NOT NULL,
Critico varchar(8) NOT NULL,
Gittata tinyint UNSIGNED NOT NULL DEFAULT 0,
TipoDiDanno varchar(3) NOT NULL,
PRIMARY KEY (IDOggetto),
FOREIGN KEY (IDOggetto) REFERENCES Oggetto(ID) ON UPDATE CASCADE ON DELETE CASCADE
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Armatura
(
IDOggetto smallint(5) UNSIGNED NOT NULL,
Bonus tinyint UNSIGNED NOT NULL,
DestrezzaMassima tinyint UNSIGNED DEFAULT NULL,
FallimentoArcano tinyint UNSIGNED NOT NULL DEFAULT 0,
Penalita tinyint UNSIGNED NOT NULL DEFAULT 0,
Tipologia ENUM ('Leggera', 'Media', 'Pesante', 'Scudo') NOT NULL DEFAULT 'Leggera',
PRIMARY KEY (IDOggetto),
FOREIGN KEY (IDOggetto) REFERENCES Oggetto(ID) ON UPDATE CASCADE ON DELETE CASCADE
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Lanciato
(
IDIncantesimo smallint(5) UNSIGNED NOT NULL,
IDPersonaggio smallint(5) UNSIGNED NOT NULL,
PRIMARY KEY (IDPersonaggio, IDIncantesimo),
FOREIGN KEY (IDIncantesimo) REFERENCES Incantesimo(ID) ON DELETE CASCADE,
FOREIGN KEY (IDPersonaggio) REFERENCES Personaggio(ID) ON DELETE CASCADE
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Livello
(
IDClasse smallint(5) UNSIGNED NOT NULL,
IDPersonaggio smallint(5) UNSIGNED NOT NULL,
Effettivo tinyint UNSIGNED DEFAULT 0,
PuntiVita tinyint UNSIGNED NOT NULL DEFAULT 1,
PRIMARY KEY (IDPersonaggio, Effettivo),
FOREIGN KEY (IDClasse) REFERENCES Classe(ID) ON DELETE CASCADE,
FOREIGN KEY (IDPersonaggio) REFERENCES Personaggio(ID) ON DELETE CASCADE
)ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS Posseduto
(
IDOggetto smallint(5) UNSIGNED NOT NULL,
IDPersonaggio smallint(5) UNSIGNED NOT NULL,
Equipaggiato boolean NOT NULL DEFAULT FALSE,
Quantita smallint(5) NOT NULL DEFAULT 0,
PRIMARY KEY (IDPersonaggio, IDOggetto),
FOREIGN KEY (IDOggetto) REFERENCES Oggetto(ID) ON DELETE CASCADE,
FOREIGN KEY (IDPersonaggio) REFERENCES Personaggio(ID) ON DELETE CASCADE
)ENGINE=InnoDB;
/* Fine Tabelle */

/* Funzioni */
DELIMITER $
-- CalcolaLivelloIncantatore
DROP FUNCTION IF EXISTS CalcolaLivelloIncantatore$
CREATE FUNCTION CalcolaLivelloIncantatore (IDPersonaggio smallint(5) UNSIGNED)
RETURNS tinyint 
DETERMINISTIC
READS SQL DATA
BEGIN
    RETURN (
        SELECT COUNT(*) 
        FROM Livello
        JOIN Classe ON Classe.ID = Livello.IDClasse
        WHERE Classe.Incanta = 'Si'
    );
END$

-- PulisciLivelliSuccessivi
DROP FUNCTION IF EXISTS PulisciLivelliSuccessivi$
CREATE FUNCTION PulisciLivelliSuccessivi (ID_Personaggio smallint(5) UNSIGNED, Livello tinyint UNSIGNED)
RETURNS tinyint
DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    SET @ret := (SELECT COUNT(*) FROM Livello WHERE IDPersonaggio = ID_Personaggio AND Effettivo > Livello);

    IF @ret > 0
    THEN
        DELETE FROM Livello
        WHERE IDPersonaggio = ID_Personaggio
            AND Effettivo > Livello;
    END IF;
    
    RETURN @ret;
END$

DELIMITER ;
/* Fine Funzioni */

/* Procedure */
DELIMITER $

-- CompattaLivelli
-- Compatta tutti i livelli di un personaggio
--  assegnando a Effettivo il valore minimo possibile mantenendo la sequenza
DROP PROCEDURE IF EXISTS CompattaLivelli$
CREATE PROCEDURE CompattaLivelli (Personaggio smallint(5) UNSIGNED)
DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    SET @top := (SELECT COUNT(*) FROM Livello WHERE IDPersonaggio = Personaggio);
    SET @counter := 1;
    
    WHILE @counter <= @top
    DO
        IF (SELECT COUNT(*) FROM Livello WHERE IDPersonaggio = Personaggio AND Effettivo = @counter) <> 1
        THEN
            UPDATE Livello
            SET Effettivo := (Effettivo - 1)
            WHERE IDPersonaggio = Personaggio
                AND Effettivo > @counter;
        ELSE
        	SET @counter := @counter + 1;
        END IF;
    END WHILE;
END$

-- ElencoEquipaggiato
-- Mostra gli oggetti equipaggiati dal Personaggio
DROP PROCEDURE IF EXISTS ElencoEquipaggiato$
CREATE PROCEDURE ElencoEquipaggiato (Personaggio smallint(5) UNSIGNED)
DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    SELECT Nome, Slot, Descrizione
    FROM Oggetto i
    JOIN Posseduto o ON i.ID = o.IDOggetto
    WHERE o.IDPersonaggio = Personaggio
    AND o.Equipaggiato = TRUE
    ORDER BY i.Slot ASC;
END$

DELIMITER ;
/* Fine Procedure */

/* Trigger */
DELIMITER $
-- LevelUp
DROP TRIGGER IF EXISTS LevelUp$
CREATE TRIGGER LevelUp
BEFORE INSERT ON Livello
FOR EACH ROW
BEGIN
    -- Set del livello effettivo
    SET @temp := (SELECT MAX(Effettivo) FROM Livello WHERE IDPersonaggio = NEW.IDPersonaggio) + 1;
    IF (@temp <> NEW.Effettivo AND (SELECT COUNT(*) FROM Livello WHERE IDPersonaggio = NEW.IDPersonaggio AND Effettivo = NEW.Effettivo) <> 0)
    THEN
        SET NEW.Effettivo := @temp;
        INSERT INTO Log(Descrizione) VALUES (CONCAT ('È stato sequenziato il livello effettivo: ',
            NEW.Effettivo));
    END IF;
    -- Controllo dei punti vita
    SET @temp := CAST((SELECT TagliaDadoVita FROM Classe WHERE ID = NEW.IDClasse) AS UNSIGNED INTEGER);
    IF (NEW.PuntiVita = 0 OR
        NEW.PuntiVita > @temp)
    THEN
        INSERT INTO Log(Descrizione) VALUES (CONCAT ('I Punti vita non sono validi (',
            NEW.PuntiVita,
            '), sono stati settati a 1 ')
        );
        SET NEW.PuntiVita := 1;
    END IF;
    --
END$

-- LevelCheck
DROP TRIGGER IF EXISTS LevelCheck$
CREATE TRIGGER LevelCheck
BEFORE UPDATE ON Livello
FOR EACH ROW
BEGIN
    -- Controllo dei punti vita
    SET @temp := CAST((SELECT TagliaDadoVita FROM Classe WHERE ID = NEW.IDClasse) AS UNSIGNED INTEGER);
    IF (NEW.PuntiVita = 0 OR
        NEW.PuntiVita > @temp)
    THEN
        INSERT INTO Log(Descrizione) VALUES (CONCAT ('I Punti vita non sono validi (',
            NEW.PuntiVita,
            '), sono stati settati a 1 ')
        );
        SET NEW.PuntiVita := 1;
    END IF;
    --
END$

-- ControlloArmatura
DROP TRIGGER IF EXISTS ControlloArmatura$
CREATE TRIGGER ControlloArmatura
BEFORE INSERT ON Armatura
FOR EACH ROW
BEGIN
    SET @flag := 0;
    IF NEW.Tipologia = 'Scudo' AND (SELECT Slot FROM Oggetto WHERE ID = NEW.IDOggetto) <> 'Mano'
    THEN
        INSERT INTO Log(Descrizione)
        VALUES ('Slot inadatto per uno scudo');
        SET @flag := 1;
    ELSEIF NEW.Tipologia <> 'Scudo' AND (SELECT Slot FROM Oggetto WHERE ID = NEW.IDOggetto) <> 'Armatura'
    THEN
        INSERT INTO Log(Descrizione)
        VALUES ('Slot inadatto per una armatura');
        SET @flag := 2;
    END IF;
    IF @flag <> 0
    THEN
        SET NEW.IDOggetto := NULL;
    END IF;
END$

DELIMITER ;
/* Fine Trigger */

/* Query */

-- ElencoArmiUtilizzate
-- Elenca le armi aggiungendo gli attributi dell'oggetto riferito utilizzate dai personaggi
CREATE VIEW ElencoArmiUtilizzate
AS
    SELECT Nome, Danno, Critico, TipoDiDanno, Gittata, Descrizione
    FROM Oggetto i
    JOIN Arma w ON i.ID = w.IDOggetto
    JOIN Posseduto o ON i.ID = o.IDOggetto
    ORDER BY i.Nome ASC;

-- ElencoArmatureUtilizzate
-- Elenca le armature aggiungendo gli attributi dell'oggetto riferito utilizzate dai personaggi
CREATE VIEW ElencoArmatureUtilizzate
AS
    SELECT Nome, Bonus, DestrezzaMassima, FallimentoArcano, Penalita, Tipologia, Descrizione
    FROM Oggetto i
    JOIN Armatura a ON i.ID = a.IDOggetto
    JOIN Posseduto o ON i.ID = o.IDOggetto
    WHERE a.Tipologia <> 'Scudo'
    ORDER BY a.Tipologia ASC;
    
-- ElencoScudiUtilizzati
-- Elenca gli scudi aggiungendo gli attributi dell'oggetto riferito utilizzati dai personaggi
CREATE VIEW ElencoScudiUtilizzati
AS
    SELECT Nome, Danno, Bonus, DestrezzaMassima, FallimentoArcano, Penalita, Tipologia, Descrizione
    FROM Oggetto i
    JOIN Armatura a ON i.ID = a.IDOggetto
    JOIN Arma w ON i.ID = w.IDOggetto
    JOIN Posseduto o ON i.ID = o.IDOggetto
    WHERE a.Tipologia = 'Scudo'
    ORDER BY i.Nome ASC;
    
-- ElencoIncantesimiUtilizzati
-- Elenca gli incantesimi utilizzati
CREATE VIEW ElencoIncantesimiUtilizzati
AS
    SELECT Nome, Livello, Descrizione
    FROM Incantesimo s
    JOIN Lanciato t ON s.ID = t.IDIncantesimo
    ORDER BY s.Livello ASC;
    
-- StatisticaClasseUsata
-- Elenca le classi per frequenza di utilizzo
CREATE VIEW StatisticaClasseUsata
AS
    SELECT c.Nome NomeClasse, COUNT(DISTINCT l.IDPersonaggio) NumeroUtilizzi, COUNT(*)/COUNT(DISTINCT l.IDPersonaggio) MediaLivelli
    FROM Livello l, Classe c
    WHERE l.IDClasse = c.ID
    GROUP BY c.ID
    ORDER BY NumeroUtilizzi DESC;

-- RicchezzaPersonaggi
-- Elenca i personaggi assegnando la loro ricchezza
CREATE VIEW RicchezzaPersonaggi
AS    
    SELECT c.nome, SUM(i.prezzo) AS Totale
    FROM Personaggio c
    JOIN Posseduto o ON c.ID = o.IDPersonaggio
    JOIN Oggetto i ON o.IDOggetto = i.ID
    GROUP BY c.ID
    ORDER BY c.Nome;

/* Popolazione */ 
-- Classe
LOAD DATA LOCAL INFILE 'Dati/classe.csv'
INTO TABLE Classe
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

-- Incantesimo
LOAD DATA LOCAL INFILE 'Dati/incantesimo.csv'
INTO TABLE Incantesimo
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

-- Oggetto
LOAD DATA LOCAL INFILE 'Dati/oggetto.csv'
INTO TABLE Oggetto
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

-- Razza
LOAD DATA LOCAL INFILE 'Dati/razza.csv'
INTO TABLE Razza
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

-- Talento
LOAD DATA LOCAL INFILE 'Dati/talento.csv'
INTO TABLE Talento
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

-- Personaggio
LOAD DATA LOCAL INFILE 'Dati/personaggio.csv'
INTO TABLE Personaggio
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

-- Accesso
LOAD DATA LOCAL INFILE 'Dati/accesso.csv'
INTO TABLE Accesso
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

-- Arma
LOAD DATA LOCAL INFILE 'Dati/arma.csv'
INTO TABLE Arma
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

-- Armatura
LOAD DATA LOCAL INFILE 'Dati/armatura.csv'
INTO TABLE Armatura
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

-- Lanciato
LOAD DATA LOCAL INFILE 'Dati/lanciato.csv'
INTO TABLE Lanciato
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

-- Livello
LOAD DATA LOCAL INFILE 'Dati/livello.csv'
INTO TABLE Livello
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';

-- Posseduto
LOAD DATA LOCAL INFILE 'Dati/posseduto.csv'
INTO TABLE Posseduto
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';
