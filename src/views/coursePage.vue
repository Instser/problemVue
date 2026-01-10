<script setup>
import {onMounted, onBeforeUnmount, ref} from "vue";
import axios from "axios";
import router from "@/router/router";
import {storage} from "@/storage/storage";
import {ElNotification, ElMessageBox} from "element-plus";
// eslint-disable-next-line no-unused-vars
import {Plus, Edit, Delete, User, View, InfoFilled, Bottom, Select, School, Check, Search} from "@element-plus/icons-vue";

const tableData = ref([])
const params = ref({
  page: 1,
  pageSize: 10 // 每次加载的数量改为较小的值，以便于测试懒加载
})
const count = ref(0)
const loading = ref(false)
const hasMoreData = ref(true)
// 不再需要多选功能
// const multipleSelection = ref([])
const courseDialogVisible = ref(false)
const dialogForm = ref({
  name: '',
  description: '',
  id: ''
})
const course1DialogVisible = ref(false)
const teacherDialogVisible = ref(false)
const teacherForm = ref([])
const allTeachers = ref([])
const selectedTeachers = ref([])
const teacherSearchKeyword = ref('')
const selectedCollege = ref('')
const collegeOptions = ref([])
const currentEditCourseId = ref(null)
const currentEditCourseName = ref('')

const getPage = (isInitial = false) => {
  // 如果已经在加载中，则不重复加载
  if (loading.value) {
    console.log('已经在加载中，忽略此次请求');
    return;
  }

  console.log('开始加载课程数据，页码:', params.value.page, '是否初始化:', isInitial);
  loading.value = true

  axios.get('/api/course/page', {
    params: {
      page: params.value.page,
      pageSize: params.value.pageSize
    }
  }).then(res => {
    if (res.data.code === 200) {
      const newData = res.data.data.list || [];
      console.log('获取到课程数量:', newData.length);

      if (isInitial) {
        tableData.value = newData;
      } else {
        tableData.value = [...tableData.value, ...newData];
      }
      count.value = res.data.data.count;

      // 判断是否还有更多数据
      const moreData = tableData.value.length < count.value;
      hasMoreData.value = moreData;

      console.log('数据加载完成:', {
        当前数据量: tableData.value.length,
        总数据量: count.value,
        还有更多数据: moreData
      });

      // 如果还有更多数据，增加页码
      if (hasMoreData.value) {
        params.value.page++;
      }
    } else if (res.data.code === 401) {
      console.log('用户未授权，跳转到登录页面');
      storage.remove('isAuthenticated');
      router.push('/login');
    } else {
      console.error('加载课程数据失败:', res.data);
      ElNotification({
        title: '加载失败',
        message: res.data.msg || '获取课程数据失败',
        type: 'error',
        duration: 3000
      });
    }
  }).catch(err => {
    console.error('请求课程数据出错:', err);
    ElNotification({
      title: '加载失败',
      message: '网络错误，请稍后重试',
      type: 'error',
      duration: 3000
    });
  }).finally(() => {
    loading.value = false;
  });
}
const handleScroll = () => {
  // 获取滚动位置信息
  const scrollTop = document.documentElement.scrollTop || document.body.scrollTop
  const scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight
  const clientHeight = document.documentElement.clientHeight || window.innerHeight

  // 计算距离底部的距离
  const distanceToBottom = scrollHeight - scrollTop - clientHeight

  // 调试信息
  console.log('课程页面滚动检测:', {
    hasMoreData: hasMoreData.value,
    loading: loading.value,
    scrollTop,
    scrollHeight,
    clientHeight,
    distanceToBottom,
    tableDataLength: tableData.value.length,
    totalCount: count.value
  })

  // 检查是否滚动到底部附近，并且还有更多数据可加载，且当前不在加载状态
  if (hasMoreData.value && !loading.value) {
    // 当滚动到距离底部300px时加载更多数据（增大触发区域）
    if (distanceToBottom < 300) {
      console.log('触发加载更多课程数据')
      getPage()
    }
  }
}

