"""
Test configuration and fixtures for the beginR application.
"""
import pytest
import os
import tempfile
from app import app

@pytest.fixture
def client():
    """Create a test client for the Flask application."""
    # Create a temporary file for testing database
    db_fd, app.config['DATABASE'] = tempfile.mkstemp()
    app.config['TESTING'] = True
    app.config['WTF_CSRF_ENABLED'] = False
    
    with app.test_client() as client:
        with app.app_context():
            yield client
    
    os.close(db_fd)
    os.unlink(app.config['DATABASE'])

@pytest.fixture
def runner():
    """Create a test runner for CLI commands."""
    return app.test_cli_runner()