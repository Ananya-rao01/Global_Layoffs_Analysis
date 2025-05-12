-- Exploratory Data Analysis
SELECT *
FROM  layoffs_staging2;

SELECT date
FROM layoffs_staging2
ORDER BY date ASC;

-- Total Layoffs Over Time (Trend Analysis)
    -- By Month:Spotting seasonal trends & monthly spikes
SELECT 
  DATE_FORMAT(date, '%Y-%m') AS layoff_month,
  SUM(total_laid_off) AS total
FROM layoffs_staging2
WHERE date IS NOT NULL
GROUP BY layoff_month
ORDER BY layoff_month;

  -- By Year:Understanding broad long-term patterns
SELECT 
  YEAR(date) AS layoff_year,
  SUM(total_laid_off) AS total
FROM layoffs_staging2
WHERE date IS NOT NULL
GROUP BY layoff_year
ORDER BY layoff_year;

-- Companies with Highest Layoffs
SELECT company, 
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;

-- Layoffs by Industry
SELECT industry, 
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;

-- Layoffs by Country
SELECT country, 
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC;

-- Average Percentage of Workforce Laid Off per Company
SELECT company, 
       ROUND(AVG(percentage_laid_off) * 100, 2) AS avg_layoff_percentage
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL
GROUP BY company
ORDER BY avg_layoff_percentage DESC;

-- Date of First and Most Recent Layoff per Company
SELECT company, 
       MIN(date) AS first_layoff, 
       MAX(date) AS last_layoff
FROM layoffs_staging2
GROUP BY company
ORDER BY company;

-- Companies with Multiple Layoffs
SELECT company, 
       COUNT(*) AS layoff_events
FROM layoffs_staging2
GROUP BY company
HAVING COUNT(*) > 1
ORDER BY layoff_events DESC;

-- Layoffs Before/After Funding Rounds
SELECT company, stage, date, total_laid_off
FROM layoffs_staging2
WHERE stage IN ('Series A', 'Series B', 'Series C', 'Series D', 'Post-IPO')
  AND total_laid_off IS NOT NULL
ORDER BY company,date;

-- Mass Layoffs (100%) and Company Closure Pattern
SELECT company, location, date
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

-- Layoff Intensity Score
SELECT company,
       SUM(total_laid_off * percentage_laid_off) AS layoff_intensity
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL
GROUP BY company
ORDER BY layoff_intensity DESC;

--  Layoffs Timing by Quarter or Season
SELECT EXTRACT(QUARTER FROM date) AS quarter,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE date IS NOT NULL
GROUP BY quarter
ORDER BY quarter;

-- Country vs Industry Layoff Analysis
  -- What are the top 10 most affected country-industry combos globally?
SELECT 
    country,
    industry,
    COUNT(*) AS num_layoff_events,
    SUM(total_laid_off) AS total_layoffs,
    AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL 
  AND percentage_laid_off IS NOT NULL
GROUP BY country, industry
HAVING SUM(total_laid_off) > 0
ORDER BY total_layoffs DESC, country, industry
LIMIT 10;

  -- Which industries are most affected in particular countries 
SELECT 
    country,
    industry,
    COUNT(*) AS num_layoff_events,
    SUM(total_laid_off) AS total_layoffs,
    AVG(percentage_laid_off) AS avg_percentage_laid_off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL 
  AND percentage_laid_off IS NOT NULL
GROUP BY country, industry
HAVING SUM(total_laid_off) > 0
ORDER BY country ASC, total_layoffs DESC,industry;
