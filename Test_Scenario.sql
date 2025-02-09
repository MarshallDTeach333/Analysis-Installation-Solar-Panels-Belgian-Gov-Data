
-- ----------- SCENARIO: wat als vermogen in tabel zonnepanelen kW is IPV MWh

-- Vermogen in tabel Zonnepanelen moet in 'kW' zijn en  niet 'MWh'
	-- kW = duidt op max vermogen van 1 zonnepaneel
    -- MWh = duidt op energie != vermogen
		-- Probleem: zelfs al zien we vermogen als kW kloppen de aangegeven Vermogensklasse nog steeds niet
			-- Formule: (Vermogen_kW/Aantal) = Vermogensklasse
            -- Oplossing: Correcte Vermogensklasse labelen
            
ALTER TABLE zonnepanelen
RENAME COLUMN Vermogen TO Vermogen_kW; -- Correcte benaming gaven

-- 1. Toevoegen kolom 'avg_vermogen_per_paneel'
-- 2. Gemiddeld Vermogen per Paneel berekenen
ALTER TABLE zonnepanelen
ADD COLUMN avg_vermogen_per_paneel INT NOT NULL;

UPDATE zonnepanelen
SET avg_vermogen_per_paneel = (Vermogen_kW/Aantal);


-- 1. Toevoegen kolom 'Vermogensklasse_correct'
-- 2. Update waardes met de correct overeenkomende Vermogensklasse
ALTER TABLE zonnepanelen
ADD COLUMN Vermogensklasse_correct VARCHAR(1);

UPDATE zonnepanelen
SET Vermogensklasse_correct = CASE
								  WHEN avg_vermogen_per_paneel < 10 THEN 'A'
                                  WHEN avg_vermogen_per_paneel > 10 AND avg_vermogen_per_paneel <= 40 THEN 'B'
                                  WHEN avg_vermogen_per_paneel > 40 AND avg_vermogen_per_paneel <= 250 THEN 'C'
                                  WHEN avg_vermogen_per_paneel > 250 AND avg_vermogen_per_paneel <= 750 THEN 'D'
                                  ELSE 'E'
							  END;

-- Kijken naar het verschill van het aantal Vermogensklassen na verandering
	-- CONCLUSIE: zo kunnen we zien hoeveel de totaal aantal installaties per klasse verandert 
SELECT t1.*,
	   t2.*
FROM (
	SELECT Vermogensklasse, COUNT(*) AS installaties_per_klasse_fout
    FROM zonnepanelen
    GROUP BY (1)
    ORDER BY Vermogensklasse
) AS t1
JOIN (
	SELECT Vermogensklasse_correct, COUNT(*) AS installaties_per_klasse_correct
    FROM zonnepanelen
    GROUP BY (1)
    ORDER BY Vermogensklasse_correct
) AS t2
ON t1.Vermogensklasse = t2.Vermogensklasse_correct;