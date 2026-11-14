# Results and Thesis Write-up: AI Impact on Computer Science Job Postings

This file lists each analysis step with its code, the output R produced, what the output means, and the wording to use in the thesis. Numbers come directly from the R output. Copy the thesis paragraphs and adjust them to your own style, but keep the numbers and the limitations.

Dataset: OG_dataset.csv, 15,000 AI and tech job postings, 1 January 2024 to 30 April 2025, 20 columns after cleaning.

---

## 1. Data cleaning

**Code (01_load_inspect.R)**
```r
colSums(is.na(jobs))              # missing values
sum(duplicated(jobs$job_id))      # duplicate IDs
sum(duplicated(jobs))             # duplicate rows
```

**Output**
- Missing values: 0 in every column
- Duplicate job IDs: 0
- Duplicate rows: 0
- Deadlines before posting date: 0
- Negative or zero salaries: 0

**Thesis wording**
> The dataset contained 15,000 postings and 19 original variables. Data cleaning found no missing values, no duplicate job IDs, and no duplicate rows. All deadlines fell after their posting dates. The application_deadline variable was removed because it was used only for validation, leaving 20 variables in the cleaned dataset. The cleaned file was saved as output/jobs_clean.csv, and the original file was not modified.

---

## 2. Data exploration

**Structure (Part A)**
```r
dim(jobs_clean)
str(jobs_clean)
```
**Output:** 15,000 rows and 20 columns. `posting_date` is a Date and `experience_level` is a factor with levels EN, MI, SE, EX.

**Category counts (Part C)**
```r
table(jobs_clean$experience_level)
round(prop.table(table(jobs_clean$experience_level)) * 100, 1)
length(unique(jobs_clean$job_title))
```
**Output:** EN 3,718 (24.8%); MI 3,781 (25.2%); SE 3,741 (24.9%); EX 3,760 (25.1%). 20 distinct job titles, 15 industries, 20 locations.

**Thesis wording**
> Postings were almost evenly split across the four experience levels: entry (24.8%), mid (25.2%), senior (24.9%), and executive (25.1%). Such an even split is unusual for real job markets, so the dataset may be sampled or synthetic, and this is discussed as a limitation.

**Date range (Part E)**
```r
range(jobs_clean$posting_date)
table(jobs_clean$posting_year)
```
**Output:** 1 January 2024 to 30 April 2025. 11,332 postings in 2024 and 3,668 in 2025.

**Thesis wording**
> Postings span January 2024 to April 2025. Most postings (11,332) fall in 2024; 2025 covers only four months (3,668 postings), so year-to-year comparisons are partial.

---

## 3. Descriptive statistics

**Code (Part D and stats table)**
```r
summary(jobs_clean$salary_usd)
sd(jobs_clean$salary_usd)
IQR(jobs_clean$salary_usd)
```

**Output: summary table**

| Variable | Mean | Median | Mode | SD | Min | Max |
|---|---|---|---|---|---|---|
| salary_usd | 115,349 | 99,705 | 51,000 and 67,253 | 60,261 | 32,519 | 399,095 |
| years_experience | 6.25 | 5 | 0 | 5.55 | 0 | 19 |
| benefits_score | 7.50 | 7.5 | 9.9 | 1.45 | 5 | 10 |
| job_description_length | 1,503 | 1,512 | 1,519 | 576 | 500 | 2,499 |

Salary quartiles: Q1 = 70,180; Q3 = 146,409; IQR = 76,229.

**Thesis wording**
> Salaries ranged from USD 32,519 to USD 399,095, with a median of USD 99,705 and a mean of USD 115,349 (SD = 60,261). The mean exceeds the median, showing a right-skewed distribution, so the median is used as the typical salary. Years of experience required ranged from 0 to 19 (median 5, mean 6.25). Benefits scores were roughly symmetric around 7.5. Job descriptions had a median length of 1,512 characters.

> Mode is reported for completeness. Salary has two tied modes (51,000 and 67,253), so it has no single most common value. The mode is a weak summary for continuous variables.

---

## 4. Outlier detection (IQR method)

**Code (Part G)**
```r
q <- quantile(jobs_clean$salary_usd, c(0.25, 0.75))
lower <- q[1] - 1.5 * IQR(jobs_clean$salary_usd)
upper <- q[2] + 1.5 * IQR(jobs_clean$salary_usd)
sum(jobs_clean$salary_usd < lower | jobs_clean$salary_usd > upper)
```
**Output:** lower fence −44,163; upper fence 260,752; 483 postings above the upper fence (3.2%); none below the lower fence.

**Thesis wording**
> Using the interquartile-range rule, 483 postings (3.2%) had salaries above USD 260,752. None fell below the lower fence. These high salaries are genuine postings and were retained; they explain why the mean is higher than the median.

