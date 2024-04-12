<script setup>
import {onBeforeUnmount, ref} from "vue";
import axios from "axios";
import router from "@/router/router";
import {ArrowDown} from "@element-plus/icons-vue";
import {ElNotification} from "element-plus";
import {storage} from "@/storage/storage";

const tableData = ref([])
const pageParams = ref({
  page: 1,
  pageSize: 20
})
const count = ref()
const folderCount = ref(0)
const multipleSelection = ref({
  folderList: [],
  questionList: []
})
const currentPage = ref(1)
const courseArr = ref([])
const folderArr = ref([])
const questionArr = ref([])
const currentCourse = ref({
  courseName: '',
  courseId: ''
})
const search = ref('')
const isLoading = ref(false)
const fullHeight = ref(document.documentElement.clientHeight - 97)
const loading = ref(false)
const dialogFormVisible = ref(false)
const dialogForm = ref({
  name: '',
  desc: '',
  courseId: ''
})
/*
@params
 */
const getCourse = async () => {
  await axios.get('api/course/getAll').then(res => {
    console.log(res.data)
    if (res.data.code === 401) {
      storage.remove('isAuthenticated');
      router.push('/login')
    }
    if (res.data.code === 200) {
      courseArr.value = res.data.data;
      currentCourse.value.courseName = res.data.data[0].name
      currentCourse.value.courseId = res.data.data[0].id
      console.log(currentCourse.value)
    }
  })
}
const getFolder = async () => {
  await axios.get('/api/quesFolder/getFolder').then(res => {
    folderArr.value = res.data.data
    for (let i = 0; i < res.data.data.length; i++) {
      // 为文件夹对象添加description属性，传入tableData中
      res.data.data[i].description = res.data.data[i].name
      // 添加children属性来实现树形表格加载文件夹下的题目
      res.data.data[i].children = true
      tableData.value.push(res.data.data[i])
      folderCount.value++
      console.log(res.data.data[i])
    }
  })
}
const loadData = async () => {
  loading.value = true
  axios.post('/api/questions/page', JSON.parse(JSON.stringify({
        page: pageParams.value.page,
        pageSize: pageParams.value.pageSize,
        filterKey: 'ques_cour',
        filterValue: [currentCourse.value.courseId],
      }))
  ).then(res => {
    if (res.data.code === 401) {
      storage.remove('isAuthenticated');
      router.push('/login')
    }
    if (res.data.code === 200) {
      pageParams.value.page++
      // 将返回的数据遍历push到tableData
      questionArr.value = res.data.data.list
      console.log(questionArr.value)
      for (let i = 0; i < res.data.data.list.length; i++) {
        tableData.value.push(res.data.data.list[i])
      }
      console.log(res.data.data.list)
      console.log(tableData.value)
      console.log(res.data.data.count + folderArr.value.length)
      count.value = res.data.data.count + folderArr.value.length
      // 通过比较得知是否还有能加载的题目,加上文件夹数量，不然会漏题。
      isLoading.value = tableData.value.length < res.data.data.count + folderArr.value.length;
      // 处理后将loading状态解锁
      loading.value = false
    }else if (storage.get('isAuthenticated')){
      ElNotification({
        title: '未查询到该课程的题目',
        type: 'warning',
        duration: 0
      });
      loading.value = false
    }
  }).catch(e => {
    console.log(e)
  });
}

const handleClick = (row) => {
  // 判断是题目还是文件夹
  if (row.foldDesc) {
    return;
  } else {
    // 点击编辑后，携带获取到的题目id跳转到编辑页面
    router.push({path: '/edit', query: {id : row.id}})
  }

}
const handleSelectionChange = (val) => {
  // 重置多选数据列表
  multipleSelection.value = {
    folderList: [],
    questionList: []
  }
  // 判断item类型，然后分别加入题目或者文件夹数组
  for (let i = 0; i < val.length; i++) {
    if (val[i].foldDesc) {
      multipleSelection.value.folderList.push(val[i]);
    } else {
      multipleSelection.value.questionList.push(val[i]);
    }
  }
  console.log("多选列表")
  console.log(multipleSelection.value)
}
const cancelEvent = () => {
  console.log(multipleSelection.value.folderList.map(folder => folder.id).join(','))
}
const deleteEvent = () => {
  const folderIdArr = ref(multipleSelection.value.folderList.map(folder => folder.id))
  const questionIdArr = ref(multipleSelection.value.questionList.map(question => question.id))
  console.log(questionIdArr.value)
  if (folderIdArr.value[0]) {
    console.log('有文件夹删除')
    axios.post('/api/quesFolder/deletedFolder', '',{
      params: {
        id: folderIdArr.value.join(',')
      }
    }).then(() => {
      for (let i = 0; i < folderIdArr.value.length; i++) {
        const dataIndex = tableData.value.findIndex(item => item.id === folderIdArr.value[i])
        console.log(dataIndex)
        // 过滤到相同id的题目，只删除文件夹
        if (dataIndex !== -1 && tableData.value[dataIndex].name) {
          tableData.value.splice(dataIndex, 1)
        }
      }
    })
  }
  axios.post('/api/questions/delete', '',{
        params: {
          id: questionIdArr.value.join(',')
        }
      }
  ).then(() => {
    // 通过table索引移除
    for (let i = 0; i < questionIdArr.value.length; i++) {
      const dataIndex = tableData.value.findIndex(item => item.id === questionIdArr.value[i])
      console.log(dataIndex)
      // 过滤到相同id的文件夹，只删除题目
      if (dataIndex !== -1 && !tableData.value[dataIndex].name) {
        tableData.value.splice(dataIndex, 1)
      }
    }
  });

}
const courseSelect = (courseItem) => {
  // 点击转换到其他课程
  console.log(courseItem.id)
  if (courseItem.id !== currentCourse.value.courseId) {
    currentCourse.value.courseName = courseItem.name;
    currentCourse.value.courseId = courseItem.id
    // 清除列表，然后加入新的课程的题目
    pageParams.value.page = 1
    tableData.value = []
    getFolder()
    loadData()
  }
}
const creatEventListener = () => {
  window.addEventListener('resize', handleResize)
}
const handleResize= () => {
  //获取窗口高度
  fullHeight.value = document.documentElement.clientHeight - 97
}

