//
//  Able.swift
//  WisdomSession
//
//  Created by jianfeng on 2023/11/23.
//

import Foundation
import Alamofire


public protocol WisdomSessionable {
    
    // MARK: The target's base `String`. (设置请求域名)
    var baseURL: String { get }

    // MARK: The path to be appended to `baseURL` to form the full `URL`. (设置请求路径)
    var path: String { get }

    // MARK: The headers to be used in the request. (设置请求头参数)
    var headers: [String:String]? { get }

    // MARK: The type of HTTP task to be performed. (设置请求体参数)
    var parameters: [String: any Sendable] { get }
    
    // The type of validation to perform on the request. Default is `.none`.
    //var validationType: ValidationType { get }

    // MARK: The description in the request. (设置请求描述)
    var description: String { get }

    // MARK: Debug 环境下相应模拟数据。如果请求实现此属性， Debug 环境不在走网络数据，Release 环境自动忽略。
    // - code         : NSInteger
    // - message      : String
    // - timestamp    : 时间戳
    // - responseData : Any
    // - asyncTime    : TimeInterval 异步延迟
    var responseDebugData: WisdomSessionDebugData? { get }
    
    // MARK: The Current Session Cancel. (停止当前网络请求)
    func cancelSession()
}


// MARK: 设置网络请求，绑定协议实现
public protocol WisdomSessionApiable: WisdomSessionable {
    
    var dataRequest: DataRequest? { get set }

    // MARK: The HTTP method used in the request. (设置请求方案)
    var method: WisdomSessionMethod { get }
    
    // MARK: Session Start. (开启网络请求)
    func request(succedClosure: @escaping WisdomSessionSuccedClosure, failedClosure: @escaping WisdomSessionFailedClosure)
    
}


public extension WisdomSessionApiable {

    var headers: [String:String]? { nil }

    var parameters: [String: any Sendable] { [:] }

    var description: String { "" }

    var responseDebugData: WisdomSessionDebugData? { nil }
    
    mutating func request(succedClosure: @escaping WisdomSessionSuccedClosure, failedClosure: @escaping WisdomSessionFailedClosure) {
        let dataRequest = WisdomSession.request(clientable: self, succedClosure: succedClosure, failedClosure: failedClosure)
        self.dataRequest = dataRequest
    }
    
    func cancelSession() {
        dataRequest?.cancel()
    }
}


// MARK: 设置网络请求，绑定协议实现 - 文件上传
public protocol WisdomSessionUploadApiable: WisdomSessionable {
    
    var uploadRequest: UploadRequest? { get set }

    // MARK: The HTTP method used in the request. (设置请求方案)
    var method: WisdomSessionUploadMethod { get }
    
    // MARK: Session Start. (开启网络请求)
    func requestUpload(succedClosure: @escaping WisdomSessionSuccedClosure, failedClosure: @escaping WisdomSessionFailedClosure)
    
}


public extension WisdomSessionUploadApiable {

    var headers: [String:String]? { nil }

    var parameters: [String: any Sendable] { [:] }

    var description: String { "" }

    var responseDebugData: WisdomSessionDebugData? { nil }
    
    mutating func requestUpload(succedClosure: @escaping WisdomSessionSuccedClosure, failedClosure: @escaping WisdomSessionFailedClosure) {
        let uploadRequest = WisdomSession.requestUpload(clientable: self, succedClosure: succedClosure, failedClosure: failedClosure)
        self.uploadRequest = uploadRequest
    }
    
    func cancelSession() {
        uploadRequest?.cancel()
    }
}
