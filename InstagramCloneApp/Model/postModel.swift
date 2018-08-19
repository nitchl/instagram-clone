//
//  postModel.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/08/03.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import Foundation

class PostModel {
    
    var postText: String?
    var imageUrl: String?
    var uid: String? // User Id, welcher den Post gemacht hat
    var id: String? // Post ID
    
    //Ratio
    var ratio: CGFloat?
    
    // Video
    var videoUrl: String?
    
    // Time
    var secondsFrom1970: Double?
    var postDate: Date?
    
    // Like stuff
    var likeCount: Int?
    var likes: Dictionary<String, Any>?
    var isLiked: Bool? = false
    
    init(dictionary: [String: Any], key: String) {
        postText = dictionary["postText"] as? String
        imageUrl = dictionary["imageUrl"] as? String
        uid = dictionary["uid"] as? String
        id = key
        
        //Ratio
        ratio = dictionary["imageRatio"] as? CGFloat
        
        // Video
        videoUrl = dictionary["videoUrl"] as? String
        
        // Time
        secondsFrom1970 = dictionary["postTime"] as? Double
        if let _secondsFrom1970 = secondsFrom1970 {
            postDate = Date(timeIntervalSince1970: _secondsFrom1970)
        }
        
        // Like stuff
        likeCount = dictionary["likeCount"] as? Int
        if likeCount == nil {
            likeCount = 0
        }
        
        likes = dictionary["likes"] as? Dictionary<String, Any>
        
        if let currentUserUid = UserApi.shared.CURRENT_USER_UID {
            if let likes = self.likes {
                isLiked = likes[currentUserUid] != nil // true oder nil
            }
        }
    }
}
