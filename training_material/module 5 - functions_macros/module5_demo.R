# Module 5 Demo — Functions & Macro Translation
# Comprehensive examples of creating and using functions for clinical programming

# ===========================
# SETUP: Load Required Packages
# ===========================

library(dplyr)
library(tibble)
library(lubridate)
library(stringr)
library(purrr)

# ===========================
# Part 1: Basic Function Creation
# ===========================

cat("=== Part 1: Basic Function Creation ===\n")

# Simple function: Create age categories
create_age_category <- function(age) {
  case_when(
    is.na(age) ~ "Unknown",
    age < 18 ~ "Pediatric",
    age >= 18 & age < 65 ~ "Adult",
    age >= 65 ~ "Elderly"
  )
}

# Test the function
test_ages <- c(16, 25, 45, 67, 72, NA)
cat("Age categories for", paste(test_ages, collapse = ", "), ":\n")
print(create_age_category(test_ages))

# ===========================
# Part 2: Clinical Data Processing Functions
# ===========================

cat("\n=== Part 2: Clinical Data Processing Functions ===\n")

# Create sample demographics data
dm <- tibble(
  USUBJID = paste0("001-", sprintf("%03d", 1:8)),
  AGE = c(25, 45, 67, 52, 71, 34, 58, 63),
  SEX = c("F", "M", "F", "M", "F", "F", "M", "F"),
  RFSTDTC = "2024-01-15"
)

print("Demographics data:")
print(dm)

# Function 1: Derive elderly flag
derive_elderly_flag <- function(data, age_var, cutoff = 65) {
  data %>%
    mutate(
      ELDERLY = case_when(
        is.na({{ age_var }}) ~ "U",
        {{ age_var }} >= cutoff ~ "Y",
        {{ age_var }} < cutoff ~ "N"
      )
    )
}

# Apply elderly flag function
dm_with_elderly <- dm %>%
  derive_elderly_flag(AGE)

cat("\nWith elderly flag:\n")
print(dm_with_elderly)

# Function 2: Standardize text variables
standardize_text <- function(data, text_var) {
  data %>%
    mutate(
      {{ text_var }} := {{ text_var }} %>%
        str_trim() %>%
        str_to_upper() %>%
        str_replace_all("\\s+", " ")
    )
}

# ===========================
# Part 3: SAS Macro Translation
# ===========================

cat("\n=== Part 3: SAS Macro Translation ===\n")

# Create sample AE data
ae_data <- tibble(
  USUBJID = c("001-001", "001-001", "001-002", "001-002", "001-003"),
  AESEQ = c(1, 2, 1, 2, 1),
  AEDECOD = c("  HEADACHE ", "NAUSEA", "fatigue  ", "DIZZINESS", "RASH"),
  AESTDTC = c("2024-01-20", "2024-01-25", "2024-01-18", "2024-01-22", "2024-01-26"),
  RFSTDTC = c("2024-01-15", "2024-01-15", "2024-01-16", "2024-01-16", "2024-01-15")
)

cat("Original AE data:\n")
print(ae_data)

# SAS-style macro translated to R function: Calculate study day
calc_study_day <- function(data, event_date, ref_date, new_var = "STUDY_DAY") {
  data %>%
    mutate(
      !!new_var := case_when(
        is.na(ymd({{ event_date }})) | is.na(ymd({{ ref_date }})) ~ NA_real_,
        ymd({{ event_date }}) >= ymd({{ ref_date }}) ~ as.numeric(ymd({{ event_date }}) - ymd({{ ref_date }})) + 1,
        ymd({{ event_date }}) < ymd({{ ref_date }}) ~ as.numeric(ymd({{ event_date }}) - ymd({{ ref_date }}))
      )
    )
}

# Apply study day calculation
ae_with_studyday <- ae_data %>%
  calc_study_day(AESTDTC, RFSTDTC, "AESTDY")

cat("\nWith study day calculated:\n")
print(ae_with_studyday)

# Function: Standardize AE terms (like SAS macro)
standardize_ae_terms <- function(data, ae_var) {
  data %>%
    mutate(
      {{ ae_var }} := {{ ae_var }} %>%
        str_trim() %>%
        str_to_upper() %>%
        str_replace_all("\\s+", " ")
    )
}

# Apply standardization
ae_clean <- ae_with_studyday %>%
  standardize_ae_terms(AEDECOD)

cat("\nWith standardized AE terms:\n")
print(ae_clean)

# ===========================
# Part 4: Advanced Functions with Error Handling
# ===========================

cat("\n=== Part 4: Advanced Functions with Error Handling ===\n")

# Function with validation and error handling
derive_bmi_category <- function(data, weight_var, height_var, unit = "metric") {
  # Input validation
  if (!unit %in% c("metric", "imperial")) {
    stop("unit must be either 'metric' or 'imperial'")
  }
  
  if (!all(c(deparse(substitute(weight_var)), deparse(substitute(height_var))) %in% names(data))) {
    warning("One or more specified variables not found in data")
  }
  
  data %>%
    mutate(
      BMI = case_when(
        unit == "metric" ~ {{ weight_var }} / ({{ height_var }} / 100)^2,
        unit == "imperial" ~ ({{ weight_var }} * 703) / {{ height_var }}^2
      ),
      BMI_CATEGORY = case_when(
        is.na(BMI) ~ "Unknown",
        BMI < 18.5 ~ "Underweight",
        BMI >= 18.5 & BMI < 25 ~ "Normal",
        BMI >= 25 & BMI < 30 ~ "Overweight",
        BMI >= 30 ~ "Obese"
      )
    )
}

