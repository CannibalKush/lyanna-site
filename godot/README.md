# Ego Incremental

A responsive Godot 4 incremental game prototype.

The player begins as a hungry beggar near an ancient river.
The first systems are Gathering, Meditation, Incantation, and Bartering.
Each system has activities, currencies, upgrades, and relationships.

## Run locally

Open the `godot/` folder in Godot 4.3 or newer.
Run the main scene.

## Architecture

- `data/systems.json` contains declarative system and activity content.
- `scripts/core/game_state.gd` owns hoisted save state through the `GameState` autoload.
- `scripts/core/content_database.gd` loads game content.
- `scripts/core/simulation_rules.gd` contains pure progression and effect rules.
- `scripts/ui/game_hud.gd` owns day, currency, and path XP display.
- `scripts/ui/system_navigation.gd` owns system navigation.
- `scripts/ui/activity_panel.gd` owns activity selection and active progress.
- `scripts/ui/reward_popup.gd` owns level-up choices.
- `scripts/ui/ui_factory.gd` creates shared controls and styles.
- `scripts/main.gd` coordinates commands, state changes, and view updates.

The intended flow is:

```text
input -> controller -> state and rules -> view update -> feedback
```

The view does not own persistent state.

## Current loop

- Actions use saved wall-clock time, so browser tab changes do not lose progress.
- System levels give recursive bonuses: `x1.01` output and `x0.99` action time.
- Activity labels use `TIME | +[RESOURCE] | -[RESOURCE]`.
- Activity tooltips show resource names and amounts.
- Progress bars use subtle pulse motion.
- Unlock the next system.
- Toggle automatic repetition after an activity completes.
- Progress saves to `user://ego_incremental.json`.

## Export for the site

The project uses the Compatibility renderer.
This keeps Web and mobile export options open.

Export a new version with:

```sh
VERSION=v15
mkdir -p "public/godot/$VERSION"
/Applications/Godot.app/Contents/MacOS/Godot \
  --headless --path godot \
  --export-release Web "$PWD/public/godot/$VERSION/index.html"
brotli -q 11 -c "public/godot/$VERSION/index.wasm" \
  > /tmp/index.wasm.br
mv /tmp/index.wasm.br "public/godot/$VERSION/index.wasm"
```

Update the iframe route and `public/_headers` when the version changes.

## Design source

The OpenSpec plan lives in:

```text
openspec/changes/ego-incremental-foundation/
```

The browser client remains untrusted.
Offline progress is not ranked.
