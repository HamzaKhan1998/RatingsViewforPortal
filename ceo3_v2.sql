with 
cte0_0 as  (
  select * 
  FROM `people-analytics-keeptruckin.0_2024_H1_360.ratings`
),

cte0 as (
  SELECT d.email_address, DATE_DIFF(DATE '2024-02-20', hire_date, DAY) as diff,
  ceo_3_email, ceo_4_email, ceo_5_email, ceo_6_email, ceo_7_email,
  management_chain_level_03 as mg1, 
  management_chain_level_04 as mg2, 
  management_chain_level_05 as mg3,
  management_chain_level_06 as mg4,
  management_chain_level_07 as mg5,
  case 
  when DATE_DIFF(DATE '2024-02-20', hire_date, DAY) < 90 then 'Too new to tell'
  when r.rating is null then "Not Rated"
  else r.rating
  end as rating,
  FROM `people-analytics-keeptruckin.workday_raw.census_dni` d
  left join cte0_0 r
  on d.email_address = r.email_address
  where 
  d.active_status = 1
  and _fivetran_deleted = false
  and d.employee_type = 'Regular'
),

cte2 as (
  SELECT ceo_5_email, mg3, count(rating) as total_count FROM cte0
  where rating <> 'Too new to tell' and rating <> 'Not Rated'
  group by ceo_5_email, mg3
),

cte2_ as (
  SELECT ceo_5_email, mg4, count(rating) as total_count FROM cte0
  where rating <> 'Too new to tell' and rating <> 'Not Rated'
  group by ceo_5_email, mg4
),

--Getting the HC by rating


cte4 as (
  SELECT ceo_5_email, mg3, rating, count(rating) as total_count_2 FROM cte0
  where rating <> 'Too new to tell'  and rating <> 'Not Rated'
  group by ceo_5_email, mg3, rating
),

cte4_ as (
  SELECT ceo_5_email, mg4, rating, count(rating) as total_count_2 FROM cte0
  where rating <> 'Too new to tell'  and rating <> 'Not Rated'
  group by ceo_5_email, mg4, rating
),

--Getting the percentage by rating

cte6 as (
  select cte2.ceo_5_email as mg_email, cte2.mg3 as mg1, rating, ROUND(((cte4.total_count_2/cte2.total_count) * 100),2) as percent
  from cte2 inner join cte4
  on cte2.mg3 = cte4.mg3
  --where cte2.mg2 not in (select mg1 from cte5)
),

cte6_ as (
  select cte2_.ceo_5_email as mg_email, cte2_.mg4 as mg1, rating, ROUND(((cte4_.total_count_2/cte2_.total_count) * 100),2) as percent
  from cte2_ inner join cte4_
  on cte2_.mg4 = cte4_.mg4
  where cte2_.mg4 not in (select mg1 from cte6)
),

cte7 as (
  select * from cte6
  union all
  select * from cte6_
  --order by mg1, rating
),


cte9 as (
  SELECT * FROM cte7
  PIVOT(SUM(percent) FOR rating 
  IN ("Sets a New Standard", "Often Exceeds Expectations", "Consistently Meets Expectations", "Needs Development"))
),



cte11 as (
  SELECT * FROM cte4
  PIVOT(SUM(total_count_2) FOR rating 
  IN ("Sets a New Standard", "Often Exceeds Expectations", "Consistently Meets Expectations", "Needs Development"))
),

cte12 as (
  SELECT * FROM cte4_
  PIVOT(SUM(total_count_2) FOR rating 
  IN ("Sets a New Standard", "Often Exceeds Expectations", "Consistently Meets Expectations", "Needs Development"))
),

cte13 as (
  select mg_email, mg1, 
  `Sets a New Standard` as Sets_a_New_Standard, 
  `Often Exceeds Expectations` as Often_Exceeds_Expectations, 
  `Consistently Meets Expectations` as Consistently_Meets_Expectations, 
  `Needs Development` as Needs_Development
  from cte9
),


cte15 as (
  select mg3 as mg1,
  `Sets a New Standard` as Sets_a_New_Standard, 
  `Often Exceeds Expectations` as Often_Exceeds_Expectations, 
  `Consistently Meets Expectations` as Consistently_Meets_Expectations, 
  `Needs Development` as Needs_Development
  from cte11
),

cte16 as (
  select mg4 as mg1,
  `Sets a New Standard` as Sets_a_New_Standard, 
  `Often Exceeds Expectations` as Often_Exceeds_Expectations, 
  `Consistently Meets Expectations` as Consistently_Meets_Expectations, 
  `Needs Development` as Needs_Development
  from cte12
  --where cte12.mg4 not in (select mg1 from cte15)
),

cte16_ as (
  select cte16.* from cte16
  left join cte15
  on cte16.mg1 = cte15.mg1
  where cte15.mg1 is null
  
),


