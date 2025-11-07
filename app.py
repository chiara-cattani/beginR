from flask import Flask, render_template, send_file, url_for, request, jsonify, flash, redirect
import os
import zipfile
import io
from datetime import datetime
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from reportlab.lib.units import inch
from flask_mail import Mail, Message

app = Flask(__name__)
app.config['SECRET_KEY'] = 'clinical-r-transition-2024'

# --- Flask-Mail config (user must fill in real values) ---
app.config['MAIL_SERVER'] = 'smtp.example.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = 'your@email.com'
app.config['MAIL_PASSWORD'] = 'yourpassword'
app.config['MAIL_DEFAULT_SENDER'] = 'your@email.com'
mail = Mail(app)

# Module data structure
MODULES = {
    1: {
        'title': 'R for SAS Programmers: First Contact',
        'description': 'Introduction to R programming fundamentals, environment setup, and basic syntax for clinical programmers transitioning from SAS.',
        'objectives': [
            'Understand what R is and how it differs from SAS',
            'Be familiar with the RStudio interface and file types',
            'Learn how to write basic R code (variables, data frames, functions)',
            'Know the key R packages for clinical programming',
            'Understand how to use GitHub Copilot to assist you while coding'
        ],
        'files': {
            'theory': 'training_material/module 1 - intro/module1_theory.qmd',
            'theory_html': 'training_material/module 1 - intro/module1_theory.html',
            'demo': 'training_material/module 1 - intro/module1_demo.R',
            'exercise': 'training_material/module 1 - intro/module1_exercise.R',
            'solution': 'training_material/module 1 - intro/module1_solution.qmd',
            'solution_html': 'training_material/module 1 - intro/module1_solution.html'
        }
    },
    2: {
        'title': 'Building SDTM Datasets in R',
        'description': 'Learn to build SDTM datasets using R, focusing on data loading, variable derivation, and CDISC compliance.',
        'objectives': [
            'Understand how to load raw clinical data from CSV, XPT, or Excel',
            'Learn the key tidyverse tools for SDTM derivations',
            'Be able to derive standard SDTM variables like --DTC, --DY, --TPT, --SEQ, --SPID',
            'Apply SDTM dataset labeling using xportr',
            'Compare SDTM mapping in R vs SAS macro-based approaches',
            'Use GitHub Copilot to assist with formatting, variable naming, and logic'
        ],
        'files': {
            'theory': 'training_material/module 2 - sdtm/module2_theory.qmd',
            'theory_html': 'training_material/module 2 - sdtm/module2_theory.html',
            'demo': 'training_material/module 2 - sdtm/module2_demo.R',
            'exercise': 'training_material/module 2 - sdtm/module2_exercise.R',
            'solution': 'training_material/module 2 - sdtm/module2_solution.qmd',
            'solution_html': 'training_material/module 2 - sdtm/module2_solution.html'
        }
    },
    3: {
        'title': 'ADaM Programming in R',
        'description': 'Master ADaM dataset creation using R, focusing on pharmaverse packages, admiral toolkit, and AI assistance.',
        'objectives': [
            'Understand how to use pharmaverse packages for ADaM',
            'Learn how to derive ADSL and BDS datasets (e.g., ADVS, ADAE)',
            'Apply key functions from admiral to handle derivations and flags',
            'Use Copilot to build mutate chains and ADaM derivation templates'
        ],
        'files': {
            'theory': 'training_material/module 3 - adam/module3_theory.qmd',
            'theory_html': 'training_material/module 3 - adam/module3_theory.html',
            'demo': 'training_material/module 3 - adam/module3_demo.R',
            'exercise': 'training_material/module 3 - adam/module3_exercise.R',
            'solution': 'training_material/module 3 - adam/module3_solution.qmd',
            'solution_html': 'training_material/module 3 - adam/module3_solution.html'
        }
    },
    4: {
        'title': 'TLF Listings in R',
        'description': 'Create professional listings for clinical data using R, with focus on flextable, gt, and reactable packages.',
        'objectives': [
            'Understand what listings are and when they are used',
            'Learn to build subject- and event-level listings in R',
            'Apply conditional formatting and export to Word/HTML/PDF',
            'Use Copilot to format and enhance table output'
        ],
        'files': {
            'theory': 'training_material/module 4 - listings/module4_theory.qmd',
            'theory_html': 'training_material/module 4 - listings/module4_theory.html',
            'demo': 'training_material/module 4 - listings/module4_demo.R',
            'exercise': 'training_material/module 4 - listings/module4_exercise.R',
            'solution': 'training_material/module 4 - listings/module4_solution.qmd',
            'solution_html': 'training_material/module 4 - listings/module4_solution.html'
        }
    },
    5: {
        'title': 'TLF Tables: Summary Statistics',
        'description': 'Generate summary statistics tables for clinical trials using gtsummary, tidyverse, and AI assistance.',
        'objectives': [
            'Understand how to compute descriptive statistics by treatment arm',
            'Learn to create summary tables with tidyverse and gtsummary',
            'Create tables for continuous and categorical variables',
            'Practice exporting tables to Word or HTML',
            'Use Copilot to help build, format, and export summary tables'
        ],
        'files': {
            'theory': 'training_material/module 5 - tables/module5_theory.qmd',
            'theory_html': 'training_material/module 5 - tables/module5_theory.html',
            'demo': 'training_material/module 5 - tables/module5_demo.R',
            'exercise': 'training_material/module 5 - tables/module5_exercise.R',
            'solution': 'training_material/module 5 - tables/module5_solution.qmd',
            'solution_html': 'training_material/module 5 - tables/module5_solution.html'
        }
    },
    6: {
        'title': 'TLF Figures: Clinical Visualizations',
        'description': 'Create professional clinical plots and figures using ggplot2, survminer, and patchwork with AI assistance.',
        'objectives': [
            'Learn to create common clinical plots using ggplot2, survminer, and patchwork',
            'Understand how to visualize lab values, adverse events, and survival curves',
            'Learn to group plots by treatment arm or facet by visit',
            'Use AI (Copilot) to accelerate plot creation'
        ],
        'files': {
            'theory': 'training_material/module 6 - figures/module6_theory.qmd',
            'theory_html': 'training_material/module 6 - figures/module6_theory.html',
            'demo': 'training_material/module 6 - figures/module6_demo.R',
            'exercise': 'training_material/module 6 - figures/module6_exercise.R',
            'solution': 'training_material/module 6 - figures/module6_solution.qmd',
            'solution_html': 'training_material/module 6 - figures/module6_solution.html'
        }
    },
    7: {
        'title': 'Final Project: From SDTM to TLFs',
        'description': 'Complete a comprehensive clinical analysis project, from raw data to TLFs, using GitHub Copilot as your AI assistant.',
        'objectives': [
            'Apply everything learned in previous modules to complete a mock clinical analysis project',
            'Build SDTM datasets from raw data using dplyr, lubridate, and stringr',
            'Derive ADaM datasets using admiral and pharmaverse packages',
            'Generate TLFs (listings, tables, figures) for clinical reporting',
            'Use GitHub Copilot to assist with debugging, formatting, and optimization'
        ],
        'files': {
            'theory': 'training_material/module 7 - project/module7_theory.qmd',
            'theory_html': 'training_material/module 7 - project/module7_theory.html',
            'demo': 'training_material/module 7 - project/module7_demo.R',
            'exercise': 'training_material/module 7 - project/module7_exercise.R',
            'solution': 'training_material/module 7 - project/module7_solution.qmd',
            'solution_html': 'training_material/module 7 - project/module7_solution.html'
        }
    }
}

