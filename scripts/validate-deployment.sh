#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: scripts/validate-deployment.sh <target-org>"
  exit 1
fi

TARGET_ORG="$1"
failures=0

check_query() {
  local label="$1"
  local query="$2"
  if sf data query --target-org "${TARGET_ORG}" --query "${query}" --json >/dev/null; then
    echo "[PASS] ${label}"
  else
    echo "[FAIL] ${label}"
    failures=$((failures + 1))
  fi
}

check_file() {
  local path="$1"
  if [[ -f "${path}" ]]; then
    echo "[PASS] ${path}"
  else
    echo "[FAIL] ${path}"
    failures=$((failures + 1))
  fi
}

echo "Validating Interview Feedback Tracker deployment in org: ${TARGET_ORG}"
sf config set "target-org=${TARGET_ORG}" >/dev/null

echo
echo "Validating custom objects..."
for object_name in Interview_Feedback__c Feedback_Template__c Competency_Rating__c Feedback_Share__c Interview_Feedback_Audit__c; do
  check_query "${object_name} is queryable" "SELECT COUNT() FROM ${object_name}"
done

echo
echo "Validating Apex classes..."
for class_name in InterviewFeedbackService FeedbackAnalyticsService FeedbackSharingService FeedbackTemplateService FeedbackSecurityService InterviewFeedbackTestDataFactory; do
  check_query "${class_name} class exists" "SELECT Id FROM ApexClass WHERE Name = '${class_name}' LIMIT 1"
done

echo
echo "Validating permission sets..."
for permission_set in Interview_Feedback_Manager Interview_Feedback_User Interview_Feedback_Viewer; do
  check_query "${permission_set} permission set exists" "SELECT Id FROM PermissionSet WHERE Name = '${permission_set}' LIMIT 1"
done

echo
echo "Validating LWC source files..."
for component in interviewFeedbackCollector performanceDashboard mobileFeedbackCapture; do
  check_file "force-app/main/default/lwc/${component}/${component}.js"
done

echo
echo "Validation Summary"
echo "=================="
if [[ "${failures}" -eq 0 ]]; then
  echo "All validation checks passed."
else
  echo "${failures} validation check(s) failed."
  exit 1
fi
