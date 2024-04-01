import { createRouter, createWebHistory } from 'vue-router'
import Main from "@/views/mainPage.vue";
import home from "@/views/homePage.vue";
import course from "@/views/coursePage.vue";
import questions from "@/views/questionsPage.vue";
import central from "@/views/centralPage.vue";
import login from "@/views/loginPage.vue";

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
    },
    {
        path: '/login',
        name: '登录',
        component: login,
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

router.beforeEach((to, from, next) => {
    const isAuthenticated = true;/* 判断用户是否已登录 */

    if (to.name !== '登录' && !isAuthenticated) {
        next({ name: '登录' });
    } else if (to.name === '登录' && isAuthenticated) {
        next({ name: '首页' });
    } else {
        next();
    }
})

export default router