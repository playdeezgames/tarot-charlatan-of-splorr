# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

"Tarot Charlatan of SPLORR!!" is an MCP server, written in Odin, for tarot card readings. It was ported from a VB.NET terminal app, which has been removed (it remains in git history). There is no terminal UI; if one is wanted later it would be a wrapper around the MCP server.

The server only deals cards: it shuffles, draws, and reports positions and reversals. Interpreting the cards is left to the calling model (the end goal, per the README, is AI-assisted readings for streaming).

## Commands

All from `odin/`:

```bash
odin build . -out:tcos-mcp -vet -strict-style   # build (binary is gitignored)
odin test . -vet -strict-style                  # run tests
odin test . -vet -strict-style -define:ODIN_TEST_NAMES=tcos.test_deck_draw_exhausts   # single test
printf '%s\n' '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"draw_reading","arguments":{"question":"q","spread":"three_card","seed":42}}}' | ./tcos-mcp   # smoke test
```

Register with Claude Code: `claude mcp add tarot -- <repo>/odin/tcos-mcp`.

## Architecture

Single Odin package `tcos`, stdio MCP transport (newline-delimited JSON-RPC; **stdout is protocol-only**, log to stderr).

- `cards.odin`: the 78-card `CARDS` table, filled at startup by `cards_init()` (called from `main`, and from tests via `ensure_cards`). Names are heap-allocated for process lifetime. Card id = index into `CARDS` (56 minors in suit order Wands, Cups, Swords, Pentacles, then 22 majors); `mcp.odin` relies on `type >= 56` meaning major arcana.
- `spreads.odin`: the `SPREADS` table (single_card, three_card, celtic_cross). Adding a spread is one table row; the tool schema enum and `list_spreads` derive from it.
- `deck.odin`: seedable shuffle of a fresh deck, each card independently reversed at 50%.
- `mcp.odin`: protocol handling and the two tools, `list_spreads` and `draw_reading` (`question`, `spread`, optional `seed` for reproducible draws). Notifications get no reply. Dynamic literals are enabled in this file, so each message is handled with `context.allocator = context.temp_allocator` and freed per loop iteration.
- `tcos_test.odin`: tests for cards, deck and spreads. The MCP layer is untested.

Not implemented: reading persistence, card meanings.

`ss/` holds Fool card screenshots (28/56/112px) from earlier card-image experiments; nothing references them.
