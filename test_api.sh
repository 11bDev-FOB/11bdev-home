#!/bin/bash
# API Test Script for 11bDev
# Tests all API endpoints

set -e

BASE_URL="${API_BASE_URL:-http://localhost:3000}"
API_URL="$BASE_URL/api"
ADMIN_USER="${ADMIN_USERNAME:-admin}"
ADMIN_PASS="${ADMIN_PASSWORD:-changeme}"

echo "🧪 11bDev API Test Script"
echo "=========================="
echo "Base URL: $API_URL"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

test_endpoint() {
    local method=$1
    local endpoint=$2
    local description=$3
    local auth=$4
    local data=$5
    
    echo -e "${BLUE}Testing:${NC} $description"
    echo "  $method $endpoint"
    
    if [ "$auth" == "true" ]; then
        if [ -z "$data" ]; then
            response=$(curl -s -w "\n%{http_code}" -u "$ADMIN_USER:$ADMIN_PASS" -X "$method" "$API_URL$endpoint")
        else
            response=$(curl -s -w "\n%{http_code}" -u "$ADMIN_USER:$ADMIN_PASS" -X "$method" "$API_URL$endpoint" \
                -H "Content-Type: application/json" \
                -d "$data")
        fi
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$API_URL$endpoint")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)
    
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo -e "  ${GREEN}✓ PASSED${NC} (HTTP $http_code)"
        ((TESTS_PASSED++))
    else
        echo -e "  ${RED}✗ FAILED${NC} (HTTP $http_code)"
        echo "  Response: $body"
        ((TESTS_FAILED++))
    fi
    echo ""
}

echo "📝 Testing Posts API"
echo "-------------------"
test_endpoint "GET" "/posts" "List all posts" false
test_endpoint "GET" "/posts/1" "Get post by ID" false

echo ""
echo "🗂️  Testing Projects API"
echo "----------------------"
test_endpoint "GET" "/projects" "List all projects" false
test_endpoint "GET" "/projects/1" "Get project by ID" false

echo ""
echo "🔒 Testing Protected Endpoints (requires auth)"
echo "----------------------------------------------"

# Test creating a post
POST_DATA='{"post":{"title":"API Test Post","content":"This is a test post created via API","published":false}}'
test_endpoint "POST" "/posts" "Create new post" true "$POST_DATA"

# Test creating a project
PROJECT_DATA='{"project":{"title":"API Test Project","description":"Test project from API","published":false}}'
test_endpoint "POST" "/projects" "Create new project" true "$PROJECT_DATA"

echo ""
echo "📊 Test Summary"
echo "==============="
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC} 🎉"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    exit 1
fi
