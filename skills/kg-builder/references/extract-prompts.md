# Stage 1 — Entity & Relationship Extraction Prompts

Stage 1 runs two sequential LLM passes on the input document.

## Pass 1 — Entity Extraction

Send this prompt (fill in `{DOCUMENT}` and `{RUBRIC}`):

```
You are an expert information-extraction assistant.

RUBRIC:
{RUBRIC}

DOCUMENT:
{DOCUMENT}

Task: Extract all entities from the DOCUMENT that match the types defined in the RUBRIC.
For each entity, record:
  - id: unique identifier (e1, e2, ...)
  - text: the exact surface form as it appears in the document
  - type: the entity type from the rubric
  - context: the sentence or clause where the entity appears

Output ONLY valid JSON. Do not include explanation or commentary.

Format:
{
  "entities": [
    { "id": "e1", "text": "...", "type": "...", "context": "..." }
  ]
}
```

### Filling in {RUBRIC}

- If `kg_rubric.md` exists in the working directory: insert its full contents.
- Otherwise: insert the full contents of `references/default-rubric.md`.
- If the user described a rubric inline: insert their description verbatim.

### Filling in {DOCUMENT}

Insert the full contents of the input document.
For documents longer than ~8,000 words, process in overlapping chunks of ~4,000 words (500-word overlap):
1. Run Pass 1 on each chunk to get per-chunk entity lists. Assign globally unique ids (chunk 1: e1–eN, chunk 2: eN+1–eM, etc.). Merge all entity lists.
2. Run Pass 2 on EACH CHUNK separately using only the entities extracted from that chunk. After all chunks, merge the triple lists. Duplicate triples (same source text + relation + target text) should be deduplicated, keeping the first occurrence.

---

## Pass 2 — Relationship Extraction

After Pass 1 completes, send this prompt (fill in `{ENTITIES}`, `{DOCUMENT}`, `{RUBRIC}`):

```
You are an expert information-extraction assistant.

RUBRIC:
{RUBRIC}

DOCUMENT:
{DOCUMENT}

ENTITIES ALREADY IDENTIFIED:
{ENTITIES}

CITATION KEYS AVAILABLE:
{CITATION_KEYS}

Task: Extract all relationships between the entities listed above.
Only use entity ids from the ENTITIES list above. Do not create new entity ids.
For each relationship, record:
  - source_id: id of the source entity
  - relation: relationship label (uppercase, underscore-separated)
  - target_id: id of the target entity
  - evidence: copy the supporting sentence verbatim from the DOCUMENT — use the exact characters as they appear; do not paraphrase, condense, or rephrase
  - citation_keys: list the keys from CITATION KEYS AVAILABLE that appear in or immediately adjacent to the evidence sentence; use [] if none

Granularity rule: when the text describes a chain of events (e.g., "A activates B, which then causes C"), extract each step as a separate triple (A→B and B→C). Do not collapse multi-step chains into a single A→C edge. Prefer granular, step-by-step triples over high-level summary edges.

Output ONLY valid JSON. Do not include explanation or commentary.

Format:
{
  "triples": [
    { "source_id": "e1", "relation": "BORN_IN", "target_id": "e2", "evidence": "...", "citation_keys": ["[14]"] }
  ]
}
```

### Filling in {ENTITIES}

Insert the JSON output from Pass 1.

### Filling in {CITATION_KEYS}

- If `kg_output/citation_map.json` exists and is non-empty: insert a newline-separated list of all keys (e.g. `[14]`, `(Smith et al., 2020)`).
- Otherwise: insert `none`.

---

## Pass 2b — Isolated-Node Check

After Pass 2 completes, check for entities that appear in no triple (neither as `source_id` nor `target_id`). For each isolated entity:

1. Re-read the document section(s) where that entity appears.
2. Extract at least one relationship for it, or remove the entity from the entity list if no relationship can be found.

This step requires no LLM call if you can identify isolated nodes mechanically. If the entity list is large, send this prompt (fill in `{ISOLATED_ENTITIES}` and `{DOCUMENT}`):

```
You are an expert information-extraction assistant.

DOCUMENT:
{DOCUMENT}

The following entities were extracted but have no relationships yet:
{ISOLATED_ENTITIES}

Task: For each isolated entity, find at least one relationship to another known entity that is explicitly stated or strongly implied in the DOCUMENT. Output triples in the same JSON format as Pass 2. If no relationship can be found for an entity, omit it.

Granularity rule: when the text describes a chain A → B → C, extract each step separately.

Output ONLY valid JSON:
{
  "triples": [
    { "source_id": "e1", "relation": "LABEL", "target_id": "e2", "evidence": "...", "citation_keys": [] }
  ]
}
```

Merge any new triples into the Pass 2 output before proceeding to Stage 2.

---

## Merging Pass 1 + Pass 2 Output

Combine into a single JSON object:

```json
{
  "entities": [ ...from Pass 1... ],
  "triples": [ ...from Pass 2... ]
}
```

Store this as the Stage 1 output to pass to Stage 2.

---
