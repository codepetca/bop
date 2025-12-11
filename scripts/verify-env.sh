#!/bin/bash
set -e

echo "🔍 Verifying WristBop development environment..."

# Check Swift version
if ! swift --version | grep -q "Swift version"; then
    echo "❌ Swift not found"
    echo "   Install Xcode from the App Store or download from developer.apple.com"
    exit 1
fi
echo "✅ Swift compiler available"

# Build core package
echo "Building WristBopCore..."
if ! swift build > /dev/null 2>&1; then
    echo "❌ Core package build failed"
    echo "   Running swift build to show errors:"
    swift build
    exit 1
fi
echo "✅ WristBopCore builds successfully"

# Run core tests
echo "Running core tests..."
if ! swift test > /dev/null 2>&1; then
    echo "❌ Core tests failing"
    echo "   Running swift test to show failures:"
    swift test
    exit 1
fi
echo "✅ Core tests passing"

# Check Xcode project exists
if [ ! -d "WristBop/WristBop.xcodeproj" ]; then
    echo "❌ Xcode project not found"
    echo "   Expected: WristBop/WristBop.xcodeproj"
    exit 1
fi
echo "✅ Xcode project present"

# Check for .ai directory
if [ ! -d ".ai" ]; then
    echo "❌ .ai/ directory not found"
    echo "   AI documentation layer missing. Run setup first."
    exit 1
fi
echo "✅ AI documentation layer present"

echo ""
echo "✨ Environment verified. Ready for development."
echo ""
echo "📊 Quick stats:"
TEST_OUTPUT=$(swift test 2>&1 | grep -E "Test Suite.*passed" | tail -1 || echo "")
if [ -n "$TEST_OUTPUT" ]; then
    echo "  $TEST_OUTPUT"
else
    echo "  Tests: (run swift test for details)"
fi
echo "  Current branch: $(git branch --show-current)"
echo ""
echo "Next steps:"
echo "  - Run: bash scripts/features-view.sh summary"
echo "  - Read: .ai/START-HERE.md"
