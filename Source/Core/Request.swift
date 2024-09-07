//
//  WisdomSession+Request.swift
//  WisdomSession
//
//  Created by qmlt on 2023/11/23.
//

import Foundation


public struct WisdomSessionRequest {

    public let url: String // 域名 + path
    
    public let baseUrl: String?
    
    public let urlPath: String
    
    public let method: WisdomSessionMethod
    
    public let parameters: [String:Any]
    
    public let headers: [String:String]?
    
    public let description: String
    
    public let responseable: WisdomSessionResponseable.Type?
    
    // MARK: Debug 环境下模拟数据。如果请求实现此属性 Debug 环境不在走网络数据，Release 环境自动忽略。
    // - code         : NSInteger
    // - message      : String
    // - responseData : Any
    // - asyncTime    : TimeInterval 异步延迟
    public let debugData: (code: NSInteger,
                           message: String,
                           responseData: Any,
                           asyncTime: TimeInterval)?
    
    /* url path 路径 初始化 */
    public init(path: String,
                method: WisdomSessionMethod,
                parameters: [String:Any],
                headers: [String:String]?=nil,
                debugData: (code: NSInteger, message: String, responseData: Any, asyncTime: TimeInterval)?=nil,
                responseable: WisdomSessionResponseable.Type?=nil,
                desc: String="") {
        if let baseURL = WisdomSessionCore.baseURL, baseURL.count > 0{
            url = Self.getUrl(baseUrl: baseURL, urlPath: path)
            self.baseUrl = baseURL
        }else {
            url = path
            self.baseUrl = path
        }
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.debugData = debugData
        self.responseable = responseable
        description = desc
        urlPath = path
    }
    
    /* baseUrl + url path 路径 初始化 */
    public init(baseUrl: String,
                path: String,
                method: WisdomSessionMethod,
                parameters: [String:Any],
                headers: [String:String]?=nil,
                debugData: (code: NSInteger, message: String, responseData: Any, asyncTime: TimeInterval)?=nil,
                responseable: WisdomSessionResponseable.Type?=nil,
                desc: String="") {
        url = Self.getUrl(baseUrl: baseUrl, urlPath: path)
        
        self.baseUrl = baseUrl
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.debugData = debugData
        self.responseable = responseable
        description = desc
        urlPath = path
    }
    
    private static func getUrl(baseUrl: String, urlPath: String) -> String {
        let hasSuffix = baseUrl.hasSuffix("/")
        let hasPrefix = urlPath.hasPrefix("/")
        
        if hasSuffix && hasPrefix {
            var base_Url = baseUrl
            base_Url.removeLast()
            return base_Url + urlPath
        }else if !hasSuffix && !hasPrefix {
            let url_Path = "/"+urlPath
            return baseUrl + url_Path
        }else {
            return baseUrl + urlPath
        }
    }
}
