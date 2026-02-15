# Police Staffing Analysis
This project aims to inform future officer staffing needs based on historical data from Seattle Police Department's CAD database. Deliverables will include a slide deck with findings and statistics, this repository containing documented code with explanations, and visualizations.

## Table of Contents
1. [Executive Summary](#executive-summary)
   - [Purpose](#purpose)
   - [Findings](#findings)
   - [Reccomendations](#reccomendations)
2. [Workload Assessment](#workload-assessment)
3. [Staffing Reccomendations](#staffing-reccomendations)
## Executive Summary
This analysis aims to link workload of the police department and worforce numbers to ensure there is enough officer coverage where and when they are needed to keep up with active and administrative duties. The first goal is to quantify the workload of Seattle Police Department's West precinct, then give staffing reccomendations based on number of hours needed.

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
### Reccomendations

## Workload Assessment

### Number of Calls
- 6AM - 2PM contains 40% of calls  
- 2PM - 10PM contains 38% of calls  
- 10PM - 6AM contains 22% of calls  
- There is very little seasonal variability. All months are within 10% of the yearly average. Saturdays and Sundays have the fewest number of calls, while Fridays have the highest numbers of calls.
### Time Spent on Calls
SPD West spends between 14,000 - 17,000 hours on labor per month with the highest number of hours being worked in May.
### Establishing Performance Objectives
The way which agencies are directed to allocate their time determines how workload metrics influence staffing hours [^2]. 

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

