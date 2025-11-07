# Module 4 Exercise — Date & Text Handling
# Practice lubridate and stringr functions with clinical data

# ===========================
# SETUP: Load Required Packages
# ===========================

library(dplyr)
library(tibble)
library(lubridate)
library(stringr)

# ===========================
# EXERCISE 1: Date Parsing Challenge
# ===========================

# Create a dataset with messy date formats (realistic clinical scenario)
ae_raw <- tibble(
  USUBJID = c("001-001", "001-002", "001-003", "001-004", "001-005", "001-006"),
  AEDECOD = c("HEADACHE", "NAUSEA", "FATIGUE", "DIZZINESS", "RASH", "COUGH"),
  AESTDTC_MESSY = c("2024-01-20", "25/01/2024", "01/18/2024", "20240122", "2024/01/25", "Jan 26, 2024"),
  RFSTDTC = rep("2024-01-15", 6)
)

# YOUR TASK: Clean and parse the dates
# 1. Create AESTDT by parsing AESTDTC_MESSY (hint: use case_when with different lubridate functions)
# 2. Create RFSTDT by parsing RFSTDTC
# 3. Calculate AESTDY using the formula: AESTDT - RFSTDT + 1

ae_dates <- ae_raw %>%
  mutate(
    # YOUR CODE HERE - parse AESTDTC_MESSY
    AESTDT = case_when(
      # Add your date parsing logic here
      # Hint: use str_detect() to identify patterns, then ymd(), dmy(), mdy() etc.
    ),
    
    # YOUR CODE HERE - parse RFSTDTC
    RFSTDT = ,
    
    # YOUR CODE HERE - calculate study day
    AESTDY = 
  )

# Display results
print("Parsed dates and study days:")
print(ae_dates)

# ===========================
# EXERCISE 2: Study Day Categories
# ===========================

# Add study day categories to your dataset
ae_with_categories <- ae_dates %>%
  mutate(
    # YOUR CODE HERE - create study day categories
    STUDYDAY_PERIOD = case_when(
      # Add your logic here:
      # AESTDY <= 0 should be "Pre-treatment"
      # AESTDY 1-7 should be "Week 1"  
      # AESTDY 8-14 should be "Week 2"
      # AESTDY 15-28 should "Month 1"
      # > 28 should be "After Month 1"
      # Missing should be "Unknown"
    ),
    
    # YOUR CODE HERE - create early AE flag (within first 7 days)
    EARLY_AE = 
  )

# Display results
print("With study day categories:")
print(ae_with_categories)

# ===========================
# EXERCISE 3: String Cleaning Challenge
# ===========================

# Create messy adverse event terms
ae_messy_text <- tibble(
  USUBJID = c("001-001", "001-002", "001-003", "001-004", "001-005"),
  AEDECOD_RAW = c(
    "  mild headache  ",
    "SEVERE nausea (grade 3)",
    "fatigue - moderate",
    "  DIZZINESS mild  ",
    "skin rash (MODERATE)"
  ),
  MEDICATION = c("Ibuprofen 400mg", "ondansetron 8 MG", "caffeine 200mg", "rest", "hydrocortisone 1%")
)

# YOUR TASK: Clean and extract information
ae_cleaned <- ae_messy_text %>%
  mutate(
    # YOUR CODE HERE - clean adverse event terms
    AEDECOD_CLEAN = AEDECOD_RAW %>%
      # Step 1: Remove leading/trailing spaces
      # Step 2: Convert to uppercase  
      # Step 3: Remove parentheses and contents
      # Step 4: Remove dashes and extra spaces
      # Step 5: Final trim
    
    # YOUR CODE HERE - extract severity
    SEVERITY = case_when(
      # Use str_detect with (?i) for case-insensitive matching
      # Check for "mild", "moderate", "severe" in AEDECOD_RAW
    ),
    
    # YOUR CODE HERE - extract base term (remove severity words)
    AETERM_BASE = AEDECOD_CLEAN %>%
      # Remove severity words from beginning and end
    
    # YOUR CODE HERE - create specific AE flags
    HEADACHE_FLAG = ,
    NAUSEA_FLAG = ,
    FATIGUE_FLAG = ,
    
    # YOUR CODE HERE - extract numeric dose from medication
    DOSE_NUMERIC = as.numeric(str_extract(MEDICATION, "\\d+")),
    
    # YOUR CODE HERE - clean medication names
    MED_CLEAN = MEDICATION %>%
      # Remove dose information and clean
  )

