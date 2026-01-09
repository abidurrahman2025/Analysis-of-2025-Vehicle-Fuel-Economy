# 2025 Car Fuel Economy Analysis - R Script

## Overview

This R script analyzes the **2025 car fuel economy dataset** from the EPA's Fuel Economy Guide. The script performs comprehensive statistical analyses and visualizations to explore relationships between vehicle characteristics and fuel efficiency.

## Dataset Information

- **File**: `2025 car economy.xlsx`
- **Sheet**: `FEguide`
- **Rows**: Extensive dataset of 2025 model year vehicles
- **Columns**: ~200+ technical specifications including:
  - Manufacturer, Division, Carline
  - Engine displacement, cylinders, transmission
  - Fuel economy metrics (City, Highway, Combined MPG)
  - Aspiration method, fuel type, drive system
  - CO2 emissions, technical features

## Prerequisites

### Required R Packages:
```r
install.packages("readxl")
```

## Script Structure

### 1. **Data Loading & Preparation**
- Reads the Excel file using `readxl` package
- Filters for 2025 model year vehicles only
- Creates categorical variables for analysis:
  - `is_turbocharged`: Turbocharged vs Naturally Aspirated
  - `fuel_type`: Premium vs Regular fuel
  - `drive_type`: AWD, FWD, RWD classification
- Cleans and converts numeric variables

### 2. **Hypothesis Testing**

#### **Hypothesis 1: Turbocharged vs Naturally Aspirated Engines**
- **Research Question**: Do turbocharged engines have different fuel economy compared to naturally aspirated engines?
- **Analyses**:
  - T-test comparison of combined MPG
  - Linear model controlling for engine displacement
  - Visualizations: Boxplots, histograms, scatter plots

#### **Hypothesis 2: Premium vs Regular Fuel Vehicles**
- **Research Question**: Do vehicles requiring premium fuel differ in fuel economy from those using regular fuel?
- **Analyses**:
  - T-tests for City, Highway, and Combined MPG
  - Comparative boxplots for all three metrics
  - Summary statistics by fuel type

### 3. **Additional Analyses**

#### **Correlation Analysis**
- Correlation matrix between key variables
- Scatterplot matrix visualization

#### **Two-Way ANOVA**
- Tests interaction effects between fuel type and aspiration type

#### **Displacement Category Analysis**
- Categorizes engines by displacement size
- Analyzes MPG patterns across size categories

#### **Comprehensive Linear Model**
- Builds final predictive model with multiple predictors
- Includes diagnostic plots (residuals, Q-Q, leverage)

## Key Outputs

### Statistical Tests:
1. T-tests comparing group means
2. Linear regression models
3. ANOVA for interaction effects
4. Correlation coefficients

### Visualizations:
1. Comparative boxplots (aspiration type, fuel type)
2. Histograms of MPG distributions
3. Scatter plots (engine displacement vs MPG)
4. Diagnostic plots for model validation
5. Bar charts for categorical comparisons

## Running the Script

1. **Install required packages** (if not already installed):
```r
install.packages("readxl")
```

2. **Set working directory** to folder containing:
   - `2025 car economy.xlsx`
   - The R script file

3. **Run the script** in R or RStudio:
```r
source("your_script_name.R")
```

## Expected Results

The script will output:
- Console printouts of statistical test results
- Multiple plot windows with visualizations
- Summary statistics for each hypothesis
- Model coefficients and diagnostics

## Notes & Considerations

1. **Data Quality**: Script removes rows with missing key variables
2. **Scope**: Only analyzes 2025 model year vehicles
3. **Assumptions**: Statistical tests assume approximately normal distributions
4. **Interpretation**: Results show associations, not necessarily causation

## Potential Extensions

1. Add more sophisticated machine learning models
2. Include interaction terms in regression
3. Analyze time trends if multiple years available
4. Create interactive visualizations with Shiny
5. Export results to formatted reports (HTML/PDF)

## File Structure Recommendation

```
project-folder/
├── 2025 car economy.xlsx      # Source data
├── car_economy_analysis.R     # This R script
├── README.md                  # This documentation
└── outputs/                   # (Optional) For saving plots/results
```

## Author & Version

- **Purpose**: Educational/Analytical exploration of EPA fuel economy data
- **Date**: Current implementation
- **Data Source**: EPA Fuel Economy Guide 2025

## License

This analysis script is provided for educational purposes. The dataset is publicly available from the EPA.
