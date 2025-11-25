#!/bin/bash

# GitHub Actions Workflow Trigger Script
# Usage: ./trigger_workflow.sh

set -e

# Configuration
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
REPO_OWNER="superpeiss"
REPO_NAME="ios-app-1123a1bf-67ee-4511-b9f6-3bb127b84f41"
WORKFLOW_FILE="ios-build.yml"
BRANCH="main"

# Validate token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable not set"
    echo "Usage: GITHUB_TOKEN=your_token ./scripts/trigger_workflow.sh"
    exit 1
fi

echo "Triggering GitHub Actions workflow: $WORKFLOW_FILE"
echo "Repository: $REPO_OWNER/$REPO_NAME"
echo "Branch: $BRANCH"
echo ""

# Trigger the workflow
RESPONSE=$(curl -k -s -w "\n%{http_code}" -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -d "{\"ref\":\"$BRANCH\"}" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/workflows/$WORKFLOW_FILE/dispatches")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_CODE" -eq 204 ]; then
    echo "✅ Workflow triggered successfully!"
    echo ""
    echo "Waiting for workflow to start..."
    sleep 5

    # Get the latest workflow run
    RUN_INFO=$(curl -k -s \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github+json" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs?per_page=1")

    RUN_ID=$(echo "$RUN_INFO" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
    RUN_URL=$(echo "$RUN_INFO" | grep -o '"html_url":"[^"]*actions/runs/[^"]*"' | head -1 | cut -d'"' -f4)

    echo "Workflow Run ID: $RUN_ID"
    echo "Workflow URL: $RUN_URL"
    echo ""
    echo "To monitor the workflow, run: ./scripts/check_workflow.sh"
else
    echo "❌ Failed to trigger workflow"
    echo "HTTP Status Code: $HTTP_CODE"
    echo "Response: $(echo "$RESPONSE" | head -n-1)"
    exit 1
fi
