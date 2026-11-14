# ==========================================================================
# 03_statistical_tests.R
# Statistical tests for the five research questions on AI and CS job postings.
# Input:  output/jobs_clean.csv (created by 01_load_inspect.R)
# Run from top to bottom, with the AI_CS_Jobs_Research project open.
# ==========================================================================


# --------------------------------------------------------------------------
# SETUP
# Load packages and read the cleaned data.
# --------------------------------------------------------------------------
library(tidyverse)
jobs_clean <- read.csv("output/jobs_clean.csv")


# ==========================================================================
# RESEARCH QUESTION 3: Are junior developers more affected than senior ones?
# Two tests: salary (Wilcoxon) and entry-level share by year (chi-square).
# ==========================================================================

# --- Q3, Test 1: salary, entry (EN) vs senior (SE) ---
# Keep only entry-level and senior postings
en_se <- jobs_clean %>% filter(experience_level %in% c("EN", "SE"))

# Group sizes and median salary for each group
en_se %>%
  group_by(experience_level) %>%
  summarise(n = n(), median_salary = median(salary_usd))

# Wilcoxon rank-sum test: do EN and SE salaries differ?
wilcox.test(salary_usd ~ experience_level, data = en_se, exact = FALSE)

# Effect size r, first attempt (superseded by the block below).
# qnorm() of a p-value that underflows to 0 returns -Inf, so this prints Inf.
w <- wilcox.test(salary_usd ~ experience_level, data = en_se, exact = FALSE)
z <- qnorm(w$p.value / 2)
r <- abs(z) / sqrt(nrow(en_se))
r

# Effect size r, correct method: calculated from the W statistic
# Use this value for the report.
w <- wilcox.test(salary_usd ~ experience_level, data = en_se, exact = FALSE)
n1 <- sum(en_se$experience_level == "EN")   # number of entry-level postings
n2 <- sum(en_se$experience_level == "SE")   # number of senior postings
mean_W <- n1 * n2 / 2                       # expected W if there were no difference
sd_W <- sqrt(n1 * n2 * (n1 + n2 + 1) / 12)  # spread of W if there were no difference
z <- (w$statistic - mean_W) / sd_W          # Z-score of the observed W
r <- abs(z) / sqrt(n1 + n2)                 # effect size r = |Z| / sqrt(N)
r

# --- Q3, Test 2: entry-level share by posting year ---
# Chi-square test of independence on counts of postings
tab <- table(jobs_clean$posting_year, jobs_clean$experience_level)
chisq.test(tab)


# ==========================================================================
# RESEARCH QUESTION 2: Do required skills relate to salary?
# Descriptive count of skills, then a Wilcoxon test on Python vs not.
# ==========================================================================

# --- Q2, Step 1: most requested skills (descriptive) ---
# Each posting lists several skills, so split them into one row per skill
skills_long <- jobs_clean %>%
  separate_rows(required_skills, sep = ", ")

skills_long %>%
  count(required_skills, sort = TRUE) %>%
  head(10)

# --- Q2, Test: salary, postings that require Python vs not ---
# Each posting falls in exactly one group, so no posting is counted twice.

# Flag postings whose skills include Python
jobs_clean <- jobs_clean %>%
  mutate(has_python = str_detect(required_skills, "Python"))

# Count and median salary for each group
jobs_clean %>%
  group_by(has_python) %>%
  summarise(n = n(), median_salary = median(salary_usd))

# Wilcoxon rank-sum test: does salary differ between the two groups?
wilcox.test(salary_usd ~ has_python, data = jobs_clean, exact = FALSE)


# ==========================================================================
# RESEARCH QUESTION 5: Does salary differ by company location?
# Kruskal-Wallis test across all locations, plus epsilon-squared.
# ==========================================================================

# --- Q5, Step 1: five locations with the most postings (descriptive) ---
jobs_clean %>%
  count(company_location, sort = TRUE) %>%
  head(5)

# --- Q5, Test: salary across all company locations ---
# Kruskal-Wallis rank-sum test: more than two groups, skewed data
kruskal.test(salary_usd ~ company_location, data = jobs_clean)

# --- Q5, Effect size: epsilon-squared ---
# H is the Kruskal-Wallis statistic from the test above, entered by hand
H <- 3296.9
n <- nrow(jobs_clean)                 # total number of postings
k <- n_distinct(jobs_clean$company_location)  # number of locations (groups)
eps2 <- (H - k + 1) / (n - k)         # epsilon-squared effect size
eps2

# --- Q5, Step 2: median salary by location (descriptive) ---
# Shows which countries pay more or less
jobs_clean %>%
  group_by(company_location) %>%
  summarise(n = n(), median_salary = median(salary_usd)) %>%
  arrange(desc(median_salary))


# ==========================================================================
# RESEARCH QUESTION 4: Do industries differ in their experience mix?
# Chi-square test of industry by experience level, plus row percentages.
# ==========================================================================

# Table of industry by experience level
tab_ind <- table(jobs_clean$industry, jobs_clean$experience_level)

# Chi-square test: does the experience mix differ by industry?
chisq.test(tab_ind)

# Share of each experience level within each industry (row percentages)
round(prop.table(tab_ind, margin = 1) * 100, 1)


# ==========================================================================
# RESEARCH QUESTION 1: Does the number of postings change over time?
# Spearman correlation between month order (1 to 16) and monthly count.
# ==========================================================================

# Monthly counts in time order, with t = 1 for the first month
monthly <- jobs_clean %>%
  count(posting_year, posting_month) %>%
  arrange(posting_year, posting_month) %>%
  mutate(t = row_number())

monthly

# Spearman correlation: does the monthly count change with time?
cor.test(monthly$t, monthly$n, method = "spearman", exact = FALSE)


# ==========================================================================
# DESCRIPTIVE STATISTICS (supports the report, not a research question)
# Mean, median, mode, SD, min, and max for the key numeric variables.
# ==========================================================================

# Mode function: returns the most frequent value(s) in a vector
get_mode <- function(x) {
  freq <- table(x)
  as.numeric(names(freq)[freq == max(freq)])
}

# Put the four variables in a list, so the table is built one row per variable
vars <- list(
  salary_usd             = jobs_clean$salary_usd,
  years_experience       = jobs_clean$years_experience,
  benefits_score         = jobs_clean$benefits_score,
  job_description_length = jobs_clean$job_description_length
)

# One row per variable; tied modes are joined with commas
stats_table <- data.frame(
  variable  = names(vars),
  mean      = sapply(vars, mean),
  median    = sapply(vars, median),
  mode      = sapply(vars, function(x) paste(get_mode(x), collapse = ", ")),
  sd        = sapply(vars, sd),
  min       = sapply(vars, min),
  max       = sapply(vars, max),
  row.names = NULL
)

stats_table
