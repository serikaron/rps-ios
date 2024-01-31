//
//  Linkman.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case domainError(Int, String?)
    
    var errorDescription: String? {
        switch self {
        case let .domainError(code, msg):
            return "\(code) - \(msg ?? "")"
        }
    }
}

class Linkman{
    static let shared = Linkman()
    
    var standalone = false
    var showLog = false
}

extension Linkman {
    func log(request: URLRequest){
        let urlString = request.url?.absoluteString ?? ""
        let components = NSURLComponents(string: urlString)

        let method = request.httpMethod != nil ? "\(request.httpMethod!)": ""
        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"
        let host = "\(components?.host ?? "")"

        var requestLog = "\n---------- OUT ---------->\n"
        requestLog += "\(urlString)"
        requestLog += "\n\n"
        requestLog += "\(method) \(path)?\(query) HTTP/1.1\n"
        requestLog += "Host: \(host)\n"
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            requestLog += "\(key): \(value)\n"
        }
        if let body = request.httpBody{
            let bodyString = NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "Can't render body; not utf8 encoded";
            requestLog += "\n\(bodyString)\n"
        }

        requestLog += "\n------------------------->\n";
        print(requestLog)
    }
    
    func log(data: Data?, response: HTTPURLResponse?, error: Error?){

        let urlString = response?.url?.absoluteString
        let components = NSURLComponents(string: urlString ?? "")

        let path = "\(components?.path ?? "")"
        let query = "\(components?.query ?? "")"

        var responseLog = "\n<---------- IN ----------\n"
        if let urlString = urlString {
            responseLog += "\(urlString)"
            responseLog += "\n\n"
        }

        if let statusCode =  response?.statusCode{
            responseLog += "HTTP \(statusCode) \(path)?\(query)\n"
        }
        if let host = components?.host{
            responseLog += "Host: \(host)\n"
        }
        for (key,value) in response?.allHeaderFields ?? [:] {
            responseLog += "\(key): \(value)\n"
        }
        if let body = data{
            let bodyString = NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "Can't render body; not utf8 encoded";
            responseLog += "\n\(bodyString)\n"
        }
        if let error = error{
            responseLog += "\nError: \(error.localizedDescription)\n"
        }

        responseLog += "<------------------------\n";
        print(responseLog)
    }
    
    @MainActor
    func make(request: Request) async throws {
        do {
//            print("make \(standalone ? "standalone" : "network") request")
            if (standalone || request.forceStandalone) {
                request._response = request.standaloneResponse
                try await Task.sleep(nanoseconds: UInt64.random(in: 10_000_000...200_000_000))
                return
            }
            
            let url = try request.url
            
            var req = URLRequest(url: url)
            req.httpMethod = request.method.rawValue
            if let body = request.bodyDict {
                req.httpBody = try body.encoded()
            }
            if let body = request.bodyArray {
                req.httpBody = try body.encoded()
            }
            if let token = Box.shared.tokenSubject.value {
                req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            if request._uploadData == nil {
                req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            req.setValue("ios", forHTTPHeaderField: "ss")
            if let extraHeader = request.headers {
                extraHeader.forEach { header in
                    req.addValue(header.value, forHTTPHeaderField: header.key)
                }
            }
            
            if (showLog) {
                log(request: req)
            }
            
            let (data, response) =
            request._uploadData == nil ?
            try await URLSession.shared.data(for: req) :
            try await URLSession.shared.upload(for: req, from: request._uploadData!)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw "not an http response"
            }
            
            if (showLog) {
                log(data: data, response: httpResponse, error: nil)
            }
            
            guard 200 <= httpResponse.statusCode && httpResponse.statusCode < 300 else {
                throw "request failed, status: \(httpResponse.statusCode)"
            }
            
            if request.checkResponse {
                struct Rsp: Decodable {
                    let code: Int
                    let msg: String?
                }
                let rsp = try data.decoded() as Rsp
                
                guard rsp.code == 200 else {
                    if (rsp.code == 401) {
                        Box.setToken(nil)
                    }
                    throw NetworkError.domainError(rsp.code, rsp.msg)
                }
            }
            
            
            request._response = data
        } catch {
            if request.sendError {
                Box.sendError(error)
            }
            if request.throwError {
                throw error
            }
        }
    }
}

enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

// MARK: - Request

class Request: Withable {
    var rawURL: String = ""
    var path: String = ""
    var method: HTTPMethod = .GET
    var query: [String: String?]?
    var bodyDict: JSONDict?
    var bodyArray: [Any]?
    var headers: [String: String]?
    fileprivate var _uploadData: Data?

    var queryItems: [URLQueryItem] {
        guard let query = query else { return [] }
        
        return query.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
    }
    
    var standaloneResponse: Data?
    var _response: Data?
    var sendError = true
    var throwError = true
    var forceStandalone: Bool = false
    var checkResponse: Bool = true
    
    @discardableResult
    func make() async throws -> Self {
        try await Linkman.shared.make(request: self)
        return self
    }
    
    func response<T: Codable>(default: T? = nil) throws -> T {
        guard let r = _response else {
            throw "response not exists"
        }
        
        let rsp = try r.decoded() as Response<T>
        
        switch (rsp.data, `default`) {
        case (.some(let rspData), _):
            return rspData
        case (.none, .some(let def)):
            return def
        case (.none, .none):
            throw "response data not exists"
        }
    }
    
    func uploadInfo(filename: String, binary: Data, boundary: String = UUID().uuidString) -> Self {
        if headers == nil {
            headers = [:]
        }
        headers!["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        
        var formData = Data()
        
        // Add the image data to the raw http request data
        formData.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        let paramName = "file"
        formData.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        formData.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        formData.append(binary)
        
        formData.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        _uploadData = formData
        
        return self
    }
    
    fileprivate var url: URL {
        get throws {
            if rawURL.isEmpty {
                var urlComponents = URLComponents.rps()
                urlComponents.path = urlComponents.path + path
                
                if let query = query {
                    urlComponents.queryItems = query.map { (key, value) in
                        URLQueryItem(name: key, value: value)
                    }
                }
                
                guard let url = urlComponents.url else {
                    throw "invalid url: \(urlComponents.string ?? path)"
                }
                
                return url
            } else {
                guard let url = URL(string: rawURL) else {
                    throw "invalid url \(rawURL)"
                }
                
                return url
            }
        }
    }
}

// MARK: - Response
struct Response<T: Codable>: Codable {
    let code: Int
    let data: T?
}

func standaloneResponse<T: Codable>(_ data: T) -> Data {
    try! Response<T>(code: 0, data: data).encoded()
}

extension URLComponents {
    static func rps() -> URLComponents {
        prod
    }
    
    private static var dev: URLComponents {
        var out = URLComponents()
        out.scheme = "http"
        out.host = "121.199.160.77:9205"
        out.port = 8080
        return out
    }
    
    private static var prod: URLComponents {
        var out = URLComponents()
        out.scheme = "https"
        out.host = "rps2.zfp.cn"
        out.path = "/prod-api"
        return out
    }
}

extension Encodable {
    func encoded() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}

extension Data {
    func decoded<T: Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
}

typealias JSONDict = [String: Any]
extension JSONDict {
    func encoded() throws -> Data {
        try JSONSerialization.data(withJSONObject: self)
    }
}

extension [Any] {
    func encoded() throws -> Data {
        try JSONSerialization.data(withJSONObject: self)
    }
}
