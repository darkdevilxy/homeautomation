#!/bin/bash
set -e

LAMBDA_URL="https://4khajhu3yqi4vi7yvvyl32qczi0lbgcu.lambda-url.ap-southeast-2.on.aws/"
VERSION_LABEL=$(date +%Y%m%d%H%M%S)  # Generate a timestamp as version label

echo "Triggering Lambda to deploy version $VERSION_LABEL"

# Send request to Lambda URL
RESPONSE=$(curl -s -X POST "$LAMBDA_URL" -H "Content-Type: application/json" -d "{\"version_label\": \"$VERSION_LABEL\"}")

echo "Lambda Response: $RESPONSE"

# Check if deployment succeeded
if echo "$RESPONSE" | grep -q "Deployment triggered"; then
    echo "✅ Lambda deployment successful."
    exit 0
else
    echo "❌ Lambda deployment failed."
    exit 1
fi
