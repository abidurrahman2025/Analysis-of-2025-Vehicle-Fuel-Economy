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

## Hypothesis Establishment and Research Framework

I used the 2025 fuel economy dataset from US Department of Energy. I will investigate on two research questions: Do turbocharged engines provide significantly better fuel economy compared to naturally aspirated engines of similar displacement in 2025 model year vehicles? Do vehicles requiring premium fuel demonstrate different fuel economy patterns compared to those using regular fuel in the 2025 model year?

Based on the research questions, I established two primary hypotheses for this analysis:

### Hypothesis 1:

### Null Hypothesis (H₀):
There is no significant difference in combined fuel economy between turbocharged and naturally aspirated engines of similar displacement.

### Alternative Hypothesis (H₁):
Turbocharged engines have significantly better combined fuel economy than naturally aspirated engines of similar displacement.

### Hypothesis 2:

### Null Hypothesis (H₀):
There is no significant difference in fuel economy patterns between vehicles requiring premium fuel and those using regular fuel.

### Alternative Hypothesis (H₁):
Vehicles requiring premium fuel show different fuel economy patterns compared to vehicles using regular fuel.

These hypotheses were tested using comprehensive statistical methods including t-tests, ANOVA, correlation analysis, and multiple regression modeling to control for potential confounding factors.

## Research Methodology and Analysis
The analysis began with loading and preparing the dataset from the 2025 Fuel Economy Guide:

<img width="1023" height="255" alt="1" src="https://github.com/user-attachments/assets/858db9ae-9057-40b4-bcc1-290a5e056405" />

The dataset contained 868 vehicles with 162 variables each. I then filtered for 2025 model year vehicles and created analysis variables:

<img width="1023" height="460" alt="2-1" src="https://github.com/user-attachments/assets/b3adc74d-30b3-4000-a4ee-7b579481411a" />
<img width="1023" height="182" alt="3-1" src="https://github.com/user-attachments/assets/3d5c17ba-cdbe-46ec-b3a8-4d8582aaf66e" />

The final analysis dataset contained 868 vehicles with 169 variables after creating additional analysis columns.

<img width="767" height="328" alt="4" src="https://github.com/user-attachments/assets/2d361a09-e72f-4ca1-9f91-28eb4948457b" />

The dataset contained 586 turbocharged vehicles averaging 22.8 MPG with 2.7L displacement and 282 naturally aspirated vehicles averaging 26.2 MPG with 3.5L displacement. The naturally aspirated vehicles showed greater variability in fuel economy (SD = 9.91 vs 4.64).

### Visualization 1: Turbocharged vs Naturally Aspirated Comparison

<img width="767" height="289" alt="5" src="https://github.com/user-attachments/assets/9fc12355-494d-4b4a-a55a-f5429470462b" />
<img width="767" height="204" alt="6" src="https://github.com/user-attachments/assets/3c75309e-ab0b-4b8d-a7d1-979e0e3877ea" />
<img width="530" height="457" alt="hypothesis-1" src="https://github.com/user-attachments/assets/98d09ea1-a1b4-46c9-a37b-6a46cc572944" />

In the Hypothesis 1 Visualization, the boxplot comparison showed naturally aspirated engines with both higher median values and greater variability in fuel economy. Turbocharged vehicles clustered in a relatively normal distribution around 20-25 MPG, while naturally aspirated engines exhibited a pronounced bimodal distribution with concentrations in both high-efficiency (small engines achieving 35+ MPG) and low-efficiency ranges (large engines below 20 MPG). The scatter plot showed that turbocharged engines (red points) predominantly occupying the medium displacement range (2-3L) with moderate efficiency, while naturally aspirated engines (blue points) demonstrated both extremely efficient small engines and inefficient large engines, visually explaining why the overall mean comparison might be misleading.

Statistical Tests for Hypothesis 1

<img width="764" height="201" alt="7" src="https://github.com/user-attachments/assets/238fd57b-0561-4d33-ad7a-43adea0f4679" />

The t-test showed a statistically significant difference (p = 6.43e-08) with naturally aspirated engines averaging 3.43 MPG higher than turbocharged engines.

