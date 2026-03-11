#!/usr/bin/env python3
"""
SessionStart hook to validate chrome-devtools MCP configuration.
Only notifies if there's an actual configuration problem, not if Chrome isn't running.
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
logger = logging.getLogger('check-chrome-debug-on-start')


def send_notification(title: str, message: str):
    """Send a macOS notification."""
    script = f'display notification "{message}" with title "{title}"'
    subprocess.run(['osascript', '-e', script], capture_output=True)


def parse_version(version_str: str) -> tuple[int, int, int]:
    """Parse a version string like '20.19.0' into a tuple of ints."""
    # Strip 'v' prefix if present
    version_str = version_str.lstrip('v')
    parts = version_str.split('.')
    return (
        int(parts[0]) if len(parts) > 0 else 0,
        int(parts[1]) if len(parts) > 1 else 0,
        int(parts[2].split('-')[0]) if len(parts) > 2 else 0  # Handle pre-release versions
    )


def check_node_version_compatible(required_engines: str, current_version: str) -> tuple[bool, str]:
    """
    Check if current Node version satisfies the engines requirement.
    Supports patterns like: ^20.19.0 || ^22.12.0 || >=23
    """
    current = parse_version(current_version)
    logger.debug(f"Checking Node {current_version} against requirement: {required_engines}")

    # Parse the requirement (e.g., "^20.19.0 || ^22.12.0 || >=23")
    alternatives = [alt.strip() for alt in required_engines.split('||')]

    for alt in alternatives:
        alt = alt.strip()

        if alt.startswith('^'):
            # Caret range: ^20.19.0 means >=20.19.0 and <21.0.0
            req = parse_version(alt[1:])
            if current[0] == req[0] and (current[1], current[2]) >= (req[1], req[2]):
                return True, f"Node {current_version} satisfies {alt}"

        elif alt.startswith('>='):
            # Greater than or equal
            req = parse_version(alt[2:])
            if current >= req:
                return True, f"Node {current_version} satisfies {alt}"

        elif alt.startswith('>'):
            # Greater than
            req = parse_version(alt[1:])
            if current > req:
                return True, f"Node {current_version} satisfies {alt}"

    return False, f"Node {current_version} does not satisfy: {required_engines}"


def validate_node_version(package_name: str) -> tuple[bool, str]:
    """Check if current Node version is compatible with the package requirements."""
    try:
        # Get current Node version
        result = subprocess.run(
            ['node', '--version'],
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode != 0:
            return False, "Could not determine Node version"

        current_version = result.stdout.strip()
        logger.debug(f"Current Node version: {current_version}")

        # Get required Node version from package
        result = subprocess.run(
            ['npm', 'view', package_name, 'engines.node'],
            capture_output=True,
            text=True,
            timeout=10
        )

        if result.returncode != 0 or not result.stdout.strip():
            # No engines field - assume compatible
            return True, "No Node version requirement specified"

        required_engines = result.stdout.strip()
        logger.debug(f"Required Node engines: {required_engines}")

        return check_node_version_compatible(required_engines, current_version)

    except subprocess.TimeoutExpired:
        return False, "Node version check timed out"
    except FileNotFoundError:
        return False, "node not found in PATH"
    except Exception as e:
        return False, str(e)


def validate_npm_package(package_name: str) -> tuple[bool, str]:
    """Check if an npm package can be resolved (exists in registry)."""
    try:
        # Use npm view to check if package exists - this doesn't require Chrome
        result = subprocess.run(
            ['npm', 'view', package_name, 'version'],
            capture_output=True,
            text=True,
            timeout=10
        )
        if result.returncode == 0:
            version = result.stdout.strip()
            return True, f"Package found: {package_name}@{version}"
        else:
            return False, f"Package not found: {result.stderr.strip()}"
    except subprocess.TimeoutExpired:
        return False, "npm view timed out"
    except FileNotFoundError:
        return False, "npm not found in PATH"
    except Exception as e:
        return False, str(e)


def validate_mcp_config() -> tuple[bool, str]:
    """Validate that chrome-devtools MCP server is configured using claude CLI."""
    try:
        result = subprocess.run(
            ['claude', 'mcp', 'get', 'chrome-devtools'],
            capture_output=True,
            text=True,
            timeout=10
        )
        if result.returncode == 0:
            return True, "chrome-devtools MCP server is configured"
        else:
            return False, "chrome-devtools not configured in any MCP config"
    except subprocess.TimeoutExpired:
        return False, "claude mcp get timed out"
    except FileNotFoundError:
        return False, "claude CLI not found in PATH"
    except Exception as e:
        return False, str(e)


def main():
    logger.info("=" * 50)
    logger.info("Hook started: check-chrome-debug-on-start.py")

    try:
        raw_input = sys.stdin.read()
        logger.debug(f"Raw stdin: {raw_input[:500]}")
        input_data = json.loads(raw_input) if raw_input.strip() else {}
    except json.JSONDecodeError as e:
        logger.error(f"JSON decode error: {e}")
        input_data = {}

    session_type = input_data.get('session_type', 'unknown')
    logger.debug(f"Session type: {session_type}")

    # Validate MCP configuration using claude CLI
    config_valid, config_msg = validate_mcp_config()
    logger.info(f"Config validation: {config_valid}, {config_msg}")

    if not config_valid:
        title = "Chrome DevTools MCP Misconfigured"
        message = config_msg

        send_notification(title, message)
        logger.error(f"Configuration error: {config_msg}")

        # Use systemMessage to show warning to user
        output = {
            'systemMessage': f"chrome-devtools MCP config error: {config_msg}"
        }
        print(json.dumps(output))
        return

    # Validate npm package exists (catches typos in package name)
    package_name = "chrome-devtools-mcp@latest"

    if package_name:
        # Check if npm package exists
        pkg_valid, pkg_msg = validate_npm_package(package_name)
        logger.info(f"Package validation: {pkg_valid}, {pkg_msg}")

        if not pkg_valid:
            title = "Chrome DevTools MCP Package Error"
            message = f"npm package issue: {pkg_msg[:50]}"

            send_notification(title, message)
            logger.error(f"Package error: {pkg_msg}")

            # Use systemMessage to show warning to user
            output = {
                'systemMessage': f"chrome-devtools MCP package error: {pkg_msg}"
            }
            print(json.dumps(output))
            return

        # Check Node version compatibility
        node_valid, node_msg = validate_node_version(package_name)
        logger.info(f"Node version validation: {node_valid}, {node_msg}")

        if not node_valid:
            title = "Chrome DevTools MCP Node Error"
            message = f"Node version issue: {node_msg[:50]}"

            send_notification(title, message)
            logger.error(f"Node version error: {node_msg}")

            # Use systemMessage to show warning to user
            output = {
                'systemMessage': f"chrome-devtools MCP Node error: {node_msg}"
            }
            print(json.dumps(output))
            return

    logger.info("chrome-devtools MCP configuration is valid")
    # Don't output anything if everything is fine - Chrome not running is expected


if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        logger.exception(f"Unhandled exception: {e}")
        # Don't block session start on errors
        sys.exit(0)
