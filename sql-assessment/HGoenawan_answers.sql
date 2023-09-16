/*Note: code is done using sas studio on demand, then copied into sql file
/***********************************Import csv files into tables for SAS to read************************************/

/*libnames and librefs*/

libname data base "/home/u62456161/PMG";

/*import the csvs into the work library*/
FILENAME REFFILE '/home/u62456161/PMG/marketing_performance.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=data.market_perform;
	GETNAMES=YES;
RUN;

FILENAME REFFILE '/home/u62456161/PMG/campaign_info.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=data.campaign;
	GETNAMES=YES;
RUN;

FILENAME REFFILE '/home/u62456161/PMG/website_revenue.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=data.website_revenue;
	GETNAMES=YES;
RUN;


/***********************************Question 1: Write query to get sum of impressions by day************************************/
title;
title "Total Impressions by Day";
proc sql;
	select date, sum(impressions) as Sum_of_Impressions
		from data.market_perform
	group by date; 
quit; /*note, it was unclear whether we could remove columns, but I did so to keep the output briefer*/

/*******************Question 2: Write query to get the top 3 revenue generating states from best to worst.
												How much revenue did the third best state generate?****************************/
title;
title "Top 3 States Generating Most Revenue Ordered Best to Worst";
proc sql outobs = 3;
	select distinct state, sum(revenue) as Total_Revenue
		from data.website_revenue
	group by state
	order by Total_Revenue desc;
quit;

/****************** Question 2 Answer: The third best state, OH, generated 37577 in Total Revenue******************************/

/*******************Question 3: Write a query that shows total cost, impressions, clicks, and revenue of
								each campaign. Make sure to include the campaign name*******************************************/
title;
title "Summary Data of each Campaign";								
proc sql;
	select name as Campaign_Name, sum(market_perform.cost) as Total_Cost, sum(market_perform.impressions) as Total_Impressions, 
		   sum(market_perform.clicks) as Total_Clicks, sum(website_revenue .revenue) as Total_revenue
		from data.campaign as c
	inner join 
		data.website_revenue as r
		on c.ID = r.campaign_ID
	inner join 
		data.market_perform as m
		on c.ID = m.campaign_ID
	group by name;	
quit;

/**************** Question 4: Write a query to get the number of conversions of Campaign5 by state. 
					Which state generated the most conversions for this campaign?********************************/
title;
title "Number of Conversions of Campaign 5 by State";					
proc sql;
	select distinct sum(market_perform.conversions) as Total_Conversions, website_revenue.state as State
		from data.campaign as c
	inner join
		data.market_perform as m
		on c.id = m.campaign_ID
	inner join
		data.website_revenue as r
		on c.id = r.campaign_ID
	where name = "Campaign5"
	group by website_revenue.state
	order by Total_Conversions desc;
quit;

/****************** Question 4 Answer: GA generated the most conversions for this campaign at 3342******************************/

/******************Question 5: In your opinion, which campaign was the most efficient, and why?********************************/

/* I want to use net profit/cost, cost/conversions, and revenue/click metrics to compare the campaigns*/

/*I will first create a table holding summary statistics for each campaign, modified slightly from Question 3*/

title;
title "Summary Data of each Campaign";								
proc sql;
	create table data.pmg_Summary as
		select name as Campaign_Name, sum(market_perform.cost) as Total_Cost, sum(market_perform.impressions) as Total_Impressions, 
		   sum(market_perform.clicks) as Total_Clicks, sum(website_revenue.revenue) as Total_revenue, 
		   sum(market_perform.conversions) as Total_Conversions
			from data.campaign as c
		inner join 
			data.website_revenue as r
			on c.ID = r.campaign_ID
		inner join 
			data.market_perform as m
			on c.ID = m.campaign_ID
		group by name;	
quit;

/* I will now use this summary table to calculate metrics for efficiency*/
title;
title "Efficiency Statistics for each Campaign";
proc sql;
	select campaign_name, (total_revenue-total_cost)/total_cost as NetProfit_Cost_Ratio, 
		total_cost/total_conversions as Cost_Per_Conversion, total_revenue/total_clicks as Revenue_Per_Click
		from data.pmg_summary
	order by NetProfit_Cost_Ratio desc, Cost_Per_Conversion asc, Revenue_Per_Click desc;
quit;
			
/****************Question 5 answer: Using sql query shown above, I believe Campaign 4 was most efficient when it was enabled.
				 I used net profit/cost of campaign to delegate efficiency, and further compared it to 
				 campaign cost per conversions and revenue per click to get a wider scope into campaign efficiency. 
				 Campaign 4 had the highest net profit/cost, one of the lowest cost per conversions, and one of the highest
				 revenue per click. We can see Campaign 2 performs better than Campaign 4 for the last 2 metrics, but only slightly.
				 It is to be noted that I valued net profit/cost more, thus I selected Campaign 4. *******************************/
				
/***************Bonus Question: Write a query that showcases the best day of the week to run ads.******************************/
title;
title "Best Day to Run Ads";

proc sql number;
	 select distinct put(datepart(m.date), downame9.) as Day, sum(website_revenue.revenue) as Total_Revenue
	 	from data.market_perform as m
	 inner join 
	 	data.website_revenue as r
	 	on m.campaign_ID = r.campaign_ID
	 group by Day
	 order by Total_Revenue desc;
quit;

/****************Using revenue as a metric, Friday is the best day of the week to run ads********************/
