<script setup>
import { ref, onMounted } from "vue";
import { storage } from "@/storage/storage";
import axios from 'axios';
const username = ref(storage.get('username') || '用户');
const welcomeTime = ref('');
const statistics = ref({
  questionCount: 0,
  courseCount: 0,
  folderCount: 0,
  lastLoginTime: ''
});

// 公告数据
const announcements = ref([]);



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
    if (res.data && res.data.code === 200 && res.data.data) {
      statistics.value = res.data.data;
    }
  } catch (error) {
    console.error('Failed to fetch statistics:', error);
  }
};

// 获取最新公告
const getLatestAnnouncements = async () => {
  try {
    console.log('获取最新公告');
    const res = await axios.get('/api/announcement/latest');
    console.log('公告响应:', res);

    // 统一从 res.data.data 中获取响应数据
    if (res.data && res.data.code === 200 && res.data.data && res.data.data.length > 0) {
      announcements.value = res.data.data;
    } else {
      // 如果没有公告，设置三个默认公告
      announcements.value = [
        {
          title: '暂无公告',
          content: '暂无公告内容',
          createTime: new Date()
        },
        {
          title: '暂无公告',
          content: '暂无公告内容',
          createTime: new Date()
        },
        {
          title: '暂无公告',
          content: '暂无公告内容',
          createTime: new Date()
        }
      ];
    }
  } catch (error) {
    console.error('Failed to fetch announcements:', error);
    // 出错时设置三个默认公告
    announcements.value = [
      {
        title: '获取公告失败',
        content: '请稍后再试',
        createTime: new Date()
      },
      {
        title: '获取公告失败',
        content: '请稍后再试',
        createTime: new Date()
      },
      {
        title: '获取公告失败',
        content: '请稍后再试',
        createTime: new Date()
      }
    ];
  }
};

// 格式化日期
const formatDate = (dateString) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleDateString();
};

// 监听公告更新
const listenForAnnouncementUpdates = () => {
  window.addEventListener('storage', (event) => {
    if (event.key === 'announcement_updated') {
      console.log('检测到公告更新，刷新数据');
      getLatestAnnouncements();
    }
  });
};

onMounted(() => {
  getStatistics();
  getWelcomeTime();
  getLatestAnnouncements();
  listenForAnnouncementUpdates();
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

    <!-- 系统公告 -->
    <div class="announcement-section">
      <h2 class="section-title">系统公告</h2>
      <div class="announcement-container">
        <el-card class="announcement-card-container">
          <div v-for="(announcement, index) in announcements.slice(0, 3)" :key="index" class="announcement-item">
            <div class="announcement-header">
              <div class="announcement-title">
                <span>{{ announcement?.title || '暂无公告' }}</span>
                <el-tag v-if="announcement?.isTop" size="small" type="danger">置顶</el-tag>
              </div>
              <span class="announcement-date">{{ formatDate(announcement?.createTime) }}</span>
            </div>
            <div class="announcement-content">
              <p v-html="announcement?.content"></p>
            </div>
            <div v-if="index < announcements.slice(0, 3).length - 1" class="announcement-divider"></div>
          </div>
          <div v-if="announcements.length === 0" class="announcement-empty">
            <p>暂无公告</p>
          </div>
        </el-card>
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



.announcement-section {
  margin-bottom: 30px;

  .announcement-container {
    // 控制公告栏的宽度，与其他组件一样自适应页面宽度
    width: 100%;
  }

  .announcement-card-container {
    border-radius: 8px;
    box-shadow: var(--box-shadow);
    padding: 0;
    // 增加高度以容纳三条公告
    min-height: 300px;

    .announcement-item {
      padding: 15px 20px;
      position: relative;
      // 确保每个公告项占据足够的高度，但不要太高，以便能显示三条公告
      height: 100px;
      box-sizing: border-box;
      overflow: hidden;

      .announcement-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 5px;

        .announcement-title {
          display: flex;
          align-items: center;
          gap: 5px;
          font-size: 15px;
          font-weight: 600;
          // 限制标题长度，超出显示省略号
          max-width: 70%;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
        }

        .announcement-date {
          color: var(--text-secondary);
          font-size: 12px;
        }
      }

      .announcement-content {
        margin-top: 5px;
        height: 60px;
        overflow: hidden;

        p {
          margin: 0;
          line-height: 1.5;
          // 限制内容显示行数
          overflow: hidden;
          text-overflow: ellipsis;
          display: -webkit-box;
          -webkit-line-clamp: 2;
          line-clamp: 2;
          -webkit-box-orient: vertical;
          max-height: 3em; // 2行文字的高度
          font-size: 14px;
        }
      }

      .announcement-divider {
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        height: 1px;
        background-color: #ebeef5;
      }
    }

    .announcement-empty {
      padding: 30px;
      text-align: center;
      color: var(--text-secondary);
    }
  }
}
</style>
