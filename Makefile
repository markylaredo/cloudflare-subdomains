# Makefile for Cloudflare subdomain management

.PHONY: help list add generate auto-update stop-auto-update

help:
	@echo "Cloudflare Subdomain Management"
	@echo "=============================="
	@echo "Available commands:"
	@echo "  make list              - List all configured subdomains"
	@echo "  make add name=NAME host=HOST port=PORT"
	@echo "                         - Add a new subdomain"
	@echo "  make generate          - Generate config.yml and restart service"
	@echo "  make auto-update       - Start automatic config update monitoring"
	@echo "  make stop-auto-update  - Stop automatic config update monitoring"
	@echo ""
	@echo "Examples:"
	@echo "  make add name=infatrack host=192.168.10.153 port=3001"

list:
	@./list-subdomains.sh

add:
	@if [ -z "$(name)" ] || [ -z "$(host)" ] || [ -z "$(port)" ]; then 
		echo "Error: name, host, and port are required"; 
		echo "Usage: make add name=NAME host=HOST port=PORT"; 
		exit 1; 
	fi
	@./add-subdomain.sh $(name) $(host) $(port)

generate:
	@./generate-config.sh

auto-update:
	@echo "Starting auto-update monitor in the background..."
	@echo "Note: Requires inotify-tools to be installed"
	@echo "On Ubuntu/Debian: sudo apt-get install inotify-tools"
	@nohup ./auto-update-config.sh > auto-update.log 2>&1 &
	@echo "Auto-update monitor started. Check auto-update.log for status."

stop-auto-update:
	@echo "Stopping auto-update monitor..."
	@pkill -f auto-update-config.sh || echo "Auto-update monitor not running."
	@echo "Auto-update monitor stopped."

manual-update:
	@echo "Manually updating configuration from subdomains.json..."
	@./manual-update-config.sh
	@echo "Manual update completed."