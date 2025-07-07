#!/bin/bash

# api-test.sh - Comprehensive API testing script
# Tests all user routes with good and error paths

# Configuration
API_URL="http://172.18.90.21:3001"
TIMEOUT=10
TEST_EMAIL="test-$(date +%s)@example.com"  # Unique email for each test run
TEST_PASSWORD="password123"
TEST_USERNAME="testuser"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Helper function to make HTTP requests
make_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    local expected_status=$4
    
    if [ -n "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X "$method" \
            -H "Content-Type: application/json" \
            -d "$data" \
            --max-time $TIMEOUT \
            "$API_URL$endpoint" 2>/dev/null)
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" \
            --max-time $TIMEOUT \
            "$API_URL$endpoint" 2>/dev/null)
    fi
    
    # Split response body and status code
    body=$(echo "$response" | head -n -1)
    status=$(echo "$response" | tail -n 1)
    
    echo "$status|$body"
}

# Test result checker
check_test() {
    local test_name="$1"
    local expected_status="$2"
    local actual_status="$3"
    local response_body="$4"
    local additional_check="$5"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    local pass=true
    local comment=""
    
    # Check status code
    if [ "$actual_status" != "$expected_status" ]; then
        pass=false
        comment="Expected $expected_status, got $actual_status"
    fi
    
    # Additional checks (e.g., response contains certain fields)
    if [ -n "$additional_check" ] && [ "$pass" = true ]; then
        if ! echo "$response_body" | grep -q "$additional_check"; then
            pass=false
            comment="Response missing expected content: $additional_check"
        fi
    fi
    
    # Print result
    if [ "$pass" = true ]; then
        printf "| %-25s | %-6s | ${GREEN}%-5s${NC} | %-4s | %-30s |\n" \
            "$test_name" "$expected_status" "PASS" "$actual_status" "$comment"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        printf "| %-25s | %-6s | ${RED}%-5s${NC} | %-4s | %-30s |\n" \
            "$test_name" "$expected_status" "FAIL" "$actual_status" "$comment"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        
        # Show response body for failed tests
        if [ ${#response_body} -gt 0 ]; then
            echo "  Response: $response_body"
        fi
    fi
}

# Print header
print_header() {
    echo ""
    echo "${BLUE}=== API Test Suite ===${NC}"
    echo "Testing API at: $API_URL"
    echo "Test Email: $TEST_EMAIL"
    echo ""
    printf "+---------------------------+--------+-------+------+--------------------------------+\n"
    printf "| %-25s | %-6s | %-5s | %-4s | %-30s |\n" "Test Name" "Expect" "Pass?" "Got" "Comment"
    printf "+---------------------------+--------+-------+------+--------------------------------+\n"
}

# Print footer
print_footer() {
    printf "+---------------------------+--------+-------+------+--------------------------------+\n"
    echo ""
    echo "${BLUE}=== Test Summary ===${NC}"
    echo "Total Tests: $TOTAL_TESTS"
    echo "${GREEN}Passed: $PASSED_TESTS${NC}"
    echo "${RED}Failed: $FAILED_TESTS${NC}"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo "${GREEN}All tests passed! 🎉${NC}"
        exit 0
    else
        echo "${RED}Some tests failed 😞${NC}"
        exit 1
    fi
}

# Check if server is running
check_server() {
    echo "Checking if server is running..."
    result=$(make_request "GET" "/api/health" "" "200")
    status=$(echo "$result" | cut -d'|' -f1)
    
    if [ "$status" != "200" ]; then
        echo "${RED}Error: Server is not running at $API_URL${NC}"
        echo "Please start your server first: npm start"
        exit 1
    fi
    echo "${GREEN}Server is running!${NC}"
}

# Store user ID for later tests
USER_ID=""

# Test functions
test_health_check() {
    result=$(make_request "GET" "/api/health" "" "200")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Health Check" "200" "$status" "$body" "status"
}

test_get_all_users() {
    result=$(make_request "GET" "/api/users" "" "200")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Get All Users" "200" "$status" "$body" "success"
}

test_create_user_success() {
    local data="{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\",\"username\":\"$TEST_USERNAME\"}"
    result=$(make_request "POST" "/api/users" "$data" "201")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Create User (Success)" "201" "$status" "$body" "success"
    
    # Extract user ID for later tests
    if [ "$status" = "201" ]; then
        USER_ID=$(echo "$body" | grep -o '"user_id":[0-9]*' | cut -d':' -f2)
        echo "  Created user ID: $USER_ID"
    fi
}

test_create_user_duplicate() {
    local data="{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\",\"username\":\"$TEST_USERNAME\"}"
    result=$(make_request "POST" "/api/users" "$data" "409")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Create User (Duplicate)" "409" "$status" "$body" "Duplicate Entry"
}

test_create_user_missing_fields() {
    local data="{\"email\":\"\"}"
    result=$(make_request "POST" "/api/users" "$data" "400")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Create User (Missing Fields)" "400" "$status" "$body" "required"
}

test_get_user_success() {
    if [ -n "$USER_ID" ]; then
        result=$(make_request "GET" "/api/users/$USER_ID" "" "200")
        status=$(echo "$result" | cut -d'|' -f1)
        body=$(echo "$result" | cut -d'|' -f2)
        check_test "Get User (Success)" "200" "$status" "$body" "success"
    else
        check_test "Get User (Success)" "200" "SKIP" "" "No user ID available"
    fi
}

test_get_user_not_found() {
    result=$(make_request "GET" "/api/users/99999" "" "404")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Get User (Not Found)" "404" "$status" "$body" "not found"
}

test_update_user_success() {
    if [ -n "$USER_ID" ]; then
        local data="{\"username\":\"updated_user\"}"
        result=$(make_request "PUT" "/api/users/$USER_ID" "$data" "200")
        status=$(echo "$result" | cut -d'|' -f1)
        body=$(echo "$result" | cut -d'|' -f2)
        check_test "Update User (Success)" "200" "$status" "$body" "success"
    else
        check_test "Update User (Success)" "200" "SKIP" "" "No user ID available"
    fi
}

test_update_user_not_found() {
    local data="{\"username\":\"updated_user\"}"
    result=$(make_request "PUT" "/api/users/99999" "$data" "404")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Update User (Not Found)" "404" "$status" "$body" "not found"
}

test_delete_user_not_found() {
    result=$(make_request "DELETE" "/api/users/99999" "" "404")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Delete User (Not Found)" "404" "$status" "$body" "not found"
}

test_delete_user_success() {
    if [ -n "$USER_ID" ]; then
        result=$(make_request "DELETE" "/api/users/$USER_ID" "" "200")
        status=$(echo "$result" | cut -d'|' -f1)
        body=$(echo "$result" | cut -d'|' -f2)
        check_test "Delete User (Success)" "200" "$status" "$body" "success"
    else
        check_test "Delete User (Success)" "200" "SKIP" "" "No user ID available"
    fi
}

test_404_route() {
    result=$(make_request "GET" "/api/nonexistent" "" "404")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "404 Route" "404" "$status" "$body" "not found"
}

# Main execution
main() {
    print_header
    
    # Check server first
    check_server
    
    # Run tests in logical order
    test_health_check
    test_get_all_users
    test_create_user_success
    test_create_user_duplicate
    test_create_user_missing_fields
    test_get_user_success
    test_get_user_not_found
    test_update_user_success
    test_update_user_not_found
    test_delete_user_not_found
    test_delete_user_success
    test_404_route
    
    print_footer
}

# Run main function
main "$@"