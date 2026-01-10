<script setup>
import tinymce from 'tinymce/tinymce'
import Editor from '@tinymce/tinymce-vue'

// 注册数学公式按钮和帮助按钮
tinymce.PluginManager.add('mathformula', function(editor) {
  // 添加一个命令，用于打开数学公式对话框
  editor.addCommand('openMathFormulaDialog', function(/* eslint-disable-next-line no-unused-vars */ ui, value) {
    // 创建预览区域
    const previewContainer = document.createElement('div');
    previewContainer.className = 'formula-preview-container';
    previewContainer.style.cssText = 'margin-top: 10px; padding: 10px; border: 1px solid #ddd; border-radius: 4px; min-height: 40px; background-color: #f9f9f9;';

    // 打开对话框
    editor.windowManager.open({
      title: '插入数学公式',
      body: {
        type: 'panel',
        items: [
          {
            type: 'textarea',
            name: 'formula',
            label: '输入LaTeX格式的数学公式',
            placeholder: '例如: \\frac{a}{b} 或 \\sum_{i=1}^{n} i^2'
          },
          {
            type: 'htmlpanel',
            html: '<div><label style="display: block; margin-bottom: 5px; font-weight: bold;">预览效果：</label><div id="formula-preview" style="min-height: 40px; padding: 10px; border: 1px solid #ddd; border-radius: 4px; background-color: #f9f9f9;"></div></div>'
          }
        ]
      },
      buttons: [
        {
          type: 'cancel',
          text: '取消'
        },
        {
          type: 'submit',
          text: '插入',
          primary: true
        }
      ],
      initialData: {
        formula: value || ''
      },
      onOpen: function(api) {
        // 对话框打开后，如果有初始值，立即触发预览更新
        setTimeout(function() {
          const formula = api.getData().formula.trim();
          const previewEl = document.getElementById('formula-preview');

          if (previewEl && formula) {
            // 清空预览区域
            previewEl.innerHTML = '';

            // 添加公式
            const mathSpan = document.createElement('span');
            mathSpan.className = 'math-tex';
            mathSpan.textContent = '$$' + formula + '$$';
            previewEl.appendChild(mathSpan);

            // 渲染公式
            if (window.MathJax) {
              try {
                window.MathJax.typesetClear([previewEl]);
                window.MathJax.typeset([previewEl]);
              } catch (e) {
                console.error('预览MathJax渲染错误:', e);
              }
            }
          }
        }, 100);
      },
      onAction: function(api, details) {
        if (details.name === 'formula') {
          // 当公式输入框内容变化时，更新预览
          const formula = api.getData().formula.trim();
          const previewEl = document.getElementById('formula-preview');

          if (previewEl && formula) {
            // 清空预览区域
            previewEl.innerHTML = '';

            // 添加公式
            const mathSpan = document.createElement('span');
            mathSpan.className = 'math-tex';
            mathSpan.textContent = '$$' + formula + '$$';
            previewEl.appendChild(mathSpan);

            // 渲染公式
            if (window.MathJax) {
              try {
                window.MathJax.typesetClear([previewEl]);
                window.MathJax.typeset([previewEl]);
              } catch (e) {
                console.error('预览MathJax渲染错误:', e);
              }
            }
          }
        }
      },
      onChange: function(api) {
        // 当公式输入框内容变化时，更新预览
        const formula = api.getData().formula.trim();
        const previewEl = document.getElementById('formula-preview');

        if (previewEl) {
          // 清空预览区域
          previewEl.innerHTML = '';

          if (formula) {
            // 添加公式
            const mathSpan = document.createElement('span');
            mathSpan.className = 'math-tex';
            mathSpan.textContent = '$$' + formula + '$$';
            previewEl.appendChild(mathSpan);

            // 渲染公式
            if (window.MathJax) {
              try {
                window.MathJax.typesetClear([previewEl]);
                window.MathJax.typeset([previewEl]);
              } catch (e) {
                console.error('预览MathJax渲染错误:', e);
              }
            }
          }
        }
      },
      onSubmit: function(api) {
        const data = api.getData();
        const formula = data.formula.trim();

        if (!formula) {
          api.close();
          return;
        }

        // 插入数学公式，使用$$包裹LaTeX公式，添加特殊类以便识别
        // 添加contenteditable="false"使公式作为一个整体，不可在内部编辑
        // 添加data-formula属性存储原始公式，以便后续编辑
        editor.insertContent('<span class="math-tex" contenteditable="false" data-formula="' + formula + '">$$' + formula + '$$</span>&nbsp;');
        api.close();

        // 延迟执行，确保内容已更新后渲染公式
        setTimeout(function() {
          if (window.MathJax) {
            try {
              // 尝试渲染编辑器内的公式
              const editorBody = editor.getBody();
              if (editorBody) {
                window.MathJax.typesetClear([editorBody]);
                window.MathJax.typeset([editorBody]);

                // 确保公式元素可见
                const mathElements = editorBody.querySelectorAll('.math-tex');
                mathElements.forEach(function(el) {
                  el.style.visibility = 'visible';
                  el.style.display = 'inline-block';
                });

                // 确保MathJax生成的元素可见
                const mjxElements = editorBody.querySelectorAll('mjx-container');
                mjxElements.forEach(function(el) {
                  el.style.visibility = 'visible';
                  el.style.display = 'inline-block';
                });
              } else {
                // 如果无法获取编辑器body，则尝试全局渲染
                window.MathJax.typeset();
              }
            } catch (e) {
              console.error('MathJax渲染错误:', e);
              // 出错时尝试全局渲染
              window.MathJax.typeset();
            }
          }
        }, 200);
      }
    });
  });

  // 数学公式按钮
  editor.ui.registry.addButton('mathformula', {
    text: '数学公式',
    tooltip: '插入数学公式',
    onAction: function() {
      editor.execCommand('openMathFormulaDialog');
    }
  });

  // 数学公式帮助按钮
  editor.ui.registry.addButton('mathhelp', {
    icon: 'help',
    tooltip: '数学公式帮助',
    onAction: function() {
      // 创建一个变量来存储当前的对话框实例
      let mathHelpDialog;

      // 打开帮助对话框
      mathHelpDialog = editor.windowManager.open({
        title: '数学公式输入帮助',
        body: {
          type: 'panel',
          items: [
            {
              type: 'htmlpanel',
              html: mathHelpContent
            }
          ]
        },
        buttons: [
          {
            type: 'cancel',
            text: '关闭'
          }
        ],
        width: 1000,
        height: 600,
        onSubmit: function(api) {
          api.close();
        },
        onClose: function() {
          // 对话框关闭时清理资源
        },
        onAction: function() {
          // 对话框打开后，初始化MathJax渲染
        }
      });

      // 对话框打开后，初始化MathJax渲染
      setTimeout(function() {
        if (window.MathJax) {
          try {
            // 尝试清除之前的渲染并重新渲染
            window.MathJax.typesetClear();
            window.MathJax.typeset();

            // 查找所有公式元素并确保它们可见
            const mathElements = document.querySelectorAll('.formula-display');
            mathElements.forEach(function(el) {
              el.style.visibility = 'visible';
              el.style.display = 'block';
            });

            // 查找所有MathJax生成的元素并确保它们可见
            const mjxElements = document.querySelectorAll('mjx-container');
            mjxElements.forEach(function(el) {
              el.style.visibility = 'visible';
              el.style.display = 'inline-block';
            });

            // 为所有"使用"按钮添加点击事件
            const useButtons = document.querySelectorAll('.use-formula-btn');
            useButtons.forEach(function(button) {
              button.addEventListener('click', function(e) {
                // 获取按钮上的数据属性中存储的公式
                const formula = e.target.getAttribute('data-formula');

                // 关闭帮助对话框
                mathHelpDialog.close();

                // 延迟一下，确保对话框已关闭
                setTimeout(function() {
                  // 打开数学公式输入对话框
                  editor.execCommand('openMathFormulaDialog', false, formula);

                  // 再次延迟，确保对话框已打开并且初始化完成
                  setTimeout(function() {
                    // 手动触发预览更新
                    const previewEl = document.getElementById('formula-preview');
                    if (previewEl && formula) {
                      // 清空预览区域
                      previewEl.innerHTML = '';

                      // 添加公式
                      const mathSpan = document.createElement('span');
                      mathSpan.className = 'math-tex';
                      mathSpan.textContent = '$$' + formula + '$$';
                      previewEl.appendChild(mathSpan);

                      // 渲染公式
                      if (window.MathJax) {
                        try {
                          window.MathJax.typesetClear([previewEl]);
                          window.MathJax.typeset([previewEl]);
                        } catch (e) {
                          console.error('预览MathJax渲染错误:', e);
                        }
                      }
                    }
                  }, 200);
                }, 100);
              });
            });
          } catch (e) {
            console.error('MathJax渲染错误:', e);
          }
        }
      }, 300);
    }
  });
})
import 'tinymce/plugins/image'
import 'tinymce/plugins/wordcount'
import 'tinymce/plugins/fullscreen'
import 'tinymce/plugins/autoresize'
import 'tinymce/plugins/lists'
import 'tinymce/plugins/code'
import 'tinymce/plugins/table'
import 'tinymce/plugins/charmap'
import 'tinymce/plugins/insertdatetime'
import 'tinymce/plugins/nonbreaking'
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
import { mathHelpContent } from "@/components/MathHelpContent";

