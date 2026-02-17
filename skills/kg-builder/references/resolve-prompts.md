# Stage 3 — Entity Resolution Prompts

Stage 3 deduplicates and normalizes entity surface forms, then optionally maps them to a user-supplied ontology.

## Pass 1 — Intra-document Deduplication

Send this prompt (fill in `{ENTITIES}`):

```
You are an entity resolution expert.

ENTITIES:
{ENTITIES}

Task: Identify groups of entities that refer to the same real-world thing within this document.
Criteria for grouping:
- Same name with different capitalization or punctuation ("apple inc" = "Apple Inc.")
- Abbreviation or acronym expansion ("the US" = "United States", "ML" = "machine learning")
- Pronoun/referent resolution ("the company" when only one Organization exists)
- Partial name matches when unambiguous ("Curie" = "Marie Curie" if only one Curie appears)

Do NOT merge entities that are genuinely different.

Output ONLY valid JSON:
{
  "clusters": [
    {
      "canonical_id": "e1",
      "canonical_text": "Marie Curie",
      "member_ids": ["e1", "e7", "e12"],
      "reason": "e7='Curie', e12='Dr. Curie' are the same person"
    }
  ]
}

Rules:
- canonical_id must be one of the existing entity ids.
- canonical_text should be the most complete, formal form of the name.
- Entities that have no duplicates still appear as single-member clusters.
```

### Filling in {ENTITIES}

Insert the `entities` array from Stage 2's output.

---

## Pass 2 — Update Triples

After deduplication, rewrite all triples to use canonical ids:

For each triple in the Stage 2 output:
- Replace `source_id` with the `canonical_id` of its cluster.
- Replace `target_id` with the `canonical_id` of its cluster.
- Remove self-loops (where source_id == target_id after resolution).
- Remove duplicate triples (same source, relation, target after resolution).

This pass is mechanical — no LLM call needed. Apply the cluster mapping in code.

---

## Pass 3 — User Ontology Mapping (optional)

Only run this pass if the user provides an ontology file or describes one inline.

Send this prompt (fill in `{CANONICAL_ENTITIES}`, `{ONTOLOGY}`):

```
You are an ontology mapping expert.

CANONICAL ENTITIES (after deduplication):
{CANONICAL_ENTITIES}

TARGET ONTOLOGY:
{ONTOLOGY}

Task: Map each canonical entity to the best matching concept in the TARGET ONTOLOGY.
- If a clear match exists, record the ontology URI or ID.
- If no match exists, leave ontology_id as null.
- Do not force mappings; prefer null over a bad match.

Output ONLY valid JSON:
{
  "mappings": [
    { "canonical_id": "e1", "canonical_text": "Marie Curie", "ontology_id": "Q7186", "ontology_label": "Marie Curie" },
    { "canonical_id": "e2", "canonical_text": "Warsaw", "ontology_id": null, "ontology_label": null }
  ]
}
```

---

## Stage 3 Output

Pass to Stage 4:
1. Resolved entity list: one entry per canonical entity (with optional ontology_id).
2. Resolved triple list: all triples using canonical_ids, duplicates removed.
3. The validated schema from Stage 2.
