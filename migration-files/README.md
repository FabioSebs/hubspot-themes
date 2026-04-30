# Migration files

Staging area for porting the three Linta page designs (location, service,
service-location) into an existing HubSpot theme. Each subfolder is a
self-contained drop-in with only the pieces the corresponding page actually
uses — no dead modules, no unreferenced images, no theme tokens you don't need.

## Folder anatomy

```
migration-files/
├── location/             → goes with location-theme/templates/location.html
│   ├── css/location.css
│   ├── assets/           (images used by the 10 sections)
│   └── sections/         (10 .html section partials)
├── service/              → goes with service-theme/templates/service.html
│   ├── css/service.css
│   ├── assets/           (9 images)
│   └── sections/         (13 .html section partials)
└── service-location/     → goes with service-location-theme/templates/home.html
    ├── css/service-location.css
    ├── assets/           (7 images)
    └── sections/         (11 .html section partials)
```

Section files reference assets via `get_asset_url("../assets/...")` — so they
expect an `assets/` folder sibling to `sections/` in the target theme.

## Migration strategy (per page)

Do this once per migration folder. Order matters.

### 1. Copy modules first

Each set of sections includes one or more modules from the source theme. The
target theme must have these modules at `<target-theme>/modules/<name>.module/`
or the sections will fail to render. Copy from the source theme's `modules/`
folder:

| Migration         | Required modules                                  | Source                          |
|-------------------|---------------------------------------------------|---------------------------------|
| location          | `faq-accordion`, `reviews`, `button`              | `location-theme/modules/`       |
| service           | `faq-accordion`                                   | `service-theme/modules/`        |
| service-location  | `faq-accordion`                                   | `service-location-theme/modules/` |

Skip any module the target theme already provides under the same name — but
verify the field signature matches before assuming compatibility.

### 2. Copy assets

Drop the migration's `assets/` folder into the target theme root as-is. It will
sit alongside the existing `images/` folder; they don't collide. Do not rename
to `images/` unless you also rewrite every `../assets/` path in the section
files (one `sed -i 's|\.\./assets/|../images/|g' sections/*.html` away).

### 3. Copy sections

Drop every file from the migration's `sections/` folder into
`<target-theme>/sections/`. These are HubL DnD partials — they work as soon as
they live in a `sections/` directory.

### 4. Copy CSS and wire it up

Put the migration's CSS file in `<target-theme>/css/` (or wherever the target
theme keeps stylesheets). It is **not** auto-loaded — pick one wiring strategy:

- **Per-template (recommended)** — only loads CSS on pages that need it, and
  avoids the cross-migration `.lt-faq-section` conflict (see Gotchas). Add this
  ABOVE the `{% extends %}` line in your new template:

  ```hubl
  {% set template_css = "../css/location.css" %}
  ```

  The theme's `templates/layouts/base.html` already handles `template_css` and
  emits a `require_css` call when it's set.

- **Global** — append `{% include './location.css' %}` at the bottom of the
  target theme's `css/main.css`. CSS loads on every page. Only do this if you
  want the styles available everywhere.

### 5. Create the page template

Copy the matching template file from the source theme into
`<target-theme>/templates/`. These are already wired for the section paths:

| Migration         | Source template to copy                                      |
|-------------------|--------------------------------------------------------------|
| location          | `location-theme/templates/location.html`                     |
| service           | `service-theme/templates/service.html`                       |
| service-location  | `service-location-theme/templates/home.html`                 |

Then add the `template_css` line at the top so the matching CSS loads. Example
for location:

```hubl
<!--
  templateType: page
  isAvailableForNewContent: true
  label: Location
-->
{% set template_css = "../css/location.css" %}
{% extends "./layouts/base.html" %}

{% block body %}
{% dnd_area "dnd_area"
  label="Main section",
  class="body-container body-container--location"
%}
  {% include_dnd_partial path="../sections/hero-banner.html" %}
  {% include_dnd_partial path="../sections/location-map.html" %}
  ...
{% end_dnd_area %}
{% endblock body %}
```

## Quick reference

### location

- 10 sections: hero-banner, location-map, service-areas, our-roofing-services,
  why-choose-us, our-roofing-process, reviews, faq, estimate-cta, bottom-strip
- CSS uses inline color values (no CSS variables); selector prefix `.lt-`
- Assets: bg-location.jpg, linta-roofing-logo.png, serving-areas/ (6 jpgs),
  section-previews/hero-banner.png

### service

- 13 sections: hero-banner, service-areas, why-choose, who-we-are, signs,
  right-contractor, trust, why-myrtle-beach, cost, benefits, faq, steps,
  final-cta
- CSS defines `--st-*` design tokens at the top; selector prefix `.st-`
- Assets: hero.jpg, team-image.jpg, trust-section.jpg, damaged-shingles.jpg,
  leak-repair.jpg, chimney-repair.jpg, schedule-inspection.png,
  expert-recommendatin.jpg (typo carried from source), repair-peace-of-mind.png

### service-location

- 11 sections: hero, who-we-are, primary-services, other-services, why-choose,
  process, all-locations, surrounding-areas, reviews, faq, estimate-cta
- CSS defines `--sl-*` design tokens; selector prefix `.sl-`
- Assets: hero.jpg, who-we-are.jpg, locations/ (5 jpgs)
- Note: source template is `home.html`, not `service-location.html`

## Gotchas

- **`.lt-faq-section` is defined in all three CSS files** with slightly
  different typography (each tuned to its theme). Per-template CSS loading
  (strategy above) keeps them isolated. Loading two migrations' CSS globally on
  the same page makes the last-loaded definition win.
- **CSS variable scopes are independent** — `--st-*` (service) and `--sl-*`
  (service-location) won't collide with each other or with anything in the
  target theme.
- **Section-level `screenshotPath`** in `location/sections/hero-banner.html`
  points to `../assets/section-previews/hero-banner.png`. Already copied. If you
  rename to `images/`, the screenshot path needs the same rewrite.
- **Module field compatibility** — when reusing a target-theme module that
  shares a name with one of ours (e.g. `button`), confirm the field names match
  what the section's `{% dnd_module path="../modules/button" ... %}` call
  passes. If they diverge, copy our version under a unique name and update the
  section's `path=`.
- **Existing template name collisions** — pick a unique `label:` and filename
  if the target theme already has a `location.html` / `service.html` / `home.html`.
