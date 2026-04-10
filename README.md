# Chat with PGLite and Prisma in the browser

**[Live demo →](https://coworkersimulator.github.io/chat-demo/)**

A fully client-side business chat demo that runs entirely in the browser — no server, no backend. It uses Prisma's edge client with a PGlite adapter to run real Prisma queries against an in-browser PostgreSQL database. Because it's a demo, the database is in-memory and resets on every page refresh.

Open the app in two browser tabs and pick a different user in each. Send messages or react to see conversations update live between tabs.

## Features

- **Channels** — create named channels for team discussions
- **Direct messages** — one-on-one or group conversations
- **Emoji reactions** — react to any message
- **Multi-user** — switch between users to simulate conversations
- **Multi-tab support** — shared in-memory database across browser tabs via a SharedWorker, so refreshing one tab doesn't reset the database

## Tech stack

- [React 19](https://react.dev/) + [Vite](https://vitejs.dev/)
- [PGlite](https://electric-sql.com/docs/api/pglite) — PostgreSQL in WebAssembly, running in-browser
- [Prisma](https://www.prisma.io/) — type-safe ORM running in the browser via the edge WASM client and PGlite adapter
- [date-fns](https://date-fns.org/) — date formatting
- [@multiavatar/multiavatar](https://multiavatar.com/) — deterministic user avatars

## Architecture

### SharedWorker database

PGlite runs inside a **SharedWorker** — a single browser worker instance shared across all tabs from the same origin. This means there is one database regardless of how many tabs are open. When a tab refreshes it reconnects to the existing SharedWorker and its in-memory state rather than creating a fresh database. The data is only lost when every tab is closed and the SharedWorker terminates.

### Cross-tab live updates

After any write, the writing tab posts to a `BroadcastChannel`. Other tabs receive the notification and reload the current view, keeping messages and reactions in sync without polling or a server.

## Getting started

```bash
npm install
npm run dev
```

## Build & deploy

```bash
npm run build
```

The app builds to `dist/` as a static site. It deploys automatically to GitHub Pages on push to `main` via the included workflow.

## Database

The queries are managed with Prisma. To pull schema changes from a local PGlite server:

```bash
npm run pglite:server:memory  # start a local PGlite server
npm run prisma:pull            # introspect and regenerate the client
```
