<template>
  <div class="login-container">
    <div class="form-container">
      <h1>欢迎使用</h1>
      <el-form ref="formRef" :model="loginForm" :rules="loginRules" label-position="top">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="loginForm.username"></el-input>
        </el-form-item>
        <el-form-item label="密码" prop="password" @keydown.enter="login">
          <el-input type="password" v-model="loginForm.password"></el-input>
        </el-form-item>
        <el-form-item label="验证码" prop="code" @keydown.enter="login">
          <el-input type="text" v-model="loginForm.code"></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="login">登录</el-button>
          <el-button type="primary" @click="registerFormVisible = true">注册</el-button>
          <el-checkbox v-model=rememberMe value="1" label="记住账号" />
        </el-form-item>
        <img :src="decodePwd" @click="getVcimg" alt="加载失败" />
      </el-form>
    </div>
    <div v-if="registerFormVisible" class="form-container" style="margin-top: 20px;">
      <h1>注册新用户</h1>
      <el-form ref="registerFormRef" :model="registerForm" :rules="registerRules" label-position="top">
        <el-form-item label="昵称" prop="nickname">
          <el-input v-model="registerForm.nickname"></el-input>
        </el-form-item>
        <el-form-item label="用户名" prop="username">
          <el-input v-model="registerForm.username"></el-input>
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input type="password" v-model="registerForm.password"></el-input>
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="registerForm.role" placeholder="请选择">
            <el-option label="教师" value="teacher"></el-option>
            <el-option label="管理员" value="admin"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="性别" prop="gender">
          <el-select v-model="registerForm.gender" placeholder="请选择">
            <el-option label="男" value="male"></el-option>
            <el-option label="女" value="female"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="学院" prop="college">
          <el-input v-model="registerForm.college"></el-input>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="register1">注册</el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup>
import {ref, unref} from "vue";
import router from "@/router/router";
import axios from "axios";
import {storage} from "@/storage/storage";
import {ElNotification} from "element-plus";

const formRef = ref(null)
const decodePwd = ref('')
const rememberMe = ref([])
const loginForm = ref({
  username: '',
  password: '',
  code: ''
  })
const registerForm = ref({
  nickname: '',
  username: '',
  password: '',
  role: '',
  gender: '',
  college: ''
})
const registerFormVisible = ref(false)
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
  const form = unref(formRef)
  form.validate(valid => {
    if (valid) {
      axios.post('http://8.210.230.249:8888/doLogin', JSON.parse(JSON.stringify({
            username: loginForm.value.username,
            password: loginForm.value.password,
            'remember-me': rememberMe.value[0],
            code: loginForm.value.code
          }))
      ).then(res => {
        if (res.data.msg === '验证码不匹配!') {
          ElNotification({
            title: '验证码不正确',
            type: 'warning'
          })
          getVcimg()
        }
        if (res.data.msg === '账号或密码错误。') {
          ElNotification({
            title: '账号或密码错误。',
            type: 'warning'
          })
          getVcimg()
        }
        if ('data' in res.data) {
          console.log('登录');
          storage.set('isAuthenticated', true);
          storage.set('role', res.data.data.role);
          storage.set('freshRoute', true);
          router.push('/home');
        }
      }).catch()
    }else {
      ElNotification({
        title: '登陆失败，请重试',
        type: 'warning'
      })
      getVcimg()
    }
  })
}
const register1 = () => {
  axios.post('http://8.210.230.249:8888/user/addUser',JSON.parse(JSON.stringify({
    nickname: registerForm.value.nickname,
    username: registerForm.value.username,
    password: registerForm.value.password,
    role: registerForm.value.role,
    gender: registerForm.value.gender,
    college: registerForm.value.college
  }))).then(res => {
    if (res.data.code === 200) {
      registerFormVisible.value = false;
      ElNotification({
        title: '注册成功',
        type: "success"
      });
    } else {
      ElNotification({
        title: '注册失败',
        type: "error"
      });
    }
  })
}
const getVcimg = () => {
  axios.get('http://8.210.230.249:8888/vcimg').then(res => {
    decodePwd.value = 'data:image/jpeg;base64,' + res.data.data
  })
}
getVcimg()
</script>

<style scoped>
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
}
.login-container {
  background-image: url('../../static/image/guangyou1.jpg');
  background-size: cover;
  background-repeat: no-repeat;
  background-attachment: fixed;
  background-position: center center;
  height: 100vh;
  width: 100vw;
  position: absolute;
  top: 0;
  left: 0;
}
.form-container {
  background-color: rgba(255, 255, 255, 0.5);
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  width: auto;
}
h1 {
  text-align: center;
  margin-bottom: 20px;
}
</style>