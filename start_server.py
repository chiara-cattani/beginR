#!/usr/bin/env python3
"""
Robust Flask Server Starter for TransitionR Course
This script ensures the server stays running and handles errors gracefully.
"""

import os
import subprocess
import sys
import time
from pathlib import Path


def setup_environment():
    """Setup working directory and environment variables"""
    script_dir = Path(__file__).parent.absolute()
    os.chdir(script_dir)

    print("🚀 Starting TransitionR Course Server...")
    print(f"📁 Working directory: {script_dir}")
    print("🌐 Server will be available at: http://127.0.0.1:5000")
    print("⚠️  To stop the server, press Ctrl+C")
    print("-" * 50)

    env = os.environ.copy()
    env["FLASK_APP"] = "app.py"
    env["FLASK_ENV"] = "development"
    env["FLASK_DEBUG"] = "1"
    env["PYTHONUNBUFFERED"] = "1"

    return env


def monitor_process(process):
    """Monitor the Flask server process"""
    while True:
        output = process.stdout.readline()
        if output == "" and process.poll() is not None:
            break
        if output:
            print(output.strip())
            if "Running on http://127.0.0.1:5000" in output:
                print("✅ Server started successfully!")


def handle_process_result(process, retry_count, max_retries):
    """Handle the result of a server process attempt"""
    return_code = process.poll()
    print(f"⚠️  Server stopped with return code: {return_code}")

    if return_code == 0:
        print("✅ Server stopped normally.")
        return True, retry_count
    else:
        retry_count += 1
        if retry_count < max_retries:
            print("🔄 Retrying in 3 seconds...")
            time.sleep(3)
        else:
            print("❌ Max retries reached. Please check for errors.")
        return False, retry_count


def main():
    env = setup_environment()
    retry_count = 0
    max_retries = 3

    while retry_count < max_retries:
        try:
            print(
                f"🔄 Starting Flask server (attempt {retry_count + 1}/{max_retries})..."
            )

            process = subprocess.Popen(
                [sys.executable, "app.py"],
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                universal_newlines=True,
                bufsize=1,
            )

            monitor_process(process)
            should_break, retry_count = handle_process_result(
                process, retry_count, max_retries
            )

            if should_break:
                break

        except KeyboardInterrupt:
            print("\n🛑 Server stopped by user.")
            if "process" in locals():
                process.terminate()
            break
        except Exception as e:
            print(f"❌ Error starting server: {e}")
            retry_count += 1
            if retry_count < max_retries:
                print("🔄 Retrying in 3 seconds...")
                time.sleep(3)


if __name__ == "__main__":
    main()
