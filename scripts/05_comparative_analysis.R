# ==========================================================
# 05 COMPARATIVE ANALYSIS
# Average salary (USD) across groups, from the cleaned dataset.
#
# Run from the project root folder (AI_CS_Jobs_Research), so the
# relative paths below resolve correctly. Open the .Rproj file in
# RStudio, or call setwd() to the project root before sourcing.
#
# Input : data/jobs_clean.csv        (created by 01_load_inspect.R)
# Output: output/Analysis_Results/   (summary CSV files)
#         output/Graphs/             (bar chart PNG files)
# ==========================================================

# 1. Import the cleaned dataset
data <- read.csv("data/jobs_clean.csv")

# 2. Create output folders if they do not exist
dir.create("output/Analysis_Results", recursive = TRUE, showWarnings = FALSE)
dir.create("output/Graphs", recursive = TRUE, showWarnings = FALSE)

# Helper: draw a vertical bar chart and save it as a PNG
save_bar <- function(file, values, labels, main, ylab = "Average Salary (USD)") {
  png(file, width = 1200, height = 800)
  barplot(values, names.arg = labels, main = main, ylab = ylab)
  dev.off()
}

# 3. Experience level vs average salary
salary_exp <- aggregate(salary_usd ~ experience_level, data, mean)
salary_exp <- salary_exp[order(-salary_exp$salary_usd), ]
write.csv(salary_exp, "output/Analysis_Results/Salary_Experience.csv", row.names = FALSE)
save_bar("output/Graphs/Salary_by_Experience.png",
         salary_exp$salary_usd, salary_exp$experience_level,
         "Salary by Experience Level")

# 4. Employment type vs average salary
salary_employment <- aggregate(salary_usd ~ employment_type, data, mean)
write.csv(salary_employment, "output/Analysis_Results/Salary_by_Employment_Type.csv", row.names = FALSE)
save_bar("output/Graphs/Salary_by_Employment_Type.png",
         salary_employment$salary_usd, salary_employment$employment_type,
         "Salary by Employment Type")

# 5. Company size vs average salary
salary_company <- aggregate(salary_usd ~ company_size, data, mean)
write.csv(salary_company, "output/Analysis_Results/Salary_by_Company_Size.csv", row.names = FALSE)
save_bar("output/Graphs/Salary_by_Company_Size.png",
         salary_company$salary_usd, salary_company$company_size,
         "Salary by Company Size")

# 6. Remote work type vs average salary
# remote_ratio is coded 0, 50 or 100 (percent remote)
data$work_type <- factor(data$remote_ratio,
                         levels = c(0, 50, 100),
                         labels = c("On-site", "Hybrid", "Remote"))
salary_remote <- aggregate(salary_usd ~ work_type, data, mean)
write.csv(salary_remote, "output/Analysis_Results/Salary_by_Remote_Work_Type.csv", row.names = FALSE)
save_bar("output/Graphs/Salary_by_Remote_Work_Type.png",
         salary_remote$salary_usd, salary_remote$work_type,
         "Salary by Remote Work Type")

# 7. Industry vs average salary (horizontal bars, sorted high to low)
salary_industry <- aggregate(salary_usd ~ industry, data, mean)
salary_industry <- salary_industry[order(-salary_industry$salary_usd), ]
write.csv(salary_industry, "output/Analysis_Results/Salary_by_Industry.csv", row.names = FALSE)
png("output/Graphs/Salary_by_Industry.png", width = 1600, height = 1000)
par(mar = c(5, 12, 5, 2))
barplot(salary_industry$salary_usd, names.arg = salary_industry$industry,
        main = "Salary by Industry", xlab = "Average Salary (USD)",
        horiz = TRUE, las = 1)
dev.off()

# 8. Job title vs average salary (top 15 only in the chart)
salary_job <- aggregate(salary_usd ~ job_title, data, mean)
salary_job <- salary_job[order(-salary_job$salary_usd), ]
write.csv(salary_job, "output/Analysis_Results/Salary_by_Job_Title.csv", row.names = FALSE)
top15_jobs <- head(salary_job, 15)
png("output/Graphs/Top_15_Salaries_by_Job_Title.png", width = 1600, height = 1000)
par(mar = c(5, 15, 5, 2))
barplot(top15_jobs$salary_usd, names.arg = top15_jobs$job_title,
        main = "Top 15 Highest Paying Job Titles",
        xlab = "Average Salary (USD)", horiz = TRUE, las = 1, cex.names = 0.7)
dev.off()

# 9. Education required vs average salary
salary_education <- aggregate(salary_usd ~ education_required, data, mean)
write.csv(salary_education, "output/Analysis_Results/Salary_by_Education.csv", row.names = FALSE)
save_bar("output/Graphs/Salary_by_Education.png",
         salary_education$salary_usd, salary_education$education_required,
         "Salary by Education Required")

# 10. Experience level vs employment type (job counts)
employment_exp <- as.data.frame(
  table(Experience_Level = data$experience_level,
        Employment_Type = data$employment_type)
)
colnames(employment_exp)[3] <- "Number_of_Jobs"
write.csv(employment_exp, "output/Analysis_Results/Experience_vs_Employment_Type.csv",
          row.names = FALSE)
png("output/Graphs/Experience_vs_Employment_Type.png", width = 1200, height = 800)
barplot(t(as.matrix(table(data$experience_level, data$employment_type))),
        beside = TRUE, main = "Employment Type by Experience Level",
        xlab = "Experience Level", ylab = "Number of Jobs",
        legend.text = TRUE)
dev.off()

print("All 8 comparisons completed successfully!")