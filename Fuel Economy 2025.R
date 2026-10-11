# Hypothesis Establishment and Research Framework

I used the 2025 fuel economy dataset from US Department of Energy. I will investigate on two research questions: Do turbocharged engines provide significantly better fuel economy compared to naturally aspirated engines of similar displacement in 2025 model year vehicles? Do vehicles requiring premium fuel demonstrate different fuel economy patterns compared to those using regular fuel in the 2025 model year?

Based on the research questions, I established two primary hypotheses for this analysis:

## Hypothesis 1:

**Null Hypothesis (H₀):**
There is no significant difference in combined fuel economy between turbocharged and naturally aspirated engines of similar displacement.

**Alternative Hypothesis (H₁):**
Turbocharged engines have significantly better combined fuel economy than naturally aspirated engines of similar displacement.

## Hypothesis 2:

**Null Hypothesis (H₀):**
There is no significant difference in fuel economy patterns between vehicles requiring premium fuel and those using regular fuel.

**Alternative Hypothesis (H₁):**
Vehicles requiring premium fuel show different fuel economy patterns compared to vehicles using regular fuel.

These hypotheses were tested using comprehensive statistical methods including t-tests, ANOVA, correlation analysis, and multiple regression modeling to control for potential confounding factors.

## Research Methodology and Analysis

The analysis was done in Python (Jupyter Notebook) and began with loading and preparing the dataset from the 2025 Fuel Economy Guide, downloaded directly from FuelEconomy.gov:

```python
import io
import zipfile
import urllib.request

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy import stats
import statsmodels.formula.api as smf
from statsmodels.stats.anova import anova_lm
from statsmodels.nonparametric.smoothers_lowess import lowess

URL = "https://www.fueleconomy.gov/feg/epadata/25data.zip"

req = urllib.request.Request(URL, headers={"User-Agent": "Mozilla/5.0"})
with urllib.request.urlopen(req) as resp:
    zf = zipfile.ZipFile(io.BytesIO(resp.read()))

xlsx_name = [n for n in zf.namelist() if n.lower().endswith(".xlsx")][0]
df = pd.read_excel(io.BytesIO(zf.read(xlsx_name)), sheet_name="FEguide")

print(df.shape)
print(list(df.columns[:10]))
```

The dataset contained 868 vehicles with 162 variables each. I then filtered for 2025 model year vehicles and created analysis variables:

```python
# Only 2025 model year
data = df[df["Model Year"] == 2025].copy()

# Numeric columns
data["Eng_Displ"] = pd.to_numeric(data["Eng Displ"], errors="coerce")
data["Comb_FE"] = pd.to_numeric(data["Comb FE (Guide) - Conventional Fuel"], errors="coerce")
data["City_FE"] = pd.to_numeric(data["City FE (Guide) - Conventional Fuel"], errors="coerce")
data["Hwy_FE"] = pd.to_numeric(data["Hwy FE (Guide) - Conventional Fuel"], errors="coerce")

# Categorical variables
data["is_turbocharged"] = np.where(
    data["Air Aspiration Method Desc"].str.contains("Turbo", na=False),
    "Turbocharged", "Naturally Aspirated")

data["fuel_type"] = np.where(
    data["Fuel Usage Desc - Conventional Fuel"].str.contains("Premium", na=False),
    "Premium", "Regular")

drive = data["Drive Desc"]
data["drive_type"] = np.select(
    [drive.str.contains("All Wheel", na=False),
     drive.str.contains("Front", na=False),
     drive.str.contains("Rear", na=False)],
    ["AWD", "FWD", "RWD"], default="Other")

# Drop rows missing key variables
data = data.dropna(subset=["Eng_Displ", "Comb_FE"])
print(data.shape)
```

The final analysis dataset contained 868 vehicles with 169 variables after creating additional analysis columns.

```python
turbo_data = data[data["is_turbocharged"] == "Turbocharged"]
na_data = data[data["is_turbocharged"] == "Naturally Aspirated"]

for name, d in [("Turbocharged", turbo_data), ("Naturally Aspirated", na_data)]:
    print(f"{name}: n={len(d)}, mean MPG={d['Comb_FE'].mean():.3f}, "
          f"sd={d['Comb_FE'].std():.3f}, mean displ={d['Eng_Displ'].mean():.3f}")
```

