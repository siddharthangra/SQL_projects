-- Expolatory data analysis --
-- basically we can analyse, in this particular dataset
-- can get to know, which industry is being affected the most
-- or which country is laying off and data like those --

select*
from world_layoffs.layoff_demo2;

select company, sum(total_laid_off)
from world_layoffs.layoff_demo2
group by company
order by 2 DESC;

select industry, sum(total_laid_off)
from world_layoffs.layoff_demo2
group by industry
order by 2 DESC;

select country, sum(total_laid_off)
from world_layoffs.layoff_demo2
group by country
order by 2 DESC;

select min(`Date`), max(`Date`)
from world_layoffs.layoff_demo2;

select year(`date`), sum(total_laid_off)
from world_layoffs.layoff_demo2
group by year(`date`)
order by 2 DESC;

-- Rolling total layoff
select substring(`date`,1,7) as `month`, sum(total_laid_off)
from world_layoffs.layoff_demo2
where substring(`date`,1,7) is not null
group by `month`
order by 1 ASC;

with ROLLING_TOTAL as
(
select substring(`date`,1,7) as `month`, sum(total_laid_off) as total_off
from world_layoffs.layoff_demo2
where substring(`date`,1,7) is not null
group by `month`
order by 1 ASC
)
select `month`, total_off,
sum(total_off) over(order by `month`) as rolling_total
from ROLLING_TOTAL;

-- ranking companies with lay_offs --
select company, year(`Date`), sum(total_laid_off)
from world_layoffs.layoff_demo2
group by company, year(`Date`)
order by 3 DESC;

with company_rank as 
(
select company, year(`Date`) as year_laid, sum(total_laid_off) as total_off
from world_layoffs.layoff_demo2
group by company, year(`Date`)
order by 3 DESC
)
select *, dense_rank()over(partition by year_laid order by total_off DESC) as rank_num
from company_rank
where year_laid is not null;

-- filtering out top n companies --

with company_rank as 
(
select company, year(`Date`) as year_laid, sum(total_laid_off) as total_off
from world_layoffs.layoff_demo2
group by company, year(`Date`)
order by 3 DESC
), company_year_rank as
(
select *, dense_rank()over(partition by year_laid order by total_off DESC) as rank_num
from company_rank
where year_laid is not null
)
select *
from company_year_rank
where rank_num <=5;