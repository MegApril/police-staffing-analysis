# Seattle Police Department West Precinct Staffing Analysis
This project aims to inform future officer staffing needs based on historical data from Seattle Police Department's CAD database. 

## Executive Summary
This analysis quantifies the workload of the Seattle Police Department’s West Precinct and links documented labor demand to staffing requirements. The objective is to determine whether current workforce allocation aligns with reactive, proactive, and administrative responsibilities, and to provide a defensible framework for staffing decisions. The entire workload analysis can be found [here.](Analysis/workload-analysis.md)

In 2023, SPD West responded to 97,739 unique calls for service, requiring 189,795.88 hours of recorded labor. A total of 169,260 CAD records were associated with these events, reflecting the full scope of documented workload activity.

### Purpose
This analysis establishes a systematic method for evaluating operational demand based on:
- Temporal distribution of Calls for Service (hour, day, month)
- Time spent by final call type
- Nature of calls
- Geographic distribution of workload by beat

Staffing recommendations are derived from:
- Workload-based hour calculations
- Agency shift relief assumptions (8-hour and 10-hour staffing models)
- Department performance objectives
- Empirical workload metrics

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

**5. Determine Required Officers per Shift**  
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
