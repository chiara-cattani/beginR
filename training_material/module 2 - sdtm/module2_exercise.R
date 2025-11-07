# Module 2 Hands-On Exercise (Student Version)
# Domain: AE (Adverse Events)
# Goal: Practice building an SDTM domain from mock CRF-like data

# ----------------------------
# ✅ Part 1 — Create Raw Dataset
# ----------------------------

# Create a data frame named `ae_raw` with at least 5 rows and the following columns:
# - USUBJID (e.g., "01-001", ...)
# - AESTDAT (raw AE start date, e.g., "2023-01-02")
# - AETM (time of AE, e.g., "08:00", "20:00")
# - FORMID (e.g., "F001", ...)
# - RFSTDTC (reference start date: use same date for all records)

# Your code here


# ----------------------------
# ✅ Part 2 — Derive SDTM Variables
# ----------------------------

# 1. Derive AESTDTC in ISO format from AESTDAT
# 2. Derive AEDY = AESTDTC - RFSTDTC + 1
# 3. Derive AETPT using AETM (08:00 = MORNING, 20:00 = EVENING)
# 4. Derive AESEQ by subject
# 5. Derive AESPID = paste0("CRF_", FORMID)

# Your code here


# ----------------------------
# ✅ Part 3 — Apply Labels
# ----------------------------

# Assign appropriate labels using `labelled::var_label()` to each variable

# Your code here


# ----------------------------
# ✅ Part 4 — Export to XPT
# ----------------------------

# Use haven::write_xpt() to export the dataset to "output/ae_demo.xpt"

# Your code here


# ----------------------------
# 💡 Bonus — Use Copilot
# ----------------------------

# Try using GitHub Copilot for these comments:
# # Create AESTDTC from AESTDAT
# # Assign AETPT based on time
# # Number AESEQ within subject
# # Create AESPID using FORMID

# ----------------------------
# ✅ Summary
# ----------------------------

# In this exercise, you should have:
# - Created an AE-like dataset from scratch
# - Derived SDTM variables including dates, study day, and sequence
# - Applied labels and exported to XPT
# - Practiced prompting Copilot for R code
