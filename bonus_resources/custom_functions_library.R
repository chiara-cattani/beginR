
# tlf_generator.R
# Production TLF (Tables, Listings, Figures) Generator for Clinical Reports
# Regulatory-compliant deliverables following ICH E3 guidelines
# Clinical Programming Training - Advanced TLF Module

library(dplyr)
library(tibble)
library(tidyr)
library(gt)
library(ggplot2)
library(scales)
library(stringr)
library(flextable)

cat("=== Clinical TLF Generator ===\n")
cat("Creating regulatory-compliant Tables, Listings, and Figures\n\n")

# =================
# Create Comprehensive Mock ADaM Data
# =================

set.seed(2024)

# ADSL - Subject-Level Analysis Dataset
adsl <- tibble(
  STUDYID = "ABC-123",
  USUBJID = paste0("ABC-123-", sprintf("%03d", 1:60)),
  SUBJID = sprintf("%03d", 1:60),
  SITEID = sample(c("001", "002", "003", "004"), 60, replace = TRUE),
  TRT01P = sample(c("Placebo", "Study Drug 5mg", "Study Drug 10mg"), 60, replace = TRUE),
  TRT01PN = case_when(
    TRT01P == "Placebo" ~ 0,
    TRT01P == "Study Drug 5mg" ~ 5,
    TRT01P == "Study Drug 10mg" ~ 10
  ),
  AGE = sample(18:75, 60, replace = TRUE),
  AGEGR1 = case_when(AGE < 65 ~ "<65", TRUE ~ ">=65"),
  SEX = sample(c("M", "F"), 60, replace = TRUE, prob = c(0.55, 0.45)),
  RACE = sample(c("WHITE", "BLACK OR AFRICAN AMERICAN", "ASIAN", "OTHER"), 
                60, replace = TRUE, prob = c(0.75, 0.15, 0.08, 0.02)),
  SAFFL = "Y",
  ITTFL = "Y",
  PPROTFL = sample(c("Y", "N"), 60, replace = TRUE, prob = c(0.9, 0.1)),
  DCSREAS = case_when(
    PPROTFL == "N" ~ sample(c("ADVERSE EVENT", "WITHDRAWAL BY SUBJECT", "PROTOCOL VIOLATION"), 
                           sum(PPROTFL == "N"), replace = TRUE),
    TRUE ~ NA_character_
  ),
  TRTSDT = as.Date("2024-01-15"),
  TRTEDT = TRTSDT + sample(28:84, 60, replace = TRUE)
)

# ADAE - Adverse Events Analysis Dataset  
adae <- tibble(
  USUBJID = sample(adsl$USUBJID, 120, replace = TRUE),
  AESEQ = ave(USUBJID, USUBJID, FUN = seq_along),
  AETERM = sample(c("HEADACHE", "NAUSEA", "FATIGUE", "DIZZINESS", "RASH",
                    "UPPER RESPIRATORY INFECTION", "BACK PAIN", "INSOMNIA",
                    "DIARRHEA", "MUSCLE PAIN"), 120, replace = TRUE),
  AEDECOD = AETERM,
  AEBODSYS = case_when(
    AETERM %in% c("HEADACHE", "DIZZINESS") ~ "NERVOUS SYSTEM DISORDERS",
    AETERM %in% c("NAUSEA", "DIARRHEA") ~ "GASTROINTESTINAL DISORDERS",
    AETERM == "FATIGUE" ~ "GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS",
    AETERM == "RASH" ~ "SKIN AND SUBCUTANEOUS TISSUE DISORDERS",
    AETERM == "UPPER RESPIRATORY INFECTION" ~ "RESPIRATORY, THORACIC AND MEDIASTINAL DISORDERS",
    AETERM %in% c("BACK PAIN", "MUSCLE PAIN") ~ "MUSCULOSKELETAL AND CONNECTIVE TISSUE DISORDERS",
    AETERM == "INSOMNIA" ~ "PSYCHIATRIC DISORDERS",
    TRUE ~ "GENERAL DISORDERS AND ADMINISTRATION SITE CONDITIONS"
  ),
  AESEV = sample(c("MILD", "MODERATE", "SEVERE"), 120, replace = TRUE, prob = c(0.6, 0.3, 0.1)),
  AESER = sample(c("N", "Y"), 120, replace = TRUE, prob = c(0.9, 0.1)),
  AEREL = sample(c("NOT RELATED", "UNLIKELY", "POSSIBLE", "PROBABLE"), 
                 120, replace = TRUE, prob = c(0.4, 0.3, 0.2, 0.1)),
  TRTEMFL = "Y",  # Treatment-emergent flag
  AESTDT = as.Date("2024-01-15") + sample(1:60, 120, replace = TRUE)
) %>%
  left_join(adsl %>% select(USUBJID, TRT01P, TRT01PN, SAFFL), by = "USUBJID")

