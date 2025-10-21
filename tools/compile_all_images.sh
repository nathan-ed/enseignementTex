#!/bin/bash
# Master script to compile all exercise and evaluation images
# Usage: ./compile_all_images.sh [num_jobs]

set -e

NUM_JOBS="${1:-$(nproc)}"  # Default to number of CPU cores

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
EVAL_ROOT="$(dirname "$REPO_ROOT")/evalTex"

EXERCISE_SCRIPT="$SCRIPT_DIR/compile_all_exercise_images.sh"
EVAL_SCRIPT="$EVAL_ROOT/tools/compile_all_eval_images.sh"

echo ""
echo "========================================================================"
echo "Compiling all exercises and evaluations to SVG images"
echo "========================================================================"
echo "Parallel jobs: $NUM_JOBS"
echo "========================================================================"
echo ""

# Compile exercises
if [ -f "$EXERCISE_SCRIPT" ]; then
    echo ">>> Compiling EXERCISES..."
    echo ""
    bash "$EXERCISE_SCRIPT" "$NUM_JOBS"
    echo ""
else
    echo "Warning: Exercise compilation script not found at $EXERCISE_SCRIPT"
fi

# Compile evaluations
if [ -f "$EVAL_SCRIPT" ]; then
    echo ">>> Compiling EVALUATIONS..."
    echo ""
    bash "$EVAL_SCRIPT" "$NUM_JOBS"
    echo ""
else
    echo "Warning: Evaluation compilation script not found at $EVAL_SCRIPT"
fi

echo ""
echo "========================================================================"
echo "All compilations complete!"
echo "========================================================================"
echo ""
