//
//  AuthProvider.swift
//
//  Created by Colin Harris on 8/6/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation

public struct AuthenticatedUser: Codable {
    public var name: String?
    public var email: String?
    public var accessToken: String?
    public var refreshToken: String?
    
    public init(name: String, email: String, accessToken: String, refreshToken: String) {
        self.name = name
        self.email = email
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

public protocol AuthProvider {
    var authenticatedUser: AuthenticatedUser? { get }
    
    func authHeaders() -> [String: String]
}
