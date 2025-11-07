
# adam_build.R
# Create ADaM datasets from derived SDTM data

library(dplyr)
library(lubridate)

# Example SDTM datasets
dm <- data.frame(
  USUBJID = c("101-001", "101-002"),
  BRTHDT = as.Date(c("1980-05-20", "1975-09-12")),
  SEX = c("M", "F"),
  TRTSDT = as.Date(c("2023-01-01", "2023-02-01"))
)

ex <- data.frame(
  USUBJID = c("101-001", "101-001", "101-002"),
  EXSTDTC = as.Date(c("2023-01-01", "2023-01-15", "2023-02-01")),
  EXENDTC = as.Date(c("2023-01-10", "2023-01-20", "2023-02-10")),
  EXDOSE = c(100, 100, 150)
)

# Derive ADSL: subject-level dataset
adsl <- dm %>%
  mutate(
    AGE = as.integer((TRTSDT - BRTHDT) / 365.25),
    TRTSDT = as.Date(TRTSDT),
    TRTSDTC = format(TRTSDT, "%Y-%m-%d")
  )

# Derive ADex: exposure analysis dataset
adex <- ex %>%
  group_by(USUBJID) %>%
  summarise(
    TRTDOSE = sum(EXDOSE, na.rm = TRUE),
    EXSTDT = min(EXSTDTC, na.rm = TRUE),
    EXENDT = max(EXENDTC, na.rm = TRUE)
  ) %>%
  ungroup()

# Merge ADSL and ADex to build ADAE-like structure
ad <- adsl %>%
  left_join(adex, by = "USUBJID") %>%
  mutate(
    TRTDU = as.integer(EXENDT - EXSTDT + 1),
    TRTDOSE = ifelse(is.na(TRTDOSE), 0, TRTDOSE)
  )

# Preview
print(ad)
