# Game Foundation Specification

## ADDED Requirements

### Requirement: System-driven play

The game SHALL present unlockable systems in the left navigation.
A system SHALL own activities, currencies, upgrades, and cross-system effects.

#### Scenario: Open a system

- GIVEN the player has unlocked a system
- WHEN the player selects its left-navigation item
- THEN the game SHALL show that system's activities and state
- AND the game SHALL not present the system as an ungrouped task

#### Scenario: Interrelate systems

- GIVEN one system produces a currency or effect used by another system
- WHEN the player completes an activity
- THEN the receiving system SHALL apply the defined benefit
- AND the interface SHALL identify the relationship

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

### Requirement: Future competitive boundary

The first release SHALL exclude public community features.
The simulation SHALL expose structured commands and state transitions that can support future server validation.

#### Scenario: Offline progress

- GIVEN the player uses local progress
- WHEN the player completes a run
- THEN the run SHALL remain unranked

#### Scenario: Future ranked result

- GIVEN a future ranked mode uses fixed challenge rules
- WHEN the player submits a result
- THEN a server SHALL validate the command history and state transitions
- AND the server SHALL calculate the ranked result