The dataset contained 586 turbocharged vehicles averaging 22.8 MPG with 2.7L displacement and 282 naturally aspirated vehicles averaging 26.2 MPG with 3.5L displacement. The naturally aspirated vehicles showed greater variability in fuel economy (SD = 9.91 vs 4.64).

## Visualization 1: Turbocharged vs Naturally Aspirated Comparison

```python
fig, axes = plt.subplots(2, 2, figsize=(11, 8))

# Boxplot
bp = axes[0, 0].boxplot([na_data["Comb_FE"], turbo_data["Comb_FE"]],
                        tick_labels=["Naturally Aspirated", "Turbocharged"],
                        patch_artist=True)
for patch, c in zip(bp["boxes"], ["lightblue", "lightgreen"]):
    patch.set_facecolor(c)
axes[0, 0].set(title="Combined Fuel Economy\nby Aspiration Type",
               xlabel="Aspiration Type", ylabel="Combined MPG")

# Histograms
axes[0, 1].hist(turbo_data["Comb_FE"], bins=15, color="lightblue", edgecolor="black")
axes[0, 1].set(title="Turbocharged Vehicles", xlabel="Combined MPG", ylabel="Frequency")

axes[1, 0].hist(na_data["Comb_FE"], bins=15, color="lightgreen", edgecolor="black")
axes[1, 0].set(title="Naturally Aspirated Vehicles", xlabel="Combined MPG", ylabel="Frequency")

# Scatter
colors = np.where(data["is_turbocharged"] == "Turbocharged", "red", "blue")
axes[1, 1].scatter(data["Eng_Displ"], data["Comb_FE"], c=colors, s=15)
axes[1, 1].scatter([], [], c="red", label="Turbocharged")
axes[1, 1].scatter([], [], c="blue", label="Naturally Aspirated")
axes[1, 1].legend(loc="upper right", fontsize=8)
axes[1, 1].set(title="Engine Displacement vs Combined MPG",
               xlabel="Engine Displacement (L)", ylabel="Combined MPG")

fig.suptitle("Hypothesis 1: Turbocharged vs Naturally Aspirated Engines")
plt.tight_layout()
plt.show()
```

In the Hypothesis 1 Visualization, the boxplot comparison showed naturally aspirated engines with both higher median values and greater variability in fuel economy. Turbocharged vehicles clustered in a relatively normal distribution around 20-25 MPG, while naturally aspirated engines exhibited a pronounced bimodal distribution with concentrations in both high-efficiency (small engines achieving 35+ MPG) and low-efficiency ranges (large engines below 20 MPG). The scatter plot showed that turbocharged engines (red points) predominantly occupying the medium displacement range (2-3L) with moderate efficiency, while naturally aspirated engines (blue points) demonstrated both extremely efficient small engines and inefficient large engines, visually explaining why the overall mean comparison might be misleading.

## Statistical Tests for Hypothesis 1

```python
# Welch t-test (unequal variances)
def welch(df, value, group):
    levels = sorted(df[group].unique())
    a = df.loc[df[group] == levels[0], value]
    b = df.loc[df[group] == levels[1], value]
    res = stats.ttest_ind(a, b, equal_var=False)
    ci = res.confidence_interval()
    print(f"{value} by {group}: {levels[0]} (mean={a.mean():.3f}) vs {levels[1]} (mean={b.mean():.3f})")
    print(f"  t = {res.statistic:.4f}, df = {res.df:.2f}, p = {res.pvalue:.4g}")
    print(f"  95% CI of difference: [{ci.low:.3f}, {ci.high:.3f}]\n")
    return res

t_test_result = welch(data, "Comb_FE", "is_turbocharged")

# Linear model controlling for displacement
lm_model1 = smf.ols("Comb_FE ~ C(is_turbocharged) + Eng_Displ", data=data).fit()
print(lm_model1.summary())
```

