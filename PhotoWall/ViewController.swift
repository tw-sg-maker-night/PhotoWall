//
//  ViewController.swift
//  PhotoWall
//
//  Created by Colin Harris on 27/6/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var colPlayer: AVPlayer!
    var coryPlayer: AVPlayer!
    var angiePlayer: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
//        sceneView.showsStatistics = true
        
        self.colPlayer = loadPlayer(name: "Col")
        self.coryPlayer = loadPlayer(name: "Cory")
        self.angiePlayer = loadPlayer(name: "Angie")
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: colPlayer.currentItem, queue: nil) { _ in
            self.colPlayer.seek(to: .zero)
            self.colPlayer.play()
        }
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: coryPlayer.currentItem, queue: nil) { _ in
            self.coryPlayer.seek(to: .zero)
            self.coryPlayer.play()
        }
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: angiePlayer.currentItem, queue: nil) { _ in
            self.angiePlayer.seek(to: .zero)
            self.angiePlayer.play()
        }
    }
    
    func loadPlayer(name: String) -> AVPlayer? {
        if let url = Bundle.main.url(forResource: name, withExtension: "mp4", subdirectory: "art.scnassets") {
            return AVPlayer(url: url)
        }
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        let configuration = ARImageTrackingConfiguration()
        guard let referencesImages = ARReferenceImage.referenceImages(inGroupNamed: "Photos", bundle: nil) else {
            print("Could not load photos!")
            return
        }
        configuration.trackingImages = referencesImages
        configuration.maximumNumberOfTrackedImages = 2
        
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        if let imageAnchor = anchor as? ARImageAnchor, let imageAnchorName = imageAnchor.referenceImage.name {
            if let player = player(for: imageAnchorName) {
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
    
    func player(for name: String) -> AVPlayer? {
        switch name {
        case "Col":
            return colPlayer
        case "Cory":
            return coryPlayer
        case "Angie":
            return angiePlayer
        default:
            return nil
        }
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