onBeforeUnmount(() =>{
  window.removeEventListener('resize', handleResize)
});
creatEventListener();
getFolder();
// 通过异步的await保证先获取课程再获取题目
(async () => {
  try {
    await getCourse();
    await loadData();
  } catch (e) {
    console.log('初始化课程、题目数据错误', e)
  }
})();
</script>

<template>
  <div class="mb-4">
    <el-button type="primary" round @click="dialogFormVisible = true">创建文件夹</el-button>
    <el-button round icon="Delete" @click="deleteEvent">批量删除</el-button>
    <el-dropdown>
      <el-button round>
        {{ currentCourse.courseName }}
        <el-icon class="el-icon--right">
          <arrow-down />
        </el-icon>
      </el-button>
      <template #dropdown>
        <el-dropdown-menu>
          <el-dropdown-item v-for="courseItem in courseArr" :key = 'courseItem.id' @click="courseSelect(courseItem)"> {{ courseItem.name }}</el-dropdown-item>
        </el-dropdown-menu>
      </template>
    </el-dropdown>
  </div>
  <div>
    <el-table :data="tableData"
              style="width: 100%"
              table-layout="auto"
              @selection-change="handleSelectionChange"
              :header-cell-style="{textAlign: 'center'}"
              :cell-style="{ textAlign: 'center' }"
              empty-text="没有数据"
              :max-height="fullHeight"
              lazy
              row-key="index"
              :load
              :tree-props="{ children: 'children', hasChildren: 'hasChildren' }">
      <el-table-column fixed type="selection" width='40' />
      <el-table-column fixed type="index" width="60" label="序号"/>
      <el-table-column prop="description" label="文件夹/题目" show-overflow-tooltip width="auto">
        <template v-slot="scope">
          <el-button link type="primary" @click="handleClick(scope.row)">{{ scope.row.description}}</el-button>
        </template>
      </el-table-column>
      <el-table-column prop="quesCourStr" label="课程" />
      <el-table-column prop="types" label="题型" />
      <el-table-column prop="hard" sortable label="难易" />
      <el-table-column fixed="right">
        <template #header>
          <el-input v-model="search" size="small" placeholder="输入题目关键字" />
        </template>
        <template  #default="{ row, $index }">
<!--          <el-button link type="primary" size="small" @click="handleClick(row)">编辑</el-button>-->
          <el-popconfirm
              width="220"
              confirm-button-text="确定"
              cancel-button-text="取消"
              icon-color="#626AEF"
              title="您确定要删除吗？"
              @confirm="deleteEvent(row, $index)"
              @cancel="cancelEvent"
          >
            <template #reference>
              <el-button link type="primary" size="small">删除</el-button>
            </template>
          </el-popconfirm>
        </template>
      </el-table-column>
      <template v-slot:append>
        <div class="buttonDiv">
          <p>总共有{{ count }}条数据</p>
          <el-button style="" :loading="loading" :disabled="loading" v-if="isLoading" @click="loadData" link type="primary" size="large">加载题目</el-button>
        </div>
      </template>
    </el-table>
    <div class="demo-pagination-block">
      <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageParams.pageSize"
          :page-sizes="[20]"
          :background="true"
          layout=""
          :total="count"
      />
    </div>
  </div>
  <el-dialog v-model="dialogFormVisible"
             title="创建文件夹"
             width="500"
             align-center
             :close-on-click-modal="false"
              @closed="() =>  dialogForm = {}">
    <el-form :model="dialogForm">
      <el-form-item label="文件夹名" :label-width="150">
        <el-input v-model="dialogForm.name" autocomplete="off" />
      </el-form-item>
      <el-form-item label="课程" :label-width="150">
        <el-select v-model="dialogForm.courseId" placeholder="选择课程">
          <el-option v-for="item in courseArr" :label="item.name" :key="item.id" :value="item.id" />
        </el-select>
      </el-form-item>
    </el-form>
    <template #footer>
      <div class="dialog-footer">
        <el-button @click="dialogFormVisible = false">取消</el-button>
        <el-button type="primary" @click="dialogFormVisible = false;">
          创建
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
.input-with-select .el-input-group__prepend {
  background-color: var(--el-fill-color-blank);
}
.buttonDiv {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 40px;
}
</style>