# Public Assets Directory

This directory contains static assets that are served directly by Next.js.

## Usage

Place your static files here:
- `favicon.ico` - Website favicon
- `robots.txt` - Search engine crawler instructions
- `sitemap.xml` - Site structure for SEO
- Images, fonts, and other static assets

## Example

```
public/
├── favicon.ico
├── logo.png
├── robots.txt
└── images/
    └── hero.jpg
```

Files in this directory are served from the root path `/`.

For example, `public/logo.png` is accessible at `/logo.png`.
