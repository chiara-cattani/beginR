# Module 6 Exercise — SDTM Programming with sdtm.oak
# Practice creating SDTM domains from raw clinical data

# ===========================
# SETUP: Load Required Packages
# ===========================

library(dplyr)
library(tibble)
library(lubridate)
library(stringr)
library(haven)
# library(sdtm.oak)  # Install if available

# ===========================
# EXERCISE DATA: Raw Clinical Data
# ===========================

# Raw demographics from multiple sites
raw_demographics <- tibble(
  subject_id = c("101-001", "101-002", "101-003", "102-001", "102-002", "102-003", "103-001", "103-002"),
  site_id = c("101", "101", "101", "102", "102", "102", "103", "103"),
  age_at_consent = c(28, 42, 65, 51, 73, 36, 59, 44), 
  sex_reported = c("F", "M", "F", "M", "F", "F", "M", "M"),
  race_category = c("White", "Black", "Asian", "White", "White", "Hispanic", "Other", "White"),
  enrollment_date = c("2024-02-01", "2024-02-02", "2024-02-03", "2024-02-05", "2024-02-06", "2024-02-07", "2024-02-08", "2024-02-09"),
  randomized_treatment = c("Placebo", "Study Drug 5mg", "Study Drug 10mg", "Placebo", "Study Drug 5mg", "Study Drug 10mg", "Placebo", "Study Drug 5mg"),
  study_status = c("Completed", "Ongoing", "Completed", "Discontinued", "Completed", "Ongoing", "Completed", "Ongoing")
)

# Raw adverse events with various formats
raw_ae_data <- tibble(
  subject_id = c("101-001", "101-002", "101-002", "101-003", "102-001", "102-002", "103-001", "103-002"),
  sequence_num = c(1, 1, 2, 1, 1, 1, 1, 1),
  event_description = c("mild headache", "NAUSEA AND VOMITING", "severe fatigue", "dizziness", "skin rash", "Upper respiratory infection", "muscle pain", "insomnia"),
  onset_date = c("2024-02-05", "2024-02-06", "2024-02-10", "2024-02-08", "2024-02-12", "2024-02-11", "2024-02-12", "2024-02-13"),
  resolution_date = c("2024-02-07", "2024-02-08", "2024-02-14", "2024-02-09", "", "2024-02-18", "2024-02-15", ""),
  intensity = c("Mild", "Moderate", "Severe", "Mild", "Moderate", "Mild", "Moderate", "Mild"),
  is_serious = c("No", "No", "Yes", "No", "No", "No", "No", "No"),
  relationship_to_drug = c("Possible", "Probable", "Possible", "Unlikely", "Probable", "Unrelated", "Possible", "Unlikely"),
  final_outcome = c("Resolved", "Resolved", "Resolved with sequelae", "Resolved", "Ongoing", "Resolved", "Resolved", "Ongoing")
)

# Raw laboratory data
raw_lab_data <- tibble(
  subject_id = rep(c("101-001", "101-002", "101-003"), each = 8),
  visit_label = rep(c("Screening", "Baseline", "Week 4", "Week 8"), each = 2, times = 3),
  lab_test_name = rep(c("Hemoglobin", "Hematocrit"), times = 12),
  lab_result = c(14.2, 42.1, 13.8, 41.5, 14.0, 42.8, 13.5, 40.2, 
                 15.1, 44.2, 14.8, 43.1, 15.0, 44.5, 14.7, 43.8,
                 13.9, 41.8, 13.6, 40.9, 13.8, 41.2, 13.4, 40.5),
  reference_unit = rep(c("g/dL", "%"), times = 12),
  normal_range_low = rep(c(12.0, 36.0), times = 12),
  normal_range_high = rep(c(16.0, 46.0), times = 12),
  collection_date = rep(c("2024-01-30", "2024-02-01", "2024-02-29", "2024-03-28"), each = 2, times = 3)
)

print("Raw Demographics Data:")
print(raw_demographics)
print("\nRaw AE Data:")  
print(raw_ae_data)
print("\nRaw Lab Data:")
print(raw_lab_data)

# ===========================
# EXERCISE 1: Create SDTM Demographics (DM) Domain
# ===========================

# YOUR TASK: Create a complete SDTM DM domain
# Requirements:
# 1. Map all demographics variables to SDTM standard names
# 2. Create proper ARMCD values: "PBO", "LOW", "HIGH" 
# 3. Handle missing/ongoing study completion dates
# 4. Calculate proper SUBJID from full subject_id
# 5. Add all required SDTM DM variables

