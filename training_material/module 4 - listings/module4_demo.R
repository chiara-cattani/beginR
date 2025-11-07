# Module 4 Demo — TLF Listings in R (Alt Demo)

# Goal: Demonstrate additional features of listings with styling,
# row highlighting, column formatting, and grouped outputs

# ----------------------------
# 📦 Load Required Libraries
# ----------------------------

library(dplyr)
library(flextable)
library(gt)
library(reactable)

# ----------------------------
# 📄 Create Mock AE Dataset with Grouping
# ----------------------------

ae_listing <- data.frame(
  USUBJID = c("01-001", "01-001", "01-002", "01-003"),
  AEDECOD = c("HEADACHE", "NAUSEA", "DIZZINESS", "HEADACHE"),
  AESTDTC = c("2023-01-01", "2023-01-03", "2023-01-02", "2023-01-05"),
  AESEV = c("MILD", "MODERATE", "SEVERE", "MILD"),
  AESER = c("N", "N", "Y", "N"),
  stringsAsFactors = FALSE
)

# ----------------------------
# 🧾 Create flextable with Grouped Rows and Highlights
# ----------------------------

ft_ae <- flextable(ae_listing) %>%
  set_caption("AE Listing with Grouped Subjects") %>%
  autofit() %>%
  theme_booktabs() %>%
  highlight(i = ~ AESEV == "SEVERE", color = "red", part = "body") %>%
  italic(i = ~ AESER == "Y", part = "body") %>%
  bold(i = ~ AESER == "Y", part = "body") %>%
  add_header_lines(values = "Clinical Trial Adverse Events")

ft_ae

# ----------------------------
# 🧾 Create gt Table with Multiple Columns Colored
# ----------------------------

gt_ae <- ae_listing %>%
  gt(rowname_col = "USUBJID", groupname_col = "AEDECOD") %>%
  tab_header(title = "AE Listing (Grouped by Term)") %>%
  data_color(
    columns = AESEV,
    colors = scales::col_factor(
      palette = c("MILD" = "lightgreen", "MODERATE" = "khaki", "SEVERE" = "lightcoral"),
      domain = NULL
    )
  ) %>%
  fmt_date(columns = AESTDTC, date_style = "mdy")

gt_ae

# ----------------------------
# 🌐 Interactive Listing with Custom Columns
# ----------------------------

reactable(
  ae_listing,
  searchable = TRUE,
  groupBy = "AEDECOD",
  columns = list(
    AESEV = colDef(style = function(value) {
      if (value == "SEVERE") "color: red; font-weight: bold;"
      else if (value == "MODERATE") "color: orange;"
      else NULL
    }),
    AESER = colDef(name = "Serious?", align = "center")
  )
)

# ----------------------------
# 🤖 Copilot Prompt Ideas for This Demo
# ----------------------------

# # Highlight SEVERE events in red
# # Bold serious AEs (AESER == Y)
# # Group subjects by AEDECOD
# # Create searchable interactive table