BONUS_RESOURCES = {
    'sas_cheatsheet': {
        'title': 'SAS to R Cheatsheet',
        'description': 'Quick reference guide for SAS users transitioning to R',
        'file': '_sas_to_r_cheatsheet.pdf',
        'icon': '📋'
    },
    'copilot_prompts': {
        'title': 'Copilot Prompt Library',
        'description': 'Collection of effective prompts for GitHub Copilot',
        'file': '_copilot_prompt_library.pdf',
        'icon': '🤖'
    },
    'clinical_template': {
        'title': 'Clinical Report Template',
        'description': 'R Markdown template for clinical trial reports',
        'file': '_clinical_report_template.Rmd',
        'icon': '📄'
    },
    'sdtm_derive': {
        'title': 'SDTM Derivation Examples',
        'description': 'Example scripts for SDTM dataset creation',
        'file': '_sdtm_derive.R',
        'icon': '📊'
    },
    'adam_build': {
        'title': 'ADaM Build Examples',
        'description': 'Example scripts for ADaM dataset creation',
        'file': '_adam_build.R',
        'icon': '📈'
    },
    'tlf_generator': {
        'title': 'TLF Generator',
        'description': 'Automated TLF generation scripts',
        'file': '_tlf_generator.R',
        'icon': '📋'
    },
    'qc_with_ai': {
        'title': 'QC with AI',
        'description': 'Quality control procedures using AI assistance',
        'file': '_qc_with_ai.R',
        'icon': '🔍'
    }
}

