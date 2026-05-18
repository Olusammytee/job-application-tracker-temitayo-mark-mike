#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/deploy-interview-feedback-tracker.sh <target-org> [--validate-only] [--no-tests] [--test-level RunLocalTests]
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

TARGET_ORG="$1"
shift
VALIDATE_ONLY=false
RUN_TESTS=true
TEST_LEVEL="RunLocalTests"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --validate-only)
      VALIDATE_ONLY=true
      shift
      ;;
    --no-tests)
      RUN_TESTS=false
      shift
      ;;
    --test-level)
      TEST_LEVEL="${2:?Missing value for --test-level}"
      shift 2
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

echo "Starting Interview Feedback Tracker deployment to org: ${TARGET_ORG}"
sf config set "target-org=${TARGET_ORG}"
sf org display --target-org "${TARGET_ORG}" >/dev/null

deploy_component() {
  local component="$1"
  local args=(project deploy start --source-dir "force-app/main/default/${component}" --target-org "${TARGET_ORG}")
  if [[ "${VALIDATE_ONLY}" == "true" ]]; then
    args+=(--dry-run)
  fi
  sf "${args[@]}"
}

deploy_phase() {
  local name="$1"
  shift
  echo
  echo "${name}"
  echo "${name}" | sed 's/./=/g'
  for component in "$@"; do
    echo "Deploying: ${component}"
    deploy_component "${component}"
  done
}

deploy_phase "Phase 1: Custom Objects and Fields" \
  objects/Interview_Feedback__c \
  objects/Feedback_Template__c \
  objects/Competency_Rating__c \
  objects/Feedback_Share__c \
  objects/Interview_Feedback_Audit__c

deploy_phase "Phase 2: Permission Sets and Security" \
  permissionsets/Interview_Feedback_Manager \
  permissionsets/Interview_Feedback_User \
  permissionsets/Interview_Feedback_Viewer

deploy_phase "Phase 3: Apex Classes and Services" \
  classes/InterviewFeedbackTestDataFactory \
  classes/InterviewFeedbackService \
  classes/FeedbackAnalyticsService \
  classes/FeedbackSharingService \
  classes/FeedbackTemplateService \
  classes/FeedbackSecurityService \
  classes/FeedbackDataRetentionBatch \
  classes/FeedbackDataRetentionScheduler

deploy_phase "Phase 4: Test Classes" \
  classes/InterviewFeedbackObjectTest \
  classes/InterviewFeedbackServiceTest \
  classes/FeedbackAnalyticsServiceTest \
  classes/FeedbackSharingServiceTest \
  classes/FeedbackSecurityServiceTest \
  classes/FeedbackQueryOptimizationServiceTest \
  classes/InterviewFeedbackComprehensiveTest \
  classes/InterviewFeedbackErrorHandlingTest

deploy_phase "Phase 5: Lightning Web Components" \
  lwc/interviewFeedbackCollector \
  lwc/performanceDashboard \
  lwc/mobileFeedbackCapture

if [[ "${RUN_TESTS}" == "true" && "${VALIDATE_ONLY}" == "false" ]]; then
  echo
  echo "Running Apex tests..."
  sf apex run test --test-level "${TEST_LEVEL}" --result-format human --code-coverage --target-org "${TARGET_ORG}"
fi

if [[ "${VALIDATE_ONLY}" == "false" ]]; then
  echo
  echo "Assigning permission sets..."
  sf org assign permset --name Interview_Feedback_Manager --target-org "${TARGET_ORG}" || true
  sf org assign permset --name Interview_Feedback_User --target-org "${TARGET_ORG}" || true
fi

echo
echo "Interview Feedback Tracker deployment completed successfully."
