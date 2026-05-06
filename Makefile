# Convenience wrapper for the static lab.
#
# Targets:
#   make build           Build the static-analysis container image.
#   make shell           Drop into the container with samples/ + analysis/ mounted.
#   make triage SAMPLE=samples/foo.bin   Run scripts/triage.sh against a sample.
#   make verify SAMPLE=samples/foo.bin   Run scripts/verify-hashes.sh against a sample.
#   make yara  SAMPLE=samples/foo.bin    Run yara rules against a sample.
#   make carve SAMPLE=samples/foo.bin    Carve embedded resources out of a PE.
#   make report          Compile report/*.md into report/stuxnet-report.pdf via pandoc.
#   make slides          Compile slides/deck.md into slides/deck.pdf via marp.
#   make hooks           Enable the repo's pre-commit hook.
#   make clean           Remove the container image.

COMPOSE := UID=$(shell id -u) GID=$(shell id -g) docker compose -f static-lab/docker-compose.yml

.PHONY: build shell triage verify yara carve report slides hooks clean

REPORT_SOURCES := \
  report/00-abstract.md \
  report/01-introduction.md \
  report/02-methodology.md \
  report/03-propagation.md \
  report/04-persistence.md \
  report/05-payload.md \
  report/06-evasion.md \
  report/07-detection-defenses.md \
  report/08-conclusion.md \
  report/references.md

build:
	$(COMPOSE) build

shell:
	$(COMPOSE) run --rm static-lab

triage:
	@if [ -z "$(SAMPLE)" ]; then echo "usage: make triage SAMPLE=samples/<file>"; exit 2; fi
	$(COMPOSE) run --rm static-lab bash scripts/triage.sh "$(SAMPLE)"

verify:
	@if [ -z "$(SAMPLE)" ]; then echo "usage: make verify SAMPLE=samples/<file>"; exit 2; fi
	$(COMPOSE) run --rm static-lab bash scripts/verify-hashes.sh "$(SAMPLE)"

yara:
	@if [ -z "$(SAMPLE)" ]; then echo "usage: make yara SAMPLE=samples/<file>"; exit 2; fi
	$(COMPOSE) run --rm static-lab yara -r yara/stuxnet.yar "$(SAMPLE)"

carve:
	@if [ -z "$(SAMPLE)" ]; then echo "usage: make carve SAMPLE=samples/<file>"; exit 2; fi
	$(COMPOSE) run --rm static-lab python3 scripts/carve-resources.py "$(SAMPLE)" -o "analysis/$(notdir $(SAMPLE))/carved"

report: report/stuxnet-report.pdf

report/stuxnet-report.pdf: $(REPORT_SOURCES)
	@command -v pandoc >/dev/null 2>&1 || { \
	  echo "pandoc not installed. apt: sudo apt install pandoc texlive-xetex"; \
	  echo "         brew: brew install pandoc basictex"; \
	  exit 1; }
	pandoc -s --toc --number-sections \
	  --pdf-engine=xelatex \
	  --metadata title="Stuxnet: A Multi-Axis Analysis" \
	  --metadata author="$$(git config user.name)" \
	  --metadata date="$$(date +%Y-%m-%d)" \
	  -o $@ $(REPORT_SOURCES)
	@echo "[+] wrote $@"

slides: slides/deck.pdf

slides/deck.pdf: slides/deck.md
	@command -v marp >/dev/null 2>&1 || { \
	  echo "marp-cli not installed. install: npm install -g @marp-team/marp-cli"; \
	  exit 1; }
	marp --pdf --allow-local-files -o $@ $<
	@echo "[+] wrote $@"

hooks:
	git config core.hooksPath .githooks
	@echo "[+] pre-commit hook enabled (refuses binary / sample commits)"

clean:
	-rm -f report/stuxnet-report.pdf slides/deck.pdf
	-docker rmi mlw-lab/static:latest
