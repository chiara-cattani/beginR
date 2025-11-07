# ---
# title: "Module 1 Hands-On Exercise (Student Version)"
# format: html
# editor: visual
# ---

# 🧪 Getting Started with R — Hands-On

# This document will guide you through your first real R programming task as a clinical programmer using R.  
# You’ll create and manipulate a demographics dataset, label it, summarize it, and export it.

# ---

## ✅ Part 1 — Create a Demographics Dataset

# Create a data frame named `dm` with the following columns:
# - `USUBJID`: Subject ID (e.g., "01-001", ...)
# - `AGE`: Subject's age (numeric)
# - `SEX`: "M" or "F"

# Add 5 rows with realistic values and use `head()` to view the dataset.


# Your code here


# ---

## ✅ Part 2 — Create Derived Variables

# Using `dplyr::mutate()`:
# - Add a variable `AGEGRP`:
#   - If AGE < 50 → "YOUNG"
#   - Otherwise → "OLD"
# - Add a variable `ISFEMALE`:
#   - "Yes" if SEX = "F"
#   - "No" otherwise


# Your code here


# ---

## ✅ Part 3 — Add Variable Labels

# Using the `{labelled}` package:
# - Assign labels to the variables you created:
#   - AGE: "Age at screening"
#   - SEX: "Biological sex"
#   - AGEGRP: "Age category"
#   - ISFEMALE: "Is subject female?"


# Your code here


# ---

## ✅ Part 4 — Summarize the Dataset

# Using `group_by()` and `summarise()`:
# - Summarize the number of subjects and average AGE by `AGEGRP` with standard deviation
# - Count the number of males and females


# Your code here


# ---

## ✅ Part 5 — Export to XPT Format

# Use `haven::write_xpt()` to export the dataset as `dm_demo.xpt` inside a new folder called `output`.


# Your code here


# ---

## 💡 Bonus — Copilot Prompt Practice (Optional)

# Try writing the following comment in your script and see what GitHub Copilot suggests:


# Flag subjects over 60 as elderly


# Then use the suggestion to create a new variable.

# ---

## 📊 Bonus — Plot Distribution by Sex

# Create a simple bar plot showing counts for each sex using `ggplot2`.


# Your code here


# ---

## ✅ Summary

# In this exercise, you practiced:
# - Creating and manipulating data frames
# - Adding derived variables and labels
# - Summarizing and exporting datasets
# - Using AI (Copilot) to assist coding

# You’re ready for the next module!