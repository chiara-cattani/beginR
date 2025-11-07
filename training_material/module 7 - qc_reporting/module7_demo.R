# Module 7 Demo — Post-Processing, QC & Reporting
# Comprehensive examples of clinical report generation and quality control

# ===========================
# SETUP: Load Required Packages
# ===========================

library(dplyr)
library(tibble)
library(lubridate)
library(stringr)
library(gt)
library(flextable)
library(ggplot2)

cat("=== Post-Processing, QC & Reporting Demo ===\n")
cat("Creating production-quality clinical reports with QC validation\n\n")

# ===========================
# Part 1: Create Mock Clinical Data
# ===========================

cat("=== Part 1: Mock Clinical Data Creation ===\n")

# Create comprehensive clinical dataset
set.seed(2024)

# Demographics data
demo_data <- tibble(
  USUBJID = paste0("001-", sprintf("%03d", 1:20)),
  AGE = sample(18:75, 20, replace = TRUE),
  SEX = sample(c("M", "F"), 20, replace = TRUE, prob = c(0.6, 0.4)),
  RACE = sample(c("WHITE", "BLACK OR AFRICAN AMERICAN", "ASIAN", "OTHER"), 
                20, replace = TRUE, prob = c(0.7, 0.15, 0.1, 0.05)),
  ARMCD = rep(c("PBO", "LOW", "HIGH"), length.out = 20),
  ARM = case_when(
    ARMCD == "PBO" ~ "Placebo",
    ARMCD == "LOW" ~ "Study Drug 5mg",
    ARMCD == "HIGH" ~ "Study Drug 10mg"
  ),
  RFSTDTC = as.Date("2024-01-15"),
  SAFFL = "Y",  # Safety population flag
  ITTFL = "Y"   # Intent-to-treat population flag
)

# Adverse events data
ae_data <- tibble(
  USUBJID = sample(demo_data$USUBJID, 35, replace = TRUE),
  AESEQ = ave(USUBJID, USUBJID, FUN = seq_along),
  AETERM = sample(c("HEADACHE", "NAUSEA", "FATIGUE", "DIZZINESS", "RASH", 
                    "UPPER RESPIRATORY INFECTION", "MUSCLE PAIN", "INSOMNIA",
                    "DIARRHEA", "BACK PAIN"), 35, replace = TRUE),
  AEDECOD = AETERM,  # Simplified - normally mapped to MedDRA
  AEBODSYS = case_when(
    AETERM %in% c("HEADACHE", "DIZZINESS") ~ "NERVOUS SYSTEM DISORDERS",
    AETERM %in% c("NAUSEA", "DIARRHEA") ~ "GASTROINTESTINAL DISORDERS",
    AETERM == "FATIGUE" ~ "GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS",
    AETERM == "RASH" ~ "SKIN AND SUBCUTANEOUS TISSUE DISORDERS",
    AETERM == "UPPER RESPIRATORY INFECTION" ~ "RESPIRATORY, THORACIC AND MEDIASTINAL DISORDERS",
    AETERM %in% c("MUSCLE PAIN", "BACK PAIN") ~ "MUSCULOSKELETAL AND CONNECTIVE TISSUE DISORDERS",
    AETERM == "INSOMNIA" ~ "PSYCHIATRIC DISORDERS",
    TRUE ~ "GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS"
  ),
  AESEV = sample(c("MILD", "MODERATE", "SEVERE"), 35, replace = TRUE, prob = c(0.6, 0.3, 0.1)),
  AESER = sample(c("N", "Y"), 35, replace = TRUE, prob = c(0.9, 0.1)),
  AEREL = sample(c("NOT RELATED", "UNLIKELY", "POSSIBLE", "PROBABLE"), 
                 35, replace = TRUE, prob = c(0.3, 0.3, 0.3, 0.1)),
  AEOUT = sample(c("RECOVERED/RESOLVED", "RECOVERING/RESOLVING", "NOT RECOVERED/NOT RESOLVED"), 
                 35, replace = TRUE, prob = c(0.7, 0.2, 0.1)),
  AESTDTC = as.Date("2024-01-15") + sample(1:60, 35, replace = TRUE),
  AEENDTC = AESTDTC + sample(1:14, 35, replace = TRUE)
) %>%
  left_join(demo_data %>% select(USUBJID, ARMCD, ARM, RFSTDTC), by = "USUBJID") %>%
  mutate(
    AESTDY = as.numeric(AESTDTC - RFSTDTC) + 1,
    AEENDY = as.numeric(AEENDTC - RFSTDTC) + 1
  )

