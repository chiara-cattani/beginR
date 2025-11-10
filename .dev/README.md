# Development Configuration Files

This directory contains all development and CI/CD related configuration files.

## Files in this directory:

- `pytest.ini` - Test configuration
- `requirements-dev.txt` - Development dependencies
- `.flake8` - Linting configuration  
- `pyproject.toml` - Black formatter configuration
- `.isort.cfg` - Import sorting configuration
- `.pre-commit-config.yaml` - Pre-commit hooks
- `tests/` - Test suite

## Usage:

Install development dependencies:
```bash
pip install -r .dev/requirements-dev.txt
```

Run tests:
```bash
pytest .dev/tests/
```

Format code:
```bash
black .
isort .
```

Run linting:
```bash
flake8 .
```

For detailed CI/CD documentation, see `docs/CI-CD.md`.