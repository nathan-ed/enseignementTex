#!/bin/bash
# Compile a single exercise to PDF
# Usage: ./compile_exercise.sh EXERCISE_ID [with_correction]

set -e  # Exit on error

EXERCISE_ID="$1"
SHOW_CORRECTION="${2:-false}"
REPO_ROOT="/home/nathan/Documents/enseignement/documentsLaTeX/enseignementTex"
OUTPUT_DIR="$REPO_ROOT/output/exercises"
TEMP_DIR="$REPO_ROOT/temp_compile"

# Validate input
if [ -z "$EXERCISE_ID" ]; then
    echo "Error: Exercise ID required"
    echo "Usage: $0 EXERCISE_ID [with_correction]"
    exit 1
fi

if [ ! -f "$REPO_ROOT/src_exos/${EXERCISE_ID}.tex" ]; then
    echo "Error: Exercise file not found: $REPO_ROOT/src_exos/${EXERCISE_ID}.tex"
    exit 1
fi

# Create directories
mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"

# Create temporary wrapper LaTeX file at repo root level (like 1M/ 2M/ 3M/ directories)
WRAPPER_FILE="$TEMP_DIR/${EXERCISE_ID}_wrapper.tex"

cat > "$WRAPPER_FILE" <<'EOF'
\documentclass[a4paper,12pt]{article}
\usepackage{../packages/coursCollege}
\newcommand{\Chapitre}{Exercise}
\renewcommand{\path}{../}
\renewcommand{\cours}{}
\pagestyle{empty}

\begin{document}
EOF

# Add the exercise input
echo "\\input{../src_exos/${EXERCISE_ID}.tex}" >> "$WRAPPER_FILE"

# Add exercise content
cat >> "$WRAPPER_FILE" <<'EOF'

\begin{exercice}
\Contenu
\end{exercice}
EOF

# Add correction if requested
if [ "$SHOW_CORRECTION" = "true" ] || [ "$SHOW_CORRECTION" = "yes" ] || [ "$SHOW_CORRECTION" = "1" ]; then
    cat >> "$WRAPPER_FILE" <<'EOF'

\vspace{1em}

\begin{corri}
\Solution
\end{corri}
EOF
fi

echo "\end{document}" >> "$WRAPPER_FILE"

# Compile with lualatex (silent mode) - work from temp directory (one level below root like 1M/2M/3M)
cd "$TEMP_DIR"
lualatex -interaction=nonstopmode -halt-on-error "${EXERCISE_ID}_wrapper.tex" > /dev/null 2>&1 || {
    echo "Error compiling $EXERCISE_ID"
    exit 1
}

# Move output PDF to final location
if [ -f "${EXERCISE_ID}_wrapper.pdf" ]; then
    mv "${EXERCISE_ID}_wrapper.pdf" "$OUTPUT_DIR/${EXERCISE_ID}.pdf"

    # Cleanup auxiliary files
    rm -f "${EXERCISE_ID}_wrapper".*

    echo "Success: $OUTPUT_DIR/${EXERCISE_ID}.pdf"
else
    echo "Error: PDF not generated for $EXERCISE_ID"
    exit 1
fi
