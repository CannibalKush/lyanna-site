# Proposal: Ego Incremental Foundation

## Intent

Turn the current Godot demo into a durable incremental-game foundation.

The game will focus on task mastery, progression choices, automation, prestige, and later community competition.

The player selects work from a task list.
The work advances over time.
The task grants rewards and XP.
Task levels unlock new tasks and choices.
Automation removes repetitive work.
Prestige converts a completed run into permanent progress.

## Design thesis

The primary fantasy is:

> Begin as a forgotten beggar in ancient Mesopotamia, then climb through hidden knowledge toward godhood.

The player should move from manual task selection to automation design.
The player should make meaningful choices about speed, XP, yield, quality, critical rewards, and discovery.

The game should make ordinary work feel sacred.
The long horizon should move through stages such as:

```text
Beggar → Gatherer → Initiate → Scribe → Diviner → Priest → Kingmaker → Living god
```

The player begins with hunger, obscurity, and one small ritual.
The player gradually discovers that humble tasks belong to a hidden spiritual and economic structure.

## Scope

This change defines the long-term foundation and the first vertical slice.

The first vertical slice includes:

- Data-defined tasks.
- Task XP and levels.
- Level rewards with player choice.
- A small directed acyclic progression graph.
- Distinct resources, silver, insight, and legacy currencies.
- Basic task repetition.
- A locked automation path.
- A locked prestige path.
- Local progress persistence.
- Testable simulation rules.

Later slices may add:

- Conditional automation.
- Market systems.
- Seasonal challenges.
- Server-authoritative leaderboards.
- Guilds and asynchronous community features.

## Non-goals

- Real-time multiplayer.
- Full-loot PvP.
- A trusted browser client.
- A giant skill tree in the first release.
- A player market before server authority exists.
- A leaderboard based on client-submitted totals.
- Monetisation.
- A claim that local saves are secure.

## Success criteria

The first slice succeeds when a player can:

1. Select a task.
2. Watch progress advance.
3. Gain task XP.
4. Level a task.
5. Choose a level reward.
6. Unlock a related task.
7. Understand one useful synergy.
8. See a clear reason to automate the old task.
9. See a clear reason to prestige later.

The technical slice succeeds when the same task definitions drive the UI, simulation, save data, and tests.
