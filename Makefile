# =====================================================
# Makefile
# =====================================================

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# -----------------------------------------------------
# Go environment
# -----------------------------------------------------
GOPATH        ?= $(shell go env GOPATH)
BIN_DIR       := $(GOPATH)/bin
GOLANGCI_LINT := $(BIN_DIR)/golangci-lint
GOLANGCI_VER  := v1.54.2

APP_NAME      := vuln-list-update

# -----------------------------------------------------
# Colors (safe fallback if tput not available)
# -----------------------------------------------------
TPUT := $(shell command -v tput >/dev/null 2>&1 && echo tput)

BOLD    := $(shell $(TPUT) bold 2>/dev/null || echo "")
PURPLE  := $(shell $(TPUT) setaf 5 2>/dev/null || echo "")
GREEN   := $(shell $(TPUT) setaf 2 2>/dev/null || echo "")
CYAN    := $(shell $(TPUT) setaf 6 2>/dev/null || echo "")
RED     := $(shell $(TPUT) setaf 1 2>/dev/null || echo "")
RESET   := $(shell $(TPUT) sgr0 2>/dev/null || echo "")

TITLE   := $(BOLD)$(PURPLE)
SUCCESS := $(BOLD)$(GREEN)

# -----------------------------------------------------
# Phony targets
# -----------------------------------------------------
.PHONY: all lint lint-fix test build clean help tools

# -----------------------------------------------------
# Default
# -----------------------------------------------------
all: lint test build

# -----------------------------------------------------
# Tooling
# -----------------------------------------------------
tools: $(GOLANGCI_LINT)

$(GOLANGCI_LINT):
	@echo "$(TITLE)==> Installing golangci-lint ($(GOLANGCI_VER))$(RESET)"
	@curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
		| sh -s -- -b $(BIN_DIR) $(GOLANGCI_VER)

# -----------------------------------------------------
# Linting
# -----------------------------------------------------
lint: tools
	@echo "$(TITLE)==> Running golangci-lint$(RESET)"
	@$(GOLANGCI_LINT) run

lint-fix: tools
	@echo "$(TITLE)==> Running golangci-lint (auto-fix)$(RESET)"
	@$(GOLANGCI_LINT) run --fix

# -----------------------------------------------------
# Testing
# -----------------------------------------------------
test:
	@echo "$(TITLE)==> Running tests$(RESET)"
	@go test -race ./...

# -----------------------------------------------------
# Build
# -----------------------------------------------------
build:
	@echo "$(TITLE)==> Building $(APP_NAME)$(RESET)"
	@go build -o $(APP_NAME) .

# -----------------------------------------------------
# Cleanup
# -----------------------------------------------------
clean:
	@echo "$(RED)==> Cleaning build artifacts$(RESET)"
	@rm -f $(APP_NAME)

# -----------------------------------------------------
# Help
# -----------------------------------------------------
help:
	@echo "$(CYAN)Available targets:$(RESET)"
	@echo "  make lint        Run linter"
	@echo "  make lint-fix    Run linter with auto-fix"
	@echo "  make test        Run tests with race detector"
	@echo "  make build       Build binary"
	@echo "  make clean       Remove build artifacts"
	@echo "  make tools       Install required tools"