# Laboratory data
lab_data <- tibble(
  USUBJID = rep(demo_data$USUBJID[1:12], each = 6),  # Subset for demo
  VISIT = rep(c("Baseline", "Week 4", "Week 8"), each = 2, times = 12),
  VISITNUM = rep(c(1, 2, 3), each = 2, times = 12),
  LBTESTCD = rep(c("HGB", "WBC"), times = 36),
  LBTEST = case_when(
    LBTESTCD == "HGB" ~ "Hemoglobin",
    LBTESTCD == "WBC" ~ "White Blood Cell Count"
  ),
  LBSTRESN = case_when(
    LBTESTCD == "HGB" ~ round(rnorm(72, mean = 13.5, sd = 1.5), 1),
    LBTESTCD == "WBC" ~ round(rnorm(72, mean = 7.2, sd = 2.1), 2)
  ),
  LBSTRESU = case_when(
    LBTESTCD == "HGB" ~ "g/dL",
    LBTESTCD == "WBC" ~ "10^9/L"
  ),
  LBNRIND = case_when(
    LBTESTCD == "HGB" & LBSTRESN < 12.0 ~ "LOW",
    LBTESTCD == "HGB" & LBSTRESN > 16.0 ~ "HIGH",
    LBTESTCD == "WBC" & LBSTRESN < 4.0 ~ "LOW", 
    LBTESTCD == "WBC" & LBSTRESN > 11.0 ~ "HIGH",
    TRUE ~ "NORMAL"
  )
) %>%
  left_join(demo_data %>% select(USUBJID, ARMCD, ARM), by = "USUBJID")

print("Demo Data Created:")
print(paste("Demographics:", nrow(demo_data), "subjects"))
print(paste("Adverse Events:", nrow(ae_data), "events"))
print(paste("Laboratory:", nrow(lab_data), "results"))

# ===========================
# Part 2: Data Formatting Functions
# ===========================

cat("\n=== Part 2: Data Formatting Functions ===\n")

# Format numeric values
format_number <- function(x, digits = 1) {
  case_when(
    is.na(x) ~ "Missing",
    TRUE ~ format(round(x, digits), nsmall = digits)
  )
}

# Format percentages
format_percent <- function(x, digits = 1) {
  case_when(
    is.na(x) ~ "Missing",
    TRUE ~ paste0(format(round(x, digits), nsmall = digits), "%")
  )
}

# Format mean (SD)
format_mean_sd <- function(mean_val, sd_val, digits = 1) {
  case_when(
    is.na(mean_val) | is.na(sd_val) ~ "Missing",
    TRUE ~ paste0(
      format(round(mean_val, digits), nsmall = digits),
      " (",
      format(round(sd_val, digits), nsmall = digits),
      ")"
    )
  )
}

# Format n (%)
format_n_pct <- function(n, total, digits = 1) {
  pct <- n / total * 100
  paste0(n, " (", format(round(pct, digits), nsmall = digits), "%)")
}

cat("Formatting functions created\n")

# ===========================
# Part 3: Quality Control Functions
# ===========================

cat("\n=== Part 3: Quality Control Functions ===\n")

# Check for missing required variables
check_required_vars <- function(data, required_vars, dataset_name = "Dataset") {
  missing_vars <- setdiff(required_vars, names(data))
  
  if (length(missing_vars) > 0) {
    warning(paste0(dataset_name, " missing required variables: ", 
                   paste(missing_vars, collapse = ", ")))
    return(FALSE)
  }
  
  cat(paste0(dataset_name, " has all required variables ✓\n"))
  return(TRUE)
}

# Validate data ranges
validate_data_ranges <- function(data, variable, min_val = NULL, max_val = NULL) {
  var_data <- data[[variable]]
  issues <- c()
  
  if (!is.null(min_val)) {
    below_min <- sum(var_data < min_val, na.rm = TRUE)
    if (below_min > 0) {
      issues <- c(issues, paste0(below_min, " values below ", min_val))
    }
  }
  
  if (!is.null(max_val)) {
    above_max <- sum(var_data > max_val, na.rm = TRUE)
    if (above_max > 0) {
      issues <- c(issues, paste0(above_max, " values above ", max_val))
    }
  }
  
  if (length(issues) == 0) {
    cat("No range issues found ✓\n")
  } else {
    cat("Range issues:", paste(issues, collapse = "; "), "\n")
  }
  
  return(issues)
}

