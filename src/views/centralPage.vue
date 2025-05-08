<script setup>
import { ref, onMounted } from "vue";
import { storage } from "@/storage/storage";
import router from "@/router/router";
import { ElNotification } from "element-plus";
import { ArrowDown } from "@element-plus/icons-vue";
import axios from "axios";
import activityService from "@/services/activityService";

// 用户信息
const userInfo = ref({
  username: storage.get('username') || '用户',
  role: storage.get('role') === 'admin' ? '管理员' : '教师',
  lastLogin: '2023-06-01 10:30:45',
  email: '1027691813@qq.com',
  college: '计算机学院',
  createdTime: '2023-01-15',
  nickname: '用户昵称'
});

// 统计数据
const statistics = ref({
  questionCount: 0,
  courseCount: 0,
  folderCount: 0,
  lastLoginTime: ''
});

// 最近活动
const recentActivities = ref([
  // 测试数据，如果API返回数据，这些测试数据会被覆盖
  {
    id: 1,
    type: '创建试题',
    name: '测试试题1',
    time: '2023-06-01 10:30:45'
  },
  {
    id: 2,
    type: '编辑试题',
    name: '测试试题2',
    time: '2023-06-02 11:20:30'
  },
  {
    id: 3,
    type: '删除试题',
    name: '测试试题3',
    time: '2023-06-03 14:15:22'
  }
]);
const activityLimit = ref(5); // 默认显示5条活动记录

// 修改密码对话框
const passwordFormVisible = ref(false);
const passwordFormLoading = ref(false);
const passwordForm = ref({
  oldPsw: '',
  newPsw: '',
  confirmPsw: ''
});

// 修改密码表单规则
const passwordRules = {
  oldPsw: [{ required: true, message: '请输入旧密码', trigger: 'blur' }],
  newPsw: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ],
  confirmPsw: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    {
      validator: (_, value, callback) => {
        if (value !== passwordForm.value.newPsw) {
          callback(new Error('两次输入的密码不一致'));
        } else {
          callback();
        }
      },
      trigger: 'blur'
    }
  ]
};

// 根据活动类型返回不同的颜色
const getActivityType = (type) => {
  const typeMap = {
    '创建试题': 'primary',
    '编辑试题': 'success',
    '创建文件夹': 'warning',
    '添加课程': 'info',
    '删除试题': 'danger'
  };
  return typeMap[type] || 'primary';
};

// 判断是否为试题相关活动
const isQuestionActivity = (type) => {
  return ['创建试题', '编辑试题', '删除试题'].includes(type);
};

// 将数字难度转换为中文难度
const getDifficultyLabel = (hard) => {
  // 将数字转换为对应的中文标签
  const difficultyMap = {
    '1': '入门',
    '2': '简单',
    '3': '中等',
    '4': '困难',
    '5': '挑战'
  };

  // 如果是数字字符串，直接映射
  if (difficultyMap[hard]) {
    return difficultyMap[hard];
  }

  // 如果是旧数据中的中文，保持原样显示
  if (['入门', '简单', '中等', '困难', '挑战'].includes(hard)) {
    return hard;
  }

  // 其他情况，尝试将其作为数字处理
  const numHard = parseInt(hard);
  if (!isNaN(numHard) && numHard >= 1 && numHard <= 5) {
    return difficultyMap[numHard.toString()];
  }

  // 默认返回中等
  return '中等';
};

// 解析活动名称，尝试提取元数据和内容
const parseActivityName = (name) => {
  try {
    // 尝试解析JSON格式的活动名称
    const parsed = JSON.parse(name);
    if (parsed && typeof parsed === 'object' && 'metadata' in parsed && 'content' in parsed) {
      // 处理元数据中的难度信息
      if (parsed.metadata) {
        // 查找并替换难度信息
        const difficultyRegex = /(\d+)难度/g;
        parsed.metadata = parsed.metadata.replace(difficultyRegex, (_match, p1) => {
          return `${getDifficultyLabel(p1)}难度`;
        });
      }
      return parsed;
    }
  } catch (e) {
    // 如果解析失败，说明不是JSON格式，使用旧格式处理
    console.log('活动名称不是JSON格式，使用旧格式处理');
  }

  // 旧格式或解析失败时，将整个名称作为内容返回
  return {
    metadata: '',
    content: name
  };
};

