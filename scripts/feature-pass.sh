#!/bin/bash
# Mark feature as passing

FEATURE_ID=$1

if [ -z "$FEATURE_ID" ]; then
    echo "Usage: $0 <feature-id>"
    echo "Example: $0 watch-002"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required but not installed"
    echo "Install with: brew install jq"
    exit 1
fi

FEATURES_FILE=".ai/features.json"

# Check if feature exists
if ! jq -e --arg id "$FEATURE_ID" '.features[] | select(.id == $id)' "$FEATURES_FILE" > /dev/null; then
    echo "❌ Feature $FEATURE_ID not found"
    exit 1
fi

# Update feature status
jq --arg id "$FEATURE_ID" \
   --arg date "$(date '+%Y-%m-%d')" \
   '(.features[] | select(.id == $id) | .passes) = true |
    (.features[] | select(.id == $id) | .completedDate) = $date |
    .meta.lastUpdated = $date |
    .meta.passing = ([.features[] | select(.passes == true)] | length) |
    .meta.failing = ([.features[] | select(.passes == false)] | length)' \
   "$FEATURES_FILE" > "$FEATURES_FILE.tmp"

mv "$FEATURES_FILE.tmp" "$FEATURES_FILE"

echo "✅ Feature $FEATURE_ID marked as passing"

# Show updated summary
PASSING=$(jq '.meta.passing' "$FEATURES_FILE")
TOTAL=$(jq '.meta.totalFeatures' "$FEATURES_FILE")
echo "   Progress: $PASSING/$TOTAL features passing"
