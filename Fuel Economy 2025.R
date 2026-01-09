# Install packages if required
if(!require(readxl)){install.packages("readxl")}

# Load required libraries
library(readxl)

# Load the data
data <- readxl::read_excel("D://USF//LIS4273 F25//R programs//2025 car economy.xlsx", sheet = "FEguide")

# Convert to data frame for base R operations
df <- as.data.frame(data)

# Basic data exploration - display dimensions and column names
dim(df)
head(names(df), 10)

# Select and clean relevant columns for analysis - only 2025 model year
analysis_data <- df[df$`Model Year` == 2025, ]

# Extract relevant columns and convert to proper numeric types
analysis_data$Eng_Displ <- as.numeric(analysis_data$`Eng Displ`)
analysis_data$Comb_FE <- as.numeric(analysis_data$`Comb FE (Guide) - Conventional Fuel`)
analysis_data$City_FE <- as.numeric(analysis_data$`City FE (Guide) - Conventional Fuel`)
analysis_data$Hwy_FE <- as.numeric(analysis_data$`Hwy FE (Guide) - Conventional Fuel`)

# Create categorical variables for analysis
analysis_data$is_turbocharged <- ifelse(
  grepl("Turbo", analysis_data$`Air Aspiration Method Desc`), 
  "Turbocharged", 
  "Naturally Aspirated"
)

analysis_data$fuel_type <- ifelse(
  grepl("Premium", analysis_data$`Fuel Usage Desc - Conventional Fuel`), 
  "Premium", 
  "Regular"
)

analysis_data$drive_type <- ifelse(
  grepl("All Wheel", analysis_data$`Drive Desc`), "AWD",
  ifelse(grepl("Front", analysis_data$`Drive Desc`), "FWD",
         ifelse(grepl("Rear", analysis_data$`Drive Desc`), "RWD", "Other"))
)

# Remove rows with missing data in key analysis variables
analysis_data <- analysis_data[!is.na(analysis_data$Eng_Displ) & 
                                 !is.na(analysis_data$Comb_FE), ]

# Display clean dataset dimensions
dim(analysis_data)

# HYPOTHESIS 1 ANALYSIS: Turbocharged vs Naturally Aspirated engines

# Split data by aspiration type for comparison
turbo_data <- analysis_data[analysis_data$is_turbocharged == "Turbocharged", ]
na_data <- analysis_data[analysis_data$is_turbocharged == "Naturally Aspirated", ]

# Display summary statistics for both groups
nrow(turbo_data)
mean(turbo_data$Comb_FE, na.rm = TRUE)
sd(turbo_data$Comb_FE, na.rm = TRUE)
mean(turbo_data$Eng_Displ, na.rm = TRUE)

nrow(na_data)
mean(na_data$Comb_FE, na.rm = TRUE)
sd(na_data$Comb_FE, na.rm = TRUE)
mean(na_data$Eng_Displ, na.rm = TRUE)

# PLOT SECTION 1: Turbocharged vs Naturally Aspirated

par(mfrow = c(2, 2), mar = c(5, 4, 4, 2) + 0.1, oma = c(0, 0, 2, 0))

# Boxplot comparing fuel economy by aspiration type
boxplot(Comb_FE ~ is_turbocharged, data = analysis_data,
        main = "Combined Fuel Economy\nby Aspiration Type",
        xlab = "Aspiration Type", ylab = "Combined MPG",
        col = c("lightblue", "lightgreen"),
        cex.main = 0.9, cex.lab = 0.8, cex.axis = 0.8)

# Histogram of fuel economy for turbocharged vehicles
hist(turbo_data$Comb_FE, main = "Turbocharged Vehicles",
     xlab = "Combined MPG", ylab = "Frequency",
     col = "lightblue", breaks = 15,
     cex.main = 0.9, cex.lab = 0.8, cex.axis = 0.8)

# Histogram of fuel economy for naturally aspirated vehicles
hist(na_data$Comb_FE, main = "Naturally Aspirated Vehicles",
     xlab = "Combined MPG", ylab = "Frequency",
     col = "lightgreen", breaks = 15,
     cex.main = 0.9, cex.lab = 0.8, cex.axis = 0.8)

# Scatter plot showing relationship between displacement and MPG
plot(analysis_data$Eng_Displ, analysis_data$Comb_FE,
     col = ifelse(analysis_data$is_turbocharged == "Turbocharged", "red", "blue"),
     pch = 16, 
     main = "Engine Displacement vs Combined MPG",
     xlab = "Engine Displacement (L)", ylab = "Combined MPG",
     cex.main = 0.9, cex.lab = 0.8, cex.axis = 0.8)
