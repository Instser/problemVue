<script setup>

const menuData = [
  {
    path: '/home',
    name: 'home',
    label: '首页',
    icon: 'view',
    url: 'Home/Home'
  },
  {
    path: '/course',
    name: 'course',
    label: '课程管理',
    icon: 'reading',
    url: 'Course/Course'
  },
  {
    path: '/questions',
    name: 'questions',
    label: '试题管理',
    icon: 'document-copy',
    url: 'Questions/Questions'
  },
  {
    path: '/folder',
    name: 'folder',
    label: '文件夹',
    icon: 'FolderOpened',
    url: 'Questions/Questions'
  },
  {
    path: '/central',
    name: 'central',
    label: '个人中心',
    icon: 'user',
    url: 'Central/Central'
  }
]
</script>

<template>
  <el-row class="tac">
    <el-col :span="24">
      <el-menu
          default-active="2"
          class="el-menu-vertical-demo"
          background-color="#545c64"
          text-color="#fff"
          active-text-color="#ffd04b"
          router :default-openeds="['0', '1']"
      >
        <h3>试题管理系统</h3>
        <el-menu-item v-for="item in menuData" :key="item.name" :index="item.path">
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