# Display results  
print("Cleaned text data:")
print(ae_cleaned)

# ===========================
# EXERCISE 4: AESTDY Derivation Practice
# ===========================

# Create a more complex dataset for AESTDY practice
complex_ae <- tibble(
  USUBJID = c("001-001", "001-001", "001-002", "001-002", "001-003"),
  AESEQ = c(1, 2, 1, 2, 1),
  AEDECOD = c("HEADACHE", "NAUSEA", "FATIGUE", "HEADACHE", "DIZZINESS"),
  AESTDTC = c("2024-01-20T08:30", "2024-01-25T14:15", "2024-01-18T09:00", "2024-01-22T16:30", NA),
  AEENDTC = c("2024-01-21T10:00", "2024-01-26T08:00", "2024-01-20T18:00", "2024-01-23T12:00", NA),
  RFSTDTC = c("2024-01-15T09:00", "2024-01-15T09:00", "2024-01-16T10:00", "2024-01-16T10:00", "2024-01-15T09:00")
)

# YOUR TASK: Derive comprehensive study day variables
complex_ae_derived <- complex_ae %>%
  mutate(
    # YOUR CODE HERE - parse start dates/times
    AESTDT = ,
    AEENDT = ,
    RFSTDT = ,
    
    # YOUR CODE HERE - calculate study days
    AESTDY = ,
    AEENDY = ,
    
    # YOUR CODE HERE - calculate duration
    AE_DURATION_DAYS = ,
    
    # YOUR CODE HERE - handle missing dates
    AESTDY_SAFE = case_when(
      # Add logic to handle missing dates appropriately
    ),
    
    # YOUR CODE HERE - create validation flags
    VALID_DATES = case_when(
      # Check for data quality issues
    )
  )

# Display results
print("Complex AESTDY derivations:")
print(complex_ae_derived)

# ===========================
# EXERCISE 5: GitHub Copilot in RStudio Practice
# ===========================

# Try writing these comments and let Copilot help in RStudio:

# Convert datetime string to date only


# Flag weekend adverse events


# Calculate time between AE start and end in hours


# Extract the first word from AEDECOD


# ===========================
# BONUS: Combined Date and Text Challenge
# ===========================

# Combine everything you've learned
final_challenge <- complex_ae_derived %>%
  mutate(
    # YOUR CODE HERE - create comprehensive AE description
    AE_DESCRIPTION = paste0(
      # Combine: AEDECOD, study day, duration
    ),
    
    # YOUR CODE HERE - create analysis-ready flags
    ONGOING_AE = ,
    EARLY_ONSET = ,
    LONG_DURATION = 
  )

# ===========================
# SUMMARY STATISTICS
# ===========================

# Calculate summary statistics
cat("\n=== EXERCISE SUMMARY ===\n")
cat("AEs by study day period:\n")
print(table(ae_with_categories$STUDYDAY_PERIOD, useNA = "ifany"))

cat("\nAEs by severity:\n") 
print(table(ae_cleaned$SEVERITY, useNA = "ifany"))

cat("\nEarly AEs (≤7 days):\n")
print(sum(ae_with_categories$EARLY_AE == "Y", na.rm = TRUE))

# ===========================
# EXERCISE COMPLETE!
# ===========================

cat("\n🎉 Module 4 Exercise Complete!\n")
cat("You practiced:\n")
cat("- Parsing different date formats with lubridate\n")
cat("- Calculating study days (AESTDY)\n")
cat("- String cleaning and standardization\n")
cat("- Text pattern detection and extraction\n")
cat("- Handling missing and invalid dates\n")
cat("- Data quality validation\n")
cat("- Combined date and text operations\n")
cat("\nExcellent work! Ready for Module 5: Functions & Macro Translation!\n")
