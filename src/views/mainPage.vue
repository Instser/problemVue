<script setup>
import { ref, computed } from 'vue'; // 移除未使用的 watch
import { useRoute } from 'vue-router';
import CommonAside from "@/components/commonAside.vue";
import CommonHeader from "@/components/commonHeader.vue";

const route = useRoute();
const asideWidth = ref('200px');
const isCollapsed = ref(false);

const toggleAside = (collapsed) => {
  isCollapsed.value = collapsed;
  asideWidth.value = collapsed ? '64px' : '200px';
};

const routeName = computed(() => route.name);
</script>

<template>
  <div class="main-container">
    <el-container class="app-wrapper">
      <el-aside :width="asideWidth" class="sidebar-container">
        <common-aside @collapse-change="toggleAside" />
      </el-aside>
      <el-container class="main-content">
        <el-header height="60px" class="app-header">
          <common-header :name="routeName" />
        </el-header>
        <el-main class="app-main">
          <router-view v-slot="{ Component }">
            <transition name="fade" mode="out-in">
              <keep-alive>
                <component :is="Component" :key="$route.fullPath" />
              </keep-alive>
            </transition>
          </router-view>
        </el-main>
        <el-footer height="40px" class="app-footer">
          <div class="footer-content">
            <span>试题管理系统 &copy; {{ new Date().getFullYear() }}</span>
          </div>
        </el-footer>
      </el-container>
    </el-container>
  </div>
</template>

<style lang="less" scoped>
.main-container {
  height: 100vh;
  width: 100%;
  overflow: hidden;
}

.app-wrapper {
  height: 100%;
  width: 100%;
}

.sidebar-container {
  transition: width 0.3s;
  overflow: hidden;
  height: 100%;
}

.main-content {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}

.app-header {
  padding: 0;
  position: relative;
  z-index: 9;
}

.app-main {
  padding: 16px;
  flex: 1;
  overflow-y: auto;
  background-color: var(--background-color);
  position: relative;
}

.app-footer {
  padding: 0;
  background-color: #fff;
  border-top: 1px solid var(--border-light);

  .footer-content {
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--text-secondary);
    font-size: 12px;
  }
}

/* 过渡动画 */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>