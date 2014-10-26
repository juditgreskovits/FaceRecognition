//
//  ViewController.swift
//  FaceRecogntion
//
//  Created by Judit Greskovits on 17/10/2014.
//  Copyright (c) 2014 Judit Greskovits. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    let _serialQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    var _captureSession: AVCaptureSession?
    var _facesMetadataObjects: NSArray?

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
        
        // Video data output
        
        var videoDataOutput = createVideoDataOutput()
        if(captureSession.canAddOutput(videoDataOutput)) {
            captureSession.addOutput(videoDataOutput)
            let connection: AVCaptureConnection = videoDataOutput.connections[0] as AVCaptureConnection
            connection.videoOrientation = AVCaptureVideoOrientation.Portrait
        }
        
        // Metadata output
        
        var metadataOutput = createMetadataOutput()
        if(captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            // metadataOutput.metadataObjectTypes =
        }
        
        captureSession.commitConfiguration()
        dispatch_async(_serialQueue, { () -> Void in
            captureSession.startRunning()
        })
        
        _captureSession = captureSession;
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func captureOutput(captureOutput: AVCaptureOutput, metadataObjects: NSArray, coonection:AVCaptureConnection) {
        _facesMetadataObjects = metadataObjects
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        let pixelBuffer: CVPixelBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        if(pixelBuffer != nil) {
            let attachments: CFDictionaryRef = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate)
            let ciImage = CIImage(CVPixelBuffer: pixelBuffer, options: attachments)
            
            if(attachments) {
                CFRelease(attachments)
            }
            
            let extent: CGRect = ciImage.extent()
            
        }
    }
    
    // helpers

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
        videoDataOutput.setSampleBufferDelegate(self, queue: _serialQueue)
        return videoDataOutput
    }
    
    func createMetadataOutput() -> AVCaptureMetadataOutput {
        
        let metadataOutput = AVCaptureMetadataOutput()
        metadataOutput.setMetadataObjectsDelegate(self, queue: _serialQueue)
        return metadataOutput
    }
    
    func metadataOutput(metadataOutput:AVCaptureMetadataOutput, allowedObjectTypes:NSArray) -> NSArray {
       
        var available = NSSet(array: metadataOutput.availableMetadataObjectTypes);
        available.intersectsSet(NSSet(array:allowedObjectTypes))
        return available.allObjects
    }
    
    func faceMetaDataObjectTypes() -> NSArray {
        
        return [AVMetadataObjectTypeFace]
    }
}

