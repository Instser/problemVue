<script setup>
import {onBeforeUnmount, ref, unref} from "vue";
import axios from "axios";
import router from "@/router/router";
import {ArrowDown, Search, Folder, Edit, Document, Delete, RemoveFilled, Reading, Plus, Remove, Bottom, InfoFilled, Select, Loading, CircleCheckFilled, Download, CopyDocument} from "@element-plus/icons-vue";
import {ElNotification, ElMessageBox} from "element-plus";
import {storage} from "@/storage/storage";
import draggable from 'vue-draggable-next';
import activityService from "@/services/activityService";

const tableData = ref([])
const pageParams = ref({
  page: 1,
  pageSize: 20
}) // 试题分页信息
const count = ref() // 数据库中当前课程下的文件夹和所有题目的总数据
const currenCount = ref() // 数当前table中的数据数量
const multipleSelection = ref({
  folderList: [],
  questionList: []
}) // 多选试题或者文件夹数据
// 不再需要分页，移除currentPage
// const currentPage = ref(1) // table的当前页面
const courseArr = ref([]) // 该教师所有课程数据
const folderArr = ref([]) // 当前页面文件夹数据
const questionArr = ref([]) // 当前页面试题数据
const currentCourse = ref({
  courseName: '',
  courseId: ''
}) // 当前课程的数据
const search = ref('') // 搜索框的数据
const isLoading = ref(false) // 判断是否还有题目加载
const fullHeight = ref(document.documentElement.clientHeight - 110) // table高度自适应
const loading = ref(false) // 判断是否正在加载
const folderDialogVisible = ref(false) // 创建、修改文件的表单展示
const dialogForm = ref({
  name: '',
  desc: '',
  courseId: ''
})  // 创建、修改文件夹的表单数据
const tableRef = ref(null) // 控制试题table的ref
const testForm = ref({
  subject: '',
  classs: '',
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
}) // 试卷基础信息的表单数据
const testArr = ref([]) // 保存选择到试卷中的试题数据
const testFormVisible = ref(false) // 试卷信息页面显示
const quickTestFormVisible = ref(false) // 快速组卷页面显示
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
      message: '请选择考试方式',
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
    {required: true, message: 'Please input activity form', trigger: 'blur'},
  ],
} // 试卷信息的校验规则
const typeDescArr = ref({
  selectDesc: '',
  gapDesc: '',
  answerDesc: '',
  proveDesc: ''
}) // 大题简介的数据
const addToFolderVisible = ref(false) // 试题添加到文件夹的表单显示
const addToFolderForm = ref({
  folderId: ''
}) // 将试题添加到文件夹的表单数据
const formRef = ref(null) // 控制试卷信息页面的ref
const quickFormRef = ref(null) // 控制快速组卷页面的ref

// 快速组卷表单数据
const quickTestForm = ref({
  // 基本信息
  subject: '',
  classs: '',
  time: '',
  yearStart: '',
  yearEnd: '',
  term: '',
  number: '',
  open: '闭卷',
  exam: '考试',
  mingTi: '',
  shenTi: '',
  shenHe: '',
  shenPi: '',
  // 题型设置
  questionTypes: [
    { type: '选择题', count: 5, enabled: true, difficulty: 3 },
    { type: '填空题', count: 3, enabled: true, difficulty: 3 },
    { type: '简答题', count: 2, enabled: true, difficulty: 3 },
    { type: '证明题', count: 1, enabled: false, difficulty: 3 }
  ],
  // 智能推荐设置
  useIntelligent: true,
  balanceDifficulty: true,
  preferNewQuestions: false,
  chapterDistribution: 'balanced' // 'balanced', 'focused', 'random'
})

// 进度条变量
const progressVisible = ref(false)
const progressPercent = ref(0)
let startTime = 0

