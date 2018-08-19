//
//  CameraViewController.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/07/31.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    //MARK: - Outlet
    @IBOutlet weak var previewPhotoView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    
    //MARK: var / let
    var captureSession = AVCaptureSession()
    var photoOutput = AVCapturePhotoOutput()
    
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupCaptureSession()
    }
    
    //MARK: - Statusbar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Kamera erstellen
    func setupCaptureSession() {
        // 1. CaptureSession
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        // 2. Input
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        do {
            guard let device = captureDevice else { return }
            let input = try AVCaptureDeviceInput(device: device)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
        } catch let error {
            ProgressHUD.showError(error.localizedDescription)
        }
        
        // 3. Output
        photoOutput.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])]   , completionHandler: nil)
        //原因 1
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        // 4. Previewlayer - Kameravorschau anzeigen lassen
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer.videoGravity = .resizeAspectFill
        cameraPreviewLayer.connection?.videoOrientation = .portrait
        //原因 2
        cameraPreviewLayer.frame = view.frame
        
        view.layer.insertSublayer(cameraPreviewLayer, at: 0)
        
        // 5. Starten
        captureSession.startRunning()
    }

    //MARK: - Take Photo
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        takePhoto()
//        print("Foto gemacht")
    }
    
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else { return }
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String : previewFormatType]
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            previewPhotoView.image = UIImage(data: imageData)
            saveButton.isHidden = false
            cancelButton.isHidden = false
        }
    }
    
    
    //MARK: - Switch Camera
    @IBAction func cameraSwitchButtonTapped(_ sender: UIButton) {
//        print("switch")
        switchCamera()
    }
    
    func switchCamera() {
        guard let input = captureSession.inputs[0] as? AVCaptureDeviceInput else { return }
        
        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }
        
        var newDevice: AVCaptureDevice?
        
        if input.device.position == .back {
            newDevice = captureDevice(with: .front)
        } else {
            newDevice = captureDevice(with: .back)
        }
        
        // Neues Input
        var deviceInput: AVCaptureDeviceInput!
        
        do {
            guard let device = newDevice else { return }
            deviceInput = try AVCaptureDeviceInput(device: device)
        } catch let error {
            ProgressHUD.showError(error.localizedDescription)
        }
        
        captureSession.removeInput(input)
        //！指示あり
        captureSession.addInput(deviceInput)
    }
    
    func captureDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .unspecified).devices
        for device in devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
    
    
    //MARK: - Save Photo
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        savePhoto()
    }
    
    func savePhoto() {
        //        print("save")
        let library = PHPhotoLibrary.shared()
        guard let image = previewPhotoView.image else { return }
        
        library.performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
            
        }) { (success, error) in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
                return
            } else {
                ProgressHUD.showSuccess("Foto gespeichert")
            }
        }
    }
    
    //MARK: - Cancel
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
//        print("cancel")
        cancel()
    }
    
    func cancel(){
        previewPhotoView.image = nil
        cancelButton.isHidden = true
        saveButton.isHidden = true
    }
    
    //MARK: - dimiss
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    
    

}
