# Tasks: Ego Incremental Foundation

## Phase 0: Agreement and boundaries

- [x] Review the proposal and design with the team.
- [x] Choose the first system families.
- [x] Choose the first currency set.
- [x] Choose the first graph nodes.
- [x] Record accepted open-question answers in the design.

## Phase 1: Data model

- [x] Create data-defined system and activity definitions.
- [x] Create versioned runtime state.
- [ ] Add content validation for missing identifiers.
- [ ] Add graph validation for cycles.
- [ ] Add validation for invalid prerequisites.

## Phase 2: Manual mastery slice

- [x] Replace hard-coded task values with data files.
- [x] Implement one active activity from its definition.
- [x] Grant activity rewards from data.
- [x] Grant XP from data.
- [x] Calculate system levels from thresholds.
- [x] Show system level and XP progress.
- [x] Present level reward choices.
- [x] Apply the selected reward.
- [x] Add the four initial systems.
- [x] Add cross-system unlock requirements.

## Phase 3: Effects and balance

- [x] Implement the first effect resolver.
- [x] Add speed effects.
- [x] Add XP effects.
- [x] Add yield effects.
- [x] Add critical effects.
- [ ] Add discovery effects.
- [ ] Define formal stacking rules.
- [ ] Add simulation tests for each stacking rule.
- [ ] Add a balance fixture for the first fifteen minutes.

## Phase 4: Automation

- [x] Add repeat-current-activity automation.
- [ ] Add fixed queues.
- [ ] Add resource conditions.
- [ ] Add energy conditions.
- [ ] Add inventory conditions.
- [ ] Add routine slots.
- [x] Prevent repeat automation from bypassing requirements.
- [ ] Add automation opportunity costs.

## Phase 5: Persistence and prestige

- [x] Add versioned save data.
- [ ] Add atomic local save writes.
- [ ] Add save migrations.
- [ ] Add a locked prestige panel.
- [ ] Define the first prestige condition.
- [ ] Add Legacy rewards.
- [ ] Test reset and preservation rules.

## Phase 6: Security foundation

- [x] Define offline and ranked modes.
- [x] Mark local state as untrusted.
- [ ] Define the server command protocol.
- [ ] Define deterministic reward calculations.
- [ ] Implement server-side prerequisite validation.
- [ ] Implement server-side reward validation.
- [ ] Add append-only ranked event records.
- [ ] Add impossible-transition detection.
- [x] Exclude offline state from ranked results.

## Phase 7: Community foundation

- [ ] Deferred by product decision.

## Verification commands

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path godot --editor --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path godot --quit-after 3
npm run build
git diff --check
```

Competitive verification must also run server tests.
A browser test alone cannot prove competitive integrity.
