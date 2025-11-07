# Module 1 Exercise — RStudio & Environment Setup
# Practice your RStudio skills and essential package usage

# ===========================
# SETUP: Load Required Packages  
# ===========================

# Load the essential packages (if you get errors, install them first)
library(dplyr)      # Data manipulation
library(haven)      # SAS file I/O  
library(tibble)     # Enhanced data frames
library(lubridate)  # Date handling
library(stringr)    # String manipulation

# Check your working directory
getwd()

# ===========================
# EXERCISE 1: Create Clinical Dataset
# ===========================

# Create a demographics dataset using tibble() with the following variables:
# - USUBJID: Subject IDs ("001-001", "001-002", "001-003", "001-004", "001-005")  
# - AGE: Ages (25, 45, 67, 52, 71)
# - SEX: Sex ("F", "M", "F", "M", "F")
# - RFSTDTC: Reference start dates ("2024-01-15", "2024-01-16", "2024-01-17", "2024-01-18", "2024-01-19")

# Create the dataset here:
dm <- # YOUR CODE HERE

# Display the dataset to check it was created correctly
dm

# ===========================
# EXERCISE 2: Basic Data Exploration
# ===========================

# Use different methods to explore your dataset:
# 1. Use View() to open the data viewer
# YOUR CODE HERE

# 2. Use glimpse() to see the structure
# YOUR CODE HERE

# 3. Use summary() to get summary statistics
# YOUR CODE HERE

# ===========================
# EXERCISE 3: Create Derived Variables
# Use mutate() to add all three variables:
dm <- dm %>%
  mutate(
    # YOUR CODE HERE - add ELDERLY variable
    # YOUR CODE HERE - add RFSTDT variable  
    # YOUR CODE HERE - add AGE_GROUP variable using case_when()
  )

# Display the updated dataset
dm

# ===========================
# EXERCISE 4: Data Summarization
# ===========================

# Use group_by() and summarise() to answer these questions:

# 1. How many subjects are in each age group?
age_group_summary <- # YOUR CODE HERE

# 2. What is the mean age by sex?
age_by_sex <- # YOUR CODE HERE

# 3. How many elderly vs non-elderly subjects are there?
elderly_summary <- # YOUR CODE HERE

# Display your summaries
age_group_summary
age_by_sex  
elderly_summary

# ===========================
# EXERCISE 5: RStudio Features Practice
# ===========================

# Practice these RStudio features:
# 1. Use auto-completion: Type dm$ and see what options appear
# 2. Get help: Run ?mutate to see the help documentation
# 3. View data: Use View(dm) to open the data viewer
# 4. Check environment: Look at the Environment pane - what objects do you see?

# Try the auto-completion here:
# dm$

# ===========================
# EXERCISE 6: GitHub Copilot in RStudio Practice
# ===========================

# Try writing these comments and see what Copilot suggests in RStudio:

# Create a flag for subjects under 30 years old


# Calculate days since study start for each subject


# Create a BMI category variable (you can make up BMI values)


# ===========================
# EXERCISE 7: String Manipulation Practice
# ===========================

# Use stringr functions to:
# 1. Extract the site number from USUBJID (the part before the dash)
# 2. Create a formatted subject label like "Subject 001-001 (Age: 25)"

dm <- dm %>%
  mutate(
    # YOUR CODE HERE - extract site using str_extract()
    SITE = str_extract(USUBJID, "\\d{3}"),  # Hint: this extracts first 3 digits
    
    # YOUR CODE HERE - create formatted label  
    SUBJ_LABEL = paste0("Subject ", USUBJID, " (Age: ", AGE, ")")
  )

# Display results
dm

# ===========================
# BONUS: Create a Simple Summary Report
# ===========================

# Create a text summary of your dataset
cat("=== DEMOGRAPHICS SUMMARY ===\n")
cat("Total subjects:", nrow(dm), "\n")
cat("Age range:", min(dm$AGE), "to", max(dm$AGE), "\n") 
cat("Female subjects:", sum(dm$SEX == "F"), "\n")
cat("Male subjects:", sum(dm$SEX == "M"), "\n")
cat("Elderly subjects (65+):", sum(dm$ELDERLY == "Y"), "\n")

# ===========================
# EXERCISE COMPLETE!
# ===========================

cat("\n🎉 Congratulations! You've completed Module 1 exercises!\n")
cat("\nYou practiced:\n")
cat("- Creating tibbles with clinical data\n")
cat("- Using dplyr for data manipulation\n") 
cat("- Working with dates using lubridate\n")
cat("- String manipulation with stringr\n")
cat("- Data summarization and exploration\n")
cat("- RStudio interface features\n")
cat("- GitHub Copilot in RStudio assistance\n")
cat("\nReady for Module 2: Data Wrangling Basics!\n")
