//
//  ShareService.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/08/05.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase

class ShareService {
    static var REF_STORAGE_POST = Storage.storage().reference().child("posts")
    
    static func uploadDataToStorage(imageData: Data, videoUrl: URL? = nil, postText: String, imageRatio: CGFloat, onSuccess: @escaping () -> Void ) {
        
        // 1. Video hochladen
        if let _videoUrl = videoUrl {
            self.uploadVideoToFireBaseStorage(videoUrl: _videoUrl, onSucces: { (videoUrlString) in
                self.uploadImageToFireBaseStorage(data: imageData, onSucces: { (thumbnailUrlString) in
                    self.uploadDataToDatabase(imageUrl: thumbnailUrlString, videoUrl: videoUrlString, postText: postText, imageRatio: imageRatio, onSuccess: onSuccess)
                })
            })
        } else {
            // 2. Bild hochalden
            self.uploadImageToFireBaseStorage(data: imageData, onSucces: { (imageUrlString) in
                self.uploadDataToDatabase(imageUrl: imageUrlString, postText: postText, imageRatio: imageRatio, onSuccess: onSuccess)
            })
            
        }
    }
    
    // Video hochladen
    fileprivate static func uploadVideoToFireBaseStorage(videoUrl: URL, onSucces: @escaping (_ videoUrl: String) -> Void) {
        let videoIdString = NSUUID().uuidString
        
        let storageRef = REF_STORAGE_POST.child(videoIdString)
        
        storageRef.putFile(from: videoUrl, metadata: nil) { (metaData, error) in
            if error != nil {
                ProgressHUD.showError("Fehler beim hochladen des Videos")
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                let videoUrlString = url?.absoluteString
                onSucces(videoUrlString ?? "Kein Video vorhande")
            })
        }
    }
    
    // Bild hochladen
    fileprivate static func uploadImageToFireBaseStorage(data: Data,  onSucces: @escaping (_ imageUrl: String) -> Void) {
        let photoIdString = NSUUID().uuidString
        
        let storageRef = REF_STORAGE_POST.child(photoIdString)
        
        storageRef.putData(data, metadata: nil) { (metaData, error) in
            if error != nil {
                ProgressHUD.showError("Fehler beim hochladen des Bildes")
            }
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                let imageUrlString = url?.absoluteString
                onSucces(imageUrlString ?? "Kein Bild vorhanden")
            })
        }
    }
    

    // MARK: - uploadDataToDatabase
    fileprivate static func uploadDataToDatabase(imageUrl: String, videoUrl: String? = nil, postText: String, imageRatio: CGFloat, onSuccess: @escaping () -> Void) {
        let newPostId = PostApi.shared.REF_POSTS.childByAutoId().key
        let newPostRef = PostApi.shared.REF_POSTS.child(newPostId)
        
        let postTime = Date().timeIntervalSince1970 //for cheking
        print(postTime) //for cheking
        
        // hashtag stuff
        var textArray = postText.components(separatedBy: CharacterSet.whitespaces)
        
        for var word in textArray {
            if word.hasPrefix("#") && word.count > 1 {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                let newHashtagRef = HashtagApi.shared.REF_HASHTAG.child(word.lowercased())
                let dic = [newPostId : true]
                newHashtagRef.updateChildValues(dic)
            }
        }
        textArray.removeAll()
        
        guard let currentUserUid = UserApi.shared.CURRENT_USER_UID else { return }
        var dic = ["uid": currentUserUid, "imageUrl" : imageUrl, "imageRatio": imageRatio, "postText" : postText, "postTime" : postTime] as [String : Any]
        
        if let _videoUrl = videoUrl {
            dic["videoUrl"] = _videoUrl
        }
        
        newPostRef.setValue(dic) { (error, _) in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
            }
            
            // Eigene Posts im newfeed laden und anzeigen
            FeedApi.shared.REF_NEWSFEED.child(currentUserUid).child(newPostId).setValue(true)
            
            // Eigene Posts markieren
            PostApi.shared.REF_MY_POSTS.child(currentUserUid).child(newPostId).setValue(true)
            
            // Posts in Echtzeit bei den Followern, des aktuell eingeloggten Users anzeigen + Reporting
            FollowApi.shared.REF_FOLLOWERS.child(currentUserUid).observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                let followerArray = snapshot.children.allObjects as! [DataSnapshot]
                followerArray.forEach({ (child) in
                    FeedApi.shared.REF_NEWSFEED.child(child.key).updateChildValues(["\(newPostId)" : true])

                    // Reporting
                    let reportingId = ReportingApi.shared.REF_REPORTING.childByAutoId().key
                    let reportingRef = ReportingApi.shared.REF_REPORTING.child(child.key).child(reportingId)
                    reportingRef.setValue(["id": reportingId, "fromUserUid": currentUserUid, "type": "post","objectId": newPostId, "time" : postTime])
                })
            })
            
            
            ProgressHUD.showSuccess("Post erstellt")
            onSuccess()
        }
    }























}
