# 02_data_exploration.R

Exploratory data analysis (EDA) of the cleaned job postings dataset. This script reads the cleaned file produced by `01_load_inspect.R` and describes it before any statistical testing.

## Requirements

- R with the `tidyverse` package (`install.packages("tidyverse")` once)
- The RStudio project `AI_CS_Jobs_Research.Rproj` must be open, so the relative paths work
- `output/jobs_clean.csv` must exist (run `01_load_inspect.R` first)

## How to run

1. Open `AI_CS_Jobs_Research.Rproj` in RStudio.
2. Run `01_load_inspect.R` from top to bottom, so `output/jobs_clean.csv` exists.
3. Open `scripts/02_data_exploration.R`.
4. Run the whole script with **Ctrl+Alt+R**, or run it part by part with **Ctrl+Enter**.

The script reads from `output/` and never modifies the original file in `data/`.

## What the script does

| Part | Purpose | Main commands |
|---|---|---|
| Setup | Load the cleaned data, convert dates, set experience-level order | `read.csv`, `as.Date`, `factor` |
| A | Check structure | `head`, `tail`, `colnames`, `str` |
| B | Check data quality | `colSums(is.na())`, `duplicated` |
| C | Count categories | `table`, `prop.table`, `unique` |
| D | Summarise numeric variables | `summary`, `sd`, `IQR`, `range` |
| E | Check the date range and monthly counts | `range`, `table` |
| F | Compare groups | `group_by`, `summarise`, `prop.table` |
| G | Detect outliers (IQR method) | `quantile`, `IQR` |
| H | Measure salary–experience relationship | `cor` (Pearson and Spearman) |
| I | Findings log | comments |

## Key results

| Check | Result |
|---|---|
| Rows and columns | 15,000 rows, 20 columns |
| Missing values | 0 in every column |
| Duplicate job IDs / rows | 0 / 0 |
| Experience levels | EN 3,718; MI 3,781; SE 3,741; EX 3,760 (each about 25%) |
| Distinct job titles / industries / locations | 20 / 15 / 20 |
| Salary (USD) | Median 99,705; mean 115,349; range 32,519 to 399,095 |
| Salary quartiles | Q1 70,180; Q3 146,409 |
| Median salary by experience | EN 60,374; MI 84,641; SE 116,907; EX 177,512 |
| Median salary by company size | Large 114,564; Medium 98,122; Small 89,648 |
| Entry-level share by year | 24.9% (2024) and 24.4% (2025) |
| Postings by year | 2024: 11,332; 2025: 3,668 |
| Date range | 1 January 2024 to 30 April 2025 |
| Salary outliers (IQR fences) | 483 above 260,752; none below −44,163 |
| Experience vs salary | Pearson r = 0.74; Spearman ρ = 0.79 |

## Interpretation notes

- Salary is right-skewed, so the median is used as the typical salary.
- Entry-level share barely changes between years. This is not evidence of a decline in junior postings.
- Monthly postings are flat (about 840 to 985 per month), so the data shows no strong posting trend.
- 2025 covers only January to April, so year-to-year comparisons are partial.
- Experience and salary are associated, not causally linked.

## Limitations

- Results are descriptive. No significance tests have been run yet.
- Category counts are nearly equal, which suggests the dataset may be sampled or generated. State this in the report.
- The dataset contains job postings, not layoffs, so it cannot answer questions about layoffs.
- Salary is used as reported. The EUR and GBP conversion to USD was not verified.

## Saving console output

The Console is not saved automatically. To keep a record, add `sink("docs/exploration_output.txt", split = TRUE)` at the top of the script and `sink()` at the end. Output is then written to `docs/exploration_output.txt`.

## Files this script uses or creates

- Reads: `output/jobs_clean.csv`
- Creates: `docs/exploration_output.txt` (only if the `sink()` lines are used)
