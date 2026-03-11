#!/usr/bin/env python3
"""
Batch test runner for troubleshooting flaky tests.
Runs a test command multiple times and captures detailed output for analysis.
"""

import argparse
import json
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path


def run_test(command: str, run_number: int, output_dir: Path) -> dict:
    """Run a single test and capture output."""
    print(f"=== Run {run_number} ===", flush=True)

    result = subprocess.run(
        command,
        shell=True,
        capture_output=True,
        text=True,
    )

    output = result.stdout + "\n" + result.stderr
    output_file = output_dir / f"run_{run_number}.txt"
    output_file.write_text(output)

    passed = result.returncode == 0
    status = "PASSED" if passed else "FAILED"
    print(f"  {status}", flush=True)

    return {
        "run": run_number,
        "passed": passed,
        "return_code": result.returncode,
        "output_file": str(output_file),
    }


def extract_failure_info(output: str) -> str:
    """Extract relevant failure information from test output."""
    lines = output.split("\n")
    failure_lines = []
    capturing = False

    for line in lines:
        # Start capturing at failure markers
        if any(marker in line for marker in ["FAILED", "AssertionError", "Error:", "FAILURES", "list is None"]):
            capturing = True

        if capturing:
            failure_lines.append(line)

        # Stop after captured enough context
        if capturing and len(failure_lines) > 50:
            break

    # Also look for specific patterns
    patterns = [
        r"AssertionError.*",
        r".*FAILED.*",
        r".*list is None.*",
        r".*pass rate \d+.*",
        r".*expected.*got.*",
    ]

    for line in lines:
        for pattern in patterns:
            if re.search(pattern, line, re.IGNORECASE):
                if line not in failure_lines:
                    failure_lines.append(line)

    return "\n".join(failure_lines[:100])  # Limit output


def main():
    parser = argparse.ArgumentParser(description="Run tests multiple times and capture results")
    parser.add_argument("--command", "-c", required=True, help="Test command to run")
    parser.add_argument("--runs", "-n", type=int, default=10, help="Number of runs (default: 10)")
    parser.add_argument("--output", "-o", default="/tmp/test_batch_results", help="Output directory")

    args = parser.parse_args()

    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Running: {args.command}")
    print(f"Runs: {args.runs}")
    print(f"Output: {output_dir}")
    print("=" * 60)

    results = []
    for i in range(1, args.runs + 1):
        result = run_test(args.command, i, output_dir)
        results.append(result)

    # Calculate summary
    passed = sum(1 for r in results if r["passed"])
    failed = args.runs - passed
    pass_rate = (passed / args.runs) * 100

    summary = {
        "command": args.command,
        "total_runs": args.runs,
        "passed": passed,
        "failed": failed,
        "pass_rate": f"{pass_rate:.1f}%",
        "timestamp": datetime.now().isoformat(),
        "results": results,
    }

    # Write summary
    summary_file = output_dir / "summary.json"
    summary_file.write_text(json.dumps(summary, indent=2))

    # Extract and consolidate failures
    failures_file = output_dir / "failures.txt"
    failure_details = []

    for result in results:
        if not result["passed"]:
            output = Path(result["output_file"]).read_text()
            failure_info = extract_failure_info(output)
            failure_details.append(f"=== Run {result['run']} ===\n{failure_info}\n")

    failures_file.write_text("\n".join(failure_details))

    # Print summary
    print("=" * 60)
    print(f"SUMMARY: {passed}/{args.runs} passed ({pass_rate:.1f}%)")
    print(f"Results saved to: {output_dir}")
    print(f"  - summary.json: Pass/fail statistics")
    print(f"  - run_N.txt: Full output for each run")
    print(f"  - failures.txt: Extracted failure details")

    if failed > 0:
        print(f"\nFailure details in: {failures_file}")
        sys.exit(1)

    sys.exit(0)


if __name__ == "__main__":
    main()
