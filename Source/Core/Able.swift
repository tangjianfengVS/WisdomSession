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


// MARK: 网络状态
public enum WisdomSessionStatus {
    case unknown        // 未知
    case notReachable   // 无网
    case cellular       // 蜂窝网络
    case ethernetOrWiFi // 以太网 或者 WIFI
}


// MARK: 1.code: 响应码  2.message: 响应信息  3.responseData: 响应数据
public typealias WisdomSessionSuccedClosure = (_ code: NSInteger,
                                               _ message: String,
                                               _ responseData: Any)->()


// MARK: 1.code: 错误码  2.message: 错误信息  3.rawResponseString: 原始信息
public typealias WisdomSessionFailedClosure = (_ code: NSInteger,
                                               _ message: String,
                                               _ rawResponseString: String)->()


// MARK: 1.code: 错误码  2.message: 错误信息  3.timestamp: 时间戳
public typealias WisdomSessionFailed = (code: NSInteger, message: String, timestamp: NSInteger)


// MARK: 1.code: 错误码  2.message: 错误信息  3.responseData: 响应数据 4.asyncTime：延迟时间
public typealias WisdomSessionDebugData = (code: NSInteger,
                                           message: String,
                                           responseData: Any,
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


// MARK: 设置网络请求，绑定协议实现
public protocol WisdomSessionApiable {
    
    var dataRequest: DataRequest? { get set }

    // MARK: The target's base `String`. (设置请求域名)
    var baseURL: String { get }

    // MARK: The path to be appended to `baseURL` to form the full `URL`. (设置请求路径)
    var path: String { get }

    // MARK: The HTTP method used in the request. (设置请求方案)
    var method: WisdomSessionMethod { get }
    
    // MARK: The headers to be used in the request. (设置请求头参数)
    var headers: [String:String]? { get }

    // MARK: The type of HTTP task to be performed. (设置请求体参数)
    var parameters: [String:Any] { get }

    // The type of validation to perform on the request. Default is `.none`.
    //var validationType: ValidationType { get }

    // MARK: The description in the request. (设置请求描述)
    var apiDescription: String { get }

    // MARK: Debug 环境下相应模拟数据。如果请求实现此属性， Debug 环境不在走网络数据，Release 环境自动忽略。
    // - code         : NSInteger
    // - message      : String
    // - timestamp    : 时间戳
    // - responseData : Any
    // - asyncTime    : TimeInterval 异步延迟
    var responseDebugData: WisdomSessionDebugData? { get }
    
    // MARK: Session Start. (开启网络请求)
    func request(succedClosure: @escaping WisdomSessionSuccedClosure, failedClosure: @escaping WisdomSessionFailedClosure)
    
    // MARK: The Current Session Cancel. (停止当前网络请求)
    func cancelSession()
}


public extension WisdomSessionApiable {

    // The type of validation to perform on the request. Default is `.none`.
    //var validationType: ValidationType { .none }
    
    var headers: [String:String]? { nil }

    var parameters: [String:Any] { [:] }

    var apiDescription: String { "" }

    var responseDebugData: WisdomSessionDebugData? { nil }
    
    mutating func request(succedClosure: @escaping WisdomSessionSuccedClosure, failedClosure: @escaping WisdomSessionFailedClosure) {
        let dataRequest = WisdomSession.request(clientable: self, succedClosure: succedClosure, failedClosure: failedClosure)
        self.dataRequest = dataRequest
    }
    
    func cancelSession() {
        dataRequest?.cancel()
    }
}


// MARK: 设置全局配置 协议
protocol WisdomSessionGlobalSetable {

    static func setSession(baseURL: String)

    static func setSession(responseable: WisdomSessionResponseable.Type)

    static func setSession(requestTimeoutInterval: TimeInterval)

    static func setSession(openLog: Bool)
    
    static func setSession(headersable: WisdomSessionHeadersable.Type)
}


protocol WisdomSessionInfoable where Self: WisdomSession {

    static var baseURL: String? { get }

    static var responseable: WisdomSessionResponseable.Type? { get }

    static var currentSessionState: WisdomSessionStatus { get }
    
    static var headersable: WisdomSessionHeadersable.Type? { get }
}


protocol WisdomSessionEncoderable {

    static func encoderJson(dict: [String: Any])->String

    static func encoderDict(data: Data)->[String:Any]
}