const courseDelete = (row) => {
  // 显示确认对话框
  ElMessageBox.confirm(`确定要删除课程「${row.name}」吗？\n注意：删除课程后，相关的试题和文件夹将无法访问。`, '删除确认', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    // 用户确认删除，执行删除操作
    axios.get('/api/course/deleteCourse', {
      params: {
        id: row.id
      }
    }).then(res => {
      if (res.data.code === 200) {
        // 重置页码和状态
        params.value.page = 1
        hasMoreData.value = true

        // 重新加载数据
        getPage(true);

        ElNotification({
          title: '删除成功',
          type: 'success'
        });

        // 记录用户活动
        const userId = storage.get('userId');
        console.log('删除课程时的用户ID:', userId); // 调试用
        if (userId) {
          axios.post('/api/userActivity/record', null, {
            params: {
              userId: userId,
              type: '删除课程',
              name: row.name || '课程',
              objectId: row.id
            }
          }).then(res => {
            console.log('记录活动成功:', res.data);
          }).catch(error => {
            console.error('记录活动失败:', error);
          });
        } else {
          console.error('用户ID不存在，无法记录活动');
        }
      } else {
        ElNotification({
          title: '删除失败',
          message: res.data.message || '服务器返回错误，请稍后重试',
          type: 'error'
        });
      }
    }).catch(error => {
      console.error('删除课程请求失败:', error);
      ElNotification({
        title: '删除请求失败',
        message: '网络错误或服务器异常，请稍后重试',
        type: 'error'
      });
    });
  }).catch(() => {
    // 用户取消删除，不执行任何操作
    ElNotification({
      title: '已取消删除',
      type: 'info'
    });
  });
}
// 不再需要表格多选功能
// const handleSelectionChange = (val) => {
//   multipleSelection.value = val
// }
const creatCourse = () => {
  axios.post('/api/course/addCourse', JSON.parse(JSON.stringify({
    name: dialogForm.value.name,
    description: dialogForm.value.description
  }))).then(res => {
    console.log('创建课程响应:', res.data.code)
    if (res.data.code === 200) {
      // 重置页码和状态
      params.value.page = 1
      hasMoreData.value = true

      // 重新加载数据
      getPage(true);

      ElNotification({
        title: '创建成功',
        type: 'success'
      });

      // 记录用户活动
      const userId = storage.get('userId');
      console.log('添加课程时的用户ID:', userId); // 调试用
      if (userId) {
        axios.post('/api/userActivity/record', null, {
          params: {
            userId: userId,
            type: '添加课程',
            name: dialogForm.value.name || '课程',
            objectId: res.data.data
          }
        }).then(res => {
          console.log('记录活动成功:', res.data);
        }).catch(error => {
          console.error('记录活动失败:', error);
        });
      } else {
        console.error('用户ID不存在，无法记录活动');
      }
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
    // 重置页码和状态
    params.value.page = 1
    hasMoreData.value = true

    // 重新加载数据
    getPage(true)
    console.log('修改课程响应:', res.data)

    if (res.data.code === 200) {
      ElNotification({
        title: '修改成功',
        type: 'success'
      });

      // 记录用户活动
      const userId = storage.get('userId');
      console.log('修改课程时的用户ID:', userId); // 调试用
      if (userId) {
        axios.post('/api/userActivity/record', null, {
          params: {
            userId: userId,
            type: '修改课程',
            name: dialogForm.value.name || '课程',
            objectId: dialogForm.value.id
          }
        }).then(res => {
          console.log('记录活动成功:', res.data);
        }).catch(error => {
          console.error('记录活动失败:', error);
        });
      } else {
        console.error('用户ID不存在，无法记录活动');
      }
    } else {
      ElNotification({
        title: '修改失败',
        type: 'error'
      });
    }
  })
}


const editTeacher = (row) => {
  // 保存当前编辑的课程ID和名称
  currentEditCourseId.value = row.id;
  currentEditCourseName.value = row.name;

  // 重置选中的教师列表
  selectedTeachers.value = [];

  // 获取教师列表，并在获取成功后处理已关联教师
  axios.get('/api/user/getAllTeachers')
    .then(res => {
      if (res.data.code === 200) {
        allTeachers.value = res.data.data || [];
        console.log('获取到教师列表:', allTeachers.value);

        // 提取所有不重复的学院选项
        const colleges = new Set();
        allTeachers.value.forEach(teacher => {
          if (teacher.college) {
            colleges.add(teacher.college);
          }
        });
        collegeOptions.value = Array.from(colleges).map(college => ({
          value: college,
          label: college
        }));

        // 添加"全部"选项
        collegeOptions.value.unshift({ value: '', label: '全部学院' });

        // 重置学院筛选
        selectedCollege.value = '';

        // 如果课程已有关联教师，设置为已选中
        if (row.teaNamesStr) {
          const currentTeacherNames = row.teaNamesStr.split(',');
          teacherForm.value = currentTeacherNames;

          // 根据教师昵称找到对应的教师对象，并添加到已选教师列表中
          currentTeacherNames.forEach(teacherName => {
            // 先尝试通过昵称查找
            let foundTeacher = allTeachers.value.find(t => t.nickname === teacherName);
            // 如果通过昵称找不到，再尝试通过用户名查找（兼容旧数据）
            if (!foundTeacher) {
              foundTeacher = allTeachers.value.find(t => t.username === teacherName);
            }
            if (foundTeacher) {
              selectedTeachers.value.push(foundTeacher);
            }
          });
        } else {
          teacherForm.value = [];
        }
      } else {
        console.error('获取教师列表失败:', res.data);
        ElNotification({
          title: '获取教师列表失败',
          message: res.data.message || '服务器返回错误',
          type: 'error'
        });
      }
    })
    .catch(error => {
      console.error('获取教师列表请求失败:', error);
      ElNotification({
        title: '获取教师列表失败',
        message: '网络错误或服务器异常',
        type: 'error'
      });
    });
}

// 根据关键词和学院过滤教师列表，并排除已选中的教师
const filteredTeachers = () => {
  // 首先过滤掉已选中的教师
  let availableTeachers = allTeachers.value.filter(teacher =>
    !selectedTeachers.value.some(selected => selected.id === teacher.id)
  );

  // 根据选择的学院进行过滤
  if (selectedCollege.value) {
    availableTeachers = availableTeachers.filter(teacher =>
      teacher.college === selectedCollege.value
    );
  }

  // 然后根据关键词进行过滤
  if (!teacherSearchKeyword.value) {
    return availableTeachers;
  }

  return availableTeachers.filter(teacher =>
    teacher.username.toLowerCase().includes(teacherSearchKeyword.value.toLowerCase()) ||
    (teacher.nickname && teacher.nickname.toLowerCase().includes(teacherSearchKeyword.value.toLowerCase()))
  );
}

// 选择教师
const handleTeacherSelect = (teacher) => {
  // 由于filteredTeachers已经过滤掉了已选中的教师，这里可以直接添加
  selectedTeachers.value.push(teacher);
}

// 移除已选教师
const removeTeacher = (teacher) => {
  selectedTeachers.value = selectedTeachers.value.filter(t => t.id !== teacher.id);
}

const saveTeachers = () => {
  // 获取选中教师的ID列表
  const teacherIds = selectedTeachers.value.map(teacher => teacher.id);

  // 调用后端API保存教师关联
  axios.post('/api/teaCour/updateCourseTeachers', {
    courseId: currentEditCourseId.value,
    teacherIds: teacherIds
  }).then(res => {
    if (res.data.code === 200) {
      // 关闭对话框
      teacherDialogVisible.value = false;

      ElNotification({
        title: '任课老师修改成功',
        type: 'success'
      });

      // 记录用户活动
      const userId = storage.get('userId');
      if (userId) {
        axios.post('/api/userActivity/record', null, {
          params: {
            userId: userId,
            type: '修改任课老师',
            name: currentEditCourseName.value || '课程',
            objectId: currentEditCourseId.value
          }
        }).then(res => {
          console.log('记录活动成功:', res.data);
        }).catch(error => {
          console.error('记录活动失败:', error);
        });
      }

      // 重置页码和状态
      params.value.page = 1;
      hasMoreData.value = true;

      // 重新加载数据
      getPage(true);
    } else {
      ElNotification({
        title: '修改任课老师失败',
        message: res.data.message || '服务器返回错误',
        type: 'error'
      });
    }
  }).catch(error => {
    console.error('修改任课老师请求失败:', error);
    ElNotification({
      title: '修改任课老师失败',
      message: '网络错误或服务器异常',
      type: 'error'
    });
  });
}
// 设置事件监听器
const setupEventListeners = () => {
  // 移除可能存在的旧监听器，防止重复监听
  window.removeEventListener('scroll', handleScroll)

  // 添加新的监听器
  window.addEventListener('scroll', handleScroll)

  console.log('课程页面滚动事件监听器已设置')
}

onMounted(() => {
  console.log('课程管理页面初始化')

  // 设置初始状态
  hasMoreData.value = true
  loading.value = false

  // 设置事件监听器
  setupEventListeners()

  // 初始加载数据
  getPage(true)

  // 初始化完成后，手动触发一次滚动检测
  setTimeout(() => {
    handleScroll()
    console.log('初始化完成，触发滚动检测')
  }, 500)
})

onBeforeUnmount(() => {
  console.log('课程管理页面销毁，移除事件监听')
  // 移除滚动监听
  window.removeEventListener('scroll', handleScroll)
})
</script>

<template>
  <div class="app-card main-container">
    <div class="header-actions">
      <div class="left-actions">
        <el-button type="primary" @click="courseDialogVisible = true">
          <el-icon><Plus /></el-icon>
          <span>创建课程</span>
        </el-button>
      </div>
    </div>
    <el-dialog v-model="courseDialogVisible"
               title="创建课程"
               width="550"
               align-center
               :close-on-click-modal="false"
               class="custom-dialog"
               @closed="() =>  dialogForm = {}">
      <div class="course-form-container">
        <div class="form-header">
          <el-icon class="icon"><School /></el-icon>
          <h3 class="title">课程信息</h3>
        </div>

        <el-form :model="dialogForm" label-position="top">
          <el-form-item label="课程名称">
            <el-input
              v-model="dialogForm.name"
              autocomplete="off"
              placeholder="请输入课程名称"
              prefix-icon="Reading"
            />
          </el-form-item>
          <el-form-item label="课程描述">
            <el-input
              v-model="dialogForm.description"
              type="textarea"
              :rows="4"
              placeholder="请输入课程描述信息，如课程内容、学时等"
              resize="none"
            />
          </el-form-item>
        </el-form>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="courseDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="courseDialogVisible = false; creatCourse()">
            <el-icon><Plus /></el-icon>
            <span>创建课程</span>
          </el-button>
        </div>
      </template>
    </el-dialog>
    <el-dialog v-model="teacherDialogVisible"
               title="管理任课老师"
               width="650"
               align-center
               :close-on-click-modal="false"
               class="custom-dialog"
               @closed="() => { teacherForm = []; selectedTeachers = []; teacherSearchKeyword = ''; }">
      <div class="teacher-manager">
        <div class="teacher-list">
          <div class="section-title">
            <el-icon class="icon current-icon"><User /></el-icon>
            <span>已选教师</span>
          </div>
          <div class="teacher-tags">
            <template v-if="selectedTeachers.length > 0">
              <el-tag
                  v-for="teacher in selectedTeachers"
                  :key="teacher.id"
                  closable
                  :disable-transitions="false"
                  @close="removeTeacher(teacher)"
                  class="teacher-tag"
                  type="success"
                  effect="light"
              >
                <el-icon><User /></el-icon>
                <span style="margin-left: 5px">{{ teacher.nickname || '无昵称' }}</span>
              </el-tag>
            </template>
            <el-empty v-else description="暂无选择任课老师" :image-size="100"></el-empty>
          </div>
        </div>

        <div class="add-teacher">
          <div class="section-title">
            <el-icon class="icon add-icon"><Plus /></el-icon>
            <span>添加教师</span>
          </div>

          <div class="search-container">
            <div class="search-row">
              <el-input
                v-model="teacherSearchKeyword"
                placeholder="搜索教师（账号或昵称）"
                clearable
                class="search-input"
                prefix-icon="Search"
              />
              <el-select
                v-model="selectedCollege"
                placeholder="选择学院"
                clearable
                class="college-select"
              >
                <el-option
                  v-for="item in collegeOptions"
                  :key="item.value"
                  :label="item.label"
                  :value="item.value"
                />
              </el-select>
            </div>
          </div>

          <div class="teachers-list-container">
            <div class="section-subtitle">可选教师列表</div>
            <div class="teachers-grid">
              <el-card
                v-for="teacher in filteredTeachers()"
                :key="teacher.id"
                class="teacher-card"
                shadow="hover"
                @click="handleTeacherSelect(teacher)"
              >
                <div class="teacher-info">
                  <el-icon class="teacher-icon"><User /></el-icon>
                  <div class="teacher-details">
                    <div class="teacher-nickname">{{ teacher.nickname || '无昵称' }}</div>
                  </div>
                </div>
              </el-card>
              <el-empty v-if="filteredTeachers().length === 0" description="未找到匹配的教师" :image-size="80"></el-empty>
            </div>
          </div>
        </div>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="teacherDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="saveTeachers">
            <el-icon><Check /></el-icon>
            <span>保存修改</span>
          </el-button>
        </div>
      </template>
    </el-dialog>
    <el-dialog v-model="course1DialogVisible"
               title="修改课程"
               width="550"
               align-center
               :close-on-click-modal="false"
               class="custom-dialog"
               @closed="() =>  dialogForm = {}">
      <div class="course-form-container">
        <div class="form-header">
          <el-icon class="icon"><Edit /></el-icon>
          <h3 class="title">编辑课程信息</h3>
        </div>

        <el-form :model="dialogForm" label-position="top">
          <el-form-item label="课程名称">
            <el-input
              v-model="dialogForm.name"
              autocomplete="off"
              placeholder="请输入课程名称"
              prefix-icon="Reading"
            />
          </el-form-item>
          <el-form-item label="课程描述">
            <el-input
              v-model="dialogForm.description"
              type="textarea"
              :rows="4"
              placeholder="请输入课程描述信息，如课程内容、学时等"
              resize="none"
            />
          </el-form-item>
        </el-form>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="course1DialogVisible = false">取消</el-button>
          <el-button type="primary" @click="course1DialogVisible = false; primaryCourse()">
            <el-icon><Edit /></el-icon>
            <span>保存修改</span>
          </el-button>
        </div>
      </template>
    </el-dialog>
    <div class="course-cards-container">
      <div v-if="tableData.length === 0" class="empty-state">
        <el-empty description="暂无课程数据" :image-size="200">
          <el-button type="primary" @click="courseDialogVisible = true">
            <el-icon><Plus /></el-icon>
            <span>创建第一个课程</span>
          </el-button>
        </el-empty>
      </div>

      <div v-else class="course-cards">
        <el-card v-for="(course, index) in tableData" :key="course.id" class="course-card" shadow="hover">
          <template #header>
            <div class="card-header">
              <h3 class="course-name" @click="() => {router.push('/home')}">
                {{ course.name }}
              </h3>
              <div class="card-actions">
                <el-button circle @click="editCourse(course);course1DialogVisible = true" type="primary" size="small">
                  <el-icon><Edit /></el-icon>
                </el-button>
                <el-button circle @click="courseDelete(course)" type="danger" size="small">
                  <el-icon><Delete /></el-icon>
                </el-button>
              </div>
            </div>
          </template>

          <div class="course-content">
            <div class="course-info">
              <div class="info-item">
                <div class="info-label">课程编号</div>
                <div class="info-value">{{ index + 1 }}</div>
              </div>
              <div class="info-item">
                <div class="info-label">描述</div>
                <div class="info-value description">{{ course.description || '暂无描述' }}</div>
              </div>
              <div class="info-item">
                <div class="info-label">任课老师</div>
                <div class="info-value teachers">
                  <template v-if="course.teaNamesStr">
                    <el-tag
                      v-for="(teacher, idx) in course.teaNamesStr.split(',')"
                      :key="idx"
                      size="small"
                      class="teacher-tag"
                      type="info"
                      effect="plain"
                    >
                      {{ teacher }}
                    </el-tag>
                  </template>
                  <el-tag v-else size="small" type="info" effect="plain">暂无任课老师</el-tag>
                </div>
              </div>
            </div>

            <div class="course-actions">
              <el-button type="primary" @click="editTeacher(course);teacherDialogVisible = true">
                <el-icon><User /></el-icon>
                <span>关联教师</span>
              </el-button>
            </div>
          </div>
        </el-card>
      </div>

      <div class="course-summary">
        <el-tag type="info" effect="plain" class="summary-tag">
          <el-icon><InfoFilled /></el-icon>
          <span>总共有 <span class="count-highlight">{{ count }}</span> 门课程</span>
        </el-tag>
      </div>
    </div>

    <div class="loading-state" v-if="loading">
      <el-skeleton style="width: 100%" animated>
        <template #template>
          <div style="display: flex; justify-content: space-between; gap: 20px;">
            <el-skeleton-item variant="card" style="width: 30%; height: 200px" />
            <el-skeleton-item variant="card" style="width: 30%; height: 200px" />
            <el-skeleton-item variant="card" style="width: 30%; height: 200px" />
          </div>
        </template>
      </el-skeleton>
    </div>

    <div class="scroll-tip" v-if="hasMoreData && !loading">
      <el-tag type="primary" effect="light" class="tip-tag">
        <el-icon><Bottom /></el-icon>
        <span>继续滚动加载更多课程</span>
      </el-tag>
    </div>

    <div class="scroll-tip" v-if="!hasMoreData && tableData.length > 0">
      <el-tag type="success" effect="light" class="tip-tag">
        <el-icon><Select /></el-icon>
        <span>已加载全部课程</span>
      </el-tag>
    </div>

    <!-- 加载更多按钮 - 作为滚动加载的备选方案 -->
    <div class="load-more-container" v-if="hasMoreData && !loading">
      <el-button
        type="primary"
        @click="getPage()"
        :loading="loading"
        class="load-more-button"
      >
        <el-icon><Bottom /></el-icon>
        <span>点击加载更多课程</span>
      </el-button>
    </div>
  </div>
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

  .left-actions {
    display: flex;
    gap: 10px;

    .el-button {
      display: flex;
      align-items: center;
      gap: 5px;
    }
  }
}

