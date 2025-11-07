# Module 6 Exercise — TLF Figures (Visualizations)

# 🎯 Goal:
# Practice creating clinical plots using ggplot2 and related packages.

# 📦 Load the following packages:
# install.packages("ggplot2")
# install.packages("dplyr")
# install.packages("tidyr")
# install.packages("patchwork")

library(ggplot2)
library(dplyr)
library(tidyr)
library(patchwork)

# 🧪 Provided Dataset

set.seed(2025)
labs <- tibble::tibble(
  USUBJID = rep(paste0("SUBJ", 1:10), each = 3),
  VISIT = rep(c("Day 1", "Week 2", "Week 4"), times = 10),
  ARM = rep(c("Placebo", "Drug"), each = 15),
  HGB = round(rnorm(30, mean = 13, sd = 1.2), 1),
  HCT = round(rnorm(30, mean = 38, sd = 3), 1)
)

labs_long <- labs %>%
  pivot_longer(cols = c(HGB, HCT), names_to = "Test", values_to = "Value")

# 📝 TASKS

# 1. Create a line plot of HGB and HCT for each subject across visits.
#    - Facet by lab test.
#    - Color lines by treatment arm.

# 2. Create a boxplot of HGB values by treatment arm and visit.
#    - Add appropriate titles and axis labels.

# 3. Create a heatmap of HGB values per subject and visit.

# 4. Compute mean and SD for HCT by visit and arm, and plot them with error bars.

# 5. BONUS: Use `patchwork` to combine 2 plots side by side.

# 🤖 Copilot Prompt Suggestions
# - "# Plot line plot by subject"
# - "# Compute mean ± SD per visit and group"
# - "# Create heatmap using geom_tile()"
# - "# Combine plots using patchwork"
