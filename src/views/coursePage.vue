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
const teacherDialogVisible =ref(false)
const teacherForm = ref([])
const inputVisible =  ref(false)
const inputValue = ref('')

const getPage = () => {
  axios.get('http://8.210.230.249:8888/course/page', {
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
  axios.get('http://8.210.230.249:8888/course/deleteCourse', {
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
  axios.post('http://8.210.230.249:8888/course/addCourse', JSON.parse(JSON.stringify({
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
  axios.post('http://8.210.230.249:8888/course/updateCourse', JSON.parse(JSON.stringify({
    id: dialogForm.value.id,
    name: dialogForm.value.name,
    description: dialogForm.value.description
  }))).then(res => {
    getPage()
    console.log(res)
  })
}
const editTeacher = (row) => {
  if (row.teaNamesStr)
    teacherForm.value = row.teaNamesStr.split(',')
}
const handleInputConfirm = () => {
  if (inputValue.value) {
    teacherForm.value.push(inputValue.value)
  }
  inputVisible.value = false
  inputValue.value = ''
}
const showInput = () => {
  inputVisible.value = true
}
const removeTeacher = (teacher) => {
  // axios.post('/api/teaCour/quitCourse',JSON.parse(JSON.stringify({
  //   userId: '',
  //   courseId: ''
  // })))
  teacherForm.value = teacherForm.value.filter(item => item !== teacher);

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
    <el-dialog v-model="teacherDialogVisible"
               title="管理任课老师"
               width="500"
               align-center
               :close-on-click-modal="false"
               @closed="() =>  teacherForm = []">
      <el-form :model="teacherForm">
        <el-form-item label="任课老师">
          <span
              style="margin: 0 5px 0 0"
              v-for="(item, index) in teacherForm"
              :key="item.id"
          >
            <el-tooltip :content="item" placement="top">
              <el-tag
                  :closable="true"
                  :disable-transitions="false"
                  @close="removeTeacher(item)"
                  :type="'success'"
            >
             {{ index + 1 }}. {{ item }}
            </el-tag>
            </el-tooltip>
          </span>
          <el-input
              v-if="inputVisible"
              v-model="inputValue"
              class="w-20"
              size="small"
              @keyup.enter="handleInputConfirm"
          />
          <el-button v-else class="button-new-tag" size="small" @click="showInput">
            + 添加老师
          </el-button>
        </el-form-item>
      </el-form>
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
          <el-button link type="primary" size="small" @click="editTeacher(scope.row);teacherDialogVisible = true">任课老师</el-button>
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
/deep/ .el-tag {
  display: flex; /* 使用 flex 布局 */
  align-items: center; /* 垂直居中子元素 */
  justify-content: space-between; /* 子元素间隔均匀 */
  max-width: 150px; /* 限制最大宽度 */
  overflow: hidden; /* 隐藏溢出内容 */
}

/deep/ .el-tag .el-tag__content {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  flex-grow: 1; /* 允许文本内容区域自动填充空间 */
}

/deep/ .el-tag .el-tag__close {
  flex-shrink: 0; /* 防止关闭按钮压缩 */
  margin-left: 8px; /* 为关闭按钮和文本提供一些间隔 */
}
</style>