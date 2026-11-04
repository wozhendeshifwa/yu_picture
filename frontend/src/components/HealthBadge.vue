<script setup lang="ts">
import { onMounted, ref } from "vue";

import { fetchHealth } from "@/api/health";

type Status = "loading" | "ok" | "down";

const status = ref<Status>("loading");
const detail = ref("");

onMounted(async () => {
  try {
    const health = await fetchHealth();
    status.value = health.status === "ok" ? "ok" : "down";
    detail.value = `/api/health → ${health.status}`;
  } catch (error) {
    status.value = "down";
    detail.value = error instanceof Error ? error.message : String(error);
  }
});
</script>

<template>
  <a-space align="center" wrap>
    <span>后端连通性</span>
    <a-tag v-if="status === 'loading'" color="blue">检测中</a-tag>
    <a-tag v-else-if="status === 'ok'" color="green">已连通</a-tag>
    <a-tag v-else color="red">未连通</a-tag>
    <a-typography-text type="secondary">{{ detail }}</a-typography-text>
  </a-space>
</template>
