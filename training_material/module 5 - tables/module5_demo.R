# Module 5 Demo (Complex Alt) — TLF Tables: Summary Statistics

# Goal: Demonstrate a more complex scenario for summary table generation using grouped data

# ----------------------------
# 📦 Load Libraries
# ----------------------------

library(dplyr)
library(gtsummary)
library(gt)

# ----------------------------
# 🧪 Mock AE Dataset with Timing and Severity
# ----------------------------

set.seed(123)

aes <- tibble::tibble(
  USUBJID = rep(paste0("01-", sprintf("%03d", 1:10)), each = 3),
  ARM = rep(rep(c("Placebo", "Drug"), each = 5), each = 3),
  AEDECOD = sample(c("NAUSEA", "HEADACHE", "FATIGUE"), 30, replace = TRUE),
  AESEV = sample(c("MILD", "MODERATE", "SEVERE"), 30, replace = TRUE, prob = c(0.4, 0.4, 0.2)),
  AESER = sample(c("Y", "N"), 30, replace = TRUE, prob = c(0.3, 0.7)),
  AESTDY = sample(1:28, 30, replace = TRUE)
)

# ----------------------------
# 🧮 Summary: Count and Proportion of Serious AEs by Arm

aes %>%
  mutate(AESER = factor(AESER, levels = c("Y", "N"))) %>%
  tbl_summary(
    by = ARM,
    include = AESER,
    statistic = list(all_categorical() ~ "{n} / {N} ({p}%)")
  ) %>%
  add_overall() %>%
  modify_header(label ~ "Serious Adverse Event") %>%
  bold_labels()

# ----------------------------
# 📊 Frequency Table of AEDECOD by ARM

aes %>%
  select(ARM, AEDECOD) %>%
  tbl_summary(by = ARM) %>%
  add_overall() %>%
  modify_header(label ~ "Adverse Event Term") %>%
  bold_labels()

# ----------------------------
# 📉 Summary Table of AE Timing (Day of Onset)

aes %>%
  select(ARM, AESTDY) %>%
  tbl_summary(
    by = ARM,
    statistic = list(all_continuous() ~ "{median} (IQR: {p25}–{p75})")
  ) %>%
  add_n() %>%
  add_overall() %>%
  bold_labels()

# ----------------------------
# 💾 Export to HTML (Optional)

# as_gt(last_tbl()) %>%
#   gtsave("output/ae_timing_summary.html")

# ----------------------------
# 🤖 Copilot Prompt Ideas

# # Create frequency table for AE terms
# # Count proportion of AESER per arm
# # Summarize AE onset day using median and IQR
# # Export grouped summary to HTML
