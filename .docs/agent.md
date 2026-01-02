# Purpose
This document defines rules, constraints, and expectations for any agentic AI (Codex, Copilot, ChatGPT, etc.) operating in this repository. 
  
AI agents are treated as junior contributors: helpful, fast, but constrained by architecture and intent.

This file exists to:
  * Prevent architectural drift
  * Avoid "helpful" violations of core principles
  * Ensure AI output aligns with long-term maintainability
  
This document **overrides default AI behaviour** when operating in this repo. 

# Canonical Architecture Reference

All AI contributions must comply with `Architecture_Requirements.pdf`.

If an AI suggestion conflicts with that document, **the architecture wins**.

# Non-Negotiable Rules for AI Agents

### 1. No Architectural Assumptions
Agents must **never invent structure**.

Before generating code, the agent must:
- Ask where the code lives (Controller / Service / View / Model)
- Ask which interfaces already exist
- Ask how the system is bootstrapped

If unsure, **pause and ask** instead of guessing.

### 2. Respect Layer Boundaries (Strict)
Agents **must not**:
- Put logic in Views
- Put UnityEngine dependencies in Services
- Introduce cross-service calls without interfaces/events
- Add “manager” or “god” classes

If a solution requires violating a boundary, the agent must:
- Explicitly call it out
- Propose an alternative that respects boundaries

### 3. Interface-First Development
For any new system or service:
- Define interfaces **before** implementations
- Never reference concrete classes across systems
- Never pass Unity types (`GameObject`, `MonoBehaviour`, etc.) through interfaces

Prefer:
`IExampleService` over `ExampleService`

### 4. No Silent Unity Dependencies
Agents must **never** introduce:
- `FindObjectOfType`
- `GetComponent`
- Hidden scene dependencies
- Serialized fields on services
All Unity binding must occur in:
- Controllers
- Bootstrappers
- Service Locators
If Unity APIs are required, they must be **explicit and justified**.

### 5. Incremental, Minimal Changes Only
Agents must:
- Change the **smallest surface area** possible
- Avoid refactors unless explicitly requested
- Preserve all existing behavior by default
If refactoring is beneficial, the agent must:
- Explain *why*
- Scope it tightly
- Offer it as an **optional step**

### 6. Tests are Logic-Only
Agents may propose or write tests only for:
- Services
- Analyzers
- Validators
- Pure Logic
Agents must not:
- Write Unity PlayMode tests unless requested
- Mock Unity APIs
- Test Views or MonoBehaviours directly

### 7. CI / Automation Constraints
Agents must assume:
- CI does **not** run Unity
- No Unity licensing is available in CI
- Only out-of-engine checks are allowed unless explicitly approved

# Communication Expectations
### When to ask questions
Agents must ask before acting if:
- File locations are ambiguous
- Multiple architectural interpretations exist
- A change could affect multiple systems
- The request is underspecified

### How to Present Solutions
Agents should:
- Prefer concrete code over prose
- Label assumptions explicitly
- Call out architectural implications
- Avoid "magic" or "trust me" solutions

# Forbidden Behaviors
Agents must never:
- Introduce global state or singletons
- Add static service access
- Hardcode asset paths
- Bypass interfaces for convenience
- "Just make it work" at the cost of architecture

# Mental Model for AI Agents
When in doubt, operate under the following hierarchy:
1. Architecture Requirements
2. Maintainability
3. Testability
4. Minimalism
5. Speed
Speed is **last**.

# Final Note
This repo values:
- Replaceable Systems
- Clear Boundaries
- Intentional complexity
- Long-term composability
If your solution is clever but fragile, **it is wrong**.
If your solution is boring but correct, **it is right**.
