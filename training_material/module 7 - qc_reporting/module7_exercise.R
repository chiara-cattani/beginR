# Module 7 Exercise — Post-Processing, QC & Reporting Challenge
# Advanced clinical programming exercise integrating all course concepts

# 🎯 EXERCISE OBJECTIVES:
# 1. Create comprehensive clinical datasets with realistic complexity
# 2. Implement robust QC procedures and validation checks
# 3. Generate regulatory-compliant summary tables and listings
# 4. Apply advanced formatting and export management
# 5. Use GitHub Copilot in RStudio for clinical programming tasks

# 📦 Required Libraries
library(dplyr)
library(tibble)
library(lubridate)
library(stringr)
library(tidyr)
library(gt)
library(flextable)  # Note: flextable sections will be replaced with SAS validation
library(ggplot2)

# Print exercise header
cat("=== MODULE 7 EXERCISE: Post-Processing, QC & Reporting ===\n")
cat("Complete the following challenges to demonstrate mastery\n")
cat("of clinical programming and reporting skills.\n")
cat("NOTE: flextable sections will be replaced with SAS validation demos\n\n")

# =====================================================
# CHALLENGE 1: Enhanced Mock Data Creation (20 points)
# =====================================================

cat("=== CHALLENGE 1: Enhanced Mock Data Creation ===\n")
cat("Create realistic clinical trial datasets with the following requirements:\n\n")

# YOUR TASK: Create comprehensive clinical datasets
# Requirements:
# - Demographics: 30 subjects across 3 treatment arms (Placebo, Low Dose, High Dose)
# - Include: USUBJID, AGE (18-80), SEX, RACE, ETHNIC, COUNTRY, ARMCD, ARM
# - Add population flags: SAFFL, ITTFL, PPROTFL
# - Adverse Events: 50+ events across multiple system organ classes
# - Include: USUBJID, AESEQ, AETERM, AEDECOD, AEBODSYS, AESEV, AESER, AEREL
# - Add start/end dates and study day calculations
# - Laboratory Data: Hematology and chemistry parameters
# - Include: USUBJID, VISIT, VISITNUM, LBTESTCD, LBTEST, LBSTRESN, LBSTRESU
# - Add normal range indicators (LBNRIND)

# TODO: Use set.seed(2024) for reproducibility
# TODO: Create demo_data, ae_data, and lab_data tibbles
# TODO: Ensure realistic distributions and clinical relevance

# Hint: Use GitHub Copilot prompt:
# "# Create realistic clinical trial demographics data with 30 subjects across 3 arms"

set.seed(2024)

# YOUR CODE HERE:
demo_data <- # TODO: Create demographics dataset

ae_data <- # TODO: Create adverse events dataset

lab_data <- # TODO: Create laboratory dataset

# VALIDATION: Check your data structure
# TODO: Add validation checks to ensure data quality
# - Check for required variables
# - Validate ranges (e.g., AGE 18-80)
# - Ensure no duplicate keys

cat("Challenge 1 Status: Data creation _____ (complete/incomplete)\n\n")

# =====================================================
# CHALLENGE 2: Advanced QC Functions (25 points)
# =====================================================

cat("=== CHALLENGE 2: Advanced QC Functions ===\n")
cat("Implement comprehensive quality control procedures:\n\n")

# YOUR TASK: Create robust QC validation functions
# Requirements:
# 1. validate_demographics() - Check demographics completeness and ranges
# 2. validate_ae_data() - Validate AE data structure and consistency  
# 3. cross_dataset_checks() - Check subject consistency across datasets
# 4. generate_data_profile() - Create comprehensive data profiling report

# TODO: Implement the following functions:

validate_demographics <- function(data) {
  # TODO: Implement demographics validation
  # Check for: required variables, age ranges, valid values for categorical vars
  # Return: list of validation results with pass/fail status
}

validate_ae_data <- function(data) {
  # TODO: Implement AE validation
  # Check for: duplicate USUBJID/AESEQ, valid severity levels, date consistency
  # Return: validation summary with issue counts
}

cross_dataset_checks <- function(demo, ae, lab) {
  # TODO: Cross-dataset validation
  # Check for: subjects in AE/lab but not in demo, treatment arm consistency
  # Return: cross-validation report
}

