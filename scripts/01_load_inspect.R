library(tidyverse)
jobs <- read_csv("data/OG_dataset.csv")
gecolSums(is.na(jobs))
sum(duplicated(jobs$job_id))
sum(duplicated(jobs))
#date conversion to real date and not a text
jobs <- jobs %>% mutate(posting_date = as.Date(posting_date))
range(jobs$posting_date)
class(jobs$posting_date)
#convert the deadline column
jobs <- jobs %>% mutate(application_deadline = as.Date(application_deadline))
range(jobs$application_deadline)
class(jobs$application_deadline)
sum(jobs$application_deadline < jobs$posting_date)
summary(jobs$salary_usd)
summary(jobs$years_experience)
summary(jobs$benefits_score)
summary(jobs$job_description_length)

table(jobs$experience_level)
table(jobs$employment_type)
table(jobs$company_size)
table(jobs$remote_ratio)
table(jobs$education_required)
table(jobs$salary_currency)

jobs %>% group_by(salary_currency) %>% summarise(median_salary = median(salary_usd))
jobs <- jobs %>% mutate(posting_year = year(posting_date), posting_month = month(posting_date))
table(jobs$posting_year)
table(jobs$posting_month)


jobs <- jobs %>% select(-application_deadline)

write_csv(jobs, "output/jobs_clean.csv")
dim(jobs)
list.files("output")

names(jobs)
ncol(jobs)
dim(jobs)


