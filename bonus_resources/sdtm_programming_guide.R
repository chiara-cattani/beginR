
# sdtm_derive.R
# Production CDISC SDTM Domain Creation from Raw Clinical Data
# Clinical Programming Training - SDTM Implementation Guide v1.7
# Uses sdtm.oak package for metadata-driven programming

library(dplyr)
library(tibble)
library(stringr)
library(lubridate)
library(haven)         # For reading SAS datasets
# library(sdtm.oak)    # Uncomment when sdtm.oak is available

cat("=== CDISC SDTM Domain Creation ===\n")
cat("Converting raw clinical data to SDTM-compliant domains\n\n")

# Set study parameters
STUDY_ID <- "ABC-123"
STUDY_RFSTDTC <- as.Date("2024-01-15")  # Common study start date

# =================
# Mock Raw Clinical Data (represents CRF/EDC data)
# =================

# Raw Demographics Data (typically from EDC)
raw_demographics <- tibble(
  subject_id = sprintf("%03d", 1:25),
  site_number = sample(c("001", "002", "003"), 25, replace = TRUE),
  birth_date = sample(seq(as.Date("1950-01-01"), as.Date("1990-12-31"), by = "day"), 25),
  gender = sample(c("Male", "Female"), 25, replace = TRUE, prob = c(0.55, 0.45)),
  race_reported = sample(c("White", "Black or African American", "Asian", "Other"), 
                        25, replace = TRUE, prob = c(0.75, 0.15, 0.08, 0.02)),
  ethnicity_reported = sample(c("Hispanic or Latino", "Not Hispanic or Latino"), 
                             25, replace = TRUE, prob = c(0.2, 0.8)),
  randomization_date = STUDY_RFSTDTC,
  planned_treatment = sample(c("Placebo", "Study Drug 5mg", "Study Drug 10mg"), 
                            25, replace = TRUE),
  informed_consent_date = STUDY_RFSTDTC - sample(1:7, 25, replace = TRUE)
)

# Raw Adverse Events Data
raw_ae <- tibble(
  subject_id = sample(raw_demographics$subject_id, 45, replace = TRUE),
  ae_verbatim_term = sample(c("headache", "Nausea", "FATIGUE", "dizziness", "skin rash",
                             "upper respiratory infection", "back pain", "trouble sleeping"),
                           45, replace = TRUE),
  ae_start_date = STUDY_RFSTDTC + sample(1:60, 45, replace = TRUE),
  ae_end_date = NA,  # Will derive
  ae_severity = sample(c("Mild", "Moderate", "Severe"), 45, replace = TRUE, prob = c(0.6, 0.3, 0.1)),
  ae_relationship = sample(c("Not Related", "Unlikely", "Possible", "Probable"), 
                          45, replace = TRUE, prob = c(0.4, 0.3, 0.2, 0.1)),
  ae_serious = sample(c("No", "Yes"), 45, replace = TRUE, prob = c(0.9, 0.1)),
  ae_outcome = sample(c("Recovered/Resolved", "Recovering/Resolving", "Not Recovered"), 
                     45, replace = TRUE, prob = c(0.7, 0.2, 0.1))
) %>%
  mutate(
    ae_end_date = case_when(
      ae_outcome == "Recovered/Resolved" ~ ae_start_date + sample(1:14, n(), replace = TRUE),
      ae_outcome == "Recovering/Resolving" ~ ae_start_date + sample(7:21, n(), replace = TRUE),
      TRUE ~ NA_Date_
    )
  )

