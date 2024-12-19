select *
from world_layoffs.layoffs;

-- DATACLEANING --
-- 1. Remove duplicates
-- 2. Standardize the dataset
-- 3. Null values or blank values
-- 4. Remove unnecessary columnss

create table world_layoffs.Layoff_demo
like world_layoffs.layoffs; -- to have a demo table and make changes innit to avoid mistake in real dataset--

insert world_layoffs.layoff_demo
select *
from world_layoffs.layoffs;

select *
from world_layoffs.layoff_demo;


-- REMOVING DUPLICATES --

-- finding duplicates --
with duplicate_cte as
(
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage,
country, funds_raised_millions) as row_num
from world_layoffs.layoff_demo
)
select *
from duplicate_cte
where row_num > 1;

-- deleting the dupllicates--
-- I can't delete from cte in my tables-- 
-- So what I can i do is make a new table insert the layoff_demo and row_num innit and delete it form there

-- hover to layoff_demo in schemas select copy to clipboard and creat statement and paste it here -- 
CREATE TABLE world_layoffs.layoff_demo2 (
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

insert into world_layoffs.layoff_demo2
select *,
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage,
country, funds_raised_millions) as row_num
from world_layoffs.layoff_demo;

delete
from world_layoffs.layoff_demo2
where row_num > 1;

select *
from world_layoffs.layoff_demo2;


-- STANDARSIZING --
update world_layoffs.layoff_demo2
set company = trim(company);

select distinct(industry)
from world_layoffs.layoff_demo2
order by 1;


update world_layoffs.layoff_demo2
set industry = 'Crypto'
where industry like 'Crypto%';
-- simillarly we will check thorugh all columns and update wherever there will be mistakes acc. to us -- 

update world_layoffs.layoff_demo2
set country = 'Unites States'
where country like 'Unites States%';


-- changing the data type of date column to date --
select `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
from world_layoffs.layoff_demo2;

update world_layoffs.layoff_demo2
set `date`= STR_TO_DATE(`date`, '%m/%d/%Y');

alter table world_layoffs.layoff_demo2
modify column `date` date;


-- Null values and blank values --


select *
from world_layoffs.layoff_demo2
where industry is null
or industry = ''
;

-- we can assign indsutries by checking out the same company--
select *
from world_layoffs.layoff_demo2
where company = 'Airbnb';

select *
from world_layoffs.layoff_demo2 as t1
join world_layoffs.layoff_demo2 as t2
	on t1.company = t2.company
    and t1.location = t2.location
where (t1.industry is null OR t1.industry = '')
and (t2.industry is not null AND t2.industry != '') ;

update world_layoffs.layoff_demo2 as t1
join world_layoffs.layoff_demo2 as t2
	on t1.company = t2.company
    and t1.location = t2.location
set t1.industry = t2.industry
where (t1.industry is null Or t1.industry = '')
and (t2.industry is not null AND t2.industry != '');

select distinct(industry),company
from world_layoffs.layoff_demo2
order by 1;


select *
from world_layoffs.layoff_demo2
where total_laid_off is null
and percentage_laid_off is null; 
-- there ain't any information of layoffs in given set and we can't calculate it by some mean i.e it's trash--

delete
from world_layoffs.layoff_demo2
where total_laid_off is null
and percentage_laid_off is null; 

alter table world_layoffs.layoff_demo2
drop column row_num;



