# beginR

A modular web-based training platform for transitioning from SAS to R programming in data analysis and clinical research

![Python](https://img.shields.io/badge/Python-3.8%2B-blue)
![Flask](https://img.shields.io/badge/Flask-2.3%2B-green)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Made with R](https://img.shields.io/badge/Made%20with-R-276DC3.svg)

**beginR** is a comprehensive Flask-based training portal that provides structured, progressive learning modules for data professionals transitioning from SAS to R. The platform emphasizes practical skills development through hands-on exercises, GitHub Copilot integration, and real-world data manipulation scenarios including SDTM programming and quality control procedures.

- **Modular**: 7 progressive learning modules from RStudio setup to advanced QC and reporting
- **Interactive**: Progress tracking, downloadable resources, and hands-on exercises
- **AI-Enhanced**: GitHub Copilot integration throughout the curriculum
- **Practical**: Real-world data manipulation, SDTM creation, and professional reporting workflows

## Project Status

- **Version**: 1.2.0 (stable)
- **Status**: ✅ Production-ready for training programs and self-study
- **Scope**: Complete SAS-to-R transition curriculum with 7 structured modules
- **Latest Updates**: Enhanced UI, improved server stability, automatic logging, CI/CD integration

## Features

- **Metadata-driven learning**: Module configuration in Python dictionaries with flexible content management
- **Progressive curriculum**: RStudio setup → data manipulation → joins → dates/text → functions → SDTM → QC/reporting
- **Resource management**: Downloadable exercises, solutions, templates, and reference materials with organized bonus content
- **Progress persistence**: localStorage-based tracking across sessions with visual progress indicators and completion animations
- **Theme support**: Light/dark mode with CSS variables and user preference persistence
- **Certificate generation**: Automatic PDF certificate generation with completion logging to file-based storage
- **Contact system**: Secure contact form with file-based message storage (no email dependencies)
- **Enhanced UI**: Improved alignment, bigger interactive elements, and better visual feedback
- **CI/CD Integration**: GitHub Actions workflows with automated testing, formatting, and trusted contributor auto-merge
- **Responsive design**: Mobile-first Bootstrap 5 implementation with cross-device compatibility

## Installation

```bash
git clone https://github.com/chiara-cattani/beginR.git
cd beginR
pip install -r requirements.txt
```

**Requirements**: Python ≥ 3.8. Dependencies include `Flask`, `Jinja2`, `Werkzeug`.
Optional: `python-dotenv` for environment variable management.

**For R exercises**: R ≥ 4.0, RStudio recommended.
Required R packages: `dplyr`, `lubridate`, `stringr`, `haven`, `gt`, `sdtm.oak`.

```r
install.packages(c("dplyr", "lubridate", "stringr", "haven", "gt", "remotes"))
remotes::install_github("pharmaverse/sdtm.oak")
```

## Quick Start

The portal provides multiple launch options:

```bash
# Launch the application
python app.py
# or
python run.py

# Robust server startup (recommended)
python start_server.py              # Cross-platform robust startup
start_server_robust.bat            # Windows with auto-restart
start_app.bat                      # Windows simple startup
./start_app.sh                     # Unix/Linux startup
```

Access the training portal at `http://localhost:5000`

### Navigate the curriculum

1. **Start with Module 1**: RStudio setup and environment configuration
2. **Progress sequentially**: Each module builds on previous concepts
3. **Use progress tracking**: Check off learning objectives as you complete them
4. **Download resources**: Access exercises, solutions, and reference materials
5. **Practice with examples**: Work through hands-on coding exercises in RStudio

## Core Modules

| Module | Topic | Key Skills |
|--------|-------|------------|
| **1** | RStudio & Environment Setup | Installation, envconfig, GitHub Copilot basics |
| **2** | Data Manipulation Basics | dplyr fundamentals, tibbles, data types, SAS comparison |
| **3** | Joins & Summaries | left_join, group_by, summarise, frequency tables |
| **4** | Date & Text Handling | lubridate functions, stringr operations, study day calculations |
| **5** | Functions & Macro Translation | Custom R functions, SAS macro conversion, purrr iteration |
| **6** | SDTM Programming | sdtm.oak domains, metadata reading, XPT export |
| **7** | QC & Reporting | ISO8601 formatting, double-programming QC, gt tables |

## � Bonus Resources

## Supplementary Resources

All bonus materials are organized in the `bonus_resources/` folder:

| Resource | Description | Module Coverage |
|----------|-------------|-----------------|
| `sas_to_r_cheatsheet.pdf` | SAS→R syntax mapping with practical examples | All modules |
| `copilot_prompt_library.pdf` | GitHub Copilot prompt templates and best practices | All modules |
| `report_template.Rmd` | Professional RMarkdown template for analysis reports | Module 7 |
| `data_manipulation_examples.R` | dplyr operations and data wrangling techniques | Modules 2-3 |
| `date_text_functions.R` | lubridate and stringr practical implementations | Module 4 |
| `custom_functions_library.R` | Reusable R functions and SAS macro translations | Module 5 |
| `sdtm_programming_guide.R` | SDTM domain creation with sdtm.oak package | Module 6 |
| `qc_validation_toolkit.R` | Quality control procedures and validation methods | Module 7 |

## Repository Layout

• `app.py` — Flask application, module configuration, and routing logic
• `templates/` — Jinja2 HTML templates with inheritance and component structure
• `static/css/styles.css` — CSS variables, responsive design, and theme management
• `static/js/main.js` — Progress tracking, theme toggle, and interactive features
• `training_material/` — Structured learning content organized by module
• `bonus_resources/` — Downloadable materials, templates, and reference files
• `requirements.txt` — Python dependencies and version specifications

## Contributing

1. Fork the repository
2. Create a feature branch for your changes
3. Follow coding standards and submit a pull request with clear description
4. For detailed development setup, see [CI-CD.md](docs/CI-CD.md)

## Roadmap

- **Enhanced progress analytics** — detailed learning analytics and completion reports
- **Interactive coding exercises** — in-browser R code execution and validation
- **Video integration** — embedded tutorial videos for complex concepts
- **Community features** — discussion forums and peer collaboration tools
- **Assessment modules** — quizzes and practical evaluations for each module
- **Certification pathway** — formal completion certificates and skills verification

## References

- [R for Data Science](https://r4ds.had.co.nz/) — Comprehensive R programming resource
- [dplyr documentation](https://dplyr.tidyverse.org/) — Data manipulation reference
- [CDISC SDTM Implementation Guide](https://www.cdisc.org/standards/foundational/sdtm) — Clinical data standards
- [GitHub Copilot Documentation](https://docs.github.com/en/copilot) — AI programming assistance

## Citation

> Cattani, C. (2025). beginR: Modular Web-Based Training Platform for SAS-to-R Transition.
> Web application version 1.0.0. https://github.com/chiara-cattani/beginR

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
