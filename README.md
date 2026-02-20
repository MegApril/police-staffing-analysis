# Seattle Police Department West Precinct Staffing Analysis
This project aims to inform future officer staffing needs based on historical data from Seattle Police Department's CAD database. 

## Executive Summary
This analysis quantifies the workload of the Seattle Police Department’s West Precinct and links documented labor demand to staffing requirements. The objective is to determine whether current workforce allocation aligns with reactive, proactive, and administrative responsibilities, and to provide a defensible framework for staffing decisions. The entire workload analysis can be found [here.](#workload-assessment)

In 2023, SPD West responded to 97,739 unique calls for service, requiring 182,278 hours of recorded labor. A total of 169,260 CAD records were associated with these events, reflecting the full scope of documented workload activity. According to Law Enforcement Today, "as of December 31, 2023, out of the 913 officers, SPD only has 424 police officers working patrol[[5]](#5)."

### Purpose
This report has two purposes.
1. Complete Workload Analysis
2. Make Reccomendations to align workload with sustainable staffing practices.

The analysis establishes a systematic method for evaluating operational demand based on several factors, and following research for a full-scope review of officer time. [[2]](#2)
- Temporal distribution of Calls for Service (hour, day, month)
- Time spent by final call type
- Nature of calls
- Geographic distribution of workload by beat

Staffing recommendations are derived from:
- Workload-based hour calculations
- Agency shift relief assumptions 
- Department performance objectives
- Rule of 60 principles

### Reccomendations for 'Rule of 60' Adherence
*Currently Underway*

### Recommended Staffing Framework
**1. Forecast Monthly Workload Hours**
  
Determine total monthly workload hours using projected call volume and projected average service time:

$$
H_m = \frac{\bar{t}_m \times \bar{n}_m}{3600}
$$

Where:
- $H_m$ = monthly allotted hours
- $\bar{t}_m$ = average time per call in month $m$
- $\bar{n}_m$ = average number of calls in month $m$

Year-over-year percent change adjustments can be applied to call volume, average service time, or total workload hours depending on forecasting strategy.
Because administrative activities, court, training, proactive policing, and other internal obligations are recorded as CAD events, this calculation reflects total documented workload demand, not solely dispatched CFS.

**2. Allocate Workload Hours by Shift**  
Distribute total projected monthly hours using historical percentages of workload by shift.  
Example (January 2024 projection at 5% increase in workload hours):
Total projected hours: 16,147.76
- 6AM–2PM (40%): 6,459.10 hours
- 2PM–10PM (38%): 6,136.15 hours
- 10PM–6AM (22%): 3,552.51 hours

**3. Convert Monthly Shift Hours to Daily Requirements**  
Divide monthly shift hours by the number of days in the month to determine average daily workload demand.  
Example (31 days in January):
- 6AM–2PM: 208.36 hours/day
- 2PM–10PM: 197.94 hours/day
- 10PM–6AM: 114.60 hours/day

**4. Determine Required Officers per Shift**  
Divide daily shift workload hours by 8 scheduled hours per officer.
Because total workload calculations include administrative, court, training, and proactive CAD events, the full 8-hour shift is used rather than applying a separate availability factor.  
Example:
- 6AM–2PM: 26 officers
- 2PM–10PM: 25 officers
- 10PM–6AM: 15 officers


**5. Convert Required Officers Needed in Accordance with the 'Rule of 60' Guidelines**  
*Currently Underway*

**6. Determine Required Officers per Shift**  
Schedule officers by sector and beat based on:
- Geographic workload distribution
- Day-of-week variation
- Seasonal patterns
- Preplanned events
- Station-specific operational requirements

*This can be further refined based on day of the week. Additionally, if we instead find that going off of (number of calls * average time) spent on calls is a better adjustment that would change these numbers. Running numbers with a 5% increase in call volume (vs hours shown in the example) and the same average time spent on calls, gave a monthly allottment of 16,131.5 for January, which is remarkably close to the numbers above.*

## Future Analyses and Model Validation
The current staffing framework is based on one year of data. To strengthen forecasting confidence for 2026 and beyond, additional historical data from 2024 and 2025 should be incorporated.

Further analysis should evaluate year-over-year trends in workload drivers to determine whether observed changes represent stable patterns or short-term variability. Specifically:  
- How does total call volume change year over year?
- How does total labor time spent on CFS change year over year?
- Are changes in call volume and labor hours consistent across multiple years?
- What is the year-over-year population change within the service area?
- Does population growth correlate with changes in call volume?
- Does population growth correlate with changes in total labor hours?  
Evaluating these factors using percent change adjustments will provide a stronger empirical foundation for budget planning, staffing projections, and performance benchmarking.


# Workload Assessment
## Defining Workload
Following guidance from the International City/County Management Association (ICMA)[[4]](#4), the “Rule of 60” recommends that approximately 60% of sworn personnel be assigned to patrol functions. This structure ensures sufficient capacity not only for responding to calls for service, but also for community engagement, training, retention planning, and specialized initiatives. To evaluate whether current staffing aligns with this principle, workload must be clearly defined. Distinguishing reactive, proactive, and organizational time is essential for determining whether patrol staffing supports both emergency response and community-oriented policing goals. Therefore, this analysis relies on the following definitions. For a complete list of how call types are mapped, refer [here.](data/call-type-mapping.csv)
|Term |Definition|Call Types Included|Example|
|--|--|--|--|
|Reactive Patrol Demand |Demand-driven and time-sensitive calls. |Crime, Alarms, Warrants, Non-Officer initiated Calls, Dispatch Events||
|Proactive / Community Patrol Activity |Officer initiated or capacity based calls.|Directed patrol activity, Officer Initiated Calls, School Visits, Special Events||
|Organizational / Out-of-Service Workload|Work that removes officers from patrol availability.|Court, Training, Out At Range, Reports, Maintenance of Vehichles, Follow Up's||

The `final_call_type` titled 'Off Duty Employment' is excluded from this analysis because it will skew the analysis and will be addressed in the agency relief metric.

## Distribution of Calls for Service
### By Hour
- 6AM - 2PM contains 40% of calls  
- 2PM - 10PM contains 38% of calls  
- 10PM - 6AM contains 22% of calls
<img src="visuals/cfs-hourly.png" alt="Right aligned" style="float: right; width:100%; height:auto;"> 

### By Day

Demand is highest on Fridays; accounting for 15% of calls for the week. Demand is lowest on the weekends; with Sundays representing 12% of calls for the week, and Saturdays representing 13% of the calls for the week.
<img src="visuals/cfs-day.png" alt="Right aligned" style="float: right; width:100%; height:auto;"> 

### By Month

There is not a significant amount of seasonal variability in this market. All months are within 10% of the monthly average which is 8,145 calls. The highest volume of calls occurs in May at 9,037, and the lowest number of calls occurs in November at 7,501.

<img src="visuals/cfs-month.png" alt="Right aligned" style="float: right; width:100%; height:auto;"> 

## Time Spent on Calls
### Hours Worked Distributed by Time of Day
Given the similar distribution of hours worked, and number of calls - going off of either number will result in similar staffing models.
- 6AM - 2PM contains 39% of hours worked  
- 2PM - 10PM contains 38% of hours worked  
- 10PM - 6AM contains 23% of hours worked

<img src="visuals/hours-worked-houly.png" alt="Right aligned" style="float: right; width:100%; height:auto;"> 

### By Month
SPD West averages between 14,411 and 17,363 labor hours per month, with May representing the peak workload period.  

The median service time per call is 31 minutes, while the mean service time is 120 minutes. This substantial gap reflects a highly skewed workload distribution: the top 10% of calls account for 53% of total labor hours. A relatively small number of highly time-intensive events significantly elevate the mean, while the median more accurately reflects a typical call.

For staffing projections, the mean service time is recommended for calculating monthly workload allotments. Although it overstates the duration of a typical call, it more accurately captures total labor demand and provides a buffer for high-duration events that disproportionately consume resources. Using the median in this context would risk systematically underestimating required staffing levels.
<img src="visuals/department-time-by-month.png" alt="Right aligned" style="float: right; width:100%; height:auto;"> 

### Proactive vs. Reactive vs. Organizational Workload

## Establishing Performance Objectives
The way which agencies are directed to allocate their time determines how workload metrics influence staffing hours[[2]](#2). 

## Determining Agency Shift Relief Metric

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
### 1
Aponte, C., Perez, A., & Carpenter, A. (2020, November 17). Analyzing Staffing as Cornerstone to Police Transformation. V2A. https://v2aconsulting.com/insights/analyzing-staffing-as-cornerstone-to-police-transformation/  
### 2
Wilson, J., & Weiss, A. (2014). A PERFORMANCE-BASED APPROACH TO POLICE STAFFING AND ALLOCATION. Office of Community Oriented Policiing Policies, U.S. Department of Justice. https://portal.cops.usdoj.gov/resourcecenter/content.ashx/cops-p247-pub.pdf  
### 3
Wilson, J. M., & Grammich, C. A. (2024). Reframing the police staffing challenge: A systems approach to workforce planning and managing workload demand. Policing: A Journal of Policy and Practice, 18. https://doi.org/10.1093/police/paae005
### 4
Center for Public Safety Management, McCabe, J., & International City/County Managemenet Association. (2013). An Analysis of Police Department Staffing: How many officers do you really need?
### 5
lawenforcementtoday.com. (2024, April 9). Seattle police staffing levels at lowest in 30 years, with many officers eligible to retire and others looking to transfer. Lawenforcementtoday.Com. https://lawenforcementtoday.com/seattle-police-staffing



