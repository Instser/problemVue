<script setup>

import CommonAside from "@/components/commonAside.vue";
import CommonHeader from "@/components/commonHeader.vue";
</script>

<template>
  <div>
    <el-container>
      <el-aside width="200px">
        <common-aside />
      </el-aside>
      <el-container>
        <el-header>
          <common-header :name="$route.name"/>
        </el-header>
        <el-main>
          <router-view></router-view>
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<style scoped>
.el-header {
  padding: 0;
}
.el-main {
  padding: 0;
}
</style>