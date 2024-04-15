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
const count = ref() // 数据库中当前课程下的文件夹和所有题目的总数据
const currenCount = ref() // 数当前table中的数据数量
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
const fullHeight = ref(document.documentElement.clientHeight - 110)
const loading = ref(false)
const folderDialogVisible = ref(false)
const dialogForm = ref({
  name: '',
  desc: '',
  courseId: ''
})
const tableRef = ref(null)
const testForm = ref({
  subject: '',
  class: '',
  time: '',
  yearStart: '',
  yearEnd: '',
  term: '',
  number: '',
  open: '',
  exam: '',
  mingTi: '',
  shenTi: '',
  shenHe: '',
  shenPi: ''
})
const testArr = ref([])
const testFormVisible = ref(false)
const rules = {
  subject: [
    {
      required: true,
      message: '请输入考试名称',
      trigger: 'blur'
    },
  ],
  class: [
    {
      required: true,
      message: '请选择班级',
      trigger: 'change',
    },
  ],
  time: [
    {
      required: true,
      message: '请输入考试时长',
      trigger: 'change',
    },
  ],
  yearStart: [
    {
      type: 'date',
      required: true,
      message: '请选择起始年份',
      trigger: 'change',
    },
  ],
  yearEnd: [
    {
      type: 'date',
      required: true,
      message: '请选择结束年份',
      trigger: 'change',
    },
  ],
  number: [
    {
      required: true,
      message: '请输入章节',
      trigger: 'change'
    }
  ],
  term: [
    {
      required: true,
      message: '请输入学期',
      trigger: 'change',
    }
  ],
  open: [
    {
      required: true,
      message: 'Please select a location',
      trigger: 'change',
    },
  ],
  exam: [
    {
      required: true,
      message: '请选择考试类型',
      trigger: 'change',
    },
  ],
  resource: [
    {
      required: true,
      message: 'Please select activity resource',
      trigger: 'change',
    },
  ],
  desc: [
    { required: true, message: 'Please input activity form', trigger: 'blur' },
  ],
}
const typeDescArr = ref({
  selectDesc: '',
  gapDesc: '',
  answerDesc: '',
  proveDesc: ''
})
const addToFolderVisible = ref(false)
const addToFolderForm = ref({
  folderId: ''
})

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
} // 加载课程数据
const getFolder = async () => {
  folderArr.value = []
  await axios.get('/api/quesFolder/getFolder').then(res => {
    folderArr.value = res.data.data
    for (let i = 0; i < folderArr.value.length; i++) {
      // 为文件夹对象添加description属性，传入tableData中
      folderArr.value[i].description = res.data.data[i].name
      // 添加children属性来实现树形表格加载文件夹下的题目
      folderArr.value[i].hasChildren = true
      // 根据table中的元素数量设置唯一索引
      folderArr.value[i].index = tableData.value.length + 1
      tableData.value.push(res.data.data[i])
      currenCount.value++
      console.log(res.data.data[i])
    }
  })
} //加载文件及数据
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
      // 将获取的题目数据全部传入题目数组
      questionArr.value = res.data.data.list
      // 将返回的数据遍历push到tableData,判断是否有题目
      console.log(questionArr.value)
      if (questionArr.value) {
        for (let i = 0; i < questionArr.value.length; i++) {
          questionArr.value[i].index = tableData.value.length + 1
          tableData.value.push(questionArr.value[i])
        }
      }
      // 记录数据库中所有题目加上文件夹的数目
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
} // 加载题目数据
const freshTable = () => {
  // 清空table
  tableData.value = []
  multipleSelection.value.questionList = []
  multipleSelection.value.folderList = []
  getFolder()
  // 重置page参数
  pageParams.value.page = 1
  loadData()
}  // 刷新table内容
const handleClick = (row) => {
  // 判断是题目还是文件夹,文件夹就打开文件夹编辑。题目就跳转到edit
  if (row.foldDesc) {
    // 是文件夹就传入id进行懒加载子数据
    // lazyLoadQuestion(row);

  } else {
    // 点击编辑后，携带获取到的题目id跳转到编辑页面
    router.push({path: '/edit', query: {id : row.id}})
  }

} //点击题目/文件夹，判断跳转
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
}//多选逻辑
const addToFolder = () => {
  const questionIdArr = ref(multipleSelection.value.questionList.map(question => question.id))
  console.log(questionIdArr.value)
  if (questionIdArr.value[0]) {
    axios.post('/api/folder_ques_list/moveToFolder', '', {
          params: {
            folderId: addToFolderForm.value.folderId,
            quesIds: questionIdArr.value.join(',')
          }
        }
    ).then(res => {
      if (res.data.code === 200) {
        ElNotification({
          title: '试题添加成功',
          type: 'success'
        });
        multipleSelection.value.questionList = []
        freshTable()
      } else {
        ElNotification({
          title: '试题添加失败',
          type: 'error'
        })
      }
    })
  }
} //将题目批量添加至文件夹
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
    }).then(res => {
      if (res.data.code === 200) {
        for (let i = 0; i < folderIdArr.value.length; i++) {
          const dataIndex = tableData.value.findIndex(item => item.id === folderIdArr.value[i])
          console.log(dataIndex)
          // 过滤到相同id的题目，只删除文件夹
          if (dataIndex !== -1 && tableData.value[dataIndex].name) {
            tableData.value.splice(dataIndex, 1)
            count.value--
          }
        }
        ElNotification({
          title: '文件夹删除成功',
          type: 'success'
        });
        // 重置文件夹多选列表
        multipleSelection.value.folderList = [];
      } else {
        ElNotification({
          title: '文件夹删除失败',
          type: 'error'
        });
      }
    })
  }
  if (questionIdArr.value[0]) {
    axios.post('/api/questions/delete', '',{
          params: {
            id: questionIdArr.value.join(',')
          }
        }
    ).then(res => {
      // 通过table索引移除
      if (res.data.code === 200) {
        for (let i = 0; i < questionIdArr.value.length; i++) {
          const dataIndex = tableData.value.findIndex(item => item.id === questionIdArr.value[i])
          console.log(dataIndex)
          // 过滤到相同id的文件夹，只删除题目
          if (dataIndex !== -1 && !tableData.value[dataIndex].name) {
            tableData.value.splice(dataIndex, 1)
            count.value--
          }
        }
        ElNotification({
          title: '题目删除成功',
          type: 'success'
        });
      } else {
        ElNotification({
          title: '题目删除失败',
          type: 'error'
        })
      }
      // 重置id列表
      multipleSelection.value.questionList = [];
    })
  }
} //批量删除逻辑
const courseSelect = async (courseItem) => {
  // 点击转换到其他课程
  console.log(courseItem.id)
  if (courseItem.id !== currentCourse.value.courseId) {
    currentCourse.value.courseName = courseItem.name;
    currentCourse.value.courseId = courseItem.id
    // 清除列表，然后加入新的课程的题目
    pageParams.value.page = 1
    tableData.value = []
    // 使用await防止获取顺序出错导致table数量统计不准确
    try {
      await getFolder()
      await loadData();
    } catch (e) {
      console.log(e)
    }
  }
} // 切换课程并获取文件夹和题目
const creatEventListener = () => {
  window.addEventListener('resize', handleResize)
} //设置页面大小监听器
const handleResize= () => {
  fullHeight.value = document.documentElement.clientHeight - 110
} //获取窗口高度
const lazyLoadQuestion = (row, treeNode, resolve) => {
  console.log(row.id)
  // 通过文件夹id获取到题目后，将返回去数据插入文件夹对象的children数组中
  axios.post('/api/questions/page', JSON.parse(JSON.stringify({
    page: 1,
    pageSize: 100,
    folderId: row.id
  }))).then(res => {
    console.log(res.data.data.list)
    if (res.data.data.list) {
      let i = 1
      // eslint-disable-next-line no-unused-vars
      res.data.data.list.forEach((item, index) => {
        item.index = row.index + '-' + i++
      })
      tableData.value[row.index - 1].childrenList = res.data.data.list
      resolve(res.data.data.list);
    } else {
      resolve([{}])
    }
    console.log(tableData.value);
  })
} //点击文件夹懒加载题目
const creatFolder = () => {
  axios.post('/api/quesFolder/creatFolder', null, {
    params: dialogForm.value
    // eslint-disable-next-line no-unused-vars
  }).then(res => {
    freshTable()
  })
}
// watch(search, (newval, oldValue) => {
//   tableRef.value.filter(newval)
// })
const addTest = (row) =>{
  console.log(typeof row.index)
  console.log(row.index)
  // 判断数据的index是number还是string，以此确定是不是子数据。
  if (typeof row.index === "number") {
    // number是外围题目，直接加入test数组中。

    tableData.value[row.index - 1].inTest = true
    testArr.value.push(tableData.value[row.index - 1]);
  }

  if (typeof row.index === "string") {
    // string是文件夹中的题目，获得位置再添加。
    let indexArr = row.index.split('-')
    // 一元加号运算符:  +indexArr[0]  可以使indexArr[0]的类型转化为number
    let question = tableData.value[+indexArr[0] - 1].childrenList[+indexArr[1] - 1]
    // 标记题目被加入组卷数组中。
    tableData.value[+indexArr[0] - 1].childrenList[+indexArr[1] - 1].inTest = true
    testArr.value.push(question)
  }
  console.log(testArr.value.findIndex(item => item.typeName === '1'))
  console.log(testArr.value)
}//  将选中的试题加入组件列表中
const removeTest = (row) => {
  // 获取id，删除
  testArr.value = testArr.value.filter(item => item.id !== row.id);
  if (typeof row.index === "string") {
    let indexArr = row.index.split('-')
    tableData.value[+indexArr[0] - 1].childrenList[+indexArr[1] - 1].inTest = false
  }
  if (typeof row.index === "number") {
    tableData.value[row.index - 1].inTest = false;
  }
  console.log(testArr.value)
} // 将不需要的试题移除组卷列表
const creatTest = () => {
  //  根据testArr中的题目情况，像请求参数中添加题目。
  let list = []
  if (testArr.value.findIndex(item => item.types === '选择题') !== -1) {
    console.log('push11')
    list.push({
      typeName: '选择题',
      "typeDesc": typeDescArr.value.selectDesc,
      "quesId": testArr.value.filter(item => item.types === '选择题').map(item => item.id)
    })
  }
  if (testArr.value.findIndex(item => item.types === '填空题') !== -1) {
    console.log('push22')
    list.push({
      "typeName": "填空题",
      "typeDesc": typeDescArr.value.gapDesc,
      "quesId": testArr.value.filter(item => item.types === '填空题').map(item => item.id)
    })
  }
  if (testArr.value.findIndex(item => item.types === '简答题') !== -1) {
    console.log('push33')
    list.push({
      "typeName": "计算题",
      "typeDesc": typeDescArr.value.answerDesc,
      "quesId": testArr.value.filter(item => item.types === '简答题').map(item => item.id)
    })
  }
  if (testArr.value.findIndex(item => item.types === '证明题') !== -1) {
    console.log('push44')
    list.push({
      "typeName": "证明题",
      "typeDesc": typeDescArr.value.proveDesc,
      "quesId": testArr.value.filter(item => item.types === '证明题').map(item => item.id)
    })
  }
  console.log(list)
  axios.post('/api/questions/buildTest', JSON.parse(JSON.stringify({
    title: testForm.value,
    list: list
  }))).then(res => {
    if (res.data.code === 200) {
      ElNotification({
        title: '试卷组建成功',
        type: 'success'
      });
    } else {
      ElNotification({
        title: '试卷组建失败',
        type: 'error'
      })
    }
  });
}// 生成试卷
const clearTest = () => {
  testArr.value.forEach((item) => {
    removeTest(item)
  })
} //点击清空组卷列表中的试题
const onStart = () => {
  return
}
const onEnd = () => {
  return
}


