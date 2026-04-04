# Functional Spec: `zolam mcp` command

## Requirements

1. `zolam mcp` registers the chroma-mcp MCP server at user scope in Claude Code
2. The command runs `claude mcp add --scope user chroma -- uvx chroma-mcp --client-type http --host localhost --port 8000 --ssl false`
3. stdout and stderr from the `claude` process are forwarded to the terminal
4. The command returns a non-zero exit code if the `claude` CLI fails or is not found
5. No flags are required -- the command uses the standard defaults
