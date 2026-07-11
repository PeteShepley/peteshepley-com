---
title: Building api-console
description: A signed-in test console for peteshepley.com's APIs — the stack, the auth model, and two CORS bugs that only showed up in production.
pubDate: 2026-07-11
tags: ["react", "typescript", "clerk", "aws"]
---

[api-console](https://test.peteshepley.com) is a signed-in test console for the
APIs behind this site: pick an API from a dropdown, read its OpenAPI
documentation, and hit "Try it out" to send a real request against the live
API as yourself, via Clerk. Because resume-api's routes are all scoped to the
caller's own identity, this isn't just a docs viewer — signing in and calling
`GET /me/resume` returns your own data from the live service.

## Stack: matching peteshepley.com's tooling, not resume-api's

TypeScript, React, and Vite — the same build tooling this site uses, not the
Python resume-api ended up on. There's no "portfolio diversity" argument here
the way there was for resume-api's language choice: this is a client-heavy,
auth-gated single-page app, exactly the shape Vite + React is built for.

Docs rendering uses Swagger UI rather than Redoc (which this site's own
`/api-docs` page uses for static, prerendered documentation). Redoc doesn't
support interactive request execution; Swagger UI does, plus a
`requestInterceptor` hook for attaching a bearer token. Two different tools
for two different jobs.

## Testing a peer-dependency warning instead of trusting it

`swagger-ui-react`'s `package.json` declares a peer dependency on React
16–18, not the React 19 Vite scaffolds by default. Rather than downgrade
React or switch libraries preemptively, I installed it anyway and actually
checked: `npm install` succeeds with an ERESOLVE warning, not an error, and a
browser smoke test confirmed every operation renders and expands correctly,
with the only console output being a benign deprecation warning from a
component `swagger-ui-react` uses internally. Kept it — the fallback if a
future upgrade breaks this is `@scalar/api-reference-react`, built for
modern React but without the interactive "Try it out" panel.

## A fresh Clerk token on every request

Swagger UI's `requestInterceptor` accepts a function that can return a
`Promise`, so instead of fetching a Clerk token once on mount, every "Try it
out" click calls `getToken({ template })` fresh right before sending. Clerk
session tokens are short-lived; a tab left open long enough would otherwise
attach a stale token and produce a confusing 401 instead of a fresh, valid
one.

## Two CORS bugs, neither visible locally

Both of these only showed up after the first real deploy, because nothing in
local dev exercises an actual cross-origin browser request.

The first: resume-api's original route was a single `ANY /{proxy+}` with a
JWT authorizer attached. `ANY` also matches `OPTIONS` — so CORS preflight
requests, which never carry an `Authorization` header, were hitting the
authorizer and getting 401'd. `curl`ing an `OPTIONS` request and seeing a
`WWW-Authenticate: Bearer` header in the 401 body confirmed the request was
reaching Clerk's authorizer rather than being answered by API Gateway's own
CORS handling. The fix was splitting the single `ANY` route into explicit
per-verb routes (`GET`, `POST`, `PUT`, `DELETE`) so `OPTIONS` matches none of
them, leaving API Gateway's native CORS support to answer preflight directly.

The second, reported as "CORS error testing resume-api while signed in":
`requestInterceptor` was attaching the bearer token to every request,
including the initial spec download from `peteshepley.com/api-docs` — a
different origin than the API itself. Swagger UI threads the same
interceptor through spec-fetching and "Try it out" execution, so an
unconditional `Authorization` header turned an otherwise-simple GET into a
preflighted one against an origin that doesn't handle preflight at all. The
fix was scoping the header to requests whose URL actually starts with the
selected API's base URL. It went unnoticed before shipping because local
testing used a bypassed auth gate, so `getToken()` always returned nothing
and the header was never attached during that pass.

## Deployment

S3 + CloudFront, aliased to `test.peteshepley.com`, reusing the existing
`*.peteshepley.com` wildcard certificate — no new cert needed since it's a
single-label subdomain. GitHub Actions deploys on every push to `main` via
an OIDC role, same pattern the main site uses. CloudFront's error handling
maps 403/404 to `/index.html` with a 200 — the standard SPA fallback — even
though the app is currently one view with nothing to deep-link to yet;
cheap to add now rather than revisit later.

## Adding another API later

The whole registry is one array in `src/apis.ts`: id, name, an OpenAPI spec
URL, and a Clerk JWT template name. Adding a second API to the dropdown
means adding one entry — nothing else in the app changes.
