//
//  LoginViewController.swift
//
//  Created by Colin Harris on 5/6/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import UIKit
import PKHUD
import GoogleSignIn

protocol LoginDelegate: class {
    func signInClicked()
}

class LoginController: UIViewController, GIDSignInUIDelegate {
    
    var googleAuthService: GoogleAuthService!
    weak var delegate: LoginDelegate?
    
    @IBOutlet var loginButton: UIButton!
    
    class func create(googleAuthService: GoogleAuthService, delegate: LoginDelegate? = nil) -> LoginController {
        let controller = LoginController(nibName: "Login", bundle: nil)
        controller.googleAuthService = googleAuthService
        controller.delegate = delegate
        return controller
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        autoSignInIfAvailable()
    }
    
    func autoSignInIfAvailable() {
        if googleAuthService!.hasAuthInKeychain() {
            hideLoginButton()
            HUD.show(.labeledProgress(title: nil, subtitle: "Signing in"))
            googleAuthService!.signInSilently()
        }
    }
    
    @IBAction
    func signInClicked() {
        hideLoginButton()
        delegate?.signInClicked()
    }
    
    func hideLoginButton() {
        loginButton?.isHidden = true
    }
    
    func showLoginButton() {
        loginButton?.isHidden = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