# ADLB - Laboratory Data
adlb <- tibble(
  USUBJID = rep(adsl$USUBJID[1:40], each = 6),  # Subset for demo
  PARAMCD = rep(rep(c("HGB", "WBC", "ALT"), each = 2), times = 40),
  PARAM = case_when(
    PARAMCD == "HGB" ~ "Hemoglobin (g/dL)",
    PARAMCD == "WBC" ~ "White Blood Cell Count (10^9/L)", 
    PARAMCD == "ALT" ~ "Alanine Aminotransferase (U/L)"
  ),
  AVISIT = rep(c("Baseline", "Week 8"), times = 120),
  AVISITN = case_when(AVISIT == "Baseline" ~ 1, AVISIT == "Week 8" ~ 4),
  AVAL = case_when(
    PARAMCD == "HGB" ~ round(rnorm(240, 13.5, 1.5), 1),
    PARAMCD == "WBC" ~ round(rnorm(240, 7.2, 2.1), 2),
    PARAMCD == "ALT" ~ round(rnorm(240, 25, 8), 0)
  ),
  ANRIND = case_when(
    PARAMCD == "HGB" & AVAL < 12.0 ~ "LOW",
    PARAMCD == "HGB" & AVAL > 16.0 ~ "HIGH", 
    PARAMCD == "WBC" & AVAL < 4.0 ~ "LOW",
    PARAMCD == "WBC" & AVAL > 11.0 ~ "HIGH",
    PARAMCD == "ALT" & AVAL > 40 ~ "HIGH",
    TRUE ~ "NORMAL"
  )
) %>%
  left_join(adsl %>% select(USUBJID, TRT01P, TRT01PN, SAFFL), by = "USUBJID") %>%
  group_by(USUBJID, PARAMCD) %>%
  mutate(
    BASE = case_when(AVISIT == "Baseline" ~ AVAL, TRUE ~ NA_real_),
    BASE = first(BASE[!is.na(BASE)])
  ) %>%
  ungroup() %>%
  mutate(
    CHG = case_when(AVISIT != "Baseline" ~ AVAL - BASE, TRUE ~ NA_real_),
    PCHG = case_when(!is.na(CHG) & BASE != 0 ~ (CHG / BASE) * 100, TRUE ~ NA_real_)
  )

# =================
# TABLE 1: Demographics and Baseline Characteristics
# =================

cat("Generating Table 1: Demographics and Baseline Characteristics...\n")