The t-test showed a statistically significant difference (p = 6.43e-08) with naturally aspirated engines averaging 3.43 MPG higher than turbocharged engines.

The linear model revealed that after controlling for engine displacement, turbocharged engines actually showed 7.06 MPG lower fuel economy than naturally aspirated engines. Engine displacement had a strong negative effect (-4.65 MPG per liter). The model explained 59.8% of the variance in fuel economy.

## Hypothesis 2 Analysis: Premium vs Regular Fuel Vehicles

### Descriptive Statistics

```python
premium_data = data[data["fuel_type"] == "Premium"]
regular_data = data[data["fuel_type"] == "Regular"]

for name, d in [("Premium", premium_data), ("Regular", regular_data)]:
    print(f"{name}: n={len(d)}, Comb={d['Comb_FE'].mean():.3f}, "
          f"City={d['City_FE'].mean():.3f}, Hwy={d['Hwy_FE'].mean():.3f}")
```

The dataset was nearly balanced with 433 premium fuel vehicles (21.8 MPG combined) and 435 regular fuel vehicles (26.0 MPG combined). Regular fuel vehicles showed advantages across all three fuel economy measures.

## Visualization 2: Fuel Type Analysis

```python
fig, axes = plt.subplots(2, 2, figsize=(11, 8))

def fuel_box(ax, col, title, ylabel):
    bp = ax.boxplot([premium_data[col].dropna(), regular_data[col].dropna()],
                    tick_labels=["Premium", "Regular"], patch_artist=True)
    for patch, c in zip(bp["boxes"], ["lightcoral", "lightyellow"]):
        patch.set_facecolor(c)
    ax.set(title=title, xlabel="Fuel Type", ylabel=ylabel)

fuel_box(axes[0, 0], "Comb_FE", "Combined MPG by Fuel Type", "Combined MPG")
fuel_box(axes[0, 1], "City_FE", "City MPG by Fuel Type", "City MPG")
fuel_box(axes[1, 0], "Hwy_FE", "Highway MPG by Fuel Type", "Highway MPG")

# Info panel
axes[1, 1].axis("off")
axes[1, 1].set_title("Fuel Type Comparison Summary")
axes[1, 1].text(0.5, 0.5, f"Premium: n = {len(premium_data)}\nRegular: n = {len(regular_data)}",
                ha="center", va="center")

fig.suptitle("Hypothesis 2: Premium vs Regular Fuel Vehicles")
plt.tight_layout()
plt.show()
```

Hypothesis 2 Visualizations through the triple boxplot arrangement demonstrated consistent superiority of regular fuel vehicles across all three fuel economy measures. The nearly identical sample sizes (433 premium vs 435 regular) shown in the information panel strengthened the statistical validity of these comparisons. The consistent pattern across combined, city, and highway measures suggested a systematic difference rather than measurement artifact.

## Statistical Tests for Hypothesis 2

```python
t_comb = welch(data, "Comb_FE", "fuel_type")
t_city = welch(data, "City_FE", "fuel_type")
t_hwy = welch(data, "Hwy_FE", "fuel_type")
```

All three t-tests showed statistically significant differences (p < 0.001) with regular fuel vehicles demonstrating superior fuel economy across all measures: 4.21 MPG higher for combined, 4.86 MPG for city, and 2.92 MPG for highway driving.

## Additional Comprehensive Analyses

```python
cor_vars = data[["Comb_FE", "Eng_Displ", "City_FE", "Hwy_FE"]]
cor_matrix = cor_vars.corr()
print(cor_matrix)

pd.plotting.scatter_matrix(cor_vars, figsize=(9, 9), s=8, alpha=0.6, diagonal="hist")
plt.suptitle("Scatterplot Matrix of Key Variables")
plt.show()
```

Correlation Matrix Visualization provided crucial validation of measurement consistency and revealed fundamental engineering relationships. The extremely high correlations between different fuel economy measures (r = 0.986 between combined and city MPG) confirmed internal consistency, while the clear negative relationship between engine displacement and all efficiency measures visually confirmed the fundamental physics of automotive efficiency.