# Comprehensive data validation
validate_clinical_data <- function(demo_data, ae_data, lab_data) {
  
  validation_results <- list()
  
  cat("Validating Demographics Data:\n")
  validation_results$demo_vars <- check_required_vars(
    demo_data, c("USUBJID", "AGE", "SEX", "ARMCD"), "Demographics"
  )
  validation_results$age_range <- validate_data_ranges(demo_data, "AGE", 18, 85)
  
  cat("\nValidating Adverse Events Data:\n")
  validation_results$ae_vars <- check_required_vars(
    ae_data, c("USUBJID", "AESEQ", "AETERM", "AESEV"), "Adverse Events"
  )
  
  # Check for duplicate AE keys
  ae_dups <- ae_data %>%
    group_by(USUBJID, AESEQ) %>%
    filter(n() > 1) %>%
    nrow()
  
  if (ae_dups > 0) {
    warning("Found ", ae_dups, " duplicate USUBJID/AESEQ combinations")
    validation_results$ae_duplicates <- ae_dups
  } else {
    cat("No duplicate AE keys found ✓\n")
    validation_results$ae_duplicates <- 0
  }
  
  cat("\nValidating Laboratory Data:\n")
  validation_results$lab_vars <- check_required_vars(
    lab_data, c("USUBJID", "LBTESTCD", "LBSTRESN"), "Laboratory"
  )
  
  return(validation_results)
}

# Run comprehensive validation
validation_report <- validate_clinical_data(demo_data, ae_data, lab_data)

# ===========================
# Part 4: Create Production-Quality Tables with gt
# ===========================

cat("\n=== Part 4: Creating Tables with gt ===\n")

# Demographics summary table
create_demographics_table <- function(data) {
  
  demo_summary <- data %>%
    group_by(ARM) %>%
    summarise(
      n = n(),
      age_mean = mean(AGE, na.rm = TRUE),
      age_sd = sd(AGE, na.rm = TRUE),
      age_min = min(AGE, na.rm = TRUE),
      age_max = max(AGE, na.rm = TRUE),
      male_n = sum(SEX == "M", na.rm = TRUE),
      male_pct = male_n / n * 100,
      .groups = "drop"
    ) %>%
    mutate(
      age_mean_sd = format_mean_sd(age_mean, age_sd, 1),
      age_range = paste0(age_min, "-", age_max),
      male_n_pct = format_n_pct(male_n, n, 1)
    ) %>%
    select(ARM, n, age_mean_sd, age_range, male_n_pct)
  
  # Add total column
  total_summary <- data %>%
    summarise(
      ARM = "Total",
      n = n(),
      age_mean_sd = format_mean_sd(mean(AGE, na.rm = TRUE), sd(AGE, na.rm = TRUE), 1),
      age_range = paste0(min(AGE, na.rm = TRUE), "-", max(AGE, na.rm = TRUE)),
      male_n_pct = format_n_pct(sum(SEX == "M", na.rm = TRUE), n, 1)
    )
  
  final_summary <- bind_rows(demo_summary, total_summary)
  
  # Create gt table
  gt_table <- final_summary %>%
    gt() %>%
    cols_label(
      ARM = "Treatment Arm",
      n = "N",
      age_mean_sd = "Age, years",
      age_range = "Age Range",
      male_n_pct = "Male, n (%)"
    ) %>%
    tab_header(
      title = "Subject Demographics and Baseline Characteristics",
      subtitle = "Safety Population"
    ) %>%
    tab_footnote(
      footnote = "Age presented as mean (SD)",
      locations = cells_column_labels(columns = age_mean_sd)
    ) %>%
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_column_labels()
    ) %>%
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_body(rows = ARM == "Total")
    ) %>%
    tab_options(
      table.font.size = 12,
      heading.title.font.size = 14,
      heading.subtitle.font.size = 12,
      table.border.top.style = "solid",
      table.border.bottom.style = "solid"
    ) %>%
    opt_align_table_header(align = "center")
  
  return(gt_table)
}

