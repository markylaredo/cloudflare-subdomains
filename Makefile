# Makefile for Cloudflare subdomain management

.PHONY: help list add generate

help:
	@echo "Cloudflare Subdomain Management"
	@echo "=============================="
	@echo "Available commands:"
	@echo "  make list              - List all configured subdomains"
	@echo "  make add name=NAME host=HOST port=PORT"
	@echo "                         - Add a new subdomain"
	@echo "  make generate          - Generate config.yml and restart service"
	@echo ""
	@echo "Examples:"
	@echo "  make add name=infatrack host=192.168.10.153 port=3001"

list:
	@./list-subdomains.sh

add:
	@if [ -z "$(name)" ] || [ -z "$(host)" ] || [ -z "$(port)" ]; then \\
		echo "Error: name, host, and port are required"; \\
		echo "Usage: make add name=NAME host=HOST port=PORT"; \\
		exit 1; \\
	fi
	@./add-subdomain.sh $(name) $(host) $(port)

generate:
	@./generate-config.sh