generate_data_profile <- function(demo, ae, lab) {
  # TODO: Comprehensive data profiling
  # Include: record counts, completeness rates, value distributions
  # Return: formatted profiling report
}

# Hint: Use GitHub Copilot prompt:
# "# Create clinical data validation function checking for missing values and outliers"

# YOUR CODE HERE:
# TODO: Implement all four functions above

cat("Challenge 2 Status: QC functions _____ (complete/incomplete)\n\n")

# =====================================================
# CHALLENGE 3: Production Tables with gt (20 points)
# =====================================================

cat("=== CHALLENGE 3: Production Tables with gt ===\n")
cat("Create regulatory-quality summary tables:\n\n")

# YOUR TASK: Create professional clinical summary tables
# Requirements:
# 1. Demographics table with proper formatting and footnotes
# 2. AE summary by system organ class and preferred term
# 3. Laboratory shift table showing baseline to endpoint changes

# TODO: Implement the following table functions:

create_demographics_gt <- function(data) {
  # TODO: Create demographics summary table
  # Include: N, Age (mean/SD, min-max), Sex n(%), Race n(%)
  # Format: Professional headers, footnotes, styling
  # Return: gt table object
}

create_ae_summary_gt <- function(ae_data, demo_data) {
  # TODO: Create AE summary table
  # Include: System organ class and preferred term
  # Show: subjects with events n(%) by treatment arm
  # Format: Hierarchical structure, proper clinical formatting
  # Return: gt table object
}

create_lab_shift_gt <- function(lab_data) {
  # TODO: Create laboratory shift table
  # Show: Normal/Abnormal at baseline vs endpoint
  # Include: shift categories (Normal→High, Low→Normal, etc.)
  # Format: Clinical standard presentation
  # Return: gt table object
}

# Hint: Use GitHub Copilot prompt:
# "# Create clinical demographics table with gt package showing treatment arms"

# YOUR CODE HERE:
# TODO: Implement all three table functions above

cat("Challenge 3 Status: gt tables _____ (complete/incomplete)\n\n")

# =====================================================
# CHALLENGE 4: Advanced Formatting Functions (15 points)
# =====================================================

cat("=== CHALLENGE 4: Advanced Formatting Functions ===\n")
cat("Create comprehensive clinical formatting utilities:\n\n")

# YOUR TASK: Build clinical-specific formatting functions
# Requirements:
# 1. Advanced number formatting with missing value handling
# 2. Clinical statistics formatting (mean±SD, median[Q1,Q3])  
# 3. Regulatory-compliant percentage formatting
# 4. Date formatting for clinical contexts

# TODO: Implement sophisticated formatting functions:

format_clinical_number <- function(x, digits = 1, missing_text = "Not Reported") {
  # TODO: Advanced number formatting
  # Handle: NA values, trailing zeros, clinical presentation standards
}

format_clinical_stats <- function(data, variable, type = "mean_sd") {
  # TODO: Clinical statistics formatting
  # Support: mean±SD, mean(SD), median[Q1,Q3], median(min,max)
  # Include: proper handling of missing values
}

format_clinical_percent <- function(n, total, digits = 1, include_n = TRUE) {
  # TODO: Clinical percentage formatting  
  # Format: n (xx.x%) or xx.x% based on include_n
  # Handle: zero counts, 100% scenarios
}

format_clinical_date <- function(date_col, format_type = "study_day") {
  # TODO: Clinical date formatting
  # Support: study days, partial dates, date ranges
  # Handle: missing dates appropriately
}

# Hint: Use GitHub Copilot prompt:
# "# Create clinical statistics formatting function for mean and standard deviation"

# YOUR CODE HERE:
# TODO: Implement all four formatting functions above

cat("Challenge 4 Status: Formatting functions _____ (complete/incomplete)\n\n")

# =====================================================
# CHALLENGE 5: Export and Documentation (10 points)
# =====================================================

cat("=== CHALLENGE 5: Export and Documentation ===\n")
cat("Implement production export procedures:\n\n")

# YOUR TASK: Create comprehensive export management
# Requirements:
# 1. Export tables to multiple formats (HTML, PDF, Word)
# 2. Generate metadata files with creation details
# 3. Create data lineage documentation
# 4. Implement version control for outputs

# TODO: Implement export management functions:

