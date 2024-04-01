<script setup>
  import {ref} from "vue";
  import axios from "axios";

  const tableData = ref([])
  const params = ref({
    page: 1,
    pageSize: 2
  })
  const count = ref(1)
  const multipleSelection = ref([])
  // const visible = ref(false)
  const currentPage = ref(1)
  const getPage = () => {
    axios.post('/api/questions/page', JSON.parse(JSON.stringify({
      page: 1,
      pageSize: 10,
      folderId: 1
    }))
    ).then(res => {
      tableData.value = res.data.data.list
      count.value = res.data.data.count
      console.log(res.data)
    }).catch()
  }
  const handleClick = (row) => {
    console.log(row)
  }
  const handleSizeChange = (val) =>{
    params.value.pageSize = val
    getPage()
  }
  const handleCurrentChange = (val) => {
    params.value.page = val
    getPage()
    console.log(params.value.pageSize,params.value.page)
  }
  const handleSelectionChange = (val) => {
    multipleSelection.value = val
    console.log(multipleSelection)
  }
  const cancelEvent = (row) => {
    console.log(row.date)
  }
  const confirmEvent = (row) => {
    console.log(row.date)
  }
  getPage()

</script>

<template>
  <el-table :data="tableData" style="width: 100%" @selection-change="handleSelectionChange">
    <el-table-column fixed type="selection" width="39" />
    <el-table-column prop="id" label="序号" width="80" />
    <el-table-column prop="description" label="文件夹/题目" width="880" />
    <el-table-column prop="types" label="题型" width="120" />
    <el-table-column prop="hard" label="难易" width="100" />
    <el-table-column fixed="right" label="操作" width="100">
      <template #default="{ row }">
        <el-button link type="primary" size="small" @click="handleClick(row)">编辑</el-button>
        <el-popconfirm
            width="220"
            confirm-button-text="确定"
            cancel-button-text="取消"
            icon-color="#626AEF"
            title="您确定要删除吗？"
            @confirm="confirmEvent(row)"
            @cancel="cancelEvent(row)"
        >
          <template #reference>
            <el-button link type="primary" size="small">删除</el-button>
          </template>
        </el-popconfirm>
      </template>
    </el-table-column>
  </el-table>
  <div class="demo-pagination-block">
    <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="params.pageSize"
        :page-sizes="[5, 10, 15, 20]"
        :background="true"
        layout="total, sizes, prev, pager, next, jumper"
        :total="count"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
    />
  </div>
</template>

<style scoped>
.demo-pagination-block + .demo-pagination-block {
  margin-top: 10px;
}
.demo-pagination-block .demonstration {
  margin-bottom: 16px;
}
</style>