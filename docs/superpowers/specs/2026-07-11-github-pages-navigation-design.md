# GitHub Pages Navigation Design

## Goal

Make navigation among the home page and the three programme pages work when the site is published from a GitHub Pages project repository.

## Scope

- Change only internal links that open another local HTML file.
- Preserve same-page anchors, email, telephone, and external form/social links.
- Do not alter page structure, styles, content, or file names.

## Navigation Rules

- Home page links to programme pages use relative filenames, prefixed with `./` for clarity.
- Each programme page logo link returns to `./index.html`.
- No internal page link begins with `/`, because a leading slash resolves from the domain root and omits the GitHub Pages repository segment.

## Files

- `index.html`: programme links in the header, solution cards, and footer.
- `Khai_Van_Hieu_Suat_Thuc_Chien.dc.html`: logo return link.
- `Khai_Van_Quan_Tri_Chuyen_Nghiep.dc.html`: logo return link.
- `Chuyen_Gia_Khai_Van_Hieu_Suat_Cao.dc.html`: logo return link.

## Verification

Inspect every local HTML link and confirm that its target file exists. Confirm no `href` that targets a local HTML page starts with `/`.
