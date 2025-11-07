# Module 6 Demo — SDTM Programming with sdtm.oak
# Comprehensive examples of creating SDTM domains from raw clinical data

# ===========================
# SETUP: Load Required Packages
# ===========================

library(dplyr)
library(tibble)
library(lubridate)
library(stringr)
library(haven)
# library(sdtm.oak)  # Install if available: remotes::install_github("pharmaverse/sdtm.oak")

cat("=== SDTM Programming Demo ===\n")
cat("Creating standardized clinical domains for regulatory submission\n\n")

# ===========================
# Part 1: Create Raw Clinical Data
# ===========================

cat("=== Part 1: Raw Clinical Data Setup ===\n")

# Raw demographics data (as received from site)
raw_demographics <- tibble(
  subject_id = c("001-001", "001-002", "001-003", "001-004", "001-005", "001-006"),
  site_number = c("001", "001", "001", "001", "001", "001"),
  age_years = c(25, 45, 67, 52, 71, 34),
  gender = c("Female", "Male", "Female", "Male", "Female", "Female"),
  race_reported = c("White", "Black or African American", "Asian", "White", "White", "Hispanic"),
  randomization_date = c("2024-01-15", "2024-01-16", "2024-01-17", "2024-01-18", "2024-01-19", "2024-01-20"),
  treatment_assigned = c("Placebo", "Active 10mg", "Placebo", "Active 10mg", "Placebo", "Active 10mg"),
  study_completion = c("Completed", "Completed", "Ongoing", "Completed", "Discontinued", "Ongoing")
)

print("Raw Demographics Data:")
print(raw_demographics)

# Raw adverse events data
raw_adverse_events <- tibble(
  subject_id = c("001-001", "001-001", "001-002", "001-003", "001-004", "001-005"),
  ae_number = c(1, 2, 1, 1, 1, 1),
  adverse_event_term = c("Mild headache", "Nausea", "Severe fatigue", "Dizziness", "Skin rash", "Mild cough"),
  start_date = c("2024-01-20", "2024-01-25", "2024-01-18", "2024-01-22", "2024-01-24", "2024-01-26"),
  end_date = c("2024-01-22", "2024-01-26", "2024-01-21", "2024-01-23", "", "2024-01-28"),
  severity_raw = c("Mild", "Moderate", "Severe", "Mild", "Moderate", "Mild"),
  serious_event = c("No", "No", "No", "No", "Yes", "No"),
  action_taken = c("None", "None", "Drug interrupted", "None", "Drug discontinued", "None"),
  outcome = c("Recovered", "Recovered", "Recovered", "Recovered", "Not recovered", "Recovered")
)

print("\nRaw Adverse Events Data:")
print(raw_adverse_events)

# Raw vital signs data
raw_vitals <- tibble(
  subject_id = rep(c("001-001", "001-002", "001-003"), each = 6),
  visit_name = rep(c("Baseline", "Week 2", "Week 4"), each = 2, times = 3),
  vital_sign = rep(c("Systolic Blood Pressure", "Diastolic Blood Pressure"), times = 9),
  measurement_value = c(120, 80, 118, 78, 122, 82, 135, 85, 130, 82, 128, 80, 142, 90, 138, 88, 140, 89),
  measurement_unit = "mmHg",
  measurement_date = rep(c("2024-01-15", "2024-01-29", "2024-02-12"), each = 2, times = 3)
)

print("\nRaw Vital Signs Data:")
print(raw_vitals)

# ===========================
# Part 2: Create SDTM Demographics (DM) Domain
# ===========================

cat("\n=== Part 2: SDTM Demographics (DM) Domain ===\n")

