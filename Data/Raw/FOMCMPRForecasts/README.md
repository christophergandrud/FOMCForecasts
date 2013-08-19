# Monetary Policy Committee Predictions Data set

These data sets include predictions from the FOMC's Monetary Reports submitted to Congress biannually (February, July). The data was gathered from:

> **Through February 1996:** <http://fraser.stlouisfed.org/publication/?pid=672&tid=87>

> **From July 1996 onwards:** <http://www.federalreserve.gov/monetarypolicy/mpr_default.htm>

The two CSV files contain forecasts concerning change in the quantities from fourth quarter to fourth quarter. The file `SameYear.csv` records predictions for the fourth quarter of the present year. `NextYear.csv` has predictions for the next year.

The variables other than `ForecastDate` use the following coding scheme:

- The first letter records if the prediction is for the same year(`S`) or next year (`N`). 

- In half of the cases this is followed by a (`C`) indicating that it is the ''central tendency'' of the predictions (usually created by excluding the highest and lowest 3 predictions). All other columns are for the full range of predictions.

- The next series of letters record the predicted quantity:

	- `Inflation`: Core CPE price index change
	- `GDP`: real GDP change
	- `Unem`: Civilian unemployment
	
- The final letter is either an `L` for the lower bound of the prediction or `H` for the higher bound.


### Notes

- The estimates for forecasts from the February 1988 were poorly scanned and visual approximations were made. See the file at: <http://fraser.stlouisfed.org/docs/historical/senate/cmp/1980s/CMP_100S_02241988.pdf>.

