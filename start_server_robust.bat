@echo off
echo 🚀 Starting TransitionR Course Server...
echo 🌐 Server will be available at: http://127.0.0.1:5000
echo ⚠️  To stop the server, press Ctrl+C
echo -------------------------------------------------
cd /d "%~dp0"
python start_server.py
pause
