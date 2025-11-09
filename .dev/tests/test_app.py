"""
Test cases for basic Flask application functionality.
"""

import json

from app import app


class TestBasicRoutes:
    """Test basic route functionality."""

    def test_index_page(self, client):
        """Test that the index page loads successfully."""
        response = client.get("/")
        assert response.status_code == 200
        assert b"BeginR" in response.data or b"R Programming" in response.data

    def test_modules_page(self, client):
        """Test that the modules page loads successfully."""
        response = client.get("/modules")
        assert response.status_code == 200
        assert b"Module" in response.data

    def test_contact_page(self, client):
        """Test that the contact page loads successfully."""
        response = client.get("/contact")
        assert response.status_code == 200
        assert b"Contact" in response.data or b"FAQ" in response.data

    def test_bonus_page(self, client):
        """Test that the bonus page loads successfully."""
        response = client.get("/bonus")
        assert response.status_code == 200


class TestModuleRoutes:
    """Test module-specific routes."""

    def test_module_pages(self, client):
        """Test that individual module pages load successfully."""
        for module_id in range(1, 8):  # Test modules 1-7
            response = client.get(f"/module/{module_id}")
            assert response.status_code == 200


class TestAPIEndpoints:
    """Test API endpoints functionality."""

    def test_contact_form_submission(self, client):
        """Test contact form submission."""
        form_data = {
            "firstName": "Test",
            "lastName": "User",
            "email": "test@example.com",
            "subject": "technical",
            "message": "This is a test message",
        }
        response = client.post(
            "/send_contact_message", data=form_data, follow_redirects=True
        )
        assert response.status_code == 200

    def test_rating_submission(self, client):
        """Test rating submission endpoint."""
        rating_data = {
            "rating": 5,
            "feedback": "Great course!",
            "timestamp": "2025-11-09T12:00:00.000Z",
        }
        response = client.post(
            "/submit_simple_rating",
            data=json.dumps(rating_data),
            content_type="application/json",
        )
        assert response.status_code == 200
        data = json.loads(response.data)
        assert data.get("success") is True


class TestFileDownloads:
    """Test file download functionality."""

    def test_download_nonexistent_file(self, client):
        """Test downloading a non-existent file returns 404."""
        response = client.get("/download/nonexistent.pdf")
        assert response.status_code == 404


class TestSecurity:
    """Test basic security measures."""

    def test_sql_injection_protection(self, client):
        """Test that SQL injection attempts are handled safely."""
        malicious_input = "'; DROP TABLE users; --"
        form_data = {
            "firstName": malicious_input,
            "lastName": "User",
            "email": "test@example.com",
            "subject": "technical",
            "message": "Test message",
        }
        response = client.post(
            "/send_contact_message", data=form_data, follow_redirects=True
        )
        # Should not crash and should return a valid response
        assert response.status_code in [200, 302]

    def test_xss_protection(self, client):
        """Test that XSS attempts are handled safely."""
        xss_payload = '<script>alert("xss")</script>'
        rating_data = {
            "rating": 5,
            "feedback": xss_payload,
            "timestamp": "2025-11-09T12:00:00.000Z",
        }
        response = client.post(
            "/submit_simple_rating",
            data=json.dumps(rating_data),
            content_type="application/json",
        )
        assert response.status_code == 200
