//
//  Core.swift
//  WisdomSession
//
//  Created by qmlt on 2023/11/23.
//

import Foundation
import Alamofire


struct WisdomSessionCore {
    
    /* network domain */
    nonisolated(unsafe) private(set) static var baseURL: String?
    
    /* network response result */
    nonisolated(unsafe) private(set) static var responseable: WisdomSessionResponseable.Type?
    
    /* network timeout interval for request */
    nonisolated(unsafe) private(set) static var timeoutIntervalForRequest: TimeInterval = 45
    
    nonisolated(unsafe) private(set) static var openLog = true
    
    nonisolated(unsafe) private(set) static var headersable: WisdomSessionHeadersable.Type?

    
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
            }
            
            Alamofire.AF.sessionConfiguration.timeoutIntervalForRequest = Self.timeoutIntervalForRequest
            Alamofire.AF.sessionConfiguration.headers = .default
            
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
            
            let dataRequest = Alamofire.AF.request(url, method: method, parameters: request.parameters, encoding: encoding, headers: headers, interceptor: nil).responseData { dataResponse in

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
            let responseData = dictResponse[#keyPath(WisdomSession.data)] ?? ""
            // 转为 Sendable 类型
            let sendableData: any Sendable = "\(responseData)"
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

            for error in WisdomSessionErrorStauts.allCases {
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
            succedClosure(code, msg, WisdomSessionSafer(value: data))
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
        Self.baseURL = baseURL
    }
    
    static func setSession(responseable: WisdomSessionResponseable.Type) {
        Self.responseable = responseable
    }
    
    static func setSession(requestTimeoutInterval: TimeInterval)  {
        Self.timeoutIntervalForRequest = requestTimeoutInterval
    }
    
    static func setSession(openLog: Bool) {
        Self.openLog = openLog
    }
    
    public static func setSession(headersable: WisdomSessionHeadersable.Type) {
        Self.headersable = headersable
    }
}


extension WisdomSessionCore: WisdomSessionEncoderable {
    
    static func encoderJson(dict: [String : Any]) -> String {
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [])
        let strJson = String(data: data!, encoding: String.Encoding.utf8)
        if strJson == nil {
            return ""
        }
        return strJson!
    }
    
    static func encoderDict(data: Data) -> [String : Any] {
        if let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
           let dict = result as? [String:Any] {
            return dict
        }
        return [:]
    }
}