@app.route('/')
def index():
    return render_template('index.html', modules=MODULES)

@app.route('/modules')
def modules():
    return render_template('modules.html', modules=MODULES)

@app.route('/module/<int:module_id>')
def module_detail(module_id):
    if module_id not in MODULES:
        return "Module not found", 404
    return render_template(f'module{module_id}.html', module=MODULES[module_id], module_id=module_id)

@app.route('/bonus')
def bonus():
    return render_template('bonus.html', resources=BONUS_RESOURCES)

@app.route('/contact')
def contact():
    return render_template('contact.html')

@app.route('/download/<path:filename>')
def download_file(filename):
    try:
        return send_file(filename, as_attachment=True)
    except FileNotFoundError:
        return "File not found", 404

@app.route('/download_module/<int:module_id>')
def download_module_zip(module_id):
    if module_id not in MODULES:
        return "Module not found", 404
    
    # Create a ZIP file in memory
    memory_file = io.BytesIO()
    with zipfile.ZipFile(memory_file, 'w') as zf:
        module = MODULES[module_id]
        for file_type, filename in module['files'].items():
            if os.path.exists(filename):
                zf.write(filename, f"module{module_id}_{filename}")
    
    memory_file.seek(0)
    return send_file(
        memory_file,
        mimetype='application/zip',
        as_attachment=True,
        download_name=f"module{module_id}_{module['title'].replace(' ', '_').lower()}.zip"
    )

@app.route('/toggle_theme', methods=['POST'])
def toggle_theme():
    data = request.get_json()
    theme = data.get('theme', 'light')
    return jsonify({'status': 'success', 'theme': theme})

