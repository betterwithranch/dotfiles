#!/usr/bin/env python3
"""
PostToolUse hook for chrome-devtools MCP tools.
Notifies the user when the chrome-devtools MCP fails to connect.
"""

import json
import logging
import subprocess
import sys
from pathlib import Path

# Set up logging to a shared hooks log file
LOG_FILE = Path.home() / '.claude' / 'hooks' / 'hooks.log'
logging.basicConfig(
    filename=str(LOG_FILE),
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('notify-chrome-devtools-error')


def send_notification(title: str, message: str):
    """Send a macOS notification."""
    script = f'display notification "{message}" with title "{title}"'
    subprocess.run(['osascript', '-e', script], capture_output=True)


def check_chrome_debug_running() -> tuple[bool, str]:
    """Check if Chrome Debug is running on port 9222."""
    try:
        import urllib.request
        req = urllib.request.Request('http://localhost:9222/json/version', method='GET')
        urllib.request.urlopen(req, timeout=2)
        return True, ""
    except Exception as e:
        return False, str(e)


def main():
    logger.info("=" * 50)
    logger.info("Hook started: notify-chrome-devtools-error.py")

    try:
        raw_input = sys.stdin.read()
        logger.debug(f"Raw stdin: {raw_input[:1000]}")
        input_data = json.loads(raw_input)
    except json.JSONDecodeError as e:
        logger.error(f"JSON decode error: {e}")
        sys.exit(0)

    tool_name = input_data.get('tool_name', '')
    tool_response = input_data.get('tool_response', {})

    logger.debug(f"Tool name: {tool_name}")
    logger.debug(f"Tool response type: {type(tool_response)}")

    # Check if this is an error response
    is_error = False
    error_message = ""

    if isinstance(tool_response, dict):
        is_error = tool_response.get('is_error', False) or tool_response.get('isError', False)
        error_message = tool_response.get('error', '') or tool_response.get('message', '')
        if not error_message and 'content' in tool_response:
            content = tool_response['content']
            if isinstance(content, list) and content:
                error_message = content[0].get('text', '') if isinstance(content[0], dict) else str(content[0])
            elif isinstance(content, str):
                error_message = content
    elif isinstance(tool_response, str):
        # Check for common error patterns in string responses
        lower_response = tool_response.lower()
        if 'error' in lower_response or 'failed' in lower_response or 'connect' in lower_response:
            is_error = True
            error_message = tool_response

    logger.debug(f"Is error: {is_error}, Error message: {error_message}")

    if is_error or 'failed' in str(tool_response).lower() or 'error' in str(tool_response).lower():
        logger.info("Detected chrome-devtools error, checking Chrome Debug status")

        chrome_running, chrome_error = check_chrome_debug_running()

        if not chrome_running:
            title = "Chrome DevTools MCP Error"
            message = f"Chrome Debug not running on port 9222. Launch: open ~/Applications/Chrome\\ Debug.app"

            send_notification(title, message)
            logger.info(f"Sent notification: {title} - {message}")

            # Output to Claude to inform about the issue
            output = {
                'decision': 'block',
                'reason': (
                    f"Chrome DevTools MCP failed. Chrome Debug is not running on port 9222.\n\n"
                    f"Error: {error_message}\n\n"
                    f"To fix:\n"
                    f"1. Launch Chrome Debug: open ~/Applications/Chrome\\ Debug.app\n"
                    f"2. Wait a few seconds for it to start\n"
                    f"3. Retry the operation"
                )
            }
            print(json.dumps(output))
        else:
            # Chrome is running but there's still an error
            title = "Chrome DevTools MCP Error"
            message = f"Tool error: {error_message[:100]}"

            send_notification(title, message)
            logger.info(f"Sent notification (Chrome running): {title} - {message}")

            output = {
                'decision': 'block',
                'reason': (
                    f"Chrome DevTools MCP error (Chrome Debug is running):\n\n"
                    f"Error: {error_message}\n\n"
                    f"Chrome Debug is running on port 9222, but the tool still failed. "
                    f"This may be a different issue."
                )
            }
            print(json.dumps(output))


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        logger.exception(f"Unhandled exception: {e}")
        raise