export_clinical_deliverable <- function(table_obj, filename, format = "html") {
  # TODO: Multi-format export function
  # Support: HTML, PDF, Word formats
  # Include: automatic metadata generation
}

create_deliverable_metadata <- function(filename, dataset_info) {
  # TODO: Comprehensive metadata creation
  # Include: creation timestamp, R session info, data sources, validation status
}

generate_lineage_doc <- function(datasets, transformations) {
  # TODO: Data lineage documentation
  # Show: data flow from raw to final deliverables
  # Include: transformation steps and validation checkpoints
}

# YOUR CODE HERE:
# TODO: Implement export and documentation functions

cat("Challenge 5 Status: Export functions _____ (complete/incomplete)\n\n")

# =====================================================
# CHALLENGE 6: GitHub Copilot Integration (10 points) 
# =====================================================

cat("=== CHALLENGE 6: GitHub Copilot Integration ===\n")
cat("Demonstrate effective AI-assisted clinical programming:\n\n")

# YOUR TASK: Document your GitHub Copilot usage
# Requirements:
# 1. Show 3 effective prompts you used during this exercise
# 2. Demonstrate how you refined prompts for better clinical context
# 3. Show examples of Copilot-generated code you adapted
# 4. Document any limitations you encountered with AI assistance

# TODO: Complete the following documentation:

copilot_usage_report <- list(
  effective_prompts = c(
    "# Prompt 1: ___________",
    "# Prompt 2: ___________", 
    "# Prompt 3: ___________"
  ),
  
  prompt_refinements = "
  # Example of how I refined a prompt:
  # Initial: ___________
  # Refined: ___________
  # Result: ___________
  ",
  
  adapted_code = "
  # Show an example where you took Copilot-generated code and adapted it:
  # Original Copilot suggestion: ___________
  # Your adaptation: ___________
  # Reason for change: ___________
  ",
  
  limitations_encountered = "
  # Describe any limitations you found with AI assistance:
  # 1. ___________
  # 2. ___________
  # 3. ___________
  "
)

# YOUR DOCUMENTATION HERE:
# TODO: Complete the copilot_usage_report list above

cat("Challenge 6 Status: Copilot documentation _____ (complete/incomplete)\n\n")

# =====================================================
# FINAL DELIVERABLE: Integrated Clinical Report
# =====================================================

cat("=== FINAL DELIVERABLE: Integrated Clinical Report ===\n")
cat("Combine all components into a comprehensive clinical report:\n\n")

# YOUR TASK: Create a complete clinical programming workflow
# Requirements:
# 1. Execute all data creation, validation, and QC procedures
# 2. Generate all summary tables with professional formatting
# 3. Export deliverables with proper documentation
# 4. Create a summary report of the entire workflow

# TODO: Execute your complete workflow:

execute_clinical_workflow <- function() {
  
  cat("Executing complete clinical programming workflow...\n")
  
  # Step 1: Data creation and validation
  # TODO: Call your data creation and validation functions
  
  # Step 2: QC procedures
  # TODO: Execute comprehensive QC checks
  
  # Step 3: Table generation
  # TODO: Create all summary tables
  
  # Step 4: Export management
  # TODO: Export deliverables with metadata
  
  # Step 5: Workflow summary
  # TODO: Generate workflow completion report
  
  cat("Clinical workflow execution complete!\n")
}

# Execute the workflow (uncomment when ready):
# execute_clinical_workflow()

# =====================================================
# EXERCISE SCORING AND SELF-ASSESSMENT
# =====================================================

cat("=== EXERCISE SCORING ===\n")
cat("Self-assess your completion:\n")
cat("Challenge 1 (Data Creation): ___/20 points\n")
cat("Challenge 2 (QC Functions): ___/25 points\n") 
cat("Challenge 3 (gt Tables): ___/20 points\n")
cat("Challenge 4 (Formatting): ___/15 points\n")
cat("Challenge 5 (Export): ___/10 points\n")
cat("Challenge 6 (Copilot): ___/10 points\n")
cat("TOTAL SCORE: ___/100 points\n\n")

cat("=== EXERCISE COMPLETE ===\n")
cat("This comprehensive exercise integrates all clinical programming\n")
cat("skills from the entire course. Successful completion demonstrates\n")
cat("readiness for professional clinical programming with R!\n")


