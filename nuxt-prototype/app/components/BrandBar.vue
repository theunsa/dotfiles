<script setup lang="ts">
const { dossier } = useAppConfig()
</script>

<template>
  <header
    class="sticky top-0 z-40 border-b border-default bg-default/85 backdrop-blur"
  >
    <div class="mx-auto flex h-14 max-w-3xl items-center gap-3 px-5">
      <span
        class="size-2.5 shrink-0 rounded-full bg-primary"
        aria-hidden="true"
      />
      <span class="truncate text-sm font-semibold tracking-tight text-highlighted">
        {{ dossier.name }}
      </span>
      <UColorModeButton class="ml-auto" size="sm" />
    </div>
  </header>
</template>
