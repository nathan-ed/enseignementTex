#!/bin/bash
# Backup all exercise metadata (JSON files)

REPO_ROOT="/home/nathan/Documents/enseignement/documentsLaTeX/enseignementTex"
BACKUP_DIR="$REPO_ROOT/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/metadata_backup_$TIMESTAMP.tar.gz"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Create tarball of all JSON files
echo "Creating backup of all exercise metadata..."
cd "$REPO_ROOT"
tar -czf "$BACKUP_FILE" src_exos/*.json
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
  tar -czf "$COMP_BACKUP" -C "$COMPETENCES_DIR" .
  COMP_STATUS=$?
  echo "✓ Competences backup created: $COMP_BACKUP"
  echo ""
  echo "To restore competences:"
  echo "  tar -xzf $COMP_BACKUP -C $COMPETENCES_DIR"
else
  echo "⚠️  Competences directory not found: $COMPETENCES_DIR"
fi

# Backup assignments
ASSIGNMENTS_DIR="$TAGGING_ROOT/assignments"
if [ -d "$ASSIGNMENTS_DIR" ]; then
  ASSIGN_BACKUP="$BACKUP_DIR/assignments_backup_$TIMESTAMP.tar.gz"
  echo "Creating backup of assignments..."
  tar -czf "$ASSIGN_BACKUP" -C "$ASSIGNMENTS_DIR" .
  ASSIGN_STATUS=$?
  echo "✓ Assignments backup created: $ASSIGN_BACKUP"
  echo ""
  echo "To restore assignments:"
  echo "  tar -xzf $ASSIGN_BACKUP -C $ASSIGNMENTS_DIR"
else
  echo "⚠️  Assignments directory not found: $ASSIGNMENTS_DIR"
fi

# Backup student registry
STUDENTS_DIR="$TAGGING_ROOT/students"
if [ -d "$STUDENTS_DIR" ]; then
  STUDENTS_BACKUP="$BACKUP_DIR/students_backup_$TIMESTAMP.tar.gz"
  echo "Creating backup of student registry..."
  tar -czf "$STUDENTS_BACKUP" -C "$STUDENTS_DIR" .
  STUDENTS_STATUS=$?
  echo "✓ Students backup created: $STUDENTS_BACKUP"
  echo ""
  echo "To restore students:"
  echo "  tar -xzf $STUDENTS_BACKUP -C $STUDENTS_DIR"
else
  echo "⚠️  Students directory not found: $STUDENTS_DIR"
fi

EXIT_CODE=0
if [ $METADATA_STATUS -ne 0 ]; then
  echo "⚠️  Warning: exercise metadata archive failed (exit code $METADATA_STATUS)."
  EXIT_CODE=$METADATA_STATUS
fi
if [ ${COMP_STATUS:-0} -ne 0 ]; then
  echo "⚠️  Warning: competences archive failed (exit code ${COMP_STATUS})."
  EXIT_CODE=${COMP_STATUS}
fi
if [ ${ASSIGN_STATUS:-0} -ne 0 ]; then
  echo "⚠️  Warning: assignments archive failed (exit code ${ASSIGN_STATUS})."
  EXIT_CODE=${ASSIGN_STATUS}
fi
if [ ${STUDENTS_STATUS:-0} -ne 0 ]; then
  echo "⚠️  Warning: students archive failed (exit code ${STUDENTS_STATUS})."
  EXIT_CODE=${STUDENTS_STATUS}
fi

# Keep only last 10 backups
cd "$BACKUP_DIR"
ls -t metadata_backup_*.tar.gz | tail -n +11 | xargs -r rm
ls -t competences_backup_*.tar.gz | tail -n +11 | xargs -r rm
ls -t assignments_backup_*.tar.gz | tail -n +11 | xargs -r rm
ls -t students_backup_*.tar.gz | tail -n +11 | xargs -r rm
echo ""
echo "Old backups cleaned (keeping last 10)"
