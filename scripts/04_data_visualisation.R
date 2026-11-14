jobs <- read.csv(file.choose())
dim(jobs)
names(jobs)
str(jobs)
library(ggplot2)
# GRAPH 1: Job Postings by Experience Level

# Count jobs for each experience level
experience_counts <- as.data.frame(
  table(jobs$experience_level)
)

# Rename columns
colnames(experience_counts) <- c(
  "experience_level",
  "job_count"
)

# Create bar chart
graph1 <- ggplot(
  experience_counts,
  aes(x = experience_level,
      y = job_count,
      fill = experience_level)
) +
  geom_col() +
  labs(
    title = "Job Postings by Experience Level",
    x = "Experience Level",
    y = "Number of Job Postings"
  ) +
  theme_minimal() +
  guides(fill = "none")

# Display graph
print(graph1)

# GRAPH 2: Salary Distribution

graph2 <- ggplot(jobs, aes(x = salary_usd)) +
  geom_histogram(
    bins = 30,
    fill = "steelblue",
    color = "white"
  ) +
  labs(
    title = "Salary Distribution of Job Postings",
    x = "Salary (USD)",
    y = "Number of Job Postings"
  ) +
  scale_x_continuous(
    labels = scales::label_comma()
  ) +
  theme_minimal()

# Display graph
print(graph2)
# ==================================
# GRAPH 3: Salary by Experience Level
# ==================================

graph3 <- ggplot(
  jobs,
  aes(
    x = factor(
      experience_level,
      levels = c("EN", "MI", "SE", "EX")
    ),
    y = salary_usd,
    fill = experience_level
  )
) +
  geom_boxplot(
    outlier.alpha = 0.3,
    na.rm = TRUE
  ) +
  scale_x_discrete(
    labels = c(
      "EN" = "Entry Level",
      "MI" = "Mid Level",
      "SE" = "Senior Level",
      "EX" = "Executive Level"
    )
  ) +
  scale_y_continuous(
    labels = scales::label_comma()
  ) +
  labs(
    title = "Salary Comparison by Experience Level",
    x = "Experience Level",
    y = "Annual Salary (USD)"
  ) +
  theme_minimal() +
  guides(fill = "none")

# Display graph
print(graph3)

# ==================================
# GRAPH 4: Job Posting Trends Over Time
# ==================================

# Convert posting_date into Date format
jobs$posting_date <- as.Date(
  jobs$posting_date,
  format = "%Y-%m-%d"
)

# Check date range
range(jobs$posting_date, na.rm = TRUE)

# Count job postings month-wise
monthly_jobs <- aggregate(
  job_id ~ format(posting_date, "%Y-%m"),
  data = jobs,
  FUN = length
)

# Rename columns
colnames(monthly_jobs) <- c("month", "job_count")

# Convert month into Date format
monthly_jobs$month <- as.Date(
  paste0(monthly_jobs$month, "-01")
)

# Create line chart
graph4 <- ggplot(
  monthly_jobs,
  aes(x = month, y = job_count)
) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_point(color = "darkblue", size = 2) +
  scale_x_date(date_labels = "%b %Y", date_breaks = "2 months") +
  labs(
    title = "Monthly Job Posting Trends",
    x = "Month",
    y = "Number of Job Postings"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

# Display graph
print(graph4)

# ==================================
# GRAPH 5: Top 10 Most Demanded Skills
# ==================================

# Split skills from each job posting
skill_list <- unlist(
  strsplit(as.character(jobs$required_skills), ",")
)

# Remove extra spaces
skill_list <- trimws(skill_list)

# Remove missing and empty values
skill_list <- skill_list[
  !is.na(skill_list) & skill_list != ""
]

# Count frequency of each skill
skill_counts <- sort(
  table(skill_list),
  decreasing = TRUE
)

# Select top 10 skills
top_skills <- head(
  as.data.frame(skill_counts),
  10
)

# Rename columns
colnames(top_skills) <- c("skill", "job_count")

# Display results
print(top_skills)

# Create Top 10 Skills Bar Chart

graph5 <- ggplot(
  top_skills,
  aes(
    x = reorder(skill, job_count),
    y = job_count
  )
) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Top 10 Most Demanded Skills",
    x = "Technical Skills",
    y = "Number of Job Postings"
  ) +
  theme_minimal()

# Display graph
print(graph5)

library(dplyr)
library(ggplot2)

location_salary <- jobs %>%
  group_by(company_location) %>%
  summarise(
    median_salary = median(salary_usd, na.rm = TRUE),
    job_count = n()
  ) %>%
  filter(job_count >= 50) %>%
  arrange(desc(median_salary)) %>%
  slice_head(n = 10)

graph6 <- ggplot(
  location_salary,
  aes(
    x = reorder(company_location, median_salary),
    y = median_salary
  )
) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  scale_y_continuous(labels = scales::label_comma()) +
  labs(
    title = "Top 10 Locations by Median Salary",
    x = "Company Location",
    y = "Median Salary (USD)"
  ) +
  theme_minimal()

print(graph6)