import io
import os
import zipfile
from datetime import datetime

from dotenv import load_dotenv
from flask import (
    Flask,
    flash,
    jsonify,
    redirect,
    render_template,
    request,
    send_file,
    url_for,
)
from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch
from reportlab.pdfgen import canvas

# Load environment variables from .env file
load_dotenv()

app = Flask(__name__)
app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "clinical-r-transition-2024")

# Module data structure
MODULES = {
    1: {
        "title": "RStudio & Environment Setup",
        "description": "Learn to install R/RStudio, set up nutriciaconfig for environment management, navigate RStudio interface, and get started with GitHub Copilot.",
        "objectives": [
            "Install R and RStudio with proper configuration",
            "Set up nutriciaconfig for environment and working directory management",
            "Navigate RStudio panes and understand R file types",
            "Load essential packages (dplyr, haven, tibble) for clinical programming",
            "Understand how to use GitHub Copilot to assist you while coding",
        ],
        "files": {
            "theory": "training_material/module 1 - intro/module1_theory.qmd",
            "theory_html": "training_material/module 1 - intro/module1_theory.html",
            "demo": "training_material/module 1 - intro/module1_demo.R",
            "exercise": "training_material/module 1 - intro/module1_exercise.R",
            "solution": "training_material/module 1 - intro/module1_solution.qmd",
            "solution_html": "training_material/module 1 - intro/module1_solution.html",
        },
    },
    2: {
        "title": "Data Manipulation Basics",
        "description": "Master fundamental data manipulation using dplyr functions, understand tibbles and data types, and learn how R operations compare to SAS DATA step logic.",
        "objectives": [
            "Understand tibbles and R data types (character, numeric, logical, date)",
            "Use dplyr functions: filter, select, mutate, arrange for data manipulation",
            "Compare R data wrangling operations with SAS DATA step logic",
            "Practice deriving clinical variables like elderly flag (age >= 65)",
            "Apply best practices for readable and efficient data transformations",
        ],
        "files": {
            "theory": "training_material/module 2 - data_manipulation/module2_theory.qmd",
            "theory_html": "training_material/module 2 - data_manipulation/module2_theory.html",
            "demo": "training_material/module 2 - data_manipulation/module2_demo.R",
            "exercise": "training_material/module 2 - data_manipulation/module2_exercise.R",
            "solution": "training_material/module 2 - data_manipulation/module2_solution.qmd",
            "solution_html": "training_material/module 2 - data_manipulation/module2_solution.html",
        },
    },
    3: {
        "title": "Joins and Summaries",
        "description": "Learn to combine datasets using join operations, create grouped summaries, and generate frequency tables for clinical data analysis.",
        "objectives": [
            "Perform join operations using left_join, inner_join, and other dplyr join functions",
            "Use group_by and summarise to create summary statistics by treatment groups",
            "Generate frequency tables using count and n functions",
            "Practice with clinical scenarios: summarizing adverse events by elderly vs non-elderly patients",
            "Handle missing data and edge cases in join operations",
        ],
        "files": {
            "theory": "training_material/module 3 - joins_summaries/module3_theory.qmd",
            "theory_html": "training_material/module 3 - joins_summaries/module3_theory.html",
            "demo": "training_material/module 3 - joins_summaries/module3_demo.R",
            "exercise": "training_material/module 3 - joins_summaries/module3_exercise.R",
            "solution": "training_material/module 3 - joins_summaries/module3_solution.qmd",
            "solution_html": "training_material/module 3 - joins_summaries/module3_solution.html",
        },
    },
    4: {
        "title": "Date & Text Handling",
        "description": "Master date conversions, study day calculations, and string manipulation essential for clinical programming and CDISC standards.",
        "objectives": [
            "Convert dates using lubridate functions (ymd, dmy, mdy) for clinical data",
            "Calculate study days (e.g., AESTDY = AESTDTC - RFSTDTC + 1)",
            "Use stringr functions for text manipulation (str_detect, str_replace, str_trim)",
            "Practice deriving AESTDY and cleaning adverse event terms",
            "Handle date/time formats and missing date scenarios in clinical contexts",
        ],
        "files": {
            "theory": "training_material/module 4 - dates_text/module4_theory.qmd",
            "theory_html": "training_material/module 4 - dates_text/module4_theory.html",
            "demo": "training_material/module 4 - dates_text/module4_demo.R",
            "exercise": "training_material/module 4 - dates_text/module4_exercise.R",
            "solution": "training_material/module 4 - dates_text/module4_solution.qmd",
            "solution_html": "training_material/module 4 - dates_text/module4_solution.html",
        },
    },
    5: {
        "title": "Functions & Macro Translation",
        "description": "Learn to write reusable R functions for clinical programming tasks and translate SAS macros into efficient R code.",
        "objectives": [
            "Write custom R functions with proper arguments and return values",
            "Understand scope, debugging, and documentation for R functions",
            "Translate simple SAS macros into equivalent R functions",
            "Use purrr package for functional programming and iteration",
            "Create reusable functions for common clinical programming tasks",
        ],
        "files": {
            "theory": "training_material/module 5 - functions_macros/module5_theory.qmd",
            "theory_html": "training_material/module 5 - functions_macros/module5_theory.html",
            "demo": "training_material/module 5 - functions_macros/module5_demo.R",
            "exercise": "training_material/module 5 - functions_macros/module5_exercise.R",
            "solution": "training_material/module 5 - functions_macros/module5_solution.qmd",
            "solution_html": "training_material/module 5 - functions_macros/module5_solution.html",
        },
    },
    6: {
        "title": "SDTM Programming with sdtm.oak",
        "description": "Build CDISC-compliant SDTM domains using the sdtm.oak package, from metadata reading to XPT file export.",
        "objectives": [
            "Read study metadata and specifications using readxl",
            "Load raw clinical datasets using haven and other R packages",
            "Create SDTM domains using sdtm.oak::create_domain functions",
            "Apply data transformations, derivations, and post-processing steps",
            "Export SDTM datasets to XPT format using haven::write_xpt",
        ],
        "files": {
            "theory": "training_material/module 6 - sdtm_programming/module6_theory.qmd",
            "theory_html": "training_material/module 6 - sdtm_programming/module6_theory.html",
            "demo": "training_material/module 6 - sdtm_programming/module6_demo.R",
            "exercise": "training_material/module 6 - sdtm_programming/module6_exercise.R",
            "solution": "training_material/module 6 - sdtm_programming/module6_solution.qmd",
            "solution_html": "training_material/module 6 - sdtm_programming/module6_solution.html",
        },
    },
    7: {
        "title": "Post-Processing, QC & Reporting",
        "description": "Quality control procedures, report generation, and GitHub Copilot best practices for clinical programming. Future: SAS validation integration.",
        "objectives": [
            "Format date/time variables to ISO8601 standards and reorder columns per specifications",
            "Implement double-programming QC by comparing R outputs against SAS results",
            "Generate professional tables and reports using gt (future: SAS validation procedures)",
            "Apply GitHub Copilot best practices for clinical programming workflows",
            "Understand learning outcomes and plan next steps in R clinical programming journey",
        ],
        "files": {
            "theory": "training_material/module 7 - qc_reporting/module7_theory.qmd",
            "theory_html": "training_material/module 7 - qc_reporting/module7_theory.html",
            "demo": "training_material/module 7 - qc_reporting/module7_demo.R",
            "exercise": "training_material/module 7 - qc_reporting/module7_exercise.R",
            "solution": "training_material/module 7 - qc_reporting/module7_solution.qmd",
            "solution_html": "training_material/module 7 - qc_reporting/module7_solution.html",
        },
    },
}

