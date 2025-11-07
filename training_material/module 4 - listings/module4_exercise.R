# Module 4 Hands-On Exercise — TLF Listings in R
# Goal: Practice creating styled and exportable clinical listings

# ----------------------------
# ✅ Part 1 — Create Subject-Level Listing
# ----------------------------

# 1. Create a data frame called `subjects` with the following columns:
# - USUBJID
# - AGE
# - SEX
# - COUNTRY

# 2. Use `flextable()` to create a table
# 3. Add a title and autofit the table

# Your code here


# ----------------------------
# ✅ Part 2 — Create Event-Level Listing with gt
# ----------------------------

# 1. Create a data frame `aes` with the following columns:
# - USUBJID
# - AEDECOD
# - AESEV
# - AESER
# - AESTDTC

# 2. Use `gt()` to create a table
# 3. Add a title and color the AESEV column
# 4. Bold or highlight AESER == "Y" rows (bonus)

# Your code here


# ----------------------------
# ✅ Part 3 — Create Interactive Listing
# ----------------------------

# 1. Use `reactable()` to display the AE data interactively
# 2. Make the table searchable
# 3. Group rows by AEDECOD
# 4. Add custom styles to AESEV column based on severity

# Your code here


# ----------------------------
# ✅ Part 4 — Export Listings (Optional)

# 1. Export the flextable to Word (using `officer`)
# 2. Export the gt table to HTML (using `gtsave`)

# Your code here (optional)


# ----------------------------
# 💡 Copilot Prompts to Try

# # Create flextable with clinical data
# # Color column based on AE severity
# # Export table to Word
# # Build interactive AE listing

# ----------------------------
# ✅ Summary

# In this exercise you should have:
# - Created formatted listings using flextable, gt, and reactable
# - Applied styling, grouping, and interactivity
# - Practiced exporting listings for reporting
# - Used Copilot to assist with formatting and output
