# Project Workspace

This repository is a **shared Unity workspace** for a small indie team.
The game concept is intentionally undecided at this stage.

The purpose of this repo is to:
- Establish a clean technical foundation
- Align contributors on architecture and workflow
- Provide guardrails that scale as the project evolves

This is **not** a prototype or vertical slice yet.
It is the environment in which one will be built.


## Tech Stack

- **Engine:** Unity (Universal 2D template)
- **Version:** 6.3 LTS (6000.3.2f1)
- **Source Control:** GitHub
- **CI:** Lightweight, out-of-engine checks only
- **Target Platforms:** TBD


## How We Work

### Branching & PRs
- `main` is protected
- All changes go through Pull Requests
- PRs must pass CI before merge
- Small, focused PRs are preferred

### CI Philosophy
- CI does **not** run Unity
- CI enforces repo hygiene, consistency, and safety
- Engine-level validation is done locally by developers

This keeps CI fast, reliable, and indie-friendly.


## Local Development

### Unity Setup
- Open the project using the **exact Unity version specified**
- Do not upgrade Unity without team discussion
- Run and test changes locally before pushing

### Tests
- Logic tests live under `Assets/_Project/Tests`
- Tests are intended to be run locally in Unity
- CI does not execute Unity tests


## Architecture & Constraints

This project follows a **strict architectural model**.

Before contributing, read:
- `Architecture_Requirements.pdf`
- `agents.md` if you are implementing any agentic AI to assist in your development.

Architecture is treated as a **hard constraint**, not a suggestion.

If something is unclear:
- Ask before implementing
- Do not “fill in the gaps” with assumptions


## AI-Assisted Development

Agentic AI tools (Codex, Copilot, ChatGPT, etc.) are allowed **only if**:
- They follow the rules in `agents.md`
- They respect architectural boundaries
- They are treated as assistants, not authors

Any AI-generated contribution is the responsibility of the human submitting it.


## What This Repo Is *Not* (Yet)

- Not a finalized game concept
- Not a feature-complete project
- Not optimized
- Not locked in scope

Those decisions come **after** alignment and foundations.


## Next Milestones (High-Level)

- Align on core game concept
- Define first vertical slice
- Begin feature implementation
- Expand testing and CI only when justified


## Questions or Uncertainty

If you’re unsure about:
- Where code should live
- How a system should be structured
- Whether something violates architecture

**Stop and ask.**

That is always preferable to guessing.
