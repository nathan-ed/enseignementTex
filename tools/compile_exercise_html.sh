#!/bin/bash
# Compile exercise to PNG image for web display
# Usage: ./compile_exercise_html.sh EXERCISE_ID

set -e

EXERCISE_ID="$1"
REPO_ROOT="/home/nathan/Documents/enseignement/documentsLaTeX/enseignementTex"
OUTPUT_DIR="$REPO_ROOT/output/exercises"
TEMP_DIR="$REPO_ROOT/temp_compile"

if [ -z "$EXERCISE_ID" ]; then
    echo "Error: Exercise ID required"
    exit 1
fi

if [ ! -f "$REPO_ROOT/src_exos/${EXERCISE_ID}.tex" ]; then
    echo "Error: Exercise file not found"
    exit 1
fi

mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"

# First compile to PDF (we already have this working)
WRAPPER_FILE="$TEMP_DIR/${EXERCISE_ID}_html.tex"

cat > "$WRAPPER_FILE" <<'EOF'
\documentclass[a4paper,12pt]{article}
\usepackage{../packages/coursCollege}
\newcommand{\Chapitre}{Exercise}
\renewcommand{\path}{../}
\renewcommand{\cours}{}
\pagestyle{empty}
\usepackage[margin=1cm]{geometry}

\begin{document}
EOF

echo "\\input{../src_exos/${EXERCISE_ID}.tex}" >> "$WRAPPER_FILE"

cat >> "$WRAPPER_FILE" <<'EOF'

\begin{exercice}
\Contenu
\end{exercice}

\vspace{1em}

\begin{corri}
\Solution
\end{corri}

\end{document}
EOF

# Compile to PDF
cd "$TEMP_DIR"
lualatex -interaction=nonstopmode -halt-on-error "${EXERCISE_ID}_html.tex" > /dev/null 2>&1 || {
    echo "Error compiling $EXERCISE_ID"
    exit 1
}

# Convert PDF to PNG using pdftoppm (high quality)
if command -v pdftoppm &> /dev/null; then
    pdftoppm -png -r 150 -singlefile "${EXERCISE_ID}_html.pdf" "$OUTPUT_DIR/${EXERCISE_ID}"
    echo "Success: $OUTPUT_DIR/${EXERCISE_ID}.png"
else
    # Fallback: just copy the PDF
    cp "${EXERCISE_ID}_html.pdf" "$OUTPUT_DIR/${EXERCISE_ID}_full.pdf"
    echo "Warning: pdftoppm not found. Saved PDF instead."
fi

# Cleanup
rm -f "${EXERCISE_ID}_html".*
