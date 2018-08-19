//
//  AuthenticationService.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/07/29.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Keychain

class AuthenticationService {
    
    //MARK: - log in
    static func signIn(email: String, password: String, onSuccess: @escaping () -> Void, onError: @escaping(_ error: String?) -> Void) {
            Auth.auth().signIn(withEmail: email, password: password) { (data, error) in
                if let err = error {
                    //print(err.localizedDescription)
                    onError(err.localizedDescription)
                    return
                }
                print(data?.user.email ?? "" )
                onSuccess() //The surrendering closure will be displayed upon successful login
            }
        }
    
    //MARK: - Automatic Einloggen
    static func automaticSingIn(onSuccess: @escaping () -> Void) {
        if Auth.auth().currentUser != nil {
            DispatchQueue.main.async {
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (Timer) in
//                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                    onSuccess()

                })
            }
        }
    }
    
    //MARK: - Ausloggen
    static func logOut(onSuccess: @escaping () -> Void, onError: @escaping (_ error: String?) -> Void) {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
//            print(logoutError.localizedDescription)
            onError(logoutError.localizedDescription)
        }
        onSuccess()
    }
    
    //MARK: - User erstellen
    static func createUser(username: String, email: String, password: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ error: String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (data, error) in
            if let err = error {
            onError(err.localizedDescription)
            return
            }
            // user erfolgreich erstellt
            guard let uid = data?.user.uid else { return }
            self.uploadUserData(uid: uid, username: username, email: email, imageData: imageData, onSuccess: onSuccess)
        }
    }
    
    
    
    
    
    
    // MARK: - User nochmal einloggen
    private static func authenticateUser() {
        guard let currentUser = UserApi.shared.CURRENT_USER else { return }
        guard let email = UserApi.shared.CURRENT_USER?.email else { return }
        guard let password = loadUserInfo() else { return }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        currentUser.reauthenticateAndRetrieveData(with: credential) { (data, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            print("Reauthenticate hat funktioniert")
        }
    }
    
    // MARK: - Load Password
    static private func loadUserInfo() -> String? {
        return Keychain.load("userInformation")
//        return "0" //for waiting
    }
    
    // MARK: - User Infos update
    static func updateUserInformation(username: String, email: String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping(_ error: String?) -> Void) {
        guard let currentUserUid = UserApi.shared.CURRENT_USER_UID else { return }
        
        // User nochmal einloggen
        authenticateUser()
        
        // Daten in Authentication ändern
        UserApi.shared.CURRENT_USER?.updateEmail(to: email, completion: { (error) in
            if error != nil {
                onError(error?.localizedDescription)
            } else {
                
                // Storage
                let storageRef = Storage.storage().reference().child("profil_image").child(currentUserUid)
                
                storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                    if error != nil {
                        return
                    }
                    
                    // Datenbank guardがダメだったので変更？
                    storageRef.downloadURL(completion: { (url, error) in
                        if error != nil {
                            print(error!.localizedDescription)
                            return
                        }
                        let profilImageUrlString = url?.absoluteString
                        
                        let ref = Database.database().reference().child("users").child(currentUserUid)
                        let dic = ["username" : username , "username_lowercase" : username.lowercased(), "email" : email, "profilImageUrl" : profilImageUrlString ?? "Kein Bild vorhanden"]
                        
                        ref.updateChildValues(dic, withCompletionBlock: { (error, ref) in
                            if error != nil {
                                onError(error?.localizedDescription)
                            } else {
                                onSuccess()
                            }
                        })
                    })
                }
            }
        })
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - Daten hochladen
    static func uploadUserData(uid: String, username: String, email: String, imageData: Data, onSuccess: @escaping () -> Void) {
        
        let storageRef = Storage.storage().reference().child("profil_image").child(uid)

        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if error != nil {
                return
            }

            storageRef.downloadURL(completion: { (url, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                // ????????????
                let profilImageUrlString = url?.absoluteString
                
                let ref = Database.database().reference().child("users").child(uid)
                ref.setValue(["uid": uid, "username" : username, "username_lowercase" : username.lowercased(), "email" : email, "profilImageUrl" : profilImageUrlString ?? "Kein Bild vorhanden"])
                
                onSuccess()

            })
        }
    }




















}
