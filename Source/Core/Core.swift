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
    private(set) static var baseURL: String?
    
    /* network response result */
    private(set) static var responseable: WisdomSessionResponseable.Type?
    
    /* network timeout interval for request */
    private(set) static var timeoutIntervalForRequest: TimeInterval = 45
    
    private(set) static var openLog = true

    
    /* network requestable */
    static func request(clientable: WisdomSessionable,
                        responseable: WisdomSessionResponseable.Type?,
                        succedClosure: @escaping WisdomSessionSuccedClosure,
                        failedClosure: @escaping WisdomSessionFailedClosure)->DataRequest? {
        let request = WisdomSessionRequest(baseUrl: clientable.baseURL,
                                           path: clientable.path,
                                           method: clientable.method,
                                           parameters: clientable.parameters,
                                           headers: clientable.headers ?? [:],
                                           debugData: clientable.debugData,
                                           responseable: responseable,
                                           desc: clientable.description)
        return Self.request(request: request, succedClosure: succedClosure, failedClosure: failedClosure)
    }

    
    /* network request */
    static func request(request: WisdomSessionRequest,
                        succedClosure: @escaping WisdomSessionSuccedClosure,
                        failedClosure: @escaping WisdomSessionFailedClosure)->DataRequest? {
        
        func result(code: NSInteger, msg: String, timestamp: NSInteger, data: Any, resultClosure: ((Bool)->())?=nil){
            if request.responseable != nil || Self.responseable != nil {
                var processed = false
                // request -> responseable
                if let able = request.responseable, let failed = able.response(code: code,
                                                                               message: msg,
                                                                               timestamp: timestamp,
                                                                               responseData: data) {
                    processed = true
                    resultClosure?(false)
                    failedClosure(failed.code, failed.message, failed.timestamp, "\(data)")
                }
                
                // 全局 -> responseable
                if let able = Self.responseable, let failed = able.response(code: code,
                                                                            message: msg,
                                                                            timestamp: timestamp,
                                                                            responseData: data) {
                    processed = true
                    resultClosure?(false)
                    failedClosure(failed.code, failed.message, failed.timestamp, "\(data)")
                }
                
                if processed==false {
                    resultClosure?(true)
                    succedClosure(code, msg, timestamp, data)
                }
            }else {
                resultClosure?(true)
                succedClosure(code, msg, timestamp, data)
            }
        }
        
        if let url = URL(string: request.url) {
            let method = HTTPMethod(rawValue: request.method.rawValue)
            let headers = HTTPHeaders(request.headers ?? [:])
            var encoding: ParameterEncoding = JSONEncoding.default
            if method == .get {
                encoding = URLEncoding.default
            }
            Alamofire.AF.sessionConfiguration.timeoutIntervalForRequest = Self.timeoutIntervalForRequest
            Alamofire.AF.sessionConfiguration.headers = .default
            
            if Self.openLog {
                print("❤️❤️------- WisdomSession - Request - Start -------❤️❤️")
                print(request)
                print("-------------------------------------------------------")
            }
            
            #if DEBUG
            if let debugData = request.debugData {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + debugData.asyncTime, execute: {
                    if Self.openLog {
                        print("✅-------- WisdomSession - DebugData - Success --------✅")
                        print(debugData)
                        print("---------------------------------------------------------")
                    }
                    
                    if debugData.code < 0 {
                        failedClosure(debugData.code,
                                      debugData.message,
                                      debugData.timestamp,
                                      "\(debugData.responseData)")
                    }else {
                        result(code     : debugData.code,
                               msg      : debugData.message,
                               timestamp: debugData.timestamp,
                               data     : debugData.responseData)
                    }
                })
                return nil
            }
            #endif
            
            let dataRequest = Alamofire.AF.request(url, method: method, parameters: request.parameters, encoding: encoding, headers: headers, interceptor: nil).responseData { dataResponse in
                
                switch dataResponse.result {
                case .failure(let afError):
                    if Self.openLog {
                        print("❌-------- WisdomSession - Response - Error --------❌")
                        print(afError)
                        print("------------------------------------------------------")
                    }
                    var error = afError.errorDescription ?? ""
                    if "\(afError)".contains("Code=-1020") || "\(afError)".contains("Code=-1009") {
                        error = "网络连接错误，请检查网络"
                    }else if "\(afError)".contains("Code=-1001") {
                        error = "网络连接超时，请检查网络"
                    }else {
                        error = "网络请求失败，请稍后重试"
                    }
                    failedClosure(afError.responseCode ?? -1, error, 0, "\(afError)")
                    
                case .success(let data):
                    let dictResponse = encoderDict(data: data)
                    let data = dictResponse[#keyPath(WisdomSession.data)] ?? ""
                    var msg = dictResponse[#keyPath(WisdomSession.message)] as? String
                    if msg == nil {
                        msg = (dictResponse[#keyPath(WisdomSession.msg)] as? String) ?? ""
                    }
                    
                    let code = dictResponse[#keyPath(WisdomSession.code)]
                    let timestamp = dictResponse[#keyPath(WisdomSession.timestamp)] as? NSInteger ?? 0
                    
                    var codeValue: NSInteger = 0
                    if let code_double = code as? Double {
                       codeValue = NSInteger(code_double)
                    }else if let code_integer = code as? NSInteger {
                       codeValue = code_integer
                    }
                    
                    for error in WisdomSessionErrorStauts.allCases {
                        if error.rawValue == codeValue {
                            if Self.openLog {
                                print("❌-------- WisdomSession - Response - Error --------❌")
                                print(dictResponse)
                                print("------------------------------------------------------")
                            }
                            if request.responseable != nil || Self.responseable != nil {
                                var processed = false
                                // request -> responseable
                                if let able = request.responseable, let failed = able.response(code: codeValue,
                                                                                               message: msg ?? "",
                                                                                               timestamp: timestamp,
                                                                                               responseData: data) {
                                    processed = true
                                    failedClosure(failed.code, failed.message, timestamp, "\(data)")
                                }
                                // 全局 -> responseable
                                if let able = Self.responseable, let failed = able.response(code: codeValue,
                                                                                            message: msg ?? "",
                                                                                            timestamp: timestamp,
                                                                                            responseData: data) {
                                    processed = true
                                    failedClosure(failed.code, failed.message, timestamp, "\(data)")
                                }
                                
                                if processed==false {
                                    failedClosure(codeValue, msg ?? "", timestamp, "\(data)")
                                }
                            }else {
                                failedClosure(codeValue, msg ?? "", timestamp, "\(data)")
                            }
                            return
                        }
                    }
                    
                    result(code: codeValue, msg: msg ?? "", timestamp: timestamp, data: data as Any) { res in
                        if Self.openLog {
                            if res {
                                print("✅-------- WisdomSession - Response - Success --------✅")
                                print(dictResponse)
                                print("--------------------------------------------------------")
                            }else {
                                print("❌-------- WisdomSession - Response - Error --------❌")
                                print(dictResponse)
                                print("------------------------------------------------------")
                            }
                        }
                    }
                }
            }
            return dataRequest
        }else {
            if Self.openLog {
                print("❌-------- WisdomSession - Request - Error --------❌")
                print("url init failed: "+"url error: "+request.url)
                print("-----------------------------------------------------")
            }
            failedClosure(-1, "url init failed", 0, "url error: "+request.url)
        }
        return nil
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


extension WisdomSessionCore: WisdomSessionSetable {
    
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
