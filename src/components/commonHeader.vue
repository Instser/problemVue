<script setup>


import {useRoute} from "vue-router";
import {ref, watch} from "vue";
// eslint-disable-next-line no-unused-vars
const props = defineProps({
  name: String
})
const route = useRoute()
const isVisible = ref(false)
const buttonText = ref('')
const buttonPath = ref('')
watch(() => route.name, (newName) => {
  switch (newName) {
    case '首页':
      isVisible.value = false;
      break;
    case '课程管理':
      isVisible.value = true;
      buttonText.value = '添加课程';
      buttonPath.value = '/edit';
      break;
    case '试题管理':
      isVisible.value = true;
      buttonText.value = '添加试题';
      buttonPath.value = '/edit';
      break
    case '文件夹':
      isVisible.value = true;
      buttonText.value = '新建文件夹';
      buttonPath.value = '/edit';
      break
    case '个人中心':
      isVisible.value = false;
  }
})
</script>

<template>
  <div class="header-container">
    <div class="l-content">
      <span class="tittle">{{ name }}</span>
    </div>
    <div class="r-content">
      <router-link :to="buttonPath">
        <el-button type="primary" icon="Plus" v-if="isVisible" >{{ buttonText }}</el-button>
      </router-link>
    </div>
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