import { createRouter, createWebHashHistory } from 'vue-router'
import Main from "@/views/mainPage.vue";
import home from "@/views/homePage.vue";
import questions from "@/views/questionsPage.vue";
import central from "@/views/centralPage.vue";
import login from "@/views/loginPage.vue";
import edit from '@/views/editPage.vue'
import {storage} from "@/storage/storage";
import course from "@/views/coursePage.vue";
import announcement from "@/views/announcementPage.vue";

// 公共路由 - 所有用户都可以访问
const constantRoutes = [
    {
        path: '/login',
        name: '登录',
        component: login,
        meta: { requiresAuth: false }
    },
    {
        path: '/',
        component: Main,
        redirect: '/home',
        name: 'main',
        children: [
            // 基础路由 - 所有已登录用户可访问
            {
                path: 'home',
                name: '首页',
                component: home,
                meta: {
                    requiresAuth: true,
                    label: '首页',
                    icon: 'view',
                    path: '/home'
                }
            },
            {
                path: 'questions',
                name: '试题管理',
                component: questions,
                meta: {
                    requiresAuth: true,
                    label: '试题管理',
                    icon: 'document-copy',
                    path: '/questions'
                }
            },
            {
                path: 'central',
                name: '个人中心',
                component: central,
                meta: {
                    requiresAuth: true,
                    label: '个人中心',
                    icon: 'user',
                    path: '/central'
                }
            },
            {
                path: 'edit',
                name: '编辑',
                component: edit,
                meta: {
                    requiresAuth: true,
                    hidden: true
                }
            }
        ]
    },
    // 404路由
    {
        path: '/:pathMatch(.*)*',
        redirect: '/home'
    }
]

// 管理员专用路由
const adminRoutes = [
    {
        path: '/course',
        component: course,
        name: '课程管理',
        meta: {
            requiresAuth: true,
            requiresAdmin: true,
            label: '课程管理',
            icon: 'Reading',
            role: 'admin',
            path: '/course'
        }
    },
    {
        path: '/announcement',
        component: announcement,
        name: '公告管理',
        meta: {
            requiresAuth: true,
            requiresAdmin: true,
            label: '公告管理',
            icon: 'Bell',
            role: 'admin',
            path: '/announcement'
        }
    }
]

// 创建路由实例
const router = createRouter({
    history: createWebHashHistory(),
    routes: constantRoutes,
    scrollBehavior() {
        return { top: 0 }
    }
})

// 路由守卫
router.beforeEach(async (to, from, next) => {
    // 获取认证状态
    const isAuthenticated = storage.get("isAuthenticated") || false;
    const userRole = storage.get("role");

    // 检查路由是否需要认证
    const requiresAuth = to.matched.some(record => record.meta.requiresAuth);
    const requiresAdmin = to.matched.some(record => record.meta.requiresAdmin);

    // 处理动态路由
    const hasAdminRoutes = router.hasRoute('课程管理');

    // 如果用户是管理员但管理员路由尚未添加
    if (isAuthenticated && userRole === 'admin' && !hasAdminRoutes) {
        // 添加管理员路由
        adminRoutes.forEach(route => {
            if (!router.hasRoute(route.name)) {
                router.addRoute('main', route);
                console.log('添加管理员路由:', route.name);
            }
        });

        // 如果当前路由是管理员路由，需要重新导航以确保路由正确加载
        if (to.matched.length === 0) {
            next({ path: to.fullPath, replace: true });
            return;
        }
    }

    // 如果用户不是管理员但尝试访问管理员路由
    if (requiresAdmin && userRole !== 'admin') {
        next({ name: '首页' });
        return;
    }

    // 认证逻辑
    if (requiresAuth && !isAuthenticated) {
        // 未登录用户尝试访问需要认证的页面，重定向到登录页
        next({ name: '登录' });
    } else if (to.name === '登录' && isAuthenticated) {
        // 已登录用户尝试访问登录页，重定向到首页
        next({ name: '首页' });
    } else {
        // 其他情况正常导航
        next();
    }
})

export default router