#!/usr/bin/env python3
"""
Auto-tag exercises with topics based on their theme field.
Uses theme_mapping from topics_1M.yaml and topics_3M.yaml.
"""

import json
import yaml
from pathlib import Path
from typing import Dict, Optional


REPO_ROOT = Path(__file__).parent.parent
SRC_EXOS_DIR = REPO_ROOT / "src_exos"
COMPETENCES_DIR = REPO_ROOT / "competences"


def load_topic_config(niveau: str) -> Dict:
    """Load topic configuration for a given niveau."""
    yaml_file = COMPETENCES_DIR / f"topics_{niveau}.yaml"

    if not yaml_file.exists():
        return {}

    with open(yaml_file, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)


def map_theme_to_topic(theme: str, niveau: str) -> Optional[str]:
    """Map an exercise theme to a topic using the theme_mapping."""
    config = load_topic_config(niveau)
    theme_mapping = config.get('theme_mapping', {})

    # Try exact match first
    if theme in theme_mapping:
        return theme_mapping[theme]

    # Try partial match (theme contains keyword)
    theme_lower = theme.lower()
    for keyword, topic in theme_mapping.items():
        if keyword in theme_lower:
            return topic

    return None


def main():
    """Auto-tag all exercises with topics."""
    print("Auto-tagging exercises with topics...")
    print()

    json_files = list(SRC_EXOS_DIR.glob("*.json"))

    tagged_count = 0
    untagged_count = 0

    for json_file in sorted(json_files):
        with open(json_file, 'r', encoding='utf-8') as f:
            metadata = json.load(f)

        niveau = metadata.get('niveau')
        theme = metadata.get('theme', '')

        if not niveau or not theme:
            continue

        # Map theme to topic
        topic = map_theme_to_topic(theme, niveau)

        if topic:
            # Update metadata
            old_topic = metadata.get('topic', '')
            metadata['topic'] = topic

            # Save metadata
            with open(json_file, 'w', encoding='utf-8') as f:
                json.dump(metadata, f, indent=2, ensure_ascii=False)

            tagged_count += 1
            if old_topic != topic:
                print(f"Tagged {metadata['id']}: {theme} -> {topic}")
        else:
            untagged_count += 1
            if theme:
                print(f"⚠️  Could not map theme '{theme}' for {metadata['id']} (niveau: {niveau})")

    print()
    print("=" * 60)
    print(f"Summary:")
    print(f"  Tagged: {tagged_count} exercises")
    print(f"  Could not tag: {untagged_count} exercises")
    print(f"  Total: {len(json_files)} exercises")
    print("=" * 60)


if __name__ == "__main__":
    main()