create_demographics_table <- function(adsl_data) {
  
  # Calculate summary statistics by treatment
  demo_stats <- adsl_data %>%
    group_by(TRT01P) %>%
    summarise(
      N = n(),
      Age_Mean = mean(AGE, na.rm = TRUE),
      Age_SD = sd(AGE, na.rm = TRUE),
      Age_Min = min(AGE, na.rm = TRUE),
      Age_Max = max(AGE, na.rm = TRUE),
      Male_N = sum(SEX == "M", na.rm = TRUE),
      White_N = sum(RACE == "WHITE", na.rm = TRUE),
      Age65_N = sum(AGEGR1 == ">=65", na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      Age_MeanSD = paste0(
        format(round(Age_Mean, 1), nsmall = 1), 
        " (", format(round(Age_SD, 1), nsmall = 1), ")"
      ),
      Age_Range = paste0(Age_Min, "-", Age_Max),
      Male_Pct = paste0(Male_N, " (", format(round(Male_N/N * 100, 1), nsmall = 1), "%)"),
      White_Pct = paste0(White_N, " (", format(round(White_N/N * 100, 1), nsmall = 1), "%)"),
      Age65_Pct = paste0(Age65_N, " (", format(round(Age65_N/N * 100, 1), nsmall = 1), "%)")
    ) %>%
    select(TRT01P, N, Age_MeanSD, Age_Range, Male_Pct, White_Pct, Age65_Pct)
  
  # Add Total column
  total_stats <- adsl_data %>%
    summarise(
      TRT01P = "Total",
      N = n(),
      Age_MeanSD = paste0(
        format(round(mean(AGE, na.rm = TRUE), 1), nsmall = 1), 
        " (", format(round(sd(AGE, na.rm = TRUE), 1), nsmall = 1), ")"
      ),
      Age_Range = paste0(min(AGE, na.rm = TRUE), "-", max(AGE, na.rm = TRUE)),
      Male_Pct = paste0(
        sum(SEX == "M", na.rm = TRUE), " (", 
        format(round(sum(SEX == "M", na.rm = TRUE)/N * 100, 1), nsmall = 1), "%)"
      ),
      White_Pct = paste0(
        sum(RACE == "WHITE", na.rm = TRUE), " (", 
        format(round(sum(RACE == "WHITE", na.rm = TRUE)/N * 100, 1), nsmall = 1), "%)"
      ),
      Age65_Pct = paste0(
        sum(AGEGR1 == ">=65", na.rm = TRUE), " (", 
        format(round(sum(AGEGR1 == ">=65", na.rm = TRUE)/N * 100, 1), nsmall = 1), "%)"
      )
    )
  
  # Combine and create table
  final_stats <- bind_rows(demo_stats, total_stats)
  
  # Reshape for presentation
  demo_table <- final_stats %>%
    pivot_longer(cols = -TRT01P, names_to = "Characteristic", values_to = "Value") %>%
    pivot_wider(names_from = TRT01P, values_from = Value) %>%
    mutate(
      Characteristic = case_when(
        Characteristic == "N" ~ "Number of subjects",
        Characteristic == "Age_MeanSD" ~ "Age, years, mean (SD)",
        Characteristic == "Age_Range" ~ "Age range, years",
        Characteristic == "Male_Pct" ~ "Male, n (%)",
        Characteristic == "White_Pct" ~ "White race, n (%)",
        Characteristic == "Age65_Pct" ~ "Age ≥65 years, n (%)"
      )
    )
  
  # Create gt table
  gt_table <- demo_table %>%
    gt() %>%
    tab_header(
      title = "Table 1. Demographics and Baseline Characteristics",
      subtitle = "Safety Population"
    ) %>%
    cols_label(Characteristic = "") %>%
    tab_footnote(
      footnote = "SD = standard deviation",
      locations = cells_body(columns = Characteristic, rows = 2)
    ) %>%
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_column_labels()
    ) %>%
    tab_style(
      style = list(
        cell_text(weight = "bold"),
        cell_fill(color = "#f0f0f0")
      ),
      locations = cells_body(columns = everything(), rows = Characteristic == "Number of subjects")
    ) %>%
    cols_align(align = "center", columns = -Characteristic) %>%
    tab_options(
      table.font.size = 11,
      heading.title.font.size = 13,
      table.border.top.style = "solid",
      table.border.bottom.style = "solid",
      table.width = pct(100)
    )
  
  return(gt_table)
}

# Generate Table 1
table1 <- create_demographics_table(adsl)
print(table1)

# =================
# TABLE 2: Adverse Events Summary
# =================

cat("\nGenerating Table 2: Adverse Events Summary...\n")

