import { createApp } from 'vue'
import App from './App.vue'
import router from "@/router/router";
import ElementPlus from 'element-plus'

createApp(App).use(router).use(ElementPlus).mount('#app')
