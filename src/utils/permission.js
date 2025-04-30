import { storage } from '@/storage/storage';

/**
 * 权限工具类
 * 提供权限相关的工具方法
 */
const permission = {
  /**
   * 检查用户是否已认证
   * @returns {boolean} 是否已认证
   */
  isAuthenticated() {
    return storage.get('isAuthenticated') === true;
  },

  /**
   * 检查用户是否是管理员
   * @returns {boolean} 是否是管理员
   */
  isAdmin() {
    return storage.get('role') === 'admin';
  },

  /**
   * 检查用户是否有权限访问指定路由
   * @param {Object} route 路由对象
   * @returns {boolean} 是否有权限
   */
  hasPermission(route) {
    // 如果路由不需要认证，所有用户都可以访问
    if (route.meta && route.meta.requiresAuth === false) {
      return true;
    }

    // 如果用户未认证，无权访问需要认证的路由
    if (!this.isAuthenticated()) {
      return false;
    }

    // 如果路由需要管理员权限，检查用户是否是管理员
    if (route.meta && route.meta.requiresAdmin && !this.isAdmin()) {
      return false;
    }

    // 其他情况，已认证用户可以访问
    return true;
  },

  /**
   * 获取用户ID
   * @returns {number|null} 用户ID
   */
  getUserId() {
    return storage.get('userId');
  },

  /**
   * 获取用户名
   * @returns {string} 用户名
   */
  getUsername() {
    return storage.get('username') || '用户';
  },

  /**
   * 获取用户角色
   * @returns {string} 用户角色
   */
  getUserRole() {
    return storage.get('role') || '';
  },

  /**
   * 清除用户认证信息
   */
  clearAuth() {
    storage.remove('isAuthenticated');
    storage.remove('role');
    storage.remove('userId');
    storage.remove('username');
  }
};

export default permission;
