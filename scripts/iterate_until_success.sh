#!/bin/bash

# Iterative Build Fix Script
# This script monitors the build and helps iterate on fixes until success
# Usage: ./iterate_until_success.sh

set -e

# Configuration
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
REPO_OWNER="superpeiss"
REPO_NAME="ios-app-1123a1bf-67ee-4511-b9f6-3bb127b84f41"
MAX_ITERATIONS=10

# Validate token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable not set"
    echo "Usage: GITHUB_TOKEN=your_token ./scripts/iterate_until_success.sh"
    exit 1
fi

echo "🔄 Starting iterative build process..."
echo "Maximum iterations: $MAX_ITERATIONS"
echo ""

ITERATION=1

while [ $ITERATION -le $MAX_ITERATIONS ]; do
    echo "==================== Iteration $ITERATION/$MAX_ITERATIONS ===================="
    echo ""

    # Trigger workflow
    echo "Triggering workflow..."
    ./scripts/trigger_workflow.sh

    echo ""
    echo "Waiting for build to complete..."

    # Wait and monitor
    TIMEOUT=600  # 10 minutes timeout
    ELAPSED=0
    INTERVAL=10

    while [ $ELAPSED -lt $TIMEOUT ]; do
        sleep $INTERVAL
        ELAPSED=$((ELAPSED + INTERVAL))

        # Check status
        RUN_INFO=$(curl -k -s \
          -H "Authorization: token $GITHUB_TOKEN" \
          -H "Accept: application/vnd.github+json" \
          -H "X-GitHub-Api-Version: 2022-11-28" \
          "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/runs?per_page=1")

        STATUS=$(echo "$RUN_INFO" | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4)
        CONCLUSION=$(echo "$RUN_INFO" | grep -o '"conclusion":"[^"]*"' | head -1 | cut -d'"' -f4)

        if [ "$STATUS" = "completed" ]; then
            echo ""
            echo "Build completed!"

            if [ "$CONCLUSION" = "success" ]; then
                echo ""
                echo "✅✅✅ BUILD SUCCEEDED! ✅✅✅"
                echo ""
                echo "Total iterations: $ITERATION"
                echo ""
                ./scripts/check_workflow.sh
                exit 0
            else
                echo ""
                echo "❌ Build failed with conclusion: $CONCLUSION"
                echo ""
                echo "Analyzing build failure..."
                ./scripts/check_workflow.sh

                # In a real scenario, you would analyze the errors here
                # and automatically apply fixes. For this demo, we'll just retry.

                echo ""
                echo "Press Enter to retry, or Ctrl+C to stop..."
                read -r

                break
            fi
        else
            echo -n "."
        fi
    done

    if [ $ELAPSED -ge $TIMEOUT ]; then
        echo ""
        echo "⏱️  Timeout waiting for build to complete"
        echo "Skipping to next iteration..."
    fi

    ITERATION=$((ITERATION + 1))
    echo ""
done

echo ""
echo "❌ Maximum iterations reached without success"
echo "Please check the repository and fix issues manually:"
echo "https://github.com/$REPO_OWNER/$REPO_NAME/actions"
exit 1
