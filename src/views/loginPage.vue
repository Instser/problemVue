<template>
  <div class="login-container">
    <div class="login-box">
      <div class="login-left">
        <div class="login-title">
          <h1>试题管理系统</h1>
          <p>一站式试题管理解决方案</p>
        </div>
      </div>

      <div class="login-right">
        <div class="login-form-container">
          <div class="form-header">
            <h2>欢迎登录</h2>
            <p>请使用您的账号登录系统</p>
          </div>

          <el-tabs v-model="activeTab" class="login-tabs">
            <el-tab-pane label="账号登录" name="login">
              <el-form ref="formRef" :model="loginForm" :rules="loginRules" label-position="top" class="login-form">
                <el-form-item prop="username">
                  <el-input
                    v-model="loginForm.username"
                    placeholder="用户名"
                    prefix-icon="User"
                  ></el-input>
                </el-form-item>

                <el-form-item prop="password">
                  <el-input
                    v-model="loginForm.password"
                    type="password"
                    placeholder="密码"
                    prefix-icon="Lock"
                    show-password
                    @keydown.enter="login"
                  ></el-input>
                </el-form-item>

                <el-form-item prop="code" class="captcha-item">
                  <el-input
                    v-model="loginForm.code"
                    placeholder="验证码"
                    prefix-icon="Key"
                    @keydown.enter="login"
                  ></el-input>
                  <div class="captcha-img" @click="getVcimg">
                    <img :src="decodePwd" alt="验证码" />
                  </div>
                </el-form-item>

                <el-form-item class="remember-item">
                  <el-checkbox v-model="rememberMe" value="1" label="记住账号" />
                </el-form-item>

                <el-form-item>
                  <el-button type="primary" class="login-button" @click="login" :loading="loginLoading">
                    <el-icon><Right /></el-icon>
                    登录
                  </el-button>
                </el-form-item>
              </el-form>
            </el-tab-pane>

            <el-tab-pane label="注册账号" name="register">
              <el-form ref="registerFormRef" :model="registerForm" :rules="registerRules" label-position="top" class="register-form">
                <el-form-item prop="nickname">
                  <el-input
                    v-model="registerForm.nickname"
                    placeholder="昵称"
                    prefix-icon="UserFilled"
                  ></el-input>
                </el-form-item>

                <el-form-item prop="username">
                  <el-input
                    v-model="registerForm.username"
                    placeholder="用户名"
                    prefix-icon="User"
                  ></el-input>
                </el-form-item>

                <el-form-item prop="password">
                  <el-input
                    v-model="registerForm.password"
                    type="password"
                    placeholder="密码"
                    prefix-icon="Lock"
                    show-password
                  ></el-input>
                </el-form-item>

                <el-row :gutter="20">
                  <el-col :span="12">
                    <el-form-item prop="role">
                      <el-select v-model="registerForm.role" placeholder="选择角色" class="full-width">
                        <el-option label="教师" value="teacher"></el-option>
                        <el-option label="管理员" value="admin"></el-option>
                      </el-select>
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item prop="gender">
                      <el-select v-model="registerForm.gender" placeholder="选择性别" class="full-width">
                        <el-option label="男" value="male"></el-option>
                        <el-option label="女" value="female"></el-option>
                      </el-select>
                    </el-form-item>
                  </el-col>
                </el-row>

                <el-form-item prop="college">
                  <el-input
                    v-model="registerForm.college"
                    placeholder="学院"
                    prefix-icon="School"
                  ></el-input>
                </el-form-item>

                <el-form-item>
                  <el-button type="primary" class="register-button" @click="register1" :loading="registerLoading">
                    <el-icon><CircleCheck /></el-icon>
                    注册
                  </el-button>
                </el-form-item>
              </el-form>
            </el-tab-pane>
          </el-tabs>

          <div class="form-footer">
            <p>版权所有 &copy; {{ new Date().getFullYear() }} 试题管理系统</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, unref, onMounted } from "vue";
import router from "@/router/router";
import axios from "axios";
import { storage } from "@/storage/storage";
import { ElNotification } from "element-plus";

const activeTab = ref('login');
const formRef = ref(null);
const registerFormRef = ref(null);
const decodePwd = ref('');
const rememberMe = ref([]);
const loginLoading = ref(false);
const registerLoading = ref(false);

const loginForm = ref({
  username: '',
  password: '',
  code: ''
});

