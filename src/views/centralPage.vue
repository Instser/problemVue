<script setup>
import {ref} from "vue";
import {storage} from "@/storage/storage";
import router from "@/router/router";
import {ElNotification} from "element-plus";
import axios from "axios";

const formVisible = ref(false)
const formTable = ref({
  oldPsw: '',
  newPsw: ''
})
const updatePsw = () => {
  axios.post('http://8.210.230.249:8888/user/updatePwd',JSON.parse(JSON.stringify({
    mapKey1: formTable.value.oldPsw,
    mapKey2: formTable.value.newPsw
  }))).then(res => {
    if (res.data.code === 200) {
      ElNotification({
        title: '修改成功',
        type: 'success'
      });
    } else {
      ElNotification({
        title: '修改失败',
        type: 'error'
      })
    }
  })
}
const logOff = () => {
  axios.get('http://8.210.230.249:8888/logout')
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
  <el-dialog v-model="formVisible"
             title="修改密码"
             width="500"
             align-center
             :close-on-click-modal="false"
             @closed="() =>  formTable = {}">
    <el-form :model="formTable">
      <el-form-item label="旧密码" :label-width="150">
        <el-input v-model="formTable.oldPsw" autocomplete="off" />
      </el-form-item>
      <el-form-item label="新密码" :label-width="150">
        <el-input v-model="formTable.newPsw" autocomplete="off" />
      </el-form-item>
    </el-form>
    <template #footer>
      <div class="dialog-footer">
        <el-button @click="formVisible = false">取消</el-button>
        <el-button type="primary" @click="formVisible = false; updatePsw()">
          提交
        </el-button>
      </div>
    </template>
  </el-dialog>
  <el-button @click="formVisible = true" >修改密码</el-button>
  <el-button @click="logOff">退出登录</el-button>
</template>

<style scoped>

</style>