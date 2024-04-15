const { defineConfig } = require('@vue/cli-service')
module.exports = defineConfig({
  transpileDependencies: true,
  css: {
    loaderOptions: {
      less: {
        lessOptions: {
          modifyVars: {},
          javascriptEnabled: true
        }
      }
    }
  },
  devServer:{
    client: {
      overlay: false
    },
    // 配置代理
    proxy:{
      '/api':{
        target:'http://localhost:8888',
        // target:'http://8.210.230.249:8888',
        changeOrigin:true, // 是否允许跨域请求
        pathRewrite: {
          '^/api': ''
        }
      }
    }
  }
})
