//
//  UserModel.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/08/03.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import Foundation

class UserModel {
    
    var username: String?
    var email: String?
    var profilImageUrl: String?
    
    var uid: String?
    
    var isFollowing: Bool?
    
    init(dictionary: [String: Any]) {
        username = dictionary["username"] as? String
        email = dictionary["email"] as? String
        profilImageUrl = dictionary["profilImageUrl"] as? String
        uid = dictionary["uid"] as? String
    }
}