# Create and display demographics table
demo_table <- create_demographics_table(demo_data)
print("Demographics table created successfully")

# AE summary table by system organ class
create_ae_summary_table <- function(ae_data, demo_data) {
  
  # Calculate denominators by treatment
  denominators <- demo_data %>%
    count(ARM, name = "total_subjects")
  
  ae_summary <- ae_data %>%
    group_by(ARM, AEBODSYS) %>%
    summarise(
      n_events = n(),
      n_subjects = n_distinct(USUBJID),
      .groups = "drop"
    ) %>%
    left_join(denominators, by = "ARM") %>%
    mutate(
      subjects_pct = n_subjects / total_subjects * 100,
      formatted = format_n_pct(n_subjects, total_subjects, 1)
    ) %>%
    select(ARM, AEBODSYS, formatted) %>%
    pivot_wider(names_from = ARM, values_from = formatted, values_fill = "0 (0.0%)")
  
  # Create gt table
  gt_table <- ae_summary %>%
    gt() %>%
    cols_label(
      AEBODSYS = "System Organ Class"
    ) %>%
    tab_header(
      title = "Adverse Events by System Organ Class",
      subtitle = "Number of Subjects with Events, n (%)"
    ) %>%
    tab_footnote(
      footnote = "Subjects counted once per system organ class",
      locations = cells_column_labels(columns = AEBODSYS)
    ) %>%
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_column_labels()
    ) %>%
    tab_options(
      table.font.size = 11,
      heading.title.font.size = 14,
      table.border.top.style = "solid",
      table.border.bottom.style = "solid"
    ) %>%
    opt_align_table_header(align = "center")
  
  return(gt_table)
}

# Create AE summary table
ae_summary_table <- create_ae_summary_table(ae_data, demo_data)
print("AE summary table created successfully")

# ===========================
# Part 5: Create Production-Quality Tables (Future: SAS Validation Demo)
# ===========================

cat("\n=== Part 5: Creating Tables with flextable ===\n")
cat("NOTE: This section will be replaced with SAS validation demos\n")
cat("showing how to validate R-created datasets using SAS procedures\n\n")

