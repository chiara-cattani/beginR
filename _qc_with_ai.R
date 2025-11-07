
# qc_with_ai.R
# AI-assisted Quality Control for clinical datasets

library(dplyr)
library(stringr)

# Example dataset: ADSL
adsl <- data.frame(
  USUBJID = c("101-001", "101-002", "101-003"),
  AGE = c(35, 48, NA),
  SEX = c("M", "F", "X"),
  TRTSDT = as.Date(c("2023-01-01", "2023-02-01", "2023-03-01"))
)

# QC 1: Check for missing values
qc_missing <- adsl %>%
  summarise(across(everything(), ~ sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Missing_Count")

print("QC Check – Missing Values:")
print(qc_missing)

# QC 2: Check for unexpected SEX values
valid_sex <- c("M", "F")
qc_invalid_sex <- adsl %>%
  filter(!SEX %in% valid_sex)

print("QC Check – Invalid SEX codes:")
print(qc_invalid_sex)

# QC 3: AI-Assisted Validation Prompt
qc_prompt <- "
Check the following dataset for:
- Missing values
- Outliers in AGE
- Unexpected SEX codes
Suggest any corrections or data quality issues.

DATA:
"
cat(qc_prompt)
print(adsl)

# You would then paste the data and prompt into ChatGPT or Copilot for review.
