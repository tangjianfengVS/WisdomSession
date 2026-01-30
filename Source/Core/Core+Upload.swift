//
//  Core+Upload.swift
//  WisdomNetwork
//
//  Created by qmlt on 2023/11/29.
//

import Foundation
import Alamofire


extension WisdomSessionCore {
    
    /* network requestable 文件上传 */
    static func requestUpload(clientable: WisdomSessionUploadApiable,
                              succedClosure: @escaping WisdomSessionSuccedClosure,
                              failedClosure: @escaping WisdomSessionFailedClosure)->UploadRequest? {
        let request = WisdomSessionUploadRequest(baseUrl: clientable.baseURL,
                                                 path: clientable.path,
                                                 method: clientable.method,
                                                 parameters: clientable.parameters,
                                                 headers: clientable.headers ?? [:],
                                                 responseDebugData: clientable.responseDebugData,
                                                 description: clientable.description)
        return Self.requestUpload(request: request, succedClosure: succedClosure, failedClosure: failedClosure)
    }
    
    
    /* network request 文件上传 */
    static func requestUpload(request: WisdomSessionUploadRequest,
                              succedClosure: @escaping WisdomSessionSuccedClosure,
                              failedClosure: @escaping WisdomSessionFailedClosure)->UploadRequest? {
        
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
            let headers = HTTPHeaders(request_headers)
            
            var method: HTTPMethod!
            switch request.method {
            case .PUT:
                method = .put
            case .POST:
                method = .post
            }
            
            //Alamofire.AF.sessionConfiguration.timeoutIntervalForRequest = Self.timeoutIntervalForRequest
            //Alamofire.AF.sessionConfiguration.headers = .default
            
            let openLog = Self.openLog
            if openLog {
                print("[WisdomSession]: 🔥 Request - Start 🔥")
                print("URL = \(url.absoluteString)")
                print(request)
                print("---------------------------------------")
            }
            
            #if DEBUG
            if let debugData = request.responseDebugData {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + debugData.asyncTime, execute: {
                    if openLog {
                        print("[WisdomSession]: ✅ DebugData - Success ✅")
                        print("URL = \(url.absoluteString)")
                        print(debugData)
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
                request.setUploadRequest(uploadRequest: nil)
                return nil
            }
            #endif
            
            let uploadRequest = Alamofire.AF.upload(multipartFormData: { imageData in
                
                if request.parameters.count > 0 {

                    for (key, value) in request.parameters {
                        // 音频文件
                        if key == #keyPath(WisdomSession.voice) {
                            if let jsonData = value as? Data {
                                let fileName = "voice_\(Int(Date().timeIntervalSince1970)).m4a"
                                imageData.append(jsonData, withName: key, fileName: fileName, mimeType: "voice/m4a")
                            }
                        // 视频文件
                        }else if key == #keyPath(WisdomSession.video) {
                            if let jsonData = value as? Data {
                                let fileName = "video_\(Int(Date().timeIntervalSince1970)).mp4"
                                imageData.append(jsonData, withName: key, fileName: fileName, mimeType: "video/mp4")
                            }
                        // 图片文件
                        }else if key == #keyPath(WisdomSession.file) || key == #keyPath(WisdomSession.image) {
                            if let jsonData = value as? Data {
                                let formatter = DateFormatter()
                                formatter.dateFormat = #keyPath(WisdomSession.yyyyMMddHHmmss)
                                let fileName = "\(formatter.string(from: Date())).png"
                                imageData.append(jsonData, withName: key, fileName: fileName, mimeType: "image/png")
                            }
                        }
                        else {
                            if let string = value as? String, let data = string.data(using: String.Encoding.utf8) {
                                imageData.append(data, withName: key)
                            }
                        }
                    }
                }
            }, to: url, method: method, headers: headers).response { dataResponse in
                
                Self.setResponseResult(url: url,
                                       openLog: openLog,
                                       dataResponse: nil,
                                       uploadDataResponse: dataResponse,
                                       succedClosure: succedClosure,
                                       failedClosure: failedClosure)
            }
            
            request.setUploadRequest(uploadRequest: uploadRequest)
            return uploadRequest
        }else {
            if openLog {
                print("[WisdomSession]: ❌ Request - URL - Error ❌")
                print("Request   URL = \(request.url)")
                print("Core Base URL = \(Self.baseURL ?? "")")
                print("--------------------------------------------")
            }
            
            failedClosure(-1, "无效链接", "Request URL = \(request.url)" + "/Core Base URL = \(Self.baseURL ?? "")")
            request.setUploadRequest(uploadRequest: nil)
            return nil
        }
    }
}