onBeforeUnmount(() =>{
  window.removeEventListener('resize', handleResize)
});// 组件销毁前解除监听释放内存

creatEventListener(); // 页面创建时开始监听页面高度

// 通过异步的await保证先获取课程再获取文件夹和题目
(async () => {
  try {
    await getCourse();
    await getFolder()
    await loadData();
  } catch (e) {
    console.log('初始化课程、题目数据错误', e)
  }
})();
</script>

<template>
  <div class="header_div">
    <el-button type="primary" round @click="folderDialogVisible = true">创建文件夹</el-button>
    <el-button type="primary" round @click="() => router.push('/edit')">创建试题</el-button>
    <el-button  round icon="CopyDocument" @click="addToFolderVisible = true">添加试题到文件夹</el-button>
    <el-button  round icon="Delete" @click="deleteEvent">批量删除</el-button>
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
    <el-col :span="6">
      <el-statistic title="已选题目" :value="testArr.length" />
    </el-col>
    <el-button type="primary" @click="testFormVisible = true"
    >创建试卷
    </el-button>
    <el-button type="primary" @click="clearTest()"
    >清空已选择试题
    </el-button>
  </div>
  <div>
    <el-table :data="tableData"
              :ref="tableRef"
              stripe
              border
              style="width: 100%"
              table-layout="auto"
              @selection-change="handleSelectionChange"
              v-model:aria-selected="multipleSelection"
              empty-text="没有数据"
              :max-height="fullHeight"
              lazy
              row-key="index"
              :load="lazyLoadQuestion"
              :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
              >
      <el-table-column fixed type="selection" width='40' />
      <el-table-column fixed type="index" width="auto"/>
      <el-table-column prop="description" label="文件夹/题目"  show-overflow-tooltip min-width="600">
        <template v-slot="scope">
          <span>{{ scope.row.description}}</span>
        </template>
      </el-table-column>
      <el-table-column prop="quesCourStr" label="课程"></el-table-column>
      <el-table-column prop="types" label="题型" sortable/>
      <el-table-column prop="hard" sortable label="难易" />
      <el-table-column fixed="right" min-width="160">
        <template #header>
          <el-input v-model="search" size="small" placeholder="输入题目关键字" />
        </template>
        <template  #default="{ row, $index }">
          <el-button link type="primary" size="small" @click="handleClick(row)">编辑</el-button>
          <el-button link type="primary" size="small" @click="addTest(row)" v-if="!row.hasChildren && row.description && !row.inTest">加入试卷</el-button>
          <el-button link type="primary" size="small" @click="removeTest(row)" v-if="!row.hasChildren && row.description && row.inTest === true">移出试卷</el-button>
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
  <el-dialog v-model="folderDialogVisible"
             title="创建文件夹"
             width="500"
             align-center
             :close-on-click-modal="false"
              @closed="() =>  dialogForm = {}">
    <el-form :model="dialogForm">
      <el-form-item label="文件夹名" :label-width="150">
        <el-input v-model="dialogForm.name" autocomplete="off" />
      </el-form-item>
      <el-form-item label="描述" :label-width="150">
        <el-input v-model="dialogForm.desc" autocomplete="off" />
      </el-form-item>
      <el-form-item label="课程" :label-width="150">
        <el-select v-model="dialogForm.courseId" placeholder="选择课程">
          <el-option v-for="item in courseArr" :label="item.name" :key="item.id" :value="item.id" />
        </el-select>
      </el-form-item>
    </el-form>
    <template #footer>
      <div class="dialog-footer">
        <el-button @click="folderDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="folderDialogVisible = false; creatFolder()">
          创建
        </el-button>
      </div>
    </template>
  </el-dialog>
  <el-dialog v-model="addToFolderVisible"
             title="批量添加选中的试题到文件夹"
             width="500"
             align-center
             :close-on-click-modal="false"
              @closed="() =>  addToFolderForm = {}">
    <el-form :model="addToFolderForm">
      <el-form-item label="文件夹" :label-width="150">
        <el-select v-model="addToFolderForm.folderId" placeholder="选择文件夹">
          <el-option v-for="item in folderArr" :label="item.name" :key="item.id" :value="item.id" />
        </el-select>
      </el-form-item>
    </el-form>
    <template #footer>
      <div class="dialog-footer">
        <el-button @click="addToFolderVisible = false">取消</el-button>
        <el-button type="primary" @click="addToFolderVisible = false; addToFolder()">
          确定
        </el-button>
      </div>
    </template>
  </el-dialog>
  <el-dialog v-model="testFormVisible"
             title="创建试卷"
             width="800"
             :close-on-click-modal="false"
             @closed="() =>  dialogForm = {}">
    <el-form
        style="max-width: 600px"
        :model="testForm"
        :rules="rules"
        label-width="auto"
        class="demo-ruleForm"
        :size="'default'"
        status-icon
    >
      <el-form-item label="试卷科目" prop="subject">
        <el-input v-model="testForm.subject" />
      </el-form-item>
      <el-form-item label="班级" prop="class">
        <el-input v-model="testForm.class" />
      </el-form-item>
      <el-form-item label="考试时长" prop="time">
        <el-input v-model="testForm.time" />
      </el-form-item>
      <el-form-item label="章节" prop="number">
        <el-input v-model="testForm.number" />
      </el-form-item>
      <el-form-item label="学年" required>
        <el-col :span="11">
          <el-form-item prop="yearStart">
            <el-date-picker
                v-model="testForm.yearStart"
                type="year"
                label="选择起始年份"
                placeholder="选择起始年份"
                value-format="YYYY"
                style="width: 100%"
            />
          </el-form-item>
        </el-col>
        <el-col class="text-center" :span="2">
          <span class="text-gray-500">-</span>
        </el-col>
        <el-col :span="11">
          <el-form-item prop="yearEnd">
            <el-date-picker
                v-model="testForm.yearEnd"
                type="year"
                label="选择结束年份"
                placeholder="选择结束年份"
                value-format="YYYY"
                style="width: 100%"
            />
          </el-form-item>
        </el-col>
      </el-form-item>
      <el-form-item label="学期" prop="term">
        <el-input v-model="testForm.term" />
      </el-form-item>
      <el-form-item label="开/闭卷" prop="open">
        <el-radio-group v-model="testForm.open">
          <el-radio-button label="开卷" value="开卷" />
          <el-radio-button label="闭卷" value="闭卷" />
        </el-radio-group>
      </el-form-item>
      <el-form-item label="考试类型" prop="exam">
        <el-radio-group v-model="testForm.exam">
          <el-radio-button label="考试" value="考试" />
          <el-radio-button label="考察" value="考察" />
        </el-radio-group>
      </el-form-item>
      <el-form-item label="命题老师" prop="mingTi">
        <el-input v-model="testForm.mingTi" placeholder="输入命题老师" clearable />
      </el-form-item>
      <el-form-item label="审题老师" prop="shenTI">
        <el-input v-model="testForm.shenTi" placeholder="输入审题老师" clearable />
      </el-form-item>
      <el-form-item label="审核老师" prop="mingTi">
        <el-input v-model="testForm.shenHe" placeholder="输入审核老师" clearable />
      </el-form-item>
      <el-form-item label="审批老师" prop="shenPi">
        <el-input v-model="testForm.shenPi" placeholder="输入审批老师" clearable />
      </el-form-item>
      <el-form-item label="选择题" prop="question1" v-if="testArr.findIndex(item => item.types === '选择题') !== -1">
        <el-input v-model="typeDescArr.selectDesc" placeholder="输入选择题描述，如：一、总共五题，每题3分" clearable />
        <span
            style="margin: 0 5px 0 0"
            v-for="(item, index) in testArr.filter(q => q.types === '选择题')"
            :key="item.id"
        >
          <el-tooltip :content="item.description" placement="top">
            <el-tag
                :closable="true"
                :disable-transitions="false"
                @close="removeTest(item)"
                :type="'success'"
            >
            {{ index + 1 }}. {{ item.description }}
          </el-tag>
          </el-tooltip>
        </span>
      </el-form-item>
      <el-form-item label="填空题" prop="question1" v-if="testArr.findIndex(item => item.types === '填空题') !== -1">
        <el-input v-model="typeDescArr.gapDesc" placeholder="输入填空题描述，如：二、总共六题，每题3分" clearable />
        <span
            style="margin: 0 5px 0 0"
            v-for="(item, index) in testArr.filter(q => q.types === '填空题')"
            :key="item.id"
        >
          <el-tooltip :content="item.description" placement="top">
            <el-tag
                :closable="true"
                :disable-transitions="false"
                @close="removeTest(item)"
                :type="'success'"
            >
            {{ index + 1 }}. {{ item.description }}
          </el-tag>
          </el-tooltip>
        </span>
      </el-form-item>
      <el-form-item label="简答题" prop="question1" v-if="testArr.findIndex(item => item.types === '简答题') !== -1">
        <el-input v-model="typeDescArr.answerDesc" placeholder="输入简答题描述，如：三、总共三题，每题10分" clearable />
        <span
            style="margin: 0 5px 0 0"
            v-for="(item, index) in testArr.filter(q => q.types === '简答题')"
            :key="item.id"
        >
          <el-tooltip :content="item.description" placement="top">
            <el-tag
                :closable="true"
                :disable-transitions="false"
                @close="removeTest(item)"
                :type="'success'"
            >
            {{ index + 1 }}. {{ item.description }}
          </el-tag>
          </el-tooltip>
        </span>
      </el-form-item>
      <el-form-item label="证明题" prop="question1" v-if="testArr.findIndex(item => item.types === '证明题') !== -1">
        <el-input v-model="typeDescArr.proveDesc" placeholder="输入证明题描述，四、总共两题，每题10分" clearable />
        <span
            style="margin: 0 5px 0 0"
            v-for="(item, index) in testArr.filter(q => q.types === '证明题')"
            :key="item.id"
        >
          <el-tooltip :content="item.description" placement="top">
            <el-tag
                :closable="true"
                :disable-transitions="false"
                @close="removeTest(item)"
                :type="'success'"
            >
            {{ index + 1 }}. {{ item.description }}
          </el-tag>
          </el-tooltip>
        </span>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="testFormVisible = false; creatTest()">
          创建
        </el-button>
        <el-button @click="testFormVisible = false">取消</el-button>
      </el-form-item>
    </el-form>
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
/deep/ .el-table__placeholder {
  display: none
}
.header_div{
  height: 50px;
  display: flex;
  align-items: center;
}
.header_div > button {
  margin-right: 10px;
}
.el-col {
  margin-left: auto;
  text-align: center;
}
/deep/ .el-statistic {
  width: 80px;
  margin-left: auto;
}
.ghost {
  border: solid 1px rgb(19, 41, 239);
}
.chosenClass {
  background-color: #f1f1f1;
}
/deep/ .el-tag {
  display: flex;
  align-items: center;
  justify-content: space-between;
  max-width: 150px;
  overflow: hidden;
}

/deep/ .el-tag .el-tag__content {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  flex-grow: 1;
}

/deep/ .el-tag .el-tag__close {
  flex-shrink: 0;
  margin-left: 8px;
}
</style>