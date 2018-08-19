//
//  RegistrationViewController.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/07/26.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import AMPopTip
import Keychain

class RegistrationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Outlet
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var haveAnAccountButton: UIButton!
    @IBOutlet weak var containerView: UIStackView!
    
    // MARK: - var / let
    var selectedImage: UIImage?
    let popTip = PopTip()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        addTargetToTextField()
        setupPopTip()
        
        addTapGestureToImageView()

    }
    
    // MARK: - Dismiss Keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
        for touch in touches {
            let touchLocation = touch.location(in: self.view)
            //            print(touchLocation)
            
            if !createAccountButton.frame.contains(touchLocation) && !createAccountButton.isEnabled {
                popTip.show(text: "Bitte Username, E-Mail und Passwort eintippen", direction: .down, maxWidth: 200, in: containerView, from: createAccountButton.frame, duration: 3)
            }
        }
    }

    
    // MARK: - Methoden
    func setupView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 2
        
        usernameTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : UIColor.black])
        
        emailTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        emailTextField.borderStyle = .roundedRect
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : UIColor.black])
        
        passwordTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : UIColor.black])
        
        createAccountButton.backgroundColor = UIColor(white: 0.8, alpha: 0.2)
        createAccountButton.layer.cornerRadius = 5
        createAccountButton.isEnabled = false
        let attributeText = NSMutableAttributedString(string: "Du hast einen Account?", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17), NSAttributedStringKey.foregroundColor : UIColor.white])
        
        attributeText.append(NSMutableAttributedString(string: " " + "Login", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17), NSAttributedStringKey.foregroundColor : UIColor.red]))
        
        haveAnAccountButton.setAttributedTitle(attributeText, for: .normal)
    }
    
    func addTargetToTextField() {
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        //popup
        emailTextField.addTarget(self, action: #selector(emailFieldDidEnter), for: .editingDidBegin)
        passwordTextField.addTarget(self, action: #selector(passwordFieldDidEnter), for: .editingDidBegin)
    }
    
    @objc func emailFieldDidEnter() {
        //        print("Email Eingabe")
        popTip.show(text: "Nur E-Mail mit @ gültig", direction: .up, maxWidth: 200, in: containerView, from: emailTextField.frame, duration: 3)
    }
    
    @objc func passwordFieldDidEnter() {
        //        print("Password Eingabe")
        popTip.show(text: "Nur Passwort mit min. 6 Zeichen gültig", direction: .up, maxWidth: 200, in: containerView, from: passwordTextField.frame, duration: 3)
    }
    
    @objc func textFieldDidChange() {
        let isText = usernameTextField.text?.count ?? 0 > 0 && emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isText {
            createAccountButton.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
            createAccountButton.layer.cornerRadius = 5
            createAccountButton.isEnabled = true
        } else {
            createAccountButton.backgroundColor = UIColor(white: 0.8, alpha: 0.2)
            createAccountButton.layer.cornerRadius = 5
            createAccountButton.isEnabled = false
        }
    }
    
    
    // MARK: - Choose photo
    func addTapGestureToImageView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSelectProfilePhoto))
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.isUserInteractionEnabled = true
    }
    
    @objc func handleSelectProfilePhoto() {
        print("click")
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            profileImageView.image = editImage
            selectedImage = editImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            profileImageView.image = originalImage
            selectedImage = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Action
    @IBAction func createButtonTapped(_ sender: UIButton) {
        print("Account create")
        view.endEditing(true)
        
        if selectedImage == nil {
//            print("Please select photo!")
            ProgressHUD.showError("Please select photo!")
            return
        }
        
        // Passwort speichern
        let saveSucces: Bool = Keychain.save(self.passwordTextField.text!, forKey: "userInformation")
        
        if saveSucces == true {
            print("Passwort gespeichert")
        }
        
        guard let image = selectedImage else { return }
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else { return }
        ProgressHUD.show("Lade...", interaction: false)
        AuthenticationService.createUser(username: usernameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!, imageData: imageData, onSuccess: {
            ProgressHUD.showSuccess("Profil wurde erstellt: プロフィールが作成されました。")
            self.performSegue(withIdentifier: "registerSegue", sender: nil)
        }) { (error) in
//            print(error!)
//            ProgressHUD.showError(error!)
            ProgressHUD.showError("User konnte nicht erstellt werden : ユーザーを作成できませんでした。")
        }
    }

    
    // MARK: - Navigation
    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - PopTip Setup
    func setupPopTip() {
        popTip.shouldDismissOnTap = true
        popTip.actionAnimation = .bounce(10.0)
        popTip.isRounded = true
        popTip.offset = 2.0
        popTip.edgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        popTip.bubbleColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        popTip.textColor = UIColor.white
    }
    
}
