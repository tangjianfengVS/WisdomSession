//
//  Able.swift
//  WisdomSession
//
//  Created by jianfeng on 2023/11/23.
//

import Foundation
import Alamofire


// MARK: 请求方案
public enum WisdomSessionMethod: String {
    case GET  = "GET"
    case POST = "POST"
}


// MARK: 请求方案 上传文件
public enum WisdomSessionUploadMethod {
    case PUT
    case POST
}


// MARK: 网络状态
public enum WisdomSessionStatus {
    case unknown        // 未知
    case notReachable   // 无网
    case cellular       // 蜂窝网络
    case ethernetOrWiFi // 以太网 或者 WIFI
}


// MARK: 1.code: 响应码  2.message: 响应信息  3.responseData: 响应数据
public typealias WisdomSessionSuccedClosure = @MainActor (_ code: NSInteger,
                                                         _ message: String,
                                                         _ responseData: any Sendable)->()


// MARK: 1.code: 错误码  2.message: 错误信息  3.rawResponseString: 原始信息
public typealias WisdomSessionFailedClosure = @MainActor (_ code: NSInteger,
                                                         _ message: String,
                                                         _ rawResponseString: String)->()


// MARK: 1.code: 错误码  2.message: 错误信息  3.timestamp: 时间戳
public typealias WisdomSessionFailed = (code: NSInteger, message: String, timestamp: NSInteger)


// MARK: 1.code: 错误码  2.message: 错误信息  3.responseData: 响应数据 4.asyncTime：延迟时间
public typealias WisdomSessionDebugData = (code: NSInteger,
                                           message: String,
                                           responseData: any Sendable,
                                           asyncTime: TimeInterval)


// MARK: 响应协议
public protocol WisdomSessionResponseable {

    // MARK: 响应 Error 统一处理
    static func response(code: NSInteger, message: String, responseData: Any)->WisdomSessionFailed?
}


// MARK: 设置请求头参数
public protocol WisdomSessionHeadersable {

    // MARK: The headers to be used in the request. (设置请求头参数)
    static var headers: [String:String]? { get }
}


// MARK: 设置全局配置 协议
protocol WisdomSessionGlobalSetable {

    static func setSession(baseURL: String)

    static func setSession(responseable: WisdomSessionResponseable.Type)

    static func setSession(requestTimeoutInterval: TimeInterval)

    static func setSession(openLog: Bool)
    
    static func setSession(headersable: WisdomSessionHeadersable.Type)
}


protocol WisdomSessionInfoable {// where Self: WisdomSession { // 循环引用

    static var baseURL: String? { get }

    static var responseable: WisdomSessionResponseable.Type? { get }

    static var currentSessionState: WisdomSessionStatus { get }
    
    static var headersable: WisdomSessionHeadersable.Type? { get }
}


protocol WisdomSessionEncoderable {

    static func encoderJson(dict: [String: Any])->String

    static func encoderDict(data: Data)->[String:Any]
}
