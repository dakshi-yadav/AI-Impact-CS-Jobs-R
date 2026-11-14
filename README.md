# AI Impact on Computer Science Job Postings

An R analysis of 15,000 AI and tech job postings (January 2024 to April 2025). It examines how experience, employment type, company size, remote work, industry, job title, education and location relate to salary, and whether postings changed over time.

## Research questions

| # | Question | Test |
|---|----------|------|
| Q1 | Does monthly posting volume change over time? | Spearman correlation |
| Q2 | Is requiring Python linked to salary? | Wilcoxon rank-sum |
| Q3 | Are junior roles paid less, and is their share changing? | Wilcoxon rank-sum and chi-square |
| Q4 | Does the experience mix differ across industries? | Chi-square |
| Q5 | Is job location linked to salary? | Kruskal-Wallis |

## Dataset

- **Source:** Kaggle, [Global AI Job Market and Salary Trends 2025](https://www.kaggle.com/datasets/bismasajjad/global-ai-job-market-and-salary-trends-2025) (accessed September 2026)
- **Size:** 15,000 postings, 19 original variables, 20 after cleaning
- **Missing values:** none. **Duplicate rows:** none.
- Salaries are used as reported in USD. Currency conversion was not done.

## Methodologies

1. **Cleaning** (`scripts/01_load_inspect.R`): checks for missing values and duplicates, converts dates, adds posting year and month, and saves `data/jobs_clean.csv`.
2. **Exploration** (`scripts/02_data_exploration.R`): counts, medians and outliers (1.5 × IQR rule).
3. **Visualisation** (`scripts/04_data_visualisation.R`): ggplot2 charts.
4. **Statistical tests** (`scripts/03_statistical_tests.R`): Wilcoxon rank-sum, chi-square, Kruskal-Wallis, Spearman and Pearson correlation, and effect sizes (r and ε²). Significance level α = 0.05. Salaries are skewed, so rank-based tests are used.
5. **Comparative analysis** (`scripts/05_comparitive_analysis.R`): average salary by experience, employment type, company size, remote work type, industry, job title and education, saved as CSV files and bar charts.

## Results

- **Q1:** No significant trend in monthly postings (ρ = −0.20, p = .45).
- **Q2:** No significant salary difference for jobs requiring Python (p = .08).
- **Q3:** Junior roles are paid much less (median 60,374 vs 116,907 USD, r = 0.78, p < .001). The entry-level share did not change significantly between 2024 and 2025 (χ²(3) = 2.51, p = .47).
- **Q4:** The experience mix does not differ significantly across industries (χ²(42) = 42.20, p = .46).
- **Q5:** Salary differs significantly across locations (H = 3296.9, p < .001, ε² = 0.22, a large effect).
- **Experience and salary:** strong positive link (Spearman ρ = 0.79, Pearson r = 0.74).

## Limitations

- Category counts are almost equal, so the data may be sampled or synthetic.
- 2025 covers only January to April, so year comparisons are partial.
- The dataset contains job postings, not layoffs, so layoff trends cannot be tested.
- Salaries are not converted to a common currency.
- Only one skill (Python) was tested for salary.
- Results show associations, not causes.

## Future goals

- Extend the literature review in the final report.
- Convert salaries to a common currency before comparing locations.
- Test additional skills using a multiple-comparison correction, such as the Holm method.

## Project structure

```
AI-Impact-CS-Jobs-R/
├── README.md
├── AI_CS_Jobs_Research.Rproj
├── data/              OG_dataset.csv, jobs_clean.csv
├── scripts/           01 to 05 R scripts (run in order)
├── output/
│   ├── Analysis_Results/   summary CSV files
│   └── Graphs/             chart PNG files
└── docs/              presentation, written report, notes
```

## How to run

1. Open `AI_CS_Jobs_Research.Rproj` in RStudio, so the working directory is the project root.
2. Run the scripts in order: `01_load_inspect.R`, `02_data_exploration.R`, `04_data_visualisation.R`, `03_statistical_tests.R`, `05_comparitive_analysis.R`.
3. Packages: `tidyverse` (dplyr, readr, tidyr), `ggplot2` and `scales` for the first four scripts. The comparative analysis uses base R only.

## Author

[Add team member names] · Supervisor: [Add name] · MCA, Indira Gandhi Delhi Technical University for Women
