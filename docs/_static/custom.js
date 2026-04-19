document.addEventListener('DOMContentLoaded', function() {
    // Inject Font Awesome for icons
    const faLink = document.createElement('link');
    faLink.rel = 'stylesheet';
    faLink.href = 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css';
    document.head.appendChild(faLink);

    // Calculate the root path of the documentation
    const pathSegments = window.location.pathname.split('/');
    const rootIndex = pathSegments.indexOf('html');
    const rootPath = rootIndex !== -1 
        ? pathSegments.slice(0, rootIndex + 1).join('/') 
        : '/';

    const nav = document.createElement('div');
    nav.className = 'custom-top-nav';
    nav.innerHTML = `
        <div class="nav-container">
            <a href="${rootPath}index.html" class="nav-logo">Cloudmesh AI</a>
            <div class="nav-links">
                <a href="${rootPath}index.html" title="Home"><i class="fa-solid fa-house"></i></a>
                <a href="${rootPath}quickstart.html">Quickstart</a>
                <a href="${rootPath}commands.html">Commands</a>
                <a href="${rootPath}manual.html">Manual</a>
                <a href="${rootPath}modules.html">API</a>
            </div>
        </div>
    `;
    document.body.insertBefore(nav, document.body.firstChild);

    // Move theme toggle to top right
    // We use a setInterval because Furo's theme switch is often injected/moved by its own scripts
    // after DOMContentLoaded and MutationObservers might miss the final state.
    const moveThemeSwitch = () => {
        // Exhaustive search for the Furo theme switch
        const themeSwitch = 
            document.querySelector('.theme-switch_ui') || 
            document.querySelector('.theme-switch') || 
            document.querySelector('button[aria-label*="theme"]') || 
            document.querySelector('button[aria-label*="dark"]') || 
            document.querySelector('button[aria-label*="light"]') ||
            Array.from(document.querySelectorAll('button, div')).find(el => 
                el.className && typeof el.className === 'string' && el.className.includes('theme-switch')
            );

        if (themeSwitch) {
            const container = nav.querySelector('.nav-container');
            if (themeSwitch.parentElement !== container) {
                container.appendChild(themeSwitch);
            }
        }
    };

    // Check every 100ms for the first 3 seconds to ensure it stays in the navbar
    const themeMoveInterval = setInterval(moveThemeSwitch, 100);
    setTimeout(() => clearInterval(themeMoveInterval), 3000);

    // Remove Furo/Sphinx attribution text from footer while keeping copyright
    const footer = document.querySelector('footer');
    if (footer) {
        // 1. Remove all attribution links
        const links = footer.querySelectorAll('a');
        links.forEach(link => {
            if (link.href.includes('sphinx') || link.href.includes('furo') || link.textContent.includes('Furo')) {
                link.remove();
            }
        });

        // 2. Clean up remaining attribution text (e.g., "Made with", "@pradyunsg's")
        // We use a recursive function to find and clean text nodes
        const cleanText = (node) => {
            if (node.nodeType === Node.TEXT_NODE) {
                node.textContent = node.textContent
                    .replace(/Made with\s+/gi, '')
                    .replace(/@pradyunsg's\s+/gi, '')
                    .replace(/\s+Furo/gi, '')
                    .replace(/Sphinx/gi, '')
                    .trim();
                if (node.textContent === '') {
                    node.remove();
                }
            } else {
                for (let i = node.childNodes.length - 1; i >= 0; i--) {
                    cleanText(node.childNodes[i]);
                }
            }
        };
        cleanText(footer);
    }
});
