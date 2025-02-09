
-- -------------------------- Maak een analyse van ter beschikking gestelde data ---------------------------------------
-- ------------------------------------------------------------------

-- Wat zijn mogelijke primary keys in het model?
	-- alle gekozen PK's kunnen de waarden uniek identifieren 
    
	-- ObservatieID (zonnepanelen)
    -- NIS_Code (NIS_Codes)
    -- PeriodeID (periodes)
    -- Vermogensklasse (Vermogensklassen)

-- Hoeveel vermogensklassen en NIS Codes zijn er?
SELECT COUNT(DISTINCT Vermogensklasse) AS aantal_vermogensklassen
FROM Vermogensklassen;

SELECT COUNT(DISTINCT NIS_Code) AS aantal_NIS_Codes
FROM NIS_Codes;

-- ------------------------------------------------------------------

-- 1. In welke periodes hebben we gegevens? 
-- 2. Wat is de vroegste en laatste observatie?

-- 1.
SELECT Jaar, Maand 
FROM periodes
ORDER BY 1,2;

-- 2. Eerst nakijken welke periodes er in de zonnepanelen tabel voorkomen
SELECT *
FROM zonnepanelen
ORDER BY Periode;

-- 2. Vroeste observatie (haal de vroeste periode en de overeenkomende jaar + maand )
	-- Analyse (als we de tabellen joinen kunnen we nakijken of de gekozen PeriodeID effectief de eerste periode bevat)
SELECT ObservatieID, PeriodeID, Jaar, Maand
FROM zonnepanelen z
INNER JOIN periodes p
ON z.Periode = p.PeriodeID
ORDER BY 3,4;   
    

-- 2. Laatste observatie (haal eerst de laatste periode => dan overeenkomende jaar + maand )
	-- Analyse (als we de tabellen joinen kunnen we nakijken of de gekozen PeriodeID effectief de laatste periode bevat)
SELECT ObservatieID, PeriodeID, Jaar, Maand
FROM zonnepanelen z
INNER JOIN periodes p
ON z.Periode = p.PeriodeID
ORDER BY 3 DESC, 4 DESC;   
-- ------------------------------------------------------------------------------


-- -------------------------- Beantwoord volgende onderzoeksvragen ---------------------------------------

-- In welke periode zijn er globaal gesproken de meeste zonnepanelen geïnstalleerd?
	-- we linken periodes met zonnepanelen om de periode (jaar, maand) te linken aan aantal
SELECT Jaar, Maand, Aantal
FROM zonnepanelen z
INNER JOIN periodes p
ON z.Periode = p.PeriodeID
ORDER BY Aantal DESC
LIMIT 1; 
-- --------------------------------------------------------------------------------

-- Wat zijn de top vijf gemeenten met de meeste geïnstalleerde zonnepanelen?
	-- we linken nis-codes met zonnepanelen om aantal installates te kunnen linken aan de overeenkomende gemeente
SELECT z.NIS_Code, Gemeente, Aantal
FROM zonnepanelen z
INNER JOIN NIS_Codes n
ON z.NIS_Code = n.NIS_Code
ORDER BY Aantal DESC
LIMIT 5; 
-- ------------------------------------------------------------------------------------

-- Welke vermogensklasse is het meeste geïnstalleerd? Hoe wordt deze geclassificeerd?
	-- 1. we vermogensklassen aan zonnepanelen om over de totale informatie te beschikken
    -- 2. we groeperen de klassen en nemen de totale som van alle installaties onder deze classe
    -- 3. we kijken welke classificatie hoort bij de meest geinstalleerde klasse
SELECT v.Vermogensklasse,
	   Classificatie,
	   SUM(Aantal) AS installaties_per_klasse
FROM zonnepanelen z
INNER JOIN Vermogensklassen v
ON z.Vermogensklasse = v.Vermogensklasse
GROUP BY Vermogensklasse
ORDER BY 3 DESC
LIMIT 1; 
-- -------------------------------------------------------------------------------

