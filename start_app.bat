@echo off
echo ========================================
echo    ClinicalRTransition
echo    Chiara Internal Training Portal
echo ========================================
echo.

echo Installing dependencies...
pip install -r requirements.txt

echo.
echo Starting the application...
echo Access the portal at: http://localhost:5000
echo Press Ctrl+C to stop the server
echo.

python run.py

pause 