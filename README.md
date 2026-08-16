# lyanna.dev

A minimal personal site with the Ego Incremental game prototype.

## Development

```sh
npm install
npm run dev
```

Open `http://localhost:4321`.

## Build

```sh
npm run build
```

The static output goes to `dist/`.

## Structure

- `src/pages/index.astro` contains the minimal homepage.
- `src/pages/games/ego-incremental.astro` contains the full-screen game route.
- `src/styles/global.css` contains shared design tokens and game-shell styles.
- `godot/` contains the Godot 4 game project.
- `godot/data/systems.json` contains the first four system definitions.
- `public/godot/` contains versioned Web exports.
- `openspec/` contains the game plan and implementation specifications.
