import os
import subprocess
import re
import sys
import json
import threading
from pathlib import Path
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor

# ==========================================
# CONFIGURATION
# ==========================================
SCRIPT_DIR = Path(__file__).parent
DOCS_REPO_ROOT = SCRIPT_DIR.parent
SIBLING_ROOT = DOCS_REPO_ROOT.parent

# Central mapping for the "Components"
REPO_CONFIG = {
    "cloudmesh-ai-common": "cma_common",
    "cloudmesh-ai-git": "cma_git",
    "cloudmesh-ai-shell": "cma_shell",
    "cloudmesh-ai-multipass": "cma_multipass"
}

# Thread lock to keep console reporting "nice" and readable
print_lock = threading.Lock()

def safe_print(msg):
    with print_lock:
        print(msg)

# ==========================================
# CORE UTILITIES
# ==========================================

def run_shell_cmd(args):
    """Run shell commands and return output or error string."""
    try:
        return subprocess.check_output(args, text=True).strip()
    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        return f"Error executing {' '.join(args)}: {e}"

def get_repo_version(repo_name):
    """Scrapes __version__ from the sibling repo's __init__.py."""
    pkg_name = REPO_CONFIG.get(repo_name)
    init_path = SIBLING_ROOT / repo_name / "src" / pkg_name / "__init__.py"
    if init_path.exists():
        content = init_path.read_text()
        match = re.search(r'__version__\s*=\s*[\'"]([^\'"]+)[\'"]', content)
        if match:
            return match.group(1)
    return "0.0.1" 

# ==========================================
# UI COMPONENTS & WORKERS
# ==========================================

def generate_github_note(repo_name):
    """Generates the split-aligned blue header for Quarto callouts."""
    version = get_repo_version(repo_name)
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    git_url = f"https://github.com/cloudmesh-ai/{repo_name}"

    header_html = (
        f"Github <span style='float: right; font-weight: normal; font-size: 0.85em;'>"
        f"Version: {version} &nbsp;&nbsp; Date: {timestamp}</span>"
    )
    
    return "\n".join([
        f"::: {{.callout-note appearance='default' icon=false}}",
        f"## {header_html}",
        f"**Source Code:** [{git_url}]({git_url})",
        ":::",
        ""
    ])

def process_component(repo_name, plugin_data):
    """Worker to generate a component page in parallel."""
    repo_abs_path = (SIBLING_ROOT / repo_name).resolve()
    target_path = DOCS_REPO_ROOT / "docs" / "repos" / f"{repo_name}.qmd"
    target_path.parent.mkdir(parents=True, exist_ok=True)
    
    title = f"{repo_name.replace('cloudmesh-ai-', '').title()}"
    lines = ["---", f"title: \"{title}\"", "---", "", generate_github_note(repo_name), "# README", ""]
    
    readme_file = repo_abs_path / "README.md"
    lines.append(readme_file.read_text(encoding="utf-8") if readme_file.exists() else "> README.md not found.")
    lines.append("\n---\n# Command Reference\n")

    local_registry = []
    for plugin in plugin_data:
        p_path_str = plugin.get("File Path", "")
        if not p_path_str or p_path_str == "-": continue
        p_path = Path(p_path_str).resolve()
        
        if repo_abs_path in p_path.parents or repo_abs_path == p_path:
            cmd_name = plugin['Plugin']
            if "(" in cmd_name or ")" in cmd_name or "core" in cmd_name.lower():
                continue

            safe_print(f"    -> Found command '{cmd_name}' in {repo_name}")
            help_text = run_shell_cmd(["cma", "help", cmd_name])
            lines.extend([f"## `{cmd_name}` {{#command-{cmd_name}}}", "", "```text", help_text, "```", ""])
            
            # Use relative link for the index and versions page
            local_registry.append({
                "name": cmd_name, 
                "link": f"../repos/{repo_name}.qmd#command-{cmd_name}"
            })

    target_path.write_text("\n".join(lines), encoding="utf-8")
    safe_print(f"  [OK] Component: {repo_name}")
    return local_registry

def write_versions_page(all_commands):
    """Generates versions page and injects links into the generated table."""
    raw_table = run_shell_cmd(["cma", "version", "--format", "md"])
    
    # Inject links into the Markdown table
    linked_table = raw_table
    for cmd in all_commands:
        # Matches the command name if it sits between table pipes
        pattern = rf"\| {cmd['name']} \|"
        replacement = f"| [{cmd['name']}]({cmd['link']}) |"
        linked_table = re.sub(pattern, replacement, linked_table)

    path = DOCS_REPO_ROOT / "docs" / "manual" / "versions.qmd"
    path.parent.mkdir(parents=True, exist_ok=True)
    
    content = ["---", "title: \"Versions\"", "---", "", "## Components and Commands", "", linked_table]
    path.write_text("\n".join(content), encoding="utf-8")
    safe_print(f"  [OK] Manual: versions.qmd (Linked)")

# ==========================================
# MAIN EXECUTION
# ==========================================

def main():
    print(f"Build Started at {datetime.now().strftime('%H:%M:%S')}")
    
    json_data = run_shell_cmd(["cma", "version", "-f", "--format", "json"])
    try:
        plugin_data = json.loads(json_data)
    except:
        plugin_data = []

    all_commands = []

    print("\n--- Generating Components ---")
    with ThreadPoolExecutor() as executor:
        repo_futures = [executor.submit(process_component, r, plugin_data) for r in REPO_CONFIG.keys()]
        for future in repo_futures:
            try:
                all_commands.extend(future.result())
            except Exception as e:
                print(f"  [!] Thread Error: {e}")

    # Generate Manual with injected URLs
    print("\n--- Generating Versions Manual ---")
    write_versions_page(all_commands)

    # Generate Command Index
    print("\n--- Generating Command Index ---")
    sorted_cmds = sorted(all_commands, key=lambda x: x['name'])
    idx_content = ["This index contains links to all discovered commands:\n"]
    for cmd in sorted_cmds:
        idx_content.append(f"* [{cmd['name']}]({cmd['link']})")
    
    idx_path = DOCS_REPO_ROOT / "docs" / "commands" / "index.qmd"
    idx_path.parent.mkdir(parents=True, exist_ok=True)
    idx_path.write_text("---\ntitle: \"Command Index\"\n---\n\n" + "\n".join(idx_content))
    
    print(f"  [OK] Index: index.qmd")
    print(f"\nBuild Complete: {datetime.now().strftime('%H:%M:%S')}")

if __name__ == "__main__":
    main()