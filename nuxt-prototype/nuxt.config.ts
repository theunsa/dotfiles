import { existsSync, readdirSync } from 'node:fs'
import { fileURLToPath } from 'node:url'

// Client pages live under unguessable slugs and are deliberately linked from
// nowhere, so the prerender crawler can never find them. Enumerate them here.
const clientContentDir = fileURLToPath(new URL('./content/d', import.meta.url))
const clientRoutes = existsSync(clientContentDir)
  ? readdirSync(clientContentDir, { withFileTypes: true })
      .filter(entry => entry.isDirectory())
      .map(entry => `/d/${entry.name}`)
  : []

export default defineNuxtConfig({
  modules: ['@nuxt/content', '@nuxt/ui'],
  css: ['~/assets/css/main.css'],
  compatibilityDate: '2026-08-29',

  devtools: { enabled: true },

  // Nuxt UI ships its own ProseCallout/ProseSteps, which would otherwise win
  // the `::callout` / `::steps` tags. Map the three authoring tags explicitly
  // at our own components so the markdown API stays `::steps`, `::callout`,
  // `::faq` regardless of what the UI library registers.
  mdc: {
    components: {
      map: {
        steps: 'DossierSteps',
        callout: 'DossierCallout',
        faq: 'DossierFaq'
      }
    }
  },

  nitro: {
    preset: 'static',
    prerender: {
      crawlLinks: true,
      routes: ['/', '/404.html', ...clientRoutes]
    }
  },

  runtimeConfig: {
    public: {
      siteUrl: process.env.NUXT_PUBLIC_SITE_URL || 'https://example.com'
    }
  }
})
