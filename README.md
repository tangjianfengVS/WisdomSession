# WisdomSession
一. 简介：

   Based on 'Alamofire' library, encapsulated network framework library(基于 Alamofire 库，封装的网络框架库)

   WisdomSession：一款 基于 Alamofire 库，封装的网络框架库。封装功能如下：

      1. 封装内部请求入参模型。封装内部响应数据处理，包括 成功/失败 情况数据，并统一 msg, code, data, timestamp 数据字段。

      2. 支持 对象直接 调用方式，还支持 枚举定义方案 调用方式。
 
      3. 支持 响应数据 本地模拟。
 
      4. 支持 响应数据 局部/全局 拦截处理错误。

   cocoapods 集成：pod 'WisdomSession', '0.0.4'
