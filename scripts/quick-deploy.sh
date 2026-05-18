#!/usr/bin/env bash
set -euo pipefail

TARGET_ORG="${1:-myCapstoneOrg}"

echo
echo "=== Quick Deploy to ${TARGET_ORG} ==="
echo "Deploys in dependency order, skipping known broken components."
echo

run_deploy() {
  local label="$1"
  shift
  echo "${label}"
  sf project deploy start "$@" --target-org "${TARGET_ORG}"
  echo "  Done."
  echo
}

run_deploy "[1/4] Deploying Custom Metadata Types..." \
  --source-dir force-app/main/default/objects/Tax_Configuration__mdt \
  --source-dir force-app/main/default/customMetadata \
  --wait 10

run_deploy "[2/4] Deploying Apex classes..." \
  --source-dir force-app/main/default/classes/BaseApiService.cls \
  --source-dir force-app/main/default/classes/BaseApiService.cls-meta.xml \
  --source-dir force-app/main/default/classes/TaxConfigurationService.cls \
  --source-dir force-app/main/default/classes/TaxConfigurationService.cls-meta.xml \
  --source-dir force-app/main/default/classes/SalaryBenchmarkService.cls \
  --source-dir force-app/main/default/classes/SalaryBenchmarkService.cls-meta.xml \
  --source-dir force-app/main/default/classes/CompanyDataService.cls \
  --source-dir force-app/main/default/classes/CompanyDataService.cls-meta.xml \
  --source-dir force-app/main/default/classes/PerformanceOptimizationService.cls \
  --source-dir force-app/main/default/classes/PerformanceOptimizationService.cls-meta.xml \
  --source-dir force-app/main/default/classes/ApplicationAnalyticsService.cls \
  --source-dir force-app/main/default/classes/ApplicationAnalyticsService.cls-meta.xml \
  --source-dir force-app/main/default/classes/JobApplicationEventPublisher.cls \
  --source-dir force-app/main/default/classes/JobApplicationEventPublisher.cls-meta.xml \
  --source-dir force-app/main/default/classes/JobApplicationEventSubscriber.cls \
  --source-dir force-app/main/default/classes/JobApplicationEventSubscriber.cls-meta.xml \
  --source-dir force-app/main/default/classes/SalaryCalculationService.cls \
  --source-dir force-app/main/default/classes/SalaryCalculationService.cls-meta.xml \
  --source-dir force-app/main/default/classes/SecurityGovernanceService.cls \
  --source-dir force-app/main/default/classes/SecurityGovernanceService.cls-meta.xml \
  --source-dir force-app/main/default/classes/TaskCreationService.cls \
  --source-dir force-app/main/default/classes/TaskCreationService.cls-meta.xml \
  --source-dir force-app/main/default/classes/ContactAssignmentService.cls \
  --source-dir force-app/main/default/classes/ContactAssignmentService.cls-meta.xml \
  --source-dir force-app/main/default/classes/EmailNotificationQueue.cls \
  --source-dir force-app/main/default/classes/EmailNotificationQueue.cls-meta.xml \
  --source-dir force-app/main/default/classes/EventValidationHandler.cls \
  --source-dir force-app/main/default/classes/EventValidationHandler.cls-meta.xml \
  --source-dir force-app/main/default/classes/ExecutiveReportingService.cls \
  --source-dir force-app/main/default/classes/ExecutiveReportingService.cls-meta.xml \
  --source-dir force-app/main/default/classes/IntegrationDeploymentService.cls \
  --source-dir force-app/main/default/classes/IntegrationDeploymentService.cls-meta.xml \
  --source-dir force-app/main/default/classes/JobApplicationTriggerHandler.cls \
  --source-dir force-app/main/default/classes/JobApplicationTriggerHandler.cls-meta.xml \
  --source-dir force-app/main/default/classes/SalaryDataAPIService.cls \
  --source-dir force-app/main/default/classes/SalaryDataAPIService.cls-meta.xml \
  --source-dir force-app/main/default/classes/SalaryMarketAnalysisBatch.cls \
  --source-dir force-app/main/default/classes/SalaryMarketAnalysisBatch.cls-meta.xml \
  --source-dir force-app/main/default/classes/SalaryMarketAnalysisScheduler.cls \
  --source-dir force-app/main/default/classes/SalaryMarketAnalysisScheduler.cls-meta.xml \
  --wait 15

run_deploy "[3/4] Deploying LWC components..." \
  --source-dir force-app/main/default/lwc/errorPanel \
  --source-dir force-app/main/default/lwc/salaryCalculator \
  --source-dir force-app/main/default/lwc/securityGovernanceDashboard \
  --source-dir force-app/main/default/lwc/applicationAnalyticsDashboard \
  --source-dir force-app/main/default/lwc/calendarIntegration \
  --source-dir force-app/main/default/lwc/executiveKpiDashboard \
  --source-dir force-app/main/default/lwc/integrationDeploymentDashboard \
  --source-dir force-app/main/default/lwc/performanceOptimizationDashboard \
  --source-dir force-app/main/default/lwc/interviewFeedbackCollector \
  --source-dir force-app/main/default/lwc/mobileFeedbackCapture \
  --source-dir force-app/main/default/lwc/performanceDashboard \
  --wait 10

run_deploy "[4/4] Deploying objects, triggers, and metadata..." \
  --source-dir force-app/main/default/objects/Job_Application__c \
  --source-dir force-app/main/default/triggers \
  --wait 10

cat <<'EOF'
=== Deployment Complete ===
Skipped (pre-existing issues):
  - Job_Application_Workflow.flow-meta.xml (duplicate actionCalls)
  - Job_Application_Manager.permissionset-meta.xml (required field ref)
  - jobApplicationDashboard LWC (inline ternary HTML syntax)
  - AutomatedReportService, CompanyDataServiceTest, etc. (Apex compile errors)
EOF
