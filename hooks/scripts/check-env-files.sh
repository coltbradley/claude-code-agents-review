#!/bin/bash
# check-env-files.sh - Blocks committing .env files with real secrets.
# Allows .env.example, .env.sample, and .env.template variants.
# Exits with code 2 to block the commit.

BLOCKED=0
BLOCKED_FILES=""

# Null-delimited iteration handles filenames with spaces
while IFS= read -r -d '' FILE; do
  BASENAME=$(basename "$FILE")

  # Allow safe example/sample/template variants
  case "$BASENAME" in
    .env.example|.env.sample|.env.template) continue ;;
    *.env.example|*.env.sample|*.env.template) continue ;;
  esac

  # Block .env and common environment-specific variants
  case "$BASENAME" in
    .env|.env.local|.env.production|.env.development|.env.staging|\
    .env.prod|.env.dev|.env.test|.env.ci|.env.override)
      BLOCKED=1
      BLOCKED_FILES="$BLOCKED_FILES  $FILE\n"
      ;;
    *)
      # Also catch nested variants like config/.env or services/api/.env.local
      if echo "$BASENAME" | grep -qE '^\.env(\.(local|production|development|staging|prod|dev|test|ci|override))?$'; then
        BLOCKED=1
        BLOCKED_FILES="$BLOCKED_FILES  $FILE\n"
      fi
      ;;
  esac
done < <(git diff --cached --name-only -z 2>/dev/null)

if [ "$BLOCKED" -eq 1 ]; then
  echo ""
  echo "BLOCKED: Attempted to commit .env file(s) containing potential secrets."
  echo ""
  echo "Blocked files:"
  printf "%b" "$BLOCKED_FILES"
  echo ""
  echo "Guidance:"
  echo "  - Add these files to .gitignore to prevent accidental commits."
  echo "  - Commit a .env.example file with placeholder values instead:"
  echo "      cp .env .env.example"
  echo "      # Replace real values with placeholders, then:"
  echo "      git add .env.example"
  echo "  - Use a secrets manager or CI/CD environment variables for real values."
  echo ""
  exit 2
fi

exit 0
