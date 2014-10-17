//
//  ViewController.swift
//  FaceRecogntion
//
//  Created by Judit Greskovits on 17/10/2014.
//  Copyright (c) 2014 Judit Greskovits. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        
        var error: NSError? = nil
        
        var captureDevice = getCamera()
        var deviceInput = AVCaptureDeviceInput(device: captureDevice, error: &error)
        
        if(captureSession.canAddInput(deviceInput)) {
            captureSession.addInput(deviceInput)
        }
        
        if(captureSession.canSetSessionPreset(AVCaptureSessionPresetHigh)) {
            captureSession.sessionPreset = AVCaptureSessionPresetHigh
        }
        
        var videoDataOutput = createVideoDataOutput()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getCamera() -> AVCaptureDevice {
        
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        
        for device in devices {
            
            if (device.position == AVCaptureDevicePosition.Front) {
                return device as AVCaptureDevice
            }
            
        }
        
        return AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    }
    
    func createVideoDataOutput() -> AVCaptureVideoDataOutput {
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        // videoDataOutput.setSampleBufferDelegate(self, queue: serialQueue)
        return videoDataOutput
    }
}