# Raw Exposure Data
raw_exposure <- tibble(
  subject_id = rep(raw_demographics$subject_id, each = 4),  # 4 visits per subject
  visit_name = rep(c("Baseline", "Week 2", "Week 4", "Week 8"), times = 25),
  visit_date = rep(STUDY_RFSTDTC, 100) + rep(c(0, 14, 28, 56), times = 25),
  dose_administered = case_when(
    subject_id %in% raw_demographics$subject_id[raw_demographics$planned_treatment == "Placebo"] ~ 0,
    subject_id %in% raw_demographics$subject_id[raw_demographics$planned_treatment == "Study Drug 5mg"] ~ 5,
    subject_id %in% raw_demographics$subject_id[raw_demographics$planned_treatment == "Study Drug 10mg"] ~ 10
  ),
  treatment_name = case_when(
    dose_administered == 0 ~ "Placebo",
    dose_administered == 5 ~ "Study Drug",
    dose_administered == 10 ~ "Study Drug"
  ),
  dose_form = "Tablet",
  route = "Oral"
) %>%
  # Add some realistic missingness
  mutate(
    dose_administered = case_when(
      runif(n()) < 0.05 ~ NA_real_,  # 5% missing doses
      TRUE ~ dose_administered
    )
  )

# =================
# DM Domain Creation (Demographics)
# =================

cat("Creating DM (Demographics) Domain...\n")

dm_sdtm <- raw_demographics %>%
  mutate(
    # Required SDTM variables
    STUDYID = STUDY_ID,
    DOMAIN = "DM",
    USUBJID = paste0(STUDY_ID, "-", subject_id),
    SUBJID = subject_id,
    RFSTDTC = format(randomization_date, "%Y-%m-%d"),
    RFENDTC = format(randomization_date + 84, "%Y-%m-%d"),  # 12-week study
    
    # Demographics
    BRTHDTC = format(birth_date, "%Y-%m-%d"),
    AGE = as.integer(floor((randomization_date - birth_date) / 365.25)),
    AGEU = "YEARS",
    SEX = case_when(
      gender == "Male" ~ "M",
      gender == "Female" ~ "F"
    ),
    RACE = str_to_upper(race_reported),
    ETHNIC = str_to_upper(ethnicity_reported),
    
    # Treatment assignment
    ARMCD = case_when(
      planned_treatment == "Placebo" ~ "PBO",
      planned_treatment == "Study Drug 5mg" ~ "LOW",
      planned_treatment == "Study Drug 10mg" ~ "HIGH"
    ),
    ARM = planned_treatment,
    ACTARMCD = ARMCD,  # Actual = Planned for this example  
    ACTARM = ARM,
    
    # Study dates
    RFICDTC = format(informed_consent_date, "%Y-%m-%d"),  # Informed consent
    RFXSTDTC = RFSTDTC,  # First study treatment (same as randomization)
    RFXENDTC = RFENDTC,  # Last study treatment
    RFPENDTC = RFENDTC,  # End of participation
    
    # Site information
    SITEID = site_number,
    INVID = paste0("INV-", site_number),  # Investigator ID
    INVNAM = paste("Dr. Investigator", site_number),
    
    # Country (simplified)
    COUNTRY = "USA"
  ) %>%
  
  # Select standard SDTM DM variables
  select(
    STUDYID, DOMAIN, USUBJID, SUBJID,
    RFSTDTC, RFENDTC, RFICDTC, RFXSTDTC, RFXENDTC, RFPENDTC,
    BRTHDTC, AGE, AGEU, SEX, RACE, ETHNIC,
    ARMCD, ARM, ACTARMCD, ACTARM,
    SITEID, INVID, INVNAM, COUNTRY
  )

cat("DM domain created with", nrow(dm_sdtm), "subjects\n")

# =================
# AE Domain Creation (Adverse Events)
# =================

cat("Creating AE (Adverse Events) Domain...\n")

