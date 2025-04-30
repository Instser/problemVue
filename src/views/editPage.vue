<script setup>
import tinymce from 'tinymce/tinymce'
import Editor from '@tinymce/tinymce-vue'
import 'tinymce/plugins/image'
import 'tinymce/plugins/wordcount'
import 'tinymce/plugins/fullscreen'
import 'tinymce/plugins/autoresize'
import 'tinymce/models/dom'
import 'tinymce/themes/silver'
import 'tinymce/icons/default'
import {ref} from "vue";
import {useRoute} from "vue-router";
import axios from "axios";
import {ElNotification} from "element-plus";
import router from "@/router/router";
// 不再直接引入storage，由activityService内部使用
import activityService from "@/services/activityService";

const init = {
  selector: 'textarea',
  language: 'zh_CN',
  content_style: "img {max-width:30%;height: auto;}",
  autoresize_bottom_margin: 50, //編輯器初始化底边距。
  min_height: 600, //编辑器最小高度
  statusbar: false, // 显示下方操作栏
  image_dimensions: false, // 禁止操作图片
  images_upload_url: '/api/questions/uploadPicture',
  plugins: 'link lists image code table wordcount image  autoresize ', // 富文本插件
  font_size_formats: '8px 10px 12px 14px 16px 18px 24px 36px 48px 128px', // 字体大小文本
  font_family_formats:
      '微软雅黑=Microsoft YaHei,Helvetica Neue,PingFang SC,sans-serif;宋体=simsun,serif', // 字体选择配置
  toolbar:
      'undo redo fontfamily fontsize fontname bold italic underline strikethrough | fontsizeselect | forecolor | alignleft aligncenter alignright | image fullscreen',  // 菜单栏配置
  branding: false, // //是否禁用“Powered by TinyMCE”
  menubar: false, //顶部菜单栏显示
  paste_data_images: false // 禁止粘贴图片
}
const route = useRoute();
const questionForm = ref({
  description: '',
  quesCourId: '',
  chapter: '',
  typeName: '',
  typeId: '',
  hard: '',
  score: '',
  answer: ''
});

// 添加课程数组
const courseArr = ref([]);

// 获取所有课程
const getCourses = () => {
  axios.get('/api/course/page', {
    params: {
      page: 1,
      pageSize: 100 // 获取足够多的课程
    }
  }).then(res => {
    if (res.data.code === 200) {
      courseArr.value = res.data.data.list;
    }
  }).catch(error => {
    console.error('获取课程失败:', error);
  });
};
// 题型映射
const typeMap = {
  '选择题': 1,
  '填空题': 2,
  '简答题': 3,
  '证明题': 4
};

// 处理题型变化
const handleTypeChange = (value) => {
  questionForm.value.typeId = typeMap[value] || '';
};

// 正则表达式
const numReg = /^[0-9]*$/
const numRe = new RegExp(numReg)

const addQuestion = () => {
  // eslint-disable-next-line no-prototype-builtins
  if (questionForm.value.hasOwnProperty('id')) {
    //  有id存在就调用update接口更新问题
    axios.post('/api/questions/update', JSON.parse(JSON.stringify(
        questionForm.value
    ))).then(res => {
      if (res.data.code === 200) {
        ElNotification({
          title: '修改成功',
          type: 'success'
        });

        // 使用活动服务记录编辑试题活动
        const detailedName = activityService.formatQuestionInfo(questionForm.value, courseArr.value);
        activityService.recordActivity('编辑试题', detailedName, questionForm.value.id)
          .catch(error => console.error('记录编辑试题活动失败:', error));

        router.push('/questions');
      } else {
        ElNotification({
          title: '修改失败',
          type: 'error'
        });
      }
    });
    console.log('update')
  } else {
    // 没有id就用add添加问题。
    axios.post('/api/questions/add', JSON.parse(JSON.stringify(
        questionForm.value
        // eslint-disable-next-line no-unused-vars
    ))).then(res => {
      if (res.data.code === 200) {
        ElNotification({
          title: '试题添加成功',
          type: 'success'
        });

        // 使用活动服务记录创建试题活动
        const detailedName = activityService.formatQuestionInfo(questionForm.value, courseArr.value);
        activityService.recordActivity('创建试题', detailedName, res.data.data)
          .catch(error => console.error('记录创建试题活动失败:', error));

        router.push('/questions');
      } else {
        ElNotification({
          title: '试题添加失败',
          type: 'error'
        });
      }
    });
    console.log('add')
  }
}
const getQuestion = () => {
  console.log(route.query)
  if (route.query && numRe.test(route.query.id)) {
    console.log('post')
    axios.get('/api/questions/query', {
      params: {
        id: route.query.id
      }
    }).then(res => {
      console.log(res.data)
      questionForm.value = res.data.data
    })
  }
}

tinymce.init({})
getCourses() // 获取课程数据
getQuestion()
</script>

<template>
  <div>
    <div class="flex gap-4 mb-4">
      <span>课程</span>
      <el-select
          v-model="questionForm.quesCourId"
          style="width: 240px"
          placeholder="选择课程"
      >
        <el-option
          v-for="course in courseArr"
          :key="course.id"
          :label="course.name"
          :value="course.id"
        />
      </el-select>
      <span>章节</span>
      <el-input
          v-model="questionForm.chapter"
          style="width: 240px"
          placeholder="章节"
      />
      <span>难度</span>
      <el-select
          v-model="questionForm.hard"
          style="width: 240px"
          placeholder="选择难度"
      >
        <el-option label="简单" value="简单" />
        <el-option label="中等" value="中等" />
        <el-option label="困难" value="困难" />
      </el-select>
    </div>
    <div class="flex gap-4">
      <span>题型</span>
      <el-select
          v-model="questionForm.typeName"
          style="width: 240px"
          placeholder="选择题型"
          @change="handleTypeChange"
      >
        <el-option label="选择题" value="选择题" />
        <el-option label="填空题" value="填空题" />
        <el-option label="简答题" value="简答题" />
        <el-option label="证明题" value="证明题" />
      </el-select>
      <span>分值</span>
      <el-input
          v-model="questionForm.score"
          style="width: 240px"
          placeholder="分值">
      </el-input>
      <span>答案</span>
      <el-input
          v-model="questionForm.answer"
          style="width: 240px"
          placeholder="答案">
      </el-input>
      <!-- 类型ID已自动设置，无需显示 -->
      <input type="hidden" v-model="questionForm.typeId">
    </div>
  </div>
  <div class="app-container">
    <Editor
      id="tinymce"
      v-model="questionForm.description"
      :init="init"
    />
  </div>
  <div>
    <button type="submit" @click="addQuestion">提交</button>
  </div>
</template>

<style scoped>

</style>