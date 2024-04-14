import {RouteRecordRaw} from "vue-router";
// @ts-ignore
import system from "@/views/systemPage.vue";
import course from "@/views/coursePage.vue";
export const asyncRoutes: RouteRecordRaw[] = [
    {
        path: '/system',
        component: system,
        name: '管理',
        meta: { label: '管理页面', icon: 'Setting',role:['admin'], path: '/system' }
    },
    {
        path: '/course',
        component: course,
        name: '课程管理',
        meta: { label: '课程管理', role: ['admin'], path: '/course'}
    }
]