.course-cards-container {
  margin-bottom: 20px;

  .empty-state {
    background-color: #fff;
    border-radius: 8px;
    box-shadow: var(--box-shadow);
    padding: 40px 0;
    text-align: center;
  }

  .course-cards {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 20px;
    margin-bottom: 20px;

    .course-card {
      border-radius: 8px;
      overflow: hidden;
      transition: all 0.3s;
      height: 100%;
      display: flex;
      flex-direction: column;

      &:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
      }

      .card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;

        .course-name {
          margin: 0;
          font-size: 18px;
          font-weight: 600;
          color: var(--primary-color);
          cursor: pointer;
          transition: all 0.3s;

          &:hover {
            color: var(--primary-dark);
            text-decoration: underline;
          }
        }

        .card-actions {
          display: flex;
          gap: 8px;
        }
      }

      .course-content {
        display: flex;
        flex-direction: column;
        flex: 1;

        .course-info {
          flex: 1;

          .info-item {
            margin-bottom: 12px;

            .info-label {
              font-size: 14px;
              color: var(--text-secondary);
              margin-bottom: 4px;
            }

            .info-value {
              font-size: 14px;
              color: var(--text-primary);

              &.description {
                line-height: 1.5;
                max-height: 60px;
                overflow: hidden;
                text-overflow: ellipsis;
                display: -webkit-box;
                -webkit-line-clamp: 2;
                line-clamp: 2;
                -webkit-box-orient: vertical;
              }

              &.teachers {
                display: flex;
                flex-wrap: wrap;
                gap: 6px;

                .teacher-tag {
                  margin-right: 0;
                }
              }
            }
          }
        }

        .course-actions {
          margin-top: 16px;
          display: flex;
          justify-content: flex-end;

          .el-button {
            display: flex;
            align-items: center;
            gap: 5px;
          }
        }
      }
    }
  }

  .course-summary {
    display: flex;
    justify-content: center;
    margin-top: 10px;

    .summary-tag {
      display: flex;
      align-items: center;
      gap: 5px;
      padding: 8px 16px;
      font-size: 14px;

      .count-highlight {
        color: var(--primary-color);
        font-weight: bold;
      }
    }
  }

  .loading-state {
    margin: 20px 0;
  }

  .scroll-tip {
    display: flex;
    justify-content: center;
    margin: 20px 0;

    .tip-tag {
      display: flex;
      align-items: center;
      gap: 5px;
      padding: 8px 16px;
      font-size: 14px;
      animation: pulse 1.5s infinite;
    }
  }

  .load-more-container {
    display: flex;
    justify-content: center;
    margin: 20px 0;

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
}

