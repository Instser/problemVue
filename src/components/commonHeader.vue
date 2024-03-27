<script setup>

// eslint-disable-next-line no-unused-vars
  const props = defineProps({
    name: String
  })
</script>

<template>
  <div class="header-container">
    <div class="l-content">
      <span class="tittle">{{ name }}</span>
    </div>
    <div class="r-content"></div>
  </div>
</template>

<style lang="less" scoped>
.header-container {
  padding: 0 20px;
  background-color: #333;
  height: 60px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  .tittle {
    color: #ffffff;
  }
}
</style>