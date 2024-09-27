SELECT *
FROM prescriber;

SELECT * 
FROM drug;

SELECT * 
FROM prescription;

--1.
  --  a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims. NPI: 1912011792 TCC 4538

SELECT prescriber.npi, prescription.total_claim_count
	FROM prescriber
INNER JOIN prescription ON prescriber.npi = prescription.npi
ORDER BY total_claim_count DESC
LIMIT 1;

--   b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

SELECT nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, prescription.total_claim_count
	FROM prescriber
INNER JOIN prescription ON prescriber.npi = prescription.npi
ORDER BY total_claim_count DESC
LIMIT 1;

-- 2.
  --  a. Which specialty had the most total number of claims (totaled over all drugs)? Family Practice 4538

SELECT specialty_description, total_claim_count
	FROM prescriber
INNER JOIN prescription ON prescriber.npi = prescription.npi
INNER JOIN drug ON prescription.drug_name = drug.drug_name
ORDER BY total_claim_count DESC
LIMIT 1;

  -- b. Which specialty had the most total number of claims for opioids? Nurse Practitioner

SELECT specialty_description, total_claim_count
	FROM prescriber
INNER JOIN prescription ON prescriber.npi = prescription.npi
INNER JOIN drug ON prescription.drug_name = drug.drug_name
WHERE opioid_drug_flag = 'Y' AND long_acting_opioid_drug_flag = 'Y'
ORDER BY total_claim_count DESC
LIMIT 1;



  --  c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
SELECT *
Prescr


  --  d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3.
   -- a. Which drug (generic_name) had the highest total drug cost? PIREFENIDONE 
   
SELECT drug.generic_name, prescription.total_drug_cost
FROM drug
INNER JOIN prescription ON prescription.drug_name = drug.drug_name
ORDER BY total_drug_cost DESC
LIMIT 1;


    --b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT ROUND(SUM(prescription.total_drug_cost/365),2) AS rounded_total, drug.generic_name
FROM drug
INNER JOIN prescription ON prescription.drug_name = drug.drug_name
GROUP BY generic_name
ORDER BY rounded_total DESC;

-- Cost per 30 day subscription
SELECT ROUND(SUM(prescription.total_drug_cost/30),2) AS rounded_total, drug.generic_name
FROM drug
INNER JOIN prescription ON prescription.drug_name = drug.drug_name
GROUP BY generic_name
ORDER BY rounded_total DESC;


-- 4.
    -- a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/

SELECT drug_name,
(CASE 
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN long_acting_opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'	
	END) AS drug_type
FROM drug;

   -- b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT drug.drug_name, prescription.total_drug_cost::money,
(CASE 
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN long_acting_opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'	
	END) AS drug_type
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name;



(SELECT SUM(total_drug_cost)::money AS opioid_cost
FROM prescription AS p
INNER JOIN drug AS d
	ON p.drug_name = d.drug_name
	WHERE d.opioid_drug_flag = 'Y' AND d.long_acting_opioid_drug_flag = 'Y')

(SELECT SUM(total_drug_cost)::money AS antibiotic_drug_cost
FROM prescription AS p
INNER JOIN drug AS d
	ON p.drug_name = d.drug_name
	WHERE d.antibiotic_drug_flag = 'Y')

   

-- 5.
   -- a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT *
FROM cbsa
WHERE cbsaname LIKE '%TN%'


   -- b. Which cbsa has the largest combined population? Nashville-Davidson Which has the smallest? Morristown Report the CBSA name and total population.  

SELECT c.cbsaname, SUM(population) AS largest_pop
FROM cbsa AS c
INNER JOIN population AS p
ON c.fipscounty = p.fipscounty
GROUP BY c.cbsaname
ORDER BY largest_pop DESC
LIMIT 1;

SELECT c.cbsaname, SUM(population) AS lowest_pop
FROM cbsa AS c
INNER JOIN population AS p
ON c.fipscounty = p.fipscounty
GROUP BY c.cbsaname
ORDER BY lowest_pop ASC
LIMIT 1;




   -- c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population. SEVIER 95523
SELECT *
FROM cbsa;

SELECT county,population
FROM fips_county
FULL JOIN cbsa ON cbsa.fipscounty = fips_county.fipscounty
FULL JOIN population ON fips_county.fipscounty = population.fipscounty
WHERE cbsa IS NULL AND population IS NOT NULL
ORDER BY population DESC;



-- 6.
   -- a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT *
FROM prescription;


SELECT drug_name, SUM(total_claim_count) AS total_claim 
FROM prescription
WHERE total_claim_count >= 3000
GROUP BY drug_name
ORDER BY total_claim;



  --  b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT p.drug_name, SUM(total_claim_count) AS total_claim, d.opioid_drug_flag
FROM prescription AS p
INNER JOIN drug AS d
	ON d.drug_name = p.drug_name
WHERE total_claim_count >= 3000
GROUP BY p.drug_name,d.opioid_drug_flag
ORDER BY total_claim


   -- c. Add another column to your answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT pr.nppes_provider_first_name, pr.nppes_provider_last_org_name, p.drug_name, SUM(total_claim_count) AS total_claim, d.opioid_drug_flag
FROM prescription AS p
INNER JOIN drug AS d
	ON d.drug_name = p.drug_name
INNER JOIN prescriber AS pr 
	ON p.npi = pr.npi
WHERE total_claim_count >= 3000
GROUP BY pr.nppes_provider_first_name, pr.nppes_provider_last_org_name, p.drug_name, d.opioid_drug_flag
ORDER BY total_claim


-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

   -- a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT *
FROM prescriber AS p
FULL JOIN prescription AS pr ON p.npi = pr.npi
FULL JOIN drug AS d ON d.drug_name = pr.drug_name
WHERE p.specialty_description = 'Pain Management' AND d.opioid_drug_flag ='Y' AND p.nppes_provider_city = 'NASHVILLE'




   -- b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count)









SELECT p.npi, d.drug_name, pr.total_claim_count, COALESCE(pr.total_claim_count,0) AS total_claims
FROM prescriber AS p
FULL JOIN prescription AS pr ON p.npi = pr.npi
FULL JOIN drug AS d ON pr.drug_name = d.drug_name
WHERE pr.total_claim_count IS NULL OR p.nppes_provider_city = 'NASHVILLE' AND d.opioid_drug_flag = 'Y' AND p.nppes_provider_city = 'NASHVILLE' 
GROUP BY p.npi, pr.total_claim_count, d.drug_name



   -- c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.




SELECT p.npi, d.drug_name, pr.total_claim_count
FROM prescriber AS p
FULL JOIN prescription AS pr ON p.npi = pr.npi
FULL JOIN drug AS d ON d.drug_name = pr.drug_name
WHERE p.specialty_description = 'Pain Management' AND d.opioid_drug_flag ='Y' AND p.nppes_provider_city = 'NASHVILLE'
GROUP BY p.npi, d.drug_name, pr.total_claim_count



   -- c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.


SELECT p.npi, d.drug_name, pr.total_claim_count AS total_claims
FROM prescription AS pr
FULL JOIN prescriber AS p on p.npi = pr.npi
FULL JOIN drug AS d on d.drug_name = pr.drug_name
WHERE pr.total_claim_count IS NULL OR p.nppes_provider_city = 'NASHVILLE' AND p.specialty_description = 'Pain Management' AND d.opioid_drug_flag ='Y'
GROUP BY p.npi, d.drug_name, total_claims


   

   -- c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

