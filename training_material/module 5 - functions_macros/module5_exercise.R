# Module 5 Exercise — Functions & Macro Translation
# Practice creating and using functions for clinical programming

# ===========================
# SETUP: Load Required Packages
# ===========================

library(dplyr)
library(tibble)
library(lubridate)
library(stringr)
library(purrr)

# ===========================
# EXERCISE 1: Basic Function Creation
# ===========================

# Create sample clinical data
demo <- tibble(
  USUBJID = paste0("001-", sprintf("%03d", 1:10)),
  AGE = c(23, 45, 67, 52, 71, 34, 58, 63, 29, 76),
  SEX = c("F", "M", "F", "M", "F", "F", "M", "F", "M", "F"),
  WEIGHT = c(65, 80, 58, 75, 62, 70, 85, 60, 78, 55),
  HEIGHT = c(160, 175, 155, 180, 158, 165, 185, 162, 172, 150),
  RFSTDTC = "2024-01-15"
)

# YOUR TASK 1: Create a function to categorize BMI
# Function should:
# 1. Calculate BMI from weight (kg) and height (cm)  
# 2. Categorize as: "Underweight" (<18.5), "Normal" (18.5-24.9), "Overweight" (25-29.9), "Obese" (≥30)
# 3. Handle missing values appropriately

create_bmi_category <- function(data, weight_var, height_var) {
  # YOUR CODE HERE
  # Hint: BMI = weight_kg / (height_cm / 100)^2
  
}

# Test your function
demo_with_bmi <- demo %>%
  create_bmi_category(WEIGHT, HEIGHT)

print("BMI categories:")
print(demo_with_bmi %>% select(USUBJID, WEIGHT, HEIGHT, BMI, BMI_CATEGORY))

# YOUR TASK 2: Create an age group function
# Function should categorize age as: "18-30", "31-50", "51-65", ">65", "Unknown" (for missing)

create_age_groups <- function(data, age_var) {
  # YOUR CODE HERE
  
}

# Test your function
demo_with_age_groups <- demo_with_bmi %>%
  create_age_groups(AGE)

print("Age groups:")
print(demo_with_age_groups %>% select(USUBJID, AGE, AGE_GROUP))

# ===========================
# EXERCISE 2: SAS Macro Translation
# ===========================

# Create adverse events data
ae_data <- tibble(
  USUBJID = c("001-001", "001-001", "001-002", "001-002", "001-003", "001-003"),
  AESEQ = c(1, 2, 1, 2, 1, 2),
  AEDECOD = c("  headache ", "NAUSEA", "fatigue", "  DIZZINESS  ", "rash", "COUGH"),
  AESTDTC = c("2024-01-20", "2024-01-25", "2024-01-18", "2024-01-22", "2024-01-26", "2024-01-28"),
  AEENDTC = c("2024-01-22", "2024-01-26", "2024-01-20", "2024-01-23", "2024-01-28", "2024-01-30"),
  RFSTDTC = c("2024-01-15", "2024-01-15", "2024-01-16", "2024-01-16", "2024-01-15", "2024-01-15")
)

print("Original AE data:")
print(ae_data)

# YOUR TASK 3: Translate this SAS macro to R function
# SAS Macro (example):
# %macro derive_studyday(indata=, outdata=, eventdt=, refdt=, studyday=);
#   data &outdata;
#     set &indata;
#     if not missing(&eventdt) and not missing(&refdt) then do;
#       if &eventdt >= &refdt then &studyday = &eventdt - &refdt + 1;
#       else &studyday = &eventdt - &refdt;
#     end;
#   run;
# %mend derive_studyday;

derive_study_day <- function(data, event_date_var, ref_date_var, new_var_name = "STUDY_DAY") {
  # YOUR CODE HERE
  # Remember: Study day = event_date - ref_date + 1 (if event >= ref)
  #          Study day = event_date - ref_date (if event < ref)
  # Handle missing dates appropriately
  
}

# Test your function for start dates
ae_with_aestdy <- ae_data %>%
  derive_study_day(AESTDTC, RFSTDTC, "AESTDY")

print("With AESTDY:")
print(ae_with_aestdy %>% select(USUBJID, AESEQ, AESTDTC, RFSTDTC, AESTDY))

# YOUR TASK 4: Create another function for end study day
ae_with_both_days <- ae_with_aestdy %>%
  derive_study_day(AEENDTC, RFSTDTC, "AEENDY")

print("With both study days:")
print(ae_with_both_days %>% select(USUBJID, AESEQ, AESTDY, AEENDY))

