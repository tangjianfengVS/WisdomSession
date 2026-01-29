//
//  WisdomSession.swift
//  WisdomSession
//
//  Created by qmlt on 2023/11/23.
//

import Foundation
import Alamofire


public class WisdomSession: WisdomSessionInfoable {

    @objc var data: String?

    @objc var message: String?

    @objc var msg: String?

    @objc var code: String?

    @objc var timestamp: String?


    // MARK: 查看全局 baseURL
    /// - Parameters:
    ///   - baseURL: client domain
    public static var baseURL: String? {
        get { WisdomSessionCore.baseURL }
    }

    // MARK: 查看全局 响应拦截器
    /// - Parameters:
    ///   - responseable: client response result
    public static var responseable: WisdomSessionResponseable.Type? {
        get { WisdomSessionCore.responseable }
    }

    // MARK: 查看当前 网络信息状态
    /// - Parameters:
    ///   - currentSessionState: current session state
    public static var currentSessionState: WisdomSessionStatus {
        get { WisdomSessionCore.getClientState() }
    }
    
    // MARK: 查看全局 请求头参数
    /// - Parameters:
    ///   - headersable: client headersable result
    public static var headersable: WisdomSessionHeadersable.Type? {
        get { WisdomSessionCore.headersable }
    }
}


extension WisdomSession {

    // MARK: 通过配置 CNetworkable 参数，网络请求
    /// - Parameters:
    ///   - clientable         : 请求参数配置
    ///   - succeedClosure: 成功结果回调
    ///   - failedClosure  : 失败结果回调
    /// - Returns: DataRequest?
    @discardableResult
    public static func request(clientable: WisdomSessionApiable,
                               succedClosure: @escaping WisdomSessionSuccedClosure,
                               failedClosure: @escaping WisdomSessionFailedClosure)->DataRequest? {
        return WisdomSessionCore.request(clientable: clientable,
                                         succedClosure: succedClosure,
                                         failedClosure: failedClosure)
    }

    
    // MARK: 通过配置 CNetworkRequest 参数，网络请求
    /// - Parameters:
    ///   - request               : 请求参数配置
    ///   - succeedClosure: 成功结果回调
    ///   - failedClosure  : 失败结果回调
    public static func request(request: WisdomSessionRequest,
                               succedClosure: @escaping WisdomSessionSuccedClosure,
                               failedClosure: @escaping WisdomSessionFailedClosure) {
        _ = WisdomSessionCore.request(request: request, succedClosure: succedClosure, failedClosure: failedClosure)
    }
}


extension WisdomSession: WisdomSessionGlobalSetable {

    // MARK: 配置全局 baseURL
    /// - Parameters:
    ///   - baseURL: client domain， Client set baseURL
    public static func setSession(baseURL: String) {
        WisdomSessionCore.setSession(baseURL: baseURL)
    }

    // MARK: 配置全局 响应拦截器
    /// - Parameters:
    ///   - responseable: Client set responseable
    public static func setSession(responseable: WisdomSessionResponseable.Type) {
        WisdomSessionCore.setSession(responseable: responseable)
    }

    // MARK: 配置全局 请求超时 时间
    /// - Parameters:
    ///   - requestTimeoutInterval: TimeInterval
    public static func setSession(requestTimeoutInterval: TimeInterval) {
        WisdomSessionCore.setSession(requestTimeoutInterval: requestTimeoutInterval)
    }

    // MARK: 配置显示 请求日志
    /// - Parameters:
    ///   - openLog: Bool （默认开启 openLog == true）
    public static func setSession(openLog: Bool) {
        WisdomSessionCore.setSession(openLog: openLog)
    }
    
    // MARK: 配置全局 请求头参数
    /// - Parameters:
    ///   - headersable: Client set headersable
    public static func setSession(headersable: WisdomSessionHeadersable.Type) {
        WisdomSessionCore.setSession(headersable: headersable)
    }
}


extension WisdomSession: WisdomSessionEncoderable {

    // MARK: 字典 转 Json
    /// - Parameters: [String: Any]
    public static func encoderJson(dict: [String: Any]) -> String {
        return WisdomSessionCore.encoderJson(dict: dict)
    }

    // MARK: Data 转 字典
    /// - Parameters: Data
    public static func encoderDict(data: Data) -> [String: Any] {
        return WisdomSessionCore.encoderDict(data: data)
    }
}