# Laboratory summary table using flextable (temporary - will become SAS validation)
create_lab_summary_flextable <- function(lab_data) {
  
  lab_summary <- lab_data %>%
    filter(VISIT == "Week 8") %>%  # Focus on endpoint visit
    group_by(ARM, LBTEST) %>%
    summarise(
      n = n(),
      mean_val = mean(LBSTRESN, na.rm = TRUE),
      sd_val = sd(LBSTRESN, na.rm = TRUE),
      median_val = median(LBSTRESN, na.rm = TRUE),
      q1_val = quantile(LBSTRESN, 0.25, na.rm = TRUE),
      q3_val = quantile(LBSTRESN, 0.75, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      mean_sd = format_mean_sd(mean_val, sd_val, 2),
      median_q1q3 = paste0(
        format(round(median_val, 2), nsmall = 2), " (",
        format(round(q1_val, 2), nsmall = 2), ", ",
        format(round(q3_val, 2), nsmall = 2), ")"
      )
    ) %>%
    select(ARM, LBTEST, n, mean_sd, median_q1q3) %>%
    pivot_wider(
      names_from = ARM,
      values_from = c(n, mean_sd, median_q1q3),
      names_sep = "_"
    )
  
  # Create flextable
  ft <- lab_summary %>%
    flextable() %>%
    set_header_labels(
      LBTEST = "Laboratory Parameter"
    ) %>%
    add_header_row(
      values = c("", rep(c("Placebo", "Study Drug 5mg", "Study Drug 10mg"), each = 3)),
      colwidths = c(1, rep(3, 3))
    ) %>%
    set_header_labels(
      values = list(
        n_Placebo = "N",
        mean_sd_Placebo = "Mean (SD)",
        median_q1q3_Placebo = "Median (Q1, Q3)",
        `n_Study Drug 5mg` = "N",
        `mean_sd_Study Drug 5mg` = "Mean (SD)",
        `median_q1q3_Study Drug 5mg` = "Median (Q1, Q3)",
        `n_Study Drug 10mg` = "N",
        `mean_sd_Study Drug 10mg` = "Mean (SD)",
        `median_q1q3_Study Drug 10mg` = "Median (Q1, Q3)"
      ),
      part = "header"
    ) %>%
    theme_vanilla() %>%
    align(align = "center", part = "header") %>%
    align(j = 1, align = "left", part = "all") %>%
    bold(part = "header") %>%
    fontsize(size = 10, part = "all") %>%
    fontsize(size = 11, part = "header") %>%
    width(j = 1, width = 2) %>%
    width(j = 2:10, width = 1)
  
  return(ft)
}

# Create laboratory summary
lab_flextable <- create_lab_summary_flextable(lab_data)
print("Laboratory flextable created successfully")
print("Future: This will be replaced with SAS validation procedures")

# ===========================
# Part 6: Advanced QC Procedures
# ===========================

cat("\n=== Part 6: Advanced QC Procedures ===\n")

# Cross-validation function
cross_validate_datasets <- function(demo_data, ae_data, lab_data) {
  
  cat("Cross-validating datasets...\n")
  
  # Check subject consistency across datasets
  demo_subjects <- unique(demo_data$USUBJID)
  ae_subjects <- unique(ae_data$USUBJID)
  lab_subjects <- unique(lab_data$USUBJID)
  
  # Subjects in AE but not in demo
  ae_orphans <- setdiff(ae_subjects, demo_subjects)
  if (length(ae_orphans) > 0) {
    warning("Subjects in AE data but not in demographics: ", 
            paste(ae_orphans, collapse = ", "))
  }
  
  # Subjects in lab but not in demo
  lab_orphans <- setdiff(lab_subjects, demo_subjects)
  if (length(lab_orphans) > 0) {
    warning("Subjects in lab data but not in demographics: ", 
            paste(lab_orphans, collapse = ", "))
  }
  
  # Treatment arm consistency
  demo_arms <- demo_data %>% select(USUBJID, ARM)
  ae_arms <- ae_data %>% distinct(USUBJID, ARM) 
  
  arm_conflicts <- ae_arms %>%
    left_join(demo_arms, by = "USUBJID", suffix = c("_ae", "_demo")) %>%
    filter(ARM_ae != ARM_demo) %>%
    nrow()
  
  if (arm_conflicts > 0) {
    warning("Found ", arm_conflicts, " treatment arm conflicts between datasets")
  } else {
    cat("No treatment arm conflicts found ✓\n")
  }
  
  cat("Cross-validation completed\n")
}

# Run cross-validation
cross_validate_datasets(demo_data, ae_data, lab_data)

# Data completeness report
generate_completeness_report <- function(demo_data, ae_data, lab_data) {
  
  cat("\n=== Data Completeness Report ===\n")
  
  # Demographics completeness
  demo_complete <- demo_data %>%
    summarise(
      across(everything(), ~ sum(!is.na(.)) / length(.)) * 100
    ) %>%
    pivot_longer(everything(), names_to = "Variable", values_to = "Completeness") %>%
    mutate(Dataset = "Demographics")
  
  # AE completeness
  ae_complete <- ae_data %>%
    select(USUBJID, AETERM, AESEV, AEREL, AEOUT) %>%
    summarise(
      across(everything(), ~ sum(!is.na(.)) / length(.)) * 100
    ) %>%
    pivot_longer(everything(), names_to = "Variable", values_to = "Completeness") %>%
    mutate(Dataset = "Adverse Events")
  
  # Lab completeness
  lab_complete <- lab_data %>%
    select(USUBJID, LBTESTCD, LBSTRESN, LBNRIND) %>%
    summarise(
      across(everything(), ~ sum(!is.na(.)) / length(.)) * 100
    ) %>%
    pivot_longer(everything(), names_to = "Variable", values_to = "Completeness") %>%
    mutate(Dataset = "Laboratory")
  
  # Combine and display
  completeness_report <- bind_rows(demo_complete, ae_complete, lab_complete) %>%
    arrange(Dataset, Variable)
  
  print(completeness_report)
  
  # Identify variables with low completeness
  low_completeness <- completeness_report %>%
    filter(Completeness < 95) %>%
    arrange(Completeness)
  
  if (nrow(low_completeness) > 0) {
    cat("\nVariables with < 95% completeness:\n")
    print(low_completeness)
  } else {
    cat("\nAll variables have ≥ 95% completeness ✓\n")
  }
  
  return(completeness_report)
}

# Generate completeness report
completeness_report <- generate_completeness_report(demo_data, ae_data, lab_data)

# ===========================
# Part 7: Export and File Management
# ===========================

cat("\n=== Part 7: Export and File Management ===\n")

# Create export directory
export_dir <- "output/clinical_reports"
if (!dir.exists(export_dir)) {
  dir.create(export_dir, recursive = TRUE)
  cat("Created export directory:", export_dir, "\n")
}

# Export function with metadata
export_clinical_table <- function(table_object, filename, table_type = "gt") {
  
  # Create full path
  full_path <- file.path(export_dir, filename)
  
  # Export based on table type
  if (table_type == "gt") {
    table_object %>%
      gtsave(full_path)
  } else if (table_type == "flextable") {
    save_as_docx(table_object, path = gsub("\\.html$", ".docx", full_path))
  }
  
  # Create metadata file
  metadata <- list(
    filename = filename,
    table_type = table_type,
    created_date = Sys.time(),
    created_by = Sys.info()["user"],
    r_version = R.version.string,
    package_versions = list(
      dplyr = as.character(packageVersion("dplyr")),
      gt = as.character(packageVersion("gt")),
      flextable = as.character(packageVersion("flextable"))
    )
  )
  
  # Save metadata as JSON-style text file
  metadata_file <- gsub("\\.(html|docx)$", "_metadata.txt", full_path)
  writeLines(
    c(
      paste("Table:", filename),
      paste("Created:", metadata$created_date),
      paste("Created by:", metadata$created_by),
      paste("R version:", metadata$r_version),
      paste("dplyr version:", metadata$package_versions$dplyr),
      paste("gt version:", metadata$package_versions$gt),
      paste("flextable version:", metadata$package_versions$flextable)
    ),
    metadata_file
  )
  
  cat("Exported:", full_path, "\n")
  cat("Metadata:", metadata_file, "\n")
}

# Export all tables (commented to avoid actual file creation in demo)
# export_clinical_table(demo_table, "demographics_table.html", "gt")
# export_clinical_table(ae_summary_table, "ae_summary_table.html", "gt")
# export_clinical_table(lab_flextable, "lab_summary_table.docx", "flextable")

cat("Export functions ready (commented to avoid file creation)\n")

# ===========================
# Part 8: GitHub Copilot Best Practices for Clinical Reporting
# ===========================

cat("\n=== Part 8: GitHub Copilot Best Practices ===\n")

# Example of good Copilot prompts for clinical programming
cat("
=== GitHub Copilot in RStudio: Clinical Reporting Tips ===

1. Use specific, clinical-focused prompts:
   # Create AE summary table with SOC grouping for regulatory submission
   # Generate demographics table following ICH E3 guidelines
   # Calculate lab shift tables with normal range indicators

2. Request validation functions:
   # Create function to validate CDISC SDTM compliance
   # Generate QC checks for missing required variables
   # Build cross-dataset consistency validation

3. Ask for regulatory-compliant formatting:
   # Format table following FDA statistical guidance
   # Create footnotes with clinical study context
   # Generate headers with population definitions

4. Leverage Copilot for complex clinical derivations:
   # Calculate time-to-event endpoints with censoring
   # Derive treatment-emergent adverse events
   # Create analysis flag derivations for populations

Examples of effective Copilot interactions in RStudio:
- 'Create a function to calculate the proportion of subjects with treatment-emergent adverse events by system organ class'
- 'Generate a laboratory outliers table showing values outside normal ranges'
- 'Build validation checks for CDISC compliance in SDTM datasets'
")

# ===========================
# Summary and Key Takeaways
# ===========================

cat("\n=== MODULE 7 DEMO COMPLETE ===\n")
cat("
Key skills demonstrated:
✓ Mock clinical data creation with realistic structure
✓ Comprehensive data validation and QC procedures  
✓ Production-quality table creation with gt (flextable section will become SAS validation)
✓ Advanced formatting functions for clinical reporting
✓ Cross-dataset validation and completeness checking
✓ Export management with metadata tracking
✓ GitHub Copilot integration for clinical programming

This module brings together all previous skills for complete
clinical reporting workflows from data validation through 
final regulatory-ready deliverables.

FUTURE ENHANCEMENT: The flextable section will be replaced with 
SAS validation procedures showing how to validate R-created 
datasets using SAS, demonstrating R-SAS interoperability.
")

cat("\nReady for Module 7 Exercise!\n")

