# Module 2 Demo — Building SDTM Datasets in R
# Domain used: EX (Exposure)
# Goal: Demonstrate loading, transforming, and exporting an SDTM domain using tidyverse + Copilot

# Load required libraries
library(dplyr)
library(haven)
library(lubridate)
library(labelled)

# ----------------------------
# Part 1: Load Raw Data
# ----------------------------

# Simulated raw exposure data
ex <- data.frame(
  USUBJID   = c("01-001", "01-001", "01-002", "01-002", "01-003"),
  EXSTDAT   = c("2023-01-01", "2023-01-02", "2023-01-01", "2023-01-04", "2023-01-02"),
  EXTM      = c("08:00", "20:00", "08:00", "20:00", "08:00"),
  FORMID    = c("F001", "F001", "F002", "F002", "F003"),
  RFSTDTC   = c("2023-01-01", "2023-01-01", "2023-01-01", "2023-01-01", "2023-01-01"),
  stringsAsFactors = FALSE
)

head(ex)

# ----------------------------
# Part 2: Derive SDTM Variables
# ----------------------------

# Convert EXSTDAT to EXDTC (ISO 8601)
ex <- ex %>%
  mutate(EXDTC = format(as.Date(EXSTDAT), "%Y-%m-%d"))

head(ex)

# Derive EXDY = EXDTC - RFSTDTC + 1
ex <- ex %>%
  mutate(EXDY = as.integer(as.Date(EXDTC) - as.Date(RFSTDTC)) + 1)

head(ex)

# Derive EXTPT based on EXTM
ex <- ex %>%
  mutate(EXTPT = case_when(
    EXTM == "08:00" ~ "MORNING",
    EXTM == "20:00" ~ "EVENING",
    TRUE ~ NA_character_
  ))

head(ex)

# Derive EXSEQ
ex <- ex %>%
  arrange(USUBJID, EXDTC) %>%
  group_by(USUBJID) %>%
  mutate(EXSEQ = row_number()) %>%
  ungroup()

head(ex)

# Derive EXSPID from FORMID
ex <- ex %>%
  mutate(EXSPID = paste0("CRF_", FORMID))

head(ex)

# ----------------------------
# Part 3: Apply Variable Labels
# ----------------------------

var_label(ex$USUBJID) <- "Unique Subject ID"
var_label(ex$EXSTDAT) <- "Start Date (Raw)"
var_label(ex$EXTM)    <- "Administration Time"
var_label(ex$EXDTC)   <- "Exposure Start Date (ISO)"
var_label(ex$EXDY)    <- "Study Day of Exposure"
var_label(ex$EXTPT)   <- "Timepoint"
var_label(ex$EXSEQ)   <- "Sequence Number"
var_label(ex$EXSPID)  <- "Source Procedure ID"
var_label(ex$FORMID)  <- "CRF Form ID"
var_label(ex$RFSTDTC) <- "Reference Start Date"

View(ex)

# ----------------------------
# Part 4: Export Dataset
# ----------------------------

if (!dir.exists("output")) dir.create("output")

write_xpt(ex, "output/ex_demo.xpt")

# ----------------------------
# Part 5: Bonus Copilot Prompts
# ----------------------------

# Try:
# # Create EXDTC from EXSTDAT in ISO format
# # Create EXTPT from EXTM
# # Assign EXSEQ by subject and date
# # Create EXSPID using FORMID
