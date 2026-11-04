<template>
  <a-layout class="layout">
    <a-layout-header class="layout__header">
      <span class="layout__brand">云图库</span>
      <span class="layout__slug">yu_picture</span>
    </a-layout-header>
    <a-layout-content class="layout__content">
      <router-view />
    </a-layout-content>
  </a-layout>
</template>

<style scoped>
.layout {
  min-height: 100vh;
}

.layout__header {
  display: flex;
  align-items: baseline;
  gap: 12px;
}

.layout__brand {
  color: #fff;
  font-size: 20px;
  font-weight: 600;
}

.layout__slug {
  color: rgba(255, 255, 255, 0.65);
  font-size: 14px;
}

.layout__content {
  padding: 24px;
}
</style>
