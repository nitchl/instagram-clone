//
//  UserSettingsTableViewController.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/08/19.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import UIKit
import SDWebImage
import Keychain

protocol UserSettingsTableViewControllerDelegate {
    func setNewName(newName: String)
}

class UserSettingsTableViewController: UITableViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - Outlet
    @IBOutlet weak var profilImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    var delegate: UserSettingsTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        emailTextField.delegate = self
        
        navigationItem.title = "Settings"
        
        profilImageView.layer.cornerRadius = 40
        
        fetchCurrentUser()
        
//        let password = Keychain.load("userInformation")
//        print("Passwort: ", password)
    }
    
    // MARK: - Fetch User Data
    func fetchCurrentUser() {
        UserApi.shared.observeCurrentUser { (user) in
            self.usernameTextField.text = user.username
            self.emailTextField.text = user.email
            
            guard let url = URL(string: user.profilImageUrl!) else { return }
            self.profilImageView.sd_setImage(with: url, completed: { (_, _, _, _) in
            })
        }
    }
    
    // MARK: - Action
    @IBAction func editFotoButtonTapped(_ sender: UIButton) {
        handleSelectProfilPhoto()
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        if let profilImage = self.profilImageView.image, let imageData = UIImageJPEGRepresentation(profilImage, 0.1) {
            ProgressHUD.show("Upload der Daten...")
            AuthenticationService.updateUserInformation(username: usernameTextField.text!, email: emailTextField.text!, imageData: imageData, onSuccess: {
                ProgressHUD.showSuccess("Update Erfolgreich!")
                
                
                self.delegate?.setNewName(newName: self.usernameTextField.text!)
                
                
            }) { (errorMessage) in
                ProgressHUD.showError(errorMessage!)
            }
        }
    }
    
    // MARK: - Select Foto
    func handleSelectProfilPhoto() {
        let pickerController = UIImagePickerController()
        // Fixed
        pickerController.delegate = self
        pickerController.allowsEditing = true
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            profilImageView.image = editImage
         
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            profilImageView.image = originalImage
          
        }
        dismiss(animated: true, completion: nil)
    }
    
}

extension UserSettingsTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        return true
    }
}







