import { createRouter, createWebHashHistory } from 'vue-router'
import Main from "@/views/mainPage.vue";
import home from "@/views/homePage.vue";
import questions from "@/views/questionsPage.vue";
import central from "@/views/centralPage.vue";
import login from "@/views/loginPage.vue";
import edit from '@/views/editPage.vue'
import {storage} from "@/storage/storage";
import course from "@/views/coursePage.vue";

const routes = [
    {
        path: '/',
        component: Main,
        redirect: '/home',
        name: 'main',
        children: [
            // 子路由
            {path: 'home', name: '首页', component: home, meta: {label:'首页', icon: 'view', path: '/home'}}, // 首页
            {path: 'questions', name: '试题管理', component: questions, meta: {label:'试题管理', icon: 'document-copy', path: '/questions'}}, // 试题管理
            {path: 'central', name: '个人中心', component: central, meta: {label:'个人中心', icon: 'user', path: '/central'}} // 个人中心
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

const adminMenu = [
    {
        path: '/course',
        component: course,
        name: '课程管理',
        meta: { label: '课程管理', icon: 'Reading', role: 'admin', path: '/course'}
    }
]

const router = createRouter({
    history: createWebHashHistory(),
    routes,
    scrollBehavior() {
        return { top: 0 }
    }
})

let registerRouteFresh = true //判断页面是否刷新以及第一次进入
router.beforeEach((to, from, next) => {
    let isAuthenticated = storage.get("isAuthenticated");/* 判断用户是否已登录 */

    // 处理动态路由
    if (registerRouteFresh || storage.get('freshRoute')) {
        if (storage.get('role') === 'admin') {
            console.log('更新route');
            // 检查路由是否已存在，避免重复添加
            const existingRoutes = router.getRoutes().map(route => route.name);

            adminMenu.forEach((value) => {
                if (!existingRoutes.includes(value.name)) {
                    router.addRoute('main', value);
                    console.log('添加路由:', value.name);
                }
            });

            registerRouteFresh = false;
            storage.set('freshRoute', false);

            // 确保路由表更新后再导航
            return next({ path: to.fullPath, replace: true });
        } else {
            try {
                if (router.hasRoute('管理')) {
                    router.removeRoute('管理');
                }
                if (router.hasRoute('课程管理')) {
                    router.removeRoute('课程管理');
                }
            } catch (e) {
                console.error('移除路由失败:', e);
            }
            storage.set('freshRoute', false);
        }
    }

    // 处理认证逻辑
    if (isAuthenticated === null) {
        isAuthenticated = false;
    }

    if (to.name !== '登录' && !isAuthenticated) {
        next({ name: '登录' });
    } else if (to.name === '登录' && isAuthenticated) {
        next({ name: '首页' });
    } else {
        // 确保路由存在
        if (to.matched.length === 0) {
            // 如果路由不匹配，重定向到首页
            next({ name: '首页' });
        } else {
            next();
        }
    }
})

export default router