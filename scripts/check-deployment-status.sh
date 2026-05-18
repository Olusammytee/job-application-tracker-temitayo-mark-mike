#!/usr/bin/env bash
set -euo pipefail

echo "Checking deployment status..."

check_file() {
  local path="$1"
  if [[ -f "${path}" ]]; then
    echo "[PASS] ${path}"
  else
    echo "[FAIL] ${path}"
  fi
}

echo
echo "Checking local files..."
check_file force-app/main/default/applications/Job_Application_Tracker.app-meta.xml
check_file force-app/main/default/permissionsets/Job_Application_Manager.permissionset-meta.xml
check_file force-app/main/default/appMenus/Job_Application_Tracker_UtilityBar.appMenu-meta.xml

echo
echo "Checking Salesforce connection..."
sf org display --json >/dev/null

if [[ -f scripts/deep-app-investigation.apex ]]; then
  echo
  echo "Running deep investigation..."
  sf apex run --file scripts/deep-app-investigation.apex
fi

echo
echo "Checking recent deployment status..."
sf project deploy report || true

echo
echo "Attempting fresh deployment of app and permission sets..."
sf project deploy start --source-dir force-app/main/default/applications --wait 10
sf project deploy start --source-dir force-app/main/default/permissionsets --wait 10

echo
echo "Assigning Job_Application_Manager permission set..."
sf org assign permset --name Job_Application_Manager || true

cat <<'EOF'

Manual verification:
1. Open Salesforce with `sf org open`.
2. Confirm the URL uses Lightning Experience.
3. Check Setup > Apps > App Manager for "Job Application Tracker".
4. Check App Launcher for "Job Application Tracker".
5. Check Permission Sets > Job Application Manager > Manage Assignments.
EOF
