#!/bin/bash
# Backup exercise metadata and competences (JSON files)
# Note: Student data (assignments, students, classes, formative_assessments)
# should be backed up using the Data Backups feature in the web UI instead.

REPO_ROOT="/home/nathan/Documents/enseignement/documentsLaTeX/enseignementTex"
BACKUP_DIR="$REPO_ROOT/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/metadata_backup_$TIMESTAMP.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create tarball of all JSON files
echo "Creating backup of exercise metadata..."
cd "$REPO_ROOT"
tar -czf "$BACKUP_FILE" src_exos/*.json 2>/dev/null
METADATA_STATUS=$?

# Count files if archive created
FILE_COUNT=0
if [ $METADATA_STATUS -eq 0 ]; then
  FILE_COUNT=$(tar -tzf "$BACKUP_FILE" | wc -l)
fi

echo "✓ Backup created: $BACKUP_FILE"
echo "✓ Files backed up: $FILE_COUNT"
echo ""
echo "To restore from this backup:"
echo "  tar -xzf $BACKUP_FILE -C $REPO_ROOT"

# Additional backup of competences/topics
TAGGING_ROOT="/home/nathan/Documents/enseignement/documentsLaTeX/tagging_app"
COMPETENCES_DIR="$TAGGING_ROOT/competences"
if [ -d "$COMPETENCES_DIR" ]; then
  COMP_BACKUP="$BACKUP_DIR/competences_backup_$TIMESTAMP.tar.gz"
  echo "Creating backup of competences and topics..."
  tar -czf "$COMP_BACKUP" -C "$COMPETENCES_DIR" . 2>/dev/null
  COMP_STATUS=$?
  echo "✓ Competences backup created: $COMP_BACKUP"
  echo ""
  echo "To restore competences:"
  echo "  tar -xzf $COMP_BACKUP -C $COMPETENCES_DIR"
else
  echo "⚠️  Competences directory not found: $COMPETENCES_DIR"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ℹ️  Student Data Backup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Student data (assignments, students, classes, formative"
echo "assessments) is now managed separately."
echo ""
echo "To backup student data, use the web UI:"
echo "  👉 Navigate to '💾 Data Backups' in the menu"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

EXIT_CODE=0
if [ $METADATA_STATUS -ne 0 ]; then
  echo "⚠️  Warning: exercise metadata archive failed (exit code $METADATA_STATUS)."
  EXIT_CODE=$METADATA_STATUS
fi
if [ ${COMP_STATUS:-0} -ne 0 ]; then
  echo "⚠️  Warning: competences archive failed (exit code ${COMP_STATUS})."
  EXIT_CODE=${COMP_STATUS}
fi

# Keep only last 10 backups
cd "$BACKUP_DIR"
ls -t metadata_backup_*.tar.gz 2>/dev/null | tail -n +11 | xargs -r rm
ls -t competences_backup_*.tar.gz 2>/dev/null | tail -n +11 | xargs -r rm
echo ""
echo "Old backups cleaned (keeping last 10)"

exit $EXIT_CODE
