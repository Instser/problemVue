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
import { onMounted, onBeforeUnmount } from 'vue';
import { useRouter } from 'vue-router';

export default {
  name: 'App',
  components: {},
  setup() {
    const router = useRouter();

    // 监听路由变化
    const handleRouteChange = () => {
      console.log('URL变化检测');
      // 强制重新渲染当前路由
      const currentPath = window.location.hash.slice(1);
      if (currentPath && currentPath !== '/') {
        router.replace(currentPath);
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
