
# sdtm_derive.R
# Derive SDTM variables from raw data using tidyverse

library(dplyr)
library(stringr)
library(lubridate)

# Example raw dataset: EX (Exposure)
raw_ex <- data.frame(
  USUBJID = c("101-001", "101-001", "101-002"),
  EXSTDTC = c("2023-01-01", "2023-01-15", "2023-02-01"),
  EXENDTC = c("2023-01-10", "2023-01-20", "2023-02-10"),
  EXDOSE = c(100, 100, 150),
  EXTRT = c("Drug A", "Drug A", "Drug B"),
  VISIT = c("Visit 1", "Visit 2", "Visit 1")
)

# Derive SDTM-compliant variables
sdtm_ex <- raw_ex %>%
  mutate(
    STUDYID = "ABC123",
    DOMAIN = "EX",
    EXSEQ = row_number(),
    EXDOSE = as.numeric(EXDOSE),
    EXTRT = as.character(EXTRT),
    EXSTDTC = as.Date(EXSTDTC),
    EXENDTC = as.Date(EXENDTC),
    VISITNUM = case_when(
      VISIT == "Visit 1" ~ 1,
      VISIT == "Visit 2" ~ 2,
      TRUE ~ NA_real_
    )
  ) %>%
  select(STUDYID, DOMAIN, USUBJID, EXSEQ, EXTRT, EXDOSE, EXSTDTC, EXENDTC, VISIT, VISITNUM)

# Preview
print(sdtm_ex)
