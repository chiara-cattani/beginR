# Module 1 Demo — Introduction to R for SAS Programmers
# Domain used: AE (Adverse Events)

# Load libraries
library(dplyr)
library(haven)
library(labelled)
library(ggplot2)

# Set working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# ----------------------------
# Part 1: Create Example Dataset
# ----------------------------

ae <- data.frame(
  USUBJID = c("01-001", "01-002", "01-003", "01-004", "01-005"),
  AEDECOD = c("HEADACHE", "NAUSEA", "FATIGUE", "HEADACHE", "DIZZINESS"),
  AESTDTC = c("2023-01-01", "2023-01-03", "2023-01-05", "2023-01-02", "2023-01-06"),
  AESEV = c("MILD", "MODERATE", "MILD", "SEVERE", "MILD"),
  stringsAsFactors = FALSE
)

View(ae)

# ----------------------------
# Part 2: Mutate — Derived Variables
# ----------------------------

# Create AE severity flag
ae <- ae %>%
  mutate(SEVFLAG = ifelse(AESEV == "SEVERE", "Y", "N"))

head(ae)

# Derive AE Start Date as date format
ae <- ae %>%
  mutate(AESTDT = as.Date(AESTDTC))

head(ae)

# ----------------------------
# Part 3: Label Variables
# ----------------------------

var_label(ae$USUBJID) <- "Unique Subject ID"
var_label(ae$AEDECOD) <- "AE Dictionary Term"
var_label(ae$AESTDTC) <- "Start Date (ISO8601)"
var_label(ae$AESTDT) <- "Start Date"
var_label(ae$AESEV) <- "Severity"
var_label(ae$SEVFLAG) <- "Severe AE?"

View(ae)

# ----------------------------
# Part 4: Summary Statistics
# ----------------------------

# Count of AEs by severity
ae %>%
  group_by(AESEV) %>%
  summarise(n = n())

# Number of severe AEs
ae %>%
  filter(SEVFLAG == "Y") %>%
  summarise(n_severe = n())

# ----------------------------
# Part 5: Export to XPT
# ----------------------------

# Create output folder if not present
if (!dir.exists("output")) dir.create("output")

write_xpt(ae, "output/ae_demo.xpt")

# ----------------------------
# Part 6: Plot
# ----------------------------

# AE count per term
ggplot(ae, aes(x = AEDECOD)) +
  geom_bar(fill = "steelblue") +
  labs(title = "Adverse Events by Type", x = "AE Term", y = "Count")

# ----------------------------
# Part 7: Bonus — Copilot Prompt Examples
# ----------------------------

# Try writing this prompt and letting Copilot suggest:
# Create a new variable AEFLAG where AEDECOD is HEADACHE -> "Y", else "N"

# Example output (if accepted):
# ae <- ae %>% mutate(AEFLAG = ifelse(AEDECOD == "HEADACHE", "Y", "N"))