---

## 5. Relationship between experience and salary

**Code (Part H)**
```r
cor(jobs_clean$salary_usd, jobs_clean$years_experience)
cor(jobs_clean$salary_usd, jobs_clean$years_experience, method = "spearman")
```
**Output:** Pearson r = 0.74; Spearman ρ = 0.79.

**Thesis wording**
> Years of experience and salary showed a strong positive association (Pearson r = 0.74; Spearman ρ = 0.79). The rank-based correlation was slightly higher, indicating that the association does not depend on the skewed high salaries. This is an association, not evidence that experience causes higher pay.

*Note: if another team member is writing the correlation section, keep these numbers in the log and cross-reference that section.*

---

## 6. Research question 1: posting trend

**Code**
```r
monthly <- jobs_clean %>%
  count(posting_year, posting_month) %>%
  arrange(posting_year, posting_month) %>%
  mutate(t = row_number())
cor.test(monthly$t, monthly$n, method = "spearman", exact = FALSE)
```

**Output:** monthly counts between 840 and 985 postings. Spearman ρ = −0.20, S = 817.2, p = .45.

**Thesis wording**
> Monthly posting volume did not change significantly over the 16 months from January 2024 to April 2025 (Spearman ρ = −0.20, n = 16, p = .45). Counts stayed between 840 and 985 per month, with a slight downward drift that is not statistically reliable. Because the dataset records postings rather than layoffs, it cannot test the layoff trend in the original research question.

**Limitation:** only 16 monthly observations, so the test has limited power to detect a small trend.

---

## 7. Research question 2: skills and salary

**Code**
```r
jobs_clean %>%
  separate_rows(required_skills, sep = ", ") %>%
  count(required_skills, sort = TRUE) %>%
  head(10)

jobs_clean <- jobs_clean %>%
  mutate(has_python = str_detect(required_skills, "Python"))

jobs_clean %>%
  group_by(has_python) %>%
  summarise(n = n(), median_salary = median(salary_usd))

wilcox.test(salary_usd ~ has_python, data = jobs_clean, exact = FALSE)
```

**Output: most requested skills**

| Skill | Postings |
|---|---|
| Python | 4,450 |
| SQL | 3,407 |
| TensorFlow | 3,022 |
| Kubernetes | 3,009 |
| Scala | 2,794 |
| PyTorch | 2,777 |
| Linux | 2,705 |
| Git | 2,631 |
| Java | 2,578 |
| GCP | 2,442 |

**Output: Python vs not**
- Requires Python: n = 4,450, median = 98,320
- Does not require Python: n = 10,550, median = 100,357
- Wilcoxon W = 23,899,633, p = .08

**Thesis wording**
> Python was the most requested skill, appearing in 4,450 postings (about 30%), followed by SQL (3,407). Postings requiring Python had a median salary of USD 98,320, compared with USD 100,357 for postings that did not. The difference was not statistically significant (Wilcoxon W = 23,899,633, p = .08). In this dataset, requiring Python is not associated with a salary premium.

**Limitation:** this compares only one skill. Testing several skills would need a correction for multiple comparisons, such as Bonferroni.

---

## 8. Research question 3: junior vs senior

**Test A: salary (Wilcoxon)**
```r
en_se <- jobs_clean %>% filter(experience_level %in% c("EN", "SE"))
wilcox.test(salary_usd ~ experience_level, data = en_se, exact = FALSE)
```
**Output:** W = 708,579, p < 2.2e-16.

**Effect size**
```r
w <- wilcox.test(salary_usd ~ experience_level, data = en_se, exact = FALSE)
n1 <- sum(en_se$experience_level == "EN")
n2 <- sum(en_se$experience_level == "SE")
mean_W <- n1 * n2 / 2
sd_W <- sqrt(n1 * n2 * (n1 + n2 + 1) / 12)
z <- (w$statistic - mean_W) / sd_W
r <- abs(z) / sqrt(n1 + n2)
r
```
**Output:** r = 0.78.

**Medians (Part F):** entry (EN) 60,374 (n = 3,718); senior (SE) 116,907 (n = 3,741).

**Test B: share by year (chi-square)**
```r
tab <- table(jobs_clean$posting_year, jobs_clean$experience_level)
chisq.test(tab)
```
**Output:** X² = 2.51, df = 3, p = .47. Entry share: 24.9% (2024), 24.4% (2025).

