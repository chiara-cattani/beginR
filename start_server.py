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


def main():
    # Ensure we're in the right directory
    script_dir = Path(__file__).parent.absolute()
    os.chdir(script_dir)

    print("🚀 Starting TransitionR Course Server...")
    print(f"📁 Working directory: {script_dir}")
    print("🌐 Server will be available at: http://127.0.0.1:5000")
    print("⚠️  To stop the server, press Ctrl+C")
    print("-" * 50)

    # Set environment variables for better stability
    env = os.environ.copy()
    env["FLASK_APP"] = "app.py"
    env["FLASK_ENV"] = "development"
    env["FLASK_DEBUG"] = "1"
    env["PYTHONUNBUFFERED"] = "1"  # Ensure immediate output

    retry_count = 0
    max_retries = 3

    while retry_count < max_retries:
        try:
            print(
                f"🔄 Starting Flask server (attempt {retry_count + 1}/{max_retries})..."
            )

            # Start the Flask server
            process = subprocess.Popen(
                [sys.executable, "app.py"],
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                universal_newlines=True,
                bufsize=1,
            )

            # Monitor the process
            while True:
                output = process.stdout.readline()
                if output == "" and process.poll() is not None:
                    break
                if output:
                    print(output.strip())

                    # Check if server started successfully
                    if "Running on http://127.0.0.1:5000" in output:
                        print("✅ Server started successfully!")

            # If we get here, the process ended
            return_code = process.poll()
            print(f"⚠️  Server stopped with return code: {return_code}")

            if return_code == 0:
                print("✅ Server stopped normally.")
                break
            else:
                retry_count += 1
                if retry_count < max_retries:
                    print("🔄 Retrying in 3 seconds...")
                    time.sleep(3)
                else:
                    print("❌ Max retries reached. Please check for errors.")

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
