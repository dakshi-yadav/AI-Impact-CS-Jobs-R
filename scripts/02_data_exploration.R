library(tidyverse)
jobs_clean <- read.csv("output/jobs_clean.csv")
jobs_clean$posting_date <- as.Date(jobs_clean$posting_date)
# Turns the experience codes into a factor with a fixed order: EN, MI, SE, EX. 
# This makes tables and charts list the levels from entry to executive, 
# instead of alphabetically (EN, EX, MI, SE).
# A factor is R’s way of storing a category with a set order.
jobs_clean$experience_level <- factor(jobs_clean$experience_level,
                                      levels = c("EN", "MI", "SE", "EX"))
dim(jobs_clean)


# Part A: Structure of the dataset
head(jobs_clean)            # first 6 rows
tail(jobs_clean)            # last 6 rows
colnames(jobs_clean)        # column names
str(jobs_clean)             # column types and sample values

# Part B: Data quality check on the saved file
colSums(is.na(jobs_clean))          # missing values per column
sum(duplicated(jobs_clean$job_id))  # duplicate job IDs
sum(duplicated(jobs_clean))         # fully duplicate rows
# Part C: Categories
# experience levels EN, MI, SE, EX; 
# employment types CT, FL, FT, PT; 
# company sizes L, M, S; 
# remote ratios 0, 50, 100; 
# four education levels; 
# currencies EUR, GBP, USD.

table(jobs_clean$experience_level)      # counts per experience level
table(jobs_clean$employment_type)       # counts per employment type
table(jobs_clean$company_size)          # counts per company size
table(jobs_clean$remote_ratio)          # counts per remote ratio
table(jobs_clean$education_required)    # counts per education level
table(jobs_clean$salary_currency)       # counts per currency

round(prop.table(table(jobs_clean$experience_level)) * 100, 1)  # percent per level
# prop.table() divides each count by the total, giving a share between 0 and 1.

length(unique(jobs_clean$job_title))    # number of distinct job titles
length(unique(jobs_clean$industry))     # number of distinct industries
length(unique(jobs_clean$company_location))  # number of distinct locations

# Part D: Numeric variables
summary(jobs_clean$salary_usd)            # min, quartiles, mean, median, max
summary(jobs_clean$years_experience)
summary(jobs_clean$benefits_score)
summary(jobs_clean$job_description_length)

sd(jobs_clean$salary_usd)                 # spread around the mean(Standard deviation)
IQR(jobs_clean$salary_usd)                # middle 50% range (Q3 minus Q1) (basis for outlier detection)
range(jobs_clean$salary_usd)              # lowest and highest salary


# Part E: Dates and time
range(jobs_clean$posting_date)                    # earliest and latest posting dates
table(jobs_clean$posting_year)                    # postings per year
table(jobs_clean$posting_year, jobs_clean$posting_month)  # postings per month, by year

# Part F: Comparing groups
jobs_clean %>%
  group_by(experience_level) %>%
  summarise(n = n(), median_salary = median(salary_usd), mean_salary = mean(salary_usd))  # salary by experience level

jobs_clean %>%
  group_by(employment_type) %>%
  summarise(n = n(), median_salary = median(salary_usd))  # salary by employment type

jobs_clean %>%
  group_by(company_size) %>%
  summarise(n = n(), median_salary = median(salary_usd))  # salary by company size

round(prop.table(table(jobs_clean$posting_year, jobs_clean$experience_level), margin = 1) * 100, 1)  # experience share within each year

# Part G: Outliers (IQR method)
q <- quantile(jobs_clean$salary_usd, c(0.25, 0.75))   # Q1 and Q3
lower <- q[1] - 1.5 * IQR(jobs_clean$salary_usd)      # lower fence
upper <- q[2] + 1.5 * IQR(jobs_clean$salary_usd)      # upper fence
lower                                                 # show lower fence
upper                                                 # show upper fence
sum(jobs_clean$salary_usd < lower | jobs_clean$salary_usd > upper)  # count of outliers
quantile(jobs_clean$salary_usd, c(0.25, 0.5, 0.75))

# Part H: Relationship between salary and experience
cor(jobs_clean$salary_usd, jobs_clean$years_experience)   # correlation coefficient (-1 to 1)
cor(jobs_clean$salary_usd, jobs_clean$years_experience, method = "spearman")

# Part I: Exploration findings log
# Part A (structure):   15,000 rows, 20 columns; posting_date is Date, experience_level is Factor
# Part B (quality):     0 missing values in all columns; 0 duplicate IDs; 0 duplicate rows
# Part C (categories):  experience EN 3,718 / MI 3,781 / SE 3,741 / EX 3,760 (about 25% each);
#                       20 job titles; 15 industries; 20 locations
# Part D (numeric):     salary median 99,705, mean 115,349, right-skewed; years experience 0-19
# Part E (dates):       postings Jan 2024 to Apr 2025; 2024 = 11,332 and 2025 = 3,668
# Part F (groups):      median salary EN 60,374 < MI 84,641 < SE 116,907 < EX 177,512
# Part G (outliers):    483 salaries above 260,752; none below -44,163
# Part H (relation):    experience vs salary: Pearson 0.74, Spearman 0.79
