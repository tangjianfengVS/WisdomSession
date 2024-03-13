//
//  Able.swift
//  WisdomNetwork
//
//  Created by qmlt on 2023/11/23.
//

import Foundation


/* 响应协议 */
public protocol WisdomNetworkResponseable {
    
    // 响应 Error 统一处理
    static func response(code: NSInteger, message: String, responseData: Any, timestamp: NSInteger)->WisdomNetworkFailed?
}


/* 入参数 协议, 用于 '枚举' 绑定协议实现 */
public protocol WisdomNetworkable {

    // The target's base `String`.
    var baseURL: String { get }

    // The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }

    // The HTTP method used in the request.
    var method: WisdomNetworkMethod { get }

    // Provides stub data for use in testing. Default is `Data()`.
    //var sampleData: Data { get }

    // The type of HTTP task to be performed.
    var parameters: [String:Any] { get }

    // The type of validation to perform on the request. Default is `.none`.
    //var validationType: ValidationType { get }

    // The headers to be used in the request.
    var headers: [String:String]? { get }
    
    // The description in the request.
    var description: String { get }
    
    // The response result
    //var responseable: CNetworkResponseable.Type? { get }
    
    // MARK: Debug 环境下模拟数据。如果请求实现此属性 Debug 环境不在走网络数据，Release 环境自动忽略。
    // - code         : NSInteger
    // - message      : String
    // - responseData : Any
    // - asyncTime    : TimeInterval 异步延迟
    var debugData: (code: NSInteger, message: String, responseData: Any, asyncTime: TimeInterval)? { get }
}


public extension WisdomNetworkable {

    // The type of validation to perform on the request. Default is `.none`.
    //var validationType: ValidationType { .none }

    // Provides stub data for use in testing. Default is `Data()`.
    //var sampleData: Data { Data() }
    
    var headers: [String:String]? { nil }
    
    var description: String { "" }
    
    //var responseable: CNetworkResponseable.Type? { nil }
    
    var debugData: (code: NSInteger, message: String, responseData: Any, asyncTime: TimeInterval)? { nil }
}


protocol WisdomNetworkSetable {

    static func setNetwork(baseURL: String)

    static func setNetwork(responseable: WisdomNetworkResponseable.Type)
    
    static func setNetwork(requestTimeoutInterval: TimeInterval) 
}


protocol WisdomNetworkInfoable where Self: WisdomNetwork {

    static var baseURL: String? { get }

    static var responseable: WisdomNetworkResponseable.Type? { get }
    
    static var currentNetworkState: WisdomNetworkStatus { get }
}


protocol WisdomNetworkEncoderable {

    static func encoderJson(dict: [String: Any])->String

    static func encoderDict(data: Data)->[String:Any]
}