.pagination-container {
  display: flex;
  justify-content: center;
  margin-top: 16px;
}

.buttonDiv {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 40px;
  color: var(--text-secondary);
}

.action-buttons {
  display: flex;
  gap: 8px;
  justify-content: center;

  .el-button {
    display: flex;
    align-items: center;
    gap: 4px;
    padding: 4px 8px;

    &:hover {
      background-color: var(--primary-light);
      border-radius: 4px;
    }
  }
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

  .form-header-icon {
    font-size: 24px;
    margin-right: 8px;
    vertical-align: middle;
    color: var(--primary-color);
  }

  .teacher-manager {
    .section-title {
      font-size: 16px;
      font-weight: 500;
      margin-bottom: 12px;
      color: var(--text-primary);
      display: flex;
      align-items: center;

      .icon {
        margin-right: 8px;
        font-size: 20px;

        &.current-icon {
          color: var(--success-color);
        }

        &.add-icon {
          color: var(--primary-color);
        }
      }
    }

    .section-subtitle {
      font-size: 14px;
      font-weight: 500;
      margin: 12px 0 8px;
      color: var(--text-secondary);
    }

    .teacher-list {
      margin-bottom: 24px;

      .teacher-tags {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        min-height: 100px;
        padding: 16px;
        background-color: var(--background-color);
        border-radius: 8px;
      }
    }

    .add-teacher {
      .search-container {
        margin-bottom: 16px;

        .search-row {
          display: flex;
          gap: 10px;

          .search-input {
            flex: 1;
          }

          .college-select {
            width: 150px;
          }
        }
      }

      .teachers-list-container {
        .teachers-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
          gap: 12px;
          max-height: 300px;
          overflow-y: auto;
          padding: 8px;
          background-color: var(--background-color);
          border-radius: 8px;

          .teacher-card {
            cursor: pointer;
            transition: all 0.2s;

            &:hover {
              transform: translateY(-2px);
              box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
              border-color: var(--primary-color);
            }

            .teacher-info {
              display: flex;
              align-items: center;

              .teacher-icon {
                font-size: 20px;
                color: var(--primary-color);
                margin-right: 10px;
              }

              .teacher-details {
                .teacher-nickname {
                  font-weight: 500;
                  color: var(--text-primary);
                  font-size: 14px;
                }
              }
            }
          }
        }
      }
    }
  }

  .course-form-container {
    .form-header {
      margin-bottom: 20px;
      padding-bottom: 16px;
      border-bottom: 1px solid var(--border-light);
      display: flex;
      align-items: center;

      .icon {
        font-size: 24px;
        margin-right: 12px;
        color: var(--primary-color);
      }

      .title {
        font-size: 18px;
        font-weight: 500;
        color: var(--text-primary);
        margin: 0;
      }
    }
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
</style>