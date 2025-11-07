# Module 4 Demo — Date & Text Handling
# Hands-on practice with lubridate and stringr for clinical programming

# ----------------------------
# 📦 Load Required Libraries
# ----------------------------

library(dplyr)
library(tibble)
library(lubridate)
library(stringr)

# ----------------------------
# � Part 1: Date Conversion Practice
# ----------------------------

# Create sample adverse events data with different date formats
ae_raw <- tibble(
  USUBJID = c("001-001", "001-001", "001-002", "001-002", "001-003"),
  AEDECOD = c("HEADACHE", "NAUSEA", "FATIGUE", "DIZZINESS", "RASH"),
  AESTDTC_RAW = c("2024-01-20", "25/01/2024", "01/18/2024", "2024-01-22", "20240125"),
  RFSTDTC = c("2024-01-15", "2024-01-15", "2024-01-16", "2024-01-16", "2024-01-15"),
  AETM = c("08:30", "14:15", "09:45", "16:20", "11:30")
)

print("Raw adverse events data:")
print(ae_raw)

# Practice different date parsing functions
ae_dates <- ae_raw %>%
  mutate(
    # Try to parse dates automatically
    AESTDT_AUTO = case_when(
      str_detect(AESTDTC_RAW, "^\\d{4}-\\d{2}-\\d{2}$") ~ ymd(AESTDTC_RAW),
      str_detect(AESTDTC_RAW, "^\\d{2}/\\d{2}/\\d{4}$") ~ dmy(AESTDTC_RAW),
      str_detect(AESTDTC_RAW, "^\\d{2}/\\d{2}/\\d{4}$") ~ mdy(AESTDTC_RAW),
      str_detect(AESTDTC_RAW, "^\\d{8}$") ~ ymd(AESTDTC_RAW),
      TRUE ~ as.Date(NA)
    ),
    
    # Convert reference start date
    RFSTDT = ymd(RFSTDTC),
    
    # Show the parsing results
    DATE_FORMAT = case_when(
      str_detect(AESTDTC_RAW, "^\\d{4}-\\d{2}-\\d{2}$") ~ "ISO (YYYY-MM-DD)",
      str_detect(AESTDTC_RAW, "^\\d{2}/\\d{2}/\\d{4}$") ~ "European (DD/MM/YYYY)",
      str_detect(AESTDTC_RAW, "^\\d{2}/\\d{2}/\\d{4}$") ~ "US (MM/DD/YYYY)",
      str_detect(AESTDTC_RAW, "^\\d{8}$") ~ "Compact (YYYYMMDD)",
      TRUE ~ "Unknown"
    )
  )

print("\nDates parsed:")
print(ae_dates)

# ----------------------------
# 📊 Part 2: Study Day Calculations
# ----------------------------

# Calculate AESTDY (study day)
ae_with_studyday <- ae_dates %>%
  mutate(
    # Basic study day calculation
    AESTDY = as.numeric(AESTDT_AUTO - RFSTDT) + 1,
    
    # Handle edge cases
    AESTDY_SAFE = case_when(
      is.na(AESTDT_AUTO) | is.na(RFSTDT) ~ NA_real_,
      AESTDT_AUTO < RFSTDT ~ as.numeric(AESTDT_AUTO - RFSTDT),  # Negative days (pre-treatment)
      TRUE ~ as.numeric(AESTDT_AUTO - RFSTDT) + 1               # Positive days (post-treatment)
    ),
    
    # Create study day categories
    STUDYDAY_PERIOD = case_when(
      is.na(AESTDY_SAFE) ~ "Missing",
      AESTDY_SAFE <= 0 ~ "Pre-treatment",
      AESTDY_SAFE <= 7 ~ "Week 1",
      AESTDY_SAFE <= 14 ~ "Week 2", 
      AESTDY_SAFE <= 28 ~ "Month 1",
      TRUE ~ "After Month 1"
    )
  )

print("\nWith study day calculations:")
print(ae_with_studyday)

# ----------------------------
# 📝 Part 3: String Manipulation Practice
# ----------------------------

# Create messy adverse event terms (realistic clinical data scenario)
ae_messy <- tibble(
  USUBJID = c("001-001", "001-002", "001-003", "001-004", "001-005"),
  AEDECOD_RAW = c(
    "  mild HEADACHE  ",
    "NAUSEA (moderate)",
    "severe FATIGUE",
    "Dizziness - mild",
    "  RASH  moderate  "
  ),
  DOSE_INFO = c("10mg once daily", "5 MG twice daily", "20mg QD", "15 mg BID", "25mg daily")
)

print("\nMessy AE terms:")
print(ae_messy)

