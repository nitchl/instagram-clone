//
//  CommentModel.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/08/04.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import Foundation

class CommentModel {
    
    var commentText: String?
    var uid: String?
    
    init(dictionary: [String: Any]) {
        commentText = dictionary["commentText"] as? String
        uid = dictionary["uid"] as? String
    }
}
