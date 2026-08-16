# Ego Incremental

A responsive Godot 4 incremental game prototype.

The player begins as a hungry beggar near an ancient river.
The first systems are Gathering, Meditation, Incantation, and Bartering.
Each system has activities, currencies, upgrades, and relationships.

## Run locally

Open the `godot/` folder in Godot 4.3 or newer.
Run the main scene.

## Current loop

- Choose an unlocked system.
- Choose an activity.
- Watch it advance over time.
- Gain currency and system XP.
- Choose a reward when a system levels.
- Unlock the next system.
- Toggle automatic repetition after an activity completes.
- Progress saves to `user://ego_incremental.json`.

## Export for the site

The project uses the Compatibility renderer.
This keeps Web and mobile export options open.

Export a new version with:

```sh
VERSION=v10
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
