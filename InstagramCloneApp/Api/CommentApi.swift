//
//  CommentApi.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/08/05.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import Foundation
import FirebaseDatabase

class CommentApi {
    // Adresse Datebank comments
    var REF_COMMENTS = Database.database().reference().child("comments")
    var REF_POST_COMMENTS = Database.database().reference().child("post-comments")
    
    // Singleton pattern (Einzelstuck Muster)
    static var shared: CommentApi = CommentApi()
    private init() {
    }
    
    // Lade die commentId fur den jeweiligen Post herrunter
    func observePostComments(postId: String, completion: @escaping (String) -> Void) {
        REF_POST_COMMENTS.child(postId).observe(.childAdded) { (snapshot) in
            let commentId = snapshot.key
            completion(commentId)
        }
    }
    
    // Lade das Kommentar mit der id...
    func observeComment(commentId: String, completion: @escaping (CommentModel) -> Void) {
        REF_COMMENTS.child(commentId).observeSingleEvent(of: .value) { (snapshot) in
            guard let dic = snapshot.value as? [String: Any] else { return }
            let newComment = CommentModel(dictionary: dic)
            completion(newComment)
        }
    }
    
    // Kommentar erstellen
    func createCommentAndUploadToDatabase(commentText: String, postId: String, onSuccess: @escaping () -> Void, onError: @escaping (_ error: String?) -> Void) {
        
        //1 Teil - kommentar erstellen
        let commentRef = REF_COMMENTS
        let commentId = commentRef.childByAutoId().key
        
        let newCommentRef = commentRef.child(commentId)
        guard let currentUserUid = UserApi.shared.CURRENT_USER_UID else { return }
        
        let dic = ["uid" : currentUserUid, "commentText" : commentText] as [String: Any]
        newCommentRef.setValue(dic) { (_, _) in
            
            // 2 Teil - Kommentar mit dem Post verknupfen
            self.REF_POST_COMMENTS.child(postId).child(commentId).setValue(true, withCompletionBlock: { (error, _) in
                if error != nil {
                    onError(error?.localizedDescription)
                }
                
                // hashtag stuff
                var textArray = commentText.components(separatedBy: CharacterSet.whitespaces)
                
                for var word in textArray {
                    if word.hasPrefix("#") && word.count > 1 {
                        word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                        let newHashtagRef = HashtagApi.shared.REF_HASHTAG.child(word.lowercased())
                        let dic = [postId : true]
                        newHashtagRef.updateChildValues(dic)
                    }
                }
                textArray.removeAll()
                
                // report stuff
                let postCommentRef = self.REF_POST_COMMENTS.child(postId).child(commentId)
                postCommentRef.setValue(true, withCompletionBlock: { (error, ref) in
                    if error != nil {
                        ProgressHUD.showError(error?.localizedDescription)
                        return
                    }
                    PostApi.shared.observePost(withPostId: postId, completion: { (post) in
                        if post.uid! != UserApi.shared.CURRENT_USER_UID! {
                            let commentTime = Date().timeIntervalSince1970
                            let reportingId = ReportingApi.shared.REF_REPORTING.childByAutoId().key
                            let reportingRef = ReportingApi.shared.REF_REPORTING.child(post.uid!).child(reportingId)
                            reportingRef.setValue(["id" : reportingId, "fromUserUid": currentUserUid, "type" : "comment", "time": commentTime, "objectId" : postId])
                        }
                    })
                })
                
                
                
                onSuccess()
            })
        }
    }
    
    
//以下のエラーが生じているが今の所動作しているのでここまま続ける hash tag KLabelについて
//    error: IB Designables: Failed to render and update auto layout status for CommentViewController (elw-Kd-Tpn): dlopen(KILabel.framework, 1): no suitable image found.  Did find:
//    KILabel.framework: required code signature missing for 'KILabel.framework'
    
    
    
   
    
    
    
}
