# Police Staffing Analysis
This project aims to inform future officer staffing needs based on historical data from Seattle Police Department's CAD database. Deliverables will include a document with findings and statistics, this repository containing documented code with explanations, and visualizations.

## Table of Contents
1. [Executive Summary](#executive-summary)
   - [Purpose](#purpose)
   - [Findings](#findings)
   - [Reccomendations](#reccomendations)
2. [Workload Assessment](#workload-assessment)
3. [Staffing Reccomendations](#staffing-reccomendations)
## Executive Summary
This analysis aims to link workload of the Seattle Police Departments West Precinct and worforce numbers to ensure there is enough officer coverage where and when they are needed to keep up with reactive, proactive, and administrative duties. The first goal is to quantify the workload of Seattle Police Department's West precinct, then give staffing reccomendations based on number of hours needed.

2023 brought 97,739 unique calls to Seattle Police Department's WEST precinct. There is a total of 169,260 records associated with these calls for service.

### Purpose
This analysis will provide a methodical system for assessing workload based on:
- Distribution of Calls For Service (Time, Day, Month)
- Time spent on calls categorized by final call type
- Nature of calls
- Volume of workload by geographic beat

Staffing reccomendations will be based on:
- Agency Shift Relief Calculations for 8 hour, and 10 hour staffing models
- Performance Objectives from the department
- Metrics from workload analysis
### Findings
In 2023, there were 97,739 unique calls for service to Seattle Police Department's WEST precinct. Servicing these calls created 189,795.88 hours of labor.
This means, on average, there were 3649.92 hours worked on a weekly basis. Assuming every full time employee worked 40 hours, we can see that 91.25 full time officers were needed to keep up with demand. 
# This does not yet reflect agency relief factor - update
### Reccomendations
*This analysis is based on one year of data. In order to feel comfortable giving 2026 forecasting estimates for staffing, metrics from 2025 and 2026 need to be pulled.*
1. Answering the following questions would provide a solid basis for budget requests, staffing forecasts, tracking department objectives and goals, and other agency needs.
   - How does the number of CFS change year over year? Is this change consistent from 2023-2024? 2024-2025?
   - How does the hours spent on CFS change year over year? Is this change consistent from 2023-2024? 2024-2025?
   - What is the population change year over year?
   - Does population change correlate to a change in hours spent on CFS?
   - Does population change correlate to number on CFS?
  

## Workload Assessment

### Distribution of Calls for Service
#### By Hour
- 6AM - 2PM contains 40% of calls  
- 2PM - 10PM contains 38% of calls  
- 10PM - 6AM contains 22% of calls
<img src="visuals/cfs-hourly.png" alt="Right aligned" style="float: right; width:100%; height:auto;"> 

#### By Day

- Demand is highest on Fridays; accounting for 15% of calls for the week. Demand is lowest on the weekends; with Sundays representing 12% of calls for the week, and Saturdays representing 13% of the calls for the week.
<img src="visuals/cfs-day.png" alt="Right aligned" style="float: right; width:100%; height:auto;"> 

#### By Month

- There is not a significant amount of seasonal variability in this market. All months are within 10% of the monthly average which is 8,145 calls. The highest volume of calls occurs in May at 9,037, and the lowest number of calls occurs in November at 7,501.

<img src="visuals/cfs-month.png" alt="Right aligned" style="float: right; width:100%; height:auto;"> 

### Time Spent on Calls
#### By Month
- SPD West spends between 14,411 - 17,363 hours on labor per month with the highest number of hours being worked in May. The median amount of time spent per call is 31 minutes, whereas the average amount of time spent per call is 120 minutes. The difference between these numbers can be explained by taking into consideration that the top 10% of calls consume 53% of labor. When there is a small amount of calls that have significantly larger amounts of time spent on them, the average is much higher than the median.
<img src="visuals/department-time-by-month.png" alt="Right aligned" style="float: right; width:100%; height:auto;"> 

#### Onview vs. Dispatch vs. Non-Patrol
According to Wilson & Grammich, it is common for departments to plan for officers to spend one-third to one-half of their time on proactive policing or onview calls (2024).

For this analysis the following definitions were used:  

- Onview - defined as officer initiated events. 
- Dispatch - defined by 911 calls, alarm calls, and telephone (not 911) calls.
- Non-Patrol - all administrative categories, assigned duties, court time, meetings with supervisors, and other events. These events were subtracted from onview and dispatch based on their final call type. The full list of final call types included in non-patrol can be found in the accompanying document in Appendix A.

In 2023, SPD West spent 32% of officer hours on onview calls. 56% of time on dispatch calls, and 12% of time on non-patrol calls.

<img src="visuals/onview_dispatch_nonpatrol.png" alt="Right aligned" style="float: right; width:100%; height:auto;"> 

### Establishing Performance Objectives
The way which agencies are directed to allocate their time determines how workload metrics influence staffing hours[^2]. 

### Determining Agency Shift Relief Metric
## Staffing Reccomendations
## Future Analyses and Opportunities for Fine Tuning
- Run similar analysis using 2024 and 2025 data to explore change on a year over year basis. Use this percentage change to model 2026 staffing needs.
## Process
### Data Gathering
1. 2025 Data (147,776 records)
   1. CAD Event Number - starts with - 2025 AND Dispatch Precinct is WEST
   2. VALIDATION: To ensure data was accurately captured, I ran the following query with a result of 147,778 records. I felt comfortable leaving the query as it was, going off of the CAD event number.
      1. CAD Event Original Time Queued is between 2025 Jan 01 12:00:00 AM AND 2026 Jan 01 12:00:00 AM AND Dispatch Precinct is WEST
2. 2024 Data (152,602 records)
   1. CAD Event Number - starts with - 2024 AND Dispatch Precinct is WEST
4. 2023 Data (169,260 records)
   1. CAD Event Number - starts with - 2023 AND Dispatch Precinct is WEST
  
All CSV's had to be pre-processed to load appropriately into BigQuery. This involved writing the files from csv's to a .paraquet file. This is found [here.](Python/cad_data_preprocessing.ipynb)
## Bibliography
[^1]: Aponte, C., Perez, A., & Carpenter, A. (2020, November 17). Analyzing Staffing as Cornerstone to Police Transformation. V2A. https://v2aconsulting.com/insights/analyzing-staffing-as-cornerstone-to-police-transformation/  
[^2]: Wilson, J., & Weiss, A. (2014). A PERFORMANCE-BASED APPROACH TO POLICE STAFFING AND ALLOCATION. Office of Community Oriented Policiing Policies, U.S. Department of Justice. https://portal.cops.usdoj.gov/resourcecenter/content.ashx/cops-p247-pub.pdf  

