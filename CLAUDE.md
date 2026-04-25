# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running the bot

```bash
luvit bot.lua
```

Requires [Luvit](https://luvit.io/) installed. All dependencies are vendored in `deps/`.

## Token/secret files

Tokens are read from plain text files — never hardcoded in source:

| File | Used for |
|---|---|
| `Content/token.txt` | Discord bot token |
| `Content/mashape_token.txt` | RapidAPI/Mashape |
| `Content/openweathermap_token.txt` | OpenWeatherMap |
| `Content/imgur_token.txt` | Imgur |

These files must exist locally but are not committed to the repo.

## Architecture

The entire bot lives in `bot.lua` (~9000 lines). This is a known technical debt — the file is a monolith containing config, event handlers, all commands, and utility functions.

**Key globals defined at the top of `bot.lua`:**
- `channels`, `roles`, `categories`, `permMaps` — hardcoded Discord IDs for this specific server
- `permissions` — discordia enum defining permission levels (`public`, `is_dev`, `is_mod`, `is_admin`, etc.)
- `commands` — hash table where every bot command is registered as `commands["name"] = { f = function, ... }`
- `tokens` — API keys loaded from `Content/*.txt` files
- `color`, `reactions`, `countryFlags` — display constants

**Command structure** (`commands["name"]` table fields):
- `f` — the handler function, always receives `(message, parameters, ...)`
- `perm` — required permission level from the `permissions` enum
- `description`, `usage` — used by `!help`

**Event handlers** are all at the bottom of `bot.lua` (line ~8009+):
`ready`, `messageCreate`, `messageUpdate`, `messageDelete`, `memberJoin`, `memberLeave`, `reactionAdd`, `reactionRemove`, `channelDelete`, `userBan`, `userUnban`, etc.

**`Content/functions.lua`** monkey-patches standard Lua globals: adds methods directly onto `math`, `string`, `table`, and `os`. This is loaded via `require("Content/functions")` (no return value).

**`Content/imageHandler.lua`** wraps ImageMagick (`convert`) and `curl` via `os.execute`/`io.popen`. Returns a chainable object — methods like `:resize()`, `:rotate()`, `:hflip()` queue flags, then `:apply()` runs the shell command.

**Database** is a remote PHP server accessed via HTTP (`db_url`). `getDatabase(fileName)` and `save(fileName, db)` are the main I/O functions.

**`!lua` sandbox**: admins and developers can execute arbitrary Lua through the bot. The sandbox environment (`ENV`) is constructed in `getLuaEnv()` and limits access to `tokens` and external HTTP via a whitelist (`token_whitelist`).

## Dependencies (deps/)

- `discordia` — Discord client library for Luvit
- `fromage` — Transformice/A801 forum HTTP client  
- `coro-http` / `coro-websocket` / `coro-net` — async HTTP/WS primitives
- `sha1`, `secure-socket`, `base64` — crypto/encoding utilities

## Documentation

`Documentation/` contains markdown API docs auto-generated from `--[[Doc ... ]]` blocks in the source. `bot.md` is the reference for all globals and utility functions exposed by `bot.lua`.