create_ae_summary_table <- function(adae_data, adsl_data) {
  
  # Get denominators
  denominators <- adsl_data %>%
    filter(SAFFL == "Y") %>%
    count(TRT01P, name = "total_n")
  
  # AE summary by SOC and preferred term
  ae_summary <- adae_data %>%
    filter(SAFFL == "Y", TRTEMFL == "Y") %>%
    group_by(TRT01P, AEBODSYS, AEDECOD) %>%
    summarise(
      n_subjects = n_distinct(USUBJID),
      n_events = n(),
      .groups = "drop"
    ) %>%
    left_join(denominators, by = "TRT01P") %>%
    mutate(
      subjects_pct = paste0(n_subjects, " (", 
                           format(round(n_subjects/total_n * 100, 1), nsmall = 1), "%)")
    ) %>%
    select(TRT01P, AEBODSYS, AEDECOD, subjects_pct) %>%
    pivot_wider(names_from = TRT01P, values_from = subjects_pct, values_fill = "0 (0.0%)")
  
  # Create summary by SOC only (roll-up)
  soc_summary <- adae_data %>%
    filter(SAFFL == "Y", TRTEMFL == "Y") %>%
    group_by(TRT01P, AEBODSYS) %>%
    summarise(n_subjects = n_distinct(USUBJID), .groups = "drop") %>%
    left_join(denominators, by = "TRT01P") %>%
    mutate(
      subjects_pct = paste0(n_subjects, " (", 
                           format(round(n_subjects/total_n * 100, 1), nsmall = 1), "%)"),
      AEDECOD = paste0("  Any ", str_to_title(str_to_lower(AEBODSYS)), " Event")
    ) %>%
    select(TRT01P, AEBODSYS, AEDECOD, subjects_pct) %>%
    pivot_wider(names_from = TRT01P, values_from = subjects_pct, values_fill = "0 (0.0%)")
  
  # Combine SOC summaries with individual terms
  combined_ae <- bind_rows(soc_summary, ae_summary) %>%
    arrange(AEBODSYS, AEDECOD) %>%
    mutate(
      Term = case_when(
        str_detect(AEDECOD, "Any.*Event") ~ AEDECOD,
        TRUE ~ paste0("    ", str_to_title(str_to_lower(AEDECOD)))
      )
    ) %>%
    select(Term, everything(), -AEBODSYS, -AEDECOD)
  
  # Create gt table
  gt_table <- combined_ae %>%
    gt() %>%
    tab_header(
      title = "Table 2. Treatment-Emergent Adverse Events by System Organ Class and Preferred Term",
      subtitle = "Safety Population - Subjects with Events, n (%)"
    ) %>%
    cols_label(Term = "System Organ Class / Preferred Term") %>%
    tab_footnote(
      footnote = "Treatment-emergent: onset on or after first dose of study drug",
      locations = cells_title()
    ) %>%
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_column_labels()
    ) %>%
    tab_style(
      style = cell_text(weight = "bold"),
      locations = cells_body(columns = Term, rows = str_detect(Term, "Any.*Event"))
    ) %>%
    cols_align(align = "center", columns = -Term) %>%
    tab_options(
      table.font.size = 10,
      heading.title.font.size = 12,
      table.border.top.style = "solid",
      table.border.bottom.style = "solid"
    )
  
  return(gt_table)
}

# Generate Table 2
table2 <- create_ae_summary_table(adae, adsl)
print(table2)

# =================
# LISTING 1: Subject Disposition
# =================

cat("\nGenerating Listing 1: Subject Disposition...\n")

create_disposition_listing <- function(adsl_data) {
  
  disposition_data <- adsl_data %>%
    select(USUBJID, SITEID, TRT01P, AGE, SEX, RACE, 
           TRTSDT, TRTEDT, PPROTFL, DCSREAS) %>%
    mutate(
      Status = case_when(
        PPROTFL == "Y" ~ "Completed",
        !is.na(DCSREAS) ~ paste0("Discontinued: ", DCSREAS),
        TRUE ~ "Ongoing"
      ),
      `Treatment Duration` = as.numeric(TRTEDT - TRTSDT) + 1
    ) %>%
    arrange(USUBJID) %>%
    select(
      `Subject ID` = USUBJID,
      `Site ID` = SITEID, 
      `Treatment` = TRT01P,
      `Age` = AGE,
      `Sex` = SEX,
      `Race` = RACE,
      `Start Date` = TRTSDT,
      `End Date` = TRTEDT,
      `Duration (Days)` = `Treatment Duration`,
      `Status` = Status
    )
  
  # Create flextable for listing
  ft_table <- disposition_data %>%
    flextable() %>%
    theme_vanilla() %>%
    align(align = "center", part = "header") %>%
    align(j = c("Subject ID", "Treatment", "Sex", "Race", "Status"), align = "left") %>%
    align(j = c("Site ID", "Age", "Duration (Days)"), align = "center") %>%
    align(j = c("Start Date", "End Date"), align = "center") %>%
    fontsize(size = 9, part = "all") %>%
    fontsize(size = 10, part = "header") %>%
    bold(part = "header") %>%
    autofit() %>%
    add_header_lines("Listing 1. Subject Disposition - All Randomized Subjects") %>%
    align(align = "center", part = "header") %>%
    fontsize(size = 11, part = "header") %>%
    bold(part = "header")
  
  return(ft_table)
}

