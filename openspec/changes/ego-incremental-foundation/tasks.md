# Tasks: Ego Incremental Foundation

## Phase 0: Agreement and boundaries

- [ ] Review the proposal and design with the team.
- [ ] Choose the first task families.
- [ ] Choose the first currency set.
- [ ] Choose the first graph nodes.
- [ ] Record accepted open-question answers in the design.

## Phase 1: Data model

- [ ] Create typed task-definition data.
- [ ] Create typed progression-node data.
- [ ] Create typed effect data.
- [ ] Create versioned runtime state.
- [ ] Add content validation for missing identifiers.
- [ ] Add graph validation for cycles.
- [ ] Add validation for invalid prerequisites.

## Phase 2: Manual mastery slice

- [ ] Replace hard-coded task values with data files.
- [ ] Implement one active task from its definition.
- [ ] Grant task rewards from data.
- [ ] Grant XP from data.
- [ ] Calculate task levels from thresholds.
- [ ] Show task level and XP progress.
- [ ] Present level reward choices.
- [ ] Apply the selected reward.
- [ ] Add three initial task families.
- [ ] Add the first cross-family unlock.

## Phase 3: Effects and balance

- [ ] Implement the effect resolver.
- [ ] Add speed effects.
- [ ] Add XP effects.
- [ ] Add yield effects.
- [ ] Add critical effects.
- [ ] Add discovery effects.
- [ ] Define stacking rules.
- [ ] Add simulation tests for each stacking rule.
- [ ] Add a balance fixture for the first fifteen minutes.

## Phase 4: Automation

- [ ] Add repeat-current-task automation.
- [ ] Add fixed queues.
- [ ] Add resource conditions.
- [ ] Add energy conditions.
- [ ] Add inventory conditions.
- [ ] Add routine slots.
- [ ] Prevent automation from bypassing requirements.
- [ ] Add automation opportunity costs.

## Phase 5: Persistence and prestige

- [ ] Add versioned save data.
- [ ] Add atomic local save writes.
- [ ] Add save migrations.
- [ ] Add a locked prestige panel.
- [ ] Define the first prestige condition.
- [ ] Add Legacy rewards.
- [ ] Test reset and preservation rules.

## Phase 6: Security foundation

- [ ] Define offline and ranked modes.
- [ ] Mark local state as untrusted.
- [ ] Define the server command protocol.
- [ ] Define deterministic reward calculations.
- [ ] Implement server-side prerequisite validation.
- [ ] Implement server-side reward validation.
- [ ] Add append-only ranked event records.
- [ ] Add impossible-transition detection.
- [ ] Exclude offline state from ranked results.

## Phase 7: Community foundation

- [ ] Add shareable build serialization.
- [ ] Add import validation for shared builds.
- [ ] Add fixed challenge definitions.
- [ ] Add challenge result submission.
- [ ] Add seasonal leaderboard rules.
- [ ] Add public milestone cards.
- [ ] Define privacy and moderation policy.
- [ ] Design asynchronous guild research.

## Verification commands

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path godot --editor --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path godot --quit-after 3
npm run build
git diff --check
```

Competitive verification must also run server tests.
A browser test alone cannot prove competitive integrity.
