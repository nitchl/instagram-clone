//
//  Post.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/08/05.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import Foundation
import FirebaseDatabase

class PostApi {
    // Adress Databank posts  post -> posts 訂正　注意！！
    var REF_POSTS = Database.database().reference().child("posts")
    var REF_MY_POSTS = Database.database().reference().child("myPosts")
    
    // Singleton patter (Einzelstuck Muster)
    static var shared: PostApi = PostApi()
    private init() {
    }
    
    // Alles Posts herunterladen
    func observePosts(completion: @escaping (PostModel) -> Void) {
        REF_POSTS.observe(.childAdded) { (snapshot) in
            guard let dic = snapshot.value as? [String: Any] else { return }
            let newPost = PostModel(dictionary: dic, key: snapshot.key)
            completion(newPost)
        }
    }
    
    // Ein Post mit der Id... herunterladen
    func observePost(withPostId id: String, completion: @escaping (PostModel) -> Void ) {
        REF_POSTS.child(id).observeSingleEvent(of: .value) { (snapshot) in
            guard let dic = snapshot.value as? [String : Any] else { return }
            let newPost = PostModel(dictionary: dic, key: snapshot.key)
            completion(newPost)
        }
    }
    
    // myPost laden
    func observeMyPosts(withUid uid: String, completion: @escaping (String) -> Void) {
        REF_MY_POSTS.child(uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            completion(postId)
        }
    }
    
    // Postcount laden
    func fetchCountPosts(withUid uid: String, completion: @escaping(UInt) -> Void) {
        REF_MY_POSTS.child(uid).observe(.value) { (snapshot) in
            let postCount = snapshot.childrenCount
            completion(postCount)
        }
    }
    
    // Lade ein Objekt wenn sich an diesem etwas verändert anahnd der id
    func observeLike(withPostId id: String, completion: @escaping (Int) -> Void) {
        REF_POSTS.child(id).observe(.childAdded) { (snapshot) in
            guard let value = snapshot.value as? Int else { return }
            completion(value)
        }
    }
    
    // Liken バグ修正 incrementLike -> updateLike
    func updateLike(postId id: String, onSuccess: @escaping (PostModel) -> Void, onError: @escaping (_ errorMessage: String?) -> Void) {
        
        let postRef = REF_POSTS.child(id)
        
        postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = UserApi.shared.CURRENT_USER_UID {
                
                var likes: Dictionary<String, Bool>
                likes = post["likes"] as? [String : Bool] ?? [:]
                
                var likeCount = post["likeCount"] as? Int ?? 0
                
                if let _ = likes[uid] {
                    // Unstar the post and remove self from stars
                    likeCount -= 1
                    likes.removeValue(forKey: uid)
                } else {
                    // Star the post and add self to stars
                    likeCount += 1
                    likes[uid] = true
                }
                
                post["likeCount"] = likeCount as AnyObject?
                post["likes"] = likes as AnyObject?
                
                // Set value and report transaction success
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                onError(error.localizedDescription)
            }
            guard let dic = snapshot?.value as? [String: Any] else { return }
            guard let postId = snapshot?.key else { return }
            let updatedPost = PostModel(dictionary: dic, key: postId)
            onSuccess(updatedPost)
        }
    }
    
    // Posts laden und nach like  sortieren
    func observeTopPost(completion: @escaping(PostModel) -> Void) {
        REF_POSTS.queryOrdered(byChild: "likeCount").observeSingleEvent(of: .value) { (snapshot) in
            let arraySnapshot = (snapshot.children.allObjects as! [DataSnapshot]).reversed()
            
            arraySnapshot.forEach({ (child) in
                guard let dic = child.value as? [String: Any] else { return }
                let post = PostModel(dictionary: dic, key: snapshot.key)
                completion(post)
            })
        }
    }
    
    
    
    
    
    
    
}
