# ==========================================
# Cloudmesh AI Documentation Makefile
# ==========================================

# Variables
PYTHON       := python3
QUARTO       := quarto
BUILD_SCRIPT := bin/make_www.py

# Detect number of CPU cores for parallel rendering
# Default to 4 if detection fails
JOBS := $(shell nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

.PHONY: all www view publish clean help

# Default target
all: www

help:
	@echo "Cloudmesh AI Documentation Build System"
	@echo ""
	@echo "Targets:"
	@echo "  make www      - Full clean, component discovery, and parallel render"
	@echo "  make view     - Run discovery and start Quarto live preview"
	@echo "  make publish  - Full build and deploy to GitHub Pages"
	@echo "  make clean    - Wipe Quarto cache and build artifacts (fixes BadResource errors)"

# --- Core Targets ---

# The 'www' target: Parallelizes both the Python discovery and the Quarto render
www: clean
	@echo "--- [1/3] Running Parallel Component Discovery ---"
	$(PYTHON) $(BUILD_SCRIPT)
	@echo "--- [2/3] Rendering Quarto Website ($(JOBS) jobs) ---"
	# Using environment variable to avoid Pandoc 'Unknown option' errors
	QUARTO_JOBS=$(JOBS) $(QUARTO) render
	@echo "--- [3/3] Build complete. Site in _site/index.html"

# Live preview for local development
view:
	$(PYTHON) $(BUILD_SCRIPT)
	QUARTO_JOBS=$(JOBS) $(QUARTO) preview

# Clean target: Specifically removes .quarto to prevent Deno/Sass cache corruption
clean:
	@echo "--- Cleaning Quarto Cache and Build Artifacts ---"
	rm -rf .quarto/
	rm -rf _site/
	@# Note: 'quarto clean' is omitted as it is not a valid command in all versions

# Publish to GitHub Pages
publish: clean
	@echo "--- Preparing Production Build ---"
	$(PYTHON) $(BUILD_SCRIPT)
	@echo "--- Rendering for Production ---"
	QUARTO_JOBS=$(JOBS) $(QUARTO) render
	@echo "--- Publishing to gh-pages ---"
	$(QUARTO) publish gh-pages

# ==========================================
# End of Makefile
# ==========================================