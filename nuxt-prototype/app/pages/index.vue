<script setup lang="ts">
const { dossier } = useAppConfig()

useSeoMeta({
  title: dossier.name,
  description: dossier.tagline
})
</script>

<template>
  <main class="flex min-h-dvh flex-col items-center justify-center bg-default px-6">
    <div class="w-full max-w-md text-center">
      <span class="mx-auto mb-6 block size-3 rounded-full bg-primary" />

      <h1 class="text-3xl font-bold tracking-tight text-highlighted sm:text-4xl">
        {{ dossier.name }}
      </h1>

      <p class="mt-4 text-lg leading-relaxed text-muted">
        {{ dossier.tagline }}
      </p>

      <UButton
        :to="`mailto:${dossier.email}`"
        color="primary"
        variant="subtle"
        size="lg"
        icon="i-lucide-mail"
        class="mt-8"
      >
        {{ dossier.email }}
      </UButton>
    </div>
  </main>
</template>