BONUS_RESOURCES = {
    "sas_cheatsheet": {
        "title": "R vs SAS Cheatsheet",
        "description": "Quick reference comparing SAS and R syntax for data programming",
        "file": "bonus_resources/rendered/01_R_vs_SAS_CheatSheet.html",
        "icon": "�",
    },
    "sdtm_programming": {
        "title": "SDTM Programming Guide",
        "description": "Complete examples for SDTM domain creation with sdtm.oak",
        "file": "bonus_resources/rendered/02_sdtm_programming_guide.html",
        "icon": "📊",
    },
    "qc_validation": {
        "title": "QC Validation Toolkit",
        "description": "Quality control procedures and data validation scripts",
        "file": "bonus_resources/rendered/03_qc_validation_toolkit.html",
        "icon": "✓",
    },
    "data_manipulation": {
        "title": "Data Manipulation Examples",
        "description": "dplyr operations and data manipulation techniques",
        "file": "bonus_resources/rendered/04_data_manipulation_examples.html",
        "icon": "📊",
    },
    "custom_functions": {
        "title": "Custom Functions Library",
        "description": "Reusable R functions and SAS macro translations",
        "file": "bonus_resources/rendered/05_custom_functions_library.html",
        "icon": "🔧",
    },
    "date_text_functions": {
        "title": "Date & Text Functions",
        "description": "lubridate and stringr practical examples",
        "file": "bonus_resources/rendered/06_date_text_functions.html",
        "icon": "📅",
    },
    "copilot_prompts": {
        "title": "GitHub Copilot Best Practices",
        "description": "Effective prompting strategies for R programming with AI",
        "file": "bonus_resources/copilot_prompt_library.pdf",
        "icon": "🤖",
    },
    "report_template": {
        "title": "Report Template",
        "description": "R Markdown template for data analysis reports",
        "file": "bonus_resources/rendered/report_template.Rmd",
        "icon": "📄",
    },
    "sas_to_r_cheatsheet": {
        "title": "SAS to R Migration Guide",
        "description": "Comprehensive guide for transitioning from SAS to R",
        "file": "bonus_resources/sas_to_r_cheatsheet.pdf",
        "icon": "🔄",
    },
}


