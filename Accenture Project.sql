-- DATA CLEANING AND PICK THE TOP 5 POPULARITY BASED ON POPULARIY SCORE

-- Remove null values from Content, Format string, and select the relevant columns
with CTE_content as 
(select Content_ID, Type, Category from Content where Content_ID is not null and Type is not null and Category is not null)
select Content_ID, Type as ContentType, 
Case when Category like '%"%' then SUBSTRING(Category, CHARINDEX('"',Category)+1, len(Category) - 2) else Category end as NewCategory
from CTE_content;

-- Remove null values from Reactions and select the relevant columns
with CTE_Reaction as (select Content_ID, Type as ReactionType from Reactions where Type is not null)
Select Content_ID, ReactionType from CTE_Reaction;

-- Remove null values from ReactionTypes and select the relevant columns
select Type as ReactionType, Score from ReactionTypes where Type is not null and Score is not null;

-- Create a temp Table for cleaned Content Data
create table #temp_Content
(Content_ID varchar(50),
ContentType varchar(50),
Category varchar(50));

insert into #temp_Content
select Content_ID, Type as ContentType, 
Case when Category like '%"%' then SUBSTRING(Category, CHARINDEX('"',Category)+1, len(Category) - 2) else Category end as NewCategory
from Content
where Content_ID is not null and Type is not null and Category is not null;

select * from #temp_Content;

-- Create a temp Table for cleaned Reaction Data
create table #temp_Reactions (
    Content_ID varchar(50),
    ReactionType varchar(50), 
    Datetime datetime,
);

insert into #temp_Reactions
select Content_ID, Type as ReactionType, [Datetime] from Reactions where Type is not null;

select * from #temp_Reactions;

-- Create a temp Table for cleaned ReactionTypes Data
create table #temp_ReactionTypes (
    ReactionType varchar(50), 
    Score int
);

insert into #temp_ReactionTypes
select Type as ReactionType, Score from ReactionTypes where Type is not null and Score is not null

select * from #temp_ReactionTypes;

-- Merge tables

create table #temp_ContentReaction(
    Content_ID varchar(50),
    ReactionType varchar(50),
    ContentType varchar(50),
    Category varchar(50),
    Datetime datetime
)

insert into #temp_ContentReaction
select b.Content_ID, b.ReactionType,
a.ContentType, a.Category, b.Datetime
from #temp_Reactions as b
inner join #temp_Content as a
on b.Content_ID = a.Content_ID

select * from #temp_ContentReaction

select c.Content_ID, c.ReactionType,
c.ContentType, c.Category, d.Score, c.Datetime
from #temp_ContentReaction as c
inner join #temp_ReactionTypes as d
on c.ReactionType = d.ReactionType

create table #temp_Top5 (
    Content_ID varchar(50),
    ReactionType varchar(50),
    ContentType varchar(50),
    Category varchar(50),
    Score int,
    Datetime datetime
)

insert into #temp_Top5
select c.Content_ID, c.ReactionType,
c.ContentType, c.Category, d.Score, c.Datetime
from #temp_ContentReaction as c
inner join #temp_ReactionTypes as d
on c.ReactionType = d.ReactionType

select * from #temp_Top5
order by Datetime desc

select TOP 5 sum(Score), Category from #temp_Top5
Group By Category
order by sum(Score) desc