const getCourse = async () => {
  await axios.get('/api/course/getAll').then(res => {
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
  // 如果已经在加载中，则不重复加载
  if (loading.value) return;

  console.log('开始加载数据，页码:', pageParams.value.page);
  loading.value = true

  try {
    const res = await axios.post('/api/questions/page', JSON.parse(JSON.stringify({
          page: pageParams.value.page,
          pageSize: pageParams.value.pageSize,
          filterKey: 'ques_cour',
          filterValue: [currentCourse.value.courseId],
        }))
    );

    if (res.data.code === 401) {
      storage.remove('isAuthenticated');
      router.push('/login')
      return;
    }

    if (res.data.code === 200) {
      // 增加页码，为下次加载做准备
      pageParams.value.page++

      // 将获取的题目数据全部传入题目数组
      questionArr.value = res.data.data.list || [];

      // 将返回的数据遍历push到tableData
      console.log('获取到题目数量:', questionArr.value.length);

      if (questionArr.value && questionArr.value.length > 0) {
        for (let i = 0; i < questionArr.value.length; i++) {
          questionArr.value[i].index = tableData.value.length + 1
          tableData.value.push(questionArr.value[i])
        }

        // 记录数据库中所有题目加上文件夹的数目
        count.value = res.data.data.count + folderArr.value.length

        // 通过比较得知是否还有能加载的题目
        const hasMoreData = tableData.value.length < res.data.data.count + folderArr.value.length;
        isLoading.value = hasMoreData;

        console.log('数据加载完成:', {
          当前数据量: tableData.value.length,
          总数据量: count.value,
          还有更多数据: hasMoreData
        });
      } else {
        // 如果没有获取到数据，说明已经加载完全部数据
        console.log('没有更多数据可加载');
        isLoading.value = false;
      }
    } else if (storage.get('isAuthenticated')) {
      ElNotification({
        title: '未查询到该课程的题目',
        type: 'warning',
        duration: 0
      });
    }
  } catch (e) {
    console.error('加载数据出错:', e);
    ElNotification({
      title: '加载数据失败',
      type: 'error',
      duration: 3000
    });
  } finally {
    // 无论成功失败，都要解除加载状态
    loading.value = false;
  }
} // 加载题目数据
const freshTable = () => {
  console.log('刷新表格数据');
  // 清空table
  tableData.value = []
  multipleSelection.value.questionList = []
  multipleSelection.value.folderList = []

  // 重置状态变量
  count.value = 0
  currenCount.value = 0
  isLoading.value = true

  // 重置page参数
  pageParams.value.page = 1

  // 先获取文件夹，再加载题目数据
  getFolder()
  loadData()
}  // 刷新table内容
const handleClick = (row) => {
  // 判断是题目还是文件夹,文件夹就打开文件夹编辑。题目就跳转到edit
  if (row.foldDesc) {
    // 是文件夹就传入id进行懒加载子数据
    // lazyLoadQuestion(row);

  } else {
    // 点击编辑后，携带获取到的题目id跳转到编辑页面
    router.push({path: '/edit', query: {id: row.id}})
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
    // 使用name属性来判断是否为文件夹，与handleSingleDelete保持一致
    if (val[i].name) {
      multipleSelection.value.folderList.push(val[i]);
    } else {
      multipleSelection.value.questionList.push(val[i]);
    }
  }
  console.log("多选列表")
  console.log(multipleSelection.value)
}//多选逻辑
const addToFolder = () => {
  const questionIdArr = multipleSelection.value.questionList.map(question => question.id);
  console.log(questionIdArr)
  if (questionIdArr.length > 0) {
    axios.post('/api/folder_ques_list/moveToFolder', '', {
          params: {
            folderId: addToFolderForm.value.folderId,
            quesIds: questionIdArr.join(',')
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
// 执行删除操作的函数
const performDelete = (folderIds, questionIds) => {
  // 删除状态标记
  const deleteLoading = ref(false);

  // 删除文件夹
  if (folderIds && folderIds.length > 0) {
    deleteLoading.value = true;
    console.log('开始删除文件夹:', folderIds);

    axios.post('/api/quesFolder/deletedFolder', '', {
      params: {
        id: folderIds.join(',')
      }
    }).then(res => {
      if (res.data.code === 200) {
        for (let i = 0; i < folderIds.length; i++) {
          const dataIndex = tableData.value.findIndex(item => item.id === folderIds[i])
          console.log('找到文件夹索引:', dataIndex)
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

        // 记录用户活动
        const userId = storage.get('userId');
        console.log('删除文件夹时的用户ID:', userId);
        if (userId) {
          // 对每个删除的文件夹记录一次活动
          folderIds.forEach(folderId => {
            const folder = folderArr.value.find(f => f.id === folderId);
            axios.post('/api/userActivity/record', null, {
              params: {
                userId: userId,
                type: '删除文件夹',
                name: folder ? folder.name : '文件夹',
                objectId: folderId
              }
            }).then(res => {
              console.log('记录活动成功:', res.data);
            }).catch(error => {
              console.error('记录活动失败:', error);
            });
          });
        } else {
          console.error('用户ID不存在，无法记录活动');
        }
      } else {
        ElNotification({
          title: '文件夹删除失败',
          message: res.data.message || '服务器返回错误，请稍后重试',
          type: 'error'
        });
      }
    }).catch(error => {
      console.error('删除文件夹请求失败:', error);
      ElNotification({
        title: '删除请求失败',
        message: '网络错误或服务器异常，请稍后重试',
        type: 'error'
      });
    }).finally(() => {
      deleteLoading.value = false;
      // 重置文件夹多选列表
      multipleSelection.value.folderList = [];
    });
  }

  // 删除试题
  if (questionIds && questionIds.length > 0) {
    deleteLoading.value = true;
    console.log('开始删除试题:', questionIds);

    axios.post('/api/questions/delete', '', {
      params: {
        id: questionIds.join(',')
      }
    }).then(res => {
      // 通过table索引移除
      if (res.data.code === 200) {
        for (let i = 0; i < questionIds.length; i++) {
          const dataIndex = tableData.value.findIndex(item => item.id === questionIds[i])
          console.log('找到试题索引:', dataIndex)
          // 过滤到相同id的文件夹，只删除题目
          if (dataIndex !== -1 && !tableData.value[dataIndex].name) {
            tableData.value.splice(dataIndex, 1)
            count.value--
          }
        }
        ElNotification({
          title: '试题删除成功',
          type: 'success'
        });

        // 注意：删除试题的活动记录已移至后端处理
        // 这样可以避免前后端重复记录活动
      } else {
        ElNotification({
          title: '试题删除失败',
          message: res.data.message || '服务器返回错误，请稍后重试',
          type: 'error'
        });
      }
    }).catch(error => {
      console.error('删除试题请求失败:', error);
      ElNotification({
        title: '删除请求失败',
        message: '网络错误或服务器异常，请稍后重试',
        type: 'error'
      });
    }).finally(() => {
      deleteLoading.value = false;
      // 重置试题多选列表
      multipleSelection.value.questionList = [];
    });
  }
};

// 单个项目删除处理函数
const handleSingleDelete = (row) => {
  // 判断是文件夹还是试题
  const isFolder = !!row.name;
  const itemName = isFolder ? row.name : (row.description ? (row.description.length > 20 ? row.description.substring(0, 20) + '...' : row.description) : '试题');
  const itemType = isFolder ? '文件夹' : '试题';

  ElMessageBox.confirm(`确定要删除${itemType}「${itemName}」吗？${isFolder ? '\n注意：删除文件夹不会删除文件夹中的试题。' : ''}`, '删除确认', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    if (isFolder) {
      // 删除单个文件夹
      performDelete([row.id], []);
    } else {
      // 删除单个试题
      performDelete([], [row.id]);
    }
  }).catch(() => {
    // 用户取消删除，不执行任何操作
    ElNotification({
      title: '已取消删除',
      type: 'info'
    });
  });
};

// 批量删除事件处理函数
const deleteEvent = () => {
  // 使用数组而不是ref，避免不必要的响应式包装
  const folderIdArr = multipleSelection.value.folderList.map(folder => folder.id);
  const questionIdArr = multipleSelection.value.questionList.map(question => question.id);

  // 如果没有选择任何项目，提示用户
  if (folderIdArr.length === 0 && questionIdArr.length === 0) {
    ElNotification({
      title: '请先选择要删除的内容',
      type: 'warning'
    });
    return;
  }

  // 构建确认信息
  let confirmMessage = '确定要删除';
  if (folderIdArr.length > 0) {
    confirmMessage += ` ${folderIdArr.length} 个文件夹`;
  }
  if (folderIdArr.length > 0 && questionIdArr.length > 0) {
    confirmMessage += '和';
  }
  if (questionIdArr.length > 0) {
    confirmMessage += ` ${questionIdArr.length} 道试题`;
  }
  confirmMessage += '吗？';

  // 添加文件夹内容提示
  if (folderIdArr.length > 0) {
    confirmMessage += '\n注意：删除文件夹不会删除文件夹中的试题。';
  }

  // 显示确认对话框
  ElMessageBox.confirm(confirmMessage, '删除确认', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    // 执行删除操作
    performDelete(folderIdArr, questionIdArr);
  }).catch(() => {
    // 用户取消删除，不执行任何操作
    ElNotification({
      title: '已取消删除',
      type: 'info'
    });
  });
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
  // 移除可能存在的旧监听器，防止重复监听
  window.removeEventListener('resize', handleResize)
  window.removeEventListener('scroll', handleScroll)

  // 添加新的监听器
  window.addEventListener('resize', handleResize)
  window.addEventListener('scroll', handleScroll)

  console.log('事件监听器已设置')

  // 初始化时手动触发一次resize，确保表格高度正确
  handleResize()
} //设置页面大小监听器和滚动监听

const handleResize = () => {
  fullHeight.value = document.documentElement.clientHeight - 110
} //获取窗口高度

const handleScroll = () => {
  // 获取滚动位置信息
  const scrollTop = document.documentElement.scrollTop || document.body.scrollTop
  const scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight
  const clientHeight = document.documentElement.clientHeight || window.innerHeight

  // 计算距离底部的距离
  const distanceToBottom = scrollHeight - scrollTop - clientHeight

  // 调试信息
  console.log('滚动检测:', {
    isLoading: isLoading.value,
    loading: loading.value,
    scrollTop,
    scrollHeight,
    clientHeight,
    distanceToBottom,
    tableDataLength: tableData.value.length,
    totalCount: count.value
  })

  // 检查是否滚动到底部附近，并且还有更多数据可加载，且当前不在加载状态
  if (isLoading.value && !loading.value) {
    // 当滚动到距离底部300px时加载更多数据（增大触发区域）
    if (distanceToBottom < 300) {
      console.log('触发加载更多数据')
      loadData()
    }
  }
} //滚动加载更多数据
const lazyLoadQuestion = (row, _treeNode, resolve) => {
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
          res.data.data.list.forEach((item) => {
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
    }).then((res) => {
      if (res.data.code === 200) {
        // 使用活动服务记录创建文件夹活动
        activityService.recordActivity(
          '创建文件夹',
          dialogForm.value.name || '文件夹',
          res.data.data
        ).catch(error => console.error('记录创建文件夹活动失败:', error));
      }
      freshTable();
    })
} // 创建文件夹
const addTest = (row) => {
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

// 难度等级转换函数
const getDifficultyLabel = (hard) => {
  // 将数字转换为对应的中文标签
  const difficultyMap = {
    '1': '入门',
    '2': '简单',
    '3': '中等',
    '4': '困难',
    '5': '挑战'
  };

  // 如果是数字字符串，直接映射
  if (difficultyMap[hard]) {
    return difficultyMap[hard];
  }

  // 如果是旧数据中的中文，保持原样显示
  if (['入门', '简单', '中等', '困难', '挑战'].includes(hard)) {
    return hard;
  }

  // 其他情况，尝试将其作为数字处理
  const numHard = parseInt(hard);
  if (!isNaN(numHard) && numHard >= 1 && numHard <= 5) {
    return difficultyMap[numHard.toString()];
  }

  // 默认返回未知
  return '未知';
}

// 根据难度返回标签类型
const getDifficultyType = (hard) => {
  // 将难度值转换为数字
  let numHard;

  // 如果是数字字符串
  if (['1', '2', '3', '4', '5'].includes(hard)) {
    numHard = parseInt(hard);
  }
  // 如果是中文
  else if (hard === '入门') {
    numHard = 1;
  } else if (hard === '简单') {
    numHard = 2;
  } else if (hard === '中等') {
    numHard = 3;
  } else if (hard === '困难') {
    numHard = 4;
  } else if (hard === '挑战') {
    numHard = 5;
  }
  // 尝试直接解析为数字
  else {
    numHard = parseInt(hard);
    if (isNaN(numHard) || numHard < 1 || numHard > 5) {
      numHard = 3; // 默认为中等
    }
  }

  // 根据数字难度返回对应的标签类型
  if (numHard <= 2) {
    return 'success'; // 绿色：入门、简单
  } else if (numHard === 3) {
    return 'warning'; // 黄色：中等
  } else {
    return 'danger';  // 红色：困难、挑战
  }
}
// 下载文件函数
const downloadFile = (data) => {
  // 检查参数是否为对象且包含url属性
  let fileUrl = '';
  if (typeof data === 'object' && data !== null) {
    if (data.url) {
      fileUrl = data.url;
    } else {
      console.error('下载参数错误: 对象中没有url属性', data);
      ElNotification({
        title: '下载失败',
        message: '无法获取下载地址',
        type: 'error'
      });
      return;
    }
  } else {
    // 如果是字符串，直接使用
    fileUrl = data;
  }

  console.log('下载文件URL:', fileUrl);

  // 直接打开URL，让浏览器处理下载
  window.open(fileUrl, '_blank');
}
const createTest = async () => {
  testFormVisible.value = false
  progressVisible.value = true
  // 重置生成的试卷数据
  generatedPaperData.value = null

  // 非线性进度实现（贝塞尔曲线缓动）
  startTime = Date.now()
  const animate = () => {
    const elapsed = Date.now() - startTime
    const progress = elapsed / 8000 // 8秒总时间

    // 使用三次贝塞尔缓动函数
    progressPercent.value = Math.min(1 - Math.pow(1 - progress, 3), 1) * 100

    if (progress < 1) {
      requestAnimationFrame(animate)
    }
  }
  requestAnimationFrame(animate)

  const form = unref(formRef)
  form.validate(valid => {
    if (valid) {
      //  根据testArr中的题目情况，像请求参数中添加题目。
      let list = []
      if (testArr.value.findIndex(item => item.types === '选择题') !== -1) {
        list.push({
          typeName: '选择题',
          "typeDesc": typeDescArr.value.selectDesc,
          "quesId": testArr.value.filter(item => item.types === '选择题').map(item => item.id)
        })
      }
      if (testArr.value.findIndex(item => item.types === '填空题') !== -1) {
        list.push({
          "typeName": "填空题",
          "typeDesc": typeDescArr.value.gapDesc,
          "quesId": testArr.value.filter(item => item.types === '填空题').map(item => item.id)
        })
      }
      if (testArr.value.findIndex(item => item.types === '简答题') !== -1) {
        list.push({
          "typeName": "计算题",
          "typeDesc": typeDescArr.value.answerDesc,
          "quesId": testArr.value.filter(item => item.types === '简答题').map(item => item.id)
        })
      }
      if (testArr.value.findIndex(item => item.types === '证明题') !== -1) {
        list.push({
          "typeName": "证明题",
          "typeDesc": typeDescArr.value.proveDesc,
          "quesId": testArr.value.filter(item => item.types === '证明题').map(item => item.id)
        })
      }
      try {
        axios.post('/api/questions/buildTest', JSON.parse(JSON.stringify({
          title: testForm.value,
          list: list
        }))).then(res => {
          if (res.data.code === 200) {
            ElNotification({
              title: '试卷组建成功，点击"下载试卷"按钮下载',
              type: 'success'
            });
            // 保存生成的试卷数据，但不自动下载
            generatedPaperData.value = res.data.data
          } else {
            ElNotification({
              title: '试卷组建失败',
              type: 'error'
            })
          }
        });
      } catch (e) {
        ElNotification.error({
          title: '网络错误',
          message: '无法连接到服务器',
        });
      }
    }
  })
}// 生成试卷
const clearTest = () => {
  testArr.value.forEach((item) => {
    removeTest(item)
  })
} //点击清空组卷列表中的试题

// 存储生成的试卷数据，用于下载按钮
const generatedPaperData = ref(null)

// 快速组卷方法
const createQuickTest = async () => {
  quickTestFormVisible.value = false
  progressVisible.value = true
  // 重置生成的试卷数据
  generatedPaperData.value = null

  // 非线性进度实现（贝塞尔曲线缓动）
  startTime = Date.now()
  const animate = () => {
    const elapsed = Date.now() - startTime
    const progress = elapsed / 8000 // 8秒总时间

    // 使用三次贝塞尔缓动函数
    progressPercent.value = Math.min(1 - Math.pow(1 - progress, 3), 1) * 100

    if (progress < 1) {
      requestAnimationFrame(animate)
    }
  }
  requestAnimationFrame(animate)

  const form = unref(quickFormRef)
  form.validate(async valid => {
    if (valid) {
      try {
        // 构建请求参数
        const params = {
          title: {
            subject: quickTestForm.value.subject,
            classs: quickTestForm.value.classs,
            time: quickTestForm.value.time,
            yearStart: quickTestForm.value.yearStart,
            yearEnd: quickTestForm.value.yearEnd,
            term: quickTestForm.value.term,
            number: quickTestForm.value.number,
            open: quickTestForm.value.open,
            exam: quickTestForm.value.exam,
            mingTi: quickTestForm.value.mingTi,
            shenTi: quickTestForm.value.shenTi,
            shenHe: quickTestForm.value.shenHe,
            shenPi: quickTestForm.value.shenPi
          },
          questionTypes: quickTestForm.value.questionTypes.filter(type => type.enabled),
          settings: {
            useIntelligent: quickTestForm.value.useIntelligent,
            balanceDifficulty: quickTestForm.value.balanceDifficulty,
            preferNewQuestions: quickTestForm.value.preferNewQuestions,
            chapterDistribution: quickTestForm.value.chapterDistribution,
            courseId: currentCourse.value.courseId
          }
        }

        // 发送请求
        const res = await axios.post('/api/questions/quickBuildTest', params)

        if (res.data.code === 200) {
          ElNotification({
            title: '试卷组建成功，点击"下载试卷"按钮下载',
            type: 'success'
          });

          // 保存生成的试卷数据，但不自动下载
          generatedPaperData.value = res.data.data

          // 清空已选题目
          clearTest()

          // 将推荐的题目添加到已选列表中
          if (res.data.data.questions && res.data.data.questions.length > 0) {
            res.data.data.questions.forEach(question => {
              // 查找题目并添加到已选列表
              const foundQuestion = tableData.value.find(item => item.id === question.id)
              if (foundQuestion) {
                addTest(foundQuestion)
              }
            })
          }
        } else {
          ElNotification({
            title: '试卷组建失败',
            type: 'error',
            message: res.data.message || '未知错误'
          })
        }
      } catch (e) {
        console.error('快速组卷失败:', e)
        ElNotification.error({
          title: '网络错误',
          message: '无法连接到服务器',
        });
      }
    }
  })
}

// 下载生成的试卷
const downloadGeneratedPaper = () => {
  if (generatedPaperData.value) {
    downloadFile(generatedPaperData.value)
  } else {
    ElNotification({
      title: '下载失败',
      message: '没有可下载的试卷',
      type: 'warning'
    })
  }
}
const searchQuestion = () => {
  if (search.value === '') {
    freshTable();
  } else {
    axios.post('/api/questions/page', JSON.parse(JSON.stringify({
      page: 1,
      pageSize: 100,
      queryKeyword: search.value,
      filterKey: 'ques_cour',
      filterValue: [currentCourse.value.courseId]
    }))).then(res => {
      if (res.data.code === 200) {
        // 获取成功后先清空列表
        tableData.value = []
        multipleSelection.value.questionList = []
        multipleSelection.value.folderList = []
        getFolder()
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
        isLoading.value = false
        // 处理后将loading状态解锁
        loading.value = false
      } else if (storage.get('isAuthenticated')) {
        ElNotification({
          title: '未查询到该课程的题目',
          type: 'warning',
          duration: 0
        });
        loading.value = false
      }
    })
  }
}


onBeforeUnmount(() => {
  console.log('组件销毁，移除事件监听');
  window.removeEventListener('resize', handleResize)
  window.removeEventListener('scroll', handleScroll)
});// 组件销毁前解除监听释放内存

// 设置初始状态
isLoading.value = true;
loading.value = false;
currenCount.value = 0;

// 设置事件监听
creatEventListener();

// 通过异步的await保证先获取课程再获取文件夹和题目
(async () => {
  try {
    console.log('开始初始化数据');
    await getCourse();
    await getFolder();
    await loadData();

    // 初始化完成后，手动触发一次滚动检测
    setTimeout(() => {
      handleScroll();
      console.log('初始化完成，触发滚动检测');
    }, 500);
  } catch (e) {
    console.error('初始化课程、题目数据错误', e);
    ElNotification({
      title: '数据加载失败',
      message: '请刷新页面重试',
      type: 'error',
      duration: 3000
    });
  }
})();
</script>

<template>
  <div class="app-card main-container">
    <div class="header-actions">
      <div class="left-actions">
        <el-button type="primary" @click="folderDialogVisible = true">
          <el-icon><Folder /></el-icon>
          <span>创建文件夹</span>
        </el-button>
        <el-button type="primary" @click="() => router.push('/edit')">
          <el-icon><Edit /></el-icon>
          <span>创建试题</span>
        </el-button>
        <el-button @click="addToFolderVisible = true">
          <el-icon><CopyDocument /></el-icon>
          <span>添加试题到文件夹</span>
        </el-button>
        <el-button @click="deleteEvent" type="danger">
          <el-icon><Delete /></el-icon>
          <span>批量删除</span>
        </el-button>
      </div>

      <div class="right-actions">
        <el-dropdown class="course-dropdown">
          <el-button>
            <el-icon><Reading /></el-icon>
            {{ currentCourse.courseName }}
            <el-icon class="el-icon--right"><arrow-down/></el-icon>
          </el-button>
          <template #dropdown>
            <el-dropdown-menu>
              <el-dropdown-item v-for="courseItem in courseArr" :key='courseItem.id' @click="courseSelect(courseItem)">
                {{ courseItem.name }}
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>

        <div class="test-actions">
          <el-statistic title="已选题目" :value="testArr.length" class="test-statistic"/>
          <el-button type="success" @click="testFormVisible = true">
            <el-icon><Document /></el-icon>
            <span>创建试卷</span>
          </el-button>
          <el-button type="primary" @click="quickTestFormVisible = true">
            <el-icon><Document /></el-icon>
            <span>快速组卷</span>
          </el-button>
          <el-button @click="clearTest()">
            <el-icon><RemoveFilled /></el-icon>
            <span>清空已选题目</span>
          </el-button>
        </div>
      </div>
    </div>

    <div class="search-container">
      <el-input v-model="search" placeholder="输入题目关键字搜索" class="search-input">
        <template #prefix>
          <el-icon><Search /></el-icon>
        </template>
        <template #append>
          <el-button @click="searchQuestion">搜索</el-button>
        </template>
      </el-input>
    </div>

    <div class="table-container">
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
                class="question-table"
                :header-cell-style="{backgroundColor: 'var(--primary-light)', color: 'var(--text-primary)', fontWeight: '600'}"
      >
      <el-table-column fixed type="selection" width='40'/>
      <el-table-column fixed type="index" width="50" label="序号"/>
      <el-table-column prop="description" label="文件夹/题目" show-overflow-tooltip min-width="500">
        <template #default="{row}">
          <div class="question-title">
            <el-icon v-if="row.hasChildren" class="folder-icon"><Folder /></el-icon>
            <el-icon v-else class="question-icon"><Document /></el-icon>
            <span>{{ row.description }}</span>
          </div>
        </template>
      </el-table-column>
      <el-table-column prop="quesCourStr" label="课程" width="120">
        <template #default="{row}">
          <el-tag size="small" type="info" v-if="row.quesCourStr">{{ row.quesCourStr }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="types" label="题型" sortable width="100">
        <template #default="{row}">
          <el-tag size="small" type="success" v-if="row.types">{{ row.types }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="hard" sortable label="难易度" width="100">
        <template #default="{row}">
          <el-tag
            size="small"
            :type="getDifficultyType(row.hard)"
            v-if="row.hard"
          >
            {{ getDifficultyLabel(row.hard) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column fixed="right" min-width="220" label="操作">
        <template #default="{ row }">
          <div class="action-buttons">
            <el-button link type="primary" size="small" @click="handleClick(row)">
              <el-icon><Edit /></el-icon>
              <span>编辑</span>
            </el-button>
            <el-button link type="success" size="small" @click="addTest(row)"
                      v-if="!row.hasChildren && row.description && !row.inTest">
              <el-icon><Plus /></el-icon>
              <span>加入试卷</span>
            </el-button>
            <el-button link type="danger" size="small" @click="removeTest(row)"
                      v-if="!row.hasChildren && row.description && row.inTest === true">
              <el-icon><Remove /></el-icon>
              <span>移出试卷</span>
            </el-button>
            <el-button link type="danger" size="small" @click="handleSingleDelete(row)">
              <el-icon><Delete /></el-icon>
              <span>删除</span>
            </el-button>
          </div>
        </template>
      </el-table-column>
      <template v-slot:append>
        <div class="loading-container" v-if="loading">
          <el-skeleton :rows="3" animated />
        </div>
      </template>
      </el-table>

      <div class="table-footer">
        <div class="data-summary">
          <el-tag type="info" effect="plain" class="summary-tag">
            <el-icon><InfoFilled /></el-icon>
            <span>已加载 <span class="count-highlight">{{ tableData.length }}</span> / {{ count }} 条数据</span>
          </el-tag>
        </div>

        <div class="scroll-tip" v-if="isLoading && !loading">
          <el-tag type="primary" effect="light" class="tip-tag">
            <el-icon><Bottom /></el-icon>
            <span>继续滚动加载更多</span>
          </el-tag>
        </div>

        <div class="scroll-tip" v-if="!isLoading && tableData.length > 0">
          <el-tag type="success" effect="light" class="tip-tag">
            <el-icon><Select /></el-icon>
            <span>已加载全部数据</span>
          </el-tag>
        </div>
      </div>

      <!-- 加载更多按钮 - 作为滚动加载的备选方案 -->
      <div class="load-more-container" v-if="isLoading && !loading">
        <el-button
          type="primary"
          @click="loadData"
          :loading="loading"
          class="load-more-button"
        >
          <el-icon><Bottom /></el-icon>
          <span>点击加载更多数据</span>
        </el-button>
      </div>
    </div>
  </div>
  <el-dialog v-model="folderDialogVisible"
             title="创建文件夹"
             width="500"
             align-center
             :close-on-click-modal="false"
             class="custom-dialog"
             @closed="() =>  dialogForm = {}">
    <el-form :model="dialogForm" label-position="top">
      <el-form-item label="文件夹名称">
        <el-input
          v-model="dialogForm.name"
          autocomplete="off"
          placeholder="请输入文件夹名称"
        />
      </el-form-item>
      <el-form-item label="文件夹描述">
        <el-input
          v-model="dialogForm.desc"
          type="textarea"
          :rows="3"
          placeholder="请输入文件夹描述"
          resize="none"
        />
      </el-form-item>
      <el-form-item label="所属课程">
        <el-select
          v-model="dialogForm.courseId"
          placeholder="请选择课程"
          style="width: 100%"
        >
          <el-option
            v-for="item in courseArr"
            :label="item.name"
            :key="item.id"
            :value="item.id"
          />
        </el-select>
      </el-form-item>
    </el-form>
    <template #footer>
      <div class="dialog-footer">
        <el-button @click="folderDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="folderDialogVisible = false; creatFolder()">
          <el-icon><Plus /></el-icon>
          <span>创建文件夹</span>
        </el-button>
      </div>
    </template>
  </el-dialog>
  <el-dialog v-model="addToFolderVisible"
             title="批量添加试题到文件夹"
             width="500"
             align-center
             :close-on-click-modal="false"
             class="custom-dialog"
             @closed="() =>  addToFolderForm = {}">
    <div class="selected-info" v-if="multipleSelection.questionList.length > 0">
      <el-alert
        title="已选择试题信息"
        type="info"
        :closable="false"
        show-icon
      >
        <div class="selected-count">
          当前已选择 <span class="count-highlight">{{ multipleSelection.questionList.length }}</span> 道试题
        </div>
      </el-alert>
    </div>

    <el-form :model="addToFolderForm" label-position="top" class="mt-20">
      <el-form-item label="选择目标文件夹">
        <el-select
          v-model="addToFolderForm.folderId"
          placeholder="请选择要添加到的文件夹"
          style="width: 100%"
        >
          <el-option
            v-for="item in folderArr"
            :label="item.name"
            :key="item.id"
            :value="item.id"
          >
            <div class="folder-option">
              <el-icon class="folder-icon"><Folder /></el-icon>
              <span>{{ item.name }}</span>
            </div>
          </el-option>
        </el-select>
      </el-form-item>
    </el-form>

    <template #footer>
      <div class="dialog-footer">
        <el-button @click="addToFolderVisible = false">取消</el-button>
        <el-button type="primary" @click="addToFolderVisible = false; addToFolder()">
          <el-icon><CopyDocument /></el-icon>
          <span>添加到文件夹</span>
        </el-button>
      </div>
    </template>
  </el-dialog>
<!--  试卷参数表单-->
  <el-dialog v-model="testFormVisible"
             title="创建试卷"
             width="800"
             :close-on-click-modal="false"
             class="custom-dialog test-paper-dialog"
             @closed="() =>  dialogForm = {}">
    <div class="selected-info" v-if="testArr.length > 0">
      <el-alert
        title="已选择试题信息"
        type="success"
        :closable="false"
        show-icon
      >
        <div class="selected-count">
          当前已选择 <span class="count-highlight">{{ testArr.length }}</span> 道试题组建试卷
        </div>
      </el-alert>
    </div>

    <el-form
        style="max-width: 100%"
        ref="formRef"
        :model="testForm"
        :rules="rules"
        label-position="top"
        class="test-form mt-20"
        :size="'default'"
        status-icon
    >
      <el-form-item label="试卷科目" prop="subject">
        <el-input v-model="testForm.subject"/>
      </el-form-item>
      <el-form-item label="班级" prop="classs">
        <el-input v-model="testForm.classs"/>
      </el-form-item>
      <el-form-item label="考试时长" prop="time">
        <el-input v-model="testForm.time"/>
      </el-form-item>
      <el-form-item label="章节" prop="number">
        <el-input v-model="testForm.number"/>
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
        <el-input v-model="testForm.term"/>
      </el-form-item>
      <el-form-item label="开/闭卷" prop="open">
        <el-radio-group v-model="testForm.open">
          <el-radio-button label="开卷" value="开卷"/>
          <el-radio-button label="闭卷" value="闭卷"/>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="考试类型" prop="exam">
        <el-radio-group v-model="testForm.exam">
          <el-radio-button label="考试" value="考试"/>
          <el-radio-button label="考察" value="考察"/>
        </el-radio-group>
      </el-form-item>
      <el-form-item label="命题老师" prop="mingTi">
        <el-input v-model="testForm.mingTi" placeholder="输入命题老师" clearable/>
      </el-form-item>
      <el-form-item label="审题老师" prop="shenTI">
        <el-input v-model="testForm.shenTi" placeholder="输入审题老师" clearable/>
      </el-form-item>
      <el-form-item label="审核老师" prop="mingTi">
        <el-input v-model="testForm.shenHe" placeholder="输入审核老师" clearable/>
      </el-form-item>
      <el-form-item label="审批老师" prop="shenPi">
        <el-input v-model="testForm.shenPi" placeholder="输入审批老师" clearable/>
      </el-form-item>
      <el-form-item label="选择题" prop="question1" v-if="testArr.findIndex(item => item.types === '选择题') !== -1">
        <el-input v-model="typeDescArr.selectDesc" placeholder="输入选择题描述，如：一、总共五题，每题3分" clearable/>
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
        <el-input v-model="typeDescArr.gapDesc" placeholder="输入填空题描述，如：二、总共六题，每题3分" clearable/>
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
        <el-input v-model="typeDescArr.answerDesc" placeholder="输入简答题描述，如：三、总共三题，每题10分" clearable/>
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
        <el-input v-model="typeDescArr.proveDesc" placeholder="输入证明题描述，四、总共两题，每题10分" clearable/>
        <draggable
            :list="testArr"
            :disable="true"
        >
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
        </draggable>
      </el-form-item>
      <el-form-item>
        <div class="form-actions">
          <el-button @click="testFormVisible = false">取消</el-button>
          <el-button type="primary" @click="createTest()">
            <el-icon><Document /></el-icon>
            <span>生成试卷</span>
          </el-button>
        </div>
      </el-form-item>
    </el-form>
  </el-dialog>
<!--  快速组卷对话框-->
  <el-dialog v-model="quickTestFormVisible"
             title="快速组卷"
             width="800"
             :close-on-click-modal="false"
             class="custom-dialog quick-test-dialog"
             @closed="() => {}">
    <el-form
        style="max-width: 100%"
        ref="quickFormRef"
        :model="quickTestForm"
        :rules="rules"
        label-position="top"
        class="quick-test-form"
        :size="'default'"
        status-icon
    >
      <!-- 基本信息部分 -->
      <div class="form-section">
        <h3 class="section-title">试卷基本信息</h3>
        <div class="form-grid">
          <el-form-item label="试卷科目" prop="subject">
            <el-input v-model="quickTestForm.subject"/>
          </el-form-item>
          <el-form-item label="班级" prop="classs">
            <el-input v-model="quickTestForm.classs"/>
          </el-form-item>
          <el-form-item label="考试时长" prop="time">
            <el-input v-model="quickTestForm.time"/>
          </el-form-item>
          <el-form-item label="章节" prop="number">
            <el-input v-model="quickTestForm.number"/>
          </el-form-item>
          <el-form-item label="学年" required>
            <el-col :span="11">
              <el-form-item prop="yearStart">
                <el-date-picker
                    v-model="quickTestForm.yearStart"
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
                    v-model="quickTestForm.yearEnd"
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
            <el-input v-model="quickTestForm.term"/>
          </el-form-item>
          <el-form-item label="开/闭卷" prop="open">
            <el-radio-group v-model="quickTestForm.open">
              <el-radio-button label="开卷" value="开卷"/>
              <el-radio-button label="闭卷" value="闭卷"/>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="考试类型" prop="exam">
            <el-radio-group v-model="quickTestForm.exam">
              <el-radio-button label="考试" value="考试"/>
              <el-radio-button label="考察" value="考察"/>
            </el-radio-group>
          </el-form-item>
        </div>
      </div>

      <!-- 题型设置部分 -->
      <div class="form-section">
        <h3 class="section-title">题型设置</h3>
        <div class="question-types-container">
          <div v-for="type in quickTestForm.questionTypes" :key="type.type" class="question-type-item">
            <div class="type-header">
              <el-checkbox v-model="type.enabled">{{ type.type }}</el-checkbox>
            </div>
            <div class="type-settings" v-if="type.enabled">
              <div class="setting-item">
                <span class="setting-label">数量:</span>
                <el-input-number v-model="type.count" :min="1" :max="20" size="small" />
              </div>
              <div class="setting-item">
                <span class="setting-label">难度:</span>
                <el-slider v-model="type.difficulty" :min="1" :max="5" :step="1" :marks="{
                  1: '入门',
                  2: '简单',
                  3: '中等',
                  4: '困难',
                  5: '挑战'
                }" />
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 智能推荐设置部分 -->
      <div class="form-section">
        <h3 class="section-title">智能推荐设置</h3>
        <div class="intelligent-settings">
          <el-form-item label="使用智能推荐">
            <el-switch v-model="quickTestForm.useIntelligent" />
          </el-form-item>

          <template v-if="quickTestForm.useIntelligent">
            <el-form-item label="均衡难度分布">
              <el-switch v-model="quickTestForm.balanceDifficulty" />
              <div class="setting-description">
                启用后，系统会尝试在保持平均难度的同时，确保试题难度分布合理
              </div>
            </el-form-item>

            <el-form-item label="优先选择新题">
              <el-switch v-model="quickTestForm.preferNewQuestions" />
              <div class="setting-description">
                启用后，系统会优先选择最近添加的试题
              </div>
            </el-form-item>

            <el-form-item label="章节分布">
              <el-radio-group v-model="quickTestForm.chapterDistribution">
                <el-radio-button label="balanced">均衡分布</el-radio-button>
                <el-radio-button label="focused">集中分布</el-radio-button>
                <el-radio-button label="random">随机分布</el-radio-button>
              </el-radio-group>
              <div class="setting-description">
                均衡分布：试题会尽量覆盖所有章节<br>
                集中分布：试题会集中在特定章节<br>
                随机分布：不考虑章节因素随机选择
              </div>
            </el-form-item>
          </template>
        </div>
      </div>

      <!-- 教师信息部分 -->
      <div class="form-section">
        <h3 class="section-title">教师信息</h3>
        <div class="form-grid">
          <el-form-item label="命题老师" prop="mingTi">
            <el-input v-model="quickTestForm.mingTi" placeholder="输入命题老师" clearable/>
          </el-form-item>
          <el-form-item label="审题老师" prop="shenTi">
            <el-input v-model="quickTestForm.shenTi" placeholder="输入审题老师" clearable/>
          </el-form-item>
          <el-form-item label="审核老师" prop="shenHe">
            <el-input v-model="quickTestForm.shenHe" placeholder="输入审核老师" clearable/>
          </el-form-item>
          <el-form-item label="审批老师" prop="shenPi">
            <el-input v-model="quickTestForm.shenPi" placeholder="输入审批老师" clearable/>
          </el-form-item>
        </div>
      </div>

      <el-form-item>
        <div class="form-actions">
          <el-button @click="quickTestFormVisible = false">取消</el-button>
          <el-button type="primary" @click="createQuickTest()">
            <el-icon><Document /></el-icon>
            <span>生成试卷</span>
          </el-button>
        </div>
      </el-form-item>
    </el-form>
  </el-dialog>
<!--  进度条-->
  <el-dialog
      :model-value="progressVisible"
      title="试卷生成中"
      width="400px"
      :close-on-click-modal="false"
      :close-on-press-escape="false"
      :show-close="false"
      class="custom-dialog progress-dialog"
  >
    <div class="progress-container">
      <div class="progress-icon" v-if="progressPercent < 100">
        <el-icon class="loading-icon"><Loading /></el-icon>
      </div>
      <div class="progress-icon success-icon" v-else>
        <el-icon><CircleCheckFilled /></el-icon>
      </div>

      <el-progress
          :percentage="progressPercent"
          :format="(percent) => `${Math.round(percent)}%`"
          :stroke-width="16"
          :text-inside="true"
          :status="progressPercent < 100 ? 'primary' : 'success'"
          striped
          striped-flow
      />

      <div class="progress-text">
        {{ progressPercent < 100 ? '正在生成试卷，请稍候...' : '试卷生成完成！' }}
      </div>
    </div>

    <template #footer>
      <el-button
          :type="progressPercent < 100 ? 'info' : 'success'"
          :disabled="progressPercent < 100"
          @click="progressPercent < 100 ? null : downloadGeneratedPaper(); progressVisible = false; progressPercent = 0;"
          class="progress-button"
      >
        <el-icon v-if="progressPercent < 100"><Loading /></el-icon>
        <el-icon v-else><Download /></el-icon>
        <span>{{ progressPercent < 100 ? '生成中...' : '下载试卷' }}</span>
      </el-button>
    </template>
  </el-dialog>
</template>

<style lang="less" scoped>
.main-container {
  padding: 20px;
  margin-bottom: 20px;
}

.header-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  flex-wrap: wrap;
  gap: 16px;

  .left-actions {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;

    .el-button {
      display: flex;
      align-items: center;
      gap: 5px;
    }
  }

  .right-actions {
    display: flex;
    align-items: center;
    gap: 20px;

    .course-dropdown {
      margin-right: 10px;
    }

    .test-actions {
      display: flex;
      align-items: center;
      gap: 10px;
    }

    .test-statistic {
      width: 100px;
      margin-right: 10px;
      padding: 0 10px;
      background-color: var(--primary-light);
      border-radius: 4px;
    }
  }
}

.search-container {
  margin-bottom: 16px;

  .search-input {
    width: 100%;
    max-width: 500px;
    transition: all 0.3s;

    &:focus-within {
      box-shadow: 0 0 0 2px var(--primary-light);
    }
  }
}

.table-container {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: var(--box-shadow);
  overflow: hidden;
  transition: all 0.3s;
  position: relative; /* 确保相对定位，便于内部元素绝对定位 */

  &:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.12);
  }

  .el-table {
    margin-bottom: 0;

    .question-title {
      display: flex;
      align-items: center;
      gap: 8px;

      .folder-icon {
        color: #E6A23C;
      }

      .question-icon {
        color: var(--primary-color);
      }
    }
  }

  .table-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 16px;
    background-color: var(--background-color);
    border-top: 1px solid var(--border-light);

    .data-summary {
      .summary-tag {
        display: flex;
        align-items: center;
        gap: 5px;
        padding: 6px 10px;

        .count-highlight {
          color: var(--primary-color);
          font-weight: bold;
        }
      }
    }

    .scroll-tip {
      .tip-tag {
        display: flex;
        align-items: center;
        gap: 5px;
        padding: 6px 10px;
        animation: pulse 1.5s infinite;
      }
    }
  }

  .loading-container {
    padding: 16px;
  }

  /* 加载更多按钮容器样式 */
  .load-more-container {
    display: flex;
    justify-content: center;
    padding: 16px;
    background-color: var(--background-color);
    border-top: 1px solid var(--border-light);

    .load-more-button {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 10px 20px;
      font-size: 14px;
      animation: pulse 1.5s infinite;

      &:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      }
    }
  }

  @keyframes pulse {
    0% {
      opacity: 0.7;
    }
    50% {
      opacity: 1;
    }
    100% {
      opacity: 0.7;
    }
  }

  .action-buttons {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;

    .el-button {
      display: flex;
      align-items: center;
      gap: 4px;

      &:hover {
        background-color: var(--primary-light);
        border-radius: 4px;
      }
    }
  }
}

.demo-pagination-block {
  display: flex;
  justify-content: flex-end;

  .el-pagination {
    padding: 0;
    border-radius: 4px;
    overflow: hidden;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);

    .el-pager li {
      background-color: white;

      &.is-active {
        background-color: var(--primary-color);
        color: white;
        font-weight: bold;
      }

      &:hover:not(.is-active) {
        color: var(--primary-color);
      }
    }

    .btn-prev, .btn-next {
      background-color: white;

      &:hover {
        color: var(--primary-color);
      }
    }
  }
}

.buttonDiv {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 50px;
  color: var(--text-secondary);
  gap: 16px;

  .count-highlight {
    color: var(--primary-color);
    font-weight: bold;
  }

  .load-more-btn {
    display: flex;
    align-items: center;
    gap: 5px;
    padding: 8px 16px;
    transition: all 0.3s;

    &:hover {
      transform: translateY(-2px);
    }
  }
}

:deep(.el-table__placeholder) {
  display: none;
}

.mt-20 {
  margin-top: 20px;
}

.custom-dialog {
  :deep(.el-dialog) {
    border-radius: 12px;
    overflow: hidden;
    box-shadow: 0 12px 32px rgba(0, 0, 0, 0.1);

    .el-dialog__header {
      background-color: var(--primary-color);
      color: white;
      padding: 15px 20px;
      margin: 0;

      .el-dialog__title {
        color: white;
        font-weight: 600;
        font-size: 18px;
      }

      .el-dialog__headerbtn {
        .el-dialog__close {
          color: white;
          font-size: 18px;

          &:hover {
            color: #f2f2f2;
          }
        }
      }
    }

    .el-dialog__body {
      padding: 24px;
    }

    .el-dialog__footer {
      padding: 10px 24px 24px;
      border-top: 1px solid var(--border-light);
    }
  }

  .dialog-footer {
    display: flex;
    justify-content: flex-end;
    gap: 12px;

    .el-button {
      padding: 10px 20px;
      display: flex;
      align-items: center;
      gap: 5px;
    }
  }

  .selected-info {
    margin-bottom: 20px;

    .selected-count {
      margin-top: 5px;
      font-size: 14px;

      .count-highlight {
        color: var(--primary-color);
        font-weight: bold;
        font-size: 16px;
      }
    }
  }

  .folder-option {
    display: flex;
    align-items: center;
    gap: 8px;

    .folder-icon {
      color: #E6A23C;
    }
  }

  &.test-paper-dialog {
    .test-form {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 16px;

      .el-form-item {
        margin-bottom: 16px;
      }

      // 让某些表单项占据整行
      .el-form-item:nth-child(5),
      .el-form-item:nth-child(11),
      .el-form-item:nth-child(12),
      .el-form-item:nth-child(13),
      .el-form-item:nth-child(14),
      .el-form-item:nth-child(15),
      .el-form-item:nth-child(16),
      .el-form-item:nth-child(17),
      .el-form-item:nth-child(18),
      .el-form-item:last-child {
        grid-column: span 2;
      }

      .form-actions {
        display: flex;
        justify-content: flex-end;
        gap: 12px;
        margin-top: 16px;

        .el-button {
          padding: 10px 20px;
          display: flex;
          align-items: center;
          gap: 5px;
        }
      }
    }
  }

  &.progress-dialog {
    .progress-container {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 20px;
      padding: 10px 0;

      .progress-icon {
        font-size: 48px;
        color: var(--primary-color);
        display: flex;
        justify-content: center;
        align-items: center;

        &.success-icon {
          color: var(--success-color);
        }

        .loading-icon {
          animation: spin 1.5s linear infinite;
        }
      }

      .progress-text {
        margin-top: 10px;
        font-size: 16px;
        color: var(--text-regular);
        text-align: center;
      }
    }

    .progress-button {
      width: 100%;
      padding: 12px;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      font-size: 16px;
    }
  }
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

:deep(.el-tag) {
  display: flex;
  align-items: center;
  justify-content: space-between;
  max-width: 150px;
  overflow: hidden;
  margin-bottom: 5px;

  .el-tag__content {
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    flex-grow: 1;
  }

  .el-tag__close {
    flex-shrink: 0;
    margin-left: 8px;
  }
}

.ghost {
  border: solid 1px var(--primary-color);
}

.chosenClass {
  background-color: var(--primary-light);
}

/* 快速组卷对话框样式 */
.quick-test-dialog {
  .form-section {
    margin-bottom: 24px;
    border: 1px solid var(--border-light);
    border-radius: 8px;
    padding: 16px;
    background-color: #f9f9f9;

    .section-title {
      margin-top: 0;
      margin-bottom: 16px;
      font-size: 18px;
      color: var(--primary-color);
      border-bottom: 1px solid var(--border-light);
      padding-bottom: 8px;
    }

    .form-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 16px;

      @media (max-width: 768px) {
        grid-template-columns: 1fr;
      }

      .el-form-item:nth-child(5) {
        grid-column: span 2;
      }
    }
  }

  .question-types-container {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;

    @media (max-width: 768px) {
      grid-template-columns: 1fr;
    }

    .question-type-item {
      border: 1px solid var(--border-light);
      border-radius: 6px;
      padding: 12px;
      background-color: white;

      .type-header {
        margin-bottom: 12px;
        font-weight: bold;
      }

      .type-settings {
        .setting-item {
          margin-bottom: 12px;
          display: flex;
          align-items: center;
          gap: 8px;

          .setting-label {
            min-width: 50px;
            font-size: 14px;
            color: var(--text-secondary);
          }

          .el-slider {
            flex: 1;
          }
        }
      }
    }
  }

  .intelligent-settings {
    background-color: white;
    border-radius: 6px;
    padding: 16px;

    .setting-description {
      margin-top: 4px;
      font-size: 12px;
      color: var(--text-secondary);
      line-height: 1.4;
    }
  }
}
</style>