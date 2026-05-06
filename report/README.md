# Report

Markdown source for the academic write-up. Compile to PDF with pandoc:

```bash
pandoc -s --toc --number-sections \
  --metadata title="Stuxnet: A Multi-Axis Analysis" \
  --metadata author="<your name>" \
  --metadata date="<YYYY-MM-DD>" \
  -o stuxnet-report.pdf \
  00-abstract.md \
  01-introduction.md \
  02-methodology.md \
  03-propagation.md \
  04-persistence.md \
  05-payload.md \
  06-evasion.md \
  07-detection-defenses.md \
  08-conclusion.md \
  references.md
```

## Workflow

1. As you work through each axis (`docs/propagation.md`, `docs/persistence.md`,
   etc.), copy your findings out of `analysis/<axis>/` into the matching
   chapter file here.
2. Add screenshots, decompilation excerpts, and tables under `report/figures/`.
3. Track citations in `references.md` (BibTeX-style or simple list).
4. Produce a final PDF at the end of the project.

Each chapter file ships as a skeleton with prompts. Replace the
`> TODO:` lines with your own writing.
