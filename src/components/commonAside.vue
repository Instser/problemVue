<script setup>

import router from "@/router/router";
import {ref} from "vue";

const menuData = ref([
])
const addLabel = () => {
  const tableData = ref(router.getRoutes().filter((item) => item.meta.label).map((item) => item))
  for (let i = 0; i < tableData.value.length; i++) {
    menuData.value[i] = tableData.value[i].meta
  }
}
addLabel()
</script>

<template>
  <el-row class="tac">
    <el-col :span="24">
      <el-menu
          default-active="1"
          class="el-menu-vertical-demo"
          background-color="#545c64"
          text-color="#fff"
          active-text-color="#ffd04b"
          router
      >
        <h3>试题管理系统</h3>
        <el-menu-item v-for="item in menuData" :key="item.label" :index="item.path">
          <el-icon>
            <component :is="item.icon"></component>
          </el-icon>
          <span>{{ item.label }}</span>
        </el-menu-item>
      </el-menu>
    </el-col>
  </el-row>
</template>

<style lang="less" scoped>
.el-menu-vertical-demo:not(.el-menu--collapse) {
  border-right: none;
  width: 200px;
  min-height: 400px;
}
.el-menu {
  height: 100vh;
  h3 {
    color: #fff;
    text-align: center;
    line-height: 48px;
  }
}
</style>