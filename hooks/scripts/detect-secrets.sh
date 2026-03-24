#!/bin/bash
# detect-secrets.sh - Detects common secret patterns in staged git files.
# Exits with code 2 to block the commit if secrets are found.

# Combined regex for all secret patterns (single grep -E call per file)
COMBINED_PATTERN='sk-[a-zA-Z0-9]{20,}|AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}|gho_[a-zA-Z0-9]{36}|glpat-[a-zA-Z0-9\-]{20,}|password[[:space:]]*[=:][[:space:]]*["'"'"'][^"'"'"']{4,}|secret[[:space:]]*[=:][[:space:]]*["'"'"'][^"'"'"']{4,}|api_key[[:space:]]*[=:][[:space:]]*["'"'"'][^"'"'"']{4,}'

FOUND=0
FINDINGS=""

# Null-delimited iteration handles filenames with spaces
while IFS= read -r -d '' FILE; do
  # Skip files that don't exist (deleted files)
  [ -f "$FILE" ] || continue

  # Skip example, sample, and template files
  case "$FILE" in
    *.example|*.sample|*.template) continue ;;
  esac

  # Skip test/mock/spec files using directory and naming conventions only
  case "$FILE" in
    test/*|tests/*|spec/*|__tests__/*) continue ;;
    *_test.*|*_spec.*|*.test.*|*.spec.*|*_mock.*|*.mock.*) continue ;;
  esac

  # Single grep call on the staged diff for this file
  MATCHES=$(git diff --cached -- "$FILE" | grep '^+' | grep -v '^+++' | grep -E "$COMBINED_PATTERN" 2>/dev/null)
  if [ -n "$MATCHES" ]; then
    FOUND=1
    FINDINGS="$FINDINGS  $FILE\n"
  fi
done < <(git diff --cached --name-only -z 2>/dev/null)

if [ "$FOUND" -eq 1 ]; then
  echo ""
  echo "BLOCKED: Potential secrets detected in staged files."
  echo ""
  echo "Flagged locations:"
  printf "%b" "$FINDINGS"
  echo ""
  echo "Guidance:"
  echo "  - Remove secrets from source files before committing."
  echo "  - Use environment variables or a secrets manager instead."
  echo "  - If this is a false positive, add the file to .gitignore"
  echo "    or use a .env.example file with placeholder values."
  echo ""
  exit 2
fi

exit 0
