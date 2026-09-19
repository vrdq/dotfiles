(() => {
  const font = '"JetBrains Mono", monospace';

  // Precise pattern for class and id names identifying icon glyphs
  const iconPattern = /(^|[-_ ])(icon|icons|glyph|symbol|symbols|material-icons[a-z0-9-]*|material-symbols[a-z0-9-]*|google-symbols|fa|fas|far|fab|fal|fad|fat|fak|fa-[a-z0-9-]+|bi|bi-[a-z0-9-]+|mdi|mdi-[a-z0-9-]+|ri-[a-z0-9-]+|ti|ti-[a-z0-9-]+|ph|ph-[a-z0-9-]+|codicon[a-z0-9-]*|octicon[a-z0-9-]*|feather[a-z0-9-]*|nerd|nf[a-z0-9-]*)([-_ ]|$)/i;

  const observedRoots = new WeakSet();

  function isIcon(element, textNode) {
    if (!element || element.nodeType !== Node.ELEMENT_NODE) return false;

    // Direct icon tag names
    const tag = element.tagName.toLowerCase();
    if (tag === 'i' || tag === 'mat-icon' || tag === 'g-icon' || tag === 'iron-icon' || tag === 'vaadin-icon') return true;
    if (element.closest('i, mat-icon, g-icon, iron-icon, vaadin-icon, [role="img"], [role="graphics-symbol"]')) return true;

    // Unicode Private Use Area codepoints
    if (textNode && /[\uE000-\uF8FF\u{F0000}-\u{10FFFD}]/u.test(textNode.nodeValue || '')) return true;

    // Check class names and IDs on the element
    const cls = (element.className && typeof element.className === 'string') ? element.className : '';
    const id = (element.id && typeof element.id === 'string') ? element.id : '';
    if (iconPattern.test(`${cls} ${id}`)) {
      // If element has text, distinguish ligature icons (single compact word) from text-bearing containers
      const txt = (element.textContent || '').trim();
      if (!/\s/.test(txt) && txt.length <= 24) {
        return true;
      }
    }

    // Computed font check for custom icon fonts or ligature settings
    try {
      const computed = window.getComputedStyle(element);
      const family = computed.fontFamily || '';
      if (/icon|symbol|glyph|awesome|material|codicon|nerd|octicon|feather|remix|tabler|phosphor|fontello|icomoon/i.test(family)) {
        return true;
      }
      const feat = computed.fontFeatureSettings || computed.webkitFontFeatureSettings || '';
      if (feat.includes('liga') && !family.includes('JetBrains Mono')) {
        return true;
      }
    } catch (_) {}

    return false;
  }

  function excluded(element, textNode) {
    if (!element || element.nodeType !== Node.ELEMENT_NODE) return true;

    // Preserve editable inputs, textareas, and contenteditable fields
    if (element.isContentEditable) return true;
    if (element.closest('input, textarea, select, option, [contenteditable="true"], [contenteditable=""]')) return true;

    // Preserve code blocks, preformatted text, SVG, MathML
    if (element.closest('pre, code, kbd, samp, svg, math')) return true;

    // Exclude actual icon elements
    if (isIcon(element, textNode)) return true;

    return false;
  }

  function apply(root) {
    if (!root) return;

    // Walk text nodes in the given root
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
    const elementsToStyle = new Set();
    let node;

    while ((node = walker.nextNode())) {
      const val = node.nodeValue;
      if (!val || !/[\p{L}\p{N}]/u.test(val)) continue;

      // Skip Private Use Area icon codepoints
      if (/[\uE000-\uF8FF\u{F0000}-\u{10FFFD}]/u.test(val)) continue;

      const parent = node.parentElement;
      if (!parent) continue;
      if (parent.style.fontFamily && parent.style.fontFamily.includes('JetBrains Mono')) continue;
      if (excluded(parent, node)) continue;

      elementsToStyle.add(parent);
    }

    for (const el of elementsToStyle) {
      el.style.setProperty('font-family', font, 'important');
    }

    // Traverse and pierce open Shadow DOM roots
    try {
      const hosts = (root.querySelectorAll ? root.querySelectorAll('*') : []);
      for (const el of hosts) {
        if (el.shadowRoot && !observedRoots.has(el.shadowRoot)) {
          observedRoots.add(el.shadowRoot);
          apply(el.shadowRoot);
          observeRoot(el.shadowRoot);
        }
      }
    } catch (_) {}
  }

  function observeRoot(rootNode) {
    if (!rootNode) return;
    try {
      new MutationObserver(records => {
        for (const record of records) {
          if (record.type === 'characterData' && record.target) {
            const p = record.target.parentElement;
            if (p && !excluded(p, record.target)) {
              p.style.setProperty('font-family', font, 'important');
            }
          } else {
            for (const node of record.addedNodes) {
              if (node.nodeType === Node.ELEMENT_NODE) {
                apply(node);
              } else if (node.nodeType === Node.TEXT_NODE) {
                const p = node.parentElement;
                if (p && !excluded(p, node)) {
                  p.style.setProperty('font-family', font, 'important');
                }
              }
            }
          }
        }
      }).observe(rootNode, { childList: true, subtree: true, characterData: true });
    } catch (_) {}
  }

  const start = () => {
    const docRoot = document.documentElement || document.body;
    if (docRoot) {
      apply(docRoot);
      observeRoot(docRoot);
    }
  };

  if (document.readyState === 'loading') {
    addEventListener('DOMContentLoaded', start, { once: true });
  } else {
    start();
  }
})();



