# Module 3 Exercise — ADaM Programming in R
# Goal: Derive ADSL and ADAE from SDTM using admiral + tidyverse

# ---------------------------------------------
# Part 1 — ADSL Derivation (from DM)
# ---------------------------------------------

# 1. Load the required libraries:
# dplyr, admiral, pharmaversesdtm, pharmaverseadam, labelled

# 2. Load the SDTM DM dataset using `data(dm)`

# 3. Derive ADSL:
# - Keep only USUBJID, AGE, SEX, RACE, ARM, COUNTRY, RFSTDTC
# - Add a new variable TRTFL:
#     - Set to "Y" if ARM is not "SCREEN FAILURE"
#     - Otherwise, set to "N"

# 4. Add variable labels to ADSL

# ---------------------------------------------
# Part 2 — ADAE Derivation (from AE)
# ---------------------------------------------

# 5. Load the SDTM AE dataset using `data(ae)`

# 6. Filter for serious adverse events (AESER = "Y")

# 7. Derive ADT and ADY from AESTDTC, using RFSTDTC from ADSL

# 8. Merge ADSL to bring in RFSTDTC by USUBJID

# 9. Add a new flag variable SAEFL = "Y" for serious AEs

# 10. Add labels for key variables: USUBJID, AEDECOD, ADT, ADY, SAEFL

# ---------------------------------------------
# Part 3 — Export
# ---------------------------------------------

# 11. Save ADSL and ADAE as XPT files inside the "output" folder:
#     - adsl_exercise.xpt
#     - adae_exercise.xpt

# ---------------------------------------------
# Bonus (Optional)
# ---------------------------------------------

# - Try to derive ADY using other date derivation functions
# - Use Copilot to write the mutate + merge steps
# - Add additional flags for specific AE categories