@app.route("/")
def index():
    return render_template("index.html", modules=MODULES)


@app.route("/modules")
def modules():
    return render_template("modules.html", modules=MODULES)


@app.route("/module/<int:module_id>")
def module_detail(module_id):
    if module_id not in MODULES:
        return "Module not found", 404
    return render_template(
        f"module{module_id}.html", module=MODULES[module_id], module_id=module_id
    )


@app.route("/bonus")
def bonus():
    return render_template("bonus.html", resources=BONUS_RESOURCES)


@app.route("/contact")
def contact():
    return render_template("contact.html")


@app.route("/download/<path:filename>")
def _search_training_material(filename):
    """Search for file in training_material subdirectories."""
    for root, dirs, files in os.walk("training_material"):
        if filename in files:
            file_path = os.path.join(root, filename)
            return send_file(file_path, as_attachment=True)
    return None


def _find_pdf_alternative(base_name):
    """Try to find PDF version of the file."""
    import re

    # Try to find PDF version first
    pdf_name = f"{base_name}.pdf"
    pdf_path = os.path.join("bonus_resources", pdf_name)
    if os.path.exists(pdf_path):
        return send_file(pdf_path, as_attachment=True)

    # Try numbered PDF version (remove number prefix)
    if re.match(r"^\d+_", base_name):
        base_without_number = re.sub(r"^\d+_", "", base_name)
        pdf_name_no_number = f"{base_without_number}.pdf"
        pdf_path_no_number = os.path.join("bonus_resources", pdf_name_no_number)
        if os.path.exists(pdf_path_no_number):
            return send_file(pdf_path_no_number, as_attachment=True)
    return None


def _find_source_files(base_name):
    """Try to find QMD or RMD source files."""
    import re

    # Try numbered source files first (remove number prefix)
    if re.match(r"^\d+_", base_name):
        base_without_number = re.sub(r"^\d+_", "", base_name)

        # Try QMD source file
        qmd_name = f"{base_without_number}.qmd"
        qmd_path = os.path.join("bonus_resources", "source", qmd_name)
        if os.path.exists(qmd_path):
            return send_file(qmd_path, as_attachment=True)

        # Try RMD source file
        rmd_name = f"{base_without_number}.Rmd"
        rmd_path = os.path.join("bonus_resources", "rendered", rmd_name)
        if os.path.exists(rmd_path):
            return send_file(rmd_path, as_attachment=True)

    # Try original name source files
    qmd_name = f"{base_name}.qmd"
    qmd_path = os.path.join("bonus_resources", "source", qmd_name)
    if os.path.exists(qmd_path):
        return send_file(qmd_path, as_attachment=True)

    rmd_name = f"{base_name}.Rmd"
    rmd_path = os.path.join("bonus_resources", "rendered", rmd_name)
    if os.path.exists(rmd_path):
        return send_file(rmd_path, as_attachment=True)

    return None


