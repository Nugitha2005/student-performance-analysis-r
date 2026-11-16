# ==============================================================================
# FINAL ASSIGNMENT R SCRIPT
# Educational Data Analysis Using Statistical Techniques and Predictive Modelling
# IE2024 - Probability & Statistics
# Author: Artigala Vidanelage Nugitha Malekth Artigala (IT25100934)
# Institution: Sri Lanka Institute of Information Technology (SLIIT)
# Dataset: Student Performance Factors (Kaggle, lainguyn123)
#          https://www.kaggle.com/datasets/lainguyn123/student-performance-factors
# ==============================================================================

# ==========================================
# Task 1: Dataset Introduction & Setup
# ==========================================
cat("\n==========================================\n")
cat("TASK 1: DATASET INTRODUCTION\n")
cat("==========================================\n")

# 1. Load the dataset into a Data Frame
student_data <- read.csv("StudentPerformanceFactors.csv")

# 2. View the first 6 rows to confirm it loaded correctly
cat("\n--- First 6 Rows of the Dataset ---\n")
print(head(student_data))

# 3. Print the total number of rows and columns
cat("\n--- Dataset Dimensions (Rows, Columns) ---\n")
print(dim(student_data))

# 4. Variable types (numerical vs categorical)
cat("\n--- Variable Structure ---\n")
str(student_data)
cat("Numerical variables:  ", sum(sapply(student_data, is.numeric)), "\n")
cat("Categorical variables:", sum(!sapply(student_data, is.numeric)), "\n")

# 5. Data preprocessing checks
cat("\n--- Data Quality Checks ---\n")
cat("Missing (NA) values in dataset:", sum(is.na(student_data)), "\n")
cat("Blank entries per column (only columns that have them):\n")
blank_counts <- colSums(student_data == "")
print(blank_counts[blank_counts > 0])
cat("Exam scores above 100:", sum(student_data$Exam_Score > 100), "\n")

# Convert the categorical variables used in the analysis to factors
student_data$Family_Income   <- factor(student_data$Family_Income)
student_data$Internet_Access <- factor(student_data$Internet_Access)


# ==========================================
# Task 2: Descriptive Statistical Analysis
# ==========================================
cat("\n==========================================\n")
cat("TASK 2: DESCRIPTIVE STATISTICS\n")
cat("==========================================\n")

# 1. Measures of Central Tendency & Quartiles
cat("\n--- Summary Statistics for Exam Score ---\n")
print(summary(student_data$Exam_Score))
cat("\n--- Percentiles of Exam Score ---\n")
print(quantile(student_data$Exam_Score, c(0.10, 0.25, 0.50, 0.75, 0.90)))
cat("Interquartile Range (IQR):", IQR(student_data$Exam_Score), "\n")

# 2. Measures of Dispersion
cat("\n--- Exam Score Dispersion ---\n")
cat("Variance: ", var(student_data$Exam_Score), "\n")
cat("Standard Deviation: ", sd(student_data$Exam_Score), "\n")
cat("Range: ", diff(range(student_data$Exam_Score)), "\n")

# 3. Frequency Tables
cat("\n--- Frequency Table: Family Income Levels ---\n")
print(table(student_data$Family_Income))
print(round(prop.table(table(student_data$Family_Income)) * 100, 1))
cat("\n--- Frequency Table: Internet Access ---\n")
print(table(student_data$Internet_Access))
print(round(prop.table(table(student_data$Internet_Access)) * 100, 1))

# 4. Correlation Analysis (Selecting Numerical Variables)
cat("\n--- Correlation Matrix ---\n")
print(round(cor(student_data[, c("Exam_Score", "Hours_Studied", "Attendance", "Previous_Scores")]), 3))

# 5. Graphical Visualizations

# Plot 1: Histogram (Data Distribution)
hist(student_data$Exam_Score,
     main="Distribution of Exam Scores",
     xlab="Exam Score", col="steelblue", breaks=30)

# Plot 2: Boxplot (Categorical vs Continuous)
boxplot(Exam_Score ~ Internet_Access, data=student_data,
        main="Exam Scores by Internet Access",
        ylab="Exam Score", xlab="Internet Access",
        col=c("lightcoral", "lightgreen"))

# Plot 3: Scatterplot with Trendline (Continuous vs Continuous)
plot(student_data$Attendance, student_data$Exam_Score,
     main="Attendance vs Exam Score",
     xlab="Attendance (%)", ylab="Exam Score",
     pch=19, col=rgb(0.2, 0.4, 0.6, 0.3)) # Using slight transparency
abline(lm(Exam_Score ~ Attendance, data=student_data), col="red", lwd=2)

# Plot 4: Barplot (Frequencies)
income_counts <- table(student_data$Family_Income)
barplot(income_counts,
        main="Students by Family Income",
        xlab="Income Level", ylab="Count",
        col=c("gold", "darkorange", "firebrick"))


