# Extraction Rubric — T1D Beta Cell Autoimmunity

## Domain
Biomedical review article on type 1 diabetes (T1D) pathogenesis, focusing on
beta cell vulnerability and the immune–beta cell dialogue.

## Entity Extraction Rules

### CellType
Extract specific, named cell types. Include both immune and non-immune cells.
- Include: beta cells, alpha cells, CD8+ T cells, CD4+ T cells, regulatory T
  cells, tissue-resident T cells, plasmacytoid dendritic cells, antigen-
  presenting cells (APCs), neutrophils, naive T cells.
- Use consistent short names: e.g., "CD8+ T cells", "beta cells", "APCs".
- Do NOT create separate nodes for the same cell type under different phrasings
  (e.g., "islet-reactive CD8+ T cells" → entity name is "CD8+ T cells").

### Disease
Extract named medical conditions and disease subtypes.
- Include: type 1 diabetes, insulitis, islet autoimmunity, hypophysitis,
  thyroiditis, adrenal disease, lupus, endotypes (as subtypes of T1D).
- Use canonical clinical names: "type 1 diabetes" (not "T1D" as a standalone
  entity name).

### Gene
Extract genes discussed in terms of their genetic function, variants, or
expression. Use canonical HGNC symbols.
- Include: MDA5 (IFIH1), TYK2, PTPN2, Bcl2l1, IRE1α (ERN1), XBP1, JNK1
  (MAPK8), JAK genes, STAT genes, NF-κB (NFKB1), ER aminopeptidase 1 (ERAP1).
- When an alias is given (e.g., "MDA5 (also known as IFIH1)"), use the primary
  name from the article but record the alias in parentheses if helpful.

### Protein
Extract proteins, cytokines, chemokines, hormones, and peptides that are
distinct from their gene symbols or are discussed as functional molecules.
- Include: insulin, proinsulin, pre-proinsulin, C-peptide, chromogranin-A,
  secretogranin-5, urocortin-3, proconvertases, HLA Class I, HLA Class II,
  PD-L1, PD-1, IFN-α, IFN-γ, IL-1β, TNF-α, CCL2, CXCL10, GAD65, IA-2, IAPP,
  TXNIP, GLP-1, Bcl-xL.
- Distinguish proteins from their encoding genes when the article discusses them
  as functional molecules rather than genetic risk factors.

### BiologicalProcess
Extract named cellular or molecular processes, pathways, and mechanisms.
- Include: unfolded protein response (UPR), ER stress, apoptosis, antigen
  presentation, HLA-I presentation, crinophagy, transpeptidation, islet
  inflammation, chemokine release, peripheral tolerance, oxidative damage,
  defective ribosomal product (DRiP) generation, neoepitope generation,
  post-translational modification, beta cell death, T cell priming.
- Use short, descriptive names: e.g., "unfolded protein response", "ER stress",
  "antigen presentation".

### AnatomicalStructure
Extract organs, tissues, organelles, and compartments.
- Include: islets, pancreas, endoplasmic reticulum (ER), pancreatic lymph nodes,
  bloodstream, gut, spleen, crinosomes, secretory granules, exosomes.
- Use singular forms: "islet" → "islets" (plural is fine for collective structures).

### Pathogen
Extract named viruses or other pathogens with a proposed role in T1D.
- Include: Coxsackievirus B (CVB).
- Use the most common name used in the article.

### Biomarker
Extract molecules or signals explicitly described as biomarkers for disease
staging or monitoring.
- Include: C-peptide, proinsulin, GAD65, IAPP, microRNAs, autoantibodies,
  beta cell-specific methylation DNA marks, IFN-α signature.
- Only include entities the article explicitly frames as diagnostic/staging
  biomarkers, not every molecule mentioned.

### Therapy
Extract therapeutic agents, drug classes, or intervention strategies.
- Include: ursodeoxycholic acid, verapamil, GLP-1 agonists, anti-PD-1
  antibodies, anti-PD-L1 antibodies, JAK/TYK2/STAT inhibitors,
  immunotherapies (general), bone marrow transplantation.
- Distinguish drug names from protein names: PD-L1 as a protein is a Protein
  node; "anti-PD-L1 antibodies" is a Therapy node.

### GeneticVariant
Extract named gene variants, alleles, or polymorphism classes associated with
T1D risk.
- Include: HLA Class II risk alleles, MDA5 variants, TYK2 variants, PTPN2
  variants.
- Frame as "<Gene> variant" or "<allele class>" rather than duplicating Gene
  nodes.

---

## Relationship Extraction Rules

- Extract relationships explicitly stated or clearly implied in the article.
- Prefer specific edge types (DESTROYS, TRIGGERS, UPREGULATES) over the generic
  ASSOCIATED_WITH; use ASSOCIATED_WITH only when directionality or mechanism is
  unclear.
- For cytokine effects on beta cells: use UPREGULATES / DOWNREGULATES for
  expression changes and TRIGGERS / CAUSES for process induction.
- Capture negative/protective relationships with INHIBITS or DOWNREGULATES.
- The NOD mouse is a model organism; include relationships derived from NOD
  mouse studies but do not create a "NOD mouse" entity — attribute findings to
  the relevant entities directly.
- Do not extract relationships between generic concepts (e.g., "immunity" and
  "disease") unless a specific mechanism is stated.
- Extract at most one triple per unique (source, edge type, target) combination;
  do not duplicate.

## Scope Limits
- Focus on molecular, cellular, and clinical entities directly relevant to T1D
  pathogenesis and beta cell biology.
- Ignore purely methodological references (e.g., "Fig. 1", numbered citations)
  unless they name specific entities.
- Do not extract person names or author names as entities.