create_dm_domain <- function(raw_data) {
  raw_data %>%
    transmute(
      STUDYID = "PROTO001",
      DOMAIN = "DM", 
      USUBJID = subject_id,
      SUBJID = str_extract(subject_id, "\\d+$"),  # Extract subject number
      RFSTDTC = randomization_date,
      RFXSTDTC = randomization_date,  # First exposure (same as randomization for this example)
      RFXENDTC = case_when(
        study_completion == "Completed" ~ "2024-03-15",  # Assume standard study duration
        study_completion == "Discontinued" ~ "2024-02-20",
        TRUE ~ ""  # Ongoing subjects
      ),
      RFPENDTC = case_when(
        study_completion %in% c("Completed", "Discontinued") ~ "2024-03-15",
        TRUE ~ ""
      ),
      DTHDTC = "",  # No deaths in this example
      DTHFL = "",   # Death flag
      SITEID = site_number,
      INVID = paste0("INV", site_number),
      INVNAM = paste0("Investigator ", site_number),
      AGE = age_years,
      AGEU = "YEARS",
      SEX = case_when(
        gender == "Female" ~ "F",
        gender == "Male" ~ "M",
        TRUE ~ "U"
      ),
      RACE = case_when(
        race_reported == "White" ~ "WHITE",
        race_reported == "Black or African American" ~ "BLACK OR AFRICAN AMERICAN", 
        race_reported == "Asian" ~ "ASIAN",
        race_reported == "Hispanic" ~ "WHITE",  # Ethnicity, not race
        TRUE ~ "OTHER"
      ),
      ETHNIC = case_when(
        race_reported == "Hispanic" ~ "HISPANIC OR LATINO",
        TRUE ~ "NOT HISPANIC OR LATINO"
      ),
      ARMCD = case_when(
        treatment_assigned == "Placebo" ~ "PBO",
        treatment_assigned == "Active 10mg" ~ "TRT",
        TRUE ~ ""
      ),
      ARM = case_when(
        treatment_assigned == "Placebo" ~ "Placebo",
        treatment_assigned == "Active 10mg" ~ "Active Treatment 10mg",
        TRUE ~ treatment_assigned
      ),
      ACTARMCD = ARMCD,  # Actual arm (same as planned in this example)
      ACTARM = ARM,
      COUNTRY = "USA",
      DMDTC = randomization_date,  # Date of demographics collection
      DMDY = 1  # Study day of demographics collection
    )
}

# Create DM domain
dm_sdtm <- create_dm_domain(raw_demographics)

cat("SDTM DM Domain created with", nrow(dm_sdtm), "records:\n")
print(dm_sdtm %>% select(USUBJID, AGE, SEX, RACE, ARMCD, ARM, RFSTDTC))

# ===========================  
# Part 3: Create SDTM Adverse Events (AE) Domain
# ===========================

cat("\n=== Part 3: SDTM Adverse Events (AE) Domain ===\n")