# ==========================================
# Task 3: Statistical Inference
# ==========================================
cat("\n==========================================\n")
cat("TASK 3: STATISTICAL INFERENCE\n")
cat("==========================================\n")
# Significance level for all tests: alpha = 0.05

# ---- Test 1: Welch Two-Sample t-test ----
# Research Question: Does having Internet Access at home affect exam scores?
# H0: mu_No = mu_Yes (no difference in mean exam scores)
# H1: mu_No != mu_Yes (mean exam scores differ)
# Why: comparing the mean of a numerical variable between two independent
# groups with unknown, possibly unequal variances and very unequal sizes.
cat("\n--- Test 1: Welch Two-Sample t-test (Internet Access) ---\n")
internet_ttest <- t.test(Exam_Score ~ Internet_Access, data = student_data)
print(internet_ttest)

# ---- Test 2: One-way ANOVA ----
# Research Question: Does mean exam score differ across family income levels?
# H0: mu_High = mu_Medium = mu_Low
# H1: at least one income group mean is different
# Why: comparing means of a numerical variable across three independent groups.
cat("\n--- Test 2: One-way ANOVA (Family Income) ---\n")
print(tapply(student_data$Exam_Score, student_data$Family_Income, mean))
income_anova <- aov(Exam_Score ~ Family_Income, data = student_data)
print(summary(income_anova))

# ---- Test 3: Pearson Correlation Significance Test ----
# Research Question: Is attendance linearly related to exam score?
# H0: rho = 0 (no linear correlation)
# H1: rho != 0
# Why: both variables are numerical; tests whether r differs from zero.
cat("\n--- Test 3: Correlation Test (Attendance vs Exam Score) ---\n")
attendance_cortest <- cor.test(student_data$Attendance, student_data$Exam_Score)
print(attendance_cortest)


# ==========================================
# Task 4: Predictive Modelling
# ==========================================
cat("\n==========================================\n")
cat("TASK 4: PREDICTIVE MODELLING\n")
cat("==========================================\n")

# Feature selection: three numerical predictors with the highest correlation
# to Exam Score (Attendance, Hours_Studied, Previous_Scores) plus two
# socio-economic factors from the research question (Family_Income,
# Internet_Access). Categorical predictors are dummy-coded automatically by
# lm(); reference levels are High income and No internet.

# 1. Train the Multiple Linear Regression model (OLS)
predictive_model <- lm(Exam_Score ~ Hours_Studied + Attendance + Previous_Scores + Family_Income + Internet_Access, data = student_data)

cat("\n--- Multiple Linear Regression Model Evaluation ---\n")
print(summary(predictive_model))

# 2. Evaluation metrics
residuals_full <- residuals(predictive_model)
cat("\nRMSE:", round(sqrt(mean(residuals_full^2)), 3), "\n")
cat("MAE: ", round(mean(abs(residuals_full)), 3), "\n")

# 3. Hold-out validation (80% train / 20% test)
set.seed(42)
train_index <- sample(nrow(student_data), 0.8 * nrow(student_data))
train_data  <- student_data[train_index, ]
test_data   <- student_data[-train_index, ]
validation_model <- lm(Exam_Score ~ Hours_Studied + Attendance + Previous_Scores + Family_Income + Internet_Access, data = train_data)
test_pred <- predict(validation_model, test_data)
test_rmse <- sqrt(mean((test_data$Exam_Score - test_pred)^2))
test_r2   <- 1 - sum((test_data$Exam_Score - test_pred)^2) /
                 sum((test_data$Exam_Score - mean(test_data$Exam_Score))^2)
cat("\n--- Hold-out Validation (unseen 20% of students) ---\n")
cat("Training rows:", nrow(train_data), " Test rows:", nrow(test_data), "\n")
cat("Test R-squared:", round(test_r2, 3), "\n")
cat("Test RMSE:     ", round(test_rmse, 3), "\n")

# 4. Make a Real-World Prediction
hypothetical_student <- data.frame(
  Hours_Studied = 20,
  Attendance = 85,
  Previous_Scores = 75,
  Family_Income = "Medium",
  Internet_Access = "Yes"
)

# Ask the trained model to predict their exam score
predicted_score <- predict(predictive_model, hypothetical_student, interval = "prediction")

cat("\n--- Real-World Prediction Demonstration ---\n")
cat("Hypothetical Profile: 20 Hrs Study, 85% Attendance, 75 Prev Score, Medium Income, Has Internet\n")
cat("Predicted Exam Score: ", round(predicted_score[1, "fit"], 2), "\n")
cat("95% Prediction Interval: ", round(predicted_score[1, "lwr"], 2), "to", round(predicted_score[1, "upr"], 2), "\n")

cat("\n==========================================\n")
cat("SCRIPT EXECUTION COMPLETE\n")
cat("==========================================\n")
