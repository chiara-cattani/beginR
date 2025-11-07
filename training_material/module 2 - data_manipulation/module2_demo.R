# Module 2 Demo — Data Wrangling Basics
# Hands-on practice with dplyr functions and clinical data manipulation

# Load required libraries
library(dplyr)
library(tibble)
library(lubridate)

# ----------------------------
# Part 1: Create Sample Clinical Data
# ----------------------------

# Create a demographics dataset with tibble
dm <- tibble(
  USUBJID = c("001-001", "001-002", "001-003", "001-004", "001-005", "001-006"),
  AGE = c(25, 45, 67, 52, 71, 34),
  SEX = c("F", "M", "F", "M", "F", "M"),
  RFSTDTC = c("2024-01-15", "2024-01-16", "2024-01-17", "2024-01-18", "2024-01-19", "2024-01-20"),
  COUNTRY = c("USA", "USA", "CAN", "USA", "CAN", "USA"),
  RACE = c("WHITE", "BLACK OR AFRICAN AMERICAN", "WHITE", "ASIAN", "WHITE", "WHITE")
)

# View the dataset structure
glimpse(dm)
head(dm)

# ----------------------------
# Part 2: filter() - Subset Rows
# ----------------------------

# Filter adults only (age >= 18) - though all are adults in this example
adults <- dm %>%
  filter(AGE >= 18)

cat("All subjects (adults only):\n")
print(adults)

# Filter elderly subjects (age >= 65)
elderly <- dm %>%
  filter(AGE >= 65)

cat("\nElderly subjects (age >= 65):\n")
print(elderly)

# Multiple conditions - elderly females  
elderly_females <- dm %>%
  filter(AGE >= 65 & SEX == "F")

cat("\nElderly female subjects:\n")
print(elderly_females)

# Filter by country
usa_subjects <- dm %>%
  filter(COUNTRY == "USA")

cat("\nUSA subjects:\n")
print(usa_subjects)

# ----------------------------
# Part 3: select() - Choose Columns
# ----------------------------

# Select specific columns
basic_demo <- dm %>%
  select(USUBJID, AGE, SEX)

cat("\nBasic demographics (select specific columns):\n")
print(basic_demo)

# Drop columns (exclude RACE and COUNTRY)
dm_no_race_country <- dm %>%
  select(-RACE, -COUNTRY)

cat("\nWithout race and country:\n")
print(dm_no_race_country)

# ----------------------------
# Part 4: mutate() - Create/Modify Variables
# ----------------------------

# Create elderly flag (age >= 65)
dm <- dm %>%
  mutate(ELDERLY = ifelse(AGE >= 65, "Y", "N"))

cat("\nWith elderly flag:\n")
print(dm)

# Create multiple derived variables
dm <- dm %>%
  mutate(
    # Convert RFSTDTC to proper Date format
    RFSTDT = ymd(RFSTDTC),
    
    # Create age groups using case_when
    AGEGRP = case_when(
      AGE < 40 ~ "Young Adult",
      AGE >= 40 & AGE < 65 ~ "Middle Age",
      AGE >= 65 ~ "Elderly"
    ),
    
    # Numeric version of age groups
    AGEGRPN = case_when(
      AGE < 40 ~ 1,
      AGE >= 40 & AGE < 65 ~ 2,
      AGE >= 65 ~ 3
    ),
    
    # Create sex flag 
    FEMALE = ifelse(SEX == "F", "Y", "N")
  )

cat("\nWith multiple derived variables:\n")
glimpse(dm)

# ----------------------------
# Part 5: arrange() - Sort Data
# ----------------------------

# Sort by age (ascending)
dm_sorted_age <- dm %>%
  arrange(AGE)

cat("\nSorted by age (ascending):\n")
print(dm_sorted_age)

# Sort by age (descending)
dm_sorted_age_desc <- dm %>%
  arrange(desc(AGE))

cat("\nSorted by age (descending):\n") 
print(dm_sorted_age_desc)

# Sort by multiple variables
dm_sorted_multi <- dm %>%
  arrange(COUNTRY, SEX, AGE)

cat("\nSorted by country, then sex, then age:\n")
print(dm_sorted_multi)

# ----------------------------
# Part 6: Combining Operations with Pipes
# ----------------------------

# Complex pipeline: Filter, mutate, arrange, select
processed_dm <- dm %>%
  filter(AGE >= 18) %>%                    # Adults only  
  mutate(BMI_CATEGORY = case_when(         # Add BMI category (simulated)
    AGE < 30 ~ "Young",
    AGE < 50 ~ "Middle",
    TRUE ~ "Mature"
  )) %>%
  arrange(USUBJID) %>%                     # Sort by subject ID
  select(USUBJID, AGE, SEX, ELDERLY, AGEGRP, BMI_CATEGORY)  # Keep relevant columns

cat("\nProcessed demographics (full pipeline):\n")
print(processed_dm)

# ----------------------------
# Part 7: SAS vs R Comparison Example
# ----------------------------

cat("\n=== SAS vs R Comparison ===\n")
cat("SAS DATA Step equivalent:\n")
cat("DATA dm;\n")
cat("  SET raw_dm;\n") 
cat("  IF AGE >= 65 THEN ELDERLY = 'Y';\n")
cat("  ELSE ELDERLY = 'N';\n")
cat("  \n")
cat("  IF AGE < 40 THEN AGEGRP = 'Young Adult';\n")
cat("  ELSE IF AGE < 65 THEN AGEGRP = 'Middle Age';\n") 
cat("  ELSE AGEGRP = 'Elderly';\n")
cat("RUN;\n")
cat("\nR dplyr equivalent:\n")
cat("dm <- raw_dm %>%\n")
cat("  mutate(\n")
cat("    ELDERLY = ifelse(AGE >= 65, 'Y', 'N'),\n")
cat("    AGEGRP = case_when(\n")
cat("      AGE < 40 ~ 'Young Adult',\n")
cat("      AGE < 65 ~ 'Middle Age',\n") 
cat("      TRUE ~ 'Elderly'\n")
cat("    )\n")
cat("  )\n")

# ----------------------------
# Part 8: GitHub Copilot Practice
# ----------------------------

# Part 8: GitHub Copilot in RStudio Practice
# ===========================

cat("\n=== GitHub Copilot in RStudio Practice ===\n")
cat("Try writing these comments and see what Copilot suggests in RStudio:\n\n")

# Create a treatment assignment flag for subjects over 50


# Calculate days since reference start date


# Create a flag for subjects from North America (USA or CAN)
dm <- dm %>%
  mutate(NORTH_AMERICA = ifelse(COUNTRY %in% c("USA", "CAN"), "Y", "N"))

cat("\nFinal dataset with North America flag:\n")
print(dm)

# ----------------------------
# Module 2 Demo Complete!
# ----------------------------

cat("\n🎉 Module 2 Demo Complete!\n")
cat("You've practiced:\n")
cat("- filter() for subsetting rows\n")
cat("- select() for choosing columns\n") 
cat("- mutate() for creating variables\n")
cat("- arrange() for sorting data\n")
cat("- Combining operations with pipes\n")
cat("- SAS vs R comparisons\n")
cat("- GitHub Copilot in RStudio assistance\n")
cat("\nReady for more advanced data wrangling in Module 3!\n")
