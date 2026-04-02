# ingester

Ingest your personal files (Google Drive, Markdown) into ChromaDB, so you can query them in Claude.

## Architecture

```
[Obsidian .md files]  ──┐
[rclone'd GDrive]     ──┼──> docker run ingest ──> ChromaDB (persistent, local)
[GitHub repos]        ──┘                                       │
                                                                │
                                   Claude Code ──> chroma-mcp ──┘
```

Everything runs locally. Default embedding model is sentence-transformers
(all-MiniLM-L6-v2) — no API keys needed.

## Quick Start

### 1. Start ChromaDB

```bash
docker compose up -d chromadb
```

### 2. Run Ingestion

Mount source directories with `-v` and pass `--source` to select what to ingest.

**Ingest Obsidian vault:**

```bash
docker compose --profile ingest run --rm \
  -v C:\Users\Chris\ObsidianVault:/sources/obsidian \
  ingest --source obsidian
```

**Ingest Google Drive (after rclone sync):**

```bash
rclone sync gdrive:/ C:\Users\Chris\GDrive --progress

docker compose --profile ingest run --rm \
  -v C:\Users\Chris\GDrive:/sources/gdrive \
  ingest --source gdrive
```

**Ingest GitHub repos:**

```bash
docker compose --profile ingest run --rm \
  -v C:\Users\Chris\repos:/sources/repos \
  ingest --source repos
```

**Ingest everything at once:**

```bash
docker compose --profile ingest run --rm \
  -v C:\Users\Chris\ObsidianVault:/sources/obsidian \
  -v C:\Users\Chris\GDrive:/sources/gdrive \
  -v C:\Users\Chris\repos:/sources/repos \
  ingest
```

**Check stats:**

```bash
docker compose --profile ingest run --rm ingest --stats
```

**Wipe and re-ingest:**

```bash
docker compose --profile ingest run --rm \
  -v C:\Users\Chris\ObsidianVault:/sources/obsidian \
  ingest --reset --source obsidian
```

## OpenRouter Embeddings (optional)

Pass your API key as an environment variable to switch from local
sentence-transformers to OpenRouter:

```bash
docker compose --profile ingest run --rm \
  -e OPENROUTER_API_KEY=sk-or-... \
  -v C:\Users\Chris\ObsidianVault:/sources/obsidian \
  ingest --source obsidian
```

To use a different model:

```bash
docker compose --profile ingest run --rm \
  -e OPENROUTER_API_KEY=sk-or-... \
  -e OPENROUTER_MODEL=google/gemini-embedding-001 \
  -v C:\Users\Chris\ObsidianVault:/sources/obsidian \
  ingest --source obsidian
```

**Important:** If switching embedding models, run with `--reset` first.
Vectors from different models are not compatible.

## Claude Code Integration (chroma-mcp)

```powershell
pip install uv
claude mcp add chroma -- uvx chroma-mcp --client-type persistent --data-dir C:\chromadb\data
claude mcp list
```

Or manually edit `.claude/settings.local.json`:

```json
{
  "mcpServers": {
    "chroma": {
      "command": "uvx",
      "args": [
        "chroma-mcp",
        "--client-type", "persistent",
        "--data-dir", "C:\\chromadb\\data"
      ]
    }
  }
}
```

Claude Code will then have access to:

- `chroma_query_documents` — semantic search
- `chroma_list_collections` — list what's indexed
- `chroma_get_collection_info` — collection stats
- `chroma_get_documents` — retrieve by ID or metadata filter

## Notes

- First ingestion is slower — sentence-transformers model downloads inside the container. Subsequent runs use Docker's layer cache.
- Re-running without `--reset` is safe — upserts overwrite existing chunks.
- chroma-mcp and the ingestion script both use PersistentClient on the same data directory. Don't run them simultaneously.
- The sentence-transformers model runs on CPU inside the container. For a personal vault this is fast enough.
