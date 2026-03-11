---
name: walk-through
description: Walk through a list of items one at a time for review and action. Use when you have a list of recommendations, issues, tasks, or findings that need individual review and decision-making.
allowed-tools: Read, Edit, Write, Bash, TaskCreate, TaskUpdate, TaskList
---

# Walk-Through Skill

Help the user work through a list of items (recommendations, issues, tasks, etc.) one at a time in an **interactive review session**.

## Core Principle: Interactive Discussion

**This is a collaborative, turn-by-turn process.** The entire purpose is to have an interactive discussion about each item where the user guides what happens. You present ONE item, wait for the user's decision, act on it, then repeat.

**NEVER:**
- Present multiple items at once
- Take action on an item before the user decides
- Move to the next item without user confirmation
- Assume what the user wants to do
- Use AskUserQuestion (it returns empty results without waiting)

**ALWAYS:**
- Present exactly ONE item
- Show the available options as plain text
- Stop and wait for the user to type their response
- Act only after receiving user's decision
- Confirm before moving to the next item

## When to Use This Skill

- After a code review that produced multiple findings
- When processing a list of recommendations or suggestions
- Walking through TODO items or issues one by one
- Any scenario where items need individual review and action

## How It Works

1. If the user provides arguments, use them as context for what to walk through
2. If no arguments provided, look at the recent conversation context for a list of items (e.g., PR review findings, recommendations, TODO items, issues)

## Process

For each item in the list:

### Step 1: Present the Item
Show the item number, title/summary, and full details clearly.

### Step 2: Provide Your Recommendation
Give a clear recommendation on what action to take (fix it, skip it, needs discussion, etc.)

### Step 3: Show Options and STOP

Present the options as plain text and END YOUR TURN. Wait for the user to respond.

```
**What would you like to do?**
- **fix** - Implement the fix/change now
- **skip** - Move to the next item without action
- **discuss** - Get more details or discuss alternatives
- **stop** - End the walk-through session
```

**⚠️ CRITICAL: YOUR TURN MUST END AFTER PRESENTING OPTIONS.**

Do NOT:
- Call any tools after presenting options
- Take any action before user responds
- Assume what the user wants

Just output the item details, your recommendation, and the options menu, then STOP. The user will type their choice.

### Step 4: Take Action Based on Response (IN THE NEXT TURN)

When you receive the user's response in the next turn:

**CRITICAL**: First output a brief acknowledgment (e.g., "Got it, fixing..." or "Skipping to next item...") before taking any action.

- **fix**: Acknowledge, implement the change, confirm completion, then present the next item
- **skip**: Acknowledge and present the next item
- **discuss**: Acknowledge, provide more context, answer questions, then re-show options
- **stop**: Acknowledge, then end the session with a summary of what was reviewed and completed

### Step 5: Track Progress
Use TaskCreate to create tasks for each item at the start, and TaskUpdate to mark them as completed or skipped as you go.

## Important Guidelines

- **ONE item at a time** - Never present multiple items in a single response
- **Wait for user** - After presenting an item and options, STOP and wait for user to type
- **Acknowledge first** - Always output text acknowledgment immediately after receiving user input
- **Track progress** - Keep a running count (e.g., "Item 3 of 7")
- **Summarize at end** - Provide a summary of all actions taken when the session ends
- **Flexible input** - Accept variations like "1", "fix", "fix it", "f", etc.

## Starting the Walk-Through

Begin by:
1. Identifying the list of items to walk through from the conversation context or arguments
2. Counting the total items
3. Using TaskCreate to create a task for each item to track progress
4. Presenting **only the first item** with your recommendation and options
5. **END YOUR TURN** - Do not take any more actions, wait for user input

## One Item Per Turn Rule

Each conversation turn should handle AT MOST one item:
- Turn 1: Present item 1, show options, END TURN
- Turn 2 (after user responds): Act on response, present item 2, show options, END TURN
- Turn 3 (after user responds): Act on response, present item 3, show options, END TURN
- ...and so on

Never process multiple items in a single turn. The user's response determines what happens next.
