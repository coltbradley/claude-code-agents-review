#!/bin/bash
# test-hooks.sh — Simple test suite for hook scripts.
# Creates temporary git repos and verifies each hook catches what it should
# and allows what it should. No external dependencies needed.
#
# Usage: bash tests/test-hooks.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0
ERRORS=()

# Helper: create a temporary git repo and return its path.
# Caller must cd into the returned path before running git operations.
setup_repo() {
  local tmpdir
  tmpdir="$SCRIPT_DIR/tests/.tmp-$$-$RANDOM"
  mkdir -p "$tmpdir"
  cd "$tmpdir"
  git init -q
  git config user.email "test@test.com"
  git config user.name "Test"
  echo "$tmpdir"
}

cleanup_repo() {
  cd "$SCRIPT_DIR"
  rm -rf "$1"
}

assert_exit() {
  local expected="$1" actual="$2" test_name="$3"
  if [ "$actual" -eq "$expected" ]; then
    PASS=$((PASS + 1))
    echo "  PASS: $test_name"
  else
    FAIL=$((FAIL + 1))
    ERRORS+=("FAIL: $test_name (expected exit $expected, got $actual)")
    echo "  FAIL: $test_name (expected exit $expected, got $actual)"
  fi
}

echo "=== detect-secrets.sh ==="

# Test 1: Should block a file containing an AWS key
REPO=$(setup_repo)
cd "$REPO"
echo 'AKIAIOSFODNN7EXAMPLE' > secret.txt
git add secret.txt
set +e
"$SCRIPT_DIR/hooks/scripts/detect-secrets.sh" > /dev/null 2>&1
EXIT_CODE=$?
set -e
assert_exit 2 "$EXIT_CODE" "Blocks staged file with AWS key pattern"
cleanup_repo "$REPO"

# Test 2: Should allow a clean file
REPO=$(setup_repo)
cd "$REPO"
echo 'hello world' > clean.txt
git add clean.txt
set +e
"$SCRIPT_DIR/hooks/scripts/detect-secrets.sh" > /dev/null 2>&1
EXIT_CODE=$?
set -e
assert_exit 0 "$EXIT_CODE" "Allows staged file with no secrets"
cleanup_repo "$REPO"

# Test 3: Should skip .example files
REPO=$(setup_repo)
cd "$REPO"
echo 'password = "hunter2"' > config.example
git add config.example
set +e
"$SCRIPT_DIR/hooks/scripts/detect-secrets.sh" > /dev/null 2>&1
EXIT_CODE=$?
set -e
assert_exit 0 "$EXIT_CODE" "Skips .example files"
cleanup_repo "$REPO"

# Test 4: Should skip files in tests/ directory
REPO=$(setup_repo)
cd "$REPO"
mkdir -p tests
echo 'api_key = "sk-test1234567890abcdef"' > tests/test_auth.py
git add tests/test_auth.py
set +e
"$SCRIPT_DIR/hooks/scripts/detect-secrets.sh" > /dev/null 2>&1
EXIT_CODE=$?
set -e
assert_exit 0 "$EXIT_CODE" "Skips files in tests/ directory"
cleanup_repo "$REPO"

# Test 5: Should NOT skip files that merely contain 'test' in name
REPO=$(setup_repo)
cd "$REPO"
echo 'api_key = "sk-test1234567890abcdef"' > contest_results.py
git add contest_results.py
set +e
"$SCRIPT_DIR/hooks/scripts/detect-secrets.sh" > /dev/null 2>&1
EXIT_CODE=$?
set -e
assert_exit 2 "$EXIT_CODE" "Does NOT skip files with 'test' in non-directory name"
cleanup_repo "$REPO"

echo ""
echo "=== check-env-files.sh ==="

# Test 6: Should block .env
REPO=$(setup_repo)
cd "$REPO"
echo 'SECRET=value' > .env
git add .env
set +e
"$SCRIPT_DIR/hooks/scripts/check-env-files.sh" > /dev/null 2>&1
EXIT_CODE=$?
set -e
assert_exit 2 "$EXIT_CODE" "Blocks .env file"
cleanup_repo "$REPO"

# Test 7: Should allow .env.example
REPO=$(setup_repo)
cd "$REPO"
echo 'SECRET=placeholder' > .env.example
git add .env.example
set +e
"$SCRIPT_DIR/hooks/scripts/check-env-files.sh" > /dev/null 2>&1
EXIT_CODE=$?
set -e
assert_exit 0 "$EXIT_CODE" "Allows .env.example file"
cleanup_repo "$REPO"

# Test 8: Should block .env.local
REPO=$(setup_repo)
cd "$REPO"
echo 'SECRET=value' > .env.local
git add .env.local
set +e
"$SCRIPT_DIR/hooks/scripts/check-env-files.sh" > /dev/null 2>&1
EXIT_CODE=$?
set -e
assert_exit 2 "$EXIT_CODE" "Blocks .env.local file"
cleanup_repo "$REPO"

echo ""
echo "=== check-large-files.sh ==="

# Test 9: Should block files over 500KB
REPO=$(setup_repo)
cd "$REPO"
dd if=/dev/zero of=bigfile.bin bs=1024 count=600 2>/dev/null
git add bigfile.bin
set +e
"$SCRIPT_DIR/hooks/scripts/check-large-files.sh" > /dev/null 2>&1
EXIT_CODE=$?
set -e
assert_exit 2 "$EXIT_CODE" "Blocks file over 500KB"
cleanup_repo "$REPO"

# Test 10: Should allow small files
REPO=$(setup_repo)
cd "$REPO"
echo 'small' > small.txt
git add small.txt
set +e
"$SCRIPT_DIR/hooks/scripts/check-large-files.sh" > /dev/null 2>&1
EXIT_CODE=$?
set -e
assert_exit 0 "$EXIT_CODE" "Allows small file"
cleanup_repo "$REPO"

