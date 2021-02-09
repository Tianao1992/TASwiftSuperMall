//
//  TANetWorkTool.swift
//  TASwiftSuperMall
//
//  Created by tianao on 2021/1/26.
//

import Foundation

//请求成功闭包
public typealias TASuccessClosure = (_ JSON: Any) -> Void
public typealias TAFailedClosure = (_ error: TANetworkingError) -> Void
public typealias TAProgressHandler = (Progress) -> Void

public enum TAReachabilityStatus {
    /// It is unknown whether the network is reachable.
    case unknown
    /// The network is not reachable.
    case notReachable
    ///  WiFi.
    case  ethernetOrWiFi
    /// The connection type is a cellular connection.
    case cellular
}

public let  Network = TANetWorking.share

public class TANetWorking {
    
   public static var share = TANetWorking()

   var sessionManager: Alamofire.Session!
    
   var reachability: NetworkReachabilityManager?

   private(set) var taskQueue = [TANetworkRequest]()
        //指定初始化器
       private init() {
        let config = URLSessionConfiguration.af.default
        config.timeoutIntervalForRequest = 30  // Timeout interval
        config.timeoutIntervalForResource = 20  // Timeout interval
        sessionManager = Alamofire.Session(configuration: config)
    }
    
    //请求方法
    public func request(url: String,
                         method: HTTPMethod = .get,
                         parameters: [String: Any]?,
                         headers: [String: String]? = nil,
                         encoding: ParameterEncoding = URLEncoding.default) -> TANetworkRequest {
        
        let task = TANetworkRequest()
        var h: HTTPHeaders?
        if let tempHeaders = headers {
            h = HTTPHeaders(tempHeaders)
        }

        task.request = sessionManager.request(url,
                                              method: method,
                                              parameters: parameters,
                                              encoding: encoding,
                                              headers: h).validate().responseJSON { [weak self] response in
            task.handleResponse(response: response)

            if let index = self?.taskQueue.firstIndex(of: task) {
                self?.taskQueue.remove(at: index)
            }
        }
        taskQueue.append(task)
        return task
    }
    
    public func upload(url: String,
                       method: HTTPMethod = .post,
                       parameters: [String: String]?,
                       datas: [TAMultipartData],
                       headers: [String: String]? = nil) -> TANetworkRequest {
        let task = TANetworkRequest()

        var h: HTTPHeaders?
        if let tempHeaders = headers {
            h = HTTPHeaders(tempHeaders)
        }

        task.request = sessionManager.upload(multipartFormData: { (multipartData) in
            // 1.参数 parameters
            if let parameters = parameters {
                for p in parameters {
                    multipartData.append(p.value.data(using: .utf8)!, withName: p.key)
                }
            }
            // 2.数据 datas
            for d in datas {
                multipartData.append(d.data, withName: d.name, fileName: d.fileName, mimeType: d.mimeType)
            }
        }, to: url, method: method, headers: h).uploadProgress(queue: .main, closure: { (progress) in
            task.handleProgress(progress: progress)
        }).validate().responseJSON(completionHandler: { [weak self] response in
            task.handleResponse(response: response)

            if let index = self?.taskQueue.firstIndex(of: task) {
                self?.taskQueue.remove(at: index)
            }
        })
        taskQueue.append(task)
        return task
    }
    
    public func download(url: String, method: HTTPMethod = .post) -> TANetworkRequest {
        // has not been implemented
        fatalError("download(...) has not been implemented")
    }

    // MARK: - Cancellation
    /// Cancel all active `Request`s, optionally calling a completion handler when complete.
    ///
    /// - Note: This is an asynchronous operation and does not block the creation of future `Request`s. Cancelled
    ///         `Request`s may not cancel immediately due internal work, and may not cancel at all if they are close to
    ///         completion when cancelled.
    ///
    /// - Parameters:
    ///   - queue:      `DispatchQueue` on which the completion handler is run. `.main` by default.
    ///   - completion: Closure to be called when all `Request`s have been cancelled.
    public func cancelAllRequests(completingOnQueue queue: DispatchQueue = .main, completion: (() -> Void)? = nil) {
        sessionManager.cancelAllRequests(completingOnQueue: queue, completion: completion)
    }
    

}
extension TANetWorking {

    /// Creates a POST request
    ///
    /// - note: more see: `self.request(...)`
    @discardableResult
    public func POST(url: String, parameters: [String: Any]? = nil, headers: [String: String]? = nil) -> TANetworkRequest {
        request(url: url, method: .post, parameters: parameters, headers: nil)
    }

    /// Creates a POST request for upload data
    ///
    /// - note: more see: `self.request(...)`
    @discardableResult
    public func POST(url: String, parameters: [String: String]? = nil, headers: [String: String]? = nil, datas: [TAMultipartData]? = nil) -> TANetworkRequest {
        guard datas != nil else {
            return request(url: url, method: .post, parameters: parameters, headers: nil)
        }
        return upload(url: url, parameters: parameters, datas: datas!, headers: headers)
    }

    /// Creates a GET request
    ///
    /// - note: more see: `self.request(...)`
    @discardableResult
    public func GET(url: String, parameters: [String: Any]? = nil, headers: [String: String]? = nil) -> TANetworkRequest {
        request(url: url, method: .get, parameters: parameters, headers: nil)
    }
}


public class TANetworkRequest : Equatable {
  
    var request: Alamofire.Request?
    /// API description information. default: nil
    var description: String?
    
    /// request response callback
    private var successHandler: TASuccessClosure?
    /// request failed callback
    private var failedHandler: TAFailedClosure?
    /// `ProgressHandler` provided for upload/download progress callbacks.
    private var progressHandler: TAProgressHandler?
    
    
    func handleResponse(response: AFDataResponse<Any>) {
        switch response.result {
        case .failure(let error):
            if let closure = failedHandler {
                let hwe = TANetworkingError(error.responseCode ?? -1, localizedDescription: error.localizedDescription)
                closure(hwe)
            }
        case .success(let JSON):
            if let closure = successHandler {
                closure(JSON)
            }
        }
        clearReference()
    }
    
    func handleProgress(progress: Foundation.Progress) {
        if let closure = progressHandler {
            closure(progress)
        }
    }

    @discardableResult
    public func success(_ closure: @escaping TASuccessClosure) -> Self {
        successHandler = closure
        return self
    }
    
    @discardableResult
    public func failed(_ closure: @escaping TAFailedClosure) -> Self {
        failedHandler = closure
        return self
    }
    
    @discardableResult
    public func progress(closure: @escaping TAProgressHandler) -> Self {
        progressHandler = closure
        return self
    }
  
    func cancel() {
        request?.cancel()
    }
    
    /// Free memory
    func clearReference() {
        successHandler = nil
        failedHandler = nil
        progressHandler = nil
    }
}

extension TANetworkRequest {
    public static func == (lhs: TANetworkRequest, rhs: TANetworkRequest) -> Bool {
        lhs.request?.id == rhs.request?.id
    }
    
}

