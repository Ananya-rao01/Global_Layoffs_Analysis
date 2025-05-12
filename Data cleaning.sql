USE project1;
SELECT *
FROM layoffs;

----- Data cleaning
-- Removing Duplicates

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM  layoffs;

SELECT *
FROM  layoffs_staging;


SELECT *, COUNT(*) 
FROM layoffs_staging
GROUP BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
HAVING COUNT(*) > 1;   -- Checking Duplicates

SELECT *
FROM  layoffs_staging
WHERE company ='Cazoo';

-- Using cte for creatiing a row number 
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,
industry, total_laid_off, percentage_laid_off, `date` , stage
, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
DELETE
FROM duplicate_cte
WHERE row_num > 1;

-- Creating another table having row_num as new column

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM  layoffs_staging2;

INSERT INTO  layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,
industry, total_laid_off, percentage_laid_off, `date` , stage
, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Deleting the duplicate values
DELETE 
FROM  layoffs_staging2
WHERE row_num > 1;

-- Checking if duplicates are removed

SELECT *
FROM  layoffs_staging2
WHERE row_num > 1;

-- Finally checking the whole table 

SELECT *
FROM  layoffs_staging2;

-- Standardising Data
-- For spottoing inconsistencies 

SELECT DISTINCT company FROM layoffs_staging2 ORDER BY company;
SELECT DISTINCT country FROM layoffs_staging2 ORDER BY country;
SELECT DISTINCT industry FROM layoffs_staging2 ORDER BY industry;

-- Removing white spaces

SELECT company, TRIM(company) FROM layoffs_staging2;
SELECT country, TRIM(country) FROM layoffs_staging2 ;
SELECT industry,TRIM(industry)FROM layoffs_staging2 ;

-- Updating the columns into standard format without white spaces
UPDATE layoffs_staging2
SET company = TRIM(company);
UPDATE layoffs_staging2
SET country = TRIM(country);
UPDATE layoffs_staging2
SET industry = TRIM(industry);

-- Updating columns with same name but different format into one specific format
UPDATE layoffs_staging2
SET country = 'United States'
WHERE country LIKE 'United States%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Converting text to date
SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;

-- Update the date column with date values 
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2;

AlTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;

-- checking for null values 
SELECT *
FROM layoffs_staging2
WHERE company IS NULL OR company = ''
   OR location IS NULL OR location = ''
   OR industry IS NULL OR industry = ''
   OR total_laid_off IS NULL
   OR percentage_laid_off IS NULL
   OR date IS NULL
   OR stage IS NULL OR stage = ''
   OR country IS NULL OR country = ''
   OR funds_raised_millions IS NULL;

-- checking for specific columns
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry=''
;
SELECT company,location,industry
FROM layoffs_staging2
WHERE industry IS NULL OR industry='';

SELECT company,location,industry
FROM layoffs_staging2
WHERE company= 'Airbnb';

SELECT company,location,industry
FROM layoffs_staging2
WHERE company= "Bally's Interactive";

SELECT company,location,industry
FROM layoffs_staging2
WHERE company= 'Carvana';

SELECT company,location,industry
FROM layoffs_staging2
WHERE company= 'Juul';

-- Updating the null values of industry 

UPDATE layoffs_staging2
SET industry = CASE
    WHEN company = 'Airbnb' THEN 'Travel'
    WHEN company = 'Carvana' THEN 'Transportation'
    WHEN company = 'Juul' THEN 'Consumer'
    ELSE industry
    END
WHERE (industry IS NULL OR industry = '')
AND company IN ('Airbnb', 'Carvana', 'Juul');

-- Checking for null values in both the total_laid_off and percentage_laid_off columns

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
-- Deleting the null values columns which are not required 

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Dropping the columns which are not useful

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;


SELECT *
FROM layoffs_staging2;