<template>
  <div class="login-container">
    <el-form ref="formRef" :model="loginForm" :rules="loginRules" label-position="top">
      <el-form-item label="用户名" prop="username">
        <el-input v-model="loginForm.username"></el-input>
      </el-form-item>
      <el-form-item label="密码" prop="password">
        <el-input type="password" v-model="loginForm.password"></el-input>
      </el-form-item>
      <el-form-item label="验证码" prop="code">
        <el-input type="text" v-model="loginForm.code"></el-input>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="login">登录</el-button>
      </el-form-item>
      <img :src="decodePwd" @click="getVcimg" alt="加载失败" />
    </el-form>
  </div>
</template>

<script setup>
import {ref, unref} from "vue";
import router from "@/router/router";
import axios from "axios";
import {storage} from "@/storage/storage";
import {ElNotification} from "element-plus";

const formRef = ref(null)
const loginForm = ref({
  username: '',
  password: '',
  code: ''
  })
const loginRules = {
  username: [{required: true, message: '请输入用户名', trigger: 'blur'}],
  password: [{required: true, message: '请输入密码', trigger: 'blur'}],
  code: [{required: true, message: '请输入验证码', trigger: 'blur'}]
}
const login = () => {
  const form = unref(formRef)
  form.validate(valid => {
    if (valid) {
      axios.post('/api/doLogin', JSON.parse(JSON.stringify({
            username: loginForm.value.username,
            password: loginForm.value.password,
            code: loginForm.value.code
          }))
      ).then(res => {
        console.log(res.data)
        if (res.data.msg === '验证码不匹配!') {
          ElNotification({
            title: '验证码不正确',
            type: 'warning'
          })
          getVcimg()
        }
        if (res.data.data === '登录成功') {
          storage.set('isAuthenticated', true);
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
const decodePwd = ref('')
const getVcimg = () => {
  axios.get('/api/vcimg').then(res => {
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
</style>