create_ae_domain <- function(raw_ae_data, dm_domain) {
  raw_ae_data %>%
    left_join(dm_domain %>% select(USUBJID, RFSTDTC), 
              by = c("subject_id" = "USUBJID")) %>%
    transmute(
      STUDYID = "PROTO001",
      DOMAIN = "AE",
      USUBJID = subject_id,
      AESEQ = ae_number,
      SPDEVID = "",  # Sponsor device identifier
      AETERM = str_to_upper(str_trim(adverse_event_term)),
      AEDECOD = case_when(
        str_detect(str_to_upper(adverse_event_term), "HEADACHE") ~ "HEADACHE",
        str_detect(str_to_upper(adverse_event_term), "NAUSEA") ~ "NAUSEA", 
        str_detect(str_to_upper(adverse_event_term), "FATIGUE") ~ "FATIGUE",
        str_detect(str_to_upper(adverse_event_term), "DIZZINESS") ~ "DIZZINESS",
        str_detect(str_to_upper(adverse_event_term), "RASH") ~ "RASH",
        str_detect(str_to_upper(adverse_event_term), "COUGH") ~ "COUGH",
        TRUE ~ str_to_upper(str_trim(adverse_event_term))
      ),
      AEBODSYS = case_when(
        str_detect(AEDECOD, "HEADACHE|DIZZINESS") ~ "NERVOUS SYSTEM DISORDERS",
        str_detect(AEDECOD, "NAUSEA") ~ "GASTROINTESTINAL DISORDERS",
        str_detect(AEDECOD, "FATIGUE") ~ "GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS",
        str_detect(AEDECOD, "RASH") ~ "SKIN AND SUBCUTANEOUS TISSUE DISORDERS",
        str_detect(AEDECOD, "COUGH") ~ "RESPIRATORY, THORACIC AND MEDIASTINAL DISORDERS",
        TRUE ~ "GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS"
      ),
      AESEV = case_when(
        str_to_upper(severity_raw) == "MILD" ~ "MILD",
        str_to_upper(severity_raw) == "MODERATE" ~ "MODERATE", 
        str_to_upper(severity_raw) == "SEVERE" ~ "SEVERE",
        TRUE ~ ""
      ),
      AESER = case_when(
        str_to_upper(serious_event) == "YES" ~ "Y",
        str_to_upper(serious_event) == "NO" ~ "N",
        TRUE ~ ""
      ),
      AEACN = case_when(
        str_detect(str_to_upper(action_taken), "NONE") ~ "NONE",
        str_detect(str_to_upper(action_taken), "INTERRUPTED") ~ "DRUG INTERRUPTED",
        str_detect(str_to_upper(action_taken), "DISCONTINUED") ~ "DRUG WITHDRAWN",
        TRUE ~ str_to_upper(action_taken)
      ),
      AEOUT = case_when(
        str_detect(str_to_upper(outcome), "RECOVERED") ~ "RECOVERED/RESOLVED",
        str_detect(str_to_upper(outcome), "NOT RECOVERED") ~ "NOT RECOVERED/NOT RESOLVED",
        TRUE ~ str_to_upper(outcome)
      ),
      AESTDTC = start_date,
      AEENDTC = if_else(end_date == "", "", end_date),
      AESTDY = case_when(
        !is.na(ymd(start_date)) & !is.na(ymd(RFSTDTC)) & ymd(start_date) >= ymd(RFSTDTC) ~ 
          as.numeric(ymd(start_date) - ymd(RFSTDTC)) + 1,
        !is.na(ymd(start_date)) & !is.na(ymd(RFSTDTC)) & ymd(start_date) < ymd(RFSTDTC) ~ 
          as.numeric(ymd(start_date) - ymd(RFSTDTC)),
        TRUE ~ NA_real_
      ),
      AEENDY = case_when(
        end_date != "" & !is.na(ymd(end_date)) & !is.na(ymd(RFSTDTC)) & ymd(end_date) >= ymd(RFSTDTC) ~ 
          as.numeric(ymd(end_date) - ymd(RFSTDTC)) + 1,
        end_date != "" & !is.na(ymd(end_date)) & !is.na(ymd(RFSTDTC)) & ymd(end_date) < ymd(RFSTDTC) ~ 
          as.numeric(ymd(end_date) - ymd(RFSTDTC)),
        TRUE ~ NA_real_
      ),
      AEDUR = case_when(
        !is.na(AEENDY) & !is.na(AESTDY) ~ AEENDY - AESTDY + 1,
        TRUE ~ NA_real_
      )
    )
}

# Create AE domain
ae_sdtm <- create_ae_domain(raw_adverse_events, dm_sdtm)

cat("SDTM AE Domain created with", nrow(ae_sdtm), "records:\n")
print(ae_sdtm %>% select(USUBJID, AESEQ, AEDECOD, AESEV, AESER, AESTDY, AEENDY))

# ===========================
# Part 4: Create SDTM Vital Signs (VS) Domain  
# ===========================

cat("\n=== Part 4: SDTM Vital Signs (VS) Domain ===\n")