-- Hoeveel zonnepanelen met een extreem hoog vermogen zijn er geïnstalleerd in de provincie Limburg in het jaar 2021?
	-- 1. om alle nodige informatie te kunnen uithalen linken we vermogensklassen, periodes en nis-codes aan zonnepanelen
    -- 2. we hebben de totale som van installaties nodig (binnen de juiste filters/groepen) => we groeperen op Jaar, Provincie, Classificatie
    -- 3. filters plaatsen => in dit geval kon ik classificatie ook in de WHERE clause plaatsen (geen verschil in dit geval) maar persoonlijk vind ik dit logischer :) 
SELECT Jaar, Provincie, Classificatie, SUM(Aantal) AS aantal_installaties
FROM zonnepanelen z
LEFT JOIN NIS_Codes n
ON z.NIS_Code = n.NIS_Code
LEFT JOIN periodes p
ON z.Periode = p.PeriodeID
LEFT JOIN Vermogensklassen v
ON z.Vermogensklasse = v.Vermogensklasse
WHERE Jaar = 2021
AND Provincie = 'Limburg'
GROUP BY 1, 2, 3
HAVING Classificatie = 'Extreem hoog';
-- ------------------------------------------------------------------------------------------

-- Kunnen we spreken van een ‘seizoenseffect’ bij het installeren van zonnepanelen? 
	-- We willen zien hoeveel installaties er totaal gebeurd zijn per maand (globaal => niet jaars gebonden)
		-- Hier kunnen we zien dat in de seizoen winter (maanden 10, 11, 12) de meeste installaties gebeuren
		-- KLeine onderzoek waarom: 
			-- Zonnepanelen werken juist beter met koelere temperaturen. 
			-- Dat komt doordat de zonnepanelen de energie efficiënter geleiden bij koude temperaturen dan bij warme temperaturen.
        
SELECT Maand, SUM(Aantal) AS aantal_installaties_per_maand
FROM zonnepanelen z
LEFT JOIN periodes p
ON z.Periode = p.PeriodeID
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3; 

-- Zijn er specifieke maanden gedurende het jaar waarin er meer zonnepanelen zijn geïnstalleerd dan in andere maanden?
	-- we halen de LIMIT weg om de opstelling van alle maanden te zien
SELECT Maand, SUM(Aantal) AS aantal_installaties_per_maand
FROM zonnepanelen z
LEFT JOIN periodes p
ON z.Periode = p.PeriodeID
GROUP BY 1
ORDER BY 2 DESC;  -- we kunnen zo afleiden dat 1.(maand 6 uitspringt t.o.v. maanden 7 en 8) / 2.(maand 3 uitspringt t.o.v. maanden 4, 5, 7 en 8)  
-- --------------------------------------------------------------------------------------------------

-- Wat is het gemiddeld geïnstalleerd vermogen per vermogensklasse? 
	-- we zoeken naar de (totaal geinstalleerde vermogen in kW) / (totaal aantal installaties) per Vermogensklasse
SELECT v.Vermogensklasse,
	   SUM(z.Vermogen_MW * 1000) / SUM(z.Aantal) AS avg_geinstalleerde_kw_per_klasse 
FROM zonnepanelen z
INNER JOIN Vermogensklassen v
ON z.Vermogensklasse = v.Vermogensklasse
GROUP BY v.Vermogensklasse;


-- Voor welke vermogensklassen is dit eerder aan de hoge kant 
-- en voor welke is dit eerder aan de lage kant?
	-- !ERROR!: deze vraag kan niet beantwoord worden zonder data over hoeveelheid specifieke panelen geinstalleerd per installatie
		-- Granulariteit van Vermogen in zonnepanelen = 1 installatie
        -- Granulariteit van Vermogen in Vermogensklassen = 1 paneel
			-- !ALTERNATIEF SCENARIO!: ik probeerde met de gegevens ter beschikking een gemiddeld aantal geinstalleerde panelen te berekenen (per periode) FOR FUN :)
				-- !CONCLUSIE!: ik kom er niet ver mee omdat ik dezelfde methode omgekeerd toepas om op deze vraag te beantwoorden waardoor ik terug op de gemiddelde vermogensklasse waardes kom

