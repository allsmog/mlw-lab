# Convenience wrapper for the static lab.
#
# Targets:
#   make build           Build the static-analysis container image.
#   make shell           Drop into the container with samples/ + analysis/ mounted.
#   make triage SAMPLE=samples/foo.bin   Run scripts/triage.sh against a sample.
#   make verify SAMPLE=samples/foo.bin   Run scripts/verify-hashes.sh against a sample.
#   make yara  SAMPLE=samples/foo.bin    Run yara rules against a sample.
#   make clean           Remove the container image.

COMPOSE := docker compose -f static-lab/docker-compose.yml

.PHONY: build shell triage verify yara clean

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

clean:
	-docker rmi mlw-lab/static:latest
