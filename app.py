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
        'title': 'RStudio & Environment Setup',
        'description': 'Learn to install R/RStudio, set up nutriciaconfig for environment management, navigate RStudio interface, and get started with GitHub Copilot.',
        'objectives': [
            'Install R and RStudio with proper configuration',
            'Set up nutriciaconfig for environment and working directory management',
            'Navigate RStudio panes and understand R file types',
            'Load essential packages (dplyr, haven, tibble) for clinical programming',
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
        'title': 'Data Manipulation Basics',
        'description': 'Master fundamental data manipulation using dplyr functions, understand tibbles and data types, and learn how R operations compare to SAS DATA step logic.',
        'objectives': [
            'Understand tibbles and R data types (character, numeric, logical, date)',
            'Use dplyr functions: filter, select, mutate, arrange for data manipulation',
            'Compare R data wrangling operations with SAS DATA step logic',
            'Practice deriving clinical variables like elderly flag (age >= 65)',
            'Apply best practices for readable and efficient data transformations'
        ],
        'files': {
            'theory': 'training_material/module 2 - data_manipulation/module2_theory.qmd',
            'theory_html': 'training_material/module 2 - data_manipulation/module2_theory.html',
            'demo': 'training_material/module 2 - data_manipulation/module2_demo.R',
            'exercise': 'training_material/module 2 - data_manipulation/module2_exercise.R',
            'solution': 'training_material/module 2 - data_manipulation/module2_solution.qmd',
            'solution_html': 'training_material/module 2 - data_manipulation/module2_solution.html'
        }
    },
    3: {
        'title': 'Joins and Summaries',
        'description': 'Learn to combine datasets using join operations, create grouped summaries, and generate frequency tables for clinical data analysis.',
        'objectives': [
            'Perform join operations using left_join, inner_join, and other dplyr join functions',
            'Use group_by and summarise to create summary statistics by treatment groups',
            'Generate frequency tables using count and n functions',
            'Practice with clinical scenarios: summarizing adverse events by elderly vs non-elderly patients',
            'Handle missing data and edge cases in join operations'
        ],
        'files': {
            'theory': 'training_material/module 3 - joins_summaries/module3_theory.qmd',
            'theory_html': 'training_material/module 3 - joins_summaries/module3_theory.html',
            'demo': 'training_material/module 3 - joins_summaries/module3_demo.R',
            'exercise': 'training_material/module 3 - joins_summaries/module3_exercise.R',
            'solution': 'training_material/module 3 - joins_summaries/module3_solution.qmd',
            'solution_html': 'training_material/module 3 - joins_summaries/module3_solution.html'
        }
    },
    4: {
        'title': 'Date & Text Handling',
        'description': 'Master date conversions, study day calculations, and string manipulation essential for clinical programming and CDISC standards.',
        'objectives': [
            'Convert dates using lubridate functions (ymd, dmy, mdy) for clinical data',
            'Calculate study days (e.g., AESTDY = AESTDTC - RFSTDTC + 1)',
            'Use stringr functions for text manipulation (str_detect, str_replace, str_trim)',
            'Practice deriving AESTDY and cleaning adverse event terms',
            'Handle date/time formats and missing date scenarios in clinical contexts'
        ],
        'files': {
            'theory': 'training_material/module 4 - dates_text/module4_theory.qmd',
            'theory_html': 'training_material/module 4 - dates_text/module4_theory.html',
            'demo': 'training_material/module 4 - dates_text/module4_demo.R',
            'exercise': 'training_material/module 4 - dates_text/module4_exercise.R',
            'solution': 'training_material/module 4 - dates_text/module4_solution.qmd',
            'solution_html': 'training_material/module 4 - dates_text/module4_solution.html'
        }
    },
    5: {
        'title': 'Functions & Macro Translation',
        'description': 'Learn to write reusable R functions for clinical programming tasks and translate SAS macros into efficient R code.',
        'objectives': [
            'Write custom R functions with proper arguments and return values',
            'Understand scope, debugging, and documentation for R functions',
            'Translate simple SAS macros into equivalent R functions',
            'Use purrr package for functional programming and iteration',
            'Create reusable functions for common clinical programming tasks'
        ],
        'files': {
            'theory': 'training_material/module 5 - functions_macros/module5_theory.qmd',
            'theory_html': 'training_material/module 5 - functions_macros/module5_theory.html',
            'demo': 'training_material/module 5 - functions_macros/module5_demo.R',
            'exercise': 'training_material/module 5 - functions_macros/module5_exercise.R',
            'solution': 'training_material/module 5 - functions_macros/module5_solution.qmd',
            'solution_html': 'training_material/module 5 - functions_macros/module5_solution.html'
        }
    },
    6: {
        'title': 'SDTM Programming with sdtm.oak',
        'description': 'Build CDISC-compliant SDTM domains using the sdtm.oak package, from metadata reading to XPT file export.',
        'objectives': [
            'Read study metadata and specifications using readxl',
            'Load raw clinical datasets using haven and other R packages',
            'Create SDTM domains using sdtm.oak::create_domain functions',
            'Apply data transformations, derivations, and post-processing steps',
            'Export SDTM datasets to XPT format using haven::write_xpt'
        ],
        'files': {
            'theory': 'training_material/module 6 - sdtm_programming/module6_theory.qmd',
            'theory_html': 'training_material/module 6 - sdtm_programming/module6_theory.html',
            'demo': 'training_material/module 6 - sdtm_programming/module6_demo.R',
            'exercise': 'training_material/module 6 - sdtm_programming/module6_exercise.R',
            'solution': 'training_material/module 6 - sdtm_programming/module6_solution.qmd',
            'solution_html': 'training_material/module 6 - sdtm_programming/module6_solution.html'
        }
    },
    7: {
        'title': 'Post-Processing, QC & Reporting',
        'description': 'Master final data formatting, quality control procedures, report generation, and GitHub Copilot best practices for clinical programming. Future: SAS validation integration.',
        'objectives': [
            'Format date/time variables to ISO8601 standards and reorder columns per specifications',
            'Implement double-programming QC by comparing R outputs against SAS results',
            'Generate professional tables and reports using gt (future: SAS validation procedures)',
            'Apply GitHub Copilot best practices for clinical programming workflows',
            'Understand learning outcomes and plan next steps in R clinical programming journey'
        ],
        'files': {
            'theory': 'training_material/module 7 - qc_reporting/module7_theory.qmd',
            'theory_html': 'training_material/module 7 - qc_reporting/module7_theory.html',
            'demo': 'training_material/module 7 - qc_reporting/module7_demo.R',
            'exercise': 'training_material/module 7 - qc_reporting/module7_exercise.R',
            'solution': 'training_material/module 7 - qc_reporting/module7_solution.qmd',
            'solution_html': 'training_material/module 7 - qc_reporting/module7_solution.html'
        }
    }
}

