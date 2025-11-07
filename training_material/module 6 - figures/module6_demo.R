# Module 6 Demo (Distinct) — TLF Figures: Clinical Visualizations

# 📦 Libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(patchwork)

# ----------------------------
# 🧬 Simulated Lab Dataset: Longitudinal Values for ALT, AST
# ----------------------------

set.seed(100)
labs <- tibble::tibble(
  USUBJID = rep(paste0("SUBJ", 1:10), each = 4),
  VISIT = rep(c("Screening", "Day 1", "Week 4", "EOS"), times = 10),
  ARM = rep(c("Placebo", "Drug"), each = 20),
  ALT = round(rnorm(40, mean = 35, sd = 10), 1),
  AST = round(rnorm(40, mean = 30, sd = 8), 1)
)

labs_long <- labs %>%
  pivot_longer(cols = c(ALT, AST), names_to = "Test", values_to = "Value")

# ----------------------------
# 📈 A. Line Plot: Lab Trajectories by Subject

ggplot(labs_long, aes(x = VISIT, y = Value, group = USUBJID, color = ARM)) +
  geom_line(alpha = 0.6) +
  facet_wrap(~Test) +
  theme_minimal() +
  labs(title = "ALT/AST Trajectories by Subject", y = "Value (U/L)")

# ----------------------------
# 📉 B. Mean ± SD Line Plot: Mean ALT/AST by Visit

labs_summary <- labs_long %>%
  group_by(VISIT, ARM, Test) %>%
  summarise(mean_val = mean(Value), sd_val = sd(Value), .groups = "drop")

ggplot(labs_summary, aes(x = VISIT, y = mean_val, group = ARM, color = ARM)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  geom_errorbar(aes(ymin = mean_val - sd_val, ymax = mean_val + sd_val), width = 0.1) +
  facet_wrap(~Test) +
  theme_minimal() +
  labs(title = "Mean ± SD for ALT and AST", y = "Mean ± SD (U/L)")

# ----------------------------
# 🔢 C. Heatmap: Mean ALT by Subject and Visit

labs_heat <- labs %>%
  select(USUBJID, VISIT, ALT) %>%
  pivot_wider(names_from = VISIT, values_from = ALT)

labs_heat_long <- labs_heat %>%
  pivot_longer(-USUBJID, names_to = "Visit", values_to = "ALT")

ggplot(labs_heat_long, aes(x = Visit, y = USUBJID, fill = ALT)) +
  geom_tile(color = "white") +
  scale_fill_gradient(low = "#ffffcc", high = "#cc0000") +
  theme_minimal() +
  labs(title = "ALT Heatmap per Subject and Visit", fill = "ALT (U/L)")

# ----------------------------
# 🤖 Copilot Prompt Ideas

# # Create mean ± SD line plot for ALT
# # Transform data into long format
# # Build heatmap of ALT by subject and visit
# # Add error bars to mean plots
