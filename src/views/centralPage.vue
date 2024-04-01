<script setup>
  import {ref} from "vue";

  const visible = ref(false)
  const test = () => {
    console.log(visible.value)
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
</template>

<style scoped>

</style>