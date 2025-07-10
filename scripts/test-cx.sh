#!/usr/bin/env bash
# Test script for cx (comma headless)

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Testing cx (comma headless)..."
echo "=============================="

# Track successes and failures
PASSED=0
FAILED=0

# Test function
test_command() {
    local description="$1"
    local command="$2"
    
    echo -n "Testing: $description... "
    
    if eval "$command" >/dev/null 2>&1; then
        echo -e "${GREEN}PASSED${NC}"
        ((PASSED++))
    else
        echo -e "${RED}FAILED${NC}"
        echo "  Command: $command"
        ((FAILED++))
    fi
}

# Test help
test_command "Help flag" "cx --help | grep -q 'Run any command without installing it'"

# Test basic commands
test_command "Cowsay" "cx cowsay 'Test' | grep -q 'Test'"
test_command "Python version" "cx python --version | grep -q 'Python'"
test_command "Python execution" "cx python -c 'print(42)' | grep -q '42'"
test_command "jq version" "cx jq --version | grep -q 'jq'"
test_command "jq processing" "echo '{\"test\": true}' | cx jq '.test' | grep -q 'true'"

# Test commands with special package mappings
test_command "Node.js" "cx node --version | grep -q 'v'"
test_command "npm" "cx npm --version | grep -q '[0-9]'"
test_command "Make" "cx make --version | grep -q 'GNU Make'"

# Test error handling
echo -n "Testing: Non-existent command... "
if cx thiscommanddoesnotexist 2>&1 | grep -q "No package found"; then
    echo -e "${GREEN}PASSED${NC}"
    ((PASSED++))
else
    echo -e "${RED}FAILED${NC}"
    ((FAILED++))
fi

# Summary
echo "=============================="
echo "Tests completed!"
echo -e "Passed: ${GREEN}$PASSED${NC}"
echo -e "Failed: ${RED}$FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed!${NC}"
    exit 1
fi