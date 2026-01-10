<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { storage } from "@/storage/storage";

const props = defineProps({
  name: String
});

// 使用props.name而不是解构，以保持响应性

const router = useRouter();
const currentTime = ref('');
const username = ref('用户');

const updateTime = () => {
  const now = new Date();
  const hours = now.getHours().toString().padStart(2, '0');
  const minutes = now.getMinutes().toString().padStart(2, '0');
  const seconds = now.getSeconds().toString().padStart(2, '0');
  currentTime.value = `${hours}:${minutes}:${seconds}`;
};

const getUserInfo = () => {
  // 这里可以添加获取用户信息的逻辑
  // 暂时使用模拟数据
  username.value = storage.get('username') || '用户';
};

const logout = () => {
  storage.remove('isAuthenticated');
  router.push('/login');
};

onMounted(() => {
  updateTime();
  setInterval(updateTime, 1000);
  getUserInfo();
});
</script>

<template>
  <div class="header-container">
    <div class="l-content">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item :to="{ path: '/home' }">首页</el-breadcrumb-item>
        <el-breadcrumb-item>{{ props.name }}</el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <div class="r-content">
      <div class="time-display">
        <el-icon><Clock /></el-icon>
        <span>{{ currentTime }}</span>
      </div>

      <el-dropdown trigger="click">
        <div class="user-info">
          <el-avatar :size="32" icon="UserFilled" />
          <span>{{ username }}</span>
          <el-icon><ArrowDown /></el-icon>
        </div>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item @click="router.push('/central')">
              <el-icon><User /></el-icon>
              <span>个人中心</span>
            </el-dropdown-item>
            <el-dropdown-item divided @click="logout">
              <el-icon><SwitchButton /></el-icon>
              <span>退出登录</span>
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </div>
</template>

<style lang="less" scoped>
.header-container {
  padding: 0 20px;
  background-color: var(--header-bg);
  height: 60px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 1px 4px rgba(0, 21, 41, 0.08);

  .l-content {
    display: flex;
    align-items: center;

    .el-breadcrumb {
      font-size: 14px;
    }
  }

  .r-content {
    display: flex;
    align-items: center;

    .time-display {
      margin-right: 20px;
      display: flex;
      align-items: center;
      color: var(--text-regular);

      .el-icon {
        margin-right: 5px;
        font-size: 16px;
      }
    }

    .user-info {
      display: flex;
      align-items: center;
      cursor: pointer;
      padding: 5px 10px;
      border-radius: 4px;
      transition: all 0.3s;

      &:hover {
        background-color: var(--background-color);
      }

      .el-avatar {
        margin-right: 8px;
        background-color: var(--primary-color);
      }

      span {
        margin-right: 5px;
        color: var(--text-primary);
      }
    }
  }
}

.el-dropdown-menu {
  .el-dropdown-item {
    display: flex;
    align-items: center;
    padding: 8px 16px;

    .el-icon {
      margin-right: 8px;
      font-size: 16px;
    }
  }
}
</style>