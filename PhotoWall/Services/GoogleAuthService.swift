//
//  GoogleAuthService.swift
//
//  Created by Colin Harris on 8/6/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import GoogleSignIn

public protocol GoogleAuthDelegate: class {
    func googleAuth(_ googleAuth: GoogleAuthService!, didSignInFor user: AuthenticatedUser!, withError error: Error!)
    func googleAuth(_ googleAuth: GoogleAuthService!, didDisconnectWith user: AuthenticatedUser!, withError error: Error!)
}

public class GoogleAuthService: NSObject {
    
    let webClientId: String
    let webClientSecret: String
    weak var delegate: GoogleAuthDelegate?
    
    public init(clientId: String, scopes: [String], webClientId: String, webClientSecret: String, delegate: GoogleAuthDelegate) {
        self.webClientId = webClientId
        self.webClientSecret = webClientSecret
        super.init()
        self.delegate = delegate
        
        GIDSignIn.sharedInstance().clientID = clientId
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    public class func googleSignIn() -> GIDSignIn {
        return GIDSignIn.sharedInstance()
    }
    
    public func hasAuthInKeychain() -> Bool {
        return GIDSignIn.sharedInstance().hasAuthInKeychain()
    }
    
    public func signInSilently() {
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    public func signIn(delegate: GIDSignInUIDelegate?) {
        GIDSignIn.sharedInstance().uiDelegate = delegate
        GIDSignIn.sharedInstance().signIn()
    }
    
    public func disconnect() {
        GIDSignIn.sharedInstance().disconnect()
    }
    
    var sharedUserDefaults: UserDefaults {
        return UserDefaults(suiteName: "group.com.thoughtworks")!
    }
    
    public func storeAuthenticatedUser(_ authenticatedUser: AuthenticatedUser) {
        let encoder = JSONEncoder()
        let authUserData = try? encoder.encode(authenticatedUser)
        sharedUserDefaults.set(authUserData, forKey: Constants.UserDefaults.AuthenticateUserKey)
    }
    
    public func clearAuthenticatedUser() {
        sharedUserDefaults.removeObject(forKey: Constants.UserDefaults.AuthenticateUserKey)
    }
}

extension GoogleAuthService: GIDSignInDelegate {
    
    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil, let user = self.authenticatedUser {
            storeAuthenticatedUser(user)
        }
        
        delegate?.googleAuth(self, didSignInFor: self.authenticatedUser, withError: error)
    }
    
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        clearAuthenticatedUser()
        delegate?.googleAuth(self, didDisconnectWith: self.authenticatedUser, withError: error)
    }
}

extension GoogleAuthService: AuthProvider {
    
    public var authenticatedUser: AuthenticatedUser? {
        guard let googleUser = GIDSignIn.sharedInstance()?.currentUser else {
            return nil
        }
        return AuthenticatedUser(
            name: googleUser.profile.name,
            email: googleUser.profile.email,
            accessToken: googleUser.authentication.accessToken,
            refreshToken: googleUser.authentication.refreshToken
        )
    }
    
    public func authHeaders() -> [String: String] {
        guard let user = authenticatedUser else {
            return [:]
        }
        return [
            "user_email": user.email!,
            "google_access_token": user.accessToken!,
            "google_refresh_token": user.refreshToken!,
            "google_client_id": webClientId,
            "google_client_secret": webClientSecret,
            "user_name": user.name!
        ]
    }
}
