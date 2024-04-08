<script setup>
  import {ref} from "vue";
  import axios from "axios";

  const tableData = ref([])
  const pageParams = ref({
    page: 1,
    pageSize: 2
  })
  const formData = ref({
    id: '',
    description: '',
    answer: '',
    quesCourStr: '',
    chapter: '',
    typeName: '',
    types: '',
    hard: '',
    score: ''
  });
  const count = ref(1)
  const multipleSelection = ref([])
  const dialogVisible = ref(false)
  const currentPage = ref(1)
  const labelWidth = '140px'
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
    // 通过row获取id，在使用filter去tableData中寻找符合id的数组对象，然后赋予formData
    formData.value = tableData.value.filter(item => item.id === row.id)[0]
    console.log(formData.value)
  }
  const handleSizeChange = (val) =>{
    pageParams.value.pageSize = val
    getPage()
  }
  const handleCurrentChange = (val) => {
    pageParams.value.page = val
    getPage()
    console.log(pageParams.value.pageSize,pageParams.value.page)
  }
  const handleSelectionChange = (val) => {
    multipleSelection.value = val
    console.log(multipleSelection)
  }
  const cancelEvent = (row) => {
    console.log(row.date)
  }
  const confirmEvent = (row) => {
    axios.post('/api/questions/delete', '',{
      params: {
        id: row.id
      }
    }
    ).then(res => {
      console.log(JSON.parse(JSON.stringify({
        id: [row.id]
      })))
      getPage()
      console.log(res)
    })
  }
  getPage()

</script>

<template>
  <el-table :data="tableData" style="width: 100%" @selection-change="handleSelectionChange">
    <el-table-column fixed type="selection" width='40' />
    <el-table-column prop="id" label="序号" width="60" />
    <el-table-column prop="description" label="文件夹/题目" show-overflow-tooltip width="auto" />
    <el-table-column prop="quesCourStr" label="课程" width="150"  />
    <el-table-column prop="types" label="题型" width="120" />
    <el-table-column prop="hard" label="难易" width="100" />
    <el-table-column fixed="right" label="操作" width="100">
      <template  #default="{ row }">
        <el-button link type="primary" size="small" @click="handleClick(row), dialogVisible = true">编辑</el-button>
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
        v-model:page-size="pageParams.pageSize"
        :page-sizes="[5, 10, 15, 20]"
        :background="true"
        layout="total, sizes, prev, pager, next, jumper"
        :total="count"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
    />
  </div>
  <el-dialog v-model="dialogVisible" title="Shipping address" width="500">
    <el-form :model="formData">
      <el-form-item label="Promotion name" :label-width="labelWidth">
        <el-input v-model="formData.name" autocomplete="off" />
      </el-form-item>
      <el-form-item label="Zones" :label-width="labelWidth">
        <el-select v-model="formData.region" placeholder="Please select a zone">
          <el-option label="Zone No.1" value="shanghai" />
          <el-option label="Zone No.2" value="beijing" />
        </el-select>
      </el-form-item>
    </el-form>
    <template #footer>
      <div class="dialog-footer">
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="dialogVisible = false">
          提交
        </el-button>
      </div>
    </template>
  </el-dialog>
</template>

<style scoped>
.demo-pagination-block + .demo-pagination-block {
  margin-top: 10px;
}
.demo-pagination-block .demonstration {
  margin-bottom: 16px;
}
</style>