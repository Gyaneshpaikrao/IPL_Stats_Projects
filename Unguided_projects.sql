
-- Top 10 batsmen total runs scored.

select fact_bating_summary.batsmanName, sum(fact_bating_summary.runs) as Total_runs_Batsmen from 
fact_bating_summary join dim_match_summary on fact_bating_summary.match_id = dim_match_summary.match_id
group by fact_bating_summary.batsmanName
order by Total_runs_Batsmen desc
limit 10;
 

-- Top 10 batsmen batting average. (min 60 balls faced in
--  each season)

select fact_bating_summary.batsmanName, round(avg(fact_bating_summary.runs),2) as AVG_runs_Batsmen, sum(fact_bating_summary.balls) as Balls_fased
from fact_bating_summary join dim_match_summary 
on fact_bating_summary.match_id = dim_match_summary.match_id
group by fact_bating_summary.batsmanName
having sum(fact_bating_summary.balls) >= 60
order by AVG_runs_Batsmen desc
limit 10;

-- Top 10 batsmen strike rate (min 60 balls faced in each
--  season)


Select bs.batsmanName, round(avg(bs.SR),0) as Avg_Sr_3year from 
fact_bating_summary as bs
join dim_match_summary as ms on 
ms.match_id = bs.match_id
group by bs.batsmanName
having sum(bs.balls) >= 60 
order by Avg_Sr_3year desc
limit 10;

-- Top 10 bowlers based on past 3 years total wickets taken.

select bls.bowlerName, sum(bls.wickets) as Wicket_Taken from
fact_bowling_summary as bls
 join dim_match_summary as ms
 on bls.match_id = ms.match_id
group by bls.bowlerName
 order by Wicket_Taken desc
 limit 10;
 
 -- Top 10 bowlers bowling average. (min 60 balls bowled in
--  each season)

select bowlerName, sum(Total_balls) as Total_balls, round(avg(Bowling_Average),2) as Bowl_AVG from 
(select bls.bowlerName, sum(bls.wickets) as Total_wicket, Sum(bls.runs) as Total_Runs, 
year(str_to_date(matchDate, '%b %d, %Y')) as Season_Year,
round(Sum(bls.Overs)*6,0) as Total_balls, 
round(sum(bls.runs)/nullif(sum(bls.wickets),0),2) as Bowling_Average from
fact_bowling_summary as bls join dim_match_summary as ms on
bls.match_id = ms.match_id 
group by bls.bowlerName, Season_Year 
having Total_wicket > 0 and Total_balls >= 60
order by Bowling_Average asc) t1
group by bowlerName, Total_balls
order by Bowl_AVG
limit 10;



-- Top 10 bowlers economy rate. (min 60 balls bowled in
--  each season)

select bowlerName, round(avg(AVG_economy),2) as Economy_rate from
(select bls.bowlerName, round(avg(bls.economy),2) As AVG_economy, 
year(str_to_date(matchDate, '%b %d, %Y')) As Season_Year 
from fact_bowling_summary As bls
join dim_match_summary as ms 
on bls.match_id = ms.match_id 
group by bls.bowlerName, Season_Year
having sum(bls.overs)*6 >= 60
order by AVG_economy) as t1
group by bowlerName
order by Economy_rate
limit 10;


-- Top 5 batsmen boundary % (fours and sixes).
select batsmanName, concat(boundary_percent, '%') as Boundary_Percent, fours, Sixs from (
select bs.batsmanName, round((sum(bs.fours) + sum(bs.sixs)) *100.0 / sum(bs.balls),2)  as Boundary_Percent, sum(bs.fours) as Fours, Sum(sixs) as Sixs 
from fact_bating_summary as bs 
join dim_match_summary as ms on 
bs.match_id = ms.match_id
 group by bs.batsmanName 
 having sum(bs.balls) >= 60
 order by Boundary_Percent desc
 limit 5) as t1;
 
 
 -- Top 5 bowlers years dot ball %.
select bowlerName, concat(Dot_Ball_Percentage, '%') as Dot_ball_Percent from(
select bls.bowlerName, round(sum(bls.Dot_Balls) *100 / (sum(bls.overs) * 6),2) as Dot_ball_Percentage 
from fact_bowling_summary as bls
 join dim_match_summary as ms
 on bls.match_id = ms.match_id
 group by bls.bowlerName
 having sum(bls.Dot_Balls) >= 60
 order by Dot_ball_Percentage desc
 limit 5) t1;
 
 
-- Top 4 teams winning %.

select team, count(*) as Match_played, 
sum(case when team = winner then 1 else 0 end) as Matchs_won, 
round(sum(case when team = winner then 1 else 0 end) * 100 / count(*),2) as Win_pct from 
( select  team1 as team, winner from dim_match_summary
  union all
  select team2 as team, winner from dim_match_summary
) as t1
 group by team
 order by  Win_pct desc
 limit 4;
 
 
-- Top 2 teams with the highest number of wins achieved by chasing targets over
--  the past 3 years.

select winner, count(*) as Match_won from dim_match_summary
where str_to_date(matchdate, '%b %d, %Y') >= current_date - interval 4 year
and lower(margin) like '%wickets%'
group by winner
order by match_won desc
limit 2;

-- Orange cap player

