import { createRouter, createWebHistory } from 'vue-router'
import Main from "@/views/mainPage.vue";
import home from "@/views/homePage.vue";
import course from "@/views/coursePage.vue";
import questions from "@/views/questionsPage.vue";
import central from "@/views/centralPage.vue";

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
            {path: 'central', name: '个人中心', component: central} // 个人中心
        ]
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

export default router