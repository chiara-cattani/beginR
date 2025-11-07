
# data_manipulation_examples.R
# Practical Data Manipulation Examples with dplyr
# Module 2-3: Data Manipulation, Filtering, Joins, and Summaries
# Core dplyr functions and techniques

library(dplyr)
library(tibble)
library(lubridate)
library(stringr)

cat("=== Data Manipulation Examples ===\n")
cat("Essential dplyr operations for data analysis\n\n")

# Load validated SDTM datasets (in production, these would be from validated sources)
# Demographics Domain (DM)
dm_sdtm <- tibble(
  STUDYID = "ABC-123",
  DOMAIN = "DM",
  USUBJID = paste0("ABC-123-", sprintf("%03d", 1:20)),
  SUBJID = sprintf("%03d", 1:20),
  SITEID = rep(c("001", "002", "003"), length.out = 20),
  BRTHDTC = sample(seq(as.Date("1950-01-01"), as.Date("1990-12-31"), by = "day"), 20),
  SEX = sample(c("M", "F"), 20, replace = TRUE, prob = c(0.6, 0.4)),
  RACE = sample(c("WHITE", "BLACK OR AFRICAN AMERICAN", "ASIAN"), 20, replace = TRUE),
  ETHNIC = sample(c("HISPANIC OR LATINO", "NOT HISPANIC OR LATINO"), 20, replace = TRUE),
  ARMCD = rep(c("PBO", "TRT"), length.out = 20),
  ARM = case_when(
    ARMCD == "PBO" ~ "Placebo",
    ARMCD == "TRT" ~ "Study Drug 10mg"
  ),
  ACTARMCD = ARMCD,  # Actual arm (same as planned for this example)
  ACTARM = ARM,
  RFSTDTC = as.Date("2024-01-15"),
  RFENDTC = as.Date("2024-01-15") + sample(28:84, 20, replace = TRUE),
  RFXSTDTC = RFSTDTC,  # First study treatment
  RFXENDTC = RFENDTC,  # Last study treatment
  RFICDTC = RFSTDTC,   # Informed consent
  RFPENDTC = RFENDTC   # End of participation
)

# Exposure Domain (EX) 
ex_sdtm <- tibble(
  STUDYID = "ABC-123",
  DOMAIN = "EX",
  USUBJID = rep(dm_sdtm$USUBJID, each = 3),
  EXSEQ = rep(1:3, times = 20),
  EXTRT = case_when(
    USUBJID %in% dm_sdtm$USUBJID[dm_sdtm$ARMCD == "PBO"] ~ "Placebo",
    TRUE ~ "Study Drug"
  ),
  EXDOSE = case_when(
    EXTRT == "Placebo" ~ 0,
    TRUE ~ 10
  ),
  EXDOSU = "mg",
  EXDOSFRM = "TABLET",
  EXROUTE = "ORAL",
  EXSTDTC = rep(dm_sdtm$RFSTDTC, each = 3) + rep(c(0, 14, 28), times = 20),
  EXENDTC = rep(dm_sdtm$RFSTDTC, each = 3) + rep(c(13, 27, 41), times = 20)
) %>%
  filter(EXSTDTC <= rep(dm_sdtm$RFENDTC, each = 3)) %>%  # Remove post-study doses
  left_join(dm_sdtm %>% select(USUBJID, RFSTDTC), by = "USUBJID") %>%
  mutate(
    EXSTDY = as.numeric(EXSTDTC - RFSTDTC) + 1,
    EXENDY = as.numeric(EXENDTC - RFSTDTC) + 1
  ) %>%
  select(-RFSTDTC)

# =================
# ADSL Creation (Subject-Level Analysis Dataset)
# =================

cat("Creating ADSL (Subject-Level Analysis Dataset)...\n")

