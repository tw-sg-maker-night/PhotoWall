//
//  BaseService.swift
//
//  Created by Colin Harris on 5/6/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import PromiseKit

enum DateError: String, Error {
    case invalidDate
}

public class BaseService {
    
    let baseUrl: URL
    let authProvider: AuthProvider
    
    public init(baseUrl: URL, authProvider: AuthProvider) {
        self.baseUrl = baseUrl
        self.authProvider = authProvider
    }
    
    func url(_ path: String) -> URL {
        return baseUrl.appendingPathComponent(path)
    }
    
    func get<T: Codable>(path: String) -> Promise<T> {
        print("GET:", url(path))
        return Alamofire.request(
            url(path),
            headers: headers()
        ).responseData().map { (body: (data: Data, response: PMKAlamofireDataResponse)) -> T in
            print("Response:", String(data: body.data, encoding: .utf8)!)
            return try BaseService.decoder().decode(T.self, from: body.data)
        }
    }
    
    func post<T: Codable>(path: String, params: [String: Any]? = [:]) -> Promise<T> {
        print("POST:", url(path))
        return Alamofire.request(
            url(path),
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers()
        ).responseData().map { (body: (data: Data, response: PMKAlamofireDataResponse)) -> T in
            print("Response:", String(data: body.data, encoding: .utf8)!)
            return try BaseService.decoder().decode(T.self, from: body.data)
        }
    }
    
    // Custom decoder in order to handle iso8601 dates that contain milliseconds
    public class func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()        
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateStr) {
                return date
            }
            throw DateError.invalidDate
        })        
        return decoder
    }
    
    // Customer encoder to output dates in iso8601 standard
    public class func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
    
    func headers(custom: [String: String] = [:]) -> [String: String] {
        var headers = ["Accept": "application/json", "Content-Type": "application/json"]
        headers = headers.merging(authProvider.authHeaders()) { $1 }
        return headers.merging(custom) { $1 }
    }
}
