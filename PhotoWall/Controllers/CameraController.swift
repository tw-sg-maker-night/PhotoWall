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
            WallAssetStore().storeVideo(fileURL, for: "Cory")
            backClicked()
        } else {
            print("fileOutput - error: \(error!.localizedDescription)")
        }
    }
    
}