#!/usr/bin/env python3
"""
Extract metadata from LaTeX exercise files and create JSON sidecar files.
This script parses all .tex files in src_exos/ and extracts metadata like:
- niveau (level: 1M, 2M, 3M, etc.)
- theme (topic)
- piments (difficulty)
- annee (year)
- etc.

Creates a .json file next to each .tex file with the extracted metadata
and empty competences array for tagging.
"""

import json
import re
from pathlib import Path
from typing import Dict, Any, Optional


REPO_ROOT = Path(__file__).parent.parent
SRC_EXOS_DIR = REPO_ROOT / "src_exos"


def extract_latex_command(content: str, command: str) -> Optional[str]:
    """
    Extract the value from a LaTeX command like \\command{value}.
    Returns None if command not found.
    """
    pattern = rf'\\{command}\{{([^}}]*)\}}'
    match = re.search(pattern, content)
    return match.group(1) if match else None


def parse_exercise_file(tex_file: Path) -> Dict[str, Any]:
    """
    Parse a LaTeX exercise file and extract all metadata.
    """
    with open(tex_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # Extract metadata from LaTeX commands
    metadata = {
        'id': tex_file.stem,  # filename without extension
        'titre': extract_latex_command(content, 'titre') or '',
        'theme': extract_latex_command(content, 'theme') or '',
        'auteur': extract_latex_command(content, 'auteur') or '',
        'niveau': extract_latex_command(content, 'niveau') or '',
        'source': extract_latex_command(content, 'source') or '',
        'type': extract_latex_command(content, 'type') or '',
        'annee': extract_latex_command(content, 'annee') or '',
        'competences': [],  # Empty - to be filled via tagging app
        'tags': [],  # Additional custom tags
        'custom_tags': [],  # Custom tags: Utilisé, Hors-série, Archivé, À modifier
        'remarques': '',  # User remarks/notes
        'topic': '',  # Topic classification (auto-tagged)
    }

    # Extract numeric values
    piments_str = extract_latex_command(content, 'piments')
    pts_str = extract_latex_command(content, 'pts')

    try:
        metadata['piments'] = int(piments_str) if piments_str else 0
    except ValueError:
        metadata['piments'] = 0

    try:
        metadata['pts'] = int(pts_str) if pts_str else 0
    except ValueError:
        metadata['pts'] = 0

    return metadata


def main():
    """
    Main function to process all exercises and create JSON metadata files.
    """
    print(f"Scanning exercises in: {SRC_EXOS_DIR}")
    print()

    # Get all .tex files
    tex_files = list(SRC_EXOS_DIR.glob("*.tex"))
    print(f"Found {len(tex_files)} exercise files")

    created_count = 0
    updated_count = 0
    skipped_count = 0

    for tex_file in sorted(tex_files):
        json_file = tex_file.with_suffix('.json')

        # Extract metadata from LaTeX file
        metadata = parse_exercise_file(tex_file)

        # Check if JSON file already exists
        if json_file.exists():
            # Load existing JSON to preserve competences
            with open(json_file, 'r', encoding='utf-8') as f:
                existing_data = json.load(f)

            # Preserve competences, tags, custom_tags, remarques, and topic if they exist
            if 'competences' in existing_data:
                metadata['competences'] = existing_data['competences']
            if 'tags' in existing_data:
                metadata['tags'] = existing_data['tags']
            if 'custom_tags' in existing_data:
                metadata['custom_tags'] = existing_data['custom_tags']
            if 'remarques' in existing_data:
                metadata['remarques'] = existing_data['remarques']
            if 'topic' in existing_data:
                metadata['topic'] = existing_data['topic']

            # Only update if metadata changed
            if existing_data != metadata:
                with open(json_file, 'w', encoding='utf-8') as f:
                    json.dump(metadata, f, indent=2, ensure_ascii=False)
                updated_count += 1
                print(f"Updated: {tex_file.name}")
            else:
                skipped_count += 1
        else:
            # Create new JSON file
            with open(json_file, 'w', encoding='utf-8') as f:
                json.dump(metadata, f, indent=2, ensure_ascii=False)
            created_count += 1
            print(f"Created: {json_file.name}")

    print()
    print("=" * 60)
    print(f"Summary:")
    print(f"  Created: {created_count} new metadata files")
    print(f"  Updated: {updated_count} existing metadata files")
    print(f"  Skipped: {skipped_count} unchanged files")
    print(f"  Total:   {len(tex_files)} exercises")
    print("=" * 60)


if __name__ == "__main__":
    main()
