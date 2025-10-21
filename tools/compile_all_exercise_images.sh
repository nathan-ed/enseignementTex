#!/bin/bash
# Compile all exercises to SVG images using GNU parallel
# Usage: ./compile_all_exercise_images.sh [num_jobs]

set -e

REPO_ROOT="/home/nathan/Documents/enseignement/documentsLaTeX/enseignementTex"
SRC_DIR="$REPO_ROOT/src_exos"
COMPILE_SCRIPT="$REPO_ROOT/tools/compile_exercise_image.sh"
NUM_JOBS="${1:-$(nproc)}"  # Default to number of CPU cores

echo "============================================================"
echo "Compiling all exercise images to SVG"
echo "============================================================"
echo "Source directory: $SRC_DIR"
echo "Parallel jobs: $NUM_JOBS"
echo "============================================================"
echo ""

# Get list of all exercise IDs
EXERCISE_IDS=$(find "$SRC_DIR" -name "*.tex" -type f -exec basename {} .tex \; | sort)
TOTAL=$(echo "$EXERCISE_IDS" | wc -l)

echo "Found $TOTAL exercises to compile"
echo "Starting parallel compilation..."
echo ""

# Compile in parallel with progress bar
echo "$EXERCISE_IDS" | parallel -j "$NUM_JOBS" --bar --eta \
    "bash '$COMPILE_SCRIPT' {} true svg > /dev/null 2>&1 || echo 'Failed: {}'"

echo ""
echo "============================================================"
echo "Compilation complete!"
echo "============================================================"
