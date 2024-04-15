<script setup>
import {onMounted, ref} from "vue";
import axios from "axios";
import router from "@/router/router";
import {storage} from "@/storage/storage";
import {ElNotification} from "element-plus";

const tableData = ref([])
const params = ref({
  page: 1,
  pageSize: 50
})
const count = ref('')
const multipleSelection = ref([])
const courseDialogVisible = ref(false)
const dialogForm = ref({
  name: '',
  description: '',
  id: ''
})
const course1DialogVisible = ref(false)

const getPage = () => {
  axios.get('/api/course/page', {
    params: {
      page: params.value.page,
      pageSize: params.value.pageSize
    }
  }).then(res => {
    if (res.data.code === 200) {
      tableData.value = res.data.data.list
      count.value = res.data.data.count
    }
    if (res.data.code === 401) {
      storage.remove('isAuthenticated');
      router.push('/login')
    }
  })
}
const handleSizeChange = (val) => {
  params.value.pageSize = val
  getPage()
}
const courseDelete = (row) => {
  axios.get('/api/course/deleteCourse', {
    params: {
      id: row.id
    }
  }).then(res => {
    if (res.data.code === 200) {
      getPage();
      ElNotification({
        title: '删除成功',
        type: 'success'
      });
    } else {
      ElNotification({
        title: '删除失败',
        type: 'error'
      })
    }
  })
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
const creatCourse = () => {
  axios.post('/api/course/addCourse', JSON.parse(JSON.stringify({
    name: dialogForm.value.name,
    description: dialogForm.value.description
  }))).then(res => {
    console.log(res.data.code)
    if (res.data.code === 200) {
      getPage();
      ElNotification({
        title: '创建成功',
        type: 'success'
      });
    } else {
      ElNotification({
        title: '创建失败',
        type: 'error'
      })
    }
  })
}
const editCourse = (row) => {
  dialogForm.value.name = row.name
  dialogForm.value.description = row.description
  dialogForm.value.id = row.id
}
const primaryCourse = () => {
  axios.post('/api/course/updateCourse', JSON.parse(JSON.stringify({
    id: dialogForm.value.id,
    name: dialogForm.value.name,
    description: dialogForm.value.description
  }))).then(res => {
    getPage()
    console.log(res)
  })
}
onMounted(() => {
    getPage()
  })
</script>

<template>
  <div id="vue">
    <div class="header_div">
      <el-button type="primary" round @click="courseDialogVisible = true">创建课程</el-button>
    </div>
    <el-dialog v-model="courseDialogVisible"
               title="创建课程"
               width="500"
               align-center
               :close-on-click-modal="false"
               @closed="() =>  dialogForm = {}">
      <el-form :model="dialogForm">
        <el-form-item label="课程名称" :label-width="150">
          <el-input v-model="dialogForm.name" autocomplete="off" />
        </el-form-item>
        <el-form-item label="描述" :label-width="150">
          <el-input v-model="dialogForm.description" autocomplete="off" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="courseDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="courseDialogVisible = false; creatCourse()">
            创建
          </el-button>
        </div>
      </template>
    </el-dialog>
    <el-dialog v-model="course1DialogVisible"
               title="修改课程"
               width="500"
               align-center
               :close-on-click-modal="false"
               @closed="() =>  dialogForm = {}">
      <el-form :model="dialogForm">
        <el-form-item label="课程名称" :label-width="150">
          <el-input v-model="dialogForm.name" autocomplete="off" />
        </el-form-item>
        <el-form-item label="描述" :label-width="150">
          <el-input v-model="dialogForm.description" autocomplete="off" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="course1DialogVisible = false">取消</el-button>
          <el-button type="primary" @click="course1DialogVisible = false; primaryCourse()">
            修改
          </el-button>
        </div>
      </template>
    </el-dialog>
    <el-table
        :data="tableData"
        border
        stripe
        :header-cell-style="{textAlign: 'center'}"
        :cell-style="{ textAlign: 'center' }"
        @selection-change="handleSelectionChange"
        empty-text="没有数据">
      border
      style="width: 100%">
      <el-table-column
          type="index"
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
          <el-button link @click="courseDelete(scope.row)" type="primary" size="small">删除</el-button>
          <el-button link type="primary" size="small" @click="editCourse(scope.row);course1DialogVisible = true">编辑</el-button>
        </template>
      </el-table-column>
      <template v-slot:append>
        <div class="buttonDiv">
          <p>总共有{{ count }}条数据</p>
        </div>
      </template>
    </el-table>
    <div class="block">
      <el-pagination
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          :current-page="params.page"
          :page-sizes="[5, 10, 15, 20]"
          :page-size="params.pageSize"
          layout=""
          :total="count">
      </el-pagination>
    </div>
  </div>
</template>

<style scoped>
.header_div{
  height: 50px;
  display: flex;
  align-items: center;
}
.header_div > button {
  margin-right: 10px;
}
.buttonDiv {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 40px;
}
</style>