// 修改密码
const updatePassword = () => {
  passwordFormLoading.value = true;
  axios.post('/api/user/updatePwd', JSON.parse(JSON.stringify({
    mapKey1: passwordForm.value.oldPsw,
    mapKey2: passwordForm.value.newPsw
  })))
  .then(res => {
    if (res.data.code === 200) {
      ElNotification({
        title: '修改成功',
        message: '密码已成功更新',
        type: 'success',
        duration: 3000
      });
      passwordFormVisible.value = false;
      // 清空表单
      passwordForm.value = {
        oldPsw: '',
        newPsw: '',
        confirmPsw: ''
      };
    } else {
      ElNotification({
        title: '修改失败',
        message: res.data.msg || '请检查旧密码是否正确',
        type: 'error',
        duration: 3000
      });
    }
  })
  .catch(error => {
    ElNotification({
      title: '修改失败',
      message: '网络错误，请稍后重试',
      type: 'error',
      duration: 3000
    });
    console.error('Update password error:', error);
  })
  .finally(() => {
    passwordFormLoading.value = false;
  });
};

// 退出登录
const logout = () => {
  axios.get('/api/logout');
  storage.remove('isAuthenticated');
  storage.remove('username');
  storage.remove('role');
  router.push('/login');
  ElNotification({
    title: '退出登录',
    message: '请重新登录',
    type: 'success',
    duration: 3000
  });
};

