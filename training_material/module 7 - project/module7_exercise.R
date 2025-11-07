# Module 7 Final Project — Exercise Handout

# 🎯 Objective:
# Use mock clinical data to:
# - Build SDTM domains: DM, AE, EX
# - Derive ADaM datasets: ADSL, ADAE
# - Create one listing, one table, and one figure
# - Use AI (e.g. Copilot) to assist with labels, formatting, and debugging

# 📦 Required Libraries:
library(dplyr)
library(readr)
library(tidyr)
library(lubridate)
library(ggplot2)
library(gtsummary)
library(flextable)
library(tibble)

# ------------------------------------------------------------
# STEP 1: GENERATE OR LOAD MOCK RAW DATA
# Create 3 datasets: dm, ae, ex
# ------------------------------------------------------------
dm <- tibble(
  USUBJID = c("01-001", "01-002"),
  AGE = c(34, 28),
  SEX = c("M", "F"),
  ARM = c("Placebo", "Treatment"),
  RFSTDTC = as.Date(c("2023-01-01", "2023-01-03"))
)

ae <- tibble(
  USUBJID = c("01-001", "01-002"),
  AETERM = c("Headache", "Nausea"),
  AESTDTC = as.Date(c("2023-01-10", "2023-01-12")),
  AEENDTC = as.Date(c("2023-01-11", "2023-01-13")),
  AESEV = c("MILD", "MODERATE")
)

ex <- tibble(
  USUBJID = c("01-001", "01-002"),
  EXSTDTC = as.Date(c("2023-01-02", "2023-01-04")),
  EXENDTC = as.Date(c("2023-01-06", "2023-01-08")),
  EXTRT = c("Drug A", "Drug B")
)

# ------------------------------------------------------------
# STEP 2: SDTM DOMAINS
# Derive SDTM variables (e.g., --DTC, --DY, --SEQ, DOMAIN)
# ------------------------------------------------------------

# ------------------------------------------------------------
# STEP 3: ADaM DATASETS
# Derive ADSL and ADAE
# ------------------------------------------------------------

# ------------------------------------------------------------
# STEP 4: TLFs
# 1. Listing: flextable
# 2. Table: gtsummary
# 3. Figure: ggplot2
# ------------------------------------------------------------

# 💡 BONUS:
# - Create export function
# - Combine plots with patchwork
# - Prompt Copilot for:
#     "# Derive AESEQ", "# Export to XPT", "# Bar plot with labels"
