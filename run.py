#!/usr/bin/env python3
"""
ClinicalRTransition - Flask Application Startup Script
Chiara Internal Training Portal
"""

from app import app

if __name__ == '__main__':
    print("🚀 Starting ClinicalRTransition...")
    print("📚 Chiara Internal Training Portal")
    print("🌐 Access the application at: http://localhost:5000")
    print("⏹️  Press Ctrl+C to stop the server")
    print("-" * 50)
    
    try:
        app.run(
            host='0.0.0.0',
            port=5000,
            debug=True,
            use_reloader=True
        )
    except KeyboardInterrupt:
        print("\n👋 ClinicalRTransition stopped. Goodbye!")
    except Exception as e:
        print(f"❌ Error starting application: {e}") 