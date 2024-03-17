use project;

-- Task 1: Identifying Approval Trends
-- Determine the number of drugs approved each year and provide insights into the yearly trends.

SELECT YEAR(ActionDate) AS Year,
COUNT(CASE WHEN ActionType = 'AP' THEN 1 END) AS Approvals,
COUNT(CASE WHEN ActionType = 'TA' THEN 1 END) AS TentativeApprovals
FROM regactiondate
WHERE ActionDate IS NOT NULL
GROUP BY Year
ORDER BY Year;
    
-- Identify the top three years that got the highest and lowest approvals, in descending and ascending order, respectively.

(SELECT YEAR(ActionDate) AS Year, COUNT(ActionType) AS Approvals
FROM regactiondate
WHERE ActionType = 'AP' AND ActionDate IS NOT NULL
GROUP BY Year
ORDER BY Approvals DESC
LIMIT 3)
UNION ALL
(SELECT YEAR(ActionDate) AS Year, COUNT(ActionType) AS Approvals
FROM regactiondate
WHERE ActionType = 'AP' AND ActionDate IS NOT NULL
GROUP BY Year
ORDER BY Approvals ASC
LIMIT 3);
    
-- Explore approval trends over the years based on sponsors.

SELECT YEAR(ra.ActionDate) AS Year, a.SponsorApplicant AS Sponsor, COUNT(ra.ActionType) AS Approvals
FROM regactiondate ra JOIN application a 
ON ra.ApplNo = a.ApplNo
WHERE ra.ActionType = 'AP' AND ra.ActionDate IS NOT NULL
GROUP BY Year, Sponsor
ORDER BY Year, Approvals DESC;
    
-- Rank sponsors based on the total number of approvals they received each year between 1939 and 1960

SELECT *, DENSE_RANK() OVER (PARTITION BY Year ORDER BY Approvals DESC) AS SponsorRank
FROM 
(SELECT YEAR(ra.ActionDate) AS Year, a.SponsorApplicant AS Sponsor, COUNT(ra.ActionType) AS Approvals
FROM regactiondate ra JOIN application a 
ON ra.ApplNo = a.ApplNo
WHERE ra.ActionType = 'AP' AND ra.ActionDate IS NOT NULL AND YEAR(ra.ActionDate) BETWEEN 1939 AND 1960
GROUP BY Year, Sponsor
) AS ApprovalCounts;

-- Task 2: Segmentation Analysis Based on Drug MarketingStatus
-- Group products based on MarketingStatus. Provide meaningful insights into the segmentation patterns.

select ProductMktStatus as MarketingStatus, count(ProductNo) as no_of_products 
from product 
group by MarketingStatus;

-- Calculate the total number of applications for each MarketingStatus year-wise after the year 2010. 

select year(ad.DocDate) as Year, p.ProductMktStatus as MarketingStatus, count(p.ApplNo) as applications
from product as p join appdoc as ad 
on (p.ApplNo = ad.ApplNo)
where year(ad.DocDate) > 2010
group by Year, MarketingStatus
order by Year, MarketingStatus;

-- Identify the top MarketingStatus with the maximum number of applications and analyze its trend over time.

select Year, MarketingStatus, applications 
from
(select year(ad.DocDate) as Year, p.ProductMktStatus as MarketingStatus, count(p.ApplNo) as applications,
row_number() over(partition by year(ad.DocDate) order by count(p.ApplNo) desc) as top_MarketingStatus
from product as p join appdoc as ad 
on (p.ApplNo = ad.ApplNo)
group by Year, MarketingStatus
order by Year, MarketingStatus) as iq
where top_MarketingStatus = 1;

-- Task 3: Analyzing Products
-- Categorize Products by dosage form and analyze their distribution.

select Form as DosageForm, count(distinct(ProductNo)) as no_of_products 
from product 
group by DosageForm 
order by no_of_products desc;

-- Calculate the total number of approvals for each dosage form and identify the most successful forms.

select p.Form as dosageform, count(r.ActionType) as approvals 
from product as p join regactiondate as r
on (p.ApplNo = r.ApplNo)
where r.ActionType = 'AP'
group by dosageform
order by approvals desc;

-- Investigate yearly trends related to successful forms.

select Year, dosageform, approvals 
from
(select year(r.ActionDate) as Year, p.Form as dosageform, count(r.ActionType) as approvals,
row_number() over(partition by year(r.ActionDate) order by count(r.ActionType) desc) as top_forms
from product as p join regactiondate as r
on (p.ApplNo = r.ApplNo)
where r.ActionType = 'AP' and r.ActionDate is not null
group by Year, dosageform
order by Year, approvals desc) as iq
where top_forms = 1;

-- Task 4: Exploring Therapeutic Classes and Approval Trends
-- Analyze drug approvals based on therapeutic evaluation code (TE_Code).

select pt.TECode as TE_Code, count(r.ActionType) as approvals 
from product_tecode as pt join regactiondate as r
on (pt.ApplNo = r.ApplNo)
where r.ActionType = 'AP'
group by TE_Code
order by approvals desc;

-- Determine the therapeutic evaluation code (TE_Code) with the highest number of Approvals in each year.

select Year, TE_Code, approvals
from
(select year(r.ActionDate) as Year, pt.TECode as TE_Code, count(r.ActionType) as approvals, 
row_number() over(partition by year(r.ActionDate) order by count(r.ActionType) desc) as top_TE_Code
from product_tecode as pt join regactiondate as r
on (pt.ApplNo = r.ApplNo)
where r.ActionType = 'AP' and r.ActionDate is not null
group by Year, TE_Code
order by Year, approvals desc) as iq
where top_TE_Code = 1;

-- ---------------------------------------------------------------------------------------------------------

