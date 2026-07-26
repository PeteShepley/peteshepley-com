# peteshepley.com

Source for Pete Shepley's personal site: a landing page, a `/projects` page, and a
blog. Built with [Astro](https://astro.build), minimalist theme (system fonts,
no client-side framework, automatic light/dark).

For why things are built this way, and how the deployment infra fits together,
see the build journal in the sibling `operations` repo:
`operations/docs/projects/peteshepley-com/journal.md`.

## Structure

```
src/
  components/       Header, Footer
  layouts/          Layout.astro (base shell), BlogPostLayout.astro
  pages/
    index.astro     landing page
    projects.astro  project list, sourced from src/data/projects.ts
    blog/           post index + [...slug] post route
    api-docs/       API documentation index, sourced from src/data/apis.json
    rss.xml.ts      RSS feed
    404.astro       matches CloudFront's custom_error_response -> /404.html
  content/blog/     blog posts (markdown)
  content.config.ts blog collection schema
  data/projects.ts  project entries shown on /projects
  data/apis.json    API registry shown on /api-docs
  styles/global.css theme (CSS custom properties, light/dark)
scripts/
  fetch-openapi-specs.mjs  pulls each API's OpenAPI spec + renders static
                            Redoc HTML into public/api-docs/ (runs before
                            dev/build — see package.json pre* scripts)
```

## Commands

| Command           | Action                               |
|:------------------|:-------------------------------------|
| `npm install`     | Install dependencies                 |
| `npm run dev`     | Start dev server at `localhost:4321` |
| `npm run build`   | Build production site to `./dist/`   |
| `npm run preview` | Preview the production build locally |
| `npm run check`   | Type-check (`astro check`)           |

## Adding a blog post

Create a Markdown file in `src/content/blog/`:

```md
---
title: Post Title
description: One-sentence summary
pubDate: 2026-07-10
tags: ["tag1", "tag2"]
---

Body in Markdown.
```

Set `draft: true` in the frontmatter to keep a post out of the index, RSS
feed, and homepage until it's ready.

## Adding a project link

Add an entry to the `projects` array in `src/data/projects.ts`.

## Publishing API documentation

`/api-docs` lists every API registered in `src/data/apis.json`. Each entry
points at the API's own repo as the source of truth for its OpenAPI spec
(`specSourceUrl`, a raw GitHub URL on `main`) and, for local development,
a sibling checkout path (`localSourcePath`) so docs stay in sync without a
network round trip while working in this workspace.

To add a new API:

1. Publish an `openapi/<name>.yaml` in that API's own repo.
2. Add an entry to `src/data/apis.json`.
3. `npm run docs:build` (or just `dev`/`build`, which run it automatically)
   fetches the spec into `public/api-docs/<id>.yaml` and renders
   `public/api-docs/<id>.html` with [Redocly](https://redocly.com/redoc).

Neither generated file is committed — `public/api-docs/` is gitignored and
rebuilt on every `dev`/`build`/deploy.

## Deployment

Deploys via GitHub Actions on every push to `main` (`.github/workflows/deploy.yml`):
build the site, sync `dist/` to the `peteshepley-com-site` S3 bucket, invalidate
CloudFront. Authentication is via GitHub OIDC (no stored AWS credentials) —
the role and bucket are provisioned in [`infrastructure/`](infrastructure/),
this repo's own OpenTofu stack. The account-wide OIDC provider it trusts is
owned centrally in `operations/infra/005-github-oidc`, looked up via data
source rather than created here. Pull requests run `.github/workflows/ci.yml`
(type-check + build) without touching any deployment credentials.

Required repo configuration (see `operations/docs/runbooks/static-site-deployment.md`
for how to get these values):

| Name                         | Kind             | Value                                                       |
|:-----------------------------|:-----------------|:---------------------------------------------------------------|
| `AWS_ROLE_ARN`               | Actions secret   | `tofu output github_deploy_role_arn` in `infrastructure/`     |
| `CLOUDFRONT_DISTRIBUTION_ID` | Actions variable | `tofu output cloudfront_distribution_id` in `infrastructure/` |

The site is reachable at the CloudFront default domain
(`tofu output cloudfront_domain_name`) until the `operations/infra/003-root-dns`
stack exists and a custom domain is attached.