```python
anova_model = smf.ols("Comb_FE ~ C(fuel_type) * C(is_turbocharged)", data=data).fit()
print(anova_lm(anova_model, typ=1))  # sequential sums of squares
```

The two-way ANOVA revealed significant main effects for both fuel type and aspiration type, plus a significant interaction effect (p = 1.43e-12), indicating the relationship between fuel type and MPG differs depending on whether the engine is turbocharged.

```python
data["displ_category"] = pd.cut(
    data["Eng_Displ"],
    bins=[0, 2, 3, 4, data["Eng_Displ"].max()],
    labels=["Small (<2L)", "Medium (2-3L)", "Large (3-4L)", "Very Large (>4L)"])

displ_summary = (data.groupby(["displ_category", "is_turbocharged"], observed=True)["Comb_FE"]
                     .agg(mean="mean", count="count")
                     .reset_index())
print(displ_summary)

labels = displ_summary["displ_category"].astype(str) + "\n" + displ_summary["is_turbocharged"]
bar_colors = ["lightblue", "lightgreen"] * (len(displ_summary) // 2 + 1)

fig, ax = plt.subplots(figsize=(10, 6))
ax.bar(range(len(displ_summary)), displ_summary["mean"],
       color=bar_colors[:len(displ_summary)], edgecolor="black")
ax.set_xticks(range(len(displ_summary)))
ax.set_xticklabels(labels, rotation=90, fontsize=8)
ax.set(title="Average MPG by Displacement and Aspiration Type", ylabel="Combined MPG",
       ylim=(0, displ_summary["mean"].max() * 1.1))
plt.tight_layout()
plt.show()
```

Displacement Category Analysis through the bar plot showed a nuanced nature of the turbocharging effect. The visualization showed that the natural aspiration advantage was most dramatic in smaller engine categories (37.6 vs 26.7 MPG in <2L category) and diminished in larger categories, suggesting that turbocharging technology might be more beneficial for larger engines where the efficiency penalty is reduced.

## Final Comprehensive Model and Diagnostics

```python
final_model = smf.ols(
    "Comb_FE ~ C(fuel_type) + C(is_turbocharged) + Eng_Displ + C(drive_type)",
    data=data).fit()
print(final_model.summary())
```

Insights from final comprehensive model :

    Turbocharged engines showed 6.30 MPG lower fuel economy after controlling for other factors
    Engine displacement remained strongly negative (-4.06 MPG per liter)
    Front-wheel drive vehicles showed 2.88 MPG advantage over all-wheel drive
    Fuel type became non-significant (p = 0.648) when controlling for other vehicle characteristics
    The model explained 63.4% of the variance in fuel economy

```python
resid = final_model.resid
fitted = final_model.fittedvalues
infl = final_model.get_influence()
std_resid = infl.resid_studentized_internal
leverage = infl.hat_matrix_diag

fig, axes = plt.subplots(2, 2, figsize=(11, 8))

# Residuals vs Fitted
ax = axes[0, 0]
ax.scatter(fitted, resid, s=12, color="blue")
ax.axhline(0, color="red", ls="--")
sm_line = lowess(resid, fitted)
ax.plot(sm_line[:, 0], sm_line[:, 1], color="darkgreen", lw=2)
ax.set(title="Residuals vs Fitted Values", xlabel="Fitted Values", ylabel="Residuals")

# Normal Q-Q
ax = axes[0, 1]
(osm, osr), _ = stats.probplot(std_resid, dist="norm")
ax.scatter(osm, osr, s=12, color="blue")
x1, x2 = stats.norm.ppf([0.25, 0.75])
y1, y2 = np.quantile(std_resid, [0.25, 0.75])
slope = (y2 - y1) / (x2 - x1)
ax.plot(osm, y1 + slope * (osm - x1), color="red", lw=2)
ax.set(title="Normal Q-Q Plot", xlabel="Theoretical Quantiles", ylabel="Standardized Residuals")

# Scale-Location
ax = axes[1, 0]
sqrt_abs = np.sqrt(np.abs(std_resid))
ax.scatter(fitted, sqrt_abs, s=12, color="blue")
sm_line = lowess(sqrt_abs, fitted)
ax.plot(sm_line[:, 0], sm_line[:, 1], color="darkgreen", lw=2)
ax.set(title="Scale-Location Plot", xlabel="Fitted Values",
       ylabel="sqrt(|Standardized Residuals|)")

# Residuals vs Leverage
ax = axes[1, 1]
ax.scatter(leverage, std_resid, s=12, color="blue")
ax.axhline(0, color="red", ls="--")
ax.set(title="Residuals vs Leverage", xlabel="Leverage", ylabel="Standardized Residuals")

fig.suptitle("Final Model Diagnostic Plots")
plt.tight_layout()
plt.show()
```

