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

const init = {
  selector: 'textarea',
  language: 'zh_CN',
  content_style: "img {max-width:100%;}",
  autoresize_bottom_margin: 50, //編輯器初始化底边距。
  min_height: 600, //编辑器最小高度
  statusbar: false, // 显示下方操作栏
  image_dimensions: false, // 禁止操作图片
  images_upload_url: '/api/questions/uploadPicture',
  plugins: 'link lists image code table wordcount image autoresize', // 富文本插件
  font_size_formats: '8px 10px 12px 14px 16px 18px 24px 36px 48px 128px', // 字体大小文本
  font_family_formats:
      '微软雅黑=Microsoft YaHei,Helvetica Neue,PingFang SC,sans-serif;宋体=simsun,serif', // 字体选择配置
  toolbar:
      'undo redo fontfamily fontsize fontname bold italic underline strikethrough | fontsizeselect | forecolor | alignleft aligncenter alignright | image fullscreen',  // 菜单栏配置
  branding: false, // //是否禁用“Powered by TinyMCE”
  menubar: false, //顶部菜单栏显示
  paste_data_images: false // 禁止粘贴图片
}
const tinymceHtml = ref('')
const subHandler = () => {
  console.log(JSON.parse(JSON.stringify({
    data: tinymceHtml.value
  })))
}
tinymce.init({})

const route = useRoute();
const getQuestion = () => {
  console.log(route.query)
}
getQuestion()
</script>

<template>
  <div class="app-container">
    <Editor
      id="tinymce"
      v-model="tinymceHtml"
      :init="init"
    />
  </div>
  <div>
    <button type="submit" @click="subHandler">提交</button>
  </div>
</template>

<style scoped>

</style>