#!/bin/bash

# GitHub Actions Workflow Status Check Script
# Usage: ./check_workflow.sh [run_id]
# If run_id is not provided, checks the latest workflow run

set -e

# Configuration
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
REPO_OWNER="superpeiss"
REPO_NAME="ios-app-1123a1bf-67ee-4511-b9f6-3bb127b84f41"

# Validate token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable not set"
    echo "Usage: GITHUB_TOKEN=your_token ./scripts/check_workflow.sh [run_id]"
    exit 1
fi

RUN_ID=$1

# If no run ID provided, get the latest
if [ -z "$RUN_ID" ]; then
    echo "Fetching latest workflow run..."
    RUN_INFO=$(curl -k -s \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github+json" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs?per_page=1")

    RUN_ID=$(echo "$RUN_INFO" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

    if [ -z "$RUN_ID" ]; then
        echo "❌ No workflow runs found"
        exit 1
    fi
fi

echo "Checking workflow run: $RUN_ID"
echo ""

# Get workflow run details
RUN_DETAILS=$(curl -k -s \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs/$RUN_ID")

# Extract information
RUN_NUMBER=$(echo "$RUN_DETAILS" | grep -o '"run_number":[0-9]*' | cut -d':' -f2)
STATUS=$(echo "$RUN_DETAILS" | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4)
CONCLUSION=$(echo "$RUN_DETAILS" | grep -o '"conclusion":"[^"]*"' | head -1 | cut -d'"' -f4)
RUN_URL=$(echo "$RUN_DETAILS" | grep -o '"html_url":"[^"]*"' | head -1 | cut -d'"' -f4)
CREATED_AT=$(echo "$RUN_DETAILS" | grep -o '"created_at":"[^"]*"' | head -1 | cut -d'"' -f4)

echo "Run Number: $RUN_NUMBER"
echo "Status: $STATUS"
echo "Conclusion: $CONCLUSION"
echo "Created At: $CREATED_AT"
echo "URL: $RUN_URL"
echo ""

# Determine emoji and message based on status
if [ "$STATUS" = "completed" ]; then
    if [ "$CONCLUSION" = "success" ]; then
        echo "✅ BUILD SUCCEEDED!"
        echo ""
        echo "The iOS app compiled successfully."

        # Try to download build log
        echo "Downloading build log..."
        ARTIFACTS=$(curl -k -s \
          -H "Authorization: token $GITHUB_TOKEN" \
          -H "Accept: application/vnd.github+json" \
          -H "X-GitHub-Api-Version: 2022-11-28" \
          "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs/$RUN_ID/artifacts")

        ARTIFACT_URL=$(echo "$ARTIFACTS" | grep -o '"archive_download_url":"[^"]*"' | head -1 | cut -d'"' -f4)

        if [ -n "$ARTIFACT_URL" ]; then
            echo "Build log artifact URL: $ARTIFACT_URL"
        fi

        exit 0
    elif [ "$CONCLUSION" = "failure" ]; then
        echo "❌ BUILD FAILED!"
        echo ""
        echo "The build encountered errors. Analyzing..."

        # Get job details
        JOBS=$(curl -k -s \
          -H "Authorization: token $GITHUB_TOKEN" \
          -H "Accept: application/vnd.github+json" \
          -H "X-GitHub-Api-Version: 2022-11-28" \
          "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs/$RUN_ID/jobs")

        # Find failed steps
        echo "$JOBS" | grep -A 5 '"conclusion": "failure"' | head -20

        echo ""
        echo "To view full logs, visit: $RUN_URL"

        exit 1
    else
        echo "⚠️  Build completed with conclusion: $CONCLUSION"
        exit 1
    fi
elif [ "$STATUS" = "in_progress" ] || [ "$STATUS" = "queued" ]; then
    echo "🔄 Build is $STATUS..."
    echo ""
    echo "Run this script again to check the updated status:"
    echo "./scripts/check_workflow.sh $RUN_ID"
    exit 0
else
    echo "⚠️  Unknown status: $STATUS"
    exit 1
fi
