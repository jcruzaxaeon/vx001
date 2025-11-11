#!/bin/bash

# api-test_2.sh - Comprehensive API testing script
# Tests all user routes with good and error paths

# Configuration
API_URL="http://127.0.0.1:3001" #DB IP Address @ Chromebook
# API_URL="http://127.18.90.21:3001" #DB IP Address @ PC
TIMEOUT=10
TEST_EMAIL="test-$(date +%s)@example.com"  # Unique email for each test run
TEST_PASSWORD="passWord123"
TEST_USERNAME="testuser"
sleep 3
EMAIL2="test-$(date +%s)@example.com"
PASSWORD2="passWord123"
USERNAME2="testuser-$(date +%s)"
COOKIES_FILE="test_cookies.txt"

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

# Store user ID for later tests
USER_ID=""
SECOND_USER_ID=""

# Helper function to make HTTP requests
make_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    local expected_status=$4
    local use_cookies=$5
    
    local curl_cmd="curl -s -w \"\n%{http_code}\" -X \"$method\" \
        -H \"Content-Type: application/json\" \
        --max-time $TIMEOUT"
    
    if [ "$use_cookies" = "true" ]; then
        curl_cmd="$curl_cmd -b \"$COOKIES_FILE\" -c \"$COOKIES_FILE\""
    fi
    
    if [ -n "$data" ]; then
        response=$(eval "$curl_cmd -d '$data' \"$API_URL$endpoint\" 2>/dev/null")
    else
        response=$(eval "$curl_cmd \"$API_URL$endpoint\" 2>/dev/null")
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
        # Does not print out the extra line
        printf "${NC}| %-35s | %-6s | ${GREEN}%-5s${NC} | %-4s | %-30s |\n" \
            "$test_name" "$expected_status" "PASS" "$actual_status" "$comment"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        printf "${NC}| %-35s | %-6s | ${RED}%-5s${NC} | %-4s | %-30s |\n" \
            "$test_name" "$expected_status" "FAIL" "$actual_status" "$comment"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        
        # Show response body for failed tests
        if [ ${#response_body} -gt 0 ]; then
            echo "${YELLOW}  Response: $response_body${NC}"
        fi
    fi
}

# Print header
print_header() {
    echo ""
    printf "${BLUE}=== API Test Suite ===${NC}\n"
    echo "Testing API at: $API_URL"
    # echo "Test Email: $TEST_EMAIL"
    echo ""
    printf "+-------------------------------------+--------+-------+------+--------------------------------+\n"
    printf "| %-35s | %-6s | %-5s | %-4s | %-30s |\n" "Test Name" "Expect" "Pass?" "Got" "Comment"
    printf "+-------------------------------------+--------+-------+------+--------------------------------+\n"
}

# Print section header
print_section() {
    local section_name="$1"
    printf "+-------------------------------------+--------+-------+------+--------------------------------+\n"
    printf "| ${YELLOW}%-35s${NC} |        |       |      |                                |\n" "$section_name"
    printf "+-------------------------------------+--------+-------+------+--------------------------------+\n"
}

# Print footer
print_footer() {
    printf "+-------------------------------------+--------+-------+------+--------------------------------+\n"
    echo ""
    echo "${BLUE}=== Test Summary ===${NC}"
    echo "Total Tests: $TOTAL_TESTS"
    echo "${GREEN}Passed: $PASSED_TESTS${NC}"
    echo "${RED}Failed: $FAILED_TESTS${NC}"
    
    # Clean up cookies file
    if [ -f "$COOKIES_FILE" ]; then
        rm "$COOKIES_FILE"
    fi
    
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
    echo ""
    echo "Checking if server is running..."
    result=$(make_request "GET" "/api/health" "" "200" "false")
    status=$(echo "$result" | cut -d'|' -f1)
    
    if [ "$status" != "200" ]; then
        printf "${RED}Error: Server is not running at $API_URL${NC}"
        printf "Please start your server first: npm start"
        exit 1
    fi
    printf "${GREEN}Server is running!${NC}\n"
}

# Test functions
test_health_check() {
    result=$(make_request "GET" "/api/health" "" "200" "false")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Health Check" "200" "$status" "$body" "status"
}

test_get_all_users_unauthorized() {
    result=$(make_request "GET" "/api/users" "" "401" "false")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Get All Users (Unauthorized)" "401" "$status" "$body" ""
}

# Authentication Tests
test_register_user() {
    local data="{
        \"email\":\"$TEST_EMAIL\",
        \"password\":\"$TEST_PASSWORD\",
        \"username\":\"$TEST_USERNAME\"
    }"
    result=$(make_request "POST" "/api/auth/register" "$data" "201" "true")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Register User (Success)" "201" "$status" "$body" "success"
    
    # Extract user ID for later tests
    if [ "$status" = "201" ]; then
        USER_ID=$(echo "$body" | grep -o '"user_id":[0-9]*' | cut -d':' -f2)
        if [ -z "$USER_ID" ]; then
            USER_ID=$(echo "$body" | grep -o '"id":[0-9]*' | cut -d':' -f2)
        fi
        printf "  ${GREEN}Created user ID: $USER_ID${NC}\n"
    fi
}

