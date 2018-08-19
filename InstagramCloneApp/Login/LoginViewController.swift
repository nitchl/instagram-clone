//
//  LoginViewController.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/07/26.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import UIKit
import FirebaseAuth
import AMPopTip
import Keychain

class LoginViewController: UIViewController {
    
    // MARK: - outlet
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var containerView: UIStackView!
    
    
    // MARK: - var / let
    let popTip = PopTip()
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupPopTip()
        
        addTargetToTextField()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AuthenticationService.automaticSingIn(onSuccess: {
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        })

    }
    
    
    // MARK: - Dismiss Keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 間違ったIDでloginしたら The email address is badly formatted. がされる
        view.endEditing(true)
        
        for touch in touches {
            let touchLocation = touch.location(in: self.view)
            //            print(touchLocation)
            
            if !loginButton.frame.contains(touchLocation) && !loginButton.isEnabled {
                popTip.show(text: "Bitte E-Mail und Passwort eintippen", direction: .down, maxWidth: 200, in: containerView, from: loginButton.frame, duration: 3)
            }
            
        }
        
    }
    
    
    // MARK: - Methoden
    func setupViews() {
        emailTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        emailTextField.borderStyle = .roundedRect
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : UIColor.black])
        
        passwordTextField.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : UIColor.black])
        
        loginButton.backgroundColor = UIColor(white: 0.8, alpha: 0.2)
        loginButton.layer.cornerRadius = 5
        loginButton.isEnabled = false
    }
    
    func addTargetToTextField() {
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
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
        let isText = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isText {
            loginButton.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
            loginButton.layer.cornerRadius = 5
            loginButton.isEnabled = true
        } else {
            loginButton.backgroundColor = UIColor(white: 0.8, alpha: 0.2)
            loginButton.layer.cornerRadius = 5
            loginButton.isEnabled = false
        }
    }

    
    
    
    
    
    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        ProgressHUD.show("Lade...", interaction: false)
        AuthenticationService.signIn(email: emailTextField.text!, password: passwordTextField.text!, onSuccess: {
            ProgressHUD.showSuccess("Login erfolgreich")
            
            // Passwort speichern
            let saveSucces: Bool = Keychain.save(self.passwordTextField.text!, forKey: "userInformation")
            
            if saveSucces == true {
                print("Passwort gespeichert")
            }
            
            
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }) { (error) in
//            print(error!)
//            ProgressHUD.showError(error!)
            ProgressHUD.showError("EMail oder Passwort falsch! :Eメールまたはパスワードが間違っています！")
        }
        // let test = AuthenticationService()
        // test.signIn()
        //AuthenticationService.signIn()
    }

    //    ポップアップ h ttps://github.com/andreamazz/AMPopTip
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
