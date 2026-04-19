# Makefile for Cloudmesh AI Documentation

SPHINX_BUILD = sphinx-build
SPHINX_APIDOC = sphinx-apidoc
DOCS_DIR = docs
BUILD_DIR = _build/html/

PACKAGES = cloudmesh.ai.common \
           cloudmesh.ai.cmc

.PHONY: doc view clean

doc:
	@echo "Generating API documentation..."
	@# Clear previous API docs to avoid stale files
	rm -rf $(DOCS_DIR)/api
	mkdir -p $(DOCS_DIR)/api
	@# Process specified packages
	@for pkg_dot in $(PACKAGES); do \
		pkg_dash=$$(echo $$pkg_dot | sed 's/\./-/g'); \
		if [ "$$pkg_dash" = "cloudmesh-ai-cmc" ]; then \
			mkdir -p $(DOCS_DIR)/api/$$pkg_dash; \
			echo "$$pkg_dash package" > $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "==================================================" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo ".. toctree::" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "   :maxdepth: 2" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "   core" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "   commands" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "   utils" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "Detailed API Reference" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "-----------------------" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "Core Modules" > $(DOCS_DIR)/api/$$pkg_dash/core.rst; \
			echo "=============" >> $(DOCS_DIR)/api/$$pkg_dash/core.rst; \
			echo "Command Modules" > $(DOCS_DIR)/api/$$pkg_dash/commands.rst; \
			echo "===============" >> $(DOCS_DIR)/api/$$pkg_dash/commands.rst; \
			echo "Utility Modules" > $(DOCS_DIR)/api/$$pkg_dash/utils.rst; \
			echo "===============" >> $(DOCS_DIR)/api/$$pkg_dash/utils.rst; \
			for mod in cloudmesh.ai.cmc.main cloudmesh.ai.cmc.registry cloudmesh.ai.cmc.context cloudmesh.ai.cmc.utils; do \
				echo "" >> $(DOCS_DIR)/api/$$pkg_dash/core.rst; \
				echo ".. automodule:: $$mod" >> $(DOCS_DIR)/api/$$pkg_dash/core.rst; \
				echo "   :members:" >> $(DOCS_DIR)/api/$$pkg_dash/core.rst; \
				echo "   :undoc-members:" >> $(DOCS_DIR)/api/$$pkg_dash/core.rst; \
				echo "   :show-inheritance:" >> $(DOCS_DIR)/api/$$pkg_dash/core.rst; \
			done; \
			for mod in cloudmesh.ai.command.banner cloudmesh.ai.command.command cloudmesh.ai.command.docs cloudmesh.ai.command.doctor cloudmesh.ai.command.help_cmd cloudmesh.ai.command.man cloudmesh.ai.command.markdown.gemini cloudmesh.ai.command.shell cloudmesh.ai.command.sys.info cloudmesh.ai.command.time cloudmesh.ai.command.tree cloudmesh.ai.command.completion cloudmesh.ai.command.config cloudmesh.ai.command.version cloudmesh.ai.command.plugins cloudmesh.ai.command.telemetry cloudmesh.ai.command.logs; do \
				echo "" >> $(DOCS_DIR)/api/$$pkg_dash/commands.rst; \
				echo ".. automodule:: $$mod" >> $(DOCS_DIR)/api/$$pkg_dash/commands.rst; \
				echo "   :members:" >> $(DOCS_DIR)/api/$$pkg_dash/commands.rst; \
				echo "   :undoc-members:" >> $(DOCS_DIR)/api/$$pkg_dash/commands.rst; \
				echo "   :show-inheritance:" >> $(DOCS_DIR)/api/$$pkg_dash/commands.rst; \
			done; \
		elif [ "$$pkg_dash" = "cloudmesh-ai-common" ]; then \
			mkdir -p $(DOCS_DIR)/api/$$pkg_dash; \
			echo "$$pkg_dash package" > $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "==================================================" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo ".. toctree::" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "   :maxdepth: 2" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "   utils" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "Detailed API Reference" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "-----------------------" >> $(DOCS_DIR)/api/$$pkg_dash/cloudmesh.rst; \
			echo "Utility Modules" > $(DOCS_DIR)/api/$$pkg_dash/utils.rst; \
			echo "===============" >> $(DOCS_DIR)/api/$$pkg_dash/utils.rst; \
			for mod in cloudmesh.ai.common.time cloudmesh.ai.common.logging cloudmesh.ai.common.user cloudmesh.ai.common.aggregation cloudmesh.ai.common.io cloudmesh.ai.common.telemetry cloudmesh.ai.common.stopwatch cloudmesh.ai.common.sys; do \
				echo "" >> $(DOCS_DIR)/api/$$pkg_dash/utils.rst; \
				echo ".. automodule:: $$mod" >> $(DOCS_DIR)/api/$$pkg_dash/utils.rst; \
				echo "   :members:" >> $(DOCS_DIR)/api/$$pkg_dash/utils.rst; \
				echo "   :undoc-members:" >> $(DOCS_DIR)/api/$$pkg_dash/utils.rst; \
				echo "   :show-inheritance:" >> $(DOCS_DIR)/api/$$pkg_dash/utils.rst; \
			done; \
		fi; \
	done
	@echo "Creating modules.rst..."
	@echo "API Reference" > $(DOCS_DIR)/modules.rst; \
	echo "==============" >> $(DOCS_DIR)/modules.rst; \
	echo "" >> $(DOCS_DIR)/modules.rst; \
	echo ".. toctree::" >> $(DOCS_DIR)/modules.rst; \
	echo "   :maxdepth: 2" >> $(DOCS_DIR)/modules.rst; \
	echo "" >> $(DOCS_DIR)/modules.rst; \
	for dir in $(DOCS_DIR)/api/*; do \
		if [ -d "$$dir" ]; then \
			rel_dir=$${dir#$(DOCS_DIR)/}; \
			echo "   $$rel_dir/cloudmesh" >> $(DOCS_DIR)/modules.rst; \
		fi; \
	done
	@echo "Building HTML..."
	$(SPHINX_BUILD) -b html $(shell pwd)/$(DOCS_DIR) $(shell pwd)/$(BUILD_DIR)
	@echo "Documentation build complete in $(BUILD_DIR)."

view:
	@if [ -f $(BUILD_DIR)index.html ]; then \
		open $(BUILD_DIR)index.html; \
	else \
		echo "index.html not found in $(BUILD_DIR). Run 'make doc' first."; \
	fi

clean:
	rm -rf _build
	rm -rf $(DOCS_DIR)/api
	rm -f $(DOCS_DIR)/modules.rst
