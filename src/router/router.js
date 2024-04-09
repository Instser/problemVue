import { createRouter, createWebHistory } from 'vue-router'
import Main from "@/views/mainPage.vue";
import home from "@/views/homePage.vue";
import course from "@/views/coursePage.vue";
import questions from "@/views/questionsPage.vue";
import central from "@/views/centralPage.vue";
import login from "@/views/loginPage.vue";
import edit from '@/views/editPage.vue'
import folder from '@/views/folderPage.vue'
import {storage} from "@/storage/storage";

const routes = [
    {
        path: '/',
        component: Main,
        redirect: '/home',
        children: [
            // 子路由
            {path: 'home', name: '首页', component: home}, // 首页
            {path: 'course', name: '课程管理', component: course}, // 课程管理
            {path: 'questions', name: '试题管理', component: questions}, // 试题管理
            {path: 'folder', name: '文件夹', component: folder}, // 题目文件夹
            {path: 'central', name: '个人中心', component: central} // 个人中心
        ]
    },
    {
        path: '/login',
        name: '登录',
        component: login
    },
    {
        path: '/edit',
        name: '编辑',
        component: edit
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

router.beforeEach((to, from, next) => {
    let isAuthenticated = storage.get("isAuthenticated");/* 判断用户是否已登录 */
    if (isAuthenticated === null) {
        isAuthenticated = false
    }
    if (to.name !== '登录' && !isAuthenticated) {
        next({ name: '登录' });
    } else if (to.name === '登录' && isAuthenticated) {
        next({ name: '首页' });
    } else {
        next();
    }
})

export default router