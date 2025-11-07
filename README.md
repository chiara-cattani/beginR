# beginR

A modular web-based training platform for transitioning from SAS to R programming in data analysis and clinical research

![Python](https://img.shields.io/badge/Python-3.8%2B-blue)
![Flask](https://img.shields.io/badge/Flask-2.3%2B-green)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Made with R](https://img.shields.io/badge/Made%20with-R-276DC3.svg)

**beginR** is a comprehensive Flask-based training portal that provides structured, progressive learning modules for data professionals transitioning from SAS to R. The platform emphasizes practical skills development through hands-on exercises, GitHub Copilot integration, and real-world data manipulation scenarios including SDTM programming and quality control procedures.

• **Modular**: 7 progressive learning modules from RStudio setup to advanced QC and reporting
• **Interactive**: Progress tracking, downloadable resources, and hands-on exercises
• **AI-Enhanced**: GitHub Copilot integration throughout the curriculum  
• **Practical**: Real-world data manipulation, SDTM creation, and professional reporting workflows

## Project Status

• **Version**: 1.0.0 (stable)
• **Status**: ✅ Production-ready for training programs and self-study
• **Scope**: Complete SAS-to-R transition curriculum with 7 structured modules

## Features

• **Metadata-driven learning**: Module configuration in Python dictionaries with flexible content management
• **Progressive curriculum**: RStudio setup → data manipulation → joins → dates/text → functions → SDTM → QC/reporting
• **Resource management**: Downloadable exercises, solutions, templates, and reference materials
• **Progress persistence**: localStorage-based tracking across sessions with visual progress indicators
• **Theme support**: Light/dark mode with CSS variables and user preference persistence
• **Responsive design**: Mobile-first Bootstrap 5 implementation with cross-device compatibility

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

# Platform-specific shortcuts
start_app.bat      # Windows
./start_app.sh     # Unix/Linux
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
| **1** | RStudio & Environment Setup | Installation, nutriciaconfig, GitHub Copilot basics |
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

## Features Overview

### Progress Tracking
• localStorage-based progress persistence across browser sessions
• Individual learning objective completion tracking with visual indicators
• Module-level progress bars and completion status
• Dark/light theme preference persistence

### User Interface
• Responsive Bootstrap 5 design optimized for multiple screen sizes
• CSS variables for consistent theming and easy customization
• Font Awesome icons and Inter font for professional appearance
• Accessible navigation with ARIA labels and keyboard support

## �🔧 Configuration & Deployment

### Environment Variables
Create a `.env` file for custom settings:
```env
FLASK_ENV=development
SECRET_KEY=your-secret-key-here
DEBUG=True
PORT=5000
```

### Production Deployment
1. Set `FLASK_ENV=production` and disable debug mode
2. Use production WSGI server (Gunicorn recommended)
3. Configure reverse proxy (Nginx) with SSL certificates
4. Set secure session configurations

### Docker Deployment
```dockerfile
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
```

## 🌐 Browser Compatibility

- **Chrome/Edge**: 90+ (full support)
- **Firefox**: 88+ (full support)  
- **Safari**: 14+ (full support)
- **Mobile browsers**: iOS Safari 14+, Chrome Mobile 90+

## 🏗️ Technology Details

### Backend Stack
- **Flask 2.3+**: Lightweight Python web framework
- **Jinja2**: Template engine with inheritance and macros
- **Werkzeug**: WSGI utilities and development server

### Frontend Stack  
- **Bootstrap 5.3**: Responsive CSS framework with CSS Grid
- **Font Awesome 6**: Comprehensive icon library
- **Inter Font**: Professional typography from Google Fonts
- **Vanilla JavaScript**: Progress tracking and theme management

### Key Features
- **Responsive Design**: Mobile-first approach with Bootstrap Grid
- **Accessibility**: ARIA labels, keyboard navigation, color contrast
- **Performance**: Minified assets, efficient CSS variables
- **SEO**: Semantic HTML, meta tags, structured data

## Contributing

1. Fork the repository
2. Create a feature branch for your changes
3. Follow PEP 8 coding standards for Python code
4. Test across multiple browsers and screen sizes
5. Update documentation as needed
6. Submit a pull request with clear description

## Known Limitations

1. **Content scope**: Focuses on SAS-to-R transition; not comprehensive R programming
2. **Performance**: Not optimized for concurrent users (designed for individual/small group use)
3. **Offline usage**: Requires internet connection for CDN resources (Bootstrap, Font Awesome)
4. **Mobile experience**: Full functionality best experienced on desktop/tablet devices

## Roadmap

• **Enhanced progress analytics** — detailed learning analytics and completion reports
• **Interactive coding exercises** — in-browser R code execution and validation
• **Video integration** — embedded tutorial videos for complex concepts
• **Community features** — discussion forums and peer collaboration tools
• **Assessment modules** — quizzes and practical evaluations for each module
• **Certification pathway** — formal completion certificates and skills verification

## References

• [R for Data Science](https://r4ds.had.co.nz/) — Comprehensive R programming resource
• [dplyr documentation](https://dplyr.tidyverse.org/) — Data manipulation reference
• [CDISC SDTM Implementation Guide](https://www.cdisc.org/standards/foundational/sdtm) — Clinical data standards
• [GitHub Copilot Documentation](https://docs.github.com/en/copilot) — AI programming assistance

## Citation

> Cattani, C. (2025). beginR: Modular Web-Based Training Platform for SAS-to-R Transition. 
> Web application version 1.0.0. https://github.com/chiara-cattani/beginR

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details. 