# Clean and standardize text
ae_cleaned <- ae_messy %>%
  mutate(
    # Basic cleaning
    AEDECOD_CLEAN = AEDECOD_RAW %>%
      str_trim() %>%                                    # Remove leading/trailing spaces
      str_to_upper() %>%                               # Convert to uppercase
      str_replace_all("\\s+", " ") %>%                 # Replace multiple spaces with single
      str_replace_all("\\([^)]*\\)", "") %>%           # Remove parentheses and contents
      str_replace_all(" - ", " ") %>%                  # Remove dashes
      str_trim(),                                      # Trim again
    
    # Extract severity from the term
    SEVERITY_EXTRACTED = case_when(
      str_detect(AEDECOD_RAW, "(?i)mild") ~ "MILD",
      str_detect(AEDECOD_RAW, "(?i)moderate") ~ "MODERATE",
      str_detect(AEDECOD_RAW, "(?i)severe") ~ "SEVERE",
      TRUE ~ "UNKNOWN"
    ),
    
    # Extract base term (remove severity qualifiers)
    AETERM_BASE = AEDECOD_CLEAN %>%
      str_replace_all("^(MILD|MODERATE|SEVERE)\\s+", "") %>%  # Remove severity at start
      str_replace_all("\\s+(MILD|MODERATE|SEVERE)$", ""),     # Remove severity at end
    
    # Create flags based on text patterns
    HEADACHE_FLAG = ifelse(str_detect(AETERM_BASE, "HEADACHE"), "Y", "N"),
    GI_FLAG = ifelse(str_detect(AETERM_BASE, "NAUSEA|VOMITING|DIARRHEA"), "Y", "N"),
    
    # Clean dose information
    DOSE_CLEAN = DOSE_INFO %>%
      str_to_upper() %>%
      str_replace_all("ONCE DAILY|QD", "QD") %>%
      str_replace_all("TWICE DAILY|BID", "BID") %>%
      str_replace_all("\\s+", " ") %>%
      str_trim(),
    
    # Extract numeric dose
    DOSE_NUMERIC = as.numeric(str_extract(DOSE_INFO, "\\d+")),
    
    # Extract dose frequency
    DOSE_FREQ = case_when(
      str_detect(DOSE_CLEAN, "QD|DAILY") ~ "QD",
      str_detect(DOSE_CLEAN, "BID|TWICE") ~ "BID",
      TRUE ~ "OTHER"
    )
  )

print("\nCleaned AE data:")
print(ae_cleaned)

# ----------------------------
# 📊 Part 4: Combining Date and Text Operations
# ----------------------------

# Comprehensive example combining both date and text handling
final_ae <- ae_with_studyday %>%
  left_join(ae_cleaned, by = "USUBJID") %>%
  mutate(
    # Combine clean AE term with study day info
    AE_SUMMARY = paste0(AETERM_BASE, " (Day ", AESTDY_SAFE, ")"),
    
    # Create comprehensive AE description
    AE_DESCRIPTION = paste0(
      AETERM_BASE, " - ", 
      SEVERITY_EXTRACTED, " severity, ",
      "occurred on study day ", AESTDY_SAFE,
      " (", STUDYDAY_PERIOD, ")"
    ),
    
    # Validate data quality
    DATA_QUALITY = case_when(
      is.na(AESTDY_SAFE) ~ "Missing study day",
      is.na(AETERM_BASE) | AETERM_BASE == "" ~ "Missing AE term",
      SEVERITY_EXTRACTED == "UNKNOWN" ~ "Missing severity",
      TRUE ~ "Complete"
    )
  ) %>%
  select(USUBJID, AEDECOD_RAW, AETERM_BASE, SEVERITY_EXTRACTED, 
         AESTDY_SAFE, STUDYDAY_PERIOD, AE_DESCRIPTION, DATA_QUALITY)

print("\nFinal comprehensive AE dataset:")
print(final_ae)

# ----------------------------
# 🤖 Part 5: GitHub Copilot in RStudio Practice
# ----------------------------

cat("\n=== GitHub Copilot in RStudio Practice ===\n")
cat("Try writing these comments and see what Copilot suggests in RStudio:\n\n")

# Calculate days between AE start and study end date


# Extract the first word from adverse event term


# Flag AEs that occurred within 30 days of treatment start
final_ae <- final_ae %>%
  mutate(EARLY_AE = ifelse(AESTDY_SAFE <= 30 & AESTDY_SAFE > 0, "Y", "N"))

# Create time-to-event calculation from reference date


# ----------------------------
# Module 4 Demo Complete!
# ----------------------------

cat("\n🎉 Module 4 Demo Complete!\n")
cat("You've practiced:\n")
cat("- Date parsing with lubridate (ymd, dmy, mdy)\n")
cat("- Study day calculations (AESTDY)\n")
cat("- String cleaning with stringr functions\n")
cat("- Text pattern detection and extraction\n")
cat("- Combining date and text operations\n")
cat("- Data quality validation\n")
cat("- GitHub Copilot in RStudio assistance\n")
cat("\nReady for Module 5: Functions & Macro Translation!\n")