<img width="768" height="325" alt="8" src="https://github.com/user-attachments/assets/dbcb72c2-81da-4ab0-8639-91fcba5a04e4" />

The linear model revealed that after controlling for engine displacement, turbocharged engines actually showed 7.06 MPG lower fuel economy than naturally aspirated engines. Engine displacement had a strong negative effect (-4.65 MPG per liter). The model explained 59.8% of the variance in fuel economy.

Hypothesis 2 Analysis: Premium vs Regular Fuel Vehicles

Descriptive Statistics

<img width="768" height="300" alt="9" src="https://github.com/user-attachments/assets/6c038013-4c20-49be-a83b-e3f4ed38d9d2" />

The dataset was nearly balanced with 433 premium fuel vehicles (21.8 MPG combined) and 435 regular fuel vehicles (26.0 MPG combined). Regular fuel vehicles showed advantages across all three fuel economy measures.

Visualization 2: Fuel Type Analysis

<img width="766" height="310" alt="10" src="https://github.com/user-attachments/assets/41ca7bd3-6389-4248-a9dd-4471c0805da3" />
<img width="765" height="112" alt="11" src="https://github.com/user-attachments/assets/d0f93d02-9e20-40da-b123-83fc0f4fbf56" />
<img width="530" height="457" alt="hypothesis-2" src="https://github.com/user-attachments/assets/1df6ac95-bc2c-4cc5-b3c7-79af3b020d12" />

Hypothesis 2 Visualizations through the triple boxplot arrangement demonstrated consistent superiority of regular fuel vehicles across all three fuel economy measures. The nearly identical sample sizes (433 premium vs 435 regular) shown in the information panel strengthened the statistical validity of these comparisons. The consistent pattern across combined, city, and highway measures suggested a systematic difference rather than measurement artifact.
Statistical Tests for Hypothesis 2

<img width="767" height="254" alt="12" src="https://github.com/user-attachments/assets/c0830ef2-6004-4768-a7bd-1294ef04b8f5" />
<img width="766" height="171" alt="13" src="https://github.com/user-attachments/assets/92f24718-2dd8-4cf2-8a3c-d85afefe8a53" />
<img width="766" height="175" alt="14" src="https://github.com/user-attachments/assets/0cd30b7d-0e0f-46da-9ff7-11c40379e798" />

All three t-tests showed statistically significant differences (p < 0.001) with regular fuel vehicles demonstrating superior fuel economy across all measures: 4.21 MPG higher for combined, 4.86 MPG for city, and 2.92 MPG for highway driving.

Additional Comprehensive Analyses

<img width="767" height="269" alt="15" src="https://github.com/user-attachments/assets/029a86c5-3bd0-47f1-ab21-925dd572ecf7" />
<img width="664" height="664" alt="scatterplot-matrix-of-key-variables" src="https://github.com/user-attachments/assets/6c522d8c-956f-4baa-9f00-2fd98807d970" />

Correlation Matrix Visualization provided crucial validation of measurement consistency and revealed fundamental engineering relationships. The extremely high correlations between different fuel economy measures (r = 0.986 between combined and city MPG) confirmed internal consistency, while the clear negative relationship between engine displacement and all efficiency measures visually confirmed the fundamental physics of automotive efficiency.

<img width="767" height="155" alt="16" src="https://github.com/user-attachments/assets/1126950e-1c66-4f0c-bd31-a43da105ef97" />

The two-way ANOVA revealed significant main effects for both fuel type and aspiration type, plus a significant interaction effect (p = 1.43e-12), indicating the relationship between fuel type and MPG differs depending on whether the engine is turbocharged.

<img width="767" height="236" alt="17-1" src="https://github.com/user-attachments/assets/2e6ccc83-1b34-4f65-bdcc-922e72b40b82" />
<img width="766" height="254" alt="18-1" src="https://github.com/user-attachments/assets/24339515-af7b-4cf1-91bf-06005768b503" />
<img width="664" height="664" alt="average-mpg-by-displacement-and-aspiration-type" src="https://github.com/user-attachments/assets/a64e5af3-8b8b-40f5-b32d-4524203b1019" />