adsl <- dm_sdtm %>%
  mutate(
    # Standard ADaM variables
    STUDYID = STUDYID,
    USUBJID = USUBJID,
    SUBJID = SUBJID,
    SITEID = SITEID,
    
    # Treatment variables (planned)
    TRT01P = ARM,
    TRT01PN = case_when(
      ARMCD == "PBO" ~ 0,
      ARMCD == "TRT" ~ 1
    ),
    TRT01A = ACTARM,  # Actual treatment
    TRT01AN = case_when(
      ACTARMCD == "PBO" ~ 0,
      ACTARMCD == "TRT" ~ 1
    ),
    
    # Demographics derivations
    AGE = as.numeric(floor((RFSTDTC - BRTHDTC) / 365.25)),
    AGEGR1 = case_when(
      AGE < 65 ~ "<65",
      AGE >= 65 ~ ">=65"
    ),
    AGEGR1N = case_when(
      AGE < 65 ~ 1,
      AGE >= 65 ~ 2
    ),
    SEX = SEX,
    RACE = RACE,
    ETHNIC = ETHNIC,
    
    # Study dates
    TRTSDT = RFXSTDTC,   # Treatment start date
    TRTEDT = RFXENDTC,   # Treatment end date
    
    # Duration calculations
    TRTDURD = as.numeric(TRTEDT - TRTSDT) + 1,  # Treatment duration in days
    
    # Population flags (typically derived from protocol deviations, etc.)
    SAFFL = "Y",    # Safety population
    ITTFL = "Y",    # Intent-to-treat population  
    PPROTFL = case_when(
      # Per-protocol population (simplified criteria)
      TRTDURD >= 28 ~ "Y",
      TRUE ~ "N"
    ),
    
    # Randomization date
    RANDDT = RFICDTC,
    
    # Study completion
    EOSSTT = case_when(
      !is.na(RFPENDTC) ~ "COMPLETED",
      TRUE ~ "ONGOING"
    ),
    DCSREAS = case_when(
      EOSSTT == "COMPLETED" ~ NA_character_,
      TRUE ~ "STUDY ONGOING"  # Simplified
    )
  ) %>%
  
  # Add exposure summary from EX domain
  left_join(
    ex_sdtm %>%
      filter(EXDOSE > 0) %>%  # Exclude placebo
      group_by(USUBJID) %>%
      summarise(
        TRTDUR = sum(as.numeric(EXENDTC - EXSTDTC) + 1, na.rm = TRUE),
        AVGDD = mean(EXDOSE, na.rm = TRUE),
        CUMDOSE = sum(EXDOSE, na.rm = TRUE),
        .groups = "drop"
      ),
    by = "USUBJID"
  ) %>%
  
  # Clean up and select key variables
  select(
    # Identifiers
    STUDYID, USUBJID, SUBJID, SITEID,
    # Treatment
    TRT01P, TRT01PN, TRT01A, TRT01AN,
    # Demographics  
    AGE, AGEGR1, AGEGR1N, SEX, RACE, ETHNIC,
    # Dates
    TRTSDT, TRTEDT, RANDDT,
    # Durations and dosing
    TRTDURD, TRTDUR, AVGDD, CUMDOSE,
    # Populations
    SAFFL, ITTFL, PPROTFL,
    # Disposition
    EOSSTT, DCSREAS
  )

cat("ADSL created with", nrow(adsl), "subjects\n")

# =================
# ADEX Creation (Exposure Analysis Dataset) 
# =================

cat("Creating ADEX (Exposure Analysis Dataset)...\n")

