<script setup>
import { ref, onMounted } from "vue";
import { ElMessage, ElMessageBox } from "element-plus";
import axios from "axios";
import { storage } from "@/storage/storage";
import router from "@/router/router";

// 表格数据
const tableData = ref([]);
const loading = ref(false);
const total = ref(0);

// 查询参数
const queryParams = ref({
  page: 1,
  pageSize: 10,
  title: ""
});

// 表单数据
const formVisible = ref(false);
const formLoading = ref(false);
const formTitle = ref("添加公告");
const form = ref({
  id: null,
  title: "",
  content: "",
  status: true,
  isTop: false
});

// 表单校验规则
const rules = {
  title: [
    { required: true, message: "请输入公告标题", trigger: "blur" },
    { min: 1, max: 100, message: "长度在 1 到 100 个字符", trigger: "blur" }
  ],
  content: [
    { required: true, message: "请输入公告内容", trigger: "blur" }
  ]
};

// 获取公告列表
const getList = () => {
  loading.value = true;
  axios.get("/api/announcement/page", {
    params: queryParams.value
  }).then(res => {
    if (res.data.code === 401) {
      storage.remove("isAuthenticated");
      router.push("/login");
      return;
    }

    if (res.data.code === 200 || !res.data.code) {
      const data = res.data.code === 200 ? res.data.data : res.data;
      tableData.value = data.list || [];
      total.value = data.count || 0;
    }
  }).catch(error => {
    console.error("Failed to fetch announcements:", error);
    ElMessage.error("获取公告列表失败");
  }).finally(() => {
    loading.value = false;
  });
};

// 搜索
const handleSearch = () => {
  queryParams.value.page = 1;
  getList();
};

// 重置搜索
const resetSearch = () => {
  queryParams.value = {
    page: 1,
    pageSize: 10,
    title: ""
  };
  getList();
};

// 分页变化
const handleSizeChange = (val) => {
  queryParams.value.pageSize = val;
  getList();
};

const handleCurrentChange = (val) => {
  queryParams.value.page = val;
  getList();
};

// 打开表单
const openForm = (row) => {
  resetForm();
  if (row) {
    formTitle.value = "编辑公告";
    form.value = { ...row };
  } else {
    formTitle.value = "添加公告";
  }
  formVisible.value = true;
};

// 重置表单
const resetForm = () => {
  form.value = {
    id: null,
    title: "",
    content: "",
    status: true,
    isTop: false
  };
};

// 提交表单
const submitForm = async () => {
  formLoading.value = true;
  try {
    const url = form.value.id ? "/api/announcement/update" : "/api/announcement/add";
    const res = await axios.post(url, form.value);

    console.log("提交表单响应:", res);

    // 统一从 res.data.data 中获取响应数据
    if (res.data && res.data.code === 200 && res.data.data > 0) {
      ElMessage.success(form.value.id ? "更新成功" : "添加成功");
      formVisible.value = false;
      getList();

      // 通知其他页面刷新公告数据
      localStorage.setItem('announcement_updated', Date.now().toString());
    } else {
      console.error("操作失败，响应数据:", res.data);
      ElMessage.error(form.value.id ? "更新失败" : "添加失败");
    }
  } catch (error) {
    console.error("Form submission error:", error);
    ElMessage.error("操作失败，请稍后重试");
  } finally {
    formLoading.value = false;
  }
};

// 删除公告
const handleDelete = (id) => {
  ElMessageBox.confirm("确定要删除该公告吗？", "提示", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    type: "warning"
  }).then(() => {
    axios.get(`/api/announcement/delete?id=${id}`).then(res => {
      if (res.data && res.data.code === 200 && res.data.data > 0) {
        ElMessage.success("删除成功");
        getList();
        // 通知其他页面刷新公告数据
        localStorage.setItem('announcement_updated', Date.now().toString());
      } else {
        ElMessage.error("删除失败");
      }
    }).catch(error => {
      console.error("Delete error:", error);
      ElMessage.error("删除失败，请稍后重试");
    });
  }).catch(() => {});
};

// 更改状态
const handleStatusChange = (row) => {
  const status = row.status;
  axios.get(`/api/announcement/updateStatus?id=${row.id}&status=${status}`).then(res => {
    if (res.data && res.data.code === 200 && res.data.data > 0) {
      ElMessage.success(`${status ? '启用' : '禁用'}成功`);
      // 通知其他页面刷新公告数据
      localStorage.setItem('announcement_updated', Date.now().toString());
    } else {
      row.status = !status; // 恢复原状态
      ElMessage.error(`${status ? '启用' : '禁用'}失败`);
    }
  }).catch(error => {
    console.error("Status change error:", error);
    row.status = !status; // 恢复原状态
    ElMessage.error("操作失败，请稍后重试");
  });
};

