#!/bin/bash
# Batch compile all exercises using GNU parallel
# Usage: ./compile_all_exercises.sh [num_jobs]

set -e

REPO_ROOT="/home/nathan/Documents/enseignement/documentsLaTeX/enseignementTex"
NUM_JOBS="${1:-$(nproc)}"  # Use all CPU cores by default

echo "Starting batch compilation of all exercises..."
echo "Using $NUM_JOBS parallel jobs"
echo ""

# Get list of all exercise IDs (filenames without .tex extension)
find "$REPO_ROOT/src_exos" -name "*.tex" -type f -printf "%f\n" |
    sed 's/\.tex$//' |
    parallel -j "$NUM_JOBS" --bar --eta \
        "$REPO_ROOT/tools/compile_exercise.sh {}"

echo ""
echo "Batch compilation complete!"
echo "PDFs available in: $REPO_ROOT/output/exercises/"

# Count successful compilations
SUCCESS_COUNT=$(find "$REPO_ROOT/output/exercises" -name "*.pdf" -type f | wc -l)
TOTAL_COUNT=$(find "$REPO_ROOT/src_exos" -name "*.tex" -type f | wc -l)

echo "Successfully compiled: $SUCCESS_COUNT / $TOTAL_COUNT exercises"
