# Deployment Guide for beginR - Clinical R Training

## Prerequisites

Your project is already properly configured for deployment with:
- ✅ `app.py` - Flask application entry point
- ✅ `requirements.txt` - Python dependencies with specific versions

## Deployment Options

### 1. Local Development
```bash
# Install dependencies
pip install -r requirements.txt

# Run the application
python app.py
```

### 2. Heroku Deployment
1. Create a `Procfile` in your root directory:
```
web: python app.py
```

2. Install Heroku CLI and deploy:
```bash
heroku create your-app-name
git add .
git commit -m "Initial deployment"
git push heroku main
```

### 3. PythonAnywhere Deployment
1. Upload your files to PythonAnywhere
2. Create a virtual environment
3. Install dependencies: `pip install -r requirements.txt`
4. Configure WSGI file to point to your app
5. Set up static files and templates

### 4. Railway Deployment
1. Connect your GitHub repository to Railway
2. Railway will automatically detect Flask and deploy
3. Set environment variables if needed

### 5. Render Deployment
1. Connect your GitHub repository to Render
2. Set build command: `pip install -r requirements.txt`
3. Set start command: `python app.py`

## Environment Variables

For production, consider setting these environment variables:
- `SECRET_KEY` - Change from the default value
- `MAIL_SERVER` - Your SMTP server
- `MAIL_USERNAME` - Your email username
- `MAIL_PASSWORD` - Your email password

## File Structure
```
beginR/
├── app.py                 # ✅ Flask application entry point
├── run.py                # ✅ Alternative startup script
├── requirements.txt       # ✅ Python dependencies
├── start_app.bat         # ✅ Windows launcher
├── start_app.sh          # ✅ Unix/Linux launcher
├── static/               # ✅ Static files (CSS, JS)
│   ├── css/styles.css    # ✅ Custom styling with music player
│   └── js/main.js        # ✅ JavaScript with music functionality
├── templates/            # ✅ HTML templates with music player
├── training_material/    # ✅ Course modules and exercises
├── bonus_resources/      # ✅ Additional learning resources
├── DEPLOYMENT_GUIDE.md   # ✅ This guide
└── README.md            # ✅ Project documentation
```

## Testing Deployment
After deployment, test these features:
- ✅ Homepage loads correctly
- ✅ Module pages are accessible
- ✅ File downloads work (QMD source files prioritized)
- ✅ Music player dropdown functionality
- ✅ Theme toggle (light/dark mode)
- ✅ Progress tracking persistence
- ✅ Certificate generation works
- ✅ Email functionality (if configured)

## Security Notes
- Change the default `SECRET_KEY` in production
- Configure proper email settings for certificate emails
- Ensure all file paths are secure
- Consider adding rate limiting for downloads

Your project is ready for deployment! 🚀 