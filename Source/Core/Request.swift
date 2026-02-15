//
//  WisdomSession+Request.swift
//  WisdomSession
//
//  Created by qmlt on 2023/11/23.
//

import Foundation
import Alamofire


public class WisdomSessionRequest {

    public let url: String // 域名 + path
    
    public let baseUrl: String?
    
    public let urlPath: String
    
    public let method: WisdomSessionMethod
    
    public let parameters: [String: any Sendable]
    
    public let headers: [String:String]?
    
    public let description: String
    
    // MARK: Debug 环境下模拟数据。如果请求实现此属性 Debug 环境不在走网络数据，Release 环境自动忽略。
    // - code         : NSInteger
    // - message      : String
    // - responseData : Any
    // - asyncTime    : TimeInterval 异步延迟
    public let responseDebugData: WisdomSessionDebugData?
    
    private var dataRequest: DataRequest?
    
    
    /* url path 路径 初始化 */
    public init(path        : String,
                method      : WisdomSessionMethod,
                parameters  : [String: any Sendable],
                headers     : [String:String]?=nil,
                responseDebugData : WisdomSessionDebugData?=nil,
                description : String="") {
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
        self.responseDebugData = responseDebugData
        self.description = description
        self.urlPath = path
    }
    
    
    /* baseUrl + url path 路径 初始化 */
    public init(baseUrl     : String,
                path        : String,
                method      : WisdomSessionMethod,
                parameters  : [String: any Sendable],
                headers     : [String:String]?=nil,
                responseDebugData : WisdomSessionDebugData?=nil,
                description : String="") {
        url = Self.getUrl(baseUrl: baseUrl, urlPath: path)
        
        self.baseUrl = baseUrl
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.responseDebugData = responseDebugData
        self.description = description
        urlPath = path
    }
    
    
    func setDataRequest(dataRequest: DataRequest?) {
        self.dataRequest = dataRequest
    }
    

    /* 停止当前网络请求 */
    public func cancelSession() {
        dataRequest?.cancel()
    }
    
    
    public static func getUrl(baseUrl: String, urlPath: String) -> String {
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


public class WisdomSessionUploadRequest {

    public let url: String // 域名 + path
    
    public let baseUrl: String?
    
    public let urlPath: String
    
    public let method: WisdomSessionUploadMethod
    
    public let parameters: [String: any Sendable]
    
    public let headers: [String:String]?
    
    public let description: String
    
    // MARK: Debug 环境下模拟数据。如果请求实现此属性 Debug 环境不在走网络数据，Release 环境自动忽略。
    // - code         : NSInteger
    // - message      : String
    // - responseData : Any
    // - asyncTime    : TimeInterval 异步延迟
    public let responseDebugData: WisdomSessionDebugData?
    
    private var uploadRequest: UploadRequest?
    
    
    /* url path 路径 初始化 */
    public init(path        : String,
                method      : WisdomSessionUploadMethod,
                parameters  : [String: any Sendable],
                headers     : [String:String]?=nil,
                responseDebugData : WisdomSessionDebugData?=nil,
                description : String="") {
        if let baseURL = WisdomSessionCore.baseURL, baseURL.count > 0{
            url = WisdomSessionRequest.getUrl(baseUrl: baseURL, urlPath: path)
            self.baseUrl = baseURL
        }else {
            url = path
            self.baseUrl = path
        }
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.responseDebugData = responseDebugData
        self.description = description
        self.urlPath = path
    }
    
    
    /* baseUrl + url path 路径 初始化 */
    public init(baseUrl     : String,
                path        : String,
                method      : WisdomSessionUploadMethod,
                parameters  : [String: any Sendable],
                headers     : [String:String]?=nil,
                responseDebugData : WisdomSessionDebugData?=nil,
                description : String="") {
        url = WisdomSessionRequest.getUrl(baseUrl: baseUrl, urlPath: path)
        
        self.baseUrl = baseUrl
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.responseDebugData = responseDebugData
        self.description = description
        urlPath = path
    }
    
    
    func setUploadRequest(uploadRequest: UploadRequest?) {
        self.uploadRequest = uploadRequest
    }
    

    /* 停止当前网络请求 */
    public func cancelSession() {
        uploadRequest?.cancel()
    }
}