create_dm_sdtm <- function(raw_demo_data) {
  raw_demo_data %>%
    transmute(
      # YOUR CODE HERE
      # Complete the DM domain mapping:
      STUDYID = ,
      DOMAIN = ,
      USUBJID = ,
      SUBJID = ,  # Hint: extract subject number after the dash
      RFSTDTC = ,
      RFXSTDTC = ,
      RFXENDTC = ,  # Handle study completion logic
      SITEID = ,
      AGE = ,
      AGEU = ,
      SEX = ,  # Map to CDISC controlled terminology
      RACE = ,  # Standardize race categories  
      ETHNIC = ,  # Derive from race_category
      ARMCD = ,  # "PBO", "LOW", "HIGH"
      ARM = ,    # Full treatment descriptions
      # Add other required DM variables
    )
}

# Test your function
dm_domain <- create_dm_sdtm(raw_demographics)
print("DM Domain (first few variables):")
print(dm_domain %>% select(USUBJID, AGE, SEX, RACE, ARMCD, ARM))

# ===========================
# EXERCISE 2: Create SDTM Adverse Events (AE) Domain
# ===========================

# YOUR TASK: Create a complete SDTM AE domain
# Requirements:
# 1. Standardize adverse event terms (AETERM)
# 2. Create proper AEDECOD mappings (simplified MedDRA-like)
# 3. Assign appropriate AEBODSYS (body system)
# 4. Calculate AESTDY and AEENDY correctly
# 5. Map severity, seriousness, and outcome to CDISC terminology

create_ae_sdtm <- function(raw_ae_data, dm_data) {
  raw_ae_data %>%
    left_join(dm_data %>% select(USUBJID, RFSTDTC), 
              by = c("subject_id" = "USUBJID")) %>%
    transmute(
      # YOUR CODE HERE
      # Complete the AE domain mapping:
      STUDYID = ,
      DOMAIN = ,
      USUBJID = ,
      AESEQ = ,
      AETERM = ,  # Standardize the event descriptions
      AEDECOD = ,  # Create preferred terms
      AEBODSYS = ,  # Map to body systems
      AESEV = ,     # Map intensity to MILD/MODERATE/SEVERE
      AESER = ,     # Map is_serious to Y/N
      AEREL = ,     # Map relationship_to_drug
      AEOUT = ,     # Map final_outcome to CDISC terms
      AESTDTC = ,
      AEENDTC = ,
      AESTDY = ,    # Calculate study day from RFSTDTC
      AEENDY = ,    # Calculate end study day
      # Add other AE variables as needed
    )
}

# Test your function  
ae_domain <- create_ae_sdtm(raw_ae_data, dm_domain)
print("AE Domain (key variables):")
print(ae_domain %>% select(USUBJID, AESEQ, AEDECOD, AESEV, AESER, AESTDY))

# ===========================
# EXERCISE 3: Create SDTM Laboratory (LB) Domain
# ===========================

# YOUR TASK: Create a complete SDTM LB domain
# Requirements:
# 1. Create proper LBTESTCD values ("HGB", "HCT")
# 2. Handle numeric results and reference ranges
# 3. Create abnormal flags (high/low/normal)
# 4. Calculate study days for lab collection
# 5. Map visit names to VISITNUM

create_lb_sdtm <- function(raw_lab_data, dm_data) {
  raw_lab_data %>%
    left_join(dm_data %>% select(USUBJID, RFSTDTC), 
              by = c("subject_id" = "USUBJID")) %>%
    transmute(
      # YOUR CODE HERE
      # Complete the LB domain mapping:
      STUDYID = ,
      DOMAIN = ,
      USUBJID = ,
      LBSEQ = ,  # Use row_number()
      LBTESTCD = ,  # "HGB" or "HCT"
      LBTEST = ,    # Full test names
      LBCAT = ,     # "HEMATOLOGY"
      LBORRES = ,   # Original result as character
      LBORRESU = ,  # Original units
      LBSTRESC = ,  # Standardized result
      LBSTRESN = ,  # Numeric result
      LBSTRESU = ,  # Standardized units
      LBNRIND = ,   # Normal/High/Low flag
      LBBLFL = ,    # Baseline flag for Baseline visit
      LBDTC = ,     # Collection date
      LBDY = ,      # Study day
      VISIT = ,
      VISITNUM = ,  # 1=Screening, 2=Baseline, 3=Week 4, 4=Week 8
      # Add reference range variables
      LBORNRLO = ,  # Reference range low
      LBORNRHI = ,  # Reference range high
    )
}

