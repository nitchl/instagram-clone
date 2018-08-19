//
//  ShareViewController.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/07/28.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import AVFoundation

class ShareViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: - Outlet
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var abortButton: UIButton!
    
    
    //MARK: - var / let
    var selectedImage: UIImage?
    var videoUrl: URL?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .black
        
        navigationItem.title = "Share"
        
        //MARK: - View lifecycle
        addTapGestureToImageView()
        handleShareAndAbortButton()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imageDidChange()
    }

    //MARK: - View stuf
    func handleShareAndAbortButton() {
        shareButton.isEnabled = false
        abortButton.isEnabled = false
        
        let attributeShareButtonText = NSAttributedString(string: shareButton.currentTitle!, attributes: [NSAttributedStringKey.foregroundColor : UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)])
        let attributeAbortButtonText = NSAttributedString(string: abortButton.currentTitle!, attributes: [NSAttributedStringKey.foregroundColor : UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)])
        
        shareButton.setAttributedTitle(attributeShareButtonText, for: .normal)
        abortButton.setAttributedTitle(attributeAbortButtonText, for: .normal)
        
    }
    
    func imageDidChange() {
        let isImage = selectedImage != nil
        
        if isImage {
            shareButton.isEnabled = true
            abortButton.isEnabled = true
            
            let attributeShareButtonText = NSAttributedString(string: shareButton.currentTitle!, attributes: [NSAttributedStringKey.foregroundColor : UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)])
            let attributeAbortButtonText = NSAttributedString(string: abortButton.currentTitle!, attributes: [NSAttributedStringKey.foregroundColor : UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)])
            
            shareButton.setAttributedTitle(attributeShareButtonText, for: .normal)
            abortButton.setAttributedTitle(attributeAbortButtonText, for: .normal)
        }
    }
    //キーボードを閉じる？
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: - choose post photo
    func addTapGestureToImageView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSelectPhoto))
        postImageView.addGestureRecognizer(tapGesture)
        postImageView.isUserInteractionEnabled = true
    }

    @objc func handleSelectPhoto() {
//        print("tap photo")
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.mediaTypes = ["public.image", "public.movie"]
        present(pickerController, animated: true, completion: nil)
    }
    
    //UserInfo={NSLocalizedDescription=query cancelled} は問題ではない
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let editImage = info["UIImagePickerControllerEditedImage"] as? UIImage { //仮
            postImageView.image = editImage
            selectedImage = editImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {  //仮
            postImageView.image = originalImage
            selectedImage = originalImage
        } else if let videoUrl = info["UIImagePickerControllerMediaURL"] as? URL {  //仮
            if let thumbnailImage = self.thumbnailImageForFileUrl(fileUrl: videoUrl) {
                self.videoUrl = videoUrl
                self.postImageView.image = thumbnailImage
                self.selectedImage = thumbnailImage
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func thumbnailImageForFileUrl(fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenrerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let time = CMTime.init(value: 9, timescale: 3) //圧縮率を決める
            let thumbnailImage = try imageGenrerator.copyCGImage(at: time, actualTime: nil)
            
            return UIImage(cgImage: thumbnailImage)
        } catch let err {
            print("Fehler: ", err)
        }
        return nil
    }
    
    //MARK: - Post
    @IBAction func shareButtonTapped(_ sender: UIButton) {
//        print("share")
        view.endEditing(true)
        ProgressHUD.show("Lade...", interaction: false)
        
        guard let image = selectedImage else { return }
        guard let imageData = UIImageJPEGRepresentation(image, 0.3) else { return }
        let imageRatio = image.size.width / image.size.height
        
        // videoUrl: videoUrlが抜けていました。
        ShareService.uploadDataToStorage(imageData: imageData, videoUrl: videoUrl,postText: postTextView.text, imageRatio: imageRatio) {
            self.remove()
            self.handleShareAndAbortButton()
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    @IBAction func abortButtonTapped(_ sender: UIButton) {
        print("Abort")
        remove()
        handleShareAndAbortButton()
    }
    
    func remove() {
        selectedImage = nil
        postTextView.text = ""
        postImageView.image = UIImage(named: "placeholder")
        videoUrl = nil
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
