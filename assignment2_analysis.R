# ================================================================================
# Obligatorisk Opgave 2 - Sandsynlighedsregning og Statistik
# Analysis of Connecticut State Employee Salary Data (2017)
# ================================================================================

# Clear workspace
rm(list = ls())

# Set random seed for reproducibility
set.seed(123)

# ================================================================================
# Load and Prepare Data
# ================================================================================

# Load the dataset
paydata2017 <- read.table("paydata2017.txt", header = TRUE)

# Create LogPay variable (natural logarithm of Pay)
paydata2017$LogPay <- log(paydata2017$Pay)

# ================================================================================
# Question 1: Descriptive Statistics
# ================================================================================

cat("\n=== QUESTION 1: Descriptive Statistics ===\n\n")

# Calculate statistics for Pay
pay_median <- median(paydata2017$Pay)
pay_mean <- mean(paydata2017$Pay)
pay_var <- var(paydata2017$Pay)
pay_sd <- sd(paydata2017$Pay)

# Calculate statistics for LogPay
logpay_median <- median(paydata2017$LogPay)
logpay_mean <- mean(paydata2017$LogPay)
logpay_var <- var(paydata2017$LogPay)
logpay_sd <- sd(paydata2017$LogPay)

# Display results in a formatted table
cat("Statistics Summary:\n")
cat(sprintf("%-20s %15s %15s %20s %20s\n", "", "Median", "Mean", "Variance", "Std. Deviation"))
cat(sprintf("%-20s %15.2f %15.2f %20.2f %20.2f\n", "Pay", pay_median, pay_mean, pay_var, pay_sd))
cat(sprintf("%-20s %15.4f %15.4f %20.4f %20.4f\n", "LogPay", logpay_median, logpay_mean, logpay_var, logpay_sd))
cat("\n")

# Save statistics to a file for LaTeX
cat("\nSaving LaTeX table snippet to 'statistics_table.tex'...\n")
latex_table <- paste0(
  "\\begin{table}[H]\n",
  "\\centering\n",
  "\\begin{tabular}{lrrrr}\n",
  "\\toprule\n",
  " & Median & Gennemsnit & Stikprøvevarians & Stikprøvespredning \\\\\n",
  "\\midrule\n",
  sprintf("Pay & %.2f & %.2f & %.2f & %.2f \\\\\n",
          pay_median, pay_mean, pay_var, pay_sd),
  sprintf("LogPay & %.4f & %.4f & %.4f & %.4f \\\\\n",
          logpay_median, logpay_mean, logpay_var, logpay_sd),
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\caption{Deskriptive statistikker for Pay og LogPay.}\n",
  "\\label{tab:descriptive}\n",
  "\\end{table}\n"
)
writeLines(latex_table, "statistics_table.tex")
cat("LaTeX table saved!\n\n")

# Store these values for later use
mu_hat <- logpay_mean
sigma2_hat <- logpay_var
sigma_hat <- logpay_sd

# ================================================================================
# Question 2: Histograms with Normal Distribution Overlay
# ================================================================================

cat("=== QUESTION 2: Creating Histograms ===\n\n")

# Save plots to PDF
pdf("histograms_with_normal.pdf", width = 12, height = 6)
par(mfrow = c(1, 2))

# Histogram for Pay with normal distribution overlay
hist(paydata2017$Pay, prob = TRUE,
     main = "Histogram of Pay with Normal Distribution",
     xlab = "Pay (USD)",
     ylab = "Density",
     col = "lightblue",
     border = "white")

# Overlay normal distribution
f1 <- function(x) dnorm(x, mean = pay_mean, sd = pay_sd)
curve(f1, add = TRUE, col = "red", lwd = 2)
legend("topright", legend = "N(μ, σ²)", col = "red", lty = 1, lwd = 2)

