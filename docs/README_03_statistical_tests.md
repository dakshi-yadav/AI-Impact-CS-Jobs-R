# 03_statistical_tests.R

Statistical tests for the five research questions on AI and computer science job postings. Each test answers one research question. Results and thesis wording are in `Results_and_Thesis_Writeup.md`.

## Requirements

- R with `tidyverse` (`install.packages("tidyverse")` once)
- The RStudio project `AI_CS_Jobs_Research.Rproj` open, so relative paths work
- `output/jobs_clean.csv` must exist (run `01_load_inspect.R` first)

## How to run

1. Open `AI_CS_Jobs_Research.Rproj` in RStudio.
2. Run `01_load_inspect.R` from top to bottom, so the cleaned file exists.
3. Open `scripts/03_statistical_tests.R`.
4. Run the whole script with **Ctrl+Alt+R**, or part by part with **Ctrl+Enter**.

The script reads `output/jobs_clean.csv` and does not change any file.

## Tests and the research question each one answers

| Research question | Test | R function | Why this test |
|---|---|---|---|
| Q3: Are junior developers more affected? (salary) | Wilcoxon rank-sum, EN vs SE | `wilcox.test()` | Salaries are skewed, so a rank-based test is used |
| Q3: Is the entry-level share changing? | Chi-square, experience by year | `chisq.test()` | Counts of postings in categories |
| Q2: Do skills relate to salary? | Wilcoxon, Python vs not | `wilcox.test()` | Two independent groups of postings |
| Q4: Do industries differ in experience mix? | Chi-square, industry by experience | `chisq.test()` | Counts in categories |
| Q5: Does location relate to salary? | Kruskal-Wallis across locations | `kruskal.test()` | More than two groups, skewed data |
| Q1: Does monthly posting volume trend? | Spearman correlation, month order vs count | `cor.test(method = "spearman")` | Only 16 monthly points, so a rank test |

## Effect sizes

- Wilcoxon: r = |Z| / √N. Z is calculated from the W statistic (the p-value can underflow to 0).
- Kruskal-Wallis: epsilon-squared = (H − k + 1) / (n − k).
- Interpretation: r or ε² of about 0.1 is small, 0.3 medium, 0.5 or more large. For ε², 0.01 is small, 0.06 medium, 0.14 or more large.

## Decisions made

- `exact = FALSE` is used in the Wilcoxon and Spearman tests to avoid warnings with large samples.
- Salary is analysed as reported in USD. The EUR and GBP conversion was not verified.
- Each posting belongs to one group in every test, except the skills test, which uses one skill (Python) to avoid counting postings more than once.
- Outliers are kept in all tests.
- Results are reported as associations, not causes.

## Limitations

- Q1: the dataset covers only 16 months, and the monthly counts are close together, so the test has limited power.
- Q3 share test: 2025 covers only January to April, so this test is partial.
- Q2: only one skill is tested. Testing more skills would require a correction for multiple comparisons.
- The data contains job postings, not layoffs, so layoff trends cannot be tested.
- Category counts are nearly equal, which suggests the data may be sampled or generated. State this in the report.

## Files this script uses or creates

- Reads: `output/jobs_clean.csv`
- Creates: nothing by default. To keep results, use `sink("docs/statistical_output.txt", split = TRUE)` at the top and `sink()` at the end.
