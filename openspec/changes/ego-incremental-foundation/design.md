# Design: Ego Incremental Foundation

## 1. Product shape

The game presents humble tasks as the first layer of a hidden Mesopotamian spiritual world.
The player begins as a hungry beggar outside an ancient city.
The left bar contains unlockable systems, not a flat list of chores.
Each system has its own screen, rules, currencies, upgrades, and relationships.
The active system advances a chosen activity at a fixed simulation rate.
The interface shows system progress, XP, rewards, currencies, and discoveries.

The first systems should feel concrete and poor:

- Gathering: collect reeds, food, and water.
- Meditation: reduce the cost of future improvements.
- Incantation: convert Focus into materials.
- Bartering: buy and sell goods.
- Scribing: turn discoveries into permanent knowledge.
- Divination: reveal future opportunities and risks.

The player does not click for every action.
The player chooses which system deserves attention.

The first useful transformation is:

```text
unlock system → learn its currency → improve the system → connect it to another system → automate routine → approach divinity
```

## 2. Progression graph

Represent progression as a directed acyclic graph.

Each node has an identifier, category, requirements, rewards, and optional tags.
Edges express prerequisites.
The loader rejects missing nodes and cycles.

Example graph:

```text
woodcutting → carpentry
foraging → herbalism
woodcutting + foraging → campcraft
scouting → cartography → trade_routes
```

Use node types for:

- Tasks.
- Passive upgrades.
- Automation rules.
- Discovery unlocks.
- Prestige unlocks.

Use hard prerequisites for access.
Use soft synergies for bonuses.
Do not hide every bonus inside the graph.
The player must understand why a node matters.

## 3. System model

Each left-bar element is a system definition.
A system owns one main loop and may expose several activities.

A system definition contains:

- Stable identifier.
- Display name and symbol.
- Unlock requirements.
- Primary currency.
- Optional secondary currency.
- Activities.
- Self-upgrades.
- Cross-system effects.
- Automation rules.
- Prestige interactions.

Example systems:

```text
Meditation
  currency: calm
  secondary: insight
  improves: upgrade costs, focus recovery
  receives: incense from Incantation

Incantation
  currency: focus
  secondary: words
  converts: focus → materials
  receives: calm from Meditation

Bartering
  currency: silver
  secondary: reputation
  converts: goods ↔ silver
  receives: goods from Gathering and Incantation
```

Systems should improve themselves and sometimes improve another system.
Cross-system effects should remain legible.
The player should understand the connection before optimizing it.

Each activity definition contains:

- Stable identifier.
- Display name.
- Category.
- Base duration.
- XP per action.
- Reward definitions.
- Requirements.
- Level reward choices.
- Automation rules.
- Tags for synergy matching.

Runtime state contains:

- Current level.
- Current XP.
- Selected specializations.
- Total actions.
- Current progress.
- Automation state.

The engine calculates task outcomes.
The UI renders definitions and runtime state.
The UI never owns progression rules.

## 4. Effects and synergies

Use typed effects instead of scattered bonus variables.

Initial effect types:

- `speed_multiplier`.
- `xp_multiplier`.
- `yield_multiplier`.
- `critical_chance`.
- `quality_multiplier`.
- `discovery_chance`.
- `automation_capacity`.
- `starting_bonus`.

Each effect includes:

- Source identifier.
- Target identifier or category.
- Effect type.
- Numeric value.
- Stacking rule.

Use explicit stacking rules:

- Additive for small bonuses.
- Multiplicative for major system bonuses.
- Maximum value for caps.
- Exclusive choice for specializations.

Do not let effects mutate state directly.
The effect resolver calculates a snapshot from state and definitions.

## 5. Currencies

Start with four currency families.

### Materials

Task outputs.
Materials feed crafting and construction.

### Silver

Economic currency.
Silver buys tools, storage, task access, and automation.

### Insight

Knowledge currency.
Insight unlocks graph nodes and research.

### Legacy

Prestige currency.
Legacy buys permanent run-to-run improvements.

Each currency must have a clear source and sink.
Add no currency without a named design purpose.

## 6. Level rewards

Major task levels present a choice.
The choice should change future behavior.

Example:

```text
Woodcutting level 5

Lumberjack: +10% wood yield.
Scholar: +10% woodcutting XP.
Surveyor: +5% discovery chance.
```

Avoid rewards that only increase the same number.
Prefer sidegrades, new tasks, and new automation options.

## 7. Automation

Automation unlocks in stages.

### Stage one

Repeat the current task.

### Stage two

Queue a fixed task sequence.

### Stage three

Add conditions such as resource, energy, and inventory limits.

### Stage four

Add priority rules and routine slots.

