//
//  PhotoWallController.swift
//  PhotoWall
//
//  Created by Colin Harris on 9/8/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

protocol PhotoWallDelegate: class {
    func displayCamera()
    func displayLibrary()
    func displayLocationList()
}

class PhotoWallController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var locationButton: UIButton!
    @IBOutlet var locationButtonWidth: NSLayoutConstraint!
    
    var wallAssets: [WallAsset] = []
    var players: [String: AVPlayer] = [:]
    
    var assetStore: AssetStore!
    weak var delegate: PhotoWallDelegate?
    
    class func new(assetStore: AssetStore, delegate: PhotoWallDelegate) -> PhotoWallController {
//        let controller = PhotoWallController()
        // TODO: Get rid of the storyboard
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoWall") as! PhotoWallController
        controller.assetStore = assetStore
        controller.delegate = delegate
        return controller
    }
    
    @IBAction func libraryClicked() {
        delegate?.displayLibrary()
    }
    
    @IBAction func addClicked() {
        delegate?.displayCamera()
    }
    
    @IBAction func locationClicked() {
        delegate?.displayLocationList()        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cameraController = segue.destination as? CameraController {
            cameraController.assetIdentifier = UUID().uuidString
        }
        if let _ = segue.destination as? LibraryController {
            // ...
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
    }
    
    func loadWallAssets() {
        self.wallAssets = assetStore.loadAssets()
        for wallAsset in wallAssets {
            print("WallAsset: \(wallAsset)")
        }
    }
    
    func loadPlayer(for asset: WallAsset) -> AVPlayer? {
        return AVPlayer(url: asset.videoUrl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        locationButton.setTitle(assetStore.groupId, for: .normal)
        locationButton.imageView?.contentMode = .scaleAspectFit
        if let title = locationButton.title(for: .normal) {
            let titleSize = title.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)])
            locationButtonWidth.constant = titleSize.width + 80
        }
        
        loadWallAssets()
        for asset in wallAssets {
            self.players[asset.identifier] = loadPlayer(for: asset)
        }
        
        for player in players.values {
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { _ in
                player.seek(to: .zero)
                player.play()
            }
        }
        
        let configuration = ARImageTrackingConfiguration()
        
        guard let referenceImages = loadReferenceImages() else {
            print("Could not load photos!")
            return
        }
        configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = players.count
        
        sceneView.session.run(configuration)
    }
    
    func loadReferenceImages() -> Set<ARReferenceImage>? {
        let images: [ARReferenceImage] = wallAssets.map { asset in
            return asset.referenceImage()
        }.compactMap { $0 }
        return Set(images)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor, let imageAnchorName = imageAnchor.referenceImage.name {
            if let player = players[imageAnchorName] {
                let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width,
                                     height: imageAnchor.referenceImage.physicalSize.height)
                
                plane.firstMaterial?.diffuse.contents = player
                player.play()
                
                let planeNode = SCNNode(geometry: plane)
                planeNode.eulerAngles.x = -.pi / 2
                
                node.addChildNode(planeNode)
            }
        }
        
        return node
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
}
