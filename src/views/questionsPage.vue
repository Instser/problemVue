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
const count = ref(1)
const multipleSelection = ref([])
const currentPage = ref(1)
const courseArr = ref([])
const folderArr = ref([])
const currentCourse = ref({
  courseName: '',
  courseId: ''
})
const search = ref('')
const isLoading = ref(false)
const fullHeight = ref(document.documentElement.clientHeight - 97)
const loading = ref(false)
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
      tableData.value.push(res.data.data[i])
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
      for (let i = 0; i < res.data.data.list.length; i++) {
        tableData.value.push(res.data.data.list[i])
      }
      console.log(res.data.data.list)
      console.log(tableData.value)
      count.value = res.data.data.count
      // 通过比较得知是否还有能加载的题目。
      isLoading.value = tableData.value.length < res.data.data.count;
      // 处理后将loading状态解锁
      loading.value = false
    }else{
      ElNotification({
        title: '未查询到您的课程',
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
  // 点击编辑后，携带获取到的题目id跳转到编辑页面
  router.push({path: '/edit', query: {id : row.id}})
}
const handleSelectionChange = (val) => {
  // 多选题目按钮
  multipleSelection.value = val
  console.log(multipleSelection.value)
}
const cancelEvent = (row) => {
  console.log(row.date)
}
const confirmEvent = (row) => {
  judgment(row)
  // 确认删除题目
  axios.post('/api/questions/delete', '',{
    params: {
      id: row.id
    }
  }
  ).then(res => {
    console.log(row.id)
    // 通过rowid直接删除tableData中的元素索引，然后移除
    const dataIndex = tableData.value.findIndex(item => item.id === row.id)
    if (dataIndex !== -1) {
      tableData.value.splice(dataIndex, 1)
    }
    console.log(res);
  })
}
const courseSelect = (courseItem) => {
  // 点击转换到其他课程
  console.log(courseItem.id)
  if (courseItem.id !== currentCourse.value.courseId) {
    currentCourse.value.courseName = courseItem.name;
    currentCourse.value.courseId = courseItem.id
    // 清除列表，然后加入新的课程的题目
    tableData.value = []
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
const judgment = (row) =>{
  console.log(row.row.index)
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
  <div>
    <el-dropdown>
      <el-button type="primary">
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
              :max-height="fullHeight">
      <el-table-column fixed type="selection" width='40' />
      <el-table-column fixed type="index" width="60" />
      <el-table-column prop="description" label="文件夹/题目" show-overflow-tooltip width="auto">
        <template v-slot="scope">
          <el-button link type="primary" @click="loadData">{{ scope.row.description}}</el-button>
        </template>
      </el-table-column>
      <el-table-column prop="quesCourStr" label="课程" />
      <el-table-column prop="types" label="题型" />
      <el-table-column prop="hard" sortable label="难易" />
      <el-table-column fixed="right">
        <template #header>
          <el-input v-model="search" size="small" placeholder="输入题目关键字" />
        </template>
        <template  #default="{ row }">
          <el-button link type="primary" size="small" @click="handleClick(row)">编辑</el-button>
          <el-popconfirm
              width="220"
              confirm-button-text="确定"
              cancel-button-text="取消"
              icon-color="#626AEF"
              title="您确定要删除吗？"
              @confirm="judgment(row)"
              @cancel="cancelEvent(row)"
          >
            <template #reference>
              <el-button link type="primary" size="small">删除</el-button>
            </template>
          </el-popconfirm>
        </template>
      </el-table-column>
      <template v-slot:append>
        <div class="buttonDiv">
          <el-button style="" :loading="loading" :disabled="loading" v-if="isLoading" @click="loadData" link type="primary" size="large">加载题目</el-button>
        </div>
      </template>
    </el-table>
    <div class="demo-pagination-block">
      <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageParams.pageSize"
          :page-sizes="[10]"
          :background="true"
          layout=""
          :total="count"
      />
    </div>
  </div>
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