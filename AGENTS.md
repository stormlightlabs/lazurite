# Agent Guidelines

This document provides a high-level overview for contributors (human and AI agents)
working on Lazurite.

## Core Documentation Map

- [**Architecture Overview**](./doc/ARCHITECTURE.md):
  Project structure, layered architecture (Domain, Infrastructure, Application, Presentation),
  and multi-account isolation.
- [**Development Workflow**](./doc/DEVELOPMENT_WORKFLOW.md):
  Build commands, style guide, naming conventions, and commit standards.
- [**Testing Guide**](./doc/testing/README.md):
  Test organization, execution via `just`, and troubleshooting.
- [**Patterns**](./doc/PATTERNS.md):
  Advanced state management and coding patterns.

## Development Checklist

Before committing and submitting a PR, ensure you have:

1. Ran `just check` to format, lint, and test your changes.
2. Verified that all generated code is up to date (`just gen`).
3. Added unit tests for new logic and verified coverage targets (>95%).
4. Followed [Conventional Commits](https://www.conventionalcommits.org/).

## Coding Standards Summary

| Category             | Standard                              |
| :------------------- | :------------------------------------ |
| **Language**         | Dart with 2-space indentation         |
| **State Management** | Riverpod + Freezed                    |
| **Logic Layering**   | Strict separation between UI and Data |
| **Database**         | Drift with reactive streams           |
| **Naming**           | widgets: `PascalCase`                 |
|                      | members: `lowerCamelCase`             |
|                      | files: `snake_case`                   |

For deep dives into specific subsystems, refer to the files in the `doc/` directory.
