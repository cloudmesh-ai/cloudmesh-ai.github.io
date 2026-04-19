import os
import sys
from pathlib import Path

# Add the root of the project to sys.path
# The current file is in cloudmesh-ai.github.io/docs
# We need to go up two levels to reach the root /Users/grey/Desktop/class/cloudmesh-ai/click
root_dir = Path(__file__).resolve().parents[2]

# Only add the requested packages to sys.path to avoid conflicts with other repositories
for pkg in ["cloudmesh-ai-cmc", "cloudmesh-ai-common"]:
    src_dir = root_dir / pkg / "src"
    if src_dir.exists():
        sys.path.insert(0, str(src_dir))

# -- Project information -----------------------------------------------------
project = 'Cloudmesh AI'
copyright = '2026, Gregor von Laszewski'
author = 'Gregor von Laszewski'

# -- General configuration ---------------------------------------------------
extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.viewcode',
    'sphinx.ext.napoleon',
    'sphinx.ext.autosummary',
]

autosummary_generate = True
templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# Autodoc settings to ensure all members and their docstrings are included
autodoc_default_options = {
    'members': True,
    'member-order': 'bysource',
    'special-members': '__init__',
    'undoc-members': True,
    'inherited-members': True,
    'show-inheritance': True,
}
# Ensure Napoleon handles Google style docstrings
napoleon_google_docstring = True
napoleon_numpy_docstring = False

# -- Options for HTML output -------------------------------------------------
html_theme = 'furo'
html_static_path = ['_static']
html_css_files = [
    'custom.css',
]
html_js_files = [
    'custom.js',
]
