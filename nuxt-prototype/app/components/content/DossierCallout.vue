<script setup lang="ts">
defineProps<{
  title?: string
  icon?: string
  color?: 'primary' | 'neutral' | 'info' | 'success' | 'warning' | 'error'
}>()
</script>

<template>
  <UAlert
    :title="title"
    :icon="icon || 'i-lucide-shield-check'"
    :color="color || 'primary'"
    variant="subtle"
    class="not-prose my-8"
    :ui="{
      title: 'text-base font-semibold',
      description: 'text-base leading-relaxed text-default'
    }"
  >
    <template #description>
      <slot />
    </template>
  </UAlert>
</template>