legend("topright", legend = c("Turbocharged", "Naturally Aspirated"),
       col = c("red", "blue"), pch = 16, cex = 0.7)

title("Hypothesis 1: Turbocharged vs Naturally Aspirated Engines", outer = TRUE)

# Statistical Test 1: Independent t-test comparing MPG by aspiration type
t_test_result <- t.test(Comb_FE ~ is_turbocharged, data = analysis_data)
t_test_result

# Statistical Test 2: Linear model controlling for engine displacement
lm_model1 <- lm(Comb_FE ~ is_turbocharged + Eng_Displ, data = analysis_data)
summary(lm_model1)

# HYPOTHESIS 2 ANALYSIS: Premium vs Regular fuel

# Split data by fuel type for comparison
premium_data <- analysis_data[analysis_data$fuel_type == "Premium", ]
regular_data <- analysis_data[analysis_data$fuel_type == "Regular", ]

# Display summary statistics for both fuel types
nrow(premium_data)
mean(premium_data$Comb_FE, na.rm = TRUE)
mean(premium_data$City_FE, na.rm = TRUE)
mean(premium_data$Hwy_FE, na.rm = TRUE)

nrow(regular_data)
mean(regular_data$Comb_FE, na.rm = TRUE)
mean(regular_data$City_FE, na.rm = TRUE)
mean(regular_data$Hwy_FE, na.rm = TRUE)

# PLOT SECTION 2: Fuel Type Analysis

par(mfrow = c(2, 2), mar = c(5, 4, 4, 2) + 0.1, oma = c(0, 0, 2, 0))

# Boxplot for combined MPG by fuel type
boxplot(Comb_FE ~ fuel_type, data = analysis_data,
        main = "Combined MPG by Fuel Type",
        xlab = "Fuel Type", ylab = "Combined MPG",
        col = c("lightcoral", "lightyellow"),
        cex.main = 0.9, cex.lab = 0.8, cex.axis = 0.8)

# Boxplot for city MPG by fuel type
boxplot(City_FE ~ fuel_type, data = analysis_data,
        main = "City MPG by Fuel Type",
        xlab = "Fuel Type", ylab = "City MPG",
        col = c("lightcoral", "lightyellow"),
        cex.main = 0.9, cex.lab = 0.8, cex.axis = 0.8)

# Boxplot for highway MPG by fuel type
boxplot(Hwy_FE ~ fuel_type, data = analysis_data,
        main = "Highway MPG by Fuel Type",
        xlab = "Fuel Type", ylab = "Highway MPG",
        col = c("lightcoral", "lightyellow"),
        cex.main = 0.9, cex.lab = 0.8, cex.axis = 0.8)

# Information panel showing sample sizes
plot(1, type = "n", axes = FALSE, xlab = "", ylab = "",
     main = "Fuel Type Comparison Summary", cex.main = 0.9)
text(1, 1, paste("Premium: n =", nrow(premium_data), 
                 "\nRegular: n =", nrow(regular_data)),
     cex = 0.8)

title("Hypothesis 2: Premium vs Regular Fuel Vehicles", outer = TRUE)

# Statistical tests for different MPG measures by fuel type
t_comb <- t.test(Comb_FE ~ fuel_type, data = analysis_data)
t_city <- t.test(City_FE ~ fuel_type, data = analysis_data)
t_hwy <- t.test(Hwy_FE ~ fuel_type, data = analysis_data)

# Display t-test results
t_comb
t_city
t_hwy


# CORRELATION ANALYSIS
# Calculate correlation matrix between key continuous variables
cor_vars <- analysis_data[, c("Comb_FE", "Eng_Displ", "City_FE", "Hwy_FE")]
cor_matrix <- cor(cor_vars, use = "complete.obs")
cor_matrix

# PLOT SECTION 3: Correlation Matrix Visualization

par(mar = c(5, 4, 4, 2) + 0.1)
# Create scatterplot matrix to visualize relationships
pairs(cor_vars, 
      main = "Scatterplot Matrix of Key Variables",
      cex.main = 0.9, cex.labels = 0.8, cex.axis = 0.7,
      gap = 0.5)  # Add gap between plots for better spacing

# TWO-WAY ANOVA: Testing interaction between fuel type and aspiration type
anova_model <- aov(Comb_FE ~ fuel_type * is_turbocharged, data = analysis_data)
summary(anova_model)

# DISPLACEMENT CATEGORY ANALYSIS
# Create displacement categories for stratified analysis
analysis_data$displ_category <- cut(analysis_data$Eng_Displ,
                                    breaks = c(0, 2, 3, 4, max(analysis_data$Eng_Displ, na.rm = TRUE)),
                                    labels = c("Small (<2L)", "Medium (2-3L)", "Large (3-4L)", "Very Large (>4L)"))