ae_sdtm <- raw_ae %>%
  # Join with DM for USUBJID and reference dates
  left_join(
    dm_sdtm %>% select(SUBJID, USUBJID, RFSTDTC),
    by = c("subject_id" = "SUBJID")
  ) %>%
  
  # Generate sequence numbers per subject
  group_by(USUBJID) %>%
  mutate(AESEQ = row_number()) %>%
  ungroup() %>%
  
  mutate(
    # Required SDTM variables
    STUDYID = STUDY_ID,
    DOMAIN = "AE",
    
    # AE term standardization (normally done with MedDRA)
    AETERM = str_to_upper(str_trim(ae_verbatim_term)),
    AEDECOD = AETERM,  # Decoded term (same as term for this example)
    AEBODSYS = case_when(
      AETERM %in% c("HEADACHE", "DIZZINESS") ~ "NERVOUS SYSTEM DISORDERS",
      AETERM == "NAUSEA" ~ "GASTROINTESTINAL DISORDERS", 
      AETERM == "FATIGUE" ~ "GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS",
      AETERM == "SKIN RASH" ~ "SKIN AND SUBCUTANEOUS TISSUE DISORDERS",
      AETERM == "UPPER RESPIRATORY INFECTION" ~ "RESPIRATORY, THORACIC AND MEDIASTINAL DISORDERS",
      AETERM == "BACK PAIN" ~ "MUSCULOSKELETAL AND CONNECTIVE TISSUE DISORDERS",
      AETERM == "TROUBLE SLEEPING" ~ "PSYCHIATRIC DISORDERS",
      TRUE ~ "GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS"
    ),
    
    # Severity mapping
    AESEV = str_to_upper(ae_severity),
    AETOXGR = case_when(
      AESEV == "MILD" ~ "1",
      AESEV == "MODERATE" ~ "2", 
      AESEV == "SEVERE" ~ "3"
    ),
    
    # Relationship to study drug
    AEREL = str_to_upper(ae_relationship),
    
    # Serious AE flag
    AESER = case_when(
      ae_serious == "Yes" ~ "Y",
      ae_serious == "No" ~ "N"
    ),
    
    # Outcome
    AEOUT = str_to_upper(ae_outcome),
    
    # Dates and study days
    AESTDTC = format(ae_start_date, "%Y-%m-%d"),
    AEENDTC = case_when(
      !is.na(ae_end_date) ~ format(ae_end_date, "%Y-%m-%d"),
      TRUE ~ NA_character_
    ),
    AESTDY = as.integer(ae_start_date - as.Date(RFSTDTC)) + 1,
    AEENDY = case_when(
      !is.na(ae_end_date) ~ as.integer(ae_end_date - as.Date(RFSTDTC)) + 1,
      TRUE ~ NA_integer_
    ),
    
    # Ongoing flag
    AEONGOVL = case_when(
      is.na(ae_end_date) ~ "Y",
      TRUE ~ "N"
    )
  ) %>%
  
  # Select standard SDTM AE variables
  select(
    STUDYID, DOMAIN, USUBJID, AESEQ,
    AETERM, AEDECOD, AEBODSYS,
    AESEV, AETOXGR, AEREL, AESER, AEOUT,
    AESTDTC, AEENDTC, AESTDY, AEENDY, AEONGOVL
  )

cat("AE domain created with", nrow(ae_sdtm), "adverse events\n")

# =================
# EX Domain Creation (Exposure)
# =================

cat("Creating EX (Exposure) Domain...\n")

ex_sdtm <- raw_exposure %>%
  # Join with DM for USUBJID and reference dates
  left_join(
    dm_sdtm %>% select(SUBJID, USUBJID, RFSTDTC, ARMCD),
    by = c("subject_id" = "SUBJID")
  ) %>%
  
  # Filter out missing doses if needed, or keep for compliance calculations
  filter(!is.na(dose_administered)) %>%
  
  # Generate sequence numbers per subject
  group_by(USUBJID) %>%
  mutate(EXSEQ = row_number()) %>%
  ungroup() %>%
  
  mutate(
    # Required SDTM variables
    STUDYID = STUDY_ID,
    DOMAIN = "EX",
    
    # Treatment information
    EXTRT = treatment_name,
    EXDOSE = dose_administered,
    EXDOSU = "mg",
    EXDOSFRM = str_to_upper(dose_form),
    EXROUTE = str_to_upper(route),
    EXFREQ = "QD",  # Once daily
    
    # Visit information
    VISIT = visit_name,
    VISITNUM = case_when(
      visit_name == "Baseline" ~ 1,
      visit_name == "Week 2" ~ 2,
      visit_name == "Week 4" ~ 3,
      visit_name == "Week 8" ~ 4
    ),
    
    # Dates (assuming single-day dosing per visit for simplicity)
    EXSTDTC = format(visit_date, "%Y-%m-%d"),
    EXENDTC = format(visit_date, "%Y-%m-%d"),  # Same day
    EXSTDY = as.integer(visit_date - as.Date(RFSTDTC)) + 1,
    EXENDY = EXSTDY
  ) %>%
  
  # Select standard SDTM EX variables
  select(
    STUDYID, DOMAIN, USUBJID, EXSEQ,
    EXTRT, EXDOSE, EXDOSU, EXDOSFRM, EXROUTE, EXFREQ,
    VISIT, VISITNUM,
    EXSTDTC, EXENDTC, EXSTDY, EXENDY
  )