create_vs_domain <- function(raw_vs_data, dm_domain) {
  raw_vs_data %>%
    left_join(dm_domain %>% select(USUBJID, RFSTDTC), 
              by = c("subject_id" = "USUBJID")) %>%
    transmute(
      STUDYID = "PROTO001",
      DOMAIN = "VS",
      USUBJID = subject_id,
      VSSEQ = row_number(),
      VSTESTCD = case_when(
        str_detect(vital_sign, "Systolic") ~ "SYSBP",
        str_detect(vital_sign, "Diastolic") ~ "DIABP",
        TRUE ~ ""
      ),
      VSTEST = case_when(
        str_detect(vital_sign, "Systolic") ~ "Systolic Blood Pressure",
        str_detect(vital_sign, "Diastolic") ~ "Diastolic Blood Pressure", 
        TRUE ~ vital_sign
      ),
      VSCAT = "VITAL SIGNS",
      VSSCAT = "BLOOD PRESSURE",
      VSPOS = "SITTING",  # Assuming sitting position
      VSORRES = as.character(measurement_value),
      VSORRESU = measurement_unit,
      VSSTRESC = as.character(measurement_value),
      VSSTRESN = measurement_value,
      VSSTRESU = measurement_unit,
      VSSTAT = "",
      VSREASND = "",
      VSBLFL = case_when(
        visit_name == "Baseline" ~ "Y",
        TRUE ~ ""
      ),
      VSDTC = measurement_date,
      VSDY = case_when(
        !is.na(ymd(measurement_date)) & !is.na(ymd(RFSTDTC)) & ymd(measurement_date) >= ymd(RFSTDTC) ~ 
          as.numeric(ymd(measurement_date) - ymd(RFSTDTC)) + 1,
        !is.na(ymd(measurement_date)) & !is.na(ymd(RFSTDTC)) & ymd(measurement_date) < ymd(RFSTDTC) ~ 
          as.numeric(ymd(measurement_date) - ymd(RFSTDTC)),
        TRUE ~ NA_real_
      ),
      VISIT = visit_name,
      VISITNUM = case_when(
        visit_name == "Baseline" ~ 1,
        visit_name == "Week 2" ~ 2, 
        visit_name == "Week 4" ~ 3,
        TRUE ~ NA_real_
      ),
      VISITDY = VSDY,
      EPOCH = case_when(
        visit_name == "Baseline" ~ "SCREENING",
        TRUE ~ "TREATMENT"
      )
    )
}

# Create VS domain
vs_sdtm <- create_vs_domain(raw_vitals, dm_sdtm)

cat("SDTM VS Domain created with", nrow(vs_sdtm), "records:\n")
print(vs_sdtm %>% select(USUBJID, VSTESTCD, VSTEST, VSSTRESN, VSSTRESU, VISIT, VSDY))

# ===========================
# Part 5: Data Validation
# ===========================

cat("\n=== Part 5: SDTM Data Validation ===\n")

# Comprehensive validation function
validate_sdtm_domain <- function(data, domain_type, study_id = "PROTO001") {
  
  # Initialize validation results
  validation_results <- list(
    domain = domain_type,
    study_id = study_id,
    total_records = nrow(data),
    validation_errors = character(),
    validation_warnings = character(),
    validation_passed = TRUE
  )
  
  # Check required core variables
  required_core <- c("STUDYID", "DOMAIN", "USUBJID")
  missing_core <- setdiff(required_core, names(data))
  if (length(missing_core) > 0) {
    validation_results$validation_errors <- c(validation_results$validation_errors,
                                            paste("Missing required core variables:", paste(missing_core, collapse = ", ")))
    validation_results$validation_passed <- FALSE
  }
  
  # Domain-specific validations
  if (domain_type == "DM") {
    required_dm <- c("SUBJID", "RFSTDTC", "AGE", "SEX", "ARMCD")
    missing_dm <- setdiff(required_dm, names(data))
    if (length(missing_dm) > 0) {
      validation_results$validation_errors <- c(validation_results$validation_errors,
                                               paste("Missing required DM variables:", paste(missing_dm, collapse = ", ")))
      validation_results$validation_passed <- FALSE
    }
    
    # Check for duplicate USUBJIDs in DM
    duplicates <- data %>% group_by(USUBJID) %>% filter(n() > 1) %>% nrow()
    if (duplicates > 0) {
      validation_results$validation_errors <- c(validation_results$validation_errors,
                                               paste("Duplicate USUBJIDs found in DM domain:", duplicates, "records"))
      validation_results$validation_passed <- FALSE
    }
  }
  
  if (domain_type == "AE") {
    required_ae <- c("AESEQ", "AETERM", "AESTDTC")
    missing_ae <- setdiff(required_ae, names(data))
    if (length(missing_ae) > 0) {
      validation_results$validation_errors <- c(validation_results$validation_errors,
                                               paste("Missing required AE variables:", paste(missing_ae, collapse = ", ")))
      validation_results$validation_passed <- FALSE
    }
    
    # Check for duplicate USUBJID/AESEQ
    duplicates <- data %>% group_by(USUBJID, AESEQ) %>% filter(n() > 1) %>% nrow()
    if (duplicates > 0) {
      validation_results$validation_errors <- c(validation_results$validation_errors,
                                               paste("Duplicate USUBJID/AESEQ combinations:", duplicates, "records"))
      validation_results$validation_passed <- FALSE
    }
  }
  
  if (domain_type == "VS") {
    required_vs <- c("VSSEQ", "VSTESTCD", "VSORRES")
    missing_vs <- setdiff(required_vs, names(data))
    if (length(missing_vs) > 0) {
      validation_results$validation_errors <- c(validation_results$validation_errors,
                                               paste("Missing required VS variables:", paste(missing_vs, collapse = ", ")))
      validation_results$validation_passed <- FALSE
    }
  }
  
  # Check STUDYID consistency
  if ("STUDYID" %in% names(data)) {
    unique_studies <- unique(data$STUDYID)
    if (length(unique_studies) > 1 || unique_studies[1] != study_id) {
      validation_results$validation_warnings <- c(validation_results$validation_warnings,
                                                 paste("STUDYID inconsistency. Expected:", study_id, "Found:", paste(unique_studies, collapse = ", ")))
    }
  }
  
  return(validation_results)
}

