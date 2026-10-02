export type ProjectKind = 'code' | 'homelab' | 'paper';

export interface Project {
  name: string;
  kind: ProjectKind;
  description: string;
  url: string;
  tags: string[];
  /** How a visitor can look at the work: what to open, what to try. */
  howToExamine?: string;
}

export const projectKinds: { kind: ProjectKind; label: string }[] = [
  { kind: 'code', label: 'Code' },
  { kind: 'homelab', label: 'Home lab' },
  { kind: 'paper', label: 'Papers' },
];

export const projects: Project[] = [
  {
    name: 'peteshepley.com',
    kind: 'code',
    description: 'This site — an Astro-based personal presence and blog, deployed to AWS via OpenTofu and GitHub Actions.',
    url: 'https://github.com/PeteShepley/peteshepley-com',
    tags: ['astro', 'aws', 'opentofu'],
  },
  {
    name: 'Resume API',
    kind: 'code',
    description: 'An API for resume-shaped data — profile, work experience, education, skills, certifications, hobbies, and goals — served back as JSON or Markdown. Python on AWS Lambda, DynamoDB, and API Gateway, authenticated with Clerk.',
    url: 'https://peteshepley.com/api-docs/resume-api.html',
    tags: ['python', 'aws-lambda', 'dynamodb'],
    howToExamine: 'Read the OpenAPI docs, or sign in to the Resume App to use it with your own data.',
  },
  {
    name: 'Resume App',
    kind: 'code',
    description: 'A signed-in editor for resume-api data — view your assembled resume and edit every section: profile, experience, education, skills, certifications, hobbies, and goals. React, TypeScript, and Vite, authenticated with Clerk.',
    url: 'https://app.peteshepley.com/resume/',
    tags: ['react', 'typescript', 'clerk'],
    howToExamine: 'Sign in and build out your own resume.',
  },
  {
    name: 'Gin Rummy',
    kind: 'code',
    description: 'A two-player card game in the browser — PixiJS table, a deterministic game engine, and a small WebSocket relay so two people can play from anywhere.',
    url: 'https://game.peteshepley.com/gin-rummy/',
    tags: ['typescript', 'pixijs', 'websockets'],
    howToExamine: 'Create a room and send the code to a friend, or play both seats in one browser.',
  },
  {
    name: 'Crazy Eights',
    kind: 'code',
    description: 'Crazy Eights for two to six players, built on a shared card kit and the same WebSocket relay as Gin Rummy — the relay sequences moves for any game without knowing its rules.',
    url: 'https://game.peteshepley.com/crazy-eights/',
    tags: ['typescript', 'react', 'websockets'],
    howToExamine: 'Create a room, share the code with up to five friends, and start once everyone is in.',
  },
  {
    name: 'Hearts',
    kind: 'code',
    description: 'Four-player Hearts on the same card kit and relay: passing, follow-suit trick play, moon shots and games to 100, all driven by a pure engine that every client replays from the same seed.',
    url: 'https://game.peteshepley.com/hearts/',
    tags: ['typescript', 'react', 'websockets'],
    howToExamine: 'Create a room and share the code with three friends; the game starts when the fourth joins.',
  },
  {
    name: 'API Console',
    kind: 'code',
    description: "A signed-in API test console for peteshepley.com's APIs — pick an API from the dropdown, browse its OpenAPI documentation, and try live requests against your own data. React, TypeScript, and Vite, authenticated with Clerk.",
    url: 'https://github.com/PeteShepley/api-console',
    tags: ['react', 'typescript', 'swagger-ui'],
  },
];