const init = {
  selector: 'textarea',
  language: 'zh_CN',
  content_style: `
    img {max-width:30%;height: auto;}
    .math-tex {
      display: inline-block;
      padding: 2px 4px;
      margin: 0 2px;
      background-color: #f8f9fa;
      border-radius: 3px;
      cursor: pointer;
      user-select: all;
      position: relative;
      border: 1px solid transparent;
    }
    .math-tex:hover {
      border: 1px dashed #ccc;
    }
    .math-tex::after {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      z-index: 1;
    }
    .mce-preview-object {
      display: inline-block;
    }
    mjx-container {
      display: inline-block !important;
      margin: 0 !important;
      pointer-events: none;
    }
    .MathJax {
      display: inline-block !important;
      pointer-events: none;
    }
    .formula-display {
      min-height: 30px;
    }
    .formula-display mjx-container {
      display: inline-block !important;
      margin: 0 !important;
    }
  `,
  extended_valid_elements: 'span[class|style|id|contenteditable|data-formula],svg[*],g[*],path[*],mjx-container[*],mjx-assistive-mml[*],math[*],mrow[*],mi[*],mo[*],mn[*],msup[*],mfrac[*],msqrt[*]',
  entity_encoding: 'raw',
  allow_html_in_named_anchor: true,
  allow_script_urls: true,
  convert_urls: false,
  autoresize_bottom_margin: 50, //編輯器初始化底边距。
  min_height: 600, //编辑器最小高度
  statusbar: false, // 显示下方操作栏
  image_dimensions: false, // 禁止操作图片
  images_upload_url: '/api/questions/uploadPicture',
  plugins: 'lists image code table wordcount image autoresize charmap insertdatetime nonbreaking mathformula', // 富文本插件
  font_size_formats: '8px 10px 12px 14px 16px 18px 24px 36px 48px 128px', // 字体大小文本
  font_family_formats:
      '微软雅黑=Microsoft YaHei,Helvetica Neue,PingFang SC,sans-serif;宋体=simsun,serif', // 字体选择配置
  toolbar:
      'undo redo fontfamily fontsize fontname bold italic underline strikethrough | fontsizeselect | forecolor | alignleft aligncenter alignright | table image charmap insertdatetime mathformula mathhelp | fullscreen',  // 菜单栏配置
  branding: false, // //是否禁用"Powered by TinyMCE"
  menubar: false, //顶部菜单栏显示
  paste_data_images: false, // 禁止粘贴图片
  setup: function(editor) {
    // 在编辑器内容变化时，初始化MathJax渲染
    editor.on('Change', function() {
      // 延迟执行，确保内容已更新
      setTimeout(function() {
        if (window.MathJax) {
          try {
            // 尝试渲染编辑器内的公式
            const editorBody = editor.getBody();
            if (editorBody) {
              // 清除之前的渲染
              window.MathJax.typesetClear([editorBody]);
              // 重新渲染
              window.MathJax.typeset([editorBody]);

              // 确保公式元素可见
              const mathElements = editorBody.querySelectorAll('.math-tex');
              mathElements.forEach(function(el) {
                el.style.visibility = 'visible';
                el.style.display = 'inline-block';
              });

              // 确保MathJax生成的元素可见
              const mjxElements = editorBody.querySelectorAll('mjx-container');
              mjxElements.forEach(function(el) {
                el.style.visibility = 'visible';
                el.style.display = 'inline-block';
                // 确保公式正确显示
                el.style.margin = '0 2px';
              });
            }
          } catch (e) {
            console.error('编辑器内容变化时MathJax渲染错误:', e);
            // 出错时尝试全局渲染
            try {
              window.MathJax.typeset();
            } catch (err) {
              console.error('全局渲染失败:', err);
            }
          }
        }
      }, 300);
    });

    // 在编辑器初始化完成后，渲染已有的公式
    editor.on('init', function() {
      setTimeout(function() {
        if (window.MathJax) {
          try {
            const editorBody = editor.getBody();
            if (editorBody) {
              // 清除之前的渲染
              window.MathJax.typesetClear([editorBody]);
              // 重新渲染
              window.MathJax.typeset([editorBody]);

              // 确保公式元素可见
              const mathElements = editorBody.querySelectorAll('.math-tex');
              mathElements.forEach(function(el) {
                el.style.visibility = 'visible';
                el.style.display = 'inline-block';
              });

              // 确保MathJax生成的元素可见
              const mjxElements = editorBody.querySelectorAll('mjx-container');
              mjxElements.forEach(function(el) {
                el.style.visibility = 'visible';
                el.style.display = 'inline-block';
                // 确保公式正确显示
                el.style.margin = '0 2px';
              });
            }
          } catch (e) {
            console.error('编辑器初始化时MathJax渲染错误:', e);
            // 出错时尝试全局渲染
            try {
              window.MathJax.typeset();
            } catch (err) {
              console.error('全局渲染失败:', err);
            }
          }
        }
      }, 500);
    });

    // 在编辑器内容粘贴后，渲染公式
    editor.on('paste', function() {
      setTimeout(function() {
        if (window.MathJax) {
          try {
            const editorBody = editor.getBody();
            if (editorBody) {
              // 清除之前的渲染
              window.MathJax.typesetClear([editorBody]);
              // 重新渲染
              window.MathJax.typeset([editorBody]);
            }
          } catch (e) {
            console.error('粘贴内容后MathJax渲染错误:', e);
          }
        }
      }, 300);
    });

    // 在编辑器获得焦点时，确保公式正确渲染
    editor.on('focus', function() {
      setTimeout(function() {
        if (window.MathJax) {
          try {
            const editorBody = editor.getBody();
            if (editorBody) {
              // 重新渲染
              window.MathJax.typeset([editorBody]);
            }
          } catch (e) {
            console.error('编辑器获得焦点时MathJax渲染错误:', e);
          }
        }
      }, 200);
    });

    // 添加双击公式编辑功能
    editor.on('dblclick', function(e) {
      const target = e.target;

      // 检查是否点击了公式元素或其子元素
      let formulaElement = null;
      if (target.classList && target.classList.contains('math-tex')) {
        formulaElement = target;
      } else if (target.closest && target.closest('.math-tex')) {
        formulaElement = target.closest('.math-tex');
      } else if (target.parentNode && target.parentNode.closest && target.parentNode.closest('.math-tex')) {
        formulaElement = target.parentNode.closest('.math-tex');
      }

      // 如果找到了公式元素，打开编辑对话框
      if (formulaElement) {
        // 获取原始公式
        let formula = formulaElement.getAttribute('data-formula');

        // 如果没有data-formula属性，尝试从内容中提取
        if (!formula) {
          const content = formulaElement.textContent || '';
          const matches = content.match(/\$\$(.*?)\$\$/);
          if (matches && matches[1]) {
            formula = matches[1];
          }
        }

        // 打开公式编辑对话框
        if (formula) {
          editor.execCommand('openMathFormulaDialog', false, formula);

          // 记住当前选中的公式元素，以便在提交时替换
          editor.selection.select(formulaElement);
        }
      }
    });
  }
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
        <el-option label="入门" value="1" />
        <el-option label="简单" value="2" />
        <el-option label="中等" value="3" />
        <el-option label="困难" value="4" />
        <el-option label="挑战" value="5" />
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
