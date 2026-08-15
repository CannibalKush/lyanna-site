# Pocket Field

A small 2D incremental game prototype.

## Run

Open the `godot/` folder in Godot 4.3 or newer.

Run the main scene.

- Click to gather light.
- Press Space to gather light.

## Current state

- Godot 4 project settings.
- 2D scene with a procedural placeholder world.
- Basic input.
- Basic resource counter.
- No external assets.

The project uses the GL Compatibility renderer. This keeps web and mobile export options open.

The checked-in Web export lives at `public/godot/` and is embedded on `/game`.

To regenerate it after changing the Godot project:

```sh
mkdir -p public/godot/v2
/Applications/Godot.app/Contents/MacOS/Godot --headless --path godot --export-release Web "$PWD/public/godot/v2/index.html"
brotli -q 11 -c public/godot/v2/index.wasm > /tmp/index.wasm.br && mv /tmp/index.wasm.br public/godot/v2/index.wasm
```