# Histogram for LogPay with normal distribution overlay
hist(paydata2017$LogPay, prob = TRUE,
     main = "Histogram of LogPay with Normal Distribution",
     xlab = "log(Pay)",
     ylab = "Density",
     col = "lightgreen",
     border = "white")

# Overlay normal distribution
f1_log <- function(x) dnorm(x, mean = logpay_mean, sd = logpay_sd)
curve(f1_log, add = TRUE, col = "red", lwd = 2)
legend("topright", legend = "N(μ, σ²)", col = "red", lty = 1, lwd = 2)

dev.off()
cat("Histograms saved to 'histograms_with_normal.pdf'\n\n")

# ================================================================================
# Question 3: Probability Estimates
# ================================================================================

cat("=== QUESTION 3: Probability Estimates for Pay > 100,000 USD ===\n\n")

# Method 1: Using normal distribution assumption on Pay
# P(Pay > 100000) assuming Pay ~ N(mean, sd²)
prob_normal_pay <- 1 - pnorm(100000, mean = pay_mean, sd = pay_sd)
cat(sprintf("Method 1 (Normal distribution on Pay): %.4f\n", prob_normal_pay))

# Method 2: Using log-normal distribution (LogPay ~ N(μ, σ²))
# P(Pay > 100000) = P(log(Pay) > log(100000))
prob_lognormal <- 1 - pnorm(log(100000), mean = logpay_mean, sd = logpay_sd)
cat(sprintf("Method 2 (Log-normal distribution): %.4f\n", prob_lognormal))

# Method 3: Empirical estimate (no distributional assumptions)
prob_empirical <- mean(paydata2017$Pay > 100000)
cat(sprintf("Method 3 (Empirical): %.4f\n\n", prob_empirical))

cat(sprintf("Difference between log-normal and empirical: %.4f\n", abs(prob_lognormal - prob_empirical)))
cat(sprintf("Difference between normal and empirical: %.4f\n\n", abs(prob_normal_pay - prob_empirical)))

# ================================================================================
# Question 4: Derivation of Log-Normal Density
# ================================================================================

cat("=== QUESTION 4: Log-Normal Density Derivation ===\n")
cat("See LaTeX report for mathematical derivation.\n\n")

# ================================================================================
# Question 5: Log-Normal Distribution Analysis
# ================================================================================

cat("=== QUESTION 5: Log-Normal Distribution Fit ===\n\n")

# Define the log-normal density function
f2 <- function(y) {
  (1 / (y * sqrt(2 * pi * sigma2_hat))) *
    exp(-(log(y) - mu_hat)^2 / (2 * sigma2_hat))
}

# Create histogram with log-normal overlay
pdf("histogram_lognormal.pdf", width = 8, height = 6)
hist(paydata2017$Pay, prob = TRUE,
     main = "Histogram of Pay with Log-Normal Distribution",
     xlab = "Pay (USD)",
     ylab = "Density",
     col = "lightblue",
     border = "white",
     xlim = c(0, max(paydata2017$Pay)))

curve(f2, add = TRUE, col = "darkgreen", lwd = 2)
legend("topright",
       legend = c("Data", "Log-Normal Density"),
       col = c("lightblue", "darkgreen"),
       lty = c(0, 1),
       lwd = c(0, 2),
       pch = c(15, NA))

dev.off()
cat("Log-normal histogram saved to 'histogram_lognormal.pdf'\n")
cat(sprintf("Using μ = %.4f and σ² = %.4f from LogPay statistics\n\n", mu_hat, sigma2_hat))

# ================================================================================
# Question 6: Median Properties
# ================================================================================

cat("=== QUESTION 6: Median Properties ===\n\n")

# For X ~ N(μ, σ²), the median is μ (by symmetry)
cat(sprintf("Median of X ~ N(μ, σ²) is μ = %.4f\n", mu_hat))

# For Y = e^X, median of Y is e^μ
median_Y_theoretical <- exp(mu_hat)
cat(sprintf("Median of Y = e^X is e^μ = %.2f\n", median_Y_theoretical))