def _find_bonus_resources(filename):
    """Search for file in bonus_resources directories."""
    # Check main bonus_resources directory
    bonus_path = os.path.join("bonus_resources", filename)
    if os.path.exists(bonus_path):
        return send_file(bonus_path, as_attachment=True)

    # Check rendered subfolder
    rendered_path = os.path.join("bonus_resources", "rendered", filename)
    if os.path.exists(rendered_path):
        return send_file(rendered_path, as_attachment=True)

    return None


def download_file(filename):
    try:
        # Search for file in training_material subdirectories first
        result = _search_training_material(filename)
        if result:
            return result

        # For HTML files, try to find source files (QMD/RMD) instead of HTML
        if filename.endswith(".html"):
            base_name = os.path.splitext(filename)[0]

            # Try PDF alternative first
            result = _find_pdf_alternative(base_name)
            if result:
                return result

            # Try source files
            result = _find_source_files(base_name)
            if result:
                return result
        else:
            # For non-HTML files, check bonus_resources directory
            result = _find_bonus_resources(filename)
            if result:
                return result

        return (
            f"Download not available for: {filename}. This resource is only available for online viewing.",
            404,
        )
    except FileNotFoundError:
        return "File not found", 404


@app.route("/download_module/<int:module_id>")
def download_module_zip(module_id):
    if module_id not in MODULES:
        return "Module not found", 404

    # Create a ZIP file in memory
    memory_file = io.BytesIO()
    with zipfile.ZipFile(memory_file, "w") as zf:
        module = MODULES[module_id]
        for file_type, filename in module["files"].items():
            if os.path.exists(filename):
                zf.write(filename, f"module{module_id}_{filename}")

    memory_file.seek(0)
    return send_file(
        memory_file,
        mimetype="application/zip",
        as_attachment=True,
        download_name=f"module{module_id}_{module['title'].replace(' ', '_').lower()}.zip",
    )


@app.route("/static_files/<path:filename>")
def serve_static_files(filename):
    """Serve supporting files for rendered HTML documents"""
    try:
        # Clean up path separators for Windows
        clean_filename = filename.replace("/", os.sep)
        if os.path.exists(clean_filename):
            # Determine the correct MIME type based on file extension
            if filename.endswith(".css"):
                return send_file(clean_filename, mimetype="text/css")
            elif filename.endswith(".js"):
                return send_file(clean_filename, mimetype="application/javascript")
            elif filename.endswith(".woff") or filename.endswith(".woff2"):
                return send_file(clean_filename, mimetype="font/woff")
            else:
                return send_file(clean_filename)
        return "File not found", 404
    except Exception as e:
        return f"Error: {str(e)}", 404


@app.route("/toggle_theme", methods=["POST"])
def toggle_theme():
    data = request.get_json()
    theme = data.get("theme", "light")
    return jsonify({"status": "success", "theme": theme})


def fix_html_static_paths(content, html_filename, html_path):
    """Fix relative paths for supporting files in HTML content"""
    import re

    file_base = os.path.splitext(os.path.basename(html_filename))[0]

    # Handle numbered bonus resource files (e.g., 01_R_vs_SAS_CheatSheet.html)
    # Check if the filename starts with digits followed by underscore
    if re.match(r"^\d+_", file_base):
        # Remove the number prefix to find the actual files directory
        base_without_number = re.sub(r"^\d+_", "", file_base)
        files_dir_candidates = [f"{file_base}_files", f"{base_without_number}_files"]
    else:
        files_dir_candidates = [f"{file_base}_files"]

    # Try each possible files directory
    for files_dir in files_dir_candidates:
        if files_dir in content:
            # Get the directory where the HTML file is located
            html_dir = os.path.dirname(html_path).replace("\\", "/")
            # Replace src attributes
            content = re.sub(
                f'src="({files_dir}/[^"]*)"',
                f'src="/static_files/{html_dir}/\\1"',
                content,
            )
            # Replace href attributes
            content = re.sub(
                f'href="({files_dir}/[^"]*)"',
                f'href="/static_files/{html_dir}/\\1"',
                content,
            )
            break  # Stop after first match

    # Fix PDF links - convert relative PDF paths to view routes
    content = re.sub(r'href="([^"]+\.pdf)"', r'href="/view/\1"', content)

    return content


