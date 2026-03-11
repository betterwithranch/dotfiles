#!/usr/bin/env python3
"""
PostToolUse hook for ExitPlanMode.
Automatically renames the current session's plan file based on its content.
"""

import json
import logging
import re
import sys
from datetime import datetime
from pathlib import Path

# Set up logging to a shared hooks log file
LOG_FILE = Path.home() / '.claude' / 'hooks' / 'hooks.log'
logging.basicConfig(
    filename=str(LOG_FILE),
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('rename-plan-after-exit')


def slugify(text: str, max_length: int = 50) -> str:
    """Convert text to a URL-friendly slug."""
    text = text.lower()
    text = re.sub(r'[^a-z0-9\s]', '', text)
    text = re.sub(r'\s+', '-', text.strip())
    text = re.sub(r'-+', '-', text)
    text = text.strip('-')
    return text[:max_length]


def extract_name_from_heading(content: str) -> str | None:
    """Extract name from the first markdown heading."""
    lines = content.split('\n')[:20]
    for line in lines:
        match = re.match(r'^#+\s*(.+)$', line)
        if match:
            result = slugify(match.group(1))
            logger.debug(f"Extracted name from heading: {result}")
            return result
    return None


def extract_name_from_camelcase(content: str) -> str | None:
    """Extract name from CamelCase patterns in the content."""
    lines = content.split('\n')[:50]
    text = '\n'.join(lines)
    match = re.search(r'[A-Z][a-z]+[A-Z][a-zA-Z]+', text)
    if match:
        camel = match.group(0)
        # Convert CamelCase to kebab-case
        kebab = re.sub(r'([A-Z])', r'-\1', camel).lower().strip('-')
        logger.debug(f"Extracted name from camelcase: {kebab}")
        return kebab
    return None


def extract_name_from_words(content: str) -> str | None:
    """Extract name from first few meaningful words."""
    lines = content.split('\n')[:5]
    text = ' '.join(lines)
    words = re.findall(r'[a-zA-Z0-9]+', text)[:4]
    if words:
        result = '-'.join(w.lower() for w in words)
        logger.debug(f"Extracted name from words: {result}")
        return result
    return None


def extract_plan_name(plan_path: Path) -> str | None:
    """Extract a meaningful name from plan content using multiple strategies."""
    try:
        content = plan_path.read_text()
        logger.debug(f"Read plan file: {plan_path}, size: {len(content)} bytes")
    except (IOError, OSError) as e:
        logger.error(f"Error reading plan file: {e}")
        return None

    # Try strategies in order of preference
    name = extract_name_from_heading(content)
    if name and len(name) >= 3:
        logger.info(f"Using name from heading: {name}")
        return name

    name = extract_name_from_camelcase(content)
    if name and len(name) >= 3:
        logger.info(f"Using name from camelcase: {name}")
        return name

    name = extract_name_from_words(content)
    if name and len(name) >= 3:
        logger.info(f"Using name from words: {name}")
        return name

    logger.warning("Could not extract a meaningful name from plan")
    return None


def main():
    logger.info("=" * 50)
    logger.info("Hook started: rename-plan-after-exit.py")

    plans_dir = Path.home() / '.claude' / 'plans'
    logger.debug(f"Plans directory: {plans_dir}")

    if not plans_dir.is_dir():
        logger.error(f"Plans directory does not exist: {plans_dir}")
        sys.exit(0)

    # Log raw stdin for debugging
    try:
        raw_input = sys.stdin.read()
        logger.debug(f"Raw stdin length: {len(raw_input)} bytes")
        logger.debug(f"Raw stdin preview: {raw_input[:500]}...")
        input_data = json.loads(raw_input)
        logger.debug(f"Parsed input keys: {list(input_data.keys())}")
    except json.JSONDecodeError as e:
        logger.error(f"JSON decode error: {e}")
        sys.exit(0)

    # Get the plan file path directly from tool_response.filePath
    tool_response = input_data.get('tool_response', {})
    file_path = tool_response.get('filePath')
    logger.debug(f"File path from tool_response: {file_path}")

    if not file_path:
        logger.error("No filePath in tool_response")
        logger.debug(f"tool_response: {json.dumps(tool_response, indent=2)[:500]}")
        sys.exit(0)

    plan_file = Path(file_path)
    logger.debug(f"Looking for plan file: {plan_file}")

    if not plan_file.is_file():
        logger.error(f"Plan file does not exist: {plan_file}")
        # List existing plan files for debugging
        existing_plans = list(plans_dir.glob('*.md'))
        logger.debug(f"Existing plan files: {[p.name for p in existing_plans]}")
        sys.exit(0)

    original_name = plan_file.stem  # filename without extension
    new_name = extract_plan_name(plan_file)
    logger.debug(f"Original name: {original_name}")
    logger.debug(f"Extracted new name: {new_name}")

    if not new_name:
        logger.warning("No new name extracted, keeping original")
        sys.exit(0)

    if new_name == original_name:
        logger.info("New name same as original, no rename needed")
        sys.exit(0)

    new_path = plans_dir / f'{new_name}.md'
    logger.debug(f"Target new path: {new_path}")

    # Don't overwrite existing files
    if new_path.exists():
        timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
        new_path = plans_dir / f'{new_name}-{timestamp}.md'
        logger.debug(f"Target exists, using timestamped path: {new_path}")

    # Rename the file
    try:
        plan_file.rename(new_path)
        logger.info(f"Successfully renamed: {plan_file.name} -> {new_path.name}")
    except OSError as e:
        logger.error(f"Error renaming file: {e}")
        # Report the error to Claude
        output = {
            'decision': 'block',
            'reason': f"Failed to rename plan file: {e}"
        }
        print(json.dumps(output))
        sys.exit(1)

    # Success - report the new filename to Claude so it can update its context
    logger.info(f"Rename complete: {original_name}.md -> {new_path.name}")
    output = {
        'decision': 'continue',
        'message': f"Plan file renamed: {plan_file.name} → {new_path.name}\nNew path: {new_path}"
    }
    print(json.dumps(output))


def report_error(message: str):
    """Report an error to Claude and exit."""
    logger.error(message)
    output = {
        'decision': 'block',
        'reason': f"Plan rename hook error: {message}"
    }
    print(json.dumps(output))
    sys.exit(1)


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        logger.exception(f"Unhandled exception: {e}")
        # Report unhandled exceptions to Claude
        output = {
            'decision': 'block',
            'reason': f"Plan rename hook crashed: {e}"
        }
        print(json.dumps(output))
        sys.exit(1)
