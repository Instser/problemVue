<script setup>
import tinymce from 'tinymce/tinymce'
import Editor from '@tinymce/tinymce-vue'
import 'tinymce/plugins/image'
import 'tinymce/plugins/wordcount'
import {ref} from "vue";

const init = {
  selector: 'textarea',
  language: 'zh_CN',
  height: 500,
  statusbar: false, // 显示下方操作栏
  image_dimensions: false, // 禁止操作图片
  plugins: 'link lists image code table wordcount image', // 富文本插件
  font_size_formats: '8px 10px 12px 14px 16px 18px 24px 36px 48px 128px', // 字体大小文本
  font_family_formats:
      '微软雅黑=Microsoft YaHei,Helvetica Neue,PingFang SC,sans-serif;苹果苹方=PingFang SC,Microsoft YaHei,sans-serif;宋体=simsun,serif', // 字体选择配置
  toolbar:
      'undo redo fontfamily fontsize fontname bold italic underline strikethrough | fontsizeselect | forecolor | alignleft aligncenter alignright | image',  // 菜单栏配置
  branding: false, // //是否禁用“Powered by TinyMCE”
  menubar: false, //顶部菜单栏显示
  paste_data_images: false // 禁止粘贴图片
}
const tinymceHtml = ref('')
const subHandler = () => {
  console.log(tinymceHtml.value)
}
tinymce.init({
  selector: 'textarea',
  plugins: 'image',
  toolbar: 'image',
  images_upload_url: '/api/questions/uploadPicture'
})
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