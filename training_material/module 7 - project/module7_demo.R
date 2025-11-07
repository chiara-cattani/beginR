# Module 7 Demo — Final Project: From SDTM to TLFs

# 🎯 Objective: Use mock data to go from raw files to final TLFs

# 📦 Libraries
library(dplyr)
library(lubridate)
library(readr)
library(ggplot2)
library(gtsummary)
library(flextable)
library(tidyr)

# ------------------------
# Step 1: Load Raw Data
# ------------------------

dm <- read_csv("data/raw_dm.csv")
ae <- read_csv("data/raw_ae.csv")
ex <- read_csv("data/raw_ex.csv")

# ------------------------
# Step 2: SDTM Derivations
# ------------------------

## DM ----
dm_sdtm <- dm %>%
  mutate(
    BRTHDTC = ymd(DOB),
    AGE = floor((ymd(RFSTDTC) - BRTHDTC) / 365.25),
    ARMCD = substr(ARM, 1, 3),
    DOMAIN = "DM"
  )

## AE ----
ae_sdtm <- ae %>%
  mutate(
    AESTDTC = ymd(AESTDTC),
    AEENDTC = ymd(AEENDTC),
    AESTDY = as.integer(AESTDTC - ymd(RFSTDTC)),
    AEENDY = as.integer(AEENDTC - ymd(RFSTDTC)),
    DOMAIN = "AE",
    AESEQ = row_number()
  )

## EX ----
ex_sdtm <- ex %>%
  mutate(
    EXSTDTC = ymd(EXSTDTC),
    EXENDTC = ymd(EXENDTC),
    DOMAIN = "EX",
    EXDOSE = as.numeric(EXDOSE)
  )

# ------------------------
# Step 3: ADaM Derivations
# ------------------------

## ADSL ----
adsl <- dm_sdtm %>%
  select(USUBJID, AGE, SEX, ARM, ARMCD) %>%
  mutate(TRT01P = ARM)

## ADAE ----
adae <- ae_sdtm %>%
  left_join(adsl, by = "USUBJID") %>%
  mutate(
    ASEVFL = ifelse(AESEV == "SEVERE", "Y", "N"),
    AVALC = AESEV
  )

# ------------------------
# Step 4: TLFs
# ------------------------

## Listing: AEs
ae_listing <- adae %>%
  select(USUBJID, AETERM, AESEV, AESTDTC, AEENDTC) %>%
  flextable() %>%
  autofit()

## Table: Demographics Summary
demog_summary <- adsl %>%
  select(AGE, SEX, ARM) %>%
  tbl_summary(by = ARM, missing = "no")

## Figure: AE Count by Severity
ae_fig <- adae %>%
  count(ARM, AESEV) %>%
  ggplot(aes(x = AESEV, y = n, fill = ARM)) +
  geom_col(position = "dodge") +
  labs(title = "Adverse Events by Severity", y = "Count") +
  theme_minimal()

# ------------------------
# Optional: Save outputs
# ------------------------
# ggsave("ae_figure.png", ae_fig, width = 6, height = 4)
# flextable::save_as_docx(ae_listing, path = "ae_listing.docx")
