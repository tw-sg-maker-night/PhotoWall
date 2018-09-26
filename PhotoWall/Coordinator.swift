//
//  Coordinator.swift
//
//  Created by Colin Harris on 5/6/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import UIKit
import PKHUD
import PromiseKit

class Coordinator: NSObject {
    
    let navController: UINavigationController
    let appConfig: AppConfig
    
    var googleAuthService: GoogleAuthService!
    var locationService: LocationService!
        
    var assetStore: AssetStore?
    
    init(navController: UINavigationController) {
        self.navController = navController
        self.appConfig = AppConfigLoader().load()
        super.init()
        self.googleAuthService = GoogleAuthService(
            clientId: appConfig.googleClientId,
            scopes: appConfig.googleScopes,
            webClientId: appConfig.googleWebClientId,
            webClientSecret: appConfig.googleWebClientSecret,
            delegate: self
        )
        self.locationService = LocationClient(baseUrl: appConfig.baseUrl, authProvider: googleAuthService)
    }
    
    func start() {
        displayLogin()
    }
    
    func displayLogin() {
        let controller = LoginController.create(googleAuthService: googleAuthService, delegate: self)
        self.navController.setViewControllers([controller], animated: false)
    }
    
    func displayLocationList() {
        let controller = LocationListController.new(locationService: locationService, delegate: self)
        self.navController.present(controller, animated: true)
    }
    
    func displayLoadingLocation(location: Location) {
        let controller = LoadingController.new(assetStore: AssetStore(groupId: location.office), delegate: self)
        self.navController.setViewControllers([controller], animated: true)
    }
    
    func displayPhotoWall() {
        let controller = PhotoWallController.new(assetStore: assetStore!, delegate: self)
        self.navController.setViewControllers([controller], animated: true)
    }
    
    func displayCamera() {
        let controller = CameraController.new(assetStore: assetStore!, delegate: self)
        self.navController.present(controller, animated: true)
    }
    
    func displayLibrary() {
        let controller = LibraryController.new(assetStore: assetStore!, delegate: self)
        self.navController.pushViewController(controller, animated: true)
    }
    
    func displayAssetDetails() {
        let controller = AssetController.new(assetStore: assetStore!, delegate: self)
        self.navController.pushViewController(controller, animated: true)
    }
    
    func loginController() -> LoginController? {
        return self.navController.controllerOfType()
    }
    
    func locationListController() -> LocationListController? {
        return self.navController.controllerOfType()
    }
    
    func photoWallController() -> PhotoWallController? {
        return self.navController.controllerOfType()
    }
    
    func cameraController() -> CameraController? {
        return self.navController.controllerOfType()
    }
    
    func libraryController() -> LibraryController? {
        return self.navController.controllerOfType()
    }
    
    func displaySettings() {
        let controller = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Switch Location", style: .default) { action in
            self.displayLocationList()
        })
        controller.addAction(UIAlertAction(title: "Sign out", style: .destructive) { action in
            self.googleAuthService.disconnect()
        })
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in
            controller.dismiss(animated: true)
        })
        navController.present(controller, animated: true)
    }
    
    func displayUsersLocation() {
        HUD.show(.labeledProgress(title: nil, subtitle: "Finding location"))
        firstly {
            locationService!.getCurrentLocation()
        }.ensure {
            HUD.hide()
        }.done { (location: Location) in
            print("Found location:", location.country, location.office)
            self.displayLoadingLocation(location: location)
        }.catch { error in
            print("Error:", error)
            print("Unable to find location. Displaying location list.")
            self.displayLocationList()
        }
    }
}

extension Coordinator: GoogleAuthDelegate {
    
    func googleAuth(_ googleAuth: GoogleAuthService!, didSignInFor user: AuthenticatedUser!, withError error: Error!) {
        if let error = error {
            print("Sign in error: \(error.localizedDescription)")
            HUD.flash(.labeledError(title: "Error", subtitle: nil), delay: 1.5)
            if let controller = loginController() {
                controller.showLoginButton()
            }
        } else {
            print("Signed in as: \(user.email!)")
            displayUsersLocation()
        }
    }
    
    func googleAuth(_ googleAuth: GoogleAuthService!, didDisconnectWith user: AuthenticatedUser!, withError error: Error!) {
        print("Coordinator.didDisconnectWith:", user, error)
        if let error = error {
            print("Error: \(error.localizedDescription)")
        } else {
            if loginController() == nil {
                displayLogin()
            }
        }
    }
}

extension Coordinator: LoginDelegate {
    
    func signInClicked() {
        self.googleAuthService.signIn(delegate: loginController())
    }
}

extension Coordinator: LocationListDelegate {
    
    func locationSelected(location: Location) {
        print("Location selected:", location.country, location.office)
        self.navController.dismiss(animated: true) {
            self.displayLoadingLocation(location: location)
        }
    }
}

extension Coordinator: LoadingDelegate {
    
    func didFinishLoading(assetStore: AssetStore) {
        self.assetStore = assetStore
        displayPhotoWall()
    }
}

extension Coordinator: PhotoWallDelegate {
    
}

extension Coordinator: CameraControllerDelegate {
    
}

extension Coordinator: LibraryControllerDelegate {
    
}

extension Coordinator: AssetControllerDelegate {
    func didRemoveAsset(_ asset: WallAsset) {
        // TODO: do something...
    }
}
