# Module 3 Demo — ADaM Programming in R
# Goal: Build ADSL and ADVS using admiral + tidyverse

# Load requiredlibraries
library(dplyr)
library(admiral)
library(pharmaversesdtm)
library(pharmaverseadam)
library(labelled)

# ----------------------------
# Part 1: Create ADSL
# ----------------------------

# Load SDTM DM domain
data(dm)

# Derive ADSL
adsl <- dm %>%
  select(USUBJID, AGE, SEX, RACE, ARM, COUNTRY, RFSTDTC) %>%
  mutate(TRTFL = ifelse(ARM != "SCREEN FAILURE", "Y", "N"))

# Label ADSL variables
var_label(adsl$USUBJID) <- "Unique Subject ID"
var_label(adsl$AGE) <- "Age"
var_label(adsl$SEX) <- "Sex"
var_label(adsl$RACE) <- "Race"
var_label(adsl$ARM) <- "Planned Arm"
var_label(adsl$COUNTRY) <- "Country"
var_label(adsl$RFSTDTC) <- "Reference Start Date"
var_label(adsl$TRTFL) <- "Treatment Flag"

# ----------------------------
# Part 2: Create ADVS
# ----------------------------

# Load SDTM VS domain
data(vs) 

# Rename variables
vs <- vs %>%
  rename(PARAMCD = VSTESTCD)

# Filter only diastolic blood pressure
advs <- vs %>%
  filter(PARAMCD == "DIABP") %>%
  mutate(ASEVFL = ifelse(VSSTRESN > 90, "Y", "N"))

# Derive ADT from VSDTC
advs <- derive_vars_dt(
  dataset = advs,
  dtc = VSDTC,
  new_vars_prefix = "A"
)

# Derive AVAL and AVALC
advs <- advs %>%
  rename(AVAL = VSSTRESN) %>%
  mutate(AVALC = as.character(AVAL))

# Merge ADSL reference data
advs <- derive_vars_merged(
  dataset = advs,
  dataset_add = adsl,
  by_vars = exprs(USUBJID),
  new_vars = exprs(RFSTDTC)
)

# Derive Study Day
advs <- advs %>%
  mutate(ADY = as.integer(as.Date(ADT) - as.Date(RFSTDTC)) + 1)

# Label key variables
var_label(advs$PARAMCD) <- "Parameter Code"
var_label(advs$AVAL) <- "Analysis Value"
var_label(advs$AVALC) <- "Character Value"
var_label(advs$ASEVFL) <- "Severe Flag (DBP > 90)"
var_label(advs$ADT) <- "Analysis Date"
var_label(advs$ADY) <- "Study Day"
var_label(advs$RFSTDTC) <- "Reference Start Date"

# ----------------------------
# Part 3: Export Example Datasets
# ----------------------------

if (!dir.exists("output")) dir.create("output")

write_xpt(adsl, "output/adsl_demo.xpt")
write_xpt(advs, "output/advs_demo.xpt")

# ----------------------------
# Bonus Copilot Prompts
# ----------------------------

# Try:
# # Create ADSL from DM
# # Derive ASEVFL based on DBP threshold
# # Derive AVALC from AVAL
# # Merge ADSL to get RFSTDTC
# # Compute study day (ADY) from ADT and RFSTDTC
