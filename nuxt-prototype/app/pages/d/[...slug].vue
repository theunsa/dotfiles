<script setup lang="ts">
const route = useRoute()
const { dossier } = useAppConfig()

// Static hosts vary on trailing slashes. Normalise before both the cache key
// and the lookup, or a visit to `/d/slug/` misses the prerendered payload and
// re-queries on the client against a path that doesn't exist.
const path = computed(() => route.path.replace(/\/+$/, '') || '/')

const { data: page } = await useAsyncData(`dossier-${path.value}`, () =>
  queryCollection('dossiers').where('path', '=', path.value).first())

if (!page.value) {
  throw createError({
    statusCode: 404,
    statusMessage: 'Dossier not found',
    fatal: true
  })
}

const ctaText = computed(() => page.value?.whatsappText || DEFAULT_WHATSAPP_TEXT)
const ctaLabel = computed(() => page.value?.whatsappLabel || 'WhatsApp me')

// Unguessable-slug security model: never let these pages into an index.
useSeoMeta({
  title: () => page.value?.title,
  description: () => page.value?.description,
  robots: 'noindex, nofollow, noarchive, noimageindex'
})
</script>

<template>
  <div v-if="page" class="min-h-dvh bg-default">
    <BrandBar />

    <main class="mx-auto max-w-3xl px-5 pt-10 pb-40 sm:pb-24">
      <header class="mb-10">
        <p class="text-sm font-medium text-muted">
          Prepared for {{ page.client }} — {{ page.date }}
        </p>
        <h1
          class="mt-2 text-3xl leading-tight font-bold tracking-tight text-highlighted sm:text-4xl"
        >
          {{ page.title }}
        </h1>
        <div class="mt-6 h-px w-16 bg-primary" />
      </header>

      <!-- Nuxt UI's Prose components style the rendered markdown; the
           dossier-prose class only widens the reading size for phones. -->
      <ContentRenderer :value="page" class="dossier-prose" />

      <section
        class="mt-14 rounded-xl border border-default bg-elevated p-6 text-center"
      >
        <h2 class="text-xl font-semibold tracking-tight text-highlighted">
          Ready for Step 1?
        </h2>
        <p class="mx-auto mt-2 max-w-sm text-base text-muted">
          One message is enough — no forms, no logins.
        </p>
        <WhatsAppCta
          :number="page.whatsapp"
          :text="ctaText"
          :label="ctaLabel"
          class="mt-6"
          size="xl"
        />
      </section>

      <footer class="mt-12 text-center text-sm text-muted">
        {{ dossier.name }} — {{ dossier.email }}
      </footer>
    </main>

    <!-- Phone-first: the CTA is always one thumb-reach away. -->
    <div
      class="fixed inset-x-0 bottom-0 z-40 border-t border-default bg-default/90 p-4 pb-[calc(1rem+env(safe-area-inset-bottom))] backdrop-blur sm:hidden"
    >
      <WhatsAppCta
        :number="page.whatsapp"
        :text="ctaText"
        :label="ctaLabel"
        size="lg"
        block
      />
    </div>
  </div>
</template>