# Generate Listing 1  
listing1 <- create_disposition_listing(adsl)
cat("Subject disposition listing created\n")

# =================
# FIGURE 1: Mean Laboratory Values Over Time
# =================

cat("\nGenerating Figure 1: Laboratory Values Over Time...\n")

create_lab_figure <- function(adlb_data) {
  
  # Prepare data for plotting
  plot_data <- adlb_data %>%
    filter(PARAMCD %in% c("HGB", "WBC", "ALT")) %>%
    group_by(TRT01P, PARAMCD, AVISIT, AVISITN) %>%
    summarise(
      mean_val = mean(AVAL, na.rm = TRUE),
      se_val = sd(AVAL, na.rm = TRUE) / sqrt(n()),
      n = n(),
      .groups = "drop"
    ) %>%
    mutate(
      lower_ci = mean_val - 1.96 * se_val,
      upper_ci = mean_val + 1.96 * se_val
    )
  
  # Create the plot
  lab_plot <- plot_data %>%
    ggplot(aes(x = AVISITN, y = mean_val, color = TRT01P, group = TRT01P)) +
    geom_line(size = 1.2) +
    geom_point(size = 3, shape = 16) +
    geom_errorbar(aes(ymin = lower_ci, ymax = upper_ci), width = 0.1, size = 0.8) +
    facet_wrap(~PARAM, scales = "free_y", ncol = 3) +
    scale_x_continuous(
      breaks = c(1, 4),
      labels = c("Baseline", "Week 8")
    ) +
    scale_color_manual(
      name = "Treatment Group",
      values = c("Placebo" = "#E69F00", 
                "Study Drug 5mg" = "#56B4E9", 
                "Study Drug 10mg" = "#009E73")
    ) +
    labs(
      title = "Figure 1. Mean Laboratory Values by Treatment Group and Visit",
      subtitle = "Error bars represent 95% confidence intervals",
      x = "Study Visit",
      y = "Laboratory Value",
      caption = "Safety Population"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 12, hjust = 0.5),
      strip.text = element_text(size = 12, face = "bold"),
      legend.position = "bottom",
      legend.title = element_text(size = 11, face = "bold"),
      legend.text = element_text(size = 10),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10),
      panel.grid.minor = element_blank(),
      plot.caption = element_text(size = 9, hjust = 1)
    )
  
  return(lab_plot)
}

# Generate Figure 1
figure1 <- create_lab_figure(adlb)
print(figure1)

# =================
# Export Functions
# =================

cat("\n=== TLF Export Functions ===\n")

# Export all TLFs
export_tlfs <- function(table1, table2, listing1, figure1, output_dir = "tlf_outputs") {
  
  # Create output directory
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Export tables as HTML
  gtsave(table1, file.path(output_dir, "Table1_Demographics.html"))
  gtsave(table2, file.path(output_dir, "Table2_AdverseEvents.html"))
  
  # Export listing as Word document  
  save_as_docx(listing1, path = file.path(output_dir, "Listing1_Disposition.docx"))
  
  # Export figure as PNG and PDF
  ggsave(file.path(output_dir, "Figure1_LabValues.png"), figure1, 
         width = 12, height = 8, dpi = 300)
  ggsave(file.path(output_dir, "Figure1_LabValues.pdf"), figure1, 
         width = 12, height = 8)
  
  cat("All TLFs exported to:", output_dir, "\n")
  cat("- Table1_Demographics.html\n")
  cat("- Table2_AdverseEvents.html\n") 
  cat("- Listing1_Disposition.docx\n")
  cat("- Figure1_LabValues.png\n")
  cat("- Figure1_LabValues.pdf\n")
}

# Uncomment to export files
# export_tlfs(table1, table2, listing1, figure1)

cat("\n=== Clinical TLF Generation Complete ===\n")
cat("Production-quality deliverables ready for regulatory submission\n")

# Figure: Line plot of AVAL by visit
tlf_plot <- ggplot(adam, aes(x = VISIT, y = AVAL, color = TRTGRP, group = USUBJID)) +
  geom_line(alpha = 0.5) +
  geom_smooth(aes(group = TRTGRP), method = "loess", se = FALSE, size = 1.2) +
  theme_minimal() +
  labs(title = "Figure 1: AVAL by Visit and Treatment", y = "AVAL", x = "Visit")

print(tlf_plot)
