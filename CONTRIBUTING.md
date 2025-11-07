# Contributing to beginR

Thank you for your interest in contributing to the beginR Clinical R Training platform!

## Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/chiara-cattani/beginR.git
   cd beginR
   ```

2. **Create a virtual environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the application:**
   ```bash
   python app.py
   ```

## Project Structure

```
beginR/
├── app.py                 # Main Flask application
├── templates/             # HTML templates
├── static/               # CSS, JavaScript, assets
├── training_material/    # Course modules and exercises
├── bonus_resources/      # Additional learning resources
└── requirements.txt      # Python dependencies
```

## Code Style

- Follow PEP 8 for Python code
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and small

## Adding New Modules

1. Create module directory in `training_material/`
2. Add module configuration to `MODULES` dictionary in `app.py`
3. Include necessary files: theory, exercises, solutions
4. Update progress tracking if needed

## Testing

Before submitting changes:
- Test all core functionality (navigation, downloads, progress tracking)
- Check responsiveness on different screen sizes
- Verify theme toggle functionality
- Test music player dropdown

## Submitting Changes

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and test thoroughly
4. Commit with descriptive messages
5. Push to your fork and submit a pull request

## Issues and Support

- Report bugs via GitHub Issues
- Include steps to reproduce
- Specify your environment (OS, Python version, browser)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.