Displacement Category Analysis through the bar plot showed a nuanced nature of the turbocharging effect. The visualization showed that the natural aspiration advantage was most dramatic in smaller engine categories (37.6 vs 26.7 MPG in <2L category) and diminished in larger categories, suggesting that turbocharging technology might be more beneficial for larger engines where the efficiency penalty is reduced.

Final Comprehensive Model and Diagnostics

<img width="767" height="348" alt="19" src="https://github.com/user-attachments/assets/0a83cb40-c9d7-4fbf-aa52-4f047725d333" />

Insights from final comprehensive model :
    Turbocharged engines showed 6.30 MPG lower fuel economy after controlling for other factors
    Engine displacement remained strongly negative (-4.06 MPG per liter)
    Front-wheel drive vehicles showed 2.88 MPG advantage over all-wheel drive
    Fuel type became non-significant (p = 0.648) when controlling for other vehicle characteristics
    The model explained 63.4% of the variance in fuel economy

<img width="768" height="306" alt="20" src="https://github.com/user-attachments/assets/162bbb2c-3489-4f5e-8561-f73b847938e6" />
<img width="766" height="236" alt="21-1" src="https://github.com/user-attachments/assets/94c00fb4-ccbf-4cb8-b00e-9091f259a3b4" />
<img width="664" height="664" alt="final-model-diagnostic-plots" src="https://github.com/user-attachments/assets/09729755-3113-4cb0-86bf-79e047806ee8" />

Model Diagnostic Plots provided essential validation of the regression assumptions. The relatively random scatter in the residuals vs fitted plot, the approximately linear pattern in the Q-Q plot, and the absence of extreme leverage points all supported the validity of the multivariate conclusions.

<img width="768" height="376" alt="22" src="https://github.com/user-attachments/assets/346fe545-8107-4d1e-8d8d-78ead311f87b" />

The metrics quantify the central findings: naturally aspirated engines achieve 3.43 MPG higher fuel economy than turbocharged engines (p = 6.43e-08), regular fuel vehicles show 4.21 MPG advantage over premium fuel vehicles in bivariate analysis (p = 1.94e-19), and engine displacement shows a strong negative correlation with fuel economy (r = -0.629).
Research Abstract and Conclusion

This comprehensive analysis of 2025 model year vehicle fuel economy yields definitive conclusions regarding the two research hypotheses. For Hypothesis 1, we must reject the alternative hypothesis that turbocharged engines provide better fuel economy. The evidence strongly supports the opposite conclusion: naturally aspirated engines demonstrate significantly higher fuel economy both in simple comparisons (26.21 vs 22.78 MPG, p = 6.43e-08) and after controlling for engine displacement (7.06 MPG disadvantage for turbocharged engines, p < 2e-16). The visualization analysis revealed that this relationship is most pronounced in smaller engine categories, suggesting that the efficiency benefits of natural aspiration are particularly valuable in compact vehicle applications.

For Hypothesis 2, we find mixed evidence. While initial bivariate comparisons show substantial differences favoring regular fuel vehicles (25.99 vs 21.79 MPG, p < 1.94e-19), these differences become statistically non-significant in multivariate models that control for engine displacement, turbocharging, and drive type (p = 0.648). This pattern suggests that the apparent fuel type effect is largely confounded by other vehicle characteristics, particularly that premium fuel requirements are associated with vehicles that have other characteristics (larger engines, turbocharging) that independently reduce fuel economy.

The strong negative correlation between engine displacement and fuel economy (r = -0.629) remains a fundamental relationship in the 2025 vehicle fleet, while drive type emerges as a significant factor with front-wheel drive vehicles showing approximately 2.9 MPG advantage over all-wheel drive configurations. The comprehensive visualization approach proved essential for understanding the complex relationships and provided context that pure numerical analysis could not capture.

These findings have important implications for both automotive engineering and consumer decision-making, suggesting that the pursuit of turbocharging for fuel efficiency goals may be misguided, and that fuel type requirements should be considered in the broader context of overall vehicle design rather than as independent efficiency factors.
References

U.S. Department of Energy, & U.S. Environmental Protection Agency. (2025). 2025 Fuel Economy Data [Data set]. FuelEconomy.gov. https://www.fueleconomy.gov/feg/download.shtml

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
