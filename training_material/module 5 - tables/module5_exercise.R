# Module 5 Exercise Handout — TLF Tables: Summary Statistics

# Objective:
# Practice generating summary tables using gtsummary and dplyr.
# Work with a mock dataset to explore summary statistics, frequencies, and grouped exports.

# ----------------------------
# 1. Load Required Packages
# ----------------------------

# Uncomment if not yet installed
# install.packages("gtsummary")
# install.packages("gt")

library(dplyr)
library(gtsummary)
library(gt)

# ----------------------------
# 2. Create Mock Dataset
# ----------------------------

# Create a dataset similar to clinical trial data (demographics or AEs)
# You can use AGE, SEX, RACE, ARM, and other variables

# Example template:
demo <- tibble::tibble(
  USUBJID = paste0("01-", sprintf("%03d", 1:12)),
  AGE = sample(30:75, 12, replace = TRUE),
  SEX = sample(c("M", "F"), 12, replace = TRUE),
  RACE = sample(c("White", "Black", "Asian", "Other"), 12, replace = TRUE),
  ARM = rep(c("Placebo", "Drug"), each = 6)
)

# ----------------------------
# 3. TASKS
# ----------------------------

# Task 1:
# Create a summary table for AGE by ARM.
# Display mean ± SD.
# Include an overall column and count (n).

# Task 2:
# Create a frequency table for SEX and RACE by ARM.
# Include an overall column.

# Task 3:
# Compute a new variable "AGEGR1" as "<50" vs ">=50"
# Summarize AGEGR1 by ARM (count + %).

# Task 4 (Challenge):
# Export one of your tables to HTML using gt::gtsave()

# ----------------------------
# Notes
# ----------------------------

# Use tbl_summary(), add_overall(), add_n(), bold_labels()
# Try using mutate() from dplyr to create AGEGR1
# Use as_gt() to convert and gtsave() to export
