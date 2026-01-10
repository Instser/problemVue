const { defineConfig } = require('@vue/cli-service')
const webpack = require('webpack')

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
  configureWebpack: {
    plugins: [
      new webpack.DefinePlugin({
        __VUE_PROD_HYDRATION_MISMATCH_DETAILS__: 'false'
      })
    ]
  },
  devServer:{
    port: 8080, // 设置前端端口为8080
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
