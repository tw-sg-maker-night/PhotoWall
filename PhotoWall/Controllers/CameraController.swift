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

protocol CameraControllerDelegate: class {
    
}

class CameraController: UIViewController {
    
    @IBOutlet var previewView: UIView!
    
    var session: AVCaptureSession!
    var videoOutput: AVCaptureMovieFileOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    var assetIdentifier: String!
    var assetStore: AssetStore!
    weak var delegate: CameraControllerDelegate?
    
    class func new(assetStore: AssetStore, delegate: CameraControllerDelegate) -> CameraController {
//        let controller = CameraController()
        // TODO: Get rid of the storyboard
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Camera") as! CameraController
        controller.assetStore = assetStore
        controller.delegate = delegate
        controller.assetIdentifier = UUID().uuidString
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            // Setup video input
            let input = try AVCaptureDeviceInput(device: AVCaptureDevice.default(for: AVMediaType.video)!)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            // Setup preview
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
            previewView.layer.addSublayer(videoPreviewLayer!)
            
            // Setup output
            videoOutput = AVCaptureMovieFileOutput()
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                if let connection = videoOutput.connection(with: .video) {
//                    videoOutput.setRecordsVideoOrientationAndMirroringChangesAsMetadataTrack(true, for: connection)
//                    videoOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: connection)
                    connection.videoOrientation = .landscapeRight
                    connection.preferredVideoStabilizationMode = .standard
                }
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let bounds: CGRect = previewView.layer.bounds
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.bounds = bounds
        videoPreviewLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        session.startRunning()
    }
    
    @IBAction func backClicked() {
        self.dismiss(animated: true)
    }
    
    @IBAction func startStopRecording() {
        if videoOutput.isRecording {
            print("stopRecording")
            videoOutput.stopRecording()
        } else {
            print("startRecording")
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let fileUrl = paths[0].appendingPathComponent("output.mov")
            try? FileManager.default.removeItem(at: fileUrl)
            videoOutput.startRecording(to: fileUrl, recordingDelegate: self)
        }
    }
    
    @IBAction func takePhoto() {
        print("takePhoto")
    }
    
}

extension CameraController: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("fileOutput didStartRecordingTo: \(fileURL.absoluteString)")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo fileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            assetStore.createAssetDir(name: assetIdentifier)
            let image = imageFromVideo(url: fileURL)
            assetStore.storeImage(image, for: assetIdentifier)
            assetStore.storeVideo(fileURL, for: assetIdentifier)
            backClicked()
        } else {
            print("fileOutput - error: \(error!.localizedDescription)")
        }
    }
    
    func imageFromVideo(url: URL) -> UIImage {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        let cgImage = try! imageGenerator.copyCGImage(at: CMTime(seconds: 0.0, preferredTimescale: 1), actualTime: nil)
        var image = UIImage(cgImage: cgImage)
        let imageView = UIImageView(image: image)
        imageView.frame.size.width = 1500
        imageView.frame.size.height = 1000
        imageView.contentMode = .scaleAspectFill
        imageView.contentScaleFactor = 1.5
        imageView.clipsToBounds = true
        
        UIGraphicsBeginImageContext(imageView.frame.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        return image
    }
}
