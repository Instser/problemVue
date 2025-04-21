<script setup>
import {onMounted, onBeforeUnmount, ref} from "vue";
import axios from "axios";
import router from "@/router/router";
import {storage} from "@/storage/storage";
import {ElNotification} from "element-plus";
import {Plus, Edit, Delete, User, View, InfoFilled, Bottom, Select} from "@element-plus/icons-vue";

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
const teacherDialogVisible =ref(false)
const teacherForm = ref([])
const inputVisible =  ref(false)
const inputValue = ref('')

const getPage = (isInitial = false) => {
  loading.value = true
  axios.get('/api/course/page', {
    params: {
      page: params.value.page,
      pageSize: params.value.pageSize
    }
  }).then(res => {
    if (res.data.code === 200) {
      if (isInitial) {
        tableData.value = res.data.data.list
      } else {
        tableData.value = [...tableData.value, ...res.data.data.list]
      }
      count.value = res.data.data.count

      // 判断是否还有更多数据
      hasMoreData.value = tableData.value.length < count.value

      // 如果还有更多数据，增加页码
      if (hasMoreData.value) {
        params.value.page++
      }
    }
    if (res.data.code === 401) {
      storage.remove('isAuthenticated');
      router.push('/login')
    }
    loading.value = false
  }).catch(err => {
    console.error('Failed to fetch courses:', err)
    loading.value = false
  })
}
const handleScroll = () => {
  // 检查是否滚动到底部附近
  if (hasMoreData.value && !loading.value) {
    const scrollTop = document.documentElement.scrollTop || document.body.scrollTop
    const scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight
    const clientHeight = document.documentElement.clientHeight || window.innerHeight

    // 当滚动到距离底部200px时加载更多数据
    if (scrollTop + clientHeight >= scrollHeight - 200) {
      getPage()
    }
  }
}

const courseDelete = (row) => {
  axios.get('/api/course/deleteCourse', {
    params: {
      id: row.id
    }
  }).then(res => {
    if (res.data.code === 200) {
      // 重置页码并重新加载
      params.value.page = 1
      getPage(true);
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
    console.log(res.data.code)
    if (res.data.code === 200) {
      // 重置页码并重新加载
      params.value.page = 1
      getPage(true);
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
    // 重置页码并重新加载
    params.value.page = 1
    getPage(true)
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
  // 初始加载数据
  getPage(true)

  // 添加滚动监听
  window.addEventListener('scroll', handleScroll)
})

onBeforeUnmount(() => {
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
               width="500"
               align-center
               :close-on-click-modal="false"
               class="custom-dialog"
               @closed="() =>  dialogForm = {}">
      <el-form :model="dialogForm" label-position="top">
        <el-form-item label="课程名称">
          <el-input v-model="dialogForm.name" autocomplete="off" placeholder="请输入课程名称" />
        </el-form-item>
        <el-form-item label="课程描述">
          <el-input
            v-model="dialogForm.description"
            type="textarea"
            :rows="3"
            placeholder="请输入课程描述"
            resize="none"
          />
        </el-form-item>
      </el-form>
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
               width="500"
               align-center
               :close-on-click-modal="false"
               class="custom-dialog"
               @closed="() =>  teacherForm = []">
      <div class="teacher-manager">
        <div class="teacher-list">
          <div class="section-title">当前任课老师</div>
          <div class="teacher-tags">
            <template v-if="teacherForm.length > 0">
              <el-tag
                  v-for="(item, index) in teacherForm"
                  :key="index"
                  closable
                  :disable-transitions="false"
                  @close="removeTeacher(item)"
                  class="teacher-tag"
                  type="success"
                  effect="light"
              >
                {{ item }}
              </el-tag>
            </template>
            <el-empty v-else description="暂无任课老师" :image-size="100"></el-empty>
          </div>
        </div>

        <div class="add-teacher">
          <div class="section-title">添加新老师</div>
          <div class="input-container">
            <el-input
                v-if="inputVisible"
                v-model="inputValue"
                class="teacher-input"
                placeholder="输入老师名称后回车确认"
                @keyup.enter="handleInputConfirm"
                @blur="handleInputConfirm"
            >
              <template #append>
                <el-button @click="handleInputConfirm">添加</el-button>
              </template>
            </el-input>
            <el-button v-else type="primary" @click="showInput" class="add-button">
              <el-icon><Plus /></el-icon>
              <span>添加老师</span>
            </el-button>
          </div>
        </div>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="teacherDialogVisible = false">关闭</el-button>
        </div>
      </template>
    </el-dialog>
    <el-dialog v-model="course1DialogVisible"
               title="修改课程"
               width="500"
               align-center
               :close-on-click-modal="false"
               class="custom-dialog"
               @closed="() =>  dialogForm = {}">
      <el-form :model="dialogForm" label-position="top">
        <el-form-item label="课程名称">
          <el-input v-model="dialogForm.name" autocomplete="off" placeholder="请输入课程名称" />
        </el-form-item>
        <el-form-item label="课程描述">
          <el-input
            v-model="dialogForm.description"
            type="textarea"
            :rows="3"
            placeholder="请输入课程描述"
            resize="none"
          />
        </el-form-item>
      </el-form>
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
                <el-button circle @click="editTeacher(course);teacherDialogVisible = true" type="success" size="small">
                  <el-icon><User /></el-icon>
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
              <el-button type="primary" @click="() => {router.push('/home')}">
                <el-icon><View /></el-icon>
                <span>查看课程</span>
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

  .teacher-manager {
    .section-title {
      font-size: 16px;
      font-weight: 500;
      margin-bottom: 12px;
      color: var(--text-primary);
    }

    .teacher-list {
      margin-bottom: 24px;

      .teacher-tags {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        min-height: 100px;
        padding: 12px;
        background-color: var(--background-color);
        border-radius: 8px;
      }
    }

    .add-teacher {
      .input-container {
        display: flex;

        .teacher-input {
          width: 100%;
        }

        .add-button {
          width: 100%;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 5px;
        }
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