#!/bin/bash
# Compile exercise to cropped SVG/PNG image for web display
# Usage: ./compile_exercise_image.sh EXERCISE_ID [with_correction] [format]
# format: svg (default), png, or both

set -e

EXERCISE_ID="$1"
SHOW_CORRECTION="${2:-true}"
FORMAT="${3:-svg}"
REPO_ROOT="/home/nathan/Documents/enseignement/documentsLaTeX/enseignementTex"
OUTPUT_DIR="$REPO_ROOT/output/exercises"
TEMP_DIR="$REPO_ROOT/temp_compile"

if [ -z "$EXERCISE_ID" ]; then
    echo "Error: Exercise ID required"
    echo "Usage: $0 EXERCISE_ID [with_correction] [format]"
    echo "Format options: svg (default), png, both"
    exit 1
fi

if [ ! -f "$REPO_ROOT/src_exos/${EXERCISE_ID}.tex" ]; then
    echo "Error: Exercise file not found: $REPO_ROOT/src_exos/${EXERCISE_ID}.tex"
    exit 1
fi

mkdir -p "$OUTPUT_DIR" "$TEMP_DIR"

# Create temporary wrapper LaTeX file
WRAPPER_FILE="$TEMP_DIR/${EXERCISE_ID}_img.tex"

cat > "$WRAPPER_FILE" <<'EOF'
\documentclass[a4paper,12pt]{article}
\usepackage{../packages/coursCollege}
\newcommand{\Chapitre}{Exercise}
\renewcommand{\path}{../}
\renewcommand{\cours}{}
\pagestyle{empty}
% geometry is already loaded by coursCollege.sty

\begin{document}
EOF

echo "\\input{../src_exos/${EXERCISE_ID}.tex}" >> "$WRAPPER_FILE"

cat >> "$WRAPPER_FILE" <<'EOF'

\begin{exercice}
\Contenu
\end{exercice}
EOF

if [ "$SHOW_CORRECTION" = "true" ] || [ "$SHOW_CORRECTION" = "yes" ] || [ "$SHOW_CORRECTION" = "1" ]; then
    cat >> "$WRAPPER_FILE" <<'EOF'

\vspace{1em}
\hrule
\vspace{1em}

\begin{corri}
\Solution
\end{corri}
EOF
fi

echo "\end{document}" >> "$WRAPPER_FILE"

# Compile with lualatex
cd "$TEMP_DIR"
lualatex -interaction=nonstopmode -halt-on-error "${EXERCISE_ID}_img.tex" > /dev/null 2>&1 || {
    echo "Error compiling $EXERCISE_ID"
    exit 1
}

# Crop the PDF to remove whitespace
pdfcrop --margins 10 "${EXERCISE_ID}_img.pdf" "${EXERCISE_ID}_cropped.pdf" > /dev/null 2>&1

# Convert based on requested format
if [ "$FORMAT" = "pdf" ]; then
    # Just copy the cropped PDF to output directory
    cp "${EXERCISE_ID}_cropped.pdf" "$OUTPUT_DIR/${EXERCISE_ID}.pdf"
    echo "Success: $OUTPUT_DIR/${EXERCISE_ID}.pdf"
elif [ "$FORMAT" = "svg" ] || [ "$FORMAT" = "both" ]; then
    # Convert to SVG with transparent background using pdftocairo
    pdftocairo -svg "${EXERCISE_ID}_cropped.pdf" "$OUTPUT_DIR/${EXERCISE_ID}.svg"
    echo "Success: $OUTPUT_DIR/${EXERCISE_ID}.svg"
fi

if [ "$FORMAT" = "png" ] || [ "$FORMAT" = "both" ]; then
    # Convert cropped PDF to high-quality PNG
    # -r 200 = 200 DPI (high quality for web)
    pdftoppm -png -r 200 -singlefile "${EXERCISE_ID}_cropped.pdf" "$OUTPUT_DIR/${EXERCISE_ID}"
    echo "Success: $OUTPUT_DIR/${EXERCISE_ID}.png"
fi

# Cleanup
rm -f "${EXERCISE_ID}_img".*
rm -f "${EXERCISE_ID}_cropped.pdf"