cte18 as (
  select cte13.mg_email, cte13.mg1, 
  concat(cast(cte13.Sets_a_New_Standard as string), "% (",cast(cte15.Sets_a_New_Standard  as string), ")") as Sets_a_New_Standard,
  concat(cast(cte13.Often_Exceeds_Expectations as string), "% (",cast(cte15.Often_Exceeds_Expectations  as string), ")") as Often_Exceeds_Expectations,
  concat(cast(cte13.Consistently_Meets_Expectations as string), "% (",cast(cte15.Consistently_Meets_Expectations  as string), ")") as Consistently_Meets_Expectations,
  concat(cast(cte13.Needs_Development as string), "% (",cast(cte15.Needs_Development  as string), ")") as Needs_Development
  from cte13 inner join cte15
  on cte13.mg1 = cte15.mg1
),

cte17 as (
  select cte13.mg_email, cte13.mg1, 
  concat(cast(cte13.Sets_a_New_Standard as string), "% (",cast(cte16_.Sets_a_New_Standard  as string), ")") as Sets_a_New_Standard,
  concat(cast(cte13.Often_Exceeds_Expectations as string), "% (",cast(cte16_.Often_Exceeds_Expectations  as string), ")") as Often_Exceeds_Expectations,
  concat(cast(cte13.Consistently_Meets_Expectations as string), "% (",cast(cte16_.Consistently_Meets_Expectations  as string), ")") as Consistently_Meets_Expectations,
  concat(cast(cte13.Needs_Development as string), "% (",cast(cte16_.Needs_Development  as string), ")") as Needs_Development
  from cte13 inner join cte16_
  on cte13.mg1 = cte16_.mg1
),

cte19 as (
  select * from cte17
  union all
  select * from cte18
  where cte18.mg1 not in (select mg1 from cte17)

),

cteA as (
  SELECT distinct(mg3) FROM cte0
  where mg3 is not null
  order by mg3
),

cteB as (
  SELECT distinct(mg3) FROM cte0
  where mg3 is not null and rating = 'Too new to tell'
  order by mg3
),

cteC as (
  SELECT distinct(mg4) FROM cte0
  where mg4 is not null
  order by mg4
),

cteD as (
  SELECT distinct(mg4) FROM cte0
  where mg4 is not null and rating = 'Too new to tell'
  order by mg4
),

cteE as (
  select cteA.mg3,
  case 
  when cteB.mg3 is not null then 'New'
  else 'Not New'
  end as Rating
  from cteA left join cteB 
  on cteA.mg3 = cteB.mg3
),

cteF as (
  select cteC.mg4,
  case 
  when cteD.mg4 is not null then 'New'
  else 'Not New'
  end as Rating
  from cteC left join cteD 
  on cteC.mg4 = cteD.mg4
  where cteC.mg4 not in (select mg3 from cteE)
),

cteG as (
  select * from cteE
  union all
  select * from cteF
),

cteH as (
  select cteG.*,d.email_address from cteG left join `people-analytics-keeptruckin.workday_raw.census_dni` d
  on cteG.mg3 = d.full_name
  where --active_status = 1
   _fivetran_deleted = false
   and d.email_address not like '%keep%'
   and d.email_address <> 'faizankhan@gomotive.com'
),

cte20 as (
  SELECT ceo_5_email as mg_email, mg3 as mg1, rating, count(rating) as total_count FROM cte0
  where rating = 'Too new to tell'
  group by ceo_5_email, mg3, rating
),

cte21 as (
  SELECT ceo_5_email as mg_email, mg4 as mg1, rating, count(rating) as total_count FROM cte0
  where rating = 'Too new to tell' 
  and mg4 not in (SELECT mg3 from cte20)
  group by ceo_5_email, mg4, rating
),

cte20_21 as (
  select * from cte21
  union all
  select * from cte20
),

cteI as (
  SELECT cteH.email_address as mg_email, cteH.mg3 as mg1, 
  case
  when cteH.Rating = 'Not New' then 0
  else cte20_21.total_count 
  end as total_count
  FROM cteH left join cte20_21
  on cteH.mg3 = cte20_21.mg1
),

cteFinal as (
  select cte19.*, cteI.total_count as Not_Eligible_for_Rating from cte19 inner join cteI
  on cte19.mg1 = cteI.mg1
),

cteRem1 as (
  SELECT ceo_5_email, mg3 as mg1, count(mg3) as total_count FROM cte0
  where rating = 'Not Rated' and mg3 is not null
  group by ceo_5_email, mg3
),

cteRem2 as (
  SELECT ceo_5_email, mg4 as mg1, count(mg4) as total_count FROM cte0
  where rating = 'Not Rated' and mg4 is not null
  group by ceo_5_email, mg4
),

cteRemC as (
  select * from cteRem2
  union all
  select * from cteRem1
),

cteCom as (
  select cteFinal.*, cteRemC.total_count as Not_Rated from cteFinal inner join cteRemC
  on cteFinal.mg1 = cteRemC.mg1
)


select * from cteCom 




