export interface Project {
  name: string;
  description: string;
  url: string;
  tags: string[];
}

// Placeholders — replace with real projects.
export const projects: Project[] = [
  {
    name: 'On-prem edge Kubernetes cluster',
    description: 'A self-hosted, auto-extending Kubernetes cluster built on home hardware, documented as it goes.',
    url: 'https://peteshepley.com/blog',
    tags: ['kubernetes', 'homelab', 'infrastructure'],
  },
  {
    name: 'peteshepley.com',
    description: 'This site — an Astro-based personal presence and blog, deployed to AWS via OpenTofu and GitHub Actions.',
    url: 'https://github.com/PeteShepley/peteshepley-com',
    tags: ['astro', 'aws', 'opentofu'],
  },
  {
    name: 'Resume API',
    description: 'An API for resume-shaped data — profile, work experience, education, skills, certifications, hobbies, and goals — served back as JSON or Markdown. Python on AWS Lambda, DynamoDB, and API Gateway, authenticated with Clerk.',
    url: 'https://peteshepley.com/api-docs/resume-api.html',
    tags: ['python', 'aws-lambda', 'dynamodb'],
  },
  {
    name: 'Resume App',
    description: 'A signed-in editor for resume-api data — view your assembled resume and edit every section: profile, experience, education, skills, certifications, hobbies, and goals. React, TypeScript, and Vite, authenticated with Clerk.',
    url: 'https://resume.peteshepley.com',
    tags: ['react', 'typescript', 'clerk'],
  },
  {
    name: 'API Console',
    description: "A signed-in API test console for peteshepley.com's APIs — pick an API from the dropdown, browse its OpenAPI documentation, and try live requests against your own data. React, TypeScript, and Vite, authenticated with Clerk.",
    url: 'https://test.peteshepley.com',
    tags: ['react', 'typescript', 'swagger-ui'],
  },
  {
    name: 'Ledger API',
    description: 'A double-entry bookkeeping API — accounts, transactions, and the immutable entries that belong to them, with derived balances and idempotent posting. TypeScript on AWS Lambda, Aurora Serverless v2 (Postgres) via the RDS Data API, IAM-authenticated API Gateway.',
    url: 'https://peteshepley.com/api-docs/ledger-api.html',
    tags: ['typescript', 'aws-lambda', 'postgres'],
  },
  {
    name: 'Books API',
    description: 'A shared, Clerk-Organization-backed financial ledger ("Book") — typed expense/income/transfer transactions over a chart of accounts, with ledger-api as the double-entry backend. Go on AWS Lambda, DynamoDB, and API Gateway, authenticated with Clerk (organization claims).',
    url: 'https://peteshepley.com/api-docs/books-api.html',
    tags: ['go', 'aws-lambda', 'dynamodb'],
  },
];