# Calculate mean MPG by displacement category and aspiration type
displ_summary <- aggregate(Comb_FE ~ displ_category + is_turbocharged, 
                           data = analysis_data, 
                           function(x) c(mean = mean(x), count = length(x)))
displ_summary

# PLOT SECTION 4: Displacement Categories

# Extra bottom margin for rotated category labels
par(mar = c(8, 4, 4, 2) + 0.1)

# Calculate means for bar plot
means <- aggregate(Comb_FE ~ displ_category + is_turbocharged, data = analysis_data, mean)
bar_names <- paste(means$displ_category, "\n", means$is_turbocharged)

# Create bar plot showing MPG by displacement and aspiration type
barplot(means$Comb_FE, 
        names.arg = bar_names,
        las = 2,  # Rotate labels vertically
        col = c("lightblue", "lightgreen"),
        main = "Average MPG by Displacement and Aspiration Type",
        ylab = "Combined MPG",
        cex.main = 0.9, cex.names = 0.7, cex.axis = 0.8,
        ylim = c(0, max(means$Comb_FE) * 1.1))

# FINAL COMPREHENSIVE ANALYSIS
# Build comprehensive linear model with all key predictors
final_model <- lm(Comb_FE ~ fuel_type + is_turbocharged + Eng_Displ + drive_type,
                  data = analysis_data)
summary(final_model)

# PLOT SECTION 5: Custom Model Diagnostic Plots (without formula in title)

par(mfrow = c(2, 2), mar = c(4, 4, 3, 2) + 0.1, oma = c(0, 0, 2, 0))

# Get residuals and fitted values for custom plots
residuals <- resid(final_model)
fitted <- fitted(final_model)
std_residuals <- rstandard(final_model)

# Plot 1: Residuals vs Fitted
plot(fitted, residuals, 
     main = "Residuals vs Fitted Values",
     xlab = "Fitted Values", ylab = "Residuals",
     pch = 16, col = "blue", cex.main = 0.9, cex.lab = 0.8, cex.axis = 0.8)
abline(h = 0, col = "red", lty = 2)
lines(lowess(fitted, residuals), col = "darkgreen", lwd = 2)

# Plot 2: Normal Q-Q Plot
qqnorm(std_residuals, 
       main = "Normal Q-Q Plot",
       xlab = "Theoretical Quantiles", ylab = "Standardized Residuals",
       pch = 16, col = "blue", cex.main = 0.9, cex.lab = 0.8, cex.axis = 0.8)
qqline(std_residuals, col = "red", lwd = 2)

# Plot 3: Scale-Location Plot
sqrt_abs_resid <- sqrt(abs(std_residuals))
plot(fitted, sqrt_abs_resid,
     main = "Scale-Location Plot",
     xlab = "Fitted Values", ylab = "sqrt(|Standardized Residuals|)",
     pch = 16, col = "blue", cex.main = 0.9, cex.lab = 0.8, cex.axis = 0.8)
lines(lowess(fitted, sqrt_abs_resid), col = "darkgreen", lwd = 2)

# Plot 4: Residuals vs Leverage
leverage <- hatvalues(final_model)
plot(leverage, std_residuals,
     main = "Residuals vs Leverage",
     xlab = "Leverage", ylab = "Standardized Residuals",
     pch = 16, col = "blue", cex.main = 0.9, cex.lab = 0.8, cex.axis = 0.8)
abline(h = 0, col = "red", lty = 2)

title("Final Model Diagnostic Plots", outer = TRUE)

# Calculate and display key comparative metrics for summary
mean_turbo <- mean(turbo_data$Comb_FE)
mean_turbo
mean_na <- mean(na_data$Comb_FE)
mean_na
mean_premium <- mean(premium_data$Comb_FE)
mean_premium
mean_regular <- mean(regular_data$Comb_FE)
mean_regular
diff_turbo_na <- mean_turbo - mean_na
diff_turbo_na
diff_premium_regular <- mean_premium - mean_regular
diff_premium_regular
p_value_turbo <- t_test_result$p.value
p_value_turbo
p_value_fuel <- t_comb$p.value
p_value_fuel
cor_displ_mpg <- cor(analysis_data$Eng_Displ, analysis_data$Comb_FE, use = "complete.obs")
cor_displ_mpg

# Reset plot parameters to default values
par(mfrow = c(1, 1), mar = c(5, 4, 4, 2) + 0.1, oma = c(0, 0, 0, 0))