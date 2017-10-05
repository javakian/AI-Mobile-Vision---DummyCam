//
//  VideoCaptureDelegate.swift
//  DummyCam
//
//  Created by Andrii Tsok on 10/5/17.
//  Copyright © 2017 TSOK.AI. All rights reserved.
//

import Foundation
import AVFoundation

public protocol VideoCaptureDelegate : class {
    func capture(_ capture: VideoCapture, didCaptureVideoFrame: CVPixelBuffer?, timestamp: CMTime)
}
