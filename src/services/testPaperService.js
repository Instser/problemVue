import axios from 'axios';
import { storage } from '@/storage/storage';

/**
 * 试卷服务
 * 提供试卷相关的API调用
 */
const testPaperService = {
  /**
   * 获取当前用户的最近试卷
   * @param {number} limit 限制返回记录数
   * @returns {Promise} 试卷记录列表
   */
  getUserRecentPapers(limit = 10) {
    const userId = storage.get('userId');
    if (!userId) {
      console.warn('未找到用户ID，无法获取试卷记录');
      return Promise.reject(new Error('未找到用户ID'));
    }

    return axios({
      method: 'get',
      url: '/api/testPaper/userPapers',
      params: {
        limit
      },
      headers: {
        'Accept': 'application/json'
      }
    }).then(response => {
      if (response.data && response.data.code === 200) {
        return response.data.data;
      } else {
        console.warn('获取试卷记录失败:', response.data);
        return [];
      }
    }).catch(error => {
      console.error('获取试卷记录失败:', error);
      return [];
    });
  },

  /**
   * 获取试卷详情
   * @param {number} paperId 试卷ID
   * @returns {Promise} 试卷详情
   */
  getPaperDetail(paperId) {
    if (!paperId) {
      console.warn('试卷ID为空，无法获取试卷详情');
      return Promise.reject(new Error('试卷ID为空'));
    }

    return axios({
      method: 'get',
      url: '/api/testPaper/detail',
      params: {
        paperId
      },
      headers: {
        'Accept': 'application/json'
      }
    }).then(response => {
      if (response.data && response.data.code === 200) {
        return response.data.data;
      } else {
        console.warn('获取试卷详情失败:', response.data);
        return null;
      }
    }).catch(error => {
      console.error('获取试卷详情失败:', error);
      return null;
    });
  },

  /**
   * 获取试卷下载链接
   * @param {string} fileName 文件名
   * @returns {Promise} 下载链接
   */
  getPaperDownloadUrl(fileName) {
    if (!fileName) {
      console.warn('文件名为空，无法获取下载链接');
      return Promise.reject(new Error('文件名为空'));
    }

    return axios({
      method: 'get',
      url: '/api/testPaper/downloadUrl',
      params: {
        fileName
      },
      headers: {
        'Accept': 'application/json'
      }
    }).then(response => {
      if (response.data && response.data.code === 200) {
        return response.data.data;
      } else {
        console.warn('获取下载链接失败:', response.data);
        return null;
      }
    }).catch(error => {
      console.error('获取下载链接失败:', error);
      return null;
    });
  },

  /**
   * 将难度数字转换为中文
   * @param {string|number} hard 难度值
   * @returns {string} 中文难度
   */
  getDifficultyLabel(hard) {
    // 将数字转换为对应的中文标签
    const difficultyMap = {
      '1': '入门',
      '2': '简单',
      '3': '中等',
      '4': '困难',
      '5': '挑战'
    };

    // 如果是数字字符串，直接映射
    if (difficultyMap[hard]) {
      return difficultyMap[hard];
    }

    // 如果是旧数据中的中文，保持原样显示
    if (['入门', '简单', '中等', '困难', '挑战'].includes(hard)) {
      return hard;
    }

    // 其他情况，尝试将其作为数字处理
    const numHard = parseInt(hard);
    if (!isNaN(numHard) && numHard >= 1 && numHard <= 5) {
      return difficultyMap[numHard.toString()];
    }

    // 默认返回中等
    return '中等';
  }
};

export default testPaperService;