Automation must create a new planning problem.
It must not remove all meaningful decisions.
Automation should have limits, maintenance, risk, or opportunity cost.

## 8. Prestige

Prestige represents a new generation or a new run.

A prestige resets temporary run state:

- Task levels.
- Materials.
- Silver.
- Temporary upgrades.
- Automation routines.

A prestige preserves permanent state:

- Legacy.
- Selected permanent nodes.
- Discoveries.
- Milestones.
- Cosmetic history.

Do not implement full prestige before the manual task loop feels good.
Expose a locked prestige panel during the first slice.

## 9. Persistence

Use versioned save data.

Every save contains:

- Schema version.
- Content version.
- Player state.
- Last save timestamp.
- Optional migration metadata.

Save through one service.
Do not let task scripts write save files.

Use atomic local writes where the platform allows them.
Keep local saves convenient, not trusted.

## 10. Trust and unhackable-ness

A browser game cannot be unhackable.
The player controls the browser, JavaScript, WebAssembly, and local save data.

We can make competitive results hard to fake.
We cannot make a local single-player save impossible to edit.

### Offline mode

Treat all local state as untrusted.
Allow local progress without leaderboard eligibility.
Show this boundary clearly.

### Competitive mode

Use a server-authoritative simulation.
The client sends commands, not rewards.
The server validates every command against state and definitions.
The server grants XP, currency, and rank.

Use deterministic simulation where practical.
Use fixed-point or integer values for competitive calculations.
Define event ordering and rounding rules.

Store an append-only event log for ranked runs.
Validate event transitions on the server.
Reject impossible duration, reward, level, and prerequisite changes.

Use signed run results or server-generated run identifiers.
Never trust a client-submitted total.

The static Cloudflare site remains a client.
Use Cloudflare Workers for API endpoints.
Use Durable Objects for active run state when needed.
Use D1 for durable account and leaderboard records.
Use R2 for large replay or audit artifacts.

Do not add competitive features until this boundary exists.

## 11. Community interactions

Community features should support comparison, teaching, and shared discovery.

### Early community features

- Shareable builds.
- Shareable progression paths.
- Fixed challenge runs.
- Seasonal goals.
- Public milestone cards.
- Opt-in leaderboards.

### Later community features

- Guild research projects.
- Shared asynchronous goals.
- Player-authored contracts.
- Market listings.
- Trading.
- Cooperative world events.

Avoid direct chat in the first community slice.
Moderation, abuse reports, identity, and privacy become core systems.

Use asynchronous interaction first.
It fits an incremental game and reduces operational cost.

## 12. Leaderboards

Leaderboards need a defined metric and a defined scope.

Initial categories:

- Fastest fixed challenge completion.
- Highest mastery under fixed rules.
- Most efficient resource output.
- Highest prestige score in a season.

Avoid one global number.
A single number rewards time, not skill.

Use seasonal resets.
Publish the rules with each leaderboard.
Separate offline progress from ranked progress.

## 13. Data-driven architecture

Use a hybrid content model.

- JSON defines tasks, nodes, effects, and balance values.
- Typed Godot resources define complex assets when required.
- Typed runtime classes validate loaded content.
- A simulation service advances state.
- A resolver calculates effects.
- A persistence service saves state.
- UI scenes render state and emit player commands.

Recommended folders:

```text
godot/
├── data/
│   ├── tasks.json
│   ├── progression.json
│   └── effects.json
├── resources/
├── scripts/
│   ├── simulation/
│   ├── progression/
│   ├── persistence/
│   └── ui/
└── scenes/
```

Keep definitions separate from code.
Keep runtime state separate from definitions.
Keep effects separate from task execution.
Keep network authority separate from presentation.

## 14. Testing principles

Test rules without the Godot scene tree where possible.

Required tests include:

- Task XP reaches the expected level.
- Rewards match the task definition.
- Prerequisites unlock in order.
- The graph rejects cycles.
- Effects stack according to their rules.
- Automation does not bypass requirements.
- Save migrations preserve progress.
- Server validation rejects impossible commands.
- Ranked results exclude offline state.

Add golden simulation tests for fixed challenge runs.
A balance change must show its effect in a recorded test.

## 15. Delivery order

### Phase one: manual mastery

Build task definitions, XP, levels, rewards, and the graph.

### Phase two: meaningful choice

Add specializations, effects, and cross-task synergies.

### Phase three: automation

Add repetition, queues, conditions, and routine slots.

### Phase four: persistence and prestige

Add versioned saves, legacy, and run reset.

### Phase five: competitive foundation

Add server commands, validation, event logs, and ranked runs.

### Phase six: community

Add shareable builds, challenges, seasonal boards, and asynchronous cooperation.

Do not reverse this order.
Community features built before authority create expensive rewrites.
