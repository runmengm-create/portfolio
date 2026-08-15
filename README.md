# Portfolio Local Preview

This folder is an independent local prototype. It does not modify the `portfolio-work` Git repository.

## Preview

```bash
cd /Users/runmeng.ma/Desktop/马润萌/portfolio-local-preview
python3 -m http.server 4174
```

Open `http://127.0.0.1:4174/`.

## Review preview

Open `http://127.0.0.1:4174/preview.html` for the independent Role → About → Selected Works review page. Its chat UI posts only to `window.PREVIEW_CHAT_ENDPOINT || "/api/chat"`; no private key or hidden instruction is shipped to the browser. If the endpoint is unavailable, the UI reports “安全服务尚未连接” and restores the user’s input.

## Current scope

- Hand-drawn contour entry transition and responsive Hero
- Role Overview before About, using transparent artwork layers and HTML copy
- About method statement with Songti/Sans font switching
- Selected Works open-fields layout with one-shot blue route and project drawers
- Text-led Education section with awards and volunteer experience
- Digital Twin placeholder and Footer
- Independent accessible preview page with four project links and reduced-motion route/observation states
- Desktop/mobile layouts with reduced-motion fallback

Approved PNGs remain visual sources; runtime artwork is separated under `assets/illustrations/` and page text stays in HTML.
