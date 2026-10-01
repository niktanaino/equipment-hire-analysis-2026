# equipment-hire-analysis-2026
SQL analysis of synthetic equipment hire data to find depots with missing off-hires and late collections

Equipment Hire Analysis: Missing Off-Hires and Late Collections

**Question:** Which depots and equipment categories have the most missing off-hires and late collections?

## Why it matters
A missing off-hire means equipment may still be charged to a customer, or nobody knows where it is. A late collection means equipment sits idle when it could be hired out again. Both cost the business money.

## Data
- Synthetic dataset of **800 equipment hires** across **10 UK depots**, Oct 2025 to Sep 2026.
- Modelled on equipment hire operations. **No real company data was used.**
- Columns: contract number, customer, equipment type and category, depot, hire start, expected off-hire, off-hire logged, collected date, daily rate, days on hire, damage charge.

## Tools
SQL (Google BigQuery), Power BI

## Method
1. **Cleaned** the raw data (see below) into a new `hire_clean` table, leaving the raw table untouched.
2. **Defined the measures:**
   - *Missing off-hire:* no off-hire date logged.
   - *Late collection:* collected more than 3 days after the off-hire was logged.
3. **Calculated rates per depot and per equipment category.** Rates are used instead of raw counts so busy depots aren't unfairly penalised.
4. **Visualised** the results in Power BI.

### Data cleaning
- Removed 8 duplicate rows (808 to 800)
- Standardised depot name capitals (e.g. "LEEDS" to "Leeds")
- Trimmed extra spaces from customer names
- Labelled 6 blank customers as "Unknown"
- Kept blank off-hire and collection dates, because they are the findings

## Findings
Across all 800 hires,43 came back with no off hire logged wich is **5.4%** and **7.2%** were collected late.

| Measure | Worst depot | Rate | Company average |
|---|---|---|---|
| Late collections | Leeds (15 of 83 hires) | 18.1% | 7.2% |
| Missing off-hires | Cardiff (6 of 61 hires) | 9.8% | 5.4% |

- **Leeds** has a late-collection rate about 2.5 times the average.
- **Cardiff and Bristol** have the highest missing off-hire rates (9.8% and 9.6%), nearly double the average. Cardiff also ranks second for late collections (11.5%).
- **Clamps & Trolleys** have the highest late-collection rate by category (9.6%).
- **Slings & Rigging** have the most missing off-hires by count (22), as they make up the largest share of hires.
- 23 hires have no collection date at all.

## Recommendations
1. Review collection scheduling at Leeds.
2. Check how off-hires are logged at Cardiff and Bristol.
3. Run a weekly exception report of any off-hire with no collection date after 3 days.

## Limitations
- The data is synthetic, so the findings show the method, not real business results.
- Some groups are small (e.g. 37 testing-equipment hires), so their percentages can swing a lot.
- "Late" is defined as more than 3 days after off-hire. A different threshold would change the results.

## Files
| File | What it is |
|---|---|
| `synthetic_equipment_hire_data.csv` | Raw synthetic dataset |
| `analysis.sql` | Cleaning and analysis queries |
| `dashboard.png` | Power BI dashboard screenshot |
| `equipment_hire_dashboard.pbix` | Power BI file |
