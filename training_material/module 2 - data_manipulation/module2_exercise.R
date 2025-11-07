# Module 2 Exercise — Data Wrangling Basics
# Practice dplyr functions with clinical demographics data

# ===========================
# SETUP: Load Required Packages
# ===========================

library(dplyr)
library(tibble)
library(lubridate)

# ===========================
# EXERCISE 1: Create Clinical Dataset
# ===========================

# Create a demographics dataset with the following subjects:
# USUBJID: "001-001", "001-002", "001-003", "001-004", "001-005", "001-006", "001-007", "001-008"
# AGE: 28, 45, 67, 52, 71, 34, 58, 76
# SEX: "F", "M", "F", "M", "F", "M", "F", "M"  
# RFSTDTC: "2024-01-15", "2024-01-16", "2024-01-17", "2024-01-18", "2024-01-19", "2024-01-20", "2024-01-21", "2024-01-22"
# COUNTRY: "USA", "CAN", "USA", "GBR", "USA", "CAN", "GBR", "USA"
# ARMCD: "TRT", "PBO", "TRT", "TRT", "PBO", "TRT", "PBO", "TRT"

dm <- # YOUR CODE HERE - create the tibble

# Display your dataset
dm

# ===========================
# EXERCISE 2: Filter Practice  
# ===========================

# 1. Filter subjects who are 65 years or older
elderly_subjects <- # YOUR CODE HERE

# 2. Filter female subjects only
female_subjects <- # YOUR CODE HERE

# 3. Filter subjects on treatment (ARMCD == "TRT") who are over 50
treatment_over_50 <- # YOUR CODE HERE

# 4. Filter subjects from North America (USA or CAN)
north_america <- # YOUR CODE HERE

# Display your results
cat("Elderly subjects:\n")
print(elderly_subjects)

cat("\nFemale subjects:\n") 
print(female_subjects)

cat("\nTreatment subjects over 50:\n")
print(treatment_over_50)

cat("\nNorth American subjects:\n")
print(north_america)

# ===========================
# EXERCISE 3: Select Practice
# ===========================

# 1. Select only USUBJID, AGE, and SEX
basic_demo <- # YOUR CODE HERE

# 2. Select all columns except COUNTRY
no_country <- # YOUR CODE HERE

# 3. Select USUBJID and all columns that start with "A" (AGE, ARMCD)
usubjid_and_a_vars <- # YOUR CODE HERE - hint: use starts_with()

# Display results
print(basic_demo)
print(no_country)
print(usubjid_and_a_vars)

# ===========================
# EXERCISE 4: Mutate Practice - Create Elderly Flag
# ===========================

# Add derived variables to dm:
# 1. ELDERLY: "Y" if AGE >= 65, "N" otherwise
# 2. RFSTDT: Convert RFSTDTC to Date format using ymd()
# 3. AGEGRP: "18-39", "40-64", "65+" based on age ranges
# 4. FEMALE: "Y" if SEX == "F", "N" otherwise
# 5. TREATMENT: "Active" if ARMCD == "TRT", "Placebo" otherwise

dm <- dm %>%
  mutate(
    # YOUR CODE HERE - add all five variables
  )

# Display the updated dataset
dm

# ===========================
# EXERCISE 5: Arrange Practice
# ===========================

# 1. Sort by age (ascending)
dm_by_age <- # YOUR CODE HERE

# 2. Sort by country, then by age (descending)  
dm_by_country_age <- # YOUR CODE HERE

# 3. Sort by treatment arm, then by elderly flag, then by age
dm_complex_sort <- # YOUR CODE HERE

# Display results
cat("Sorted by age:\n")
print(dm_by_age)

cat("\nSorted by country, then age (desc):\n")
print(dm_by_country_age)

# ===========================
# EXERCISE 6: Complex Pipeline Challenge
# ===========================

# Create a pipeline that:
# 1. Filters subjects >= 40 years old
# 2. Creates a variable MATURE = "Y" (since all will be >= 40)
# 3. Sorts by treatment arm, then age
# 4. Selects USUBJID, AGE, SEX, ARMCD, TREATMENT, ELDERLY, MATURE

mature_subjects <- dm %>%
  # YOUR CODE HERE - complete the pipeline

# Display result
cat("\nMature subjects (age >= 40) processed:\n")
print(mature_subjects)

# ===========================
# EXERCISE 7: Missing Values Practice
# ===========================

# Create a version of dm with some missing ages for practice
dm_with_na <- dm %>%
  mutate(AGE = case_when(
    USUBJID == "001-002" ~ NA_real_,
    USUBJID == "001-005" ~ NA_real_,
    TRUE ~ as.numeric(AGE)
  ))

# Create elderly flag that handles missing values properly
dm_with_na <- dm_with_na %>%
  mutate(
    ELDERLY_SAFE = case_when(
      # YOUR CODE HERE - handle missing AGE values
      # Hint: is.na(AGE) ~ NA_character_, then normal logic
    )
  )

# Display result  
cat("\nDataset with missing ages handled:\n")
print(dm_with_na)

# ===========================
# EXERCISE 8: GitHub Copilot Practice
# ===========================

# Try writing these comments and let Copilot suggest code:

# Create BMI categories assuming average BMI values


# Flag subjects enrolled in January 2024


# Create a site number from USUBJID (first 3 digits)


# ===========================
# BONUS: Create Summary Statistics
# ===========================

# Calculate summary statistics
cat("\n=== SUMMARY STATISTICS ===\n")
cat("Total subjects:", nrow(dm), "\n")
cat("Mean age:", round(mean(dm$AGE), 1), "\n")
cat("Age range:", min(dm$AGE), "to", max(dm$AGE), "\n")
cat("Elderly subjects:", sum(dm$ELDERLY == "Y"), "\n")
cat("Female subjects:", sum(dm$FEMALE == "Y"), "\n")
cat("Treatment subjects:", sum(dm$ARMCD == "TRT"), "\n")

# Count by categories
cat("\nAge groups:\n")
print(table(dm$AGEGRP))

cat("\nTreatment by elderly status:\n")
print(table(dm$ARMCD, dm$ELDERLY))

# ===========================
# EXERCISE COMPLETE!
# ===========================

cat("\n🎉 Module 2 Exercise Complete!\n")
cat("You practiced:\n")
cat("- Creating tibbles with clinical data\n")
cat("- filter() for subsetting rows\n")
cat("- select() for choosing columns\n")
cat("- mutate() for deriving variables\n")
cat("- arrange() for sorting data\n")
cat("- Handling missing values\n")
cat("- Complex data pipelines\n")
cat("- Clinical variable derivations (elderly flag!)\n")
cat("\nGreat job! Ready for Module 3: Joins and Summaries!\n")
