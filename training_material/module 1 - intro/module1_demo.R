# Module 1 Demo — RStudio & Environment Setup
# Hands-on practice with RStudio interface and essential packages

# ----------------------------
# Part 1: Environment Setup
# ----------------------------

# Check R version and session info
R.version.string
sessionInfo()

# Set up working directory (use getwd() to see current directory)
getwd()

# Optional: Set working directory to script location
# setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# ----------------------------
# Part 2: Install and Load Essential Packages
# ----------------------------

# Install packages (run once - commented out after first use)
# install.packages(c("dplyr", "haven", "tibble", "lubridate", "stringr"))

# Load packages (run every session)
library(dplyr)      # Data manipulation
library(haven)      # Read/write SAS files
library(tibble)     # Enhanced data frames
library(lubridate)  # Date/time handling
library(stringr)    # String manipulation

# Check that packages loaded successfully
search()  # Shows loaded packages

# ----------------------------
# Part 3: Basic R Syntax and RStudio Practice
# ----------------------------

# Create some variables
subject_id <- "001-001"
age <- 45
study_date <- "2024-01-15"

# Display variables (try different methods)
subject_id
print(age)
cat("Study date:", study_date, "\n")

# Create a simple clinical dataset
dm <- tibble(
  USUBJID = c("001-001", "001-002", "001-003", "001-004", "001-005"),
  AGE = c(45, 62, 28, 71, 55),
  SEX = c("M", "F", "F", "M", "F"),
  RFSTDTC = c("2024-01-15", "2024-01-16", "2024-01-17", "2024-01-18", "2024-01-19")
)

# View the dataset (explore different viewing methods)
dm                    # Print in console
View(dm)             # Open in data viewer (try this!)
glimpse(dm)          # Structure overview
head(dm)             # First few rows

# ----------------------------
# Part 4: nutriciaconfig Demo (if available)
# ----------------------------

# Note: This section assumes nutriciaconfig package is available
# If not available, skip to Part 5

# Load nutriciaconfig (uncomment if package is available)
# library(nutriciaconfig)

# Example setup (replace with actual nutriciaconfig functions)
# nutriciaconfig::setup_project("module1_demo")
# nutriciaconfig::configure_paths()

# For now, demonstrate basic project organization
cat("Project organization tips:\n")
cat("- Keep data in /data folder\n") 
cat("- Keep scripts in /programs folder\n")
cat("- Keep outputs in /outputs folder\n")

# ----------------------------
# Part 5: GitHub Copilot Practice
# ----------------------------

# Practice with comments that Copilot can help with:

# Create an elderly flag for subjects 65 years and older
dm <- dm %>%
  mutate(ELDERLY = ifelse(AGE >= 65, "Y", "N"))

# Convert character date to proper Date format
dm <- dm %>%
  mutate(RFSTDT = ymd(RFSTDTC))

# View results
dm

# Check the Environment pane in RStudio - you should see the dm dataset
# Click on dm in the Environment to open it in the data viewer

# ----------------------------
# Part 6: Exploring RStudio Features  
# ----------------------------

# Try these RStudio features:
# 1. Auto-completion: Type "dm$" and see what RStudio suggests
# 2. Help: Type ?mutate in console to see help documentation
# 3. History: Check the History tab to see previous commands

# Practice with pipe operator
dm_summary <- dm %>%
  filter(AGE >= 18) %>%        # Filter adults only
  mutate(AGE_GROUP = case_when(  # Create age groups
    AGE < 65 ~ "Adult",
    AGE >= 65 ~ "Elderly"
  )) %>%
  select(USUBJID, AGE, AGE_GROUP, ELDERLY)  # Select specific columns

# View the result
dm_summary

# ----------------------------
# Part 7: Basic Data Exploration
# ----------------------------

# Summary statistics
summary(dm$AGE)

# Count by sex
dm %>% count(SEX)

# Count by elderly flag
dm %>% count(ELDERLY)

# ----------------------------
# Part 8: GitHub Copilot Practice
# ----------------------------

# Try typing these comments and see what Copilot suggests:

# Calculate the mean age of subjects
mean_age <- mean(dm$AGE)
print(paste("Mean age:", round(mean_age, 1)))

# Create a treatment assignment (randomly for demo)
set.seed(123)  # For reproducible results
dm <- dm %>%
  mutate(TRT01A = sample(c("Placebo", "Treatment"), size = n(), replace = TRUE))

# View final dataset
dm

# ----------------------------
# Part 9: RStudio Tips
# ----------------------------

cat("RStudio Tips for Clinical Programming:\n")
cat("1. Use Ctrl+Enter to run current line or selection\n")
cat("2. Use Ctrl+Shift+Enter to run entire script\n") 
cat("3. Use Tab for auto-completion\n")
cat("4. Use Ctrl+1/2/3/4 to focus different panes\n")
cat("5. Use Projects (.Rproj) to organize your work\n")
cat("6. Check Environment pane to see all variables\n")
cat("7. Use View() to open data in spreadsheet-like viewer\n")

# End of Module 1 Demo
cat("\nModule 1 Demo Complete! 🎉\n")
cat("You've successfully:\n")
cat("- Set up your R environment\n") 
cat("- Loaded essential packages\n")
cat("- Created and manipulated clinical data\n")
cat("- Practiced using RStudio features\n")
cat("- Experimented with GitHub Copilot\n")
