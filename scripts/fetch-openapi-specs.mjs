#!/usr/bin/env node
/**
 * Pulls each API's OpenAPI spec into public/api-docs/ and renders a static
 * Redoc HTML page for it, so `astro build`/`astro dev` can serve both as
 * plain static assets — no client framework needed on this site to show
 * interactive-looking API docs.
 *
 * Each API's own repo is the source of truth for its spec (e.g.
 * resume-api/openapi/resume-api.yaml). When that repo is checked out as a
 * sibling directory (the normal layout under github.com/PeteShepley/),
 * this reads the local copy so docs stay in sync during same-workspace
 * development. Otherwise (CI, where only this repo is checked out) it
 * fetches the spec from the source repo's raw GitHub URL on `main`.
 */
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';

const rootDir = dirname(dirname(fileURLToPath(import.meta.url)));
const apis = JSON.parse(readFileSync(join(rootDir, 'src/data/apis.json'), 'utf8'));
const outDir = join(rootDir, 'public/api-docs');
mkdirSync(outDir, { recursive: true });

for (const api of apis) {
  const localPath = join(rootDir, api.localSourcePath);
  let specText;

  if (existsSync(localPath)) {
    console.log(`[${api.id}] reading local sibling repo: ${api.localSourcePath}`);
    specText = readFileSync(localPath, 'utf8');
  } else {
    console.log(`[${api.id}] fetching ${api.specSourceUrl}`);
    const response = await fetch(api.specSourceUrl);
    if (!response.ok) {
      throw new Error(`[${api.id}] failed to fetch spec: ${response.status} ${response.statusText}`);
    }
    specText = await response.text();
  }

  const specPath = join(outDir, `${api.id}.yaml`);
  writeFileSync(specPath, specText);

  const htmlPath = join(outDir, `${api.id}.html`);
  execFileSync(
    join(rootDir, 'node_modules/.bin/redocly'),
    ['build-docs', specPath, '-o', htmlPath, '--title', `${api.name} — peteshepley.com`],
    { stdio: 'inherit' },
  );
}