// 更改置顶状态
const handleTopChange = (row) => {
  const isTop = row.isTop;
  axios.get(`/api/announcement/updateTopStatus?id=${row.id}&isTop=${isTop}`).then(res => {
    if (res.data && res.data.code === 200 && res.data.data > 0) {
      ElMessage.success(`${isTop ? '置顶' : '取消置顶'}成功`);
      // 通知其他页面刷新公告数据
      localStorage.setItem('announcement_updated', Date.now().toString());
    } else {
      row.isTop = !isTop; // 恢复原状态
      ElMessage.error(`${isTop ? '置顶' : '取消置顶'}失败`);
    }
  }).catch(error => {
    console.error("Top status change error:", error);
    row.isTop = !isTop; // 恢复原状态
    ElMessage.error("操作失败，请稍后重试");
  });
};

// 格式化日期
const formatDate = (dateString) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleString();
};

onMounted(() => {
  getList();
});
</script>

<template>
  <div class="announcement-container">
    <!-- 搜索区域 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="queryParams">
        <el-form-item label="公告标题">
          <el-input v-model="queryParams.title" placeholder="请输入公告标题" clearable @keyup.enter="handleSearch" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">
            <el-icon><Search /></el-icon>
            搜索
          </el-button>
          <el-button @click="resetSearch">
            <el-icon><Refresh /></el-icon>
            重置
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 操作区域 -->
    <el-card class="table-card">
      <template #header>
        <div class="card-header">
          <span>公告列表</span>
          <el-button type="primary" @click="openForm()">
            <el-icon><Plus /></el-icon>
            新增公告
          </el-button>
        </div>
      </template>

      <!-- 表格 -->
      <el-table
        v-loading="loading"
        :data="tableData"
        border
        style="width: 100%"
      >
        <el-table-column type="index" width="50" align="center" />
        <el-table-column prop="title" label="公告标题" min-width="150" show-overflow-tooltip />
        <el-table-column prop="content" label="公告内容" min-width="200" show-overflow-tooltip>
          <template #default="scope">
            <div v-html="scope.row.content"></div>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="160" align="center">
          <template #default="scope">
            {{ formatDate(scope.row.createTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="updateTime" label="更新时间" width="160" align="center">
          <template #default="scope">
            {{ formatDate(scope.row.updateTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="80" align="center">
          <template #default="scope">
            <el-switch
              v-model="scope.row.status"
              :active-value="true"
              :inactive-value="false"
              @change="handleStatusChange(scope.row)"
            />
          </template>
        </el-table-column>
        <el-table-column prop="isTop" label="置顶" width="80" align="center">
          <template #default="scope">
            <el-switch
              v-model="scope.row.isTop"
              :active-value="true"
              :inactive-value="false"
              @change="handleTopChange(scope.row)"
            />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" align="center">
          <template #default="scope">
            <el-button type="primary" link @click="openForm(scope.row)">
              <el-icon><Edit /></el-icon>
              编辑
            </el-button>
            <el-button type="danger" link @click="handleDelete(scope.row.id)">
              <el-icon><Delete /></el-icon>
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination">
        <el-pagination
          v-model:current-page="queryParams.page"
          v-model:page-size="queryParams.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 表单对话框 -->
    <el-dialog
      v-model="formVisible"
      :title="formTitle"
      width="700px"
      :close-on-click-modal="false"
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="80px"
      >
        <el-form-item label="标题" prop="title">
          <el-input v-model="form.title" placeholder="请输入公告标题" />
        </el-form-item>
        <el-form-item label="内容" prop="content">
          <el-input
            v-model="form.content"
            type="textarea"
            :rows="6"
            placeholder="请输入公告内容"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch
            v-model="form.status"
            :active-value="true"
            :inactive-value="false"
            active-text="启用"
            inactive-text="禁用"
          />
        </el-form-item>
        <el-form-item label="置顶">
          <el-switch
            v-model="form.isTop"
            :active-value="true"
            :inactive-value="false"
            active-text="是"
            inactive-text="否"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="formVisible = false">取消</el-button>
          <el-button type="primary" @click="submitForm" :loading="formLoading">
            确定
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<style lang="less" scoped>
.announcement-container {
  padding: 20px;
}

.search-card {
  margin-bottom: 20px;
}

.table-card {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

:deep(.el-table) {
  .cell {
    word-break: break-word;
  }
}
</style>
