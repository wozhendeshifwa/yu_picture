<script setup lang="ts">
import HealthBadge from "@/components/HealthBadge.vue";
</script>

<template>
  <a-card title="骨架已就绪" class="home">
    <a-space direction="vertical" size="middle">
      <a-typography-paragraph>
        前端脚手架已跑通：Vue 3 + TypeScript + Vue Router + Pinia + Ant Design Vue。
        下一轮再往里填业务（登录、上传、图片管理）。
      </a-typography-paragraph>
      <HealthBadge />
    </a-space>
  </a-card>
</template>

<style scoped>
.home {
  max-width: 720px;
}
</style>