adex <- ex_sdtm %>%
  # Join with ADSL for treatment and demographic info
  left_join(
    adsl %>% select(USUBJID, TRT01P, TRT01PN, AGE, SEX, SAFFL, ITTFL),
    by = "USUBJID"
  ) %>%
  mutate(
    # Standard ADaM variables
    STUDYID = STUDYID,
    USUBJID = USUBJID,
    
    # Analysis treatment (same as planned treatment for this example)
    TRTA = TRT01P,
    TRTAN = TRT01PN,
    
    # Exposure parameters
    PARAMCD = "DOSE",
    PARAM = "Daily Dose (mg)",
    AVAL = EXDOSE,
    AVALC = as.character(EXDOSE),
    
    # Analysis visit
    AVISIT = paste("Day", EXSTDY),
    AVISITN = EXSTDY,
    
    # Timing variables
    ADT = EXSTDTC,
    ADTM = as.POSIXct(paste(EXSTDTC, "00:00:00")),
    
    # Study day
    ADY = EXSTDY,
    
    # Base variables (for change from baseline if needed)
    BASE = case_when(
      EXSEQ == 1 ~ EXDOSE,  # First dose as baseline
      TRUE ~ NA_real_
    )
  ) %>%
  
  # Fill baseline value within subject
  group_by(USUBJID) %>%
  mutate(BASE = first(BASE[!is.na(BASE)])) %>%
  ungroup() %>%
  
  mutate(
    # Change from baseline
    CHG = AVAL - BASE,
    PCHG = (CHG / BASE) * 100
  ) %>%
  
  # Population flags  
  mutate(
    SAFFL = SAFFL,
    ITTFL = ITTFL
  ) %>%
  
  select(
    STUDYID, USUBJID, 
    TRTA, TRTAN,
    PARAMCD, PARAM,
    AVAL, AVALC, BASE, CHG, PCHG,
    AVISIT, AVISITN, ADT, ADTM, ADY,
    AGE, SEX, SAFFL, ITTFL
  )

cat("ADEX created with", nrow(adex), "records\n")

# =================
# Data Validation and QC
# =================

cat("\n=== Quality Control Checks ===\n")

# Check for required variables
required_adsl <- c("USUBJID", "TRT01P", "AGE", "SEX", "SAFFL", "ITTFL")
missing_adsl <- setdiff(required_adsl, names(adsl))
if(length(missing_adsl) > 0) {
  warning("Missing required ADSL variables: ", paste(missing_adsl, collapse = ", "))
} else {
  cat("✓ ADSL has all required variables\n")
}

# Check for duplicate subjects in ADSL
adsl_dups <- adsl %>% 
  count(USUBJID) %>% 
  filter(n > 1) %>% 
  nrow()
if(adsl_dups > 0) {
  warning("Found ", adsl_dups, " duplicate subjects in ADSL")
} else {
  cat("✓ No duplicate subjects in ADSL\n")
}

# Summary statistics
cat("\nADSL Summary:\n")
cat("- Total subjects:", nrow(adsl), "\n")
cat("- Safety population:", sum(adsl$SAFFL == "Y", na.rm = TRUE), "\n")
cat("- ITT population:", sum(adsl$ITTFL == "Y", na.rm = TRUE), "\n")
cat("- Mean age:", round(mean(adsl$AGE, na.rm = TRUE), 1), "years\n")

cat("\nADEX Summary:\n") 
cat("- Total exposure records:", nrow(adex), "\n")
cat("- Subjects with exposure data:", length(unique(adex$USUBJID)), "\n")

cat("\n=== ADaM Dataset Creation Complete ===\n")
cat("Datasets ready for analysis and TLF generation\n")

# Derive ADex: exposure analysis dataset
adex <- ex %>%
  group_by(USUBJID) %>%
  summarise(
    TRTDOSE = sum(EXDOSE, na.rm = TRUE),
    EXSTDT = min(EXSTDTC, na.rm = TRUE),
    EXENDT = max(EXENDTC, na.rm = TRUE)
  ) %>%
  ungroup()

# Merge ADSL and ADex to build ADAE-like structure
ad <- adsl %>%
  left_join(adex, by = "USUBJID") %>%
  mutate(
    TRTDU = as.integer(EXENDT - EXSTDT + 1),
    TRTDOSE = ifelse(is.na(TRTDOSE), 0, TRTDOSE)
  )

# Preview
print(ad)
