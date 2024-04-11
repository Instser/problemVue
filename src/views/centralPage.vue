<script setup>
import {ref} from "vue";
import {storage} from "@/storage/storage";
import router from "@/router/router";
import {ElNotification} from "element-plus";
import axios from "axios";

const visible = ref(false)
const test = () => {
  console.log(visible.value)
}
const getIsAuthenticated = () => {
  console.log(storage.get('isAuthenticated'))
}
const logOff = () => {
  axios.get('/api/logout')
  storage.remove('isAuthenticated')
  router.push('/login')
  ElNotification({
    title: '退出登录',
    message: '请重新登录',
    type: 'success'
  })
}
</script>

<template>
  <el-popover :visible="visible" placement="top" :width="160">
    <p>确定删除吗？</p>
    <div style="text-align: right; margin: 0">
      <el-button size="small" text @click="visible = false">取消</el-button>
      <el-button size="small" type="primary" @click="visible = false">确定</el-button>
    </div>
    <template #reference>
      <el-button @click="visible = true;test()" >删除</el-button>
    </template>
  </el-popover>
  <el-button @click="getIsAuthenticated">查看登录状态</el-button>
  <el-button @click="logOff">退出登录</el-button>
</template>

<style scoped>

</style>