# Test your function
lb_domain <- create_lb_sdtm(raw_lab_data, dm_domain)
print("LB Domain (key variables):")
print(lb_domain %>% select(USUBJID, LBTESTCD, LBSTRESN, LBSTRESU, LBNRIND, VISIT))

# ===========================
# EXERCISE 4: SDTM Validation
# ===========================

# YOUR TASK: Create comprehensive validation functions
# Test each domain for:
# 1. Required variables presence
# 2. Duplicate key combinations
# 3. Data type consistency
# 4. Value range checks

validate_dm_domain <- function(dm_data) {
  # YOUR CODE HERE
  # Check DM-specific validations:
  # - No duplicate USUBJID
  # - AGE within reasonable range (0-120)
  # - SEX values are F/M/U only
  # - Required variables present
  
}

validate_ae_domain <- function(ae_data) {
  # YOUR CODE HERE  
  # Check AE-specific validations:
  # - No duplicate USUBJID/AESEQ combinations
  # - AESTDY <= AEENDY when both present
  # - AESEV values are MILD/MODERATE/SEVERE only
  # - Required variables present
  
}

validate_lb_domain <- function(lb_data) {
  # YOUR CODE HERE
  # Check LB-specific validations:
  # - LBSTRESN is numeric when LBORRES is numeric
  # - LBNRIND values are NORMAL/HIGH/LOW/ABNORMAL only
  # - Baseline flag logic is correct
  # - Required variables present
  
}

# Test your validation functions
dm_validation <- validate_dm_domain(dm_domain)
ae_validation <- validate_ae_domain(ae_domain)
lb_validation <- validate_lb_domain(lb_domain)

print("Validation Results:")
print("DM:", dm_validation)
print("AE:", ae_validation)  
print("LB:", lb_validation)

# ===========================
# EXERCISE 5: Export to XPT Format
# ===========================

# YOUR TASK: Create a comprehensive export function
# Requirements:
# 1. Set proper dataset labels
# 2. Create organized output structure
# 3. Generate export summary report
# 4. Handle file overwrite scenarios

export_study_domains <- function(dm_data, ae_data, lb_data, study_id = "PROTO001", output_dir = "sdtm_submission") {
  # YOUR CODE HERE
  # Export all domains with proper labeling and organization
  
}

# Test your export function
export_results <- export_study_domains(dm_domain, ae_domain, lb_domain)
print("Export Results:")
print(export_results)

# ===========================
# EXERCISE 6: GitHub Copilot in RStudio Practice
# ===========================

# YOUR TASK: Use GitHub Copilot in RStudio to help create these advanced functions
# Write descriptive comments and let Copilot suggest implementations:

# Create SDTM EX (Exposure) domain from dosing records


# Map investigational product exposure with start/end dates and doses


# Create comprehensive CDISC compliance checker for all domains


# Generate SDTM define.xml metadata from domain specifications


# Create cross-domain data consistency validation (e.g., subjects in DM vs AE)


# ===========================
# BONUS CHALLENGE: Advanced SDTM Features  
# ===========================

# YOUR TASK: Implement advanced SDTM programming concepts

# 1. Create SUPP-- (Supplemental) domains for non-standard variables
create_supp_dm <- function(dm_data, additional_vars) {
  # YOUR CODE HERE
  # Create supplemental demographics domain
  
}

# 2. Implement CDISC controlled terminology validation
validate_controlled_terminology <- function(data, domain_type) {
  # YOUR CODE HERE
  # Validate against CDISC CT standards
  
}

# 3. Create pooled domain across multiple studies
pool_domains <- function(study1_data, study2_data, domain_type) {
  # YOUR CODE HERE
  # Combine domains from multiple studies
  
}

# ===========================
# EXERCISE COMPLETE!
# ===========================

cat("\n🎉 Module 6 Exercise Complete!\n")
cat("SDTM Programming skills practiced:\n")
cat("- Raw data to SDTM domain mapping\n")
cat("- CDISC variable naming and controlled terminology\n")
cat("- Study day calculations and date handling\n")
cat("- Domain validation and quality checks\n")
cat("- XPT export for regulatory submission\n")
cat("- Advanced SDTM programming concepts\n")
cat("- GitHub Copilot in RStudio assistance\n")
cat("\nExcellent work! Ready for Module 7: Post-Processing, QC & Reporting!\n")
