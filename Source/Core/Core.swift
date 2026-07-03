//
//  Core.swift
//  WisdomSession
//
//  Created by qmlt on 2023/11/23.
//

import Foundation
import Alamofire


struct WisdomSessionCore {

    /* 保护全局可变配置的锁，避免读写数据竞争 */
    private static let configLock = NSLock()

    /* network domain */
    nonisolated(unsafe) private static var _baseURL: String?

    /* network response result */
    nonisolated(unsafe) private static var _responseable: WisdomSessionResponseable.Type?

    /* network timeout interval for request */
    nonisolated(unsafe) private static var _timeoutIntervalForRequest: TimeInterval = 45

    nonisolated(unsafe) private static var _openLog = true

    nonisolated(unsafe) private static var _headersable: WisdomSessionHeadersable.Type?


    /* network domain */
    static var baseURL: String? {
        configLock.lock(); defer { configLock.unlock() }
        return _baseURL
    }

    /* network response result */
    static var responseable: WisdomSessionResponseable.Type? {
        configLock.lock(); defer { configLock.unlock() }
        return _responseable
    }

    /* network timeout interval for request */
    static var timeoutIntervalForRequest: TimeInterval {
        configLock.lock(); defer { configLock.unlock() }
        return _timeoutIntervalForRequest
    }

    static var openLog: Bool {
        configLock.lock(); defer { configLock.unlock() }
        return _openLog
    }