// 获取用户信息
const getUserInfo = async () => {
  try {
    const res = await axios.get('/api/user/info');
    if (res.data.code === 200) {
      userInfo.value = {
        ...res.data.data,
        role: storage.get('role') === 'admin' ? '管理员' : '教师'
      };
    }
  } catch (error) {
    console.error('Failed to fetch user info:', error);
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

// 获取最近活动
const getRecentActivities = async () => {
  try {
    console.log('开始获取最近活动，限制数量:', activityLimit.value);

    // 尝试使用活动服务获取最近活动
    try {
      const activities = await activityService.getRecentActivities(activityLimit.value);
      console.log('通过活动服务获取到的活动记录:', activities);

      if (activities && activities.length > 0) {
        // 确保每个活动记录都有必要的字段
        recentActivities.value = activities.map(activity => {
          return {
            id: activity.id || 0,
            type: activity.type || '未知活动',
            name: activity.name || '未命名活动',
            time: activity.time || '未知时间'
          };
        });

        console.log('处理后的活动记录:', recentActivities.value);
        return; // 成功获取数据，直接返回
      }
    } catch (serviceError) {
      console.error('通过活动服务获取活动记录失败:', serviceError);
    }

    // 如果活动服务获取失败，尝试直接从后端获取
    console.log('尝试直接从后端获取活动记录');
    const userId = storage.get('userId');
    if (!userId) {
      console.warn('未找到用户ID，无法获取活动记录');
      return;
    }

    const response = await axios({
      method: 'get',
      url: '/api/userActivity/byUserId',
      params: {
        userId,
        limit: activityLimit.value
      },
      headers: {
        'Accept': 'application/json'
      }
    });

    console.log('直接从后端获取活动记录响应:', response);

    // 处理响应数据
    let activities = [];
    if (response.data && response.data.code === 200 && Array.isArray(response.data.data)) {
      activities = response.data.data;
    } else if (response.data && response.data.data && response.data.data.code === 200 && Array.isArray(response.data.data.data)) {
      activities = response.data.data.data;
    }

    console.log('直接从后端解析的活动记录:', activities);

    if (activities && activities.length > 0) {
      // 确保每个活动记录都有必要的字段
      recentActivities.value = activities.map(activity => {
        return {
          id: activity.id || 0,
          type: activity.type || '未知活动',
          name: activity.name || '未命名活动',
          time: activity.time || '未知时间'
        };
      });

      console.log('处理后的活动记录:', recentActivities.value);
    } else {
      console.log('没有获取到活动记录，保留测试数据');
    }
  } catch (error) {
    console.error('获取最近活动失败:', error);
    // 发生错误时，保留测试数据
  }
};

// 加载更多活动
const loadMoreActivities = () => {
  activityLimit.value += 5;
  getRecentActivities();
};

onMounted(() => {
  getUserInfo();
  getStatistics();
  getRecentActivities();
});
</script>

<template>
  <div class="central-container">
    <!-- 用户信息卡片 -->
    <el-row :gutter="20">
      <el-col :span="8">
        <div class="user-card">
          <div class="user-header">
            <el-avatar :size="80" icon="UserFilled" class="user-avatar" />
            <div class="user-info">
              <h2>{{ userInfo.nickname }}</h2>
              <p>{{ userInfo.username }} <el-tag size="small" type="success">{{ userInfo.role }}</el-tag></p>
            </div>
          </div>
          <div class="user-details">
            <div class="detail-item">
              <el-icon><Message /></el-icon>
              <span>{{ userInfo.email }}</span>
            </div>
            <div class="detail-item">
              <el-icon><School /></el-icon>
              <span>{{ userInfo.college }}</span>
            </div>
            <div class="detail-item">
              <el-icon><Timer /></el-icon>
              <span>注册时间：{{ userInfo.createdTime }}</span>
            </div>
            <div class="detail-item">
              <el-icon><Calendar /></el-icon>
              <span>上次登录：{{ userInfo.lastLogin }}</span>
            </div>
          </div>
          <div class="user-actions">
            <el-button type="primary" @click="passwordFormVisible = true">
              <el-icon><Lock /></el-icon>
              修改密码
            </el-button>
            <el-button type="danger" @click="logout">
              <el-icon><SwitchButton /></el-icon>
              退出登录
            </el-button>
          </div>
        </div>
      </el-col>

      <el-col :span="16">
        <!-- 统计信息 -->
        <div class="statistics-section">
          <h3 class="section-title">统计信息</h3>
          <el-row :gutter="20">
            <el-col :span="8">
              <div class="stat-card" style="background-color: rgba(64, 158, 255, 0.1);">
                <el-icon class="stat-icon" color="#409EFF"><Document /></el-icon>
                <div class="stat-info">
                  <div class="stat-value">{{ statistics.questionCount }}</div>
                  <div class="stat-label">试题总数</div>
                </div>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="stat-card" style="background-color: rgba(103, 194, 58, 0.1);">
                <el-icon class="stat-icon" color="#67C23A"><Reading /></el-icon>
                <div class="stat-info">
                  <div class="stat-value">{{ statistics.courseCount }}</div>
                  <div class="stat-label">课程总数</div>
                </div>
              </div>
            </el-col>
            <el-col :span="8">
              <div class="stat-card" style="background-color: rgba(230, 162, 60, 0.1);">
                <el-icon class="stat-icon" color="#E6A23C"><Folder /></el-icon>
                <div class="stat-info">
                  <div class="stat-value">{{ statistics.folderCount }}</div>
                  <div class="stat-label">文件夹总数</div>
                </div>
              </div>
            </el-col>
          </el-row>
        </div>

        <!-- 最近活动 -->
        <div class="activities-section">
          <h3 class="section-title">最近活动</h3>
          <div v-if="recentActivities.length > 0">
            <el-timeline>
              <el-timeline-item
                v-for="activity in recentActivities"
                :key="activity.id"
                :timestamp="activity.time || '未知时间'"
                :type="getActivityType(activity.type || '未知活动')"
              >
                <div class="activity-content">
                  <div class="activity-header">
                    <span class="activity-type">{{ activity.type || '未知活动' }}</span>
                    <span class="activity-metadata" v-if="isQuestionActivity(activity.type)">
                      {{ parseActivityName(activity.name).metadata }}
                    </span>
                  </div>
                  <div class="activity-body" v-if="isQuestionActivity(activity.type) && parseActivityName(activity.name).content">
                    <div class="activity-content-text">{{ parseActivityName(activity.name).content }}</div>
                  </div>
                  <div class="activity-body" v-else>
                    <div class="activity-content-text">{{ activity.name || '未命名活动' }}</div>
                  </div>
                  <!-- 调试信息，可以在生产环境中移除 -->
                  <span class="activity-debug" v-if="false">ID: {{ activity.id }}</span>
                </div>
              </el-timeline-item>

              <!-- 加载更多按钮 -->
              <div class="load-more-container" v-if="recentActivities.length >= activityLimit">
                <el-button type="primary" plain @click="loadMoreActivities" size="small">
                  <el-icon><ArrowDown /></el-icon>
                  加载更多活动
                </el-button>
              </div>
            </el-timeline>
          </div>
          <div v-else class="no-activities">
            <p>暂无活动记录</p>
            <el-button type="primary" @click="getRecentActivities" size="small">
              刷新活动记录
            </el-button>
          </div>
        </div>
      </el-col>
    </el-row>
  </div>

  <!-- 修改密码对话框 -->
  <el-dialog
    v-model="passwordFormVisible"
    title="修改密码"
    width="500"
    align-center
    :close-on-click-modal="false"
  >
    <el-form
      ref="passwordFormRef"
      :model="passwordForm"
      :rules="passwordRules"
      label-position="top"
    >
      <el-form-item label="旧密码" prop="oldPsw">
        <el-input
          v-model="passwordForm.oldPsw"
          type="password"
          placeholder="请输入旧密码"
          show-password
        />
      </el-form-item>
      <el-form-item label="新密码" prop="newPsw">
        <el-input
          v-model="passwordForm.newPsw"
          type="password"
          placeholder="请输入新密码"
          show-password
        />
      </el-form-item>
      <el-form-item label="确认密码" prop="confirmPsw">
        <el-input
          v-model="passwordForm.confirmPsw"
          type="password"
          placeholder="请再次输入新密码"
          show-password
        />
      </el-form-item>
    </el-form>
    <template #footer>
      <div class="dialog-footer">
        <el-button @click="passwordFormVisible = false">取消</el-button>
        <el-button
          type="primary"
          @click="updatePassword"
          :loading="passwordFormLoading"
        >
          提交
        </el-button>
      </div>
    </template>
  </el-dialog>
</template>



<style lang="less" scoped>
.central-container {
  padding: 20px;
}

.user-card {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: var(--box-shadow);
  padding: 20px;
  height: 100%;

  .user-header {
    display: flex;
    align-items: center;
    margin-bottom: 20px;
    padding-bottom: 20px;
    border-bottom: 1px solid var(--border-light);

    .user-avatar {
      background-color: var(--primary-color);
      margin-right: 15px;
    }

    .user-info {
      h2 {
        margin: 0 0 5px;
        font-size: 20px;
        color: var(--text-primary);
      }

      p {
        margin: 0;
        color: var(--text-secondary);
        display: flex;
        align-items: center;

        .el-tag {
          margin-left: 8px;
        }
      }
    }
  }

  .user-details {
    margin-bottom: 20px;

    .detail-item {
      display: flex;
      align-items: center;
      margin-bottom: 12px;
      color: var(--text-regular);

      .el-icon {
        margin-right: 10px;
        font-size: 16px;
        color: var(--primary-color);
      }
    }
  }

  .user-actions {
    display: flex;
    justify-content: space-between;

    .el-button {
      flex: 1;
      margin: 0 5px;

      &:first-child {
        margin-left: 0;
      }

      &:last-child {
        margin-right: 0;
      }

      .el-icon {
        margin-right: 5px;
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

.statistics-section {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: var(--box-shadow);
  padding: 20px;
  margin-bottom: 20px;

  .stat-card {
    display: flex;
    align-items: center;
    padding: 15px;
    border-radius: 8px;
    transition: all 0.3s;

    &:hover {
      transform: translateY(-5px);
      box-shadow: 0 6px 16px rgba(0, 0, 0, 0.1);
    }

    .stat-icon {
      font-size: 40px;
      margin-right: 15px;
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

.activities-section {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: var(--box-shadow);
  padding: 20px;

  .activity-content {
    display: flex;
    flex-direction: column;

    .activity-header {
      display: flex;
      align-items: center;
      margin-bottom: 8px;
      flex-wrap: wrap;
      gap: 8px;

      .activity-type {
        font-weight: bold;
        color: var(--text-primary);
        background-color: rgba(64, 158, 255, 0.1);
        padding: 2px 8px;
        border-radius: 4px;
        font-size: 14px;
      }

      .activity-metadata {
        color: var(--text-secondary);
        background-color: rgba(103, 194, 58, 0.1);
        padding: 2px 8px;
        border-radius: 4px;
        font-size: 13px;
        font-weight: 500;
      }
    }

    .activity-body {
      background-color: rgba(0, 0, 0, 0.02);
      border-radius: 4px;
      padding: 8px 12px;
      margin-top: 4px;

      .activity-content-text {
        color: var(--text-regular);
        word-break: break-word; /* 允许长文本换行 */
        max-height: 120px;
        overflow-y: auto; /* 如果内容太长，添加滚动条 */
        font-size: 14px;
        line-height: 1.5;
      }
    }

    .activity-debug {
      font-size: 12px;
      color: #999;
      margin-top: 5px;
      font-style: italic;
    }
  }
}

.el-timeline-item {
  padding-bottom: 20px;
}

.load-more-container {
  display: flex;
  justify-content: center;
  margin-top: 15px;
  padding-bottom: 10px;

  .el-button {
    width: 100%;
    max-width: 200px;
    transition: all 0.3s;

    &:hover {
      transform: translateY(-2px);
    }

    .el-icon {
      margin-right: 5px;
    }
  }
}

.no-activities {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  height: 150px;
  color: var(--text-secondary);
  font-size: 16px;
  background-color: rgba(0, 0, 0, 0.02);
  border-radius: 4px;
  margin: 20px 0;

  p {
    margin-bottom: 15px;
  }

  .el-button {
    width: 120px;
  }
}
</style>