cat("EX domain created with", nrow(ex_sdtm), "exposure records\n")

# =================
# Data Quality Checks
# =================

cat("\n=== SDTM Quality Control Checks ===\n")

# Check required variables are present
check_required_vars <- function(data, domain_name, required_vars) {
  missing_vars <- setdiff(required_vars, names(data))
  if (length(missing_vars) > 0) {
    warning(paste0(domain_name, " missing required variables: ", 
                   paste(missing_vars, collapse = ", ")))
  } else {
    cat("✓", domain_name, "has all required variables\n")
  }
}

# DM required variables
check_required_vars(dm_sdtm, "DM", c("STUDYID", "DOMAIN", "USUBJID", "SUBJID", "RFSTDTC", "AGE", "SEX"))

# AE required variables  
check_required_vars(ae_sdtm, "AE", c("STUDYID", "DOMAIN", "USUBJID", "AESEQ", "AETERM", "AESTDTC"))

# EX required variables
check_required_vars(ex_sdtm, "EX", c("STUDYID", "DOMAIN", "USUBJID", "EXSEQ", "EXTRT", "EXSTDTC"))

# Check for duplicate keys
dm_dups <- dm_sdtm %>% count(USUBJID) %>% filter(n > 1) %>% nrow()
ae_dups <- ae_sdtm %>% count(USUBJID, AESEQ) %>% filter(n > 1) %>% nrow()
ex_dups <- ex_sdtm %>% count(USUBJID, EXSEQ) %>% filter(n > 1) %>% nrow()

if (dm_dups > 0) warning("DM has ", dm_dups, " duplicate USUBJID")
if (ae_dups > 0) warning("AE has ", ae_dups, " duplicate USUBJID/AESEQ") 
if (ex_dups > 0) warning("EX has ", ex_dups, " duplicate USUBJID/EXSEQ")

if (dm_dups == 0 && ae_dups == 0 && ex_dups == 0) {
  cat("✓ No duplicate keys found in any domain\n")
}

# Summary statistics
cat("\nSDTM Domain Summary:\n")
cat("- DM:", nrow(dm_sdtm), "subjects\n")
cat("- AE:", nrow(ae_sdtm), "adverse events for", length(unique(ae_sdtm$USUBJID)), "subjects\n")
cat("- EX:", nrow(ex_sdtm), "exposure records for", length(unique(ex_sdtm$USUBJID)), "subjects\n")

# =================
# Optional: Export to SAS Transport Files
# =================

# Uncomment to export (requires haven package)
# haven::write_xpt(dm_sdtm, "dm.xpt")
# haven::write_xpt(ae_sdtm, "ae.xpt") 
# haven::write_xpt(ex_sdtm, "ex.xpt")
# cat("SDTM domains exported to XPT format\n")

cat("\n=== CDISC SDTM Domain Creation Complete ===\n")
cat("Ready for ADaM dataset creation and analysis\n")
      VISIT == "Visit 2" ~ 2,
      TRUE ~ NA_real_
    )
  ) %>%
  select(STUDYID, DOMAIN, USUBJID, EXSEQ, EXTRT, EXDOSE, EXSTDTC, EXENDTC, VISIT, VISITNUM)

# Preview
print(sdtm_ex)
