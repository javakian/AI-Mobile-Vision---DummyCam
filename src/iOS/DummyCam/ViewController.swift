//
//  ViewController.swift
//  DummyCam
//
//  Created by Andrii Tsok on 10/5/17.
//  Copyright © 2017 TSOK.AI. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var videoCapture:VideoCapture!
    
    let semaphore = DispatchSemaphore(value: 2)
    
    @IBOutlet weak var monitor: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setUpCamera()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        print(#function)
    }

    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        // videoCapture.fps = 50
        videoCapture.setUp { success in
            if success {
                if let previewLayer = self.videoCapture.previewLayer {
                    self.monitor.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                
                self.videoCapture.start()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        resizePreviewLayer()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            self.videoCapture.set(orientation: .landscapeLeft)
        } else {
            self.videoCapture.set(orientation: .portrait)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        resizePreviewLayer()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = monitor.bounds
    }
}


