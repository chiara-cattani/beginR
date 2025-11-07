# date_text_functions.R
# Practical Examples: Date and Text Processing in R
# Module 4: Working with Dates, Times, and Text Data
# lubridate and stringr Package Examples

library(lubridate)
library(stringr)
library(dplyr)

cat("=== Date and Text Processing Examples ===\n")
cat("Practical functions for Module 4\n\n")

# ===== DATE PROCESSING WITH LUBRIDATE =====
cat("=== Date Processing ===\n")

# Sample date data
dates <- c("2024-01-15", "15-JAN-2024", "01/15/2024", "2024-01-15 14:30:00")
sas_dates <- c("15JAN2024", "03FEB2024", "29DEC2023")

# Parse different date formats
parsed_dates <- ymd(dates[1])
parsed_sas <- dmy(str_replace_all(sas_dates, "([0-9]{2})([A-Z]{3})([0-9]{4})", "\\1-\\2-\\3"))

# Date components
today <- today()
cat("Today:", as.character(today), "\n")
cat("Year:", year(today), "\n")
cat("Month:", month(today, label = TRUE), "\n")
cat("Day:", day(today), "\n")
cat("Weekday:", wday(today, label = TRUE), "\n")

# Date calculations
study_start <- ymd("2024-01-15")
study_end <- study_start + weeks(12)
study_duration <- interval(study_start, study_end) / days(1)

cat("Study duration:", study_duration, "days\n")

# Age calculation function
calculate_age <- function(birth_date, reference_date = today()) {
  interval(birth_date, reference_date) / years(1)
}

# Example usage
birth_dates <- ymd(c("1980-05-15", "1975-12-03", "1990-08-22"))
ages <- calculate_age(birth_dates)
cat("Ages:", round(ages, 1), "\n")

# ===== TEXT PROCESSING WITH STRINGR =====
cat("\n=== Text Processing ===\n")

# Sample text data
subject_ids <- c("SITE001-001", "SITE001-002", "SITE002-003", "SITE003-001")
adverse_events <- c("Headache (mild)", "Nausea", "Fatigue (moderate)", "Dizziness (severe)")
lab_values <- c("HGB: 12.5 g/dL", "WBC: 7.2 K/uL", "PLT: 250 K/uL")

# String detection and extraction
site_numbers <- str_extract(subject_ids, "SITE[0-9]+")
subject_numbers <- str_extract(subject_ids, "[0-9]+$")

cat("Site numbers:", paste(site_numbers, collapse = ", "), "\n")
cat("Subject numbers:", paste(subject_numbers, collapse = ", "), "\n")

# Clean AE terms
clean_aes <- str_remove_all(adverse_events, "\\s*\\([^)]+\\)")
ae_severity <- str_extract(adverse_events, "(?<=\\().*(?=\\))")

cat("Clean AE terms:", paste(clean_aes, collapse = ", "), "\n")
cat("AE severity:", paste(ae_severity, collapse = ", "), "\n")

# Extract numeric values from lab results
lab_numbers <- str_extract(lab_values, "[0-9.]+")
lab_units <- str_extract(lab_values, "[A-Za-z/]+$")

cat("Lab values:", paste(lab_numbers, collapse = ", "), "\n")
cat("Lab units:", paste(lab_units, collapse = ", "), "\n")

# ===== PRACTICAL FUNCTIONS =====
cat("\n=== Practical Utility Functions ===\n")

# Standardize text function
standardize_text <- function(text) {
  text %>%
    str_to_upper() %>%
    str_trim() %>%
    str_replace_all("\\s+", " ")
}

# Parse SAS date function
parse_sas_date <- function(sas_date_char) {
  # Convert SAS date format (e.g., "15JAN2024") to Date
  dmy(str_replace_all(sas_date_char, "([0-9]{1,2})([A-Z]{3})([0-9]{4})", "\\1-\\2-\\3"))
}

# Create visit day function
calculate_study_day <- function(visit_date, baseline_date) {
  as.numeric(visit_date - baseline_date) + 1
}

# Format datetime for output
format_datetime <- function(datetime, format = "dd-mmm-yyyy HH:MM") {
  case_when(
    format == "sas" ~ format(datetime, "%d%b%Y %H:%M", na_encode = FALSE),
    format == "iso" ~ format(datetime, "%Y-%m-%d %H:%M:%S", na_encode = FALSE),
    TRUE ~ format(datetime, "%d-%b-%Y %H:%M", na_encode = FALSE)
  )
}

# ===== EXAMPLE APPLICATIONS =====
cat("\n=== Example Applications ===\n")

# Create sample dataset
sample_data <- tibble(
  subject_id = subject_ids,
  visit_date = ymd(c("2024-01-15", "2024-01-22", "2024-02-01", "2024-02-05")),
  baseline_date = ymd("2024-01-15"),
  age_text = c("45 years", "38 years", "52 years", "29 years"),
  comments = c("Patient feeling well", "MILD headache reported", "no adverse events", "FATIGUE (moderate)")
)

# Apply functions
processed_data <- sample_data %>%
  mutate(
    site_id = str_extract(subject_id, "SITE[0-9]+"),
    subject_num = str_extract(subject_id, "[0-9]+$"),
    study_day = calculate_study_day(visit_date, baseline_date),
    age_numeric = as.numeric(str_extract(age_text, "[0-9]+")),
    clean_comments = standardize_text(comments),
    formatted_visit = format_datetime(as.POSIXct(paste(visit_date, "09:00:00")))
  )

print(processed_data)

cat("\n=== Summary ===\n")
cat("Created functions for:\n")
cat("• Date parsing and calculations\n")
cat("• Text cleaning and extraction\n")
cat("• Study day calculations\n")
cat("• Standardized formatting\n")
cat("• Age and duration computations\n")