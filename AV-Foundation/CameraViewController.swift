//
//  CameraViewController.swift
//  AV-Foundation
//
//  Created by Henry Chukwu on 3/2/20.
//  Copyright © 2020 Henry Chukwu. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var recordButton: UIButton!
    
    var takenVideo: UIImage?
    var recording = false
    
    let captureSession = AVCaptureSession()
    
    // which camera input do we want to use
    var backFacingCamera: AVCaptureDevice!
    var frontFacingCamera: AVCaptureDevice!

    var previewLayer: CALayer!
    var captureDevice: AVCaptureDevice!
    
    var recordVideo = false

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCamera()
        
        let toggleCameraGestureRecognizer = UITapGestureRecognizer()
        toggleCameraGestureRecognizer.numberOfTapsRequired = 2
        toggleCameraGestureRecognizer.addTarget(self, action: #selector(toggleCamera))
        view.addGestureRecognizer(toggleCameraGestureRecognizer)
        
        view.bringSubviewToFront(recordButton)

        if let availableVideo = takenVideo {
            imageView.image = availableVideo
        }
    }
    
    @IBAction func recordButtonPressed(_ sender: Any) {
        recording = !recording
        if !recording {
            // start recording
            recordButton.layer.borderColor = UIColor.red.cgColor
            recordButton.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            
            let outputUrl = self.applicationDocumentsDirectory()?.appendingPathComponent("video").appendingPathExtension("mov")
            let recordingDelegate: AVCaptureFileOutputRecordingDelegate? = self
            let videoFileOutput = AVCaptureMovieFileOutput()
            self.captureSession.addOutput(videoFileOutput)
            videoFileOutput.startRecording(to: outputUrl!, recordingDelegate: recordingDelegate!)
        } else {
            // stop recording
            recordButton.layer.borderColor = UIColor.clear.cgColor
            recordButton.backgroundColor = .clear
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo

        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        
        let frontDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices

        captureDevice = availableDevices.first
        backFacingCamera = availableDevices.first
        frontFacingCamera = frontDevice.first
        beginSession()
    }
    
    func beginSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = previewLayer
        self.view.layer.addSublayer(self.previewLayer)
        previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer.frame = self.view.layer.frame
        captureSession.startRunning()
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String):NSNumber(value: kCVPixelFormatType_32BGRA)]
        
        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
        
        captureSession.commitConfiguration()
        
        let queue = DispatchQueue(label: "com.henry.captureQueue")
        dataOutput.setSampleBufferDelegate(self, queue: queue)
        view.bringSubviewToFront(recordButton)
    }
    
    func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }
    
    func stopCaptureSession() {
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
    }
    
    @objc private func toggleCamera() {
        // start the configuration change
        stopCaptureSession()
        
        let newDevice = (captureDevice?.position == .back) ? frontFacingCamera : backFacingCamera
        captureDevice = newDevice
        beginSession()
    }
    
    func applicationDocumentsDirectory() -> URL? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        return
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        return
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if recordVideo {
            recordVideo = false
            // getImageFromSampleBuffer
//            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
//            }
        }
    }
}
