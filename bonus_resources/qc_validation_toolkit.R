
# qc_with_ai.R
# AI-Assisted Quality Control for Clinical Programming
# GitHub Copilot Integration for Automated QC Procedures
# Clinical Programming Training - QC Best Practices

library(dplyr)
library(tibble)
library(stringr)
library(lubridate)
library(tidyr)
library(purrr)

cat("=== AI-Assisted Clinical Data Quality Control ===\n")
cat("Comprehensive QC procedures with GitHub Copilot integration\n\n")

# =================
# Mock Clinical Data with Intentional Issues
# =================

set.seed(2024)

# Create ADSL with various data quality issues
adsl_qc <- tibble(
  STUDYID = "ABC-123",
  USUBJID = c(
    paste0("ABC-123-", sprintf("%03d", 1:18)),
    "ABC-123-019",  # Duplicate will be added
    "ABC-123-019"   # Duplicate subject
  ),
  SUBJID = c(sprintf("%03d", 1:18), "019", "019"),
  AGE = c(sample(18:75, 18, replace = TRUE), 65, NA),  # Missing age
  SEX = c(sample(c("M", "F"), 18, replace = TRUE), "X", "F"),  # Invalid sex code
  RACE = c(sample(c("WHITE", "BLACK OR AFRICAN AMERICAN", "ASIAN"), 18, replace = TRUE), 
           "white", "WHITE"),  # Inconsistent case
  TRT01P = c(sample(c("Placebo", "Study Drug 5mg", "Study Drug 10mg"), 18, replace = TRUE),
             "PLACEBO", "Study Drug 5mg"),  # Inconsistent treatment name
  TRT01PN = c(sample(c(0, 5, 10), 18, replace = TRUE), 0, 5),
  TRTSDT = c(
    rep(as.Date("2024-01-15"), 18),
    as.Date("2024-01-15"),
    as.Date("2025-01-15")  # Future date
  ),
  TRTEDT = c(
    as.Date("2024-01-15") + sample(28:84, 18, replace = TRUE),
    as.Date("2024-01-15") + 56,
    as.Date("2024-01-10")  # End before start
  ),
  SAFFL = c(rep("Y", 19), "y"),  # Inconsistent case
  ITTFL = c(rep("Y", 18), "Y", ""),  # Missing value as empty string
  DCSREAS = c(rep(NA_character_, 17), "ADVERSE EVENT", NA_character_, "Lost to follow-up")
) %>%
  mutate(
    TRTDUR = as.numeric(TRTEDT - TRTSDT) + 1
  )

# Create ADAE with quality issues
adae_qc <- tibble(
  USUBJID = c(
    sample(adsl_qc$USUBJID[1:15], 25, replace = TRUE),
    "ABC-123-999"  # Subject not in ADSL
  ),
  AESEQ = c(ave(rep(1:25, 1), rep(1:25, 1), FUN = seq_along), 1),
  AETERM = c(
    sample(c("HEADACHE", "Nausea", "FATIGUE", "dizziness"), 25, replace = TRUE),
    "headache"  # Inconsistent case
  ),
  AESEV = c(
    sample(c("MILD", "MODERATE", "SEVERE"), 25, replace = TRUE),
    "mild"  # Inconsistent case
  ),
  AESTDT = c(
    as.Date("2024-01-15") + sample(1:60, 25, replace = TRUE),
    as.Date("2023-12-01")  # Before study start
  ),
  AEREL = c(
    sample(c("NOT RELATED", "POSSIBLE", "PROBABLE"), 25, replace = TRUE),
    ""  # Missing as empty string
  ),
  TRTEMFL = c(rep("Y", 25), "N")
)

cat("Mock data created with intentional quality issues\n")

# =================
# Comprehensive QC Framework
# =================

# QC Check 1: Missing Values Analysis
qc_missing_values <- function(data, dataset_name) {
  
  cat("\n=== QC Check 1: Missing Values Analysis ===\n")
  cat("Dataset:", dataset_name, "\n")
  
  missing_summary <- data %>%
    summarise(across(everything(), ~ sum(is.na(.) | . == ""))) %>%
    pivot_longer(everything(), names_to = "Variable", values_to = "Missing_Count") %>%
    mutate(
      Total_Records = nrow(data),
      Missing_Percent = round(Missing_Count / Total_Records * 100, 1)
    ) %>%
    filter(Missing_Count > 0) %>%
    arrange(desc(Missing_Count))
  
  if (nrow(missing_summary) > 0) {
    cat("Variables with missing values:\n")
    print(missing_summary)
    
    # Flag high missingness
    high_missing <- missing_summary %>%
      filter(Missing_Percent > 10)
    
    if (nrow(high_missing) > 0) {
      cat("\n⚠️  HIGH MISSINGNESS (>10%):\n")
      print(high_missing)
    }
  } else {
    cat("✓ No missing values found\n")
  }
  
  return(missing_summary)
}