    static var headersable: WisdomSessionHeadersable.Type? {
        configLock.lock(); defer { configLock.unlock() }
        return _headersable
    }

    
    /* network requestable */
    static func request(clientable: WisdomSessionApiable,
                        succedClosure: @escaping WisdomSessionSuccedClosure,
                        failedClosure: @escaping WisdomSessionFailedClosure)->DataRequest? {
        let request = WisdomSessionRequest(baseUrl: clientable.baseURL,
                                           path: clientable.path,
                                           method: clientable.method,
                                           parameters: clientable.parameters,
                                           headers: clientable.headers ?? [:],
                                           responseDebugData: clientable.responseDebugData,
                                           description: clientable.description)
        return Self.request(request: request, succedClosure: succedClosure, failedClosure: failedClosure)
    }

    
    /* network request */
    static func request(request: WisdomSessionRequest,
                        succedClosure: @escaping WisdomSessionSuccedClosure,
                        failedClosure: @escaping WisdomSessionFailedClosure)->DataRequest? {
        var url = URL(string: request.url)
        if url == nil && !(request.baseUrl ?? "").isEmpty {
            url = URL(string: WisdomSessionRequest.getUrl(baseUrl: Self.baseURL ?? "", urlPath: request.urlPath))
        }
        
        if let url {
            // 全局 -> headers
            var request_headers = Self.headersable?.headers ?? [:]
            if let headers = request.headers, headers.count > 0 {
                for header in headers {
                    request_headers[header.key] = header.value
                }
            }
            
            let method = HTTPMethod(rawValue: request.method.rawValue)
            let headers = HTTPHeaders(request_headers)
            var encoding: ParameterEncoding = JSONEncoding.default
            if method == .get {
                encoding = URLEncoding.default
            } else if let contentType = request_headers.first(where: { $0.key.caseInsensitiveCompare("Content-Type") == .orderedSame })?.value,
                      contentType.lowercased().contains("application/x-www-form-urlencoded") {
                // Content-Type 显式声明为表单编码时，body 用 key1=value1&key2=value2 而不是 JSON
                encoding = URLEncoding.httpBody
            }
            
            // 通过 requestModifier 设置单次请求超时（直接改 AF.sessionConfiguration 对已创建的 session 无效）
            let timeout = Self.timeoutIntervalForRequest

            let openLog = Self.openLog
            if openLog {
                print("[WisdomSession]: 🔥 Request - Start 🔥")
                print("URL = \(url.absoluteString)")
                print("Request = \(request)")
                print("---------------------------------------")
            }
            
            #if DEBUG
            if let debugData = request.responseDebugData {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + debugData.asyncTime, execute: {
                    if openLog {
                        print("[WisdomSession]: ✅ DebugData - Success ✅")
                        print("URL = \(url.absoluteString)")
                        print("DebugData = \(debugData)")
                        print("-------------------------------------------")
                    }
                    
                    if debugData.code <= 0 {
                        failedClosure(debugData.code, debugData.message, "\(debugData.responseData)")
                    }else {
                        Self.result(code: debugData.code,
                                    msg: debugData.message,
                                    data: debugData.responseData,
                                    succedClosure: succedClosure,
                                    failedClosure: failedClosure)
                    }
                })
                request.setDataRequest(dataRequest: nil)
                return nil
            }
            #endif
            
            let dataRequest = Alamofire.AF.request(url, method: method, parameters: request.parameters, encoding: encoding, headers: headers, interceptor: nil, requestModifier: { $0.timeoutInterval = timeout }).responseData { dataResponse in

                nonisolated(unsafe) let unsafeResponse = dataResponse
                
                DispatchQueue.main.async(execute: {
                    Self.setResponseResult(url: url, openLog: openLog, dataResponse: unsafeResponse, uploadDataResponse: nil, succedClosure: succedClosure, failedClosure: failedClosure)
                })
            }
            
            request.setDataRequest(dataRequest: dataRequest)
            return dataRequest
        }else {
            if openLog {
                print("[WisdomSession]: ❌ Request - URL - Error ❌")
                print("Request   URL = \(request.url)")
                print("Core Base URL = \(Self.baseURL ?? "")")
                print("--------------------------------------------")
            }
            request.setDataRequest(dataRequest: nil)
            
            let url = request.url
            DispatchQueue.main.async(execute: {
                failedClosure(-1, "无效链接", "Request URL = \(url)" + "/Core Base URL = \(Self.baseURL ?? "")")
            })
            return nil
        }
    }
    
    
    @MainActor
    static func setResponseResult(url: URL,
                                  openLog: Bool,
                                  dataResponse: AFDataResponse<Data>?,
                                  uploadDataResponse: AFDataResponse<Data?>?,
                                  succedClosure: WisdomSessionSuccedClosure,
                                  failedClosure: WisdomSessionFailedClosure) {
        if let dataResponse {
            switch dataResponse.result {
            case .failure(let afError):
                onSetFailure(afError: afError)
            case .success(let data):
                onSetSuccess(data: data)
            }
        }else if let uploadDataResponse {
            switch uploadDataResponse.result {
            case .failure(let afError):
                onSetFailure(afError: afError)
            case .success(let data):
                onSetSuccess(data: data ?? Data())
            }
        }
        
        // 失败处理
        @MainActor
        func onSetFailure(afError: AFError) {
            var error = afError.errorDescription ?? "网络请求失败，请稍后重试"
            if "\(afError)".contains("Code=-1020") || "\(afError)".contains("Code=-1009") {
                error = "网络连接错误，请检查网络"
            }else if "\(afError)".contains("Code=-1001") {
                error = "网络连接超时，请检查网络"
            }
            
            if openLog {
                print("[WisdomSession]: ❌ Response - Error ❌")
                print("URL = \(url.absoluteString)")
                print("Error = \(error)")
                print("AFError = \(afError)")
                print("----------------------------------------")
            }
            
            failedClosure(afError.responseCode ?? -1, error, "\(afError)")
        }
        
        // 成功处理
        @MainActor
        func onSetSuccess(data: Data) {
            let dictResponse = Self.encoderDict(data: data)

            // 响应体非空但无法解析为 JSON 对象，视为失败，避免被静默当作成功
            if dictResponse.isEmpty && !data.isEmpty {
                let raw = String(data: data, encoding: .utf8) ?? ""
                if openLog {
                    print("[WisdomSession]: ❌ Response - Parse - Error ❌")
                    print("URL = \(url.absoluteString)")
                    print("Raw = \(raw)")
                    print("----------------------------------------")
                }
                failedClosure(-1, "数据解析失败", raw)
                return
            }
            
            let resData = dictResponse[#keyPath(WisdomSession.data)]
            let responseData: any Sendable = resData != nil ? "\(resData!)" : encoderJson(dict: dictResponse) // Bug: 修复Data字段为空，直接返回原数据
  
            // 转为 Sendable 类型
            let sendableData: any Sendable = responseData
            var msg = dictResponse[#keyPath(WisdomSession.message)] as? String
            if msg == nil {
                msg = (dictResponse[#keyPath(WisdomSession.msg)] as? String) ?? ""
            }

            let code = dictResponse[#keyPath(WisdomSession.code)]

            var codeValue: NSInteger = 0
            if let code_double = code as? Double {
               codeValue = NSInteger(code_double)
            }else if let code_integer = code as? NSInteger {
               codeValue = code_integer
            }

            for error in WisdomSessionErrorStatus.allCases {
                if error.rawValue == codeValue {
                    
                    if openLog {
                        print("[WisdomSession]: ❌ Response - Error ❌")
                        print("URL = \(url.absoluteString)")
                        print("Response = \(dictResponse)")
                        print("----------------------------------------")
                    }
                    
                    if Self.responseable != nil {
                        var processed = false
                        // 全局 -> responseable
                        if let able = Self.responseable, let failed = able.response(code: codeValue,
                                                                                    message: msg ?? "",
                                                                                    responseData: responseData) {
                            processed = true
                            failedClosure(failed.code, failed.message, "\(responseData)")
                        }

                        if processed == false {
                            failedClosure(codeValue, msg ?? "", "\(responseData)")
                        }
                    }else {
                        failedClosure(codeValue, msg ?? "", "\(responseData)")
                    }
                    return
                }
            }
            
            Self.result(code: codeValue, msg: msg ?? "", data: sendableData, succedClosure: succedClosure, failedClosure: failedClosure) { res in
                if openLog {
                    if res {
                        print("[WisdomSession]: ✅ Response - Success ✅")
                        print("URL = \(url.absoluteString)")
                        print("Response = \(dictResponse)")
                        print("------------------------------------------")
                    }else {
                        print("[WisdomSession]: ❌ Response - Error ❌")
                        print("URL = \(url.absoluteString)")
                        print("Response = \(dictResponse)")
                        print("----------------------------------------")
                    }
                }
            }
        }
    }
    
    
    @MainActor
    static func result(code: NSInteger,
                       msg: String,
                       data: any Sendable,
                       succedClosure: WisdomSessionSuccedClosure,
                       failedClosure: WisdomSessionFailedClosure,
                       resultClosure: ((Bool)->())?=nil) {
        // 全局 -> responseable
        if let responseable = Self.responseable, let failed = responseable.response(code: code,
                                                                           message: msg,
                                                                           responseData: data) {
            resultClosure?(false)
            failedClosure(failed.code, failed.message, "\(data)")
        }else {
            resultClosure?(true)
            succedClosure(code, msg, data)
        }
    }
    
    
    static func getClientState()-> WisdomSessionStatus {
        switch NetworkReachabilityManager.default?.status{
        case .unknown:      return .unknown
        case .notReachable: return .notReachable // 无网络
        case .reachable(let connectionType):
            switch connectionType {
            case .ethernetOrWiFi: return .ethernetOrWiFi // WIFI
            case .cellular: return .cellular // 蜂窝网络
            }
        default: return .unknown
        }
    }
}


extension WisdomSessionCore: WisdomSessionGlobalSetable {
    
    static func setSession(baseURL: String) {
        configLock.lock(); defer { configLock.unlock() }
        _baseURL = baseURL
    }

    static func setSession(responseable: WisdomSessionResponseable.Type) {
        configLock.lock(); defer { configLock.unlock() }
        _responseable = responseable
    }

    static func setSession(requestTimeoutInterval: TimeInterval)  {
        configLock.lock(); defer { configLock.unlock() }
        _timeoutIntervalForRequest = requestTimeoutInterval
    }

    static func setSession(openLog: Bool) {
        configLock.lock(); defer { configLock.unlock() }
        _openLog = openLog
    }

    public static func setSession(headersable: WisdomSessionHeadersable.Type) {
        configLock.lock(); defer { configLock.unlock() }
        _headersable = headersable
    }
}


extension WisdomSessionCore: WisdomSessionEncoderable {
    
    static func encoderJson(dict: [String : Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
              let strJson = String(data: data, encoding: String.Encoding.utf8) else {
            return ""
        }
        return strJson
    }
    
    static func encoderDict(data: Data) -> [String : Any] {
        if let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
           let dict = result as? [String:Any] {
            return dict
        }
        return [:]
    }
}
