---
name: test-troubleshooter
description: Troubleshoot flaky or failing tests by running them multiple times and capturing detailed output. Use when investigating test failures, debugging intermittent/flaky tests, or when asked to run tests repeatedly to understand failure patterns. CRITICAL - Always use the batch runner script to ensure failure data is captured.
---

# Test Troubleshooter

Investigate flaky or failing tests by running them in batches with full output capture.

## Critical Rule

**NEVER run tests in a loop without capturing output.** Always use `scripts/batch_test_runner.py` which:
- Runs the test N times
- Captures full stdout/stderr for each run
- Extracts and summarizes failure reasons
- Provides pass/fail statistics

## Workflow

### 1. Run the Batch Test Runner

```bash
python3 /Users/craigisrael/.claude/skills/test-troubleshooter/scripts/batch_test_runner.py \
  --command "task backend:test_eval -- -k 'test_name' -v" \
  --runs 10 \
  --output /tmp/test_results
```

Parameters:
- `--command`: The full test command to run (quoted)
- `--runs`: Number of times to run (default: 10)
- `--output`: Directory to store results (default: /tmp/test_batch_results)

### 2. Review Results

The script creates:
- `summary.json` - Pass/fail counts and failure patterns
- `run_N.txt` - Full output for each run
- `failures.txt` - Extracted failure details from all failing runs

### 3. Analyze Failures

Read `failures.txt` to understand:
- What specific assertions failed
- What the actual vs expected values were
- Whether failures are consistent or varied

### 4. Fix and Verify

After making fixes, run the batch again to verify improvement. Target: 100% pass rate over 20 runs.

## Example

```bash
# Investigate a flaky eval test
python3 /Users/craigisrael/.claude/skills/test-troubleshooter/scripts/batch_test_runner.py \
  --command "task backend:test_eval -- -k 'test_clarification_response' -v" \
  --runs 20 \
  --output /tmp/clarification_test

# Check results
cat /tmp/clarification_test/summary.json
cat /tmp/clarification_test/failures.txt
```