echo ""
echo "=== check-large-files.sh with spaces in filename ==="

# Test 11: Should handle filenames with spaces
REPO=$(setup_repo)
cd "$REPO"
dd if=/dev/zero of="my big file.bin" bs=1024 count=600 2>/dev/null
git add "my big file.bin"
set +e
"$SCRIPT_DIR/hooks/scripts/check-large-files.sh" > /dev/null 2>&1
EXIT_CODE=$?
set -e
assert_exit 2 "$EXIT_CODE" "Blocks large file with spaces in name"
cleanup_repo "$REPO"

echo ""
echo "=== change-size-nudge.sh ==="

# Test 12: Should output advisory when many files changed
REPO=$(setup_repo)
cd "$REPO"
# Create initial commit so git diff works
echo 'init' > init.txt
git add init.txt
git commit -q -m "init"
# Now modify 6 files (above threshold of 5)
for i in 1 2 3 4 5 6; do
  echo "change $i" > "file$i.txt"
done
git add file*.txt
OUTPUT=$(echo '{"tool_name":"Edit"}' | "$SCRIPT_DIR/hooks/scripts/change-size-nudge.sh" 2>&1)
if echo "$OUTPUT" | grep -q "Advisory"; then
  assert_exit 0 0 "Shows advisory when 6+ files modified"
else
  FAIL=$((FAIL + 1))
  ERRORS+=("FAIL: Shows advisory when 6+ files modified (no Advisory in output)")
  echo "  FAIL: Shows advisory when 6+ files modified (no Advisory in output)"
fi
cleanup_repo "$REPO"

# Test 13: Should stay silent with few changes
REPO=$(setup_repo)
cd "$REPO"
echo 'init' > init.txt
git add init.txt
git commit -q -m "init"
echo 'one change' > single.txt
git add single.txt
OUTPUT=$(echo '{"tool_name":"Edit"}' | "$SCRIPT_DIR/hooks/scripts/change-size-nudge.sh" 2>&1)
if echo "$OUTPUT" | grep -q "Advisory"; then
  FAIL=$((FAIL + 1))
  ERRORS+=("FAIL: Silent when only 1 file modified")
  echo "  FAIL: Silent when only 1 file modified"
else
  assert_exit 0 0 "Silent when only 1 file modified"
fi
cleanup_repo "$REPO"

# Test 14: Should not double-count files
REPO=$(setup_repo)
cd "$REPO"
echo 'init' > init.txt
git add init.txt
git commit -q -m "init"
# Create 3 files, stage them, then modify them again (appear in both staged + unstaged)
for i in 1 2 3; do
  echo "v1" > "file$i.txt"
done
git add file*.txt
for i in 1 2 3; do
  echo "v2" > "file$i.txt"
done
OUTPUT=$(echo '{"tool_name":"Edit"}' | "$SCRIPT_DIR/hooks/scripts/change-size-nudge.sh" 2>&1)
if echo "$OUTPUT" | grep -q "Advisory"; then
  FAIL=$((FAIL + 1))
  ERRORS+=("FAIL: Should not trigger with 3 deduplicated files (threshold=5)")
  echo "  FAIL: Should not trigger with 3 deduplicated files (threshold=5)"
else
  assert_exit 0 0 "Does not double-count files in both staged and unstaged"
fi
cleanup_repo "$REPO"

echo ""
echo "=== pre-commit-checks.sh (consolidated) ==="

# Test 15: Consolidated script blocks secrets
REPO=$(setup_repo)
cd "$REPO"
echo 'AKIAIOSFODNN7EXAMPLE' > secret.txt
git add secret.txt
set +e
"$SCRIPT_DIR/hooks/scripts/pre-commit-checks.sh" > /dev/null 2>&1
EXIT_CODE=$?
set -e
assert_exit 2 "$EXIT_CODE" "Consolidated: blocks staged file with AWS key"
cleanup_repo "$REPO"

# Test 16: Consolidated script blocks .env
REPO=$(setup_repo)
cd "$REPO"
echo 'SECRET=value' > .env
git add .env
set +e
"$SCRIPT_DIR/hooks/scripts/pre-commit-checks.sh" > /dev/null 2>&1
EXIT_CODE=$?
set -e
assert_exit 2 "$EXIT_CODE" "Consolidated: blocks .env file"
cleanup_repo "$REPO"

# Test 17: Consolidated script blocks large files
REPO=$(setup_repo)
cd "$REPO"
dd if=/dev/zero of=bigfile.bin bs=1024 count=600 2>/dev/null
git add bigfile.bin
set +e
"$SCRIPT_DIR/hooks/scripts/pre-commit-checks.sh" > /dev/null 2>&1
EXIT_CODE=$?
set -e
assert_exit 2 "$EXIT_CODE" "Consolidated: blocks file over 500KB"
cleanup_repo "$REPO"

# Test 18: Consolidated script allows clean files
REPO=$(setup_repo)
cd "$REPO"
echo 'hello world' > clean.txt
git add clean.txt
set +e
"$SCRIPT_DIR/hooks/scripts/pre-commit-checks.sh" > /dev/null 2>&1
EXIT_CODE=$?
set -e
assert_exit 0 "$EXIT_CODE" "Consolidated: allows clean file"
cleanup_repo "$REPO"

echo ""
echo "================================"
echo "Results: $PASS passed, $FAIL failed"
if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""
  echo "Failures:"
  for err in "${ERRORS[@]}"; do
    echo "  $err"
  done
  exit 1
fi
echo "All tests passed."
exit 0