-- TESTEN ALTERNATIEF SCENARIO (zie uitleg boven)
	-- We weten de totale vermogen per installatie	
		-- Interessant om te zien gemiddeld hoeveel panelen totaal geinstaleerd zijn per periode
			-- 1. bereken gemiddelde vermogen per Vermogensklasse
			-- 2. bereken aan de hand van punt1: gemiddeld hoeveel panelen totaal geinstaleerd zijn per periode

-- 1. avg_kW_per_klasse
	-- A: 5 kW
	-- B: 25 kW
	-- C: 145 kW
	-- D: 500 kW
	-- E: 1000 kW = 1MW (gemiddeld huis)
    
ALTER TABLE zonnepanelen
ADD COLUMN avg_kW_per_klasse INT NOT NULL;

UPDATE zonnepanelen
SET avg_kW_per_klasse = CASE
							WHEN Vermogensklasse = 'A' THEN  5
                            WHEN Vermogensklasse = 'B' THEN 25
                            WHEN Vermogensklasse = 'C' THEN 145
                            WHEN Vermogensklasse = 'D' THEN 500
                            ELSE 1000
						END;

-- 2. avg_aantal_panelen   
ALTER TABLE zonnepanelen
ADD COLUMN avg_aantal_panelen INT NOT NULL;

UPDATE zonnepanelen
SET avg_aantal_panelen = (Vermogen_MW * 1000)/avg_kW_per_klasse;


-- CONCLUSIE  (zie uitleg boven)              
SELECT v.Vermogensklasse,
	   v.Vermogen, -- v.Vermogen erbij om te bekijken laag/hoog
	   SUM(z.Vermogen_MW * 1000) / SUM(z.avg_aantal_panelen) AS avg_geinstalleerde_kw_per_klasse 
FROM zonnepanelen z
INNER JOIN Vermogensklassen v
ON z.Vermogensklasse = v.Vermogensklasse
GROUP BY v.Vermogensklasse;              
-- -----------------------------------------------------------------------------------------------------

-- Welke gemeenten hebben de meeste zonnepanelen geïnstalleerd per inwoner?
	-- 1. Bekijken hoe de installaties zich verhouden (geografisch)
		-- We zien dat installaties enkel in 300 van de 607 totale gemeentes geinstalleerd zijn
			-- in deze dataset zijn er gemeentes zonder enige installatie in de beschikbare periodes
SELECT COUNT(DISTINCT z.NIS_Code) AS nis_codes_geinstalleerd,
	   COUNT(DISTINCT n.NIS_Code) AS totaal_aantal_nis_codes
FROM zonnepanelen z
RIGHT JOIN NIS_Codes n
ON z.NIS_Code = n.NIS_Code;	

	-- 2. We gaan wat verder in de analyse om uit te zoeken welke provincie hoogst aantal gemeentes zonder installaties bevat FOR FUN :)
SELECT n.Provincie, 
	   COUNT(DISTINCT n.Gemeente) AS aantal_gemeentes_zonder_installaties
FROM zonnepanelen z
RIGHT JOIN NIS_Codes n 	 -- RIGHT JOIN verzekerd ons dat we alle officiele nis-codes meepakken 
ON z.NIS_Code = n.NIS_Code
WHERE z.NIS_Code IS NULL 	-- gemeentes die in de zonnepanelen tabel niet voorkomen
GROUP BY 1
ORDER BY 2 DESC; 

	-- 3. Onze hoofdanalyse uitvoeren
		-- we willen de verhouding zien van (totaal aantal installaties)/(totaal aantal inwoners) per gemeente
        -- TOP 10 Gemeentes selecteren
SELECT Gemeente,
	   SUM(Aantal) / SUM(Inwoners) AS installaties_per_inwoner
FROM zonnepanelen z
RIGHT JOIN NIS_Codes n
ON z.NIS_Code = n.NIS_Code
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;	
-- ---------------------------------------------------------------------------------------------------------------------------------------------
