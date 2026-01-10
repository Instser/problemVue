<script setup>
import {onMounted, ref} from "vue";
import axios from "axios";
import router from "@/router/router";

const tableData = ref([])
const params = ref({
  page: 1,
  pageSize: 2
})
const count = ref(1)
const multipleSelection = ref([])
const getPage = () => {
  axios.get('/api/course/page', {
    params: {
      page: params.value.page,
      pageSize: params.value.pageSize
    }
  }).then(res => {
    tableData.value = res.data.data.list
    count.value = res.data.data.count
  })
}
const handleSizeChange = (val) => {
  params.value.pageSize = val
  getPage()
}
const handleClick = (row) => {
  console.log(row.id)
}
const handleCurrentChange = (val) => {
  params.value.page = val
  console.log(params.value.page, params.value.pageSize)
  getPage()
}
const handleSelectionChange = (val) => {
  multipleSelection.value = val
}
onMounted(() => {
  getPage()
})
</script>

<template>
  <div id="vue">
    <el-table
        :data="tableData"
        :header-cell-style="{textAlign: 'center'}"
        :cell-style="{ textAlign: 'center' }"
        @selection-change="handleSelectionChange">
      border
      style="width: 100%">
      <el-table-column
          type="selection"
          width="55">
      </el-table-column>
      <el-table-column
          prop="name"
          label="课程"
          width="auto">
        <template v-slot="scope">
          <el-button link type="primary" @click="evt => {router.push('/home')}">{{ scope.row.name}}</el-button>
        </template>
      </el-table-column>
      <el-table-column
          prop="description"
          label="描述"
          width="auto">
      </el-table-column>
      <el-table-column
          prop="teaNamesStr"
          label="任课老师"
          width="auto">
      </el-table-column>
      <el-table-column
          fixed="right"
          label="操作"
          width="auto">
        <template v-slot="scope">
          <el-button link @click="handleClick(scope.row)" type="primary" size="small">查看</el-button>
          <el-button link type="primary" size="small">编辑</el-button>
        </template>
      </el-table-column>
    </el-table>
    <div class="block">
      <el-pagination
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          :current-page="params.page"
          :page-sizes="[1, 2, 3, 4]"
          :page-size="params.pageSize"
          layout="total, sizes, prev, pager, next, jumper"
          :total="count">
      </el-pagination>
    </div>
  </div>
</template>

<style scoped>

</style>