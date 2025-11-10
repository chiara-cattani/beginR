# CI/CD Pipeline Documentation

This repository includes a comprehensive CI/CD pipeline using GitHub Actions to ensure code quality, security, and reliable deployments.

## � **AUTOMATION STATUS: AUTO-MERGE ENABLED**

The repository now includes automated PR approval and merging workflows. See the [Auto-Merge Configuration](#auto-merge-configuration) section below for details.

## �🔧 Pipeline Components

### 1. **Continuous Integration (CI)**
- **Code Quality**: Black formatting, isort import sorting, flake8 linting
- **Security Scanning**: Bandit for Python security issues, Safety for vulnerability checks
- **Testing**: Pytest with coverage reporting
- **Multi-Python Support**: Tests against Python 3.9, 3.10, and 3.11
- **Frontend Validation**: HTML, CSS, and JavaScript linting
- **Pre-commit Hooks**: Automatic formatting and linting before commits

### 2. **Pull Request Checks**
- **Smart Filtering**: Only runs relevant checks based on changed files
- **Automated Comments**: Bot comments with check results
- **Concurrency Control**: Cancels outdated runs to save resources
- **Size Monitoring**: Tracks large files and reports in PR summary

### 3. **Deployment Pipeline**
- **Staging Deployment**: Automatic deployment to staging on main branch
- **Production Deployment**: Manual approval or tag-based deployment
- **Build Artifacts**: Versioned deployment packages
- **Health Checks**: Post-deployment validation
- **GitHub Releases**: Automatic release creation for tags

## 🚀 Workflows

### Main CI/CD (`ci-cd.yml`)
**Triggers**: Push to main/dev, Pull Requests
**Features**:
- Multi-version Python testing
- Code formatting and linting
- Security vulnerability scanning
- Frontend asset validation
- Deployment artifact creation
- Coverage reporting with Codecov

### Pull Request Checks (`pr-checks.yml`)
**Triggers**: Pull Request opened/updated
**Features**:
- Path-based filtering (only test what changed)
- Parallel execution for speed
- Automated PR status comments
- File size monitoring
- Concurrent run cancellation

### Deployment (`deploy.yml`)
**Triggers**: Push to main, tags, manual dispatch
**Features**:
- Environment-specific deployments
- Build versioning and artifacts
- Health checks and validation
- GitHub release automation
- Production deployment approval

## 📋 Setup Requirements

### Required Secrets
Add these to your GitHub repository secrets:

```bash
# Optional: For enhanced features
CODECOV_TOKEN=your_codecov_token
```

### Required Permissions
The workflows need these GitHub permissions:
- **Contents**: read/write (for releases)
- **Issues**: write (for PR comments)
- **Pull Requests**: write (for status checks)
- **Actions**: read (for workflow access)

## 🛠️ Local Development

### Install Development Dependencies
```bash
pip install -r requirements-dev.txt
```

### Set Up Pre-commit Hooks
```bash
pre-commit install
```

### Run Tests Locally
```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=. --cov-report=html

# Run specific test file
pytest tests/test_app.py
```

### Code Quality Checks
```bash
# Format code
black .
isort .

# Lint code
flake8 .

# Security scan
bandit -r .
safety check
```

## 📊 Quality Gates

All deployments must pass these quality gates:

### ✅ **Required Checks**
- [ ] All tests pass
- [ ] Code coverage > 80%
- [ ] No security vulnerabilities
- [ ] Code formatted with Black
- [ ] Imports sorted with isort
- [ ] No linting errors (flake8)
- [ ] Frontend assets valid

### 🔒 **Security Requirements**
- [ ] Bandit security scan passes
- [ ] Safety vulnerability check passes
- [ ] No hardcoded secrets detected
- [ ] Dependencies up to date

### 📱 **Frontend Validation**
- [ ] HTML validation passes
- [ ] CSS linting passes
- [ ] JavaScript linting passes
- [ ] No large binary files added

## 🌍 Deployment Environments

### **Staging**
- **URL**: `https://staging.beginr.app` (configure your staging URL)
- **Auto-deploy**: On push to `main` branch
- **Purpose**: Testing and validation before production

### **Production**
- **URL**: `https://beginr.app` (configure your production URL)
- **Deploy**: Manual approval or git tags (`v*`)
- **Purpose**: Live application for end users

## 🔍 Monitoring and Reporting

### **Coverage Reports**
- Automated coverage reporting via Codecov
- HTML reports generated in `htmlcov/`
- Coverage badge available for README

### **Security Reports**
- Bandit security scan results
- Safety vulnerability reports
- Trivy filesystem scanning

### **Performance Tracking**
- Build time monitoring
- Deployment success rates
- Test execution metrics

## 🚨 Troubleshooting

### Common Issues

**Tests Failing**: Check test logs and ensure all dependencies are installed
```bash
pip install -r requirements.txt -r requirements-dev.txt
```

**Linting Errors**: Run local formatting tools
```bash
black . && isort . && flake8 .
```

**Security Failures**: Review bandit/safety reports and fix flagged issues
```bash
bandit -r . && safety check
```

**Frontend Issues**: Validate HTML/CSS/JS manually
```bash
htmlhint templates/*.html
stylelint static/css/*.css
jshint static/js/*.js
```

### Getting Help
- Check GitHub Actions logs for detailed error messages
- Review workflow files in `.github/workflows/`
- Ensure all required secrets are configured
- Verify repository permissions are correct

---

## 🤖 Auto-Merge Configuration

### Safe Auto-Merge (`auto-merge.yml`)
**Triggers**: All PRs to main/dev branches
**Behavior**:
- ✅ Auto-approves PRs from trusted authors (`chiara-cattani`, `dependabot[bot]`, `renovate[bot]`)
- ⏳ Waits for all CI checks to pass before merging
- 🔄 Enables auto-merge with squash commits
- 📝 Adds informative comments to PRs

**Trusted Authors**: Only these users get auto-approval:
- `chiara-cattani` (repository owner)
- `dependabot[bot]` (dependency updates)
- `renovate[bot]` (automated maintenance)

### Unsafe Auto-Merge (`auto-allow-everything-unsafe.yml`)
**⚠️ DANGER ZONE - USE WITH EXTREME CAUTION**

**Triggers**: PRs to dev branch from trusted users OR PRs with `[auto-merge]` in title
**Behavior**:
- 🚨 **BYPASSES ALL SAFETY CHECKS**
- 🔥 Merges immediately without waiting for CI
- ⚡ No review requirements
- 💥 **ONLY USE FOR DEVELOPMENT/TESTING**

### Pre-commit Hooks
Automatic code formatting before commits:
```bash
# Install pre-commit
pip install pre-commit
pre-commit install

# Manual run
pre-commit run --all-files
```

### Local Testing Commands
Ensure your code passes CI before pushing:
```bash
# Run all checks that CI runs
python -m black --check .
python -m isort --check-only .
python -m flake8 .
python -m bandit -r .
python -m safety check
python -m pytest --cov=. --cov-report=xml

# Auto-fix formatting issues
python -m black .
python -m isort .
```

### Security Notes
- 🔒 Auto-merge only works for trusted repository collaborators
- 🛡️ External contributors always require manual review
- 🔐 Workflows require appropriate GitHub permissions
- ⚠️ Never enable unsafe auto-merge on production branches

---

## 📈 Pipeline Status

[![CI/CD Pipeline](https://github.com/chiara-cattani/beginR/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/chiara-cattani/beginR/actions/workflows/ci-cd.yml)
[![Deploy](https://github.com/chiara-cattani/beginR/actions/workflows/deploy.yml/badge.svg)](https://github.com/chiara-cattani/beginR/actions/workflows/deploy.yml)
[![codecov](https://codecov.io/gh/chiara-cattani/beginR/branch/main/graph/badge.svg)](https://codecov.io/gh/chiara-cattani/beginR)

*This CI/CD system ensures reliable, secure, and high-quality deployments for the beginR learning platform.*
