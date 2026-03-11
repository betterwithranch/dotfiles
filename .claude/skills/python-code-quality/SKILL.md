---
name: python-code-quality
description: Python code quality guidelines and best practices. Use when creating or modifying Python files, working with imports and module structure, refactoring code, or reviewing Python code quality. Triggers on Python development tasks involving dependencies, imports, module organization, or code structure decisions.
---

# Python Code Quality

Guidelines for writing maintainable, well-structured Python code.

## Naming

Use concise, clear names for files, functions, variables, and all identifiers. Names should be self-documenting and reveal intent without being verbose.

## Comments and Docstrings

- **Document what code does, not what it doesn't do** - Comments should describe current behavior, not enumerate what the code doesn't handle or what was removed.
- **Don't document past behavior** - Avoid comments like "Note: X is no longer supported" or "Previously this did Y". Git history provides this context.
- **Let code speak for itself** - If code doesn't do something, that's evident from reading it. No need to state "this method does NOT do X".

## Imports

- **No inline imports** - Place all imports at the top of the file. Only use inline imports when absolutely unavoidable (e.g., breaking circular dependencies that cannot be fixed architecturally).
- **No `getattr` for attribute access** - Use direct attribute access. Only use `getattr` when the attribute name is truly dynamic (computed at runtime).

## Type Annotations

- **No `Any` unless unavoidable** - Always prefer specific types. Use `Any` only when the type genuinely cannot be determined or when interfacing with untyped third-party code.
- **No `from __future__ import annotations`** - This codebase requires Python 3.11+, which natively supports all modern type annotation syntax (PEP 604 union types with `|`, PEP 585 generic syntax). Never add `from __future__ import annotations`.

## Encapsulate Default Values

Classes should encapsulate their own defaults rather than requiring callers to provide them.

**Bad** - caller must know about `ConfigService`:

```python
deps = ExtractionDeps(
    chat_id=self.chat_id,
    categories=ConfigService.get_categories(),
    levels=ConfigService.get_levels(),
)
```

**Good** - defaults encapsulated in the class:

```python
deps = ExtractionDeps(chat_id=self.chat_id)
```

Put the `ConfigService` calls in the class's `__init__` (or use `default_factory` for Pydantic models).

## Circular Dependencies

**Never use `TYPE_CHECKING` or other workarounds for circular imports.** These approaches hide architectural problems rather than solving them.

### What NOT to do

```python
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from myapp.models import User  # Hiding a circular dependency

class UserService:
    def get_user(self) -> "User":  # String annotation to avoid import
        ...
```

### Why this is problematic

- `TYPE_CHECKING` blocks mask design flaws
- String annotations reduce IDE support and type checker effectiveness
- The underlying coupling remains, making the code harder to maintain and test
- Circular dependencies indicate modules are too tightly coupled

### How to fix circular dependencies

1. **Extract shared types/interfaces** - Move shared types to a separate module that both can import
2. **Invert dependencies** - Use dependency injection so the dependent module receives what it needs
3. **Merge modules** - If two modules are tightly coupled, they may belong together
4. **Restructure the dependency graph** - Rethink module boundaries to create a clear hierarchy

**If you cannot resolve the circular dependency using these approaches, STOP and ask the user for assistance.** Do not proceed with `TYPE_CHECKING` or other workarounds.

### Example fix: Extract shared types

Before (circular):

```python
# models.py
from services import UserService  # Circular!

# services.py
from models import User  # Circular!
```

After (fixed):

```python
# types.py (new module)
from typing import Protocol

class UserProtocol(Protocol):
    id: int
    name: str

# models.py
from types import UserProtocol

# services.py
from types import UserProtocol
```
