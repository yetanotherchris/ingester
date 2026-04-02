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

Everything runs locally. Default embedding model uses OpenRouter
(`OPENROUTER_API_KEY` required). Set `USE_LOCAL_EMBEDDINGS=1` for offline
sentence-transformers.

## Quick Start

```bash
# 1. Start ChromaDB
docker compose up -d chromadb

# 2. Ingest your files (replace the path with your own)
docker compose --profile ingest run --rm \
  -e OPENROUTER_API_KEY=sk-or-... \
  -v /path/to/your/obsidian:/sources/obsidian \
  ingest --source obsidian
```

That's it. Your files are now searchable via chroma-mcp (see below).

## Other Sources

Mount any combination of source directories. Pass `--source` to ingest one,
or omit it to ingest everything mounted.

```bash
# Google Drive (after rclone sync)
docker compose --profile ingest run --rm \
  -e OPENROUTER_API_KEY=sk-or-... \
  -v ~/GDrive:/sources/gdrive \
  ingest --source gdrive

# GitHub repos
docker compose --profile ingest run --rm \
  -e OPENROUTER_API_KEY=sk-or-... \
  -v ~/repos:/sources/repos \
  ingest --source repos

# Everything at once
docker compose --profile ingest run --rm \
  -e OPENROUTER_API_KEY=sk-or-... \
  -v ~/ObsidianVault:/sources/obsidian \
  -v ~/GDrive:/sources/gdrive \
  -v ~/repos:/sources/repos \
  ingest

# Check stats
docker compose --profile ingest run --rm ingest --stats

# Wipe and re-ingest
docker compose --profile ingest run --rm \
  -e OPENROUTER_API_KEY=sk-or-... \
  -v ~/ObsidianVault:/sources/obsidian \
  ingest --reset --source obsidian
```

## Embeddings

`OPENROUTER_API_KEY` is required by default. Pass it via the environment
or add it to your compose override. To use a different model:

```bash
docker compose --profile ingest run --rm \
  -e OPENROUTER_API_KEY=sk-or-... \
  -e OPENROUTER_MODEL=google/gemini-embedding-001 \
  -v C:\Users\Chris\ObsidianVault:/sources/obsidian \
  ingest --source obsidian
```

### Local Embeddings (optional)

Set `USE_LOCAL_EMBEDDINGS=1` to use sentence-transformers (all-MiniLM-L6-v2)
with no API key:

```bash
docker compose --profile ingest run --rm \
  -e USE_LOCAL_EMBEDDINGS=1 \
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

## Advanced: Running without Compose

You can run the GHCR image directly with `docker run`. Mount `/data` for
ChromaDB storage and `/sources/<name>` for each source.

```bash
mkdir -p ~/chromadb/data

# Ingest Obsidian vault
docker run --rm \
  -v ~/chromadb/data:/data \
  -v ~/ObsidianVault:/sources/obsidian \
  ghcr.io/yetanotherchris/ingester:latest --source obsidian

# Ingest Google Drive
docker run --rm \
  -v ~/chromadb/data:/data \
  -v ~/GDrive:/sources/gdrive \
  ghcr.io/yetanotherchris/ingester:latest --source gdrive

# Ingest GitHub repos
docker run --rm \
  -v ~/chromadb/data:/data \
  -v ~/repos:/sources/repos \
  ghcr.io/yetanotherchris/ingester:latest --source repos

# Check stats
docker run --rm \
  -v ~/chromadb/data:/data \
  ghcr.io/yetanotherchris/ingester:latest --stats

# Wipe and re-ingest
docker run --rm \
  -v ~/chromadb/data:/data \
  -v ~/ObsidianVault:/sources/obsidian \
  ghcr.io/yetanotherchris/ingester:latest --reset --source obsidian
```

## Notes

- First ingestion is slower — sentence-transformers model downloads inside the container. Subsequent runs use Docker's layer cache.
- Re-running without `--reset` is safe — upserts overwrite existing chunks.
- chroma-mcp and the ingestion script both use PersistentClient on the same data directory. Don't run them simultaneously.
- The sentence-transformers model runs on CPU inside the container. For a personal vault this is fast enough.