def _find_file_location(filename):
    """Find file path and base directory for a given filename"""
    # Search for file in training_material subdirectories first
    for root, dirs, files in os.walk("training_material"):
        if filename in files:
            file_path = os.path.join(root, filename)
            base_dir = os.path.dirname(file_path)
            return file_path, base_dir

    # If not found, check bonus_resources directory (including rendered and source subfolders)
    # First check rendered subfolder
    rendered_path = os.path.join("bonus_resources", "rendered", filename)
    if os.path.exists(rendered_path):
        return rendered_path, "bonus_resources/rendered"

    # Then check source subfolder
    source_path = os.path.join("bonus_resources", "source", filename)
    if os.path.exists(source_path):
        return source_path, "bonus_resources/source"

    # Finally check main bonus_resources directory
    bonus_path = os.path.join("bonus_resources", filename)
    if os.path.exists(bonus_path):
        return bonus_path, "bonus_resources"

    return None, None


def _find_html_for_qmd(html_filename, base_dir):
    """Find corresponding HTML file for QMD file"""
    # Search for HTML file recursively in training_material
    for root, dirs, files in os.walk("training_material"):
        if html_filename in files:
            return os.path.join(root, html_filename)

    # First check rendered subfolder
    bonus_rendered_path = os.path.join("bonus_resources", "rendered", html_filename)
    if os.path.exists(bonus_rendered_path):
        return bonus_rendered_path

    # For files from source directory, try looking for numbered HTML files in rendered
    if base_dir == "bonus_resources/source":
        for rendered_file in os.listdir("bonus_resources/rendered"):
            if (
                rendered_file.endswith(".html")
                and html_filename.replace(".html", "") in rendered_file
            ):
                return os.path.join("bonus_resources", "rendered", rendered_file)

    # If still not found, check main bonus_resources directory
    bonus_html_path = os.path.join("bonus_resources", html_filename)
    if os.path.exists(bonus_html_path):
        return bonus_html_path

    return None


