//
//  AssetController.swift
//  PhotoWall
//
//  Created by Colin Harris on 8/29/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AWSCore
import PKHUD

protocol AssetControllerDelegate: class {
    func didRemoveAsset(_ asset: WallAsset)
}

class AssetController: UIViewController {

    var assetStore: AssetStore!
    weak var delegate: AssetControllerDelegate?
    
    @IBOutlet var videoView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var uploadButton: UIButton!
    
    var wallAsset: WallAsset?
    var videoPlayer: AVPlayer?
    var videoLayer: AVPlayerLayer?
    
    class func new(assetStore: AssetStore, delegate: AssetControllerDelegate) -> AssetController {
//        let controller = AssetController()
        // TODO: Get rid of the storyboard
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Asset") as! AssetController
        controller.assetStore = assetStore
        controller.delegate = delegate
        return controller
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let asset = wallAsset {
            imageView.image = asset.image()
            videoPlayer = AVPlayer(url: asset.videoUrl)
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer!.currentItem, queue: nil) { _ in
                self.imageView?.isHidden = false
            }
            
            updateUploadButtonState()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = videoPlayer {
            NotificationCenter.default.removeObserver(player.currentItem as Any)
        }
    }
    
    @IBAction
    func deleteClicked() {
        print("deleteClicked")
        if let asset = wallAsset {
            HUD.show(.progress)
            assetStore.deleteAsset(asset: asset).continueWith(executor: AWSExecutor.mainThread()) { task -> Void in
                if let error = task.error {
                    HUD.flash(.error)
                    print("Error: \(error.localizedDescription)")
                } else {
                    HUD.flash(.success)
                    self.assetStore.delete(asset: asset)
                    self.delegate?.didRemoveAsset(asset)
                }
            }
        }
    }
    
    @IBAction
    func uploadClicked() {
        print("uploadClicked")
        if let asset = wallAsset {
            HUD.show(.progress)
            assetStore.uploadAsset(asset: asset).continueWith(executor: AWSExecutor.mainThread()) { task -> Void in
                if let error = task.error {
                    HUD.flash(.error)
                    print("Error: \(error.localizedDescription)")
                } else {
                    HUD.flash(.success)
                    self.updateUploadButtonState()
                }
            }
        }
    }
    
    @IBAction
    func printClicked() {
        print("printClicked")
        if let imageUrl = wallAsset?.imageUrl {
            if UIPrintInteractionController.canPrint(imageUrl) {
                let printInfo = UIPrintInfo(dictionary: nil)
                printInfo.jobName = imageUrl.lastPathComponent
                printInfo.outputType = .photo
                
                let printController = UIPrintInteractionController.shared
                printController.printInfo = printInfo
                printController.showsNumberOfCopies = false
                printController.printingItem = imageUrl
                printController.present(animated: true)
            }
        }
    }
    
    @IBAction
    func playClicked() {
        print("playClicked")
        
        if videoLayer == nil {
            videoLayer = AVPlayerLayer(player: videoPlayer!)
            videoLayer?.videoGravity = .resizeAspectFill
            videoLayer!.frame = videoView.bounds
            videoView.layer.addSublayer(videoLayer!)
        }
        
        self.videoPlayer?.seek(to: .zero)
        videoPlayer?.play()
        imageView?.isHidden = true
    }
    
    private func updateUploadButtonState() {
        guard let asset = wallAsset else {
            return
        }
        assetStore.assetExists(asset: asset).continueWith(executor: AWSExecutor.mainThread()) { task -> Void in
            self.uploadButton.isHidden = task.error == nil
        }
    }
}
