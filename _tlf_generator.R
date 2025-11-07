
# tlf_generator.R
# Generate TLFs (Tables, Listings, Figures) for clinical reporting

library(dplyr)
library(gt)
library(ggplot2)

# Example ADaM dataset
adam <- data.frame(
  USUBJID = rep(c("101-001", "101-002", "101-003"), each = 3),
  VISIT = rep(c("Screening", "Week 1", "Week 2"), 3),
  AVAL = c(150, 140, 138, 180, 175, 170, 165, 160, 158),
  TRTGRP = rep(c("Placebo", "Treatment", "Treatment"), each = 3)
)

# Table: Mean and SD of AVAL by TRTGRP and VISIT
tlf_table <- adam %>%
  group_by(TRTGRP, VISIT) %>%
  summarise(
    N = n(),
    Mean = round(mean(AVAL, na.rm = TRUE), 1),
    SD = round(sd(AVAL, na.rm = TRUE), 1),
    .groups = "drop"
  ) %>%
  gt() %>%
  tab_header(title = "Table 1: Mean ± SD of AVAL by Treatment and Visit")

print(tlf_table)

# Figure: Line plot of AVAL by visit
tlf_plot <- ggplot(adam, aes(x = VISIT, y = AVAL, color = TRTGRP, group = USUBJID)) +
  geom_line(alpha = 0.5) +
  geom_smooth(aes(group = TRTGRP), method = "loess", se = FALSE, size = 1.2) +
  theme_minimal() +
  labs(title = "Figure 1: AVAL by Visit and Treatment", y = "AVAL", x = "Visit")

print(tlf_plot)