# QC Check 2: Duplicate Records
qc_duplicate_records <- function(data, key_vars, dataset_name) {
  
  cat("\n=== QC Check 2: Duplicate Records ===\n")
  cat("Dataset:", dataset_name, "\n")
  cat("Key variables:", paste(key_vars, collapse = ", "), "\n")
  
  duplicates <- data %>%
    group_by(across(all_of(key_vars))) %>%
    filter(n() > 1) %>%
    arrange(across(all_of(key_vars))) %>%
    ungroup()
  
  if (nrow(duplicates) > 0) {
    cat("🚨 DUPLICATE RECORDS FOUND:\n")
    print(duplicates)
    
    dup_count <- duplicates %>%
      group_by(across(all_of(key_vars))) %>%
      summarise(duplicate_count = n(), .groups = "drop")
    
    cat("\nDuplicate summary:\n")
    print(dup_count)
  } else {
    cat("✓ No duplicate records found\n")
  }
  
  return(duplicates)
}

# QC Check 3: Invalid Values
qc_invalid_values <- function(data, value_checks, dataset_name) {
  
  cat("\n=== QC Check 3: Invalid Values ===\n")
  cat("Dataset:", dataset_name, "\n")
  
  all_issues <- tibble()
  
  for (check_name in names(value_checks)) {
    variable <- value_checks[[check_name]]$variable
    valid_values <- value_checks[[check_name]]$valid_values
    
    if (variable %in% names(data)) {
      invalid_records <- data %>%
        filter(!is.na(.data[[variable]]) & 
               !(.data[[variable]] %in% valid_values)) %>%
        select(all_of(c("USUBJID", variable))) %>%
        mutate(
          Check = check_name,
          Variable = variable,
          Invalid_Value = as.character(.data[[variable]])
        )
      
      if (nrow(invalid_records) > 0) {
        cat("\n🚨", check_name, "- Invalid", variable, "values:\n")
        print(invalid_records)
        all_issues <- bind_rows(all_issues, invalid_records)
      } else {
        cat("✓", check_name, "- All", variable, "values valid\n")
      }
    }
  }
  
  return(all_issues)
}

# QC Check 4: Date Logic Validation
qc_date_logic <- function(data, dataset_name) {
  
  cat("\n=== QC Check 4: Date Logic Validation ===\n")
  cat("Dataset:", dataset_name, "\n")
  
  date_issues <- tibble()
  
  # Check for future dates
  if ("TRTSDT" %in% names(data)) {
    future_dates <- data %>%
      filter(!is.na(TRTSDT) & TRTSDT > Sys.Date()) %>%
      select(USUBJID, TRTSDT) %>%
      mutate(Issue = "Future treatment start date")
    
    if (nrow(future_dates) > 0) {
      cat("🚨 FUTURE DATES FOUND:\n")
      print(future_dates)
      date_issues <- bind_rows(date_issues, future_dates)
    }
  }
  
  # Check for end before start
  if (all(c("TRTSDT", "TRTEDT") %in% names(data))) {
    invalid_periods <- data %>%
      filter(!is.na(TRTSDT) & !is.na(TRTEDT) & TRTEDT < TRTSDT) %>%
      select(USUBJID, TRTSDT, TRTEDT) %>%
      mutate(Issue = "End date before start date")
    
    if (nrow(invalid_periods) > 0) {
      cat("🚨 INVALID DATE PERIODS:\n")
      print(invalid_periods)
      date_issues <- bind_rows(date_issues, invalid_periods)
    }
  }
  
  # Check for AE dates before study start (if applicable)
  if (all(c("AESTDT") %in% names(data))) {
    study_start <- as.Date("2024-01-15")  # Study-specific
    pre_study_aes <- data %>%
      filter(!is.na(AESTDT) & AESTDT < study_start) %>%
      select(USUBJID, AETERM, AESTDT) %>%
      mutate(Issue = "AE before study start")
    
    if (nrow(pre_study_aes) > 0) {
      cat("🚨 PRE-STUDY ADVERSE EVENTS:\n")
      print(pre_study_aes)
      date_issues <- bind_rows(date_issues, pre_study_aes)
    }
  }
  
  if (nrow(date_issues) == 0) {
    cat("✓ No date logic issues found\n")
  }
  
  return(date_issues)
}

