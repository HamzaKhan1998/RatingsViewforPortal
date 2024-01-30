with cte0 as  (
  select * FROM `people-analytics-keeptruckin.hamza_test.Rating`
),

cte2 as (
  SELECT ceo_5_email, mg3, count(rating) as total_count FROM cte0
  --where mg1 = 'Brian Germain' --and rating <> 'Not Rated' and rating <> 'Too new to tell'
  group by ceo_5_email, mg3
),

cte2_ as (
  SELECT ceo_5_email, mg4, count(rating) as total_count FROM cte0
  --where mg1 = 'Brian Germain' --and rating <> 'Not Rated' and rating <> 'Too new to tell'
  group by ceo_5_email, mg4
),

--Getting the HC by rating


cte4 as (
  SELECT ceo_5_email, mg3, rating, count(rating) as total_count_2 FROM cte0
  --where mg1 = 'Brian Germain' --and rating <> 'Not Rated' and rating <> 'Too new to tell'
  group by ceo_5_email, mg3, rating
),

cte4_ as (
  SELECT ceo_5_email, mg4, rating, count(rating) as total_count_2 FROM cte0
  --where mg1 = 'Brian Germain' --and rating <> 'Not Rated' and rating <> 'Too new to tell'
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
  IN ("Sets a New Standard", "Often Exceeds Expectations", "Consistently Meets Expectations", "Needs Development", "Not Rated", "Too new to tell"))
),



cte11 as (
  SELECT * FROM cte4
  PIVOT(SUM(total_count_2) FOR rating 
  IN ("Sets a New Standard", "Often Exceeds Expectations", "Consistently Meets Expectations", "Needs Development", "Not Rated", "Too new to tell"))
),

cte12 as (
  SELECT * FROM cte4_
  PIVOT(SUM(total_count_2) FOR rating 
  IN ("Sets a New Standard", "Often Exceeds Expectations", "Consistently Meets Expectations", "Needs Development", "Not Rated", "Too new to tell"))
),

cte13 as (
  select mg_email, mg1, 
  `Sets a New Standard` as Sets_a_New_Standard, 
  `Often Exceeds Expectations` as Often_Exceeds_Expectations, 
  `Consistently Meets Expectations` as Consistently_Meets_Expectations, 
  `Needs Development` as Needs_Development, 
  `Not Rated` as Not_Rated, 
  `Too new to tell` as Too_new_to_tell 
  from cte9
),


cte15 as (
  select mg3 as mg1,
  `Sets a New Standard` as Sets_a_New_Standard, 
  `Often Exceeds Expectations` as Often_Exceeds_Expectations, 
  `Consistently Meets Expectations` as Consistently_Meets_Expectations, 
  `Needs Development` as Needs_Development, 
  `Not Rated` as Not_Rated, 
  `Too new to tell` as Too_new_to_tell 
  from cte11
),

cte16 as (
  select mg4 as mg1,
  `Sets a New Standard` as Sets_a_New_Standard, 
  `Often Exceeds Expectations` as Often_Exceeds_Expectations, 
  `Consistently Meets Expectations` as Consistently_Meets_Expectations, 
  `Needs Development` as Needs_Development, 
  `Not Rated` as Not_Rated, 
  `Too new to tell` as Too_new_to_tell 
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
  concat(cast(cte13.Needs_Development as string), "% (",cast(cte15.Needs_Development  as string), ")") as Needs_Development,
  concat(cast(cte13.Too_new_to_tell as string), "% (",cast(cte15.Too_new_to_tell  as string), ")") as Too_new_to_tell,
  concat(cast(cte13.Not_Rated as string), "% (",cast(cte15.Not_Rated  as string), ")") as Not_Rated
  from cte13 inner join cte15
  on cte13.mg1 = cte15.mg1
),

cte17 as (
  select cte13.mg_email, cte13.mg1, 
  concat(cast(cte13.Sets_a_New_Standard as string), "% (",cast(cte16_.Sets_a_New_Standard  as string), ")") as Sets_a_New_Standard,
  concat(cast(cte13.Often_Exceeds_Expectations as string), "% (",cast(cte16_.Often_Exceeds_Expectations  as string), ")") as Often_Exceeds_Expectations,
  concat(cast(cte13.Consistently_Meets_Expectations as string), "% (",cast(cte16_.Consistently_Meets_Expectations  as string), ")") as Consistently_Meets_Expectations,
  concat(cast(cte13.Needs_Development as string), "% (",cast(cte16_.Needs_Development  as string), ")") as Needs_Development,
  concat(cast(cte13.Too_new_to_tell as string), "% (",cast(cte16_.Too_new_to_tell  as string), ")") as Too_new_to_tell,
  concat(cast(cte13.Not_Rated as string), "% (",cast(cte16_.Not_Rated  as string), ")") as Not_Rated
  from cte13 inner join cte16_
  on cte13.mg1 = cte16_.mg1
),

cte19 as (
  select * from cte17
  union all
  select * from cte18
  where cte18.mg1 not in (select mg1 from cte17)

)

select * from cte19 
order by mg1










