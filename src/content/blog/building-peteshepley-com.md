---
title: Building peteshepley.com
description: Notes on the stack, the deployment path, and the decisions behind this site.
pubDate: 2026-07-10
tags: ["astro", "aws", "opentofu", "meta"]
---

This site is the first real thing running on top of a small technology-operations
setup I've been putting together — tracked separately in a private `operations`
repo alongside this one. Writing down the decisions here, partly so I remember
why I made them.

## Why Astro

I wanted a personal site and blog that ships plain HTML/CSS with no client-side
framework tax, has first-class markdown content collections, and gets out of
the way. Astro fits that directly — static output by default, islands only if
I actually need interactivity later, and a content layer that gives me typed
frontmatter for blog posts without reaching for a CMS.

## Why plain CSS, no Tailwind

The goal was a minimalist theme: system fonts, a single accent color, generous
whitespace, automatic light/dark via `prefers-color-scheme`, no card chrome or
gradients. That's a small enough surface that a utility framework would add
more indirection than it saves — one `global.css` with a handful of custom
properties does the job.

## Deployment

The site deploys to infrastructure already defined in `operations/infra/002-static-site`:
an S3 bucket behind CloudFront, with a GitHub Actions OIDC role so no long-lived
AWS credentials are stored anywhere. Push to `main`, GitHub Actions builds the
site, syncs `dist/` to S3, and invalidates the CloudFront cache.

One gap surfaced while wiring this up: CloudFront was serving the S3 bucket
directly through Origin Access Control (not S3 website-hosting mode), which
means only the literal root path resolves `index.html` automatically. Astro's
default per-page output is a directory with an `index.html` inside it — so
`/blog/building-peteshepley-com/` had no matching object key. The fix is a
small CloudFront Function that rewrites extensionless request paths to their
`index.html` before they hit the origin — the standard pattern for static
sites behind CloudFront+OAC.

## What's next

- A real custom domain (the `dns` stack in `operations` doesn't exist yet —
  until then this is reachable on the CloudFront default domain)
- More projects on the `/projects` page as they're worth linking
- Whatever I end up building next
