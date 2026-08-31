<script setup lang="ts">
interface FaqItem {
  label: string
  content: string
}

defineProps<{ items?: FaqItem[] }>()
</script>

<template>
  <UAccordion
    :items="items"
    class="not-prose my-8"
    :ui="{
      trigger: 'py-4 text-base font-medium text-highlighted',
      body: 'text-base leading-relaxed text-muted pb-4'
    }"
  />
</template>