test_register_duplicate_user() {
    local data="{
        \"email\":\"$TEST_EMAIL\",
        \"password\":\"$TEST_PASSWORD\",
        \"username\":\"$TEST_USERNAME\"
    }"
    result=$(make_request "POST" "/api/auth/register" "$data" "409" "false")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Register User (Duplicate)" "409" "$status" "$body" ""
}

test_check_logged_in_status() {
    result=$(make_request "GET" "/api/auth/me" "" "200" "true")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Check Auth Status (Logged In)" "200" "$status" "$body" "email"
}

test_access_protected_route_authorized() {
    result=$(make_request "GET" "/api/users" "" "200" "true")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Get All Users (Authorized)" "200" "$status" "$body" "success"
}

test_logout() {
    result=$(make_request "POST" "/api/auth/logout" "" "200" "true")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Logout" "200" "$status" "$body" "success"
}

test_access_protected_route_after_logout() {
    result=$(make_request "GET" "/api/users" "" "401" "true")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Get All Users (After Logout)" "401" "$status" "$body" ""
}

test_login() {
    local data="{
        \"email\":\"$TEST_EMAIL\",
        \"password\":\"$TEST_PASSWORD\"
    }"
    result=$(make_request "POST" "/api/auth/login" "$data" "200" "true")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Login (Success)" "200" "$status" "$body" "success"
}

test_login_invalid_credentials() {
    local data="{
        \"email\":\"$TEST_EMAIL\",
        \"password\":\"wrongPassword1\"
    }"
    result=$(make_request "POST" "/api/auth/login" "$data" "401" "false")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Login (Invalid Credentials)" "401" "$status" "$body" ""
}

test_access_protected_route_after_login() {
    result=$(make_request "GET" "/api/users" "" "200" "true")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Get All Users (After Login)" "200" "$status" "$body" "success"
}

test_get_user_success() {
    if [ -n "$USER_ID" ]; then
        result=$(make_request "GET" "/api/users/$USER_ID" "" "200" "true")
        status=$(echo "$result" | cut -d'|' -f1)
        body=$(echo "$result" | cut -d'|' -f2)
        check_test "Get User (Success)" "200" "$status" "$body" "success"
    else
        check_test "Get User (Success)" "200" "SKIP" "" "No user ID available"
    fi
}

test_get_user_not_found() {
    result=$(make_request "GET" "/api/users/999999" "" "404" "true")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    check_test "Get User (Not Found)" "404" "$status" "$body" ""
}

test_update_own_user() {
    if [ -n "$USER_ID" ]; then
        local data="
            {\"username\":\"newusername\"}"
        result=$(make_request "PUT" "/api/users/$USER_ID" "$data" "200" "true")
        status=$(echo "$result" | cut -d'|' -f1)
        body=$(echo "$result" | cut -d'|' -f2)
        check_test "Update Own User (Success)" "200" "$status" "$body" "success"
    else
        check_test "Update Own User (Success)" "200" "SKIP" "" "No user ID available"
    fi
}

test_create_second_user() {
    # local EMAIL2="test2-$(date +%s)@example.com"

    local data="{
        \"email\":\"$EMAIL2\",
        \"password\":\"$PASSWORD2\",
        \"username\":\"$USERNAME2\"
    }"
    
    # Temporarily logout and create new user
    result=$(make_request "POST" "/api/auth/register" "$data" "201" "true")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    
    if [ "$status" = "201" ]; then
        SECOND_USER_ID=$(echo "$body" | grep -o '"user_id":[0-9]*' | cut -d':' -f2)
        if [ -z "$SECOND_USER_ID" ]; then
            SECOND_USER_ID=$(echo "$body" | grep -o '"id":[0-9]*' | cut -d':' -f2)
        fi
        printf "  ${GREEN}Created second user ID: $SECOND_USER_ID${NC}\n"
        
        # Login back as first user
        local login_data="{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}"
        make_request "POST" "/api/auth/login" "$login_data" "200" "true" > /dev/null
    fi
    
    check_test "Create Second User, then Login" "200" "$status" "$body" "success"
}

