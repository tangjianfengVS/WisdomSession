//
//  WisdomNetwork.swift
//  Wisdom-Network
//
//  Created by qmlt on 2023/11/23.
//

import Foundation
import Alamofire


/* 请求方案 */
public enum WisdomNetworkMethod: String {
    case GET  = "GET"
    case POST = "POST"
}

/* 网络状态 */
public enum WisdomNetworkStatus {
    case notReachable   // 无网
    case unknown        // 未知
    case ethernetOrWiFi // WIFI
    case cellular       // 蜂窝网络
}

/* 1.code: 响应码  2.message: 响应信息  3.responseData: 响应数据 */
public typealias WisdomNetworkSucceedClosure = (_ code: NSInteger, _ message: String, _ responseData: Any)->()

/* 1.code: 错误码  2.message: 错误信息  3.rawResponseString: 原始信息 */
public typealias WisdomNetworkFailedClosure = (_ code: NSInteger, _ message: String, _ rawResponseString: String)->()

/* 1.code: 错误码  2.message: 错误信息 */
public typealias WisdomNetworkFailed = (code: NSInteger, message: String)


public class WisdomNetwork: WisdomNetworkInfoable {
    
    // MARK: 查看全局 baseURL
    /// - Parameters:
    ///   - baseURL: client domain
    public static var baseURL: String? {
        get { WisdomNetworkCore.baseURL }
    }

    // MARK: 查看全局 响应拦截器
    /// - Parameters:
    ///   - responseable: client response result
    public static var responseable: WisdomNetworkResponseable.Type? {
        get { WisdomNetworkCore.responseable }
    }
    
    // MARK: 查看当前 网络信息状态
    /// - Parameters:
    ///   - currentNetworkState: current network state
    public static var currentNetworkState: WisdomNetworkStatus {
        get { WisdomNetworkCore.getClientState() }
    }
}

extension WisdomNetwork {
    
    // MARK: 通过配置 CNetworkable 参数，网络请求
    /// - Parameters:
    ///   - clientable         : 请求参数配置
    ///   - responseable    : 响应拦截器
    ///   - succeedClosure: 成功结果回调
    ///   - failedClosure  : 失败结果回调
    /// - Returns: DataRequest?
    @discardableResult
    public static func request(clientable: WisdomNetworkable,
                               responseable: WisdomNetworkResponseable.Type?=nil,
                               succeedClosure: @escaping WisdomNetworkSucceedClosure,
                               failedClosure: @escaping WisdomNetworkFailedClosure)->DataRequest? {
        return WisdomNetworkCore.request(clientable: clientable,
                                         responseable: responseable,
                                         succeedClosure: succeedClosure,
                                         failedClosure: failedClosure)
    }
    
    // MARK: 通过配置 CNetworkRequest 参数，网络请求
    /// - Parameters:
    ///   - request               : 请求参数配置
    ///   - succeedClosure: 成功结果回调
    ///   - failedClosure  : 失败结果回调
    /// - Returns: DataRequest?
    @discardableResult
    public static func request(request: WisdomNetworkRequest,
                               succeedClosure: @escaping WisdomNetworkSucceedClosure,
                               failedClosure: @escaping WisdomNetworkFailedClosure)->DataRequest? {
        return WisdomNetworkCore.request(request: request,
                                         succeedClosure: succeedClosure,
                                         failedClosure: failedClosure)
    }
}

extension WisdomNetwork: WisdomNetworkSetable {

    // MARK: 配置全局 baseURL
    /// - Parameters:
    ///   - baseURL: client domain， Client set baseURL
    public static func setNetwork(baseURL: String) {
        WisdomNetworkCore.setNetwork(baseURL: baseURL)
    }

    // MARK: 配置全局 响应拦截器
    /// - Parameters:
    ///   - responseable: Client set responseable
    public static func setNetwork(responseable: WisdomNetworkResponseable.Type) {
        WisdomNetworkCore.setNetwork(responseable: responseable)
    }
    
    // MARK: 配置全局 请求超时 时间
    /// - Parameters:
    ///   - requestTimeoutInterval: TimeInterval
    public static func setNetwork(requestTimeoutInterval: TimeInterval) {
        WisdomNetworkCore.setNetwork(requestTimeoutInterval: requestTimeoutInterval)
    }
    
    // MARK: 配置显示 请求日志
    /// - Parameters:
    ///   - openLog: Bool （默认开启 openLog == true）
    public static func setNetwork(openLog: Bool) {
        WisdomNetworkCore.setNetwork(openLog: openLog)
    }
}

extension WisdomNetwork: WisdomNetworkEncoderable {
    
    // MARK: 字典 转 Json
    /// - Parameters: [String: Any]
    public static func encoderJson(dict: [String: Any]) -> String {
        return WisdomNetworkCore.encoderJson(dict: dict)
    }
    
    // MARK: Data 转 字典
    /// - Parameters: Data
    public static func encoderDict(data: Data) -> [String: Any] {
        return WisdomNetworkCore.encoderDict(data: data)
    }
}
