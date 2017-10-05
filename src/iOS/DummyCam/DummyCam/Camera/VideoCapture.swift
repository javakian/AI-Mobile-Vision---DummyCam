//
//  VideoCapture.swift
//  DummyCam
//
//  Created by Andrii Tsok on 10/5/17.
//  Copyright © 2017 TSOK.AI. All rights reserved.
//

import Foundation
import AVFoundation
import CoreVideo

public class VideoCapture : NSObject {
    public var previewLayer : AVCaptureVideoPreviewLayer?
    public weak var delegate: VideoCaptureDelegate?
    
    public var fps = 15
    let captureSession = AVCaptureSession()
    let videoOutput = AVCaptureVideoDataOutput()
    
    let queue = DispatchQueue(label: "ai.tsok.DummyCam.camera-queue")
    
    var lastTimestamp = CMTime()
    
    public func setUp(sessionPreset: AVCaptureSession.Preset = .medium, orientation: AVCaptureVideoOrientation = .portrait, completion: @escaping (Bool) -> Void) {
        queue.async {
            let success = self.setUpCamera(sessionPreset: sessionPreset, orientation: orientation)
            DispatchQueue.main.async{
                completion(success)
            }
        }
    }
    
    func setUpCamera(sessionPreset: AVCaptureSession.Preset, orientation: AVCaptureVideoOrientation) -> Bool {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = sessionPreset
        
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Error: no video devices available")
            return false
        }
        
        guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Error: could not create AVCaptureDeviceInput")
            return false
        }
        
        if captureSession.canAddInput(videoInput){
            captureSession.addInput(videoInput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        previewLayer.connection?.videoOrientation = orientation
        
        self.previewLayer = previewLayer
        
        let setting: [String : Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)
        ]
        
        videoOutput.videoSettings = setting
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: queue)
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // We want the buffers to be in portrait orientation otherwise they are
        // rotated by 90 degrees. Need to set this _after_ addOutput()!
        videoOutput.connection(with: AVMediaType.video)?.videoOrientation = orientation
        
        captureSession.commitConfiguration()
        
        return true
    }
    
    public func start() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    public func stop() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}

extension VideoCapture : AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Because lowering the capture device's FPS looks ugly in the preview,
        // we capture at full speed but only call the delegate at its desired
        // framerate.
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let deltaTime = timestamp - lastTimestamp
        if deltaTime >= CMTimeMake(1, Int32(fps)) {
            lastTimestamp = timestamp
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            delegate?.capture(self, didCaptureVideoFrame: imageBuffer, timestamp: timestamp)
        }
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("dropped frame")
    }
}
