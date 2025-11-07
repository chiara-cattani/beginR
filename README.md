# ClinicalRTransition - Chiara Internal Training Portal

A professional Flask web application designed for clinical programmers, statisticians, and data managers transitioning from SAS to R programming, Vibe Coding, and AI-assisted development.

## 🎯 Overview

ClinicalRTransition is a comprehensive learning portal that provides structured training for Chiara's clinical programming team. The application features 7 interactive modules covering R programming fundamentals, Vibe Coding methodology, GitHub Copilot integration, and clinical data standards.

## ✨ Features

- **7 Structured Learning Modules** - From R basics to advanced clinical programming
- **Interactive Progress Tracking** - Monitor your learning journey with localStorage-based progress
- **Downloadable Resources** - Access slides, exercises, handouts, and templates
- **Light/Dark Mode Toggle** - Comfortable viewing experience
- **Responsive Design** - Works seamlessly on desktop, tablet, and mobile
- **Professional UI** - Modern, clean interface with Bootstrap 5 and Inter font
- **Bonus Resources** - Additional tools, templates, and reference materials

## 🏗️ Tech Stack

- **Backend**: Flask (Python)
- **Frontend**: Bootstrap 5, HTML5, CSS3, JavaScript
- **Templating**: Jinja2
- **Fonts**: Inter (Google Fonts)
- **Icons**: Font Awesome 6
- **Styling**: Custom CSS with CSS Variables for theming

## 📁 Project Structure

```
ClinicalRTransition/
├── app.py                          # Main Flask application
├── requirements.txt                # Python dependencies
├── README.md                       # This file
├── templates/                      # HTML templates
│   ├── base.html                   # Base template with navigation
│   ├── index.html                  # Homepage
│   ├── modules.html                # Modules overview
│   ├── module_template.html        # Generic module template
│   ├── module1.html - module7.html # Individual module pages
│   ├── bonus.html                  # Bonus resources
│   └── contact.html                # Contact and support
├── static/                         # Static assets
│   ├── css/
│   │   └── styles.css              # Custom CSS styles
│   ├── js/
│   │   └── main.js                 # JavaScript functionality
│   └── resources/                  # Downloadable files
└── Course Materials/               # Original course files
    ├── Module1_Getting_Started.pptx
    ├── module1_exercises.R
    ├── module1_handout.docx
    └── ... (all other course files)
```

## 🚀 Quick Start

### Prerequisites

- Python 3.8 or higher
- pip (Python package installer)

### Installation

1. **Clone or download the project**
   ```bash
   # If using git
   git clone <repository-url>
   cd ClinicalRTransition
   
   # Or simply download and extract the ZIP file
   ```

2. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the application**
   ```bash
   python app.py
   ```

4. **Access the application**
   Open your web browser and navigate to:
   ```
   http://localhost:5000
   ```

## 📚 Course Modules

### Module 1: Getting Started with R
- R programming fundamentals and environment setup
- Basic syntax and data structures
- R vs SAS comparison

### Module 2: Vibe Coding Essentials
- Vibe Coding methodology and principles
- Code organization and documentation
- Modular programming techniques

### Module 3: Copilot AI Programming
- GitHub Copilot setup and configuration
- Effective prompting techniques
- AI-assisted code generation

### Module 4: Clinical SDTM & ADaM
- CDISC standards in R context
- SDTM and ADaM dataset creation
- Regulatory compliance

### Module 5: TLFs and Reporting
- Tables, Listings, and Figures generation
- Automated reporting workflows
- Reproducibility and quality

### Module 6: Advanced Vibe Coding
- Advanced data manipulation techniques
- Performance optimization
- Enterprise integration

### Module 7: Final Project & QC
- Comprehensive clinical programming project
- Quality control procedures
- AI-assisted code review

## 🎨 Customization

### Colors and Themes

The application uses CSS variables for easy customization. Edit `static/css/styles.css` to modify:

- Primary colors (`--primary-color`)
- Background colors (`--light-bg`, `--dark-bg`)
- Text colors (`--text-primary`, `--text-secondary`)
- Border colors (`--border-color`)

### Adding New Modules

1. Update the `MODULES` dictionary in `app.py`
2. Create a new template file `templates/moduleX.html`
3. Add corresponding course materials to the project

### Adding New Resources

1. Update the `BONUS_RESOURCES` dictionary in `app.py`
2. Place files in the appropriate directory
3. Update download links in templates

## 🔧 Configuration

### Environment Variables

Create a `.env` file for environment-specific settings:

```env
FLASK_ENV=development
SECRET_KEY=your-secret-key-here
DEBUG=True
```

### Production Deployment

For production deployment:

1. Set `FLASK_ENV=production`
2. Use a production WSGI server (e.g., Gunicorn)
3. Configure a reverse proxy (e.g., Nginx)
4. Set up SSL certificates

## 📱 Browser Support

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For technical support or questions:

- **Slack**: #clinical-r-transition
- **Email**: clinical-r-support@Chiara.com
- **Office Hours**: Tuesday/Thursday 2-4 PM

## 📄 License

This project is proprietary to Chiara and intended for internal use only.

## 🙏 Acknowledgments

- Bootstrap team for the excellent CSS framework
- Font Awesome for the comprehensive icon library
- Google Fonts for the Inter font family
- The R community for excellent documentation and resources

---

**Built with ❤️ for Chiara's Clinical Programming Team** 