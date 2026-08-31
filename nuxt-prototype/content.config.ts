import { defineCollection, defineContentConfig } from '@nuxt/content'
import { z } from 'zod'

export default defineContentConfig({
  collections: {
    dossiers: defineCollection({
      type: 'page',
      source: 'd/**/*.md',
      schema: z.object({
        // `title` and `description` come from the page collection itself.
        client: z.string(),
        date: z.string(),
        // E.164, e.g. "+27821234567" — powers the WhatsApp CTA.
        whatsapp: z.string(),
        // Optional override for the CTA prefill and button label.
        whatsappText: z.string().optional(),
        whatsappLabel: z.string().optional()
      })
    })
  }
})