# Create data with height/weight
demo_extended <- dm_with_elderly %>%
  mutate(
    WEIGHT = c(70, 80, 65, 75, 68, 72, 85, 62),  # kg
    HEIGHT = c(165, 175, 160, 180, 155, 170, 185, 158)  # cm
  )

# Apply BMI function
demo_with_bmi <- demo_extended %>%
  derive_bmi_category(WEIGHT, HEIGHT, unit = "metric")

cat("With BMI categories:\n")
print(demo_with_bmi %>% select(USUBJID, AGE, WEIGHT, HEIGHT, BMI, BMI_CATEGORY))

# ===========================
# Part 5: Multiple Return Options Function
# ===========================

cat("\n=== Part 5: Multiple Return Options Function ===\n")

analyze_ae_data <- function(data, return_type = "summary", group_by_severity = FALSE) {
  
  base_analysis <- data %>%
    group_by(AEDECOD) %>%
    summarise(
      n_events = n(),
      n_subjects = n_distinct(USUBJID),
      min_study_day = min(AESTDY, na.rm = TRUE),
      max_study_day = max(AESTDY, na.rm = TRUE),
      .groups = "drop"
    )
  
  switch(return_type,
    "summary" = base_analysis,
    "detailed" = base_analysis %>%
      mutate(
        event_rate = round(n_events / n_subjects, 2),
        day_range = paste0(min_study_day, "-", max_study_day)
      ),
    "count_only" = nrow(base_analysis),
    "event_names" = unique(data$AEDECOD)
  )
}

# Test different return types
cat("Summary analysis:\n")
print(analyze_ae_data(ae_clean, "summary"))

cat("\nDetailed analysis:\n")
print(analyze_ae_data(ae_clean, "detailed"))

cat("\nCount only:", analyze_ae_data(ae_clean, "count_only"), "\n")

# ===========================
# Part 6: Introduction to purrr
# ===========================

cat("\n=== Part 6: Introduction to purrr ===\n")

# Create multiple datasets to process
study_data <- list(
  study1 = tibble(
    USUBJID = c("S1-001", "S1-002", "S1-003"),
    AGE = c(45, 67, 52),
    WEIGHT = c(70, 65, 75)
  ),
  study2 = tibble(
    USUBJID = c("S2-001", "S2-002", "S2-003"),
    AGE = c(34, 71, 58),
    WEIGHT = c(68, 72, 80)
  ),
  study3 = tibble(
    USUBJID = c("S3-001", "S3-002", "S3-003"),
    AGE = c(28, 63, 49),
    WEIGHT = c(62, 78, 73)
  )
)

cat("Original study data:\n")
print(study_data)

# Function to process each study
process_study <- function(data) {
  data %>%
    derive_elderly_flag(AGE) %>%
    mutate(
      BMI = case_when(
        !is.na(WEIGHT) ~ WEIGHT / (1.70^2),  # Assuming height 170cm
        TRUE ~ NA_real_
      )
    )
}

# Apply function to all studies using purrr
processed_studies <- study_data %>%
  map(process_study)

cat("\nProcessed studies with elderly flag and BMI:\n")
print(processed_studies)

# Extract specific information from all studies
cat("\nElderly counts by study:\n")
elderly_counts <- processed_studies %>%
  map_int(~ sum(.x$ELDERLY == "Y", na.rm = TRUE))
print(elderly_counts)

# ===========================
# Part 7: Functional Programming Patterns
# ===========================

cat("\n=== Part 7: Functional Programming Patterns ===\n")

# Apply multiple functions to same data
transformation_pipeline <- list(
  add_elderly = ~ derive_elderly_flag(.x, AGE),
  add_bmi = ~ mutate(.x, BMI = WEIGHT / (1.70^2)),
  add_category = ~ mutate(.x, WEIGHT_CAT = case_when(
    WEIGHT < 70 ~ "Low",
    WEIGHT >= 70 ~ "Normal"
  ))
)

# Apply all transformations
demo_final <- demo_extended %>%
  # Use reduce to apply multiple functions sequentially
  reduce(transformation_pipeline, ~ .y(.x))

cat("Final demographics with all transformations:\n")
print(demo_final %>% select(USUBJID, AGE, WEIGHT, ELDERLY, BMI, WEIGHT_CAT))

# ===========================
# Part 8: GitHub Copilot in RStudio Practice
# ===========================

cat("\n=== Part 8: GitHub Copilot in RStudio Practice ===\n")
cat("Try writing these comments in RStudio and see what Copilot suggests:\n\n")

# Create function to flag subjects with multiple AEs


# Function to calculate percent change from baseline


# Derive safety population flag based on treatment exposure


# Function to create analysis-ready dataset with all derivations


# ===========================
# SUMMARY AND NEXT STEPS
# ===========================

cat("\n=== Module 5 Demo Complete! ===\n")
cat("Key concepts demonstrated:\n")
cat("- Basic function creation and usage\n")
cat("- SAS macro to R function translation\n")
cat("- Error handling and input validation\n")
cat("- Functions with multiple return options\n")
cat("- Functional programming with purrr\n")
cat("- Batch processing of multiple datasets\n")
cat("- GitHub Copilot in RStudio assistance\n")
cat("\nReady for hands-on practice in the exercise!\n")
