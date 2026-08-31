<script setup lang="ts">
const props = defineProps<{
  number: string
  text?: string
  label?: string
  block?: boolean
  size?: 'md' | 'lg' | 'xl'
}>()

const href = computed(() => whatsappLink(props.number, props.text))
</script>

<template>
  <UButton
    :to="href"
    target="_blank"
    rel="noopener"
    color="primary"
    icon="i-lucide-message-circle"
    :size="size || 'xl'"
    :block="block"
    class="font-semibold"
  >
    {{ label || 'WhatsApp me' }}
  </UButton>
</template>
