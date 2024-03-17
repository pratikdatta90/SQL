use project;
-- Task 2: Segmentation Analysis Based on Drug MarketingStatus
-- Group products based on MarketingStatus. Provide meaningful insights into the segmentation patterns.

select ProductMktStatus as MarketingStatus, count(distinct(ProductNo)) as no_of_products 
from product 
group by MarketingStatus;

-- Calculate the total number of applications for each MarketingStatus year-wise after the year 2010. 

select year(ad.DocDate) as Year, p.ProductMktStatus as MarketingStatus, count(distinct(p.ApplNo)) as applications
from product as p join appdoc as ad 
on (p.ApplNo = ad.ApplNo)
where year(ad.DocDate) > 2010
group by Year, MarketingStatus
order by Year, MarketingStatus;

-- Identify the top MarketingStatus with the maximum number of applications and analyze its trend over time.

select Year, MarketingStatus, applications 
from
(select year(ad.DocDate) as Year, p.ProductMktStatus as MarketingStatus, count(distinct(p.ApplNo)) as applications,
row_number() over(partition by year(ad.DocDate) order by count(p.ApplNo) desc) as top_MarketingStatus
from product as p join appdoc as ad 
on (p.ApplNo = ad.ApplNo)
group by Year, MarketingStatus
order by Year, MarketingStatus) as iq
where top_MarketingStatus = 1;

