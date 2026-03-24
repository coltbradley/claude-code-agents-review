#!/bin/bash
# check-large-files.sh - Blocks staged files larger than 500KB.
# Exits with code 2 to block the commit.

MAX_BYTES=512000  # 500KB in bytes

BLOCKED=0
BLOCKED_FILES=""

# Null-delimited iteration handles filenames with spaces
while IFS= read -r -d '' FILE; do
  [ -f "$FILE" ] || continue

  FILE_SIZE=$(wc -c < "$FILE" 2>/dev/null)

  if [ -n "$FILE_SIZE" ] && [ "$FILE_SIZE" -gt "$MAX_BYTES" ]; then
    SIZE_KB=$(( FILE_SIZE / 1024 ))
    BLOCKED=1
    BLOCKED_FILES="$BLOCKED_FILES  $FILE  (${SIZE_KB}KB)\n"
  fi
done < <(git diff --cached --name-only -z 2>/dev/null)

if [ "$BLOCKED" -eq 1 ]; then
  echo ""
  echo "BLOCKED: One or more staged files exceed the 500KB size limit."
  echo ""
  echo "Oversized files:"
  printf "%b" "$BLOCKED_FILES"
  echo ""
  echo "Guidance:"
  echo "  - For large binary assets (images, models, datasets), use Git LFS:"
  echo "      git lfs track '*.extension'"
  echo "      git add .gitattributes"
  echo "  - For generated or build artifacts, add the file to .gitignore."
  echo "  - For large data files, consider an external storage solution"
  echo "    (S3, Google Drive, etc.) and store only a reference in the repo."
  echo ""
  exit 2
fi

exit 0