# Validate all domains
dm_validation <- validate_sdtm_domain(dm_sdtm, "DM")
ae_validation <- validate_sdtm_domain(ae_sdtm, "AE")
vs_validation <- validate_sdtm_domain(vs_sdtm, "VS")

print("DM Domain Validation:")
print(dm_validation)

print("\nAE Domain Validation:")
print(ae_validation)

print("\nVS Domain Validation:")
print(vs_validation)

# ===========================
# Part 6: Export to XPT Format
# ===========================

cat("\n=== Part 6: Export SDTM Domains to XPT ===\n")

# Function to export SDTM domain to XPT
export_sdtm_xpt <- function(data, domain_name, output_dir = "sdtm_output") {
  
  # Create output directory
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
    cat("Created output directory:", output_dir, "\n")
  }
  
  # Set dataset attributes
  attr(data, "label") <- paste("SDTM", toupper(domain_name), "Domain")
  
  # Create file path
  file_path <- file.path(output_dir, paste0(tolower(domain_name), ".xpt"))
  
  # Export to XPT
  haven::write_xpt(data, file_path)
  
  cat("Exported", nrow(data), "records to", file_path, "\n")
  
  # Return file info
  file_info <- file.info(file_path)
  list(
    domain = domain_name,
    file_path = file_path,
    records = nrow(data),
    file_size_kb = round(file_info$size / 1024, 2),
    created = file_info$mtime
  )
}

# Export all domains
dm_export <- export_sdtm_xpt(dm_sdtm, "dm")
ae_export <- export_sdtm_xpt(ae_sdtm, "ae") 
vs_export <- export_sdtm_xpt(vs_sdtm, "vs")

# Summary of exports
export_summary <- bind_rows(
  as_tibble(dm_export),
  as_tibble(ae_export),
  as_tibble(vs_export)
)

cat("\nExport Summary:\n")
print(export_summary)

# ===========================
# Part 7: GitHub Copilot in RStudio Practice
# ===========================

cat("\n=== Part 7: GitHub Copilot in RStudio Practice ===\n")
cat("Try writing these comments in RStudio and see what Copilot suggests:\n\n")

# Create SDTM LB domain from raw laboratory data


# Map raw concomitant medications to SDTM CM domain


# Derive SDTM exposure domain with dose and duration calculations


# Create comprehensive SDTM validation report with all domains


# ===========================
# SUMMARY AND NEXT STEPS
# ===========================

cat("\n=== Module 6 Demo Complete! ===\n")
cat("SDTM domains created:\n")
cat("- DM (Demographics):", nrow(dm_sdtm), "records\n")
cat("- AE (Adverse Events):", nrow(ae_sdtm), "records\n")
cat("- VS (Vital Signs):", nrow(vs_sdtm), "records\n")
cat("\nKey concepts demonstrated:\n")
cat("- Raw data to SDTM domain mapping\n")
cat("- Standard variable naming and coding\n")
cat("- Study day calculations\n")
cat("- Domain validation and quality checks\n")
cat("- XPT export for regulatory submission\n")
cat("- GitHub Copilot in RStudio assistance\n")
cat("\nReady for hands-on practice in the exercise!\n")
