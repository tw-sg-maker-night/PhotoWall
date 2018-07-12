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
    
    let names = ["Col", "Cory", "Angie"]
    var players: [String: AVPlayer] = [:]
    
    @IBAction func addClicked() {
        sceneView.session.pause()
        performSegue(withIdentifier: "ShowCamera", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        for name in names {
            self.players[name] = loadPlayer(name: name)
        }
        
        for player in players.values {
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: nil) { _ in
                player.seek(to: .zero)
                player.play()
            }
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
        configuration.maximumNumberOfTrackedImages = players.count
        
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
