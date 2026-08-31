<script setup lang="ts">
interface Step {
  title: string
  price?: string
  body?: string
  note?: string
}

defineProps<{ items?: Step[] }>()
</script>

<template>
  <div class="not-prose my-8 flex flex-col gap-4">
    <UCard
      v-for="(step, index) in items"
      :key="index"
      variant="outline"
      :ui="{ body: 'p-5 sm:p-6' }"
      class="border-l-4 border-l-primary"
    >
      <div class="flex items-baseline gap-3">
        <span
          class="flex size-7 shrink-0 items-center justify-center rounded-full bg-primary/10 text-sm font-semibold text-primary"
        >
          {{ index + 1 }}
        </span>
        <h3 class="text-lg font-semibold tracking-tight text-highlighted">
          {{ step.title }}
        </h3>
      </div>

      <p
        v-if="step.price"
        class="mt-3 text-2xl font-bold tracking-tight text-primary"
      >
        {{ step.price }}
      </p>

      <p v-if="step.body" class="mt-3 text-base leading-relaxed text-default">
        {{ step.body }}
      </p>

      <p v-if="step.note" class="mt-3 text-sm font-medium text-muted">
        {{ step.note }}
      </p>
    </UCard>
  </div>
</template>
