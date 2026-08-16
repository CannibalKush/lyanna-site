# Game Foundation Specification

## ADDED Requirements

### Requirement: Task-driven play

The game SHALL present available tasks as selectable items.

#### Scenario: Start a task

- GIVEN the player has unlocked a task
- WHEN the player selects the task
- THEN the simulation SHALL advance that task
- AND the interface SHALL show its progress
- AND the interface SHALL show its current XP

### Requirement: Task mastery

The game SHALL grant task XP from task definitions.

#### Scenario: Level a task

- GIVEN a task has enough XP for its next level
- WHEN the simulation resolves the XP gain
- THEN the task level SHALL increase
- AND the game SHALL present the defined level reward choices

### Requirement: Directed progression

The progression system SHALL represent prerequisites as an acyclic graph.

#### Scenario: Unlock a node

- GIVEN all prerequisites for a node are complete
- WHEN the game evaluates progression
- THEN the node SHALL become available
- AND the node SHALL not become available before all prerequisites complete

#### Scenario: Reject a cycle

- GIVEN progression data contains a cycle
- WHEN the game loads the data
- THEN validation SHALL fail
- AND the game SHALL identify the cycle

### Requirement: Effect separation

The game SHALL represent bonuses as typed effects with explicit stacking rules.

#### Scenario: Apply a synergy

- GIVEN two unlocked effects target the same task
- WHEN the game calculates task output
- THEN the resolver SHALL apply both effects according to their stacking rules
- AND the task definition SHALL remain unchanged

### Requirement: Distinct currencies

The game SHALL keep materials, silver, insight, and legacy as distinct currencies.

#### Scenario: Spend a currency

- GIVEN a node requires insight
- WHEN the player unlocks the node
- THEN the game SHALL spend insight
- AND the game SHALL not spend silver unless the node defines a silver cost

### Requirement: Automation boundaries

Automation SHALL execute valid task commands without bypassing progression requirements.

#### Scenario: Automated task

- GIVEN the player owns an automation rule for a task
- WHEN the rule selects that task
- THEN the same validation SHALL run as for manual selection
- AND the automation SHALL not grant extra rewards

### Requirement: Untrusted client

The browser client SHALL not be treated as authoritative for ranked progress.

#### Scenario: Offline progress

- GIVEN the player uses local offline state
- WHEN the player submits a leaderboard result
- THEN the server SHALL reject the result or mark it unranked

#### Scenario: Ranked command

- GIVEN the player starts a ranked run
- WHEN the client sends a task command
- THEN the server SHALL validate the command against authoritative state and definitions
- AND the server SHALL grant rewards only after validation

### Requirement: Community safety

Community systems SHALL start with asynchronous and bounded interactions.

#### Scenario: Share a build

- GIVEN the player exports a build
- WHEN another player imports it
- THEN the game SHALL validate identifiers, values, and unlocks
- AND the import SHALL not execute arbitrary code
