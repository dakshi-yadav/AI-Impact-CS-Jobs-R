# AI Impact on Computer Science Jobs

R project for the IT Workshop (MCA, IGDTUW). It studies job postings in the AI/tech field, using the Kaggle dataset "OG_dataset.csv" (15,000 postings, January 2024 to April 2025).

## Folder structure

```
AI_CS_Jobs_Research/
├── AI_CS_Jobs_Research.Rproj   (open this file in RStudio)
├── data/                       raw data, never edited
│   └── OG_dataset.csv
├── scripts/                    R code
│   └── 01_load_inspect.R
├── output/                     cleaned data and charts
└── docs/                       cleaning log and notes
```

## How to run

1. Open `AI_CS_Jobs_Research.Rproj` in RStudio.
2. Install the package once: `install.packages("tidyverse")`
3. Open `scripts/01_load_inspect.R` and run it from top to bottom (Ctrl+Alt+R runs the whole file).

The script reads the file with the relative path `data/OG_dataset.csv`, so the project must keep this folder layout.

## What the script does

1. Loads the libraries (`tidyverse`).
2. Reads `data/OG_dataset.csv` into an object called `jobs`. The raw file is not modified.
3. Checks for missing values, duplicate IDs, and duplicate rows.
4. Converts `posting_date` and `application_deadline` to dates.
5. Checks that no deadline falls before its posting date.
6. Checks the numeric ranges (salary, years of experience, benefits score, description length).
7. Checks the category values in each categorical column.
8. Compares median salary by currency.
9. Creates `posting_year` and `posting_month` from `posting_date`.
10. Removes `application_deadline` (used only for validation).
11. Saves the cleaned data to `output/jobs_clean.csv`.

## Cleaning results

| Check | Result |
|---|---|
| Rows / columns loaded | 15,000 / 19 |
| Missing values | 0 in every column |
| Duplicate job_id | 0 |
| Fully duplicate rows | 0 |
| Deadline before posting date | 0 |
| Numeric ranges | Pass (salary 32,519 to 399,095; experience 0 to 19; benefits 5 to 10; description 500 to 2,499) |
| Category values | Pass (4, 4, 3, 3, 4, 3 distinct values; no spelling variants) |
| Columns after cleaning | 20 (added 2, removed 1) |

## Decisions and limitations

- **Currency:** `salary_usd` is used as provided. Median salaries are USD 96,951, EUR 107,140, and GBP 115,281. The conversion to USD was not verified against exchange rates.
- **employee_residence** is kept because it differs from `company_location` in 4,256 of 15,000 rows.
- **application_deadline** is removed because it is used only for validation.
- **posting_month** mixes both years (January to April appear twice). Group by year and month together when analysing trends.
- **Dataset scope:** the dataset contains job postings, not layoffs. Questions about layoffs cannot be answered with this file alone.
- **Even distributions:** counts per category are very close to equal, so the dataset may be synthetic or sampled. This should be stated as a limitation.

## Team

| Role | Owner |
|---|---|
| Data lead | |
| Cleaning lead | |
| Research questions and literature | |
| Analysis lead | |
| Presentation and writing | |
