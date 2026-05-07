import { defineCollection } from "astro:content";
import { glob } from "astro/loaders";
import { z } from "astro/zod";

const footerLinkSchema = z.object({ href: z.string(), label: z.string(), external: z.boolean().optional() });

const legalPages = defineCollection({
  loader: glob({ base: "./src/content/legal", pattern: "**/*.md" }),
  schema: z.object({
    slug: z.string(),
    title: z.string(),
    description: z.string(),
    effectiveDate: z.string(),
    lead: z.string(),
    alert: z.string().optional(),
    footerLinks: z.array(footerLinkSchema),
  }),
});

export const collections = { legalPages };
