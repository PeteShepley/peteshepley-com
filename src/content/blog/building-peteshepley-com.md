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

The project is deployed to infrastructure managed by an OpenTofu stack managed
in a separate repository. The infrastructure involved is an AWS CloudFront
distribution backed by a secured S3 bucket. This project deploys to the bucket
using a Github Action.
