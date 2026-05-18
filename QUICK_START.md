# Quick Start Commands for Capstone Project

# These commands work from macOS, Linux, Windows PowerShell, Git Bash, WSL, or VS Code Terminal.

# 1. Clone and enter the project
git clone https://github.com/Olusammytee/job-application-tracker-temitayo-mark-mike.git
cd job-application-tracker-temitayo-mark-mike

# 2. Open VS Code
code .

# 3. Install project dependencies
npm install

# 4. Authorize your capstone org (will open browser)
npm run org:login
# Use credentials from private-learning/org-configuration/capstone-org-credentials.md

# 5. Deploy Job Application metadata and assign permissions
npm run setup:complete

# 6. Verify connection
npm run org:status

# 7. Open Salesforce to test
npm run org:open

# 8. Create a feature branch for your next Linear issue
git checkout -b your-name/issue-id-short-description

# SUCCESS! 🎉 Your capstone project is ready for development!

# Note: All org credentials are stored privately in private-learning/org-configuration/
# This directory is excluded from Git commits for security

# Optional helper scripts:
# - macOS/Linux/WSL: use scripts/*.sh
# - Windows PowerShell: use scripts/*.ps1
