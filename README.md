# Project Process
## Overview
This project aims to inform future officer staffing needs based on historical data from Seattle Police Department's CAD database. Deliverables will include a slide deck with findings and statistics, this repository containing documented code with explanations, and visualizations.
## Executive Summary
2023 brought 97,739 unique calls to Seattle Police Department's WEST precinct. There is a total of 169,260 records associated with these calls for service.
### Number of Calls
6AM - 2PM contains 40% of calls  
2PM - 10PM contains 38% of calls  
10PM - 6AM contains 22% of calls  
On a month to month basis, there is not a huge difference in number of calls. All months are within 10% of the yearly average indicating low seasonal variability. Saturdays and Sundays have the fewest number of calls, while Fridays have the highest numbers of calls.
### Time Spent on Calls
SPD West spends between 14,000 - 17,000 hours on labor per month with the highest number of hours being worked in May.
### Reccomendations
- Determine staffing hours based on average number of calls from year(s) prior, and average time per call. This number is shockingly uniform across months despite the following statistics. 
    1. The top 10% of calls account for *53%* of total labor.
    2. 95% of calls fall under 2.5 hours total department labor time.
    3. Median time spent per call is 31 minutes.
- Using number of calls and average time spent per call to estimate labor allows time for planned events which consume a lot of department time (Crowd management, Security needs, Concerts, etc), Violent Crime which consumes a lot of active and administrative time (homocides, assaults, robbery), responding to the community, and officer initiated calls.
- Distribute staffing hours based on percentage of calls within each shift.
    1. 40% of allotted hours should be assigned to 6AM - 2PM shift.
    2. 38% of alloted hours should be assigned to the 2PM - 10PM shift.
    3. 22% of allotted hours should be assigned to the 10PM - 6AM shift.

## Future Analyses
- Run similar analysis using 2024 and 2025 data to explore change on a year over year basis. Use this percentage change to model 2026 staffing needs.
## Data Gathering
1. 2025 Data (147,776 records)
   1. CAD Event Number - starts with - 2025 AND Dispatch Precinct is WEST
   2. VALIDATION: To ensure data was accurately captured, I ran the following query with a result of 147,778 records. I felt comfortable leaving the query as it was, going off of the CAD event number.
      1. CAD Event Original Time Queued is between 2025 Jan 01 12:00:00 AM AND 2026 Jan 01 12:00:00 AM AND Dispatch Precinct is WEST
2. 2024 Data (152,602 records)
   1. CAD Event Number - starts with - 2024 AND Dispatch Precinct is WEST
4. 2023 Data (169,260 records)
   1. CAD Event Number - starts with - 2023 AND Dispatch Precinct is WEST
  
All CSV's had to be pre-processed to load appropriately into BigQuery. This involved writing the files from csv's to a .paraquet file. This is found [here.](Python/cad_data_preprocessing.ipynb)
