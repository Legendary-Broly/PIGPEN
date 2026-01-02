# Philosophy
  * Every system must be replaceable without affecting others.
  * Views are disposable, services are reusable.
  * Controllers are glue, but should have no logic of their own.
  * Nothing should know where a tile is rendered, only that it's rendered.
  * Every major system needs to be built to easily facilitate additions of new element.
# Core Principles
  * Modular Architecture
    - Every system must be isolated into independent modules.
    - No system should directly reference the internal state of another.
    - Avoid monolithic "god classes"; decompose logic by domain responsibility.
  * Dependency Inversion
    - All services must be referenced via interfaces, not concrete classes.
    - Use dependency injection for all service and controller initialization.
  * Event-Driven Communication
    - Use events, delegates, or `UnityEvent` based systems for cross-module communication.
    - No system should call another’s methods unless through its interface or event system.
  * Testable Codebase
    - Logic-heavy classes (e.g., services, analyzers, validators) should be testable in isolation.
    - No reliance on Unity-specific APIs in service-layer logic (e.g., no `MonoBehaviour`, `GameObject`, etc.).
# System Boundaries
  * Controller
    - Routes user/system input to services; initializes scene-specificelements
  * Service
    - Handles logic, rule enforcement, and state transitions
  * Model
    - Pure data classes and game state containers
  * View
    - Only renders UI or visuals based on provided state
  * ScriptableObject
    - Configuration, metadata, or static data storage
# Script Structure & Responsibilities
  * Controllers
    - UI input routing
    - Event registration/detachment
    - Service orchestration
    - View binding (indirect)
  * Services
    - Pure logic (rules, calculations, gameplay state)
    - Must implement interfaces
    - Must not depend on Unity types or MonoBehaviours
    - All state must be internally encapsulated
  * Interfaces
    - Define all contracts for services and systems
    - Required for all services
    - Avoid passing Unity types like `GameObject`, `MonoBehaviour` through interfaces
  * Views
    - Assigned through Unity Editor
    - Listen to state and apply visual changes only
    - Should never mutate game state directly
    - Implement interface-based updates
  * ScriptableObjects
    - Used for:
      -- Configs (difficulty, health values, level layouts)
      -- Metadata (symbol definitions, grid sizes)
      -- Static rules (spawn tables, loot tables)
    - Must be created using `ScriptableObject.CreateInstance`
# Unity Integration Best Practices
  * All instantiation and MonoBehaviour bindings must be handled in the Bootstrapper or a ServiceLocator.
  * Scene objects should never access each other using `FindObjectOfType` or `GetComponent`, use injected references only.
  * Avoid serialized fields on services, use runtime configuration exclusively.
  * Separate runtime logic from editor/inspector logic. Use dedicated editor scripts when necessary.
# Testing and Debugging Best Practices
  * Include debug logs only through a centralized `ILogService` or conditional compile flags.
  * Every service must be mockable (via interface) for future unit tests.
  * Favor functional purity: return values instead of relying on side effects.
  * Do not access UnityEngine APIs (Camera, Input, Time) from services.
# Anti-Patterns to Avoid
  * `public static` access to services or managers
  * `FindObjectOfType`, `GetComponent` in services or core logic
  * Hardcoded references to prefabs or asset paths in code
  * Large monobehaviors controlling multiple domains
  * Direct cross-service interaction
  * Logic in views
