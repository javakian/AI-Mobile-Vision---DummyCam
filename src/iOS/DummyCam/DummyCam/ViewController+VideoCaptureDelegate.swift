//
//  ViewController+VideoCaptureDelegate.swift
//  DummyCam
//
//  Created by Andrii Tsok on 10/5/17.
//  Copyright © 2017 TSOK.AI. All rights reserved.
//

import Foundation
import AVFoundation

extension ViewController: VideoCaptureDelegate {
    func capture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        if let pixelBuffer = pixelBuffer {
            // For better throughput, perform the prediction on a background queue
            // instead of on the VideoCapture queue. We use the semaphore to block
            // the capture queue and drop frames when Core ML can't keep up.
            semaphore.wait()
            DispatchQueue.global().async {
                //self.process(pixelBuffer: pixelBuffer)
                print("processing a frame")
            }
        }
    }
}