const registerForm = ref({
  nickname: '',
  username: '',
  password: '',
  role: '',
  gender: '',
  college: ''
});
const registerRules = {
  nickname: [
    { required: true,
      message: '请输入昵称',
      trigger: 'blur'
    }
  ],
  username: [
    { required:
          true, message: '' +
          '请输入用户名',
      trigger: 'blur'
    }
  ],
  password: [
    { required: true,
      message: '请输入密码',
      trigger: 'blur'
    },
    { min: 6,
      message: '密码长度不能少于6位',
      trigger: 'blur'
    }
  ],
  role: [
    { required: true,
      message: '请选择角色',
      trigger: 'change'
    }
  ],
  gender: [
    { required: true,
      message: '请选择性别',
      trigger: 'change'
    }
  ],
  college: [
    { required: true,
      message: '请输入学院名称',
      trigger: 'blur'
    }
  ]
};
const loginRules = {
  username: [{required: true, message: '请输入用户名', trigger: 'blur'}],
  password: [{required: true, message: '请输入密码', trigger: 'blur'}],
  code: [{required: true, message: '请输入验证码', trigger: 'blur'}]
}
const login = () => {
  const form = unref(formRef);
  form.validate(valid => {
    if (valid) {
      loginLoading.value = true;
      axios.post('/api/doLogin', JSON.parse(JSON.stringify({
        username: loginForm.value.username,
        password: loginForm.value.password,
        'remember-me': rememberMe.value[0],
        code: loginForm.value.code
      })))
      .then(res => {
        if (res.data.msg === '验证码不匹配!') {
          ElNotification({
            title: '验证码不正确',
            type: 'warning',
            duration: 3000
          });
          getVcimg();
        } else if (res.data.msg === '账号或密码错误。') {
          ElNotification({
            title: '账号或密码错误',
            type: 'warning',
            duration: 3000
          });
          getVcimg();
        } else if ('data' in res.data) {
          ElNotification({
            title: '登录成功',
            message: '欢迎回来！',
            type: 'success',
            duration: 3000
          });
          // 存储用户信息
          storage.set('isAuthenticated', true);
          storage.set('role', res.data.data.role);
          storage.set('username', loginForm.value.username);
          storage.set('userId', res.data.data.id);

          // 导航到首页 - 路由守卫会自动处理权限路由
          router.push('/home');
        }
      })
      .catch(error => {
        ElNotification({
          title: '登录失败',
          message: '网络错误，请稍后重试',
          type: 'error',
          duration: 3000
        });
        console.error('Login error:', error);
      })
      .finally(() => {
        loginLoading.value = false;
      });
    } else {
      ElNotification({
        title: '请填写完整信息',
        type: 'warning',
        duration: 3000
      });
      getVcimg();
    }
  });
}
const register1 = () => {
  const form = unref(registerFormRef);
  form.validate(valid => {
    if (valid) {
      registerLoading.value = true;
      axios.post('/api/user/addUser', JSON.parse(JSON.stringify({
        nickname: registerForm.value.nickname,
        username: registerForm.value.username,
        password: registerForm.value.password,
        role: registerForm.value.role,
        gender: registerForm.value.gender,
        college: registerForm.value.college
      })))
      .then(res => {
        if (res.data.code === 200) {
          ElNotification({
            title: '注册成功',
            message: '请使用新账号登录系统',
            type: 'success',
            duration: 3000
          });
          activeTab.value = 'login';
          // 清空注册表单
          registerForm.value = {
            nickname: '',
            username: '',
            password: '',
            role: '',
            gender: '',
            college: ''
          };
        } else {
          ElNotification({
            title: '注册失败',
            message: res.data.msg || '请检查输入信息是否正确',
            type: 'error',
            duration: 3000
          });
        }
      })
      .catch(error => {
        ElNotification({
          title: '注册失败',
          message: '网络错误，请稍后重试',
          type: 'error',
          duration: 3000
        });
        console.error('Register error:', error);
      })
      .finally(() => {
        registerLoading.value = false;
      });
    } else {
      ElNotification({
        title: '请填写完整信息',
        type: 'warning',
        duration: 3000
      });
    }
  });
}
const getVcimg = () => {
  axios.get('/api/vcimg')
    .then(res => {
      decodePwd.value = 'data:image/jpeg;base64,' + res.data.data;
    })
    .catch(error => {
      console.error('Failed to get captcha:', error);
      ElNotification({
        title: '验证码获取失败',
        message: '请刷新页面重试',
        type: 'error',
        duration: 3000
      });
    });
};

onMounted(() => {
  getVcimg();
});
</script>

<style lang="less" scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  width: 100vw;
  background-image: url('../../static/image/guangyou1.jpg');
  background-size: cover;
  background-repeat: no-repeat;
  background-attachment: fixed;
  background-position: center center;
  position: relative;

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.4);
    backdrop-filter: blur(3px);
  }
}

.login-box {
  display: flex;
  width: 900px;
  height: 600px;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
  position: relative;
  z-index: 1;
  background-color: #fff;
}

.login-left {
  width: 40%;
  background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;
  color: #fff;
  position: relative;
  overflow: hidden;

  &::before {
    content: '';
    position: absolute;
    top: -50%;
    left: -50%;
    width: 200%;
    height: 200%;
    background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, rgba(255,255,255,0) 60%);
    transform: rotate(30deg);
  }

  .login-title {
    text-align: center;
    position: relative;
    z-index: 1;

    h1 {
      font-size: 32px;
      font-weight: 700;
      margin-bottom: 16px;
      text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
    }

    p {
      font-size: 16px;
      opacity: 0.9;
      margin-bottom: 30px;
    }
  }
}

.login-right {
  width: 60%;
  padding: 40px;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.login-form-container {
  width: 100%;
  max-width: 400px;
  margin: 0 auto;

  .form-header {
    text-align: center;
    margin-bottom: 30px;

    h2 {
      font-size: 24px;
      color: var(--text-primary);
      margin-bottom: 8px;
    }

    p {
      font-size: 14px;
      color: var(--text-secondary);
    }
  }

  .login-tabs {
    margin-bottom: 20px;
  }

  .login-form, .register-form {
    .el-form-item {
      margin-bottom: 20px;
    }

    .captcha-item {
      display: flex;
      align-items: flex-start;

      .el-form-item__content {
        display: flex;
        align-items: center;
      }

      .captcha-img {
        margin-left: 10px;
        height: 40px;
        cursor: pointer;
        border-radius: 4px;
        overflow: hidden;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);

        img {
          height: 100%;
          display: block;
        }
      }
    }

    .remember-item {
      margin-bottom: 10px;
    }

    .login-button, .register-button {
      width: 100%;
      padding: 12px 0;
      font-size: 16px;
      border-radius: 4px;
      margin-top: 10px;
      transition: all 0.3s;

      &:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(64, 158, 255, 0.4);
      }

      .el-icon {
        margin-right: 8px;
      }
    }
  }

  .form-footer {
    text-align: center;
    margin-top: 30px;
    color: var(--text-secondary);
    font-size: 12px;
  }
}

.full-width {
  width: 100%;
}
</style>