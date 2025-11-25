#!/bin/bash

# GitHub Repository Creation Script
# Usage: ./create_repo.sh

set -e

# Configuration
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
REPO_NAME="ios-app-1123a1bf-67ee-4511-b9f6-3bb127b84f41"
REPO_DESCRIPTION="Cloud File Browser - Unified iOS app for multiple cloud storage providers"
USER_NAME="superpeiss"
USER_EMAIL="dmfmjfn6111@outlook.com"

# Validate token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable not set"
    echo "Usage: GITHUB_TOKEN=your_token ./scripts/create_repo.sh"
    exit 1
fi

echo "Creating GitHub repository: $REPO_NAME"

# Create repository
RESPONSE=$(curl -k -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -d "{\"name\":\"$REPO_NAME\",\"description\":\"$REPO_DESCRIPTION\",\"private\":false}" \
  https://api.github.com/user/repos)

# Check if repository was created successfully
REPO_URL=$(echo "$RESPONSE" | grep -o '"html_url":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$REPO_URL" ]; then
    echo "Error: Failed to create repository"
    echo "Response: $RESPONSE"
    exit 1
fi

echo "✅ Repository created successfully!"
echo "Repository URL: $REPO_URL"
echo "Clone URL: git@github.com:$USER_NAME/$REPO_NAME.git"

# Generate SSH key if needed
if [ ! -f ~/.ssh/github_deploy_key ]; then
    echo ""
    echo "Generating SSH key..."
    ssh-keygen -t ed25519 -C "$USER_EMAIL" -f ~/.ssh/github_deploy_key -N ""

    # Add SSH key to GitHub
    SSH_KEY=$(cat ~/.ssh/github_deploy_key.pub)
    curl -k -s -X POST \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github+json" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      -d "{\"title\":\"Deploy Key $(date +%Y%m%d)\",\"key\":\"$SSH_KEY\"}" \
      https://api.github.com/user/keys > /dev/null

    # Configure SSH
    cat > ~/.ssh/config << EOF
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/github_deploy_key
  StrictHostKeyChecking no
EOF
    chmod 600 ~/.ssh/config

    echo "✅ SSH key generated and added to GitHub"
fi

# Initialize git and push code
echo ""
echo "Initializing git repository and pushing code..."
cd "$(dirname "$0")/.."

if [ ! -d .git ]; then
    git init
    git config user.name "$USER_NAME"
    git config user.email "$USER_EMAIL"
    git branch -m main
    git add .
    git commit -m "Initial commit: Cloud File Browser iOS app

- Multi-provider cloud storage integration (Google Drive, Dropbox, OneDrive)
- SwiftUI-based UI with MVVM architecture
- File browsing, preview, and management features
- Cross-service file operations (move, copy, rename)
- Mock service implementations for testing"
fi

git remote add origin "git@github.com:$USER_NAME/$REPO_NAME.git" 2>/dev/null || true
git push -u origin main

echo ""
echo "✅ Code pushed to repository successfully!"
echo ""
echo "Next steps:"
echo "1. Run ./scripts/trigger_workflow.sh to start the build"
echo "2. Run ./scripts/check_workflow.sh to monitor the build status"