select BatsmanName, Sum(runs) as Total_run, round(avg(SR),0) as StrikeRate, round(avg(runs),2) as AVG_runs from 
fact_bating_summary
 group by BatsmanName
 having Total_run > 500 and Strikerate > 125 and AVG_runs > 30
 order by Total_run desc
 limit 1;
 
 -- Purple cap player
select BowlerName, Sum(Wickets) as Total_wickets, round(avg(economy),2) as Avg_economy from 
fact_bowling_summary
 group by bowlername
 having Total_wickets >= 66 and avg_economy < 7.75
 order by Total_wickets;
 
 -- Top 4 Qulifying Team for 2024 ipl

select team, count(*) as Match_played, 
sum(case when team = winner then 1 else 0 end) as Matchs_won, 
round(sum(case when team = winner then 1 else 0 end) * 100 / count(*),2) as Win_pct from 
( select  team1 as team, winner from dim_match_summary
  union all
  select team2 as team, winner from dim_match_summary
where str_to_date(matchDate, '%b %d, %Y') >= current_date - interval 4 year) as t1
 group by team
 order by  Win_pct desc
 limit 4;
 
 -- Winner will be 2024
create table Previews_Final like dim_match_summary;

insert into previews_final ( team1, team2, winner, margin, matchDate)
values ( 'CSK', 'KKR', 'CSK', '27 runs', '15 Oct 2021' ),
( 'GT', 'RR', 'GT', '7 wickets', '29 may 2022'),
( 'GT', 'CSK', 'CSK', '5 wickets', '29 may 2023'),
( 'KKR', 'SH', 'KKR', '8 wickets', '26 may 2024');

select*from previews_final;

select winner as team, count(*) from (
select team1, winner from previews_final
union all
select team2, winner from previews_final) as t1
group by winner
limit 1;

-- runner-up will be 2024

select team1, count(*) from (
select team1, winner from previews_final
union all
select team2, winner from previews_final
) t1
where team1 != winner
group by team1;


-- My Team 11  3 years performance data and additional research

select Player, Role from (
with batting_stats as ( select batsmanName as Player, Sum(runs) as Total_runs, round(avg(runs),2) as Avg_runs, round(avg(sr),0) as Strike_rate 
 from fact_bating_summary
 group by batsmanName),
 bowling_stats as ( select bowlerName as Player, sum(Wickets) as Total_wickets, sum(runs)/sum(wickets) as bowling_avg, avg(economy) as avg_economy from
fact_bowling_summary
group by bowlerName),
-- allrounders
allrounders as ( select b.Player, b.Total_runs, b.Strike_rate, bl.Total_wickets, b.avg_runs, bl.bowling_avg, bl.avg_economy from batting_stats as b
join bowling_stats as bl on bl.Player = b.Player),
-- top 4 batsman
Top_Batsman as ( select Player, 'Batsman' as Role,
Total_runs, Avg_runs, Strike_rate,
null as Total_wickets, null as bowling_avg, null as avg_economy
from batting_stats
where total_runs > 500 and avg_runs > 30 and Strike_rate > 125
order by Total_runs desc
limit 4),
-- top 2 allrounder
Top_allrounder as ( select Player, 'Allrounder' as role,
Total_runs, null as Avg_runs, Strike_rate,
Total_wickets, null as bowling_avg, null as avg_economy from allrounders
where Total_runs > 300 and strike_rate > 130 and total_wickets > 10
order by total_runs desc
limit 2),
-- Top 5 bowlers
Top_bowlers as ( select player, 'Bowler' as role,
Null as Tatal_runs, null as Avg_runs, null as Strike_rate,
Total_wickets, bowling_avg, avg_economy from bowling_stats
where total_wickets > 38 and avg_economy < 9
order by Total_wickets desc, avg_economy desc
limit 5)

-- Final Result Combine all
select * from Top_batsman
union all
select * from Top_allrounder
union All
select * from Top_Bowlers
ORDER BY field(Player,
'YashasviJaiswal',
'SaiSudharsan', 
'SuryakumarYadav',
'RinkuSingh',
'GlennMaxwell', 
'RavindraJadeja',
'RashidKhan', 
'AveshKhan', 
'HarshalPatel', 
'MohammedShami',
'YuzvendraChahal') ) as t1;

-- Pick your top 3 all-rounders

select Player, Role, Total_runs, Strike_Rate, Total_wickets from (
 
 with batting_stats as ( select batsmanName as Player, Sum(runs) as Total_runs, round(avg(runs),2) as Avg_runs, round(avg(sr),0) as Strike_rate 
 from fact_bating_summary
 group by batsmanName),
 bowling_stats as ( select bowlerName as Player, sum(Wickets) as Total_wickets, sum(runs)/sum(wickets) as bowling_avg, avg(economy) as avg_economy from
fact_bowling_summary
group by bowlerName),
-- allrounders
allrounders as ( select b.Player, b.Total_runs, b.Strike_rate, bl.Total_wickets, b.avg_runs, bl.bowling_avg, bl.avg_economy from batting_stats as b
join bowling_stats as bl on bl.Player = b.Player),

-- top 3 all rounders
Top_allrounders as (select Player, 'Allrounders' as role,
Total_runs, Avg_runs, Strike_rate,
Total_wickets, Bowling_avg, Avg_economy
from allrounders
where total_runs > 500 and Total_wickets > 25
order by total_runs desc)
select * from Top_allrounders) as t1;