# QC Check 5: Cross-Dataset Validation
qc_cross_dataset <- function(adsl_data, adae_data) {
  
  cat("\n=== QC Check 5: Cross-Dataset Validation ===\n")
  
  cross_issues <- tibble()
  
  # Check for subjects in ADAE but not in ADSL
  adsl_subjects <- unique(adsl_data$USUBJID)
  adae_subjects <- unique(adae_data$USUBJID)
  
  orphan_ae_subjects <- setdiff(adae_subjects, adsl_subjects)
  
  if (length(orphan_ae_subjects) > 0) {
    cat("🚨 SUBJECTS IN ADAE BUT NOT IN ADSL:\n")
    orphan_records <- adae_data %>%
      filter(USUBJID %in% orphan_ae_subjects) %>%
      select(USUBJID, AETERM) %>%
      mutate(Issue = "Subject in ADAE but not in ADSL")
    
    print(orphan_records)
    cross_issues <- bind_rows(cross_issues, orphan_records)
  } else {
    cat("✓ All ADAE subjects found in ADSL\n")
  }
  
  return(cross_issues)
}

# =================
# AI-Assisted QC Function
# =================

# GitHub Copilot prompt examples for QC
qc_ai_prompts <- function() {
  
  cat("\n=== GitHub Copilot QC Prompts ===\n")
  cat("Use these prompts in RStudio with GitHub Copilot:\n\n")
  
  prompts <- c(
    "# Create function to identify outliers in clinical laboratory data using IQR method",
    "# Generate data quality report showing completeness rates by treatment group",
    "# Validate CDISC SDTM compliance for adverse events domain", 
    "# Check for protocol deviations in treatment duration and dosing",
    "# Create cross-tabulation to validate treatment assignment consistency",
    "# Generate summary of data cleaning actions required for regulatory submission",
    "# Identify subjects with missing key demographic variables",
    "# Validate date variables are in proper ISO8601 format for CDISC compliance",
    "# Create automated QC report template for clinical data validation",
    "# Check laboratory values against normal reference ranges by age and sex"
  )
  
  for (i in seq_along(prompts)) {
    cat(paste0(i, ". ", prompts[i], "\n"))
  }
  
  cat("\nThese prompts help generate comprehensive QC code for clinical programming\n")
}

# =================
# Execute Comprehensive QC
# =================

cat("Executing comprehensive QC procedures...\n")

# Run all QC checks on ADSL
missing_adsl <- qc_missing_values(adsl_qc, "ADSL")
duplicates_adsl <- qc_duplicate_records(adsl_qc, c("USUBJID"), "ADSL")

# Define validation rules for ADSL
adsl_checks <- list(
  "Sex_Values" = list(variable = "SEX", valid_values = c("M", "F")),
  "Treatment_Flags" = list(variable = "SAFFL", valid_values = c("Y", "N")),
  "ITT_Flags" = list(variable = "ITTFL", valid_values = c("Y", "N")),
  "Race_Values" = list(variable = "RACE", valid_values = c("WHITE", "BLACK OR AFRICAN AMERICAN", "ASIAN", "OTHER"))
)

invalid_adsl <- qc_invalid_values(adsl_qc, adsl_checks, "ADSL")
date_issues_adsl <- qc_date_logic(adsl_qc, "ADSL")

# Run QC checks on ADAE
missing_adae <- qc_missing_values(adae_qc, "ADAE")
duplicates_adae <- qc_duplicate_records(adae_qc, c("USUBJID", "AESEQ"), "ADAE")

# Define validation rules for ADAE
adae_checks <- list(
  "Severity_Values" = list(variable = "AESEV", valid_values = c("MILD", "MODERATE", "SEVERE")),
  "Relationship_Values" = list(variable = "AEREL", valid_values = c("NOT RELATED", "UNLIKELY", "POSSIBLE", "PROBABLE"))
)

invalid_adae <- qc_invalid_values(adae_qc, adae_checks, "ADAE")
date_issues_adae <- qc_date_logic(adae_qc, "ADAE")

# Cross-dataset validation
cross_issues <- qc_cross_dataset(adsl_qc, adae_qc)

# AI prompts demonstration
qc_ai_prompts()

# =================
# QC Summary Report
# =================

cat("\n=== COMPREHENSIVE QC SUMMARY REPORT ===\n")

total_issues <- sum(
  nrow(missing_adsl), nrow(duplicates_adsl), nrow(invalid_adsl), nrow(date_issues_adsl),
  nrow(missing_adae), nrow(duplicates_adae), nrow(invalid_adae), nrow(date_issues_adae),
  nrow(cross_issues)
)

cat("Total issues identified:", total_issues, "\n")

if (total_issues > 0) {
  cat("\n🚨 DATA QUALITY ISSUES REQUIRE ATTENTION 🚨\n")
  cat("Review all flagged records and implement data cleaning procedures\n")
  cat("Consider using GitHub Copilot to generate automated fixes\n")
} else {
  cat("\n✅ ALL QC CHECKS PASSED ✅\n")
  cat("Data is ready for analysis and regulatory submission\n")
}

cat("\n=== AI-Assisted QC Complete ===\n")
cat("Use GitHub Copilot in RStudio to enhance QC procedures and automate fixes\n")

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
