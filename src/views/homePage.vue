<script setup>
import { ref, onMounted, computed } from "vue";
import { useRouter } from 'vue-router';
import { storage } from "@/storage/storage";
import axios from 'axios';

const router = useRouter();
const username = ref(storage.get('username') || '用户');
const welcomeTime = ref('');
const statistics = ref({
  questionCount: 0,
  courseCount: 0,
  folderCount: 0,
  lastLoginTime: ''
});

const quickLinks = [
  { name: '试题管理', icon: 'Document', path: '/questions', color: '#409EFF' },
  { name: '个人中心', icon: 'User', path: '/central', color: '#67C23A' },
  { name: '创建试题', icon: 'Edit', path: '/edit', color: '#E6A23C' },
  { name: '课程管理', icon: 'Reading', path: '/course', color: '#F56C6C', admin: true }
];

const filteredQuickLinks = computed(() => {
  if (storage.get('role') === 'admin') {
    return quickLinks;
  } else {
    return quickLinks.filter(link => !link.admin);
  }
});

const getWelcomeTime = () => {
  const hour = new Date().getHours();
  if (hour < 6) {
    welcomeTime.value = '凌晨好';
  } else if (hour < 9) {
    welcomeTime.value = '早上好';
  } else if (hour < 12) {
    welcomeTime.value = '上午好';
  } else if (hour < 14) {
    welcomeTime.value = '中午好';
  } else if (hour < 17) {
    welcomeTime.value = '下午好';
  } else if (hour < 19) {
    welcomeTime.value = '傍晚好';
  } else {
    welcomeTime.value = '晚上好';
  }
};

// 获取统计数据
const getStatistics = async () => {
  try {
    const res = await axios.get('/api/user/statistics');
    if (res.data.code === 200) {
      statistics.value = res.data.data;
    }
  } catch (error) {
    console.error('Failed to fetch statistics:', error);
  }
};

onMounted(() => {
  getStatistics();
  getWelcomeTime();
});
</script>

<template>
  <div class="home-container">
    <!-- 欢迎区域 -->
    <div class="welcome-section">
      <div class="welcome-content">
        <h1>{{ welcomeTime }}，{{ username }}</h1>
        <p>欢迎使用试题管理系统，轻松管理您的试题和课程。</p>
      </div>
      <div class="welcome-image">
        <img src="../../static/image/guangyou1.jpg" alt="欢迎图片" />
      </div>
    </div>

    <!-- 统计信息 -->
    <div class="statistics-section">
      <el-row :gutter="20">
        <el-col :span="6">
          <div class="stat-card" style="background-color: rgba(64, 158, 255, 0.1);">
            <el-icon class="stat-icon" color="#409EFF"><Document /></el-icon>
            <div class="stat-info">
              <div class="stat-value">{{ statistics.questionCount }}</div>
              <div class="stat-label">试题总数</div>
            </div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card" style="background-color: rgba(103, 194, 58, 0.1);">
            <el-icon class="stat-icon" color="#67C23A"><Reading /></el-icon>
            <div class="stat-info">
              <div class="stat-value">{{ statistics.courseCount }}</div>
              <div class="stat-label">课程总数</div>
            </div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card" style="background-color: rgba(230, 162, 60, 0.1);">
            <el-icon class="stat-icon" color="#E6A23C"><Folder /></el-icon>
            <div class="stat-info">
              <div class="stat-value">{{ statistics.folderCount }}</div>
              <div class="stat-label">文件夹总数</div>
            </div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-card" style="background-color: rgba(245, 108, 108, 0.1);">
            <el-icon class="stat-icon" color="#F56C6C"><Timer /></el-icon>
            <div class="stat-info">
              <div class="stat-value">上次登录</div>
              <div class="stat-label">{{ statistics.lastLoginTime }}</div>
            </div>
          </div>
        </el-col>
      </el-row>
    </div>

    <!-- 快捷操作 -->
    <div class="quick-links-section">
      <h2 class="section-title">快捷操作</h2>
      <el-row :gutter="20">
        <el-col :span="6" v-for="(link, index) in filteredQuickLinks" :key="index">
          <div class="quick-link-card" @click="router.push(link.path)" :style="{ borderColor: link.color }">
            <el-icon class="quick-link-icon" :color="link.color">
              <component :is="link.icon"></component>
            </el-icon>
            <div class="quick-link-name">{{ link.name }}</div>
          </div>
        </el-col>
      </el-row>
    </div>

    <!-- 系统公告 -->
    <div class="announcement-section">
      <h2 class="section-title">系统公告</h2>
      <el-card class="announcement-card">
        <template #header>
          <div class="announcement-header">
            <span>最新公告</span>
            <el-tag size="small" type="success">新</el-tag>
          </div>
        </template>
        <div class="announcement-content">
          <p>愚蠢的伟</p>
          <p class="announcement-date">2023-06-01</p>
        </div>
      </el-card>
    </div>
  </div>
</template>

<style lang="less" scoped>
.home-container {
  padding: 20px;
}

.welcome-section {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 30px;
  background-color: #fff;
  border-radius: 8px;
  box-shadow: var(--box-shadow);
  overflow: hidden;

  .welcome-content {
    padding: 30px;
    flex: 1;

    h1 {
      font-size: 28px;
      color: var(--text-primary);
      margin-bottom: 10px;
    }

    p {
      font-size: 16px;
      color: var(--text-regular);
      margin: 0;
    }
  }

  .welcome-image {
    width: 40%;
    height: 200px;
    overflow: hidden;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  }
}

.statistics-section {
  margin-bottom: 30px;

  .stat-card {
    display: flex;
    align-items: center;
    padding: 20px;
    border-radius: 8px;
    box-shadow: var(--box-shadow);
    transition: all 0.3s;

    &:hover {
      transform: translateY(-5px);
      box-shadow: 0 6px 16px rgba(0, 0, 0, 0.1);
    }

    .stat-icon {
      font-size: 48px;
      margin-right: 20px;
    }

    .stat-info {
      .stat-value {
        font-size: 24px;
        font-weight: bold;
        color: var(--text-primary);
      }

      .stat-label {
        font-size: 14px;
        color: var(--text-secondary);
        margin-top: 5px;
      }
    }
  }
}

.section-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 20px;
  position: relative;
  padding-left: 12px;

  &::before {
    content: '';
    position: absolute;
    left: 0;
    top: 50%;
    transform: translateY(-50%);
    width: 4px;
    height: 18px;
    background-color: var(--primary-color);
    border-radius: 2px;
  }
}

.quick-links-section {
  margin-bottom: 30px;

  .quick-link-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 120px;
    background-color: #fff;
    border-radius: 8px;
    box-shadow: var(--box-shadow);
    cursor: pointer;
    transition: all 0.3s;
    border-top: 3px solid transparent;

    &:hover {
      transform: translateY(-5px);
      box-shadow: 0 6px 16px rgba(0, 0, 0, 0.1);
    }

    .quick-link-icon {
      font-size: 36px;
      margin-bottom: 10px;
    }

    .quick-link-name {
      font-size: 16px;
      color: var(--text-primary);
    }
  }
}

.announcement-section {
  .announcement-card {
    border-radius: 8px;
    box-shadow: var(--box-shadow);

    .announcement-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      font-size: 16px;
      font-weight: 600;
    }

    .announcement-content {
      p {
        margin: 0 0 10px;
        line-height: 1.6;
      }

      .announcement-date {
        text-align: right;
        color: var(--text-secondary);
        font-size: 12px;
        margin-top: 10px;
      }
    }
  }
}
</style>
