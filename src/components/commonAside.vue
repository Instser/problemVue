<script setup>
import router from "@/router/router";
import { ref, computed, onMounted, watch } from "vue";
import { useRoute } from 'vue-router';

const emit = defineEmits(['collapse-change']);
const route = useRoute();
const menuData = ref([]);
const isCollapse = ref(false);
const activeMenu = computed(() => route.path);

const addLabel = () => {
  const tableData = ref(router.getRoutes().filter((item) => item.meta?.label).map((item) => item));
  for (let i = 0; i < tableData.value.length; i++) {
    menuData.value[i] = tableData.value[i].meta;
  }
};

const toggleCollapse = () => {
  isCollapse.value = !isCollapse.value;
  emit('collapse-change', isCollapse.value);
};

watch(isCollapse, (newVal) => {
  emit('collapse-change', newVal);
});

onMounted(() => {
  addLabel();
});
</script>

<template>
  <div class="sidebar-container">
    <div class="logo-container">
      <div class="logo-content">
        <el-icon class="logo-icon"><Document /></el-icon>
        <h3 v-if="!isCollapse">试题管理系统</h3>
      </div>
      <el-icon class="collapse-icon" @click="toggleCollapse">
        <component :is="isCollapse ? 'Expand' : 'Fold'"></component>
      </el-icon>
    </div>

    <el-scrollbar>
      <el-menu
        :default-active="activeMenu"
        class="el-menu-vertical"
        :collapse="isCollapse"
        background-color="var(--sidebar-bg)"
        text-color="#fff"
        active-text-color="#409EFF"
        :collapse-transition="true"
        router
      >
        <el-menu-item v-for="item in menuData" :key="item.label" :index="item.path">
          <el-icon>
            <component :is="item.icon"></component>
          </el-icon>
          <template #title>
            <span>{{ item.label }}</span>
          </template>
        </el-menu-item>
      </el-menu>
    </el-scrollbar>

    <div class="sidebar-footer">
      <el-tooltip content="帮助文档" placement="right" :disabled="!isCollapse">
        <el-button class="footer-item" text>
          <el-icon><QuestionFilled /></el-icon>
          <span v-if="!isCollapse">帮助文档</span>
        </el-button>
      </el-tooltip>
    </div>
  </div>
</template>

<style lang="less" scoped>
.sidebar-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background-color: var(--sidebar-bg);
  transition: width 0.3s;
  overflow: hidden;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);
  position: relative;
  z-index: 10;

  .logo-container {
    height: 60px;
    padding: 0 16px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    overflow: hidden;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);

    .logo-content {
      display: flex;
      align-items: center;

      .logo-icon {
        font-size: 20px;
        color: #fff;
        margin-right: 12px;
      }

      h3 {
        color: #fff;
        margin: 0;
        font-size: 18px;
        font-weight: 600;
        white-space: nowrap;
        overflow: hidden;
      }
    }

    .collapse-icon {
      color: #fff;
      font-size: 18px;
      cursor: pointer;
      transition: all 0.3s;

      &:hover {
        color: var(--primary-color);
      }
    }
  }

  .el-scrollbar {
    flex: 1;
    overflow-x: hidden;
  }

  .el-menu {
    border-right: none;

    &.el-menu-vertical:not(.el-menu--collapse) {
      width: 200px;
    }
  }

  .el-menu-item {
    &.is-active {
      background-color: rgba(64, 158, 255, 0.1) !important;
      border-right: 3px solid var(--primary-color);

      &::before {
        content: '';
        position: absolute;
        left: 0;
        top: 0;
        width: 3px;
        height: 100%;
        background-color: var(--primary-color);
      }
    }

    &:hover {
      background-color: rgba(255, 255, 255, 0.05) !important;
    }
  }

  .sidebar-footer {
    padding: 12px;
    border-top: 1px solid rgba(255, 255, 255, 0.1);

    .footer-item {
      width: 100%;
      color: #fff;
      display: flex;
      align-items: center;
      padding: 8px 16px;
      transition: all 0.3s;

      .el-icon {
        margin-right: 8px;
      }

      &:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }
    }
  }
}
</style>