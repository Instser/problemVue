<script setup>
import { ref, onMounted } from "vue";
import { storage } from "@/storage/storage";
import router from "@/router/router";
import { ElNotification } from "element-plus";
import axios from "axios";

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
  questionCount: 125,
  courseCount: 8,
  folderCount: 15,
  lastActivity: '2023-06-01 15:45:22'
});

// 最近活动
const recentActivities = ref([
  { id: 1, type: '创建试题', name: '数据结构期末考试题', time: '2023-06-01 15:45:22' },
  { id: 2, type: '编辑试题', name: '算法分析期中测验', time: '2023-05-28 09:30:15' },
  { id: 3, type: '创建文件夹', name: '编译原理试题集', time: '2023-05-25 14:20:33' },
  { id: 4, type: '添加课程', name: '计算机网络', time: '2023-05-20 11:15:42' },
  { id: 5, type: '编辑试题', name: '操作系统期末考试', time: '2023-05-18 16:40:10' }
]);

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
      validator: (rule, value, callback) => {
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

onMounted(() => {
  getUserInfo();
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
          <el-timeline>
            <el-timeline-item
              v-for="activity in recentActivities"
              :key="activity.id"
              :timestamp="activity.time"
              :type="getActivityType(activity.type)"
            >
              <div class="activity-content">
                <span class="activity-type">{{ activity.type }}</span>
                <span class="activity-name">{{ activity.name }}</span>
              </div>
            </el-timeline-item>
          </el-timeline>
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

    .activity-type {
      font-weight: bold;
      color: var(--text-primary);
      margin-bottom: 5px;
    }

    .activity-name {
      color: var(--text-regular);
    }
  }
}

.el-timeline-item {
  padding-bottom: 20px;
}
</style>