**Thesis wording**
> Entry-level postings paid substantially less than senior postings. The median salary was USD 60,374 for entry-level roles (n = 3,718) and USD 116,907 for senior roles (n = 3,741). A Wilcoxon rank-sum test showed this difference was statistically significant (W = 708,579, p < .001), with a large effect size (r = 0.78). In contrast, the share of entry-level postings did not change significantly between 2024 and 2025 (χ²(3) = 2.51, p = .47; 24.9% vs 24.4%). The data therefore shows a large pay gap between junior and senior roles but no measurable decline in junior postings. The 2025 data covers only four months, so this comparison is partial.

---

## 9. Research question 4: industries

**Code**
```r
tab_ind <- table(jobs_clean$industry, jobs_clean$experience_level)
chisq.test(tab_ind)
round(prop.table(tab_ind, margin = 1) * 100, 1)
```

**Output:** X² = 42.20, df = 42, p = .46. Entry-level share ranged from 22.7% (Government) to 27.6% (Gaming); overall 24.8%.

**Thesis wording**
> The experience mix did not differ significantly across the 15 industries (χ²(42) = 42.20, p = .46). Entry-level postings ranged from 22.7% (Government) to 27.6% (Gaming) of each industry's postings, close to the overall 24.8%. The data shows no industry where entry-level roles are disproportionately reduced.

**Limitation:** posting counts cannot measure vulnerability directly. A shrinking industry would show fewer postings overall, not only fewer junior ones.

---

## 10. Research question 5: location

**Code**
```r
jobs_clean %>% count(company_location, sort = TRUE) %>% head(5)
kruskal.test(salary_usd ~ company_location, data = jobs_clean)

H <- 3296.9
n <- nrow(jobs_clean)
k <- n_distinct(jobs_clean$company_location)
(H - k + 1) / (n - k)

jobs_clean %>%
  group_by(company_location) %>%
  summarise(n = n(), median_salary = median(salary_usd)) %>%
  arrange(desc(median_salary))
```

**Output:**
- Kruskal-Wallis H = 3296.9, df = 19, p < 2.2e-16
- ε² = 0.22 (large)
- Highest medians: Switzerland 152,901; Denmark 147,504; Norway 142,386; United States 128,606
- Lowest medians: Ireland 73,940; Austria 74,005; India 76,035; South Korea 76,244; China 76,543
- Each location has between 721 and 814 postings

**Thesis wording**
> Median salaries differed significantly across the 20 company locations (Kruskal-Wallis H(19) = 3296.9, p < .001, ε² = 0.22, a large effect). Switzerland (USD 152,901), Denmark (USD 147,504), and Norway (USD 142,386) had the highest medians, while Ireland (USD 73,940), Austria (USD 74,005), and India (USD 76,035) had the lowest. The test shows that differences exist across locations, but not which specific pairs differ.

**Limitation:** the salaries are in USD as reported. The currency conversion was not verified, so part of the location gap may reflect how the data was converted.

---

## 11. Summary of results

| Research question | Test | Result | Significant? |
|---|---|---|---|
| Q1: posting trend | Spearman | ρ = −0.20, p = .45 | No |
| Q2: skills and salary (Python) | Wilcoxon | p = .08 | No |
| Q3: junior vs senior salary | Wilcoxon | r = 0.78, p < .001 | Yes, large |
| Q3: entry share by year | Chi-square | p = .47 | No |
| Q4: industries | Chi-square | p = .46 | No |
| Q5: location and salary | Kruskal-Wallis | ε² = 0.22, p < .001 | Yes, large |

## 11a. Number of tests

**Inferential tests (6), one per research question:**

1. Wilcoxon rank-sum: entry vs senior salary (Q3). Significant (p < .001).
2. Chi-square: experience level by year (Q3). Not significant (p = .47).
3. Wilcoxon rank-sum: Python vs not, salary (Q2). Not significant (p = .08).
4. Chi-square: industry by experience level (Q4). Not significant (p = .46).
5. Kruskal-Wallis: salary across 20 locations (Q5). Significant (p < .001).
6. Spearman correlation: monthly postings over time (Q1). Not significant (p = .45).

**Effect sizes (calculated after the tests):**
- r = 0.78 for the Q3 salary test
- ε² = 0.22 for the Q5 location test

**Descriptive correlation checks (reported in the exploration section, not counted as research-question tests):**
- Pearson r = 0.74 and Spearman ρ = 0.79 for salary and years of experience

Of the six research-question tests, two are significant (Q3 salary, Q5 location) and four are not (Q1, Q2, Q3 share, Q4).

## 12. What not to claim

- Do not claim that junior postings are declining. The share test found no change.
- Do not claim that AI caused any change in salaries or postings. The data shows associations at one point in time.
- Do not claim layoff trends. The dataset has no layoff data.
- Do not claim the salary gap by location is exact. The currency conversion is unverified.
- Do not claim that the dataset represents the real job market. The even category counts suggest it may be sampled or synthetic.