# Compare with empirical median
cat(sprintf("Empirical median of Pay: %.2f\n", pay_median))
cat(sprintf("Difference: %.2f\n\n", abs(median_Y_theoretical - pay_median)))

# ================================================================================
# Question 7: Expectation of Y via Simulation
# ================================================================================

cat("=== QUESTION 7: Finding E(Y) via Simulation ===\n\n")

# Set parameters for simulation
mu_sim <- 0
sigma_sim <- 1.5
n_sim <- 100000

# Simulate X ~ N(0, 1.5²)
X_sim <- rnorm(n_sim, mean = mu_sim, sd = sigma_sim)

# Calculate Y = e^X
Y_sim <- exp(X_sim)

# Calculate mean of Y
mean_Y_sim <- mean(Y_sim)

cat(sprintf("Simulation with μ = %.1f and σ = %.1f (n = %d)\n", mu_sim, sigma_sim, n_sim))
cat(sprintf("Simulated E(Y): %.4f\n\n", mean_Y_sim))

# Test all candidate formulas
candidates <- data.frame(
  Formula = c("e^μ", "e^(μ-σ²)", "e^(μ+σ²)", "e^(μ+σ²/2)", "e^(μ+σ)"),
  Value = c(
    exp(mu_sim),
    exp(mu_sim - sigma_sim^2),
    exp(mu_sim + sigma_sim^2),
    exp(mu_sim + sigma_sim^2/2),
    exp(mu_sim + sigma_sim)
  )
)

candidates$Difference <- abs(candidates$Value - mean_Y_sim)
print(candidates)

cat(sprintf("\nThe correct formula is: E(Y) = e^(μ + σ²/2)\n"))
cat(sprintf("Theoretical value: %.4f\n", exp(mu_sim + sigma_sim^2/2)))
cat(sprintf("Simulated value: %.4f\n\n", mean_Y_sim))

# ================================================================================
# Question 8: Expected Salary Estimate
# ================================================================================

cat("=== QUESTION 8: Expected Salary Estimate ===\n\n")

# Using the formula E(Y) = e^(μ + σ²/2) with our data
expected_salary <- exp(mu_hat + sigma2_hat/2)
cat(sprintf("Estimated average salary using log-normal: $%.2f\n", expected_salary))
cat(sprintf("Empirical mean salary: $%.2f\n", pay_mean))
cat(sprintf("Difference: $%.2f\n\n", abs(expected_salary - pay_mean)))

# ================================================================================
# Question 9: QQ-Plots
# ================================================================================

cat("=== QUESTION 9: QQ-Plots ===\n\n")

# Create QQ-plots
pdf("qqplots.pdf", width = 12, height = 6)
par(mfrow = c(1, 2))

# QQ-plot for Pay
qqnorm(paydata2017$Pay, main = "Normal Q-Q Plot for Pay",
       xlab = "Theoretical Quantiles",
       ylab = "Sample Quantiles",
       col = "blue", pch = 20)
qqline(paydata2017$Pay, col = "red", lwd = 2)

# QQ-plot for LogPay
qqnorm(paydata2017$LogPay, main = "Normal Q-Q Plot for LogPay",
       xlab = "Theoretical Quantiles",
       ylab = "Sample Quantiles",
       col = "darkgreen", pch = 20)
qqline(paydata2017$LogPay, col = "red", lwd = 2)

dev.off()
cat("QQ-plots saved to 'qqplots.pdf'\n\n")

# ================================================================================
# Summary
# ================================================================================

cat("\n=== ANALYSIS COMPLETE ===\n")
cat("All plots and results have been generated.\n")
cat("Files created:\n")
cat("  - histograms_with_normal.pdf\n")
cat("  - histogram_lognormal.pdf\n")
cat("  - qqplots.pdf\n\n")
