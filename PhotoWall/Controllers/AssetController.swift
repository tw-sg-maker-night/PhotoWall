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

class AssetController: UIViewController {

    @IBOutlet var videoView: UIView!
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var uploadButton: UIButton!
    
//    var assetStore: WallAssetStore
//    var remoteAssetStore: RemoteStore
    
    var wallAsset: WallAsset?
    var videoPlayer: AVPlayer?
    var videoLayer: AVPlayerLayer?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let asset = wallAsset {
            imageView.image = asset.image()
            videoPlayer = AVPlayer(url: asset.videoUrl)
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: videoPlayer!.currentItem, queue: nil) { _ in
                self.imageView?.isHidden = false
            }
            uploadButton.isHidden = true
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
            WallAssetStore().delete(asset: asset)
        }
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction
    func uploadClicked() {
        print("uploadClicked")
        if let asset = wallAsset {
            RemoteStore().uploadAsset(asset: asset).continueOnSuccessWith { task -> AWSTask<AnyObject>? in
                print("Upload Complete!")
                DispatchQueue.main.async {
                    let controller = UIAlertController(title: "Upload Complete!", message: nil, preferredStyle: .alert)
                    controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                }
                return nil
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
}
