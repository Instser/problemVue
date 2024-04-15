import { createRouter, createWebHistory } from 'vue-router'
import Main from "@/views/mainPage.vue";
import home from "@/views/homePage.vue";
import questions from "@/views/questionsPage.vue";
import central from "@/views/centralPage.vue";
import login from "@/views/loginPage.vue";
import edit from '@/views/editPage.vue'
import {storage} from "@/storage/storage";
import system from "@/views/systemPage.vue";
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
    // {
    // path: '/system',
    // component: system,
    // name: '管理',
    // meta: { label: '管理页面', icon: 'Setting',role:'admin', path: '/system' }
    // }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

let registerRouteFresh = true //判断页面是否刷新以及第一次进入
router.beforeEach((to, from, next) => {
    let isAuthenticated = storage.get("isAuthenticated");/* 判断用户是否已登录 */
    if (registerRouteFresh || storage.get('freshRoute')) {
        if (storage.get('role') === 'admin') {
            console.log('更新route');
            adminMenu.forEach((value) => {
                console.log(value)
                router.addRoute('main', value)
            });
            next({...to, replace: true});
            registerRouteFresh = false;
            console.log(router.getRoutes());
            storage.set('freshRoute',false)
        } else {
            router.removeRoute('管理');
            router.removeRoute('课程管理')
            storage.set('freshRoute',false)
        }
    }
    if (isAuthenticated === null) {
        isAuthenticated = false;
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