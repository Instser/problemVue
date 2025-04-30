<template>
  <div id="app">
    <router-view v-slot="{ Component }">
      <transition name="fade" mode="out-in">
        <component :is="Component" :key="$route.fullPath" />
      </transition>
    </router-view>
  </div>
</template>

<script>
import { onMounted, onBeforeUnmount, ref } from 'vue';
import { useRouter } from 'vue-router';
import permission from '@/utils/permission';

export default {
  name: 'App',
  components: {},
  setup() {
    const router = useRouter();
    const isRouteProcessing = ref(false);

    // 监听路由变化
    const handleRouteChange = () => {
      // 防止重复处理
      if (isRouteProcessing.value) return;

      try {
        isRouteProcessing.value = true;
        console.log('检测到URL变化');

        // 获取当前路径
        const currentPath = window.location.hash.slice(1);
        if (!currentPath || currentPath === '/') return;

        // 获取当前路由
        const currentRoute = router.resolve(currentPath);

        // 检查权限
        if (!permission.hasPermission(currentRoute)) {
          console.log('用户无权访问当前路由，重定向到首页');
          router.push('/');
          return;
        }

        // 正常导航
        router.replace(currentPath);
      } catch (error) {
        console.error('路由处理错误:', error);
      } finally {
        isRouteProcessing.value = false;
      }
    };

    onMounted(() => {
      // 监听 hash 变化
      window.addEventListener('hashchange', handleRouteChange);
    });

    onBeforeUnmount(() => {
      window.removeEventListener('hashchange', handleRouteChange);
    });
  }
}
</script>

<style lang="less">
@import './assets/styles/global.less';

#app {
  width: 100%;
  height: 100%;
}
</style>
