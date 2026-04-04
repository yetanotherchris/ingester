# Proposal: Add `mcp` CLI command to register chroma-mcp server

## Motivation

Setting up the chroma-mcp server for Claude Code requires remembering the exact `claude mcp add` command with the correct flags (`--scope user`, `--client-type http`, `--host`, `--port`, `--ssl false`). This is error-prone and documented only in the README. A CLI command makes this a one-step operation.

## Scope

- Add a new `zolam mcp` subcommand that runs `claude mcp add --scope user chroma -- uvx chroma-mcp --client-type http --host localhost --port 8000 --ssl false`
- The command shells out to `claude` CLI, so it requires Claude Code to be installed
- No flags needed initially -- the command uses sensible defaults matching the current setup
- Update README to reference the new command