BONUS_RESOURCES = {
    'sas_cheatsheet': {
        'title': 'R vs SAS Cheatsheet',
        'description': 'Quick reference comparing SAS and R syntax for data programming',
        'file': 'bonus_resources/rendered/01_R_vs_SAS_CheatSheet.html',
        'icon': '�'
    },
    'sdtm_programming': {
        'title': 'SDTM Programming Guide',
        'description': 'Complete examples for SDTM domain creation with sdtm.oak',
        'file': 'bonus_resources/rendered/02_sdtm_programming_guide.html',
        'icon': '📊'
    },
    'qc_validation': {
        'title': 'QC Validation Toolkit',
        'description': 'Quality control procedures and data validation scripts',
        'file': 'bonus_resources/rendered/03_qc_validation_toolkit.html',
        'icon': '✓'
    },
    'data_manipulation': {
        'title': 'Data Manipulation Examples',
        'description': 'dplyr operations and data manipulation techniques',
        'file': 'bonus_resources/rendered/04_data_manipulation_examples.html',
        'icon': '📊'
    },
    'custom_functions': {
        'title': 'Custom Functions Library',
        'description': 'Reusable R functions and SAS macro translations',
        'file': 'bonus_resources/rendered/05_custom_functions_library.html',
        'icon': '🔧'
    },
    'date_text_functions': {
        'title': 'Date & Text Functions',
        'description': 'lubridate and stringr practical examples',
        'file': 'bonus_resources/rendered/06_date_text_functions.html',
        'icon': '📅'
    },
    'copilot_prompts': {
        'title': 'GitHub Copilot Best Practices',
        'description': 'Effective prompting strategies for R programming with AI',
        'file': 'bonus_resources/copilot_prompt_library.pdf',
        'icon': '🤖'
    },
    'report_template': {
        'title': 'Report Template',
        'description': 'R Markdown template for data analysis reports',
        'file': 'bonus_resources/rendered/report_template.Rmd',
        'icon': '📄'
    },
    'sas_to_r_cheatsheet': {
        'title': 'SAS to R Migration Guide',
        'description': 'Comprehensive guide for transitioning from SAS to R',
        'file': 'bonus_resources/sas_to_r_cheatsheet.pdf',
        'icon': '🔄'
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
        # Search for file in training_material subdirectories first
        for root, dirs, files in os.walk('training_material'):
            if filename in files:
                file_path = os.path.join(root, filename)
                return send_file(file_path, as_attachment=True)
        
        # Then check bonus_resources directory (including rendered subfolder)
        rendered_path = os.path.join('bonus_resources', 'rendered', filename)
        if os.path.exists(rendered_path):
            return send_file(rendered_path, as_attachment=True)
        
        bonus_path = os.path.join('bonus_resources', filename)
        if os.path.exists(bonus_path):
            return send_file(bonus_path, as_attachment=True)
        
        return f"File not found: {filename}", 404
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

@app.route('/static_files/<path:filename>')
def serve_static_files(filename):
    """Serve supporting files for rendered HTML documents"""
    try:
        # Clean up path separators for Windows
        clean_filename = filename.replace('/', os.sep)
        if os.path.exists(clean_filename):
            # Determine the correct MIME type based on file extension
            if filename.endswith('.css'):
                return send_file(clean_filename, mimetype='text/css')
            elif filename.endswith('.js'):
                return send_file(clean_filename, mimetype='application/javascript')
            elif filename.endswith('.woff') or filename.endswith('.woff2'):
                return send_file(clean_filename, mimetype='font/woff')
            else:
                return send_file(clean_filename)
        return "File not found", 404
    except Exception as e:
        return f"Error: {str(e)}", 404

@app.route('/toggle_theme', methods=['POST'])
def toggle_theme():
    data = request.get_json()
    theme = data.get('theme', 'light')
    return jsonify({'status': 'success', 'theme': theme})

@app.route('/view/<path:filename>')
def view_file(filename):
    """View content of various file types with proper rendering"""
    try:
        # Search for file in training_material subdirectories first
        file_path = None
        base_dir = None
        
        for root, dirs, files in os.walk('training_material'):
            if filename in files:
                file_path = os.path.join(root, filename)
                base_dir = os.path.dirname(file_path)
                break
        
        # If not found, check bonus_resources directory (including rendered subfolder)
        if not file_path:
            # First check rendered subfolder
            rendered_path = os.path.join('bonus_resources', 'rendered', filename)
            if os.path.exists(rendered_path):
                file_path = rendered_path
                base_dir = 'bonus_resources/rendered'
            else:
                # Then check main bonus_resources directory
                bonus_path = os.path.join('bonus_resources', filename)
                if os.path.exists(bonus_path):
                    file_path = bonus_path
                    base_dir = 'bonus_resources'
        
        if not file_path:
            return f"File not found: {filename}", 404
        
        if filename.endswith('.pdf'):
            # For PDF files, serve them directly to open in browser
            return send_file(file_path, mimetype='application/pdf')
            
        elif filename.endswith('.qmd'):
            # For QMD files, try to find rendered HTML first, otherwise show raw content
            html_filename = filename.replace('.qmd', '.html')
            html_path = None
            
            # Search for HTML file recursively in training_material
            for root, dirs, files in os.walk('training_material'):
                if html_filename in files:
                    html_path = os.path.join(root, html_filename)
                    break
            
            # If not found, check bonus_resources directories
            if not html_path:
                # First check rendered subfolder
                bonus_rendered_path = os.path.join('bonus_resources', 'rendered', html_filename)
                if os.path.exists(bonus_rendered_path):
                    html_path = bonus_rendered_path
                else:
                    # Then check main bonus_resources directory
                    bonus_html_path = os.path.join('bonus_resources', html_filename)
                    if os.path.exists(bonus_html_path):
                        html_path = bonus_html_path
            
            if html_path:
                # Read and serve the rendered HTML
                with open(html_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Fix relative paths for supporting files
                file_base = os.path.splitext(os.path.basename(html_filename))[0]
                files_dir = f"{file_base}_files"
                if files_dir in content:
                    # Get the directory where the HTML file is located
                    html_dir = os.path.dirname(html_path).replace('\\', '/')
                    # Replace all variations of the path references
                    import re
                    # Replace src attributes
                    content = re.sub(f'src="({files_dir}/[^"]*)"', f'src="/static_files/{html_dir}/\\1"', content)
                    # Replace href attributes  
                    content = re.sub(f'href="({files_dir}/[^"]*)"', f'href="/static_files/{html_dir}/\\1"', content)
                
                return content, 200, {'Content-Type': 'text/html'}
            else:
                # Show QMD source with syntax highlighting
                with open(file_path, 'r', encoding='utf-8') as f:
                    qmd_content = f.read()
                return render_template('file_viewer.html', 
                                     filename=filename, 
                                     content=qmd_content, 
                                     file_type='markdown',
                                     message="Showing QMD source code (rendered HTML not available)")
                                     
        elif filename.endswith('.Rmd'):
            # For RMD files, try to find rendered HTML first, otherwise show raw content
            html_filename = filename.replace('.Rmd', '.html')
            html_path = os.path.join(base_dir, html_filename)
            if os.path.exists(html_path):
                with open(html_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                return content, 200, {'Content-Type': 'text/html'}
            else:
                # Show RMD source with syntax highlighting
                with open(file_path, 'r', encoding='utf-8') as f:
                    rmd_content = f.read()
                return render_template('file_viewer.html', 
                                     filename=filename, 
                                     content=rmd_content, 
                                     file_type='markdown',
                                     message="Showing RMD source code (rendered HTML not available)")
                                     
        elif filename.endswith('.R'):
            # For R files, show with syntax highlighting
            with open(file_path, 'r', encoding='utf-8') as f:
                r_content = f.read()
            return render_template('file_viewer.html', 
                                 filename=filename, 
                                 content=r_content, 
                                 file_type='r',
                                 message="R Script")
                                 
        elif filename.endswith(('.html', '.htm')):
            # For HTML files, serve with proper static file paths
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Fix relative paths for supporting files
            file_base = os.path.splitext(os.path.basename(filename))[0]
            files_dir = f"{file_base}_files"
            if files_dir in content:
                # Get the directory where the HTML file is located
                html_dir = os.path.dirname(file_path).replace('\\', '/')
                # Replace all variations of the path references
                import re
                # Replace src attributes
                content = re.sub(f'src="({files_dir}/[^"]*)"', f'src="/static_files/{html_dir}/\\1"', content)
                # Replace href attributes  
                content = re.sub(f'href="({files_dir}/[^"]*)"', f'href="/static_files/{html_dir}/\\1"', content)
            
            return content, 200, {'Content-Type': 'text/html'}
            
        else:
            # For other text files, show as plain text
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            return render_template('file_viewer.html', 
                                 filename=filename, 
                                 content=content, 
                                 file_type='text',
                                 message=f"Viewing: {os.path.basename(filename)}")
            
    except FileNotFoundError:
        return f"File not found: {filename}", 404
    except Exception as e:
        return f"Error viewing file: {str(e)}", 500

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