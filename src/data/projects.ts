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
];