def _serve_html_content(html_path, html_filename):
    """Read and serve HTML content with fixed paths"""
    with open(html_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Fix relative paths for supporting files
    content = fix_html_static_paths(content, html_filename, html_path)

    return content, 200, {"Content-Type": "text/html"}


def _serve_source_content(file_path, filename, file_type, message):
    """Serve source file with syntax highlighting"""
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    return render_template(
        "file_viewer.html",
        filename=filename,
        content=content,
        file_type=file_type,
        message=message,
    )


def _handle_file_by_type(filename, file_path, base_dir):
    """Handle file serving based on file type"""
    if filename.endswith(".pdf"):
        return send_file(file_path, mimetype="application/pdf")

    elif filename.endswith(".qmd"):
        html_filename = filename.replace(".qmd", ".html")
        html_path = _find_html_for_qmd(html_filename, base_dir)

        if html_path:
            return _serve_html_content(html_path, html_filename)
        else:
            return _serve_source_content(
                file_path,
                filename,
                "markdown",
                "Showing QMD source code (rendered HTML not available)",
            )

    elif filename.endswith(".Rmd"):
        html_filename = filename.replace(".Rmd", ".html")
        html_path = os.path.join(base_dir, html_filename)

        if os.path.exists(html_path):
            return _serve_html_content(html_path, html_filename)
        else:
            return _serve_source_content(
                file_path,
                filename,
                "markdown",
                "Showing RMD source code (rendered HTML not available)",
            )

    elif filename.endswith(".R"):
        return _serve_source_content(file_path, filename, "r", "R Script")

    elif filename.endswith((".html", ".htm")):
        return _serve_html_content(file_path, filename)

    else:
        return _serve_source_content(
            file_path, filename, "text", f"Viewing: {os.path.basename(filename)}"
        )


@app.route("/view/<path:filename>")
def view_file(filename):
    """View content of various file types with proper rendering"""
    try:
        file_path, base_dir = _find_file_location(filename)
        if not file_path:
            return f"File not found: {filename}", 404

        return _handle_file_by_type(filename, file_path, base_dir)

    except FileNotFoundError:
        return f"File not found: {filename}", 404
    except Exception as e:
        return f"Error viewing file: {str(e)}", 500


@app.route("/view_qmd/<path:filename>")
def view_qmd_content(filename):
    """Serve the actual Quarto file content"""
    try:
        with open(filename, "r", encoding="utf-8") as f:
            content = f.read()
        return content, 200, {"Content-Type": "text/plain"}
    except FileNotFoundError:
        return "File not found", 404
    except Exception as e:
        return f"Error reading file: {str(e)}", 500


def _get_mime_type(filepath):
    """Get MIME type based on file extension"""
    mime_type_map = {
        ".css": "text/css",
        ".js": "application/javascript",
        ".woff": "font/woff",
        ".woff2": "font/woff2",
        ".ttf": "font/ttf",
        ".eot": "application/vnd.ms-fontobject",
        ".svg": "image/svg+xml",
    }

    for ext, mime_type in mime_type_map.items():
        if filepath.endswith(ext):
            return mime_type

    return "text/plain"


@app.route("/view_files/<path:filepath>")
def serve_view_files(filepath):
    """Serve supporting files for HTML views (CSS, JS, etc.)"""
    try:
        full_path = os.path.join("training_material", filepath)
        mime_type = _get_mime_type(filepath)
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
    c.drawCentredString(width / 2, height - 1.5 * inch, "Certificate of Completion")
    c.setFont("Helvetica", 14)
    c.drawCentredString(width / 2, height - 2.1 * inch, "This certifies that")
    c.setFont("Helvetica-Bold", 18)
    c.drawCentredString(width / 2, height - 2.6 * inch, f"{name} {surname}")
    c.setFont("Helvetica", 14)
    c.drawCentredString(
        width / 2, height - 3.1 * inch, "has successfully completed the course:"
    )
    c.setFont("Helvetica-Bold", 16)
    c.drawCentredString(
        width / 2, height - 3.6 * inch, "TransitionR: Clinical Programming in R"
    )
    c.setFont("Helvetica", 12)
    c.drawCentredString(
        width / 2, height - 4.1 * inch, f"Date of Completion: {date_str}"
    )
    c.setFont("Helvetica-Bold", 13)
    c.drawString(1.2 * inch, height - 4.8 * inch, "Modules Completed:")
    c.setFont("Helvetica", 12)
    y = height - 5.2 * inch
    for i, m in enumerate(modules, 1):
        c.drawString(1.4 * inch, y, f"{i}. {m}")
        y -= 0.3 * inch
    c.showPage()
    c.save()
    buffer.seek(0)
    return buffer


# --- Certificate Download Route ---
@app.route("/download_certificate", methods=["POST"])
def download_certificate():
    name = request.form.get("name", "").strip()
    surname = request.form.get("surname", "").strip()
    if not name or not surname:
        flash("Name and surname are required.", "danger")
        return redirect(url_for("modules"))

    date_str = datetime.now().strftime("%B %d, %Y")
    module_titles = [MODULES[m]["title"] for m in sorted(MODULES.keys())]
    pdf_buffer = generate_certificate_pdf(name, surname, date_str, module_titles)

    # Save completer information to file (automatic logging)
    completion_datetime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    timestamp_iso = datetime.now().strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"

    completer_data = f"""=== CERTIFICATE {completion_datetime} ===
Completer: {name} {surname}
Method: Downloaded
Timestamp: {timestamp_iso}
==============================

"""

    try:
        with open("data/course_completers.txt", "a", encoding="utf-8") as f:
            f.write(completer_data)
    except Exception as file_error:
        print(f"Warning: Could not save completer data: {file_error}")

    return send_file(
        pdf_buffer,
        as_attachment=True,
        download_name=f"Certificate_{name}_{surname}.pdf",
        mimetype="application/pdf",
    )


# --- Contact Form Route (File Storage) ---
@app.route("/send_contact_message", methods=["POST"])
def send_contact_message():
    try:
        # Get form data
        first_name = request.form.get("firstName", "").strip()
        last_name = request.form.get("lastName", "").strip()
        email = request.form.get("email", "").strip()
        subject = request.form.get("subject", "").strip()
        message = request.form.get("message", "").strip()

        # Validate required fields
        if not all([first_name, last_name, email, subject, message]):
            flash("All fields are required.", "danger")
            return redirect(url_for("contact"))

        # Create data directory if it doesn't exist
        os.makedirs("data", exist_ok=True)

        # Store message in file
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        # Append to messages file
        with open("data/contact_messages.txt", "a", encoding="utf-8") as f:
            f.write(f"=== MESSAGE {timestamp} ===\n")
            f.write(f"Name: {first_name} {last_name}\n")
            f.write(f"Email: {email}\n")
            f.write(f"Subject: {subject}\n")
            f.write(f"Message:\n{message}\n")
            f.write(f"{'=' * 50}\n\n")

        flash(
            "Your message has been sent successfully! We'll get back to you soon.",
            "success",
        )

    except Exception as e:
        flash(f"Error sending message: {str(e)}. Please try again.", "danger")

    return redirect(url_for("contact"))


# --- Simple Rating Route ---
@app.route("/submit_simple_rating", methods=["POST"])
def submit_simple_rating():
    try:
        # Get JSON data
        data = request.get_json()
        rating = data.get("rating")
        feedback = data.get("feedback", "").strip()
        timestamp = data.get("timestamp")
        is_update = data.get("isUpdate", False)

        # Validate required fields
        if not rating:
            return jsonify({"success": False, "message": "Rating is required."})

        # Create data directory if it doesn't exist
        os.makedirs("data", exist_ok=True)

        # Store rating in file
        formatted_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

        if is_update and feedback:
            # This is a text feedback update - remove duplicate rating and keep only the feedback version
            try:
                # Read existing content
                with open("data/course_ratings.txt", "r", encoding="utf-8") as f:
                    content = f.read()

                # Split content into entries
                entries = content.split("=== RATING")

                # Find and remove the most recent rating entry with the same rating value
                updated_content = entries[0]  # Keep header

                for i in range(1, len(entries)):
                    entry = "=== RATING" + entries[i]
                    # Check if this entry matches our rating and is recent (no feedback)
                    if (
                        f"Rating: {rating}/5 stars\n" in entry
                        and "Feedback:" not in entry
                        and len(entries) - i <= 2
                    ):  # Only check last 2 entries
                        # Skip this entry (don't add it back)
                        continue
                    else:
                        updated_content += entry

                # Write back the cleaned content
                with open("data/course_ratings.txt", "w", encoding="utf-8") as f:
                    f.write(updated_content)

            except (FileNotFoundError, Exception):
                pass  # If any error, just continue with append

            # Append the feedback update
            with open("data/course_ratings.txt", "a", encoding="utf-8") as f:
                f.write(f"=== FEEDBACK UPDATE {formatted_time} ===\n")
                f.write(f"Rating: {rating}/5 stars (with additional feedback)\n")
                f.write(f"Feedback: {feedback}\n")
                f.write(f"Timestamp: {timestamp}\n")
                f.write(f"{'=' * 30}\n\n")
        else:
            # Regular rating submission
            with open("data/course_ratings.txt", "a", encoding="utf-8") as f:
                f.write(f"=== RATING {formatted_time} ===\n")
                f.write(f"Rating: {rating}/5 stars\n")
                if feedback:
                    f.write(f"Feedback: {feedback}\n")
                f.write(f"Timestamp: {timestamp}\n")
                f.write(f"{'=' * 30}\n\n")

        return jsonify({"success": True, "message": "Thank you for your rating!"})

    except Exception as e:
        return jsonify(
            {"success": False, "message": f"Error submitting rating: {str(e)}"}
        )


# --- Admin Route to View Data ---
@app.route("/admin/data")
def view_admin_data():
    """Simple admin page to view contact messages and feedback"""
    data = {"messages": [], "feedback": []}

    # Read contact messages
    try:
        if os.path.exists("data/contact_messages.txt"):
            with open("data/contact_messages.txt", "r", encoding="utf-8") as f:
                content = f.read()
                data["messages_raw"] = content
    except Exception as e:
        data["messages_error"] = str(e)

    # Read ratings
    try:
        if os.path.exists("data/course_ratings.txt"):
            with open("data/course_ratings.txt", "r", encoding="utf-8") as f:
                content = f.read()
                data["ratings_raw"] = content
    except Exception as e:
        data["ratings_error"] = str(e)

    return render_template("admin_data.html", data=data)


# --- Admin Route to View Course Completers ---
@app.route("/admin/completers")
def view_completers():
    """Admin route to view course completers data."""
    try:
        with open("data/course_completers.txt", "r", encoding="utf-8") as f:
            content = f.read()
        return f"<pre>{content}</pre>", 200, {"Content-Type": "text/html"}
    except FileNotFoundError:
        return "No course completers data found.", 404
    except Exception as e:
        return f"Error reading completers data: {str(e)}", 500


if __name__ == "__main__":
    debug_mode = os.getenv("FLASK_DEBUG", "True").lower() == "true"
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 5000))
    app.run(debug=debug_mode, host=host, port=port)
