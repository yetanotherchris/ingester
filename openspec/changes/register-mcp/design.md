# Design: `zolam mcp` command

## Changes

### CLI (`src/cmd/zolam/main.go`)
- Add `newMcpCmd()` function returning a `*cobra.Command`
- Use: `mcp`, Short: "Register chroma-mcp server with Claude Code"
- Executes `claude mcp add --scope user chroma -- uvx chroma-mcp --client-type http --host localhost --port 8000 --ssl false` via `os/exec`
- Streams stdout/stderr to the terminal so the user sees Claude CLI output
- Register it in `rootCmd.AddCommand()`

### README
- Update the Claude Code Integration section to mention `zolam mcp` as the preferred setup method
- Keep the manual command as a fallback reference

### No changes needed
- No new packages required (`os/exec` is stdlib)
- No Docker or config changes
- No TUI changes
