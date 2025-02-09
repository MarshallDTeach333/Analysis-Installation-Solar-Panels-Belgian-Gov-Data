

-- PK aan NIS_Codes geven
ALTER TABLE NIS_Codes
MODIFY NIS_Code VARCHAR(20) PRIMARY KEY;

-- Nakijken of we Nis_Codes als PK kunnen gebruiken (zijn er duplicaten?)
SELECT NIS_Code, COUNT(*) AS aantal
FROM NIS_Codes
GROUP BY (1)
HAVING aantal > 1;


-- Structuur van Tabellen bekijken

SELECT *
FROM zonnepanelen
ORDER BY Periode;

SELECT *
FROM NIS_Codes;

SELECT *
FROM periodes;

SELECT *
FROM Vermogensklassen;

-- ---------------------------------------------------------------

-- Vermogen in tabel Zonnepanelen moet in 'MW' zijn en  niet 'MWh'
	-- MW = duidt op max vermogen van 1 zonnepaneel of hele installatie
    -- MWh = duidt op energie != vermogen
		            
ALTER TABLE zonnepanelen
RENAME COLUMN Vermogen TO Vermogen_MW; -- Correcte benaming gaven

-- --------------------------------------------------------------------












