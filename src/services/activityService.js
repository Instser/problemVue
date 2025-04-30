import axios from 'axios';
import { storage } from '@/storage/storage';

/**
 * 活动记录服务
 * 提供统一的活动记录功能
 */
const activityService = {
  /**
   * 记录用户活动
   * @param {string} type 活动类型（创建试题、编辑试题、删除试题等）
   * @param {string} name 活动对象名称
   * @param {number} objectId 活动对象ID
   * @returns {Promise} 记录结果
   */
  recordActivity(type, name, objectId) {
    const userId = storage.get('userId');
    if (!userId) {
      console.warn('未找到用户ID，无法记录活动');
      return Promise.reject(new Error('未找到用户ID'));
    }

    return axios({
      method: 'post',
      url: '/api/userActivity/record',
      params: {
        userId,
        type,
        name,
        objectId
      },
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    }).then(response => {
      if (response.data && response.data.code === 200) {
        console.log(`记录${type}活动成功:`, response.data.data);
        return response.data.data;
      } else {
        console.warn(`记录${type}活动失败:`, response.data);
        return Promise.reject(new Error(response.data.message || '记录活动失败'));
      }
    }).catch(error => {
      console.error(`记录${type}活动失败:`, error);
      return Promise.reject(error);
    });
  },

  /**
   * 获取用户最近活动
   * @param {number} limit 限制返回记录数
   * @returns {Promise} 活动记录列表
   */
  getRecentActivities(limit = 5) {
    const userId = storage.get('userId');
    if (!userId) {
      console.warn('未找到用户ID，无法获取活动记录');
      return Promise.reject(new Error('未找到用户ID'));
    }

    // 直接使用axios实例，确保请求格式正确
    return axios({
      method: 'get',
      url: '/api/userActivity/byUserId',
      params: {
        userId,
        limit
      },
      headers: {
        'Accept': 'application/json'
      }
    }).then(response => {
      console.log('获取活动记录响应:', response);

      // 正确处理嵌套的响应结构
      if (response.data) {
        // 检查是否有嵌套的data.data结构
        let activities = [];

        if (response.data.code === 200 && Array.isArray(response.data.data)) {
          // 标准格式：{ code: 200, data: [...] }
          activities = response.data.data;
          console.log('从标准格式解析活动记录:', activities);
        } else if (response.data.data && response.data.data.code === 200 && Array.isArray(response.data.data.data)) {
          // 嵌套格式：{ data: { code: 200, data: [...] } }
          activities = response.data.data.data;
          console.log('从嵌套格式解析活动记录:', activities);
        } else if (Array.isArray(response.data)) {
          // 直接数组格式：[...]
          activities = response.data;
          console.log('从数组格式解析活动记录:', activities);
        } else {
          console.warn('未识别的响应格式:', response.data);
        }

        // 确保每个活动记录都有必要的字段
        return activities.map(activity => {
          // 如果name为null或undefined，设置为默认值
          if (!activity.name) {
            activity.name = '未命名活动';
          }
          return activity;
        });
      } else {
        console.warn('获取活动记录失败:', response);
        return [];
      }
    }).catch(error => {
      console.error('获取活动记录失败:', error);
      return [];
    });
  },

  /**
   * 格式化试题信息用于活动记录
   * @param {Object} question 试题对象
   * @param {Array} courseArr 课程数组（可选）
   * @returns {Object} 包含元数据和内容的格式化试题信息对象
   */
  formatQuestionInfo(question, courseArr = []) {
    try {
      // 创建一个对象来存储元数据和内容
      const result = {
        metadata: '',  // 元数据（题型、难度、课程等）
        content: ''    // 题目内容
      };

      // 提取纯文本内容（去除HTML标签）
      if (question.description) {
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = question.description;
        const textContent = tempDiv.textContent || tempDiv.innerText || '';

        // 构建元数据信息
        const metadataParts = [];

        // 添加题型信息
        if (question.typeName || question.types) {
          metadataParts.push(question.typeName || question.types);
        }

        // 添加难度信息
        if (question.hard) {
          metadataParts.push(`${question.hard}难度`);
        }

        // 添加课程信息
        if (question.quesCourStr) {
          metadataParts.push(question.quesCourStr);
        } else if (question.quesCourId && courseArr.length > 0) {
          const course = courseArr.find(c => c.id === question.quesCourId);
          if (course) {
            metadataParts.push(course.name);
          }
        }

        // 添加章节信息（如果有）
        if (question.chapter) {
          metadataParts.push(`章节: ${question.chapter}`);
        }

        // 将元数据部分组合起来
        result.metadata = metadataParts.join(' | ');

        // 设置题目内容
        result.content = textContent;
      } else {
        result.metadata = `试题 ID: ${question.id || '未知'}`;
        result.content = '';
      }

      // 为了兼容旧代码，我们仍然返回一个字符串，但格式是JSON
      // 新代码可以解析这个JSON字符串来获取结构化数据
      return JSON.stringify(result);
    } catch (error) {
      console.error('格式化试题信息失败:', error);
      return JSON.stringify({
        metadata: `试题 ID: ${question.id || '未知'}`,
        content: ''
      });
    }
  }
};

export default activityService;
