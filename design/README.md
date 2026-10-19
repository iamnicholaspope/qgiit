# QGIIT homepage design

## Placeholder content expansion

The desktop homepage now includes Programs, Why QGIIT, Study options, Admissions, Tuition and funding, Student support, and a final admissions call to action. Visible navigation and footer admissions/student resources were added. Program names, qualifications, durations, admissions requirements, fees, payment plans, services, intake dates, and contacts are illustrative placeholders, labeled in the design. Existing reference photographs remain temporary.

The old equipment feature and quotation cards were replaced with education-focused sections. Reusable assets sit outside the homepage: `QGIIT / Button` (Primary/Secondary, Default/Hover), `QGIIT / Program card` (four editable text properties), and a compact button-state preview. New `QGIIT / Layout` spacing/radius variables and six `QGIIT / ...` text styles support the additions. Desktop content uses auto layout and the existing color aliases.

`home-expanded.png` shows the complete expansion before the final button-label and equal-card-height correction. `admissions-placeholder.png` shows the final admissions correction. Navigation/actions are visual placeholders; no working application routes, forms, or login were created. Mobile design and React implementation remain pending.

Figma: https://www.figma.com/design/kLW7eZ3UB4pn3o61P8buC3/qgiit?node-id=1-1902

The first desktop branding pass preserves the reference layout and introduces 28 variables in `QGIIT / Colors`, using a single Brand mode. Semantic variables alias primitives; all include CSS code syntax. `colors.css` mirrors these variables for the future React implementation.

Palette: deep navy #04152D, navy #06254B, royal blue #1459B8, gold #D9AA45, silver-white #F5F7FA. Dark text is used on gold actions. A darker gold #805811 is available for text on light backgrounds.

The supplied logo appears in the header and footer. Borrowed institution names, numerical claims, testimonials, and company logos were replaced or hidden. Homepage copy is a draft for review. Existing campus, graduation, technology, and editorial photos remain reference imagery and need replacement before publication. The logo is the supplied JPEG, clipped to a circle in Figma.

`home-before.png` records the reference. `home-after.png` records the branding pass before the final news-heading contrast correction; `news-after.png` records that correction. No application code or database migration has been performed in this phase. Mobile layouts, final content and imagery, and interactive behavior remain to be designed.