@app.route('/view/<path:filename>')
def view_file(filename):
    """View HTML content of Quarto files"""
    try:
        # Check if it's a Quarto file
        if filename.endswith('.qmd'):
            # Try to find the corresponding HTML file
            html_filename = filename.replace('.qmd', '.html')
            if os.path.exists(html_filename):
                # Read and modify the HTML content to fix file paths
                with open(html_filename, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Get the directory name for the supporting files
                dir_name = os.path.basename(os.path.dirname(html_filename))
                file_base = os.path.splitext(os.path.basename(html_filename))[0]
                files_dir = f"{file_base}_files"
                
                # Replace relative paths with Flask routes
                content = content.replace(f'{files_dir}/', f'/view_files/{dir_name}/{files_dir}/')
                
                return content, 200, {'Content-Type': 'text/html'}
            else:
                # Fallback to the QMD viewer if HTML doesn't exist
                return render_template('qmd_viewer.html', filename=filename, 
                                     message=f"HTML version not available for {filename}. Showing QMD content instead.")
        else:
            return "File type not supported for viewing", 400
    except FileNotFoundError:
        return "File not found", 404

@app.route('/view_qmd/<path:filename>')
def view_qmd_content(filename):
    """Serve the actual Quarto file content"""
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            content = f.read()
        return content, 200, {'Content-Type': 'text/plain'}
    except FileNotFoundError:
        return "File not found", 404
    except Exception as e:
        return f"Error reading file: {str(e)}", 500

@app.route('/view_files/<path:filepath>')
def serve_view_files(filepath):
    """Serve supporting files for HTML views (CSS, JS, etc.)"""
    try:
        # Construct the full path to the file
        full_path = os.path.join('training_material', filepath)
        
        # Determine MIME type based on file extension
        mime_type = 'text/plain'
        if filepath.endswith('.css'):
            mime_type = 'text/css'
        elif filepath.endswith('.js'):
            mime_type = 'application/javascript'
        elif filepath.endswith('.woff'):
            mime_type = 'font/woff'
        elif filepath.endswith('.woff2'):
            mime_type = 'font/woff2'
        elif filepath.endswith('.ttf'):
            mime_type = 'font/ttf'
        elif filepath.endswith('.eot'):
            mime_type = 'application/vnd.ms-fontobject'
        elif filepath.endswith('.svg'):
            mime_type = 'image/svg+xml'
        
        return send_file(full_path, mimetype=mime_type)
    except FileNotFoundError:
        return "File not found", 404
    except Exception as e:
        return f"Error reading file: {str(e)}", 500

# --- Certificate PDF Generation Helper ---
def generate_certificate_pdf(name, surname, date_str, modules):
    buffer = io.BytesIO()
    c = canvas.Canvas(buffer, pagesize=letter)
    width, height = letter
    c.setFont("Helvetica-Bold", 22)
    c.drawCentredString(width/2, height-1.5*inch, "Certificate of Completion")
    c.setFont("Helvetica", 14)
    c.drawCentredString(width/2, height-2.1*inch, f"This certifies that")
    c.setFont("Helvetica-Bold", 18)
    c.drawCentredString(width/2, height-2.6*inch, f"{name} {surname}")
    c.setFont("Helvetica", 14)
    c.drawCentredString(width/2, height-3.1*inch, f"has successfully completed the course:")
    c.setFont("Helvetica-Bold", 16)
    c.drawCentredString(width/2, height-3.6*inch, "ClinicalRTransition: Vibe Coding, R & AI for Clinical Programmers")
    c.setFont("Helvetica", 12)
    c.drawCentredString(width/2, height-4.1*inch, f"Date of Completion: {date_str}")
    c.setFont("Helvetica-Bold", 13)
    c.drawString(1.2*inch, height-4.8*inch, "Modules Completed:")
    c.setFont("Helvetica", 12)
    y = height-5.2*inch
    for i, m in enumerate(modules, 1):
        c.drawString(1.4*inch, y, f"{i}. {m}")
        y -= 0.3*inch
    c.showPage()
    c.save()
    buffer.seek(0)
    return buffer

# --- Certificate Download Route ---
@app.route('/download_certificate', methods=['POST'])
def download_certificate():
    name = request.form.get('name', '').strip()
    surname = request.form.get('surname', '').strip()
    if not name or not surname:
        flash('Name and surname are required.', 'danger')
        return redirect(url_for('modules'))
    date_str = datetime.now().strftime('%B %d, %Y')
    module_titles = [MODULES[m]['title'] for m in sorted(MODULES.keys())]
    pdf_buffer = generate_certificate_pdf(name, surname, date_str, module_titles)
    return send_file(pdf_buffer, as_attachment=True, download_name=f'Certificate_{name}_{surname}.pdf', mimetype='application/pdf')

# --- Certificate Email Route ---
@app.route('/send_certificate', methods=['POST'])
def send_certificate():
    name = request.form.get('name', '').strip()
    surname = request.form.get('surname', '').strip()
    email = request.form.get('email', '').strip()
    if not name or not surname or not email:
        flash('Name, surname, and email are required.', 'danger')
        return redirect(url_for('modules'))
    date_str = datetime.now().strftime('%B %d, %Y')
    module_titles = [MODULES[m]['title'] for m in sorted(MODULES.keys())]
    pdf_buffer = generate_certificate_pdf(name, surname, date_str, module_titles)
    msg = Message('Your ClinicalRTransition Certificate', recipients=[email])
    msg.body = f"Dear {name} {surname},\n\nCongratulations on completing the ClinicalRTransition course! Your certificate is attached.\n\nBest regards,\nChiara"
    msg.attach(f'Certificate_{name}_{surname}.pdf', 'application/pdf', pdf_buffer.read())
    try:
        mail.send(msg)
        flash('Certificate sent to your email!', 'success')
    except Exception as e:
        flash(f'Error sending email: {str(e)}', 'danger')
    return redirect(url_for('modules'))

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000) 