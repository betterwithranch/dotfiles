#!/Users/craigisrael/dev/sanctum/otter-2/backend/.venv/bin/python
"""
Analyze Claude Code conversations for a specific day to extract
feedback patterns useful for improving skills.

Two-stage approach:
1. Regex filtering (fast, free) - finds candidates
2. LLM analysis (accurate, costs $) - validates and categorizes

Usage:
    analyze-daily-conversations.py [--date YYYY-MM-DD] [--output json|markdown]
"""

import argparse
import json
import re
import sys
from collections import defaultdict
from datetime import date, datetime
from pathlib import Path


CATEGORIES = [
    "mocking_and_patching",
    "llm_testing",
    "circular_dependencies",
    "test_fixtures",
    "import_organization",
    "type_annotations",
    "naming_conventions",
    "comments_documentation",
    "code_structure",
    "dependency_injection",
    "testing_philosophy",
    "over_engineering",
    "other",
]

ANALYSIS_PROMPT = """Analyze this user message from a coding conversation. Determine if it contains feedback or a correction about code quality practices.

Message:
{message}

Respond with JSON only:
{{
  "is_feedback": true/false,
  "category": "one of: {categories}",
  "instruction": "The actionable instruction (e.g., 'Use TestModel instead of patching run_sync')",
  "confidence": 0.0-1.0
}}

Only mark is_feedback=true if the user is correcting Claude's approach or stating a preference about how code should be written. Questions, task requests, and general discussion are NOT feedback."""


def find_transcripts_for_date(target_date: date) -> list[Path]:
    """Find all transcript files modified on the target date for sanctum projects."""
    projects_dir = Path.home() / ".claude" / "projects"
    transcripts = []

    for jsonl_file in projects_dir.rglob("*.jsonl"):
        file_path_str = str(jsonl_file)
        if "subagents" in file_path_str:
            continue
        # Only include sanctum project transcripts
        if "sanctum" not in file_path_str:
            continue
        mtime = datetime.fromtimestamp(jsonl_file.stat().st_mtime).date()
        if mtime == target_date:
            transcripts.append(jsonl_file)

    return transcripts


def extract_user_messages(transcript: Path) -> list[dict]:
    """Extract user messages from a transcript file."""
    messages = []
    with open(transcript) as f:
        for line in f:
            try:
                data = json.loads(line.strip())
                if data.get("type") == "user" and data.get("message", {}).get("role") == "user":
                    content = data["message"].get("content", "")
                    if isinstance(content, str) and 30 < len(content) < 2000:
                        # Skip meta messages and command outputs
                        if content.startswith("<") and "command" in content.lower():
                            continue
                        messages.append(
                            {
                                "content": content,
                                "timestamp": data.get("timestamp"),
                                "session_id": data.get("sessionId"),
                            }
                        )
            except json.JSONDecodeError:
                continue
    return messages


def regex_filter_candidates(messages: list[dict]) -> list[dict]:
    """Stage 1: Use regex to filter likely feedback candidates."""
    candidates = []

    corrective_patterns = [
        r"don't\s+\w+",
        r"shouldn't\s+\w+",
        r"should\s+not",
        r"should\s+be",
        r"instead\s+of",
        r"we\s+should",
        r"fix\s+this",
        r"never\s+\w+",
        r"always\s+\w+",
        r"prefer\s+\w+",
        r"use\s+\w+\s+instead",
    ]

    topic_keywords = [
        "mock",
        "patch",
        "testmodel",
        "test model",
        "type_checking",
        "circular",
        "import",
        "typing",
        "any",
        "naming",
        "confusing",
        "rename",
        "comment",
        "docstring",
        "fixture",
        "factory",
        "dependency",
        "inject",
        "extract",
        "refactor",
        "duplicate",
    ]

    for msg in messages:
        content_lower = msg["content"].lower()

        # Check for corrective language patterns
        has_correction = any(re.search(p, content_lower) for p in corrective_patterns)

        # Check for topic keywords
        has_topic = any(kw in content_lower for kw in topic_keywords)

        if has_correction or has_topic:
            candidates.append(msg)

    return candidates


def llm_analyze_candidates(candidates: list[dict], client) -> list[dict]:
    """Stage 2: Use Claude to analyze and validate candidates."""
    analyzed = []

    for candidate in candidates:
        try:
            response = client.messages.create(
                model="us.anthropic.claude-sonnet-4-20250514-v1:0",
                max_tokens=256,
                messages=[
                    {
                        "role": "user",
                        "content": ANALYSIS_PROMPT.format(
                            message=candidate["content"],
                            categories=", ".join(CATEGORIES),
                        ),
                    }
                ],
            )

            # Parse response
            response_text = response.content[0].text
            # Extract JSON from response
            json_match = re.search(r"\{[^}]+\}", response_text, re.DOTALL)
            if json_match:
                analysis = json.loads(json_match.group())

                if analysis.get("is_feedback") and analysis.get("confidence", 0) > 0.6:
                    analyzed.append(
                        {
                            **candidate,
                            "category": analysis.get("category", "other"),
                            "instruction": analysis.get("instruction", ""),
                            "confidence": analysis.get("confidence", 0),
                        }
                    )
        except Exception as e:
            print(f"Warning: Failed to analyze message: {e}", file=sys.stderr)
            continue

    return analyzed


def output_markdown(results: dict, target_date: date) -> str:
    """Format results as markdown."""
    lines = [
        f"# Conversation Analysis for {target_date}",
        "",
        f"**Transcripts analyzed:** {results['transcript_count']}",
        f"**Messages scanned:** {results['messages_scanned']}",
        f"**Candidates filtered (regex):** {results['candidates_filtered']}",
        f"**Feedback confirmed (LLM):** {len(results['feedback_items'])}",
        "",
        "## Category Counts",
        "",
    ]

    for cat, count in sorted(results["category_counts"].items(), key=lambda x: -x[1]):
        lines.append(f"- **{cat}**: {count}")

    lines.extend(["", "## Confirmed Feedback Items", ""])

    for i, item in enumerate(results["feedback_items"], 1):
        lines.append(
            f"### {i}. {item.get('category', 'unknown')} (confidence: {item.get('confidence', 0):.0%})"
        )
        lines.append(f"**Instruction:** {item.get('instruction', 'N/A')}")
        lines.append(f"**Original:** {item['content'][:200]}...")
        lines.append("")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="Analyze daily Claude conversations for skill improvement feedback"
    )
    parser.add_argument(
        "--date", type=str, help="Date to analyze (YYYY-MM-DD), defaults to today"
    )
    parser.add_argument(
        "--output", choices=["json", "markdown"], default="markdown"
    )

    args = parser.parse_args()

    target_date = (
        datetime.strptime(args.date, "%Y-%m-%d").date() if args.date else date.today()
    )

    # Find transcripts
    transcripts = find_transcripts_for_date(target_date)
    if not transcripts:
        print(f"No transcripts found for {target_date}")
        return

    # Extract all user messages
    all_messages = []
    for transcript in transcripts:
        all_messages.extend(extract_user_messages(transcript))

    # Stage 1: Regex filter
    candidates = regex_filter_candidates(all_messages)

    results = {
        "date": str(target_date),
        "transcript_count": len(transcripts),
        "messages_scanned": len(all_messages),
        "candidates_filtered": len(candidates),
        "feedback_items": [],
        "category_counts": defaultdict(int),
    }

    # Stage 2: LLM analysis via Bedrock
    try:
        import anthropic
    except ImportError:
        print(
            "Error: anthropic package not installed. Run: pip install anthropic",
            file=sys.stderr,
        )
        sys.exit(1)

    client = anthropic.AnthropicBedrock()
    analyzed = llm_analyze_candidates(candidates, client)

    results["feedback_items"] = analyzed
    for item in analyzed:
        results["category_counts"][item["category"]] += 1

    results["category_counts"] = dict(results["category_counts"])

    if args.output == "json":
        print(json.dumps(results, indent=2))
    else:
        print(output_markdown(results, target_date))


if __name__ == "__main__":
    main()