test_update_other_user_forbidden() {
    if [ -n "$SECOND_USER_ID" ]; then
        local data="{\"username\":\"hacker\"}"
        result=$(make_request "PUT" "/api/users/$SECOND_USER_ID" "$data" "403" "true")
        status=$(echo "$result" | cut -d'|' -f1)
        body=$(echo "$result" | cut -d'|' -f2)
        check_test "Update Other User (Forbidden)" "403" "$status" "$body" ""
    else
        check_test "Update Other User (Forbidden)" "403" "SKIP" "" "No second user ID"
    fi
}

test_delete_other_user_forbidden() {
    if [ -n "$SECOND_USER_ID" ]; then
        result=$(make_request "DELETE" "/api/users/$SECOND_USER_ID" "" "403" "true")
        status=$(echo "$result" | cut -d'|' -f1)
        body=$(echo "$result" | cut -d'|' -f2)
        check_test "Delete Other User (Forbidden)" "403" "$status" "$body" ""
    else
        check_test "Delete Other User (Forbidden)" "403" "SKIP" "" "No second user ID"
    fi
}

test_delete_own_user() {
    if [ -n "$USER_ID" ]; then
        result=$(make_request "DELETE" "/api/users/$USER_ID" "" "200" "true")
        status=$(echo "$result" | cut -d'|' -f1)
        body=$(echo "$result" | cut -d'|' -f2)
        check_test "Delete Own User (Success)" "200" "$status" "$body" "success"
    else
        check_test "Delete Own User (Fail)" "200" "SKIP" "" "No user ID available"
    fi
}

delete_second_user() {
    # echo "test"

    # [LESSON]
    # 1. Initially called `make_request` without `result=$(make_request)`
    # 2. Error: prints make_request's final `echo` on test report
    # 3. Soln: Store `echo` / return-value in `result` even if not used
    result=$(make_request "POST" "/api/auth/logout" "" "200" "true")
    local login_data="{
        \"email\":\"$EMAIL2\",
        \"password\":\"$PASSWORD2\",
        \"username\":\"$USERNAME2\"}"
    # echo "test2"
    result=$(make_request "POST" "/api/auth/login" "$login_data" "200" "true")
    status=$(echo "$result" | cut -d'|' -f1)
    body=$(echo "$result" | cut -d'|' -f2)
    make_request "POST" "/api/auth/login" "$login_data" "200" "true" > /dev/null
    
    if [ -n "$SECOND_USER_ID" ]; then
        result=$(make_request "DELETE" "/api/users/$SECOND_USER_ID" "" "200" "true")
        status=$(echo "$result" | cut -d'|' -f1)
        body=$(echo "$result" | cut -d'|' -f2)
        check_test "Delete Second User (Success)" "200" "$status" "$body" "success"
    else
        check_test "Delete Second User (Fail)" "200" "SKIP" "" "No user ID available"
    fi
}

# Main execution
main() {
    # Clear old cookies file
    if [ -f "$COOKIES_FILE" ]; then
        rm "$COOKIES_FILE"
    fi
    
    check_server
    print_header
    
    # Basic Tests
    print_section "BASIC TESTS"
    test_health_check
    test_get_all_users_unauthorized
    
    # Authentication Flow Tests
    print_section "AUTHENTICATION TESTS"
    test_register_user
    test_register_duplicate_user
    test_check_logged_in_status
    test_access_protected_route_authorized
    test_logout
    test_access_protected_route_after_logout
    test_login
    test_login_invalid_credentials
    test_access_protected_route_after_login
    
    # User CRUD Tests
    print_section "USER CRUD TESTS"
    test_get_user_success
    test_get_user_not_found
    test_update_own_user
    
    # Authorization Tests
    print_section "AUTHORIZATION TESTS"
    test_create_second_user
    test_update_other_user_forbidden
    test_delete_other_user_forbidden
    test_delete_own_user
    delete_second_user
    
    print_footer
}

# Run the test suite
main