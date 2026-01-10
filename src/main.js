import { createApp } from 'vue'
import App from './App.vue'
import router from "@/router/router";
import ElementPlus from 'element-plus'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import 'element-plus/dist/index.css'
import axios from "axios";
import { ElNotification } from 'element-plus'
import permission from '@/utils/permission';

// 解决窗口大小改变时组件自适应的报错
const debounce = (fn, delay) => {
    let timer
    return (...args) => {
        if (timer) {
            clearTimeout(timer)
        }
        timer = setTimeout(() => {
            fn(...args)
        }, delay)
    }
}
const _ResizeObserver = window.ResizeObserver;
window.ResizeObserver = class ResizeObserver extends _ResizeObserver {
    constructor(callback) {
        callback = debounce(callback, 200);
        super(callback);
    }
}

// 配置axios
axios.defaults.withCredentials = true;

// 添加请求拦截器
axios.interceptors.request.use(
    config => {
        // 在请求发送前可以做一些处理，如添加token等
        return config;
    },
    error => {
        console.error('请求错误:', error);
        return Promise.reject(error);
    }
);

// 添加响应拦截器
axios.interceptors.response.use(
    response => {
        // 处理响应数据
        if (response.data && response.data.code === 401) {
            // 未授权，清除认证信息并重定向到登录页
            permission.clearAuth();
            router.push('/login');
            ElNotification({
                title: '登录已过期',
                message: '请重新登录',
                type: 'warning',
                duration: 3000
            });
        }
        return response;
    },
    error => {
        // 处理响应错误
        if (error.response && error.response.status === 401) {
            // 未授权，清除认证信息并重定向到登录页
            permission.clearAuth();
            router.push('/login');
            ElNotification({
                title: '登录已过期',
                message: '请重新登录',
                type: 'warning',
                duration: 3000
            });
        } else {
            // 其他错误
            ElNotification({
                title: '请求失败',
                message: error.message || '网络错误',
                type: 'error',
                duration: 3000
            });
        }
        return Promise.reject(error);
    }
);

// 创建应用实例
const app = createApp(App);

// 全局错误处理
app.config.errorHandler = (err, vm, info) => {
    console.error('应用错误:', err);
    console.error('错误信息:', info);

    // 显示错误通知
    ElNotification({
        title: '应用错误',
        message: err.message || '发生未知错误',
        type: 'error',
        duration: 5000
    });
};

// 注册全局属性
app.config.globalProperties.$permission = permission;

// 注册插件和组件
app.use(router);
app.use(ElementPlus);

// 注册Element Plus图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
    app.component(key, component);
}

// 挂载应用
app.mount('#app');