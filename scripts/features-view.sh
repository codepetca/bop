#!/bin/bash
# Human-readable feature viewer with color

FEATURES_FILE=".ai/features.json"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}❌ jq is required but not installed${NC}"
    echo "Install with: brew install jq"
    exit 1
fi

if [ ! -f "$FEATURES_FILE" ]; then
    echo -e "${RED}❌ features.json not found${NC}"
    exit 1
fi

MODE=${1:-"summary"}

if [ "$MODE" = "summary" ]; then
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}WristBop Feature Status Summary${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    PHASE=$(jq -r '.meta.phase' "$FEATURES_FILE")
    TOTAL=$(jq -r '.meta.totalFeatures' "$FEATURES_FILE")
    PASSING=$(jq '[.features[] | select(.passes == true)] | length' "$FEATURES_FILE")
    FAILING=$(jq '[.features[] | select(.passes == false)] | length' "$FEATURES_FILE")

    echo -e "Current Phase: ${YELLOW}$PHASE${NC}"
    echo -e "Total Features: $TOTAL"
    echo -e "${GREEN}✅ Passing: $PASSING${NC}"
    echo -e "${RED}❌ Failing: $FAILING${NC}"
    echo ""

    echo "By Phase:"
    jq -r '.features | group_by(.phase) | .[] | "\(.[-1].phase): \([.[] | select(.passes == true)] | length)/\(length) passing"' "$FEATURES_FILE"
    echo ""

    echo -e "${YELLOW}Next Tasks (first 5 failing, not blocked):${NC}"
    jq -r '.features[] | select(.passes == false) | select(.blockedBy == null or .blockedBy == []) | "[\(.id)] \(.description)"' "$FEATURES_FILE" | head -5 | while read line; do
        echo -e "  ${RED}❌${NC} $line"
    done

elif [ "$MODE" = "phase" ]; then
    PHASE=$2
    if [ -z "$PHASE" ]; then
        echo "Usage: $0 phase <phase-name>"
        echo "Example: $0 phase \"Phase 2\""
        exit 1
    fi
    echo -e "${BLUE}Features in $PHASE:${NC}"
    jq -r --arg phase "$PHASE" '.features[] | select(.phase == $phase) | "\(if .passes then "✅" else "❌" end) [\(.id)] \(.description)"' "$FEATURES_FILE" | while read line; do
        if [[ $line == ✅* ]]; then
            echo -e "${GREEN}$line${NC}"
        else
            echo -e "${RED}$line${NC}"
        fi
    done

elif [ "$MODE" = "next" ]; then
    echo -e "${YELLOW}Next recommended features to work on:${NC}"
    echo ""
    jq -r '.features[] | select(.passes == false) | select(.blockedBy == null or .blockedBy == []) | "[\(.id)] \(.description)\n  Verify: \(.verification)\n  Files: \(.files | join(", "))\n"' "$FEATURES_FILE" | head -40

elif [ "$MODE" = "detail" ]; then
    FEATURE_ID=$2
    if [ -z "$FEATURE_ID" ]; then
        echo "Usage: $0 detail <feature-id>"
        echo "Example: $0 detail watch-002"
        exit 1
    fi
    echo -e "${BLUE}Feature Details:${NC}"
    jq --arg id "$FEATURE_ID" '.features[] | select(.id == $id)' "$FEATURES_FILE"

else
    echo "Usage: $0 [summary|phase <name>|detail <id>|next]"
    echo ""
    echo "Modes:"
    echo "  summary        Show overall status and next 5 tasks"
    echo "  phase <name>   Show all features in a specific phase"
    echo "  detail <id>    Show full details for a feature"
    echo "  next           Show next 5-10 unblocked features with details"
    exit 1
fi
