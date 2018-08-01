//
//  CameraController.swift
//  PhotoWall
//
//  Created by Colin Harris on 8/1/18.
//  Copyright © 2018 Colin Harris. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CameraController: UIViewController {
    
    @IBOutlet var previewView: UIView!
    
    var session: AVCaptureSession!
//    var videoOutput: AVCaptureVideoDataOutput!
    var videoOutput: AVCaptureMovieFileOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            let input = try AVCaptureDeviceInput(device: AVCaptureDevice.default(for: AVMediaType.video)!)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
            previewView.layer.addSublayer(videoPreviewLayer!)
            
//            videoOutput = AVCaptureVideoDataOutput()
//            videoOutput.videoSettings = videoOutput.recommendedVideoSettings(forVideoCodecType: .h264, assetWriterOutputFileType: .m4v) as! [String: Any]?
//            videoOutput.alwaysDiscardsLateVideoFrames = true
//            if session.canAddOutput(videoOutput) {
//                session.addOutput(videoOutput)
//            }
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        videoPreviewLayer!.frame = previewView.bounds
        session.startRunning()
    }
    
    @IBAction func backClicked() {
        self.dismiss(animated: true)
    }
    
    @IBAction func startRecording() {
        print("startRecording")    
    }
    
    @IBAction func stopRecording() {
        print("stopRecording")
        backClicked()
    }
    
    @IBAction func takePhoto() {
        print("takePhoto")
    }
}