Model Diagnostic Plots provided essential validation of the regression assumptions. The relatively random scatter in the residuals vs fitted plot, the approximately linear pattern in the Q-Q plot, and the absence of extreme leverage points all supported the validity of the multivariate conclusions.

```python
mean_turbo = turbo_data["Comb_FE"].mean()
mean_na = na_data["Comb_FE"].mean()
mean_premium = premium_data["Comb_FE"].mean()
mean_regular = regular_data["Comb_FE"].mean()

print(f"Turbo - NA difference:        {mean_turbo - mean_na:.3f}")
print(f"Premium - Regular difference: {mean_premium - mean_regular:.3f}")
print(f"p-value (turbo vs NA):        {t_test_result.pvalue:.4g}")
print(f"p-value (premium vs regular): {t_comb.pvalue:.4g}")
print(f"Correlation (displacement, MPG): {data['Eng_Displ'].corr(data['Comb_FE']):.3f}")
```

The metrics quantify the central findings: naturally aspirated engines achieve 3.43 MPG higher fuel economy than turbocharged engines (p = 6.43e-08), regular fuel vehicles show 4.21 MPG advantage over premium fuel vehicles in bivariate analysis (p = 1.94e-19), and engine displacement shows a strong negative correlation with fuel economy (r = -0.629).

## Research Abstract and Conclusion

This comprehensive analysis of 2025 model year vehicle fuel economy yields definitive conclusions regarding the two research hypotheses. For Hypothesis 1, we must reject the alternative hypothesis that turbocharged engines provide better fuel economy. The evidence strongly supports the opposite conclusion: naturally aspirated engines demonstrate significantly higher fuel economy both in simple comparisons (26.21 vs 22.78 MPG, p = 6.43e-08) and after controlling for engine displacement (7.06 MPG disadvantage for turbocharged engines, p < 2e-16). The visualization analysis revealed that this relationship is most pronounced in smaller engine categories, suggesting that the efficiency benefits of natural aspiration are particularly valuable in compact vehicle applications.

For Hypothesis 2, we find mixed evidence. While initial bivariate comparisons show substantial differences favoring regular fuel vehicles (25.99 vs 21.79 MPG, p < 1.94e-19), these differences become statistically non-significant in multivariate models that control for engine displacement, turbocharging, and drive type (p = 0.648). This pattern suggests that the apparent fuel type effect is largely confounded by other vehicle characteristics, particularly that premium fuel requirements are associated with vehicles that have other characteristics (larger engines, turbocharging) that independently reduce fuel economy.

The strong negative correlation between engine displacement and fuel economy (r = -0.629) remains a fundamental relationship in the 2025 vehicle fleet, while drive type emerges as a significant factor with front-wheel drive vehicles showing approximately 2.9 MPG advantage over all-wheel drive configurations. The comprehensive visualization approach proved essential for understanding the complex relationships and provided context that pure numerical analysis could not capture.

These findings have important implications for both automotive engineering and consumer decision-making, suggesting that the pursuit of turbocharging for fuel efficiency goals may be misguided, and that fuel type requirements should be considered in the broader context of overall vehicle design rather than as independent efficiency factors.

## References

U.S. Department of Energy, & U.S. Environmental Protection Agency. (2025). 2025 Fuel Economy Data [Data set]. FuelEconomy.gov. https://www.fueleconomy.gov/feg/download.shtml
