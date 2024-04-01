<script setup>
import {onBeforeUnmount, ref} from "vue";
  const fullWidth = ref(document.documentElement.clientWidth - 202)
  const fullHeight = ref(document.documentElement.clientHeight - 65)
  const creatEventListener = () => {
    window.addEventListener('resize', handleResize)
  }
  const handleResize= () => {
    fullWidth.value = document.documentElement.clientWidth - 202
    fullHeight.value = document.documentElement.clientHeight - 65
  }
  onBeforeUnmount(() =>{
    window.removeEventListener('resize', handleResize)
  })
  creatEventListener()

</script>

<template>
  <div>
    <img style="object-fit: cover" src="../../static/image/guangyou1.jpg" :width="fullWidth" :height="fullHeight"  alt="图像加载失败"/>
  </div>
</template>

<style scoped>

</style>