# Browser Compatibility

Generated profile HTML/CSS runs directly in the browser. There is no compile step for profile code.

Target current stable Firefox, Chrome, and Safari:

- Use standard HTML elements, classes, and `data-vibespace-*` attributes.
- Put all styling in CSS rules, not HTML attributes.
- Prefer flexbox, grid, media queries, CSS variables, transforms, transitions, and keyframes.
- Design responsively with simple breakpoints and stable dimensions.
- Avoid CSS nesting, container queries, cascade layers, scoped CSS, anchor positioning, scroll-driven animations, View Transitions, Houdini `@property`, raw popover/dialog behavior, custom elements, and web components.
- If a visual idea needs a newer feature, create the simpler broadly supported version first.

External frames are not raw HTML. Use only the `data-vibespace-capability="trusted_frame"` placeholder when web context provides one.