# ===========================
# EXERCISE 3: Advanced Functions with Error Handling
# ===========================

# YOUR TASK 5: Create a comprehensive AE processing function
# Function should:
# 1. Standardize AE terms (trim, uppercase)
# 2. Calculate study days for start and end
# 3. Calculate duration in days
# 4. Add validation flags
# 5. Include error handling

process_ae_data <- function(data, ae_term_var, start_date_var, end_date_var, ref_date_var) {
  # YOUR CODE HERE
  # Include input validation, error handling, and all processing steps
  
}

# Test your comprehensive function
processed_ae <- ae_data %>%
  process_ae_data(AEDECOD, AESTDTC, AEENDTC, RFSTDTC)

print("Fully processed AE data:")
print(processed_ae)

# ===========================
# EXERCISE 4: Functions with Multiple Return Options
# ===========================

# YOUR TASK 6: Create an analysis function with different return types
# Function should analyze AE data and return different formats based on parameter

analyze_ae_summary <- function(data, return_type = "basic") {
  # return_type options: "basic", "detailed", "counts_only", "subject_summary"
  # YOUR CODE HERE
  
}

# Test different return types
print("Basic summary:")
print(analyze_ae_summary(processed_ae, "basic"))

print("Detailed summary:")
print(analyze_ae_summary(processed_ae, "detailed"))

print("Counts only:")
print(analyze_ae_summary(processed_ae, "counts_only"))

# ===========================
# EXERCISE 5: Introduction to purrr
# ===========================

# Create multiple study datasets
study_datasets <- list(
  study_a = tibble(
    USUBJID = c("A-001", "A-002", "A-003"),
    AGE = c(45, 67, 34),
    WEIGHT = c(70, 65, 75),
    SEX = c("M", "F", "M")
  ),
  study_b = tibble(
    USUBJID = c("B-001", "B-002", "B-003"),
    AGE = c(52, 71, 58),
    WEIGHT = c(68, 72, 80),
    SEX = c("F", "F", "M")
  ),
  study_c = tibble(
    USUBJID = c("C-001", "C-002", "C-003"),
    AGE = c(29, 63, 41),
    WEIGHT = c(62, 78, 73),
    SEX = c("M", "F", "M")
  )
)

# YOUR TASK 7: Use purrr to apply functions to all studies
# 1. Apply your age group function to all studies
# 2. Apply your BMI function to all studies (assume height = 170cm for all)
# 3. Extract summary statistics from each study

# Process all studies with age groups
studies_with_age_groups <- # YOUR CODE HERE

# Process all studies with BMI (assuming height = 170cm)
studies_with_bmi <- # YOUR CODE HERE

# Extract elderly counts from each study (age >= 65)
elderly_counts_by_study <- # YOUR CODE HERE

print("Elderly counts by study:")
print(elderly_counts_by_study)

# ===========================
# EXERCISE 6: GitHub Copilot in RStudio Practice
# ===========================

# YOUR TASK 8: Use GitHub Copilot in RStudio to help create these functions
# Write the comments below and let Copilot suggest the implementations

# Create function to flag subjects with multiple adverse events


# Function to calculate time to first adverse event


# Create safety population flag based on exposure duration


# Function to derive CDISC-compliant variable labels


# Function to export processed data to multiple formats


# ===========================
# BONUS CHALLENGE: Complex Function Pipeline
# ===========================

# YOUR TASK 9: Create a complete data processing pipeline function
# Function should take raw clinical data and:
# 1. Clean and standardize all text variables
# 2. Derive all date-related variables
# 3. Create analysis flags
# 4. Add validation checks
# 5. Generate a processing summary report

create_analysis_dataset <- function(demo_data, ae_data, output_format = "processed") {
  # YOUR CODE HERE - Create a comprehensive processing pipeline
  
}

# Test your pipeline function
final_analysis_data <- create_analysis_dataset(demo, ae_data)

# ===========================
# EXERCISE COMPLETE!
# ===========================

cat("\n🎉 Module 5 Exercise Complete!\n")
cat("Functions you practiced:\n")
cat("- Basic function creation and usage\n")
cat("- SAS macro to R function translation\n")
cat("- Advanced functions with error handling\n")
cat("- Functions with multiple return options\n")
cat("- Functional programming with purrr\n")
cat("- GitHub Copilot in RStudio assistance\n")
cat("- Complex data processing pipelines\n")
cat("\nExcellent work! Ready for Module 6: SDTM Programming with sdtm.oak!\n")
