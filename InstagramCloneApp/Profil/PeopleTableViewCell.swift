//
//  PeopleTableViewCell.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/08/06.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import UIKit
import SDWebImage

protocol PeopleCellDelegate {
    func didTappedShowUserInfo(userUid: String)
}

class PeopleTableViewCell: UITableViewCell {
    
    // MARK: - Outlet
    @IBOutlet weak var profilImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followUnfollowButton: UIButton!
    
    var user: UserModel? {
        didSet {
            guard let _user = user else { return }
            updateView(user: _user)
        }
    }
    
    func updateView(user: UserModel) {
        nameLabel.text = user.username
        
        guard let url = URL(string: user.profilImageUrl!) else { return }
        profilImageView.sd_setImage(with: url) { (_, _, _, _) in
        }
        
        if user.isFollowing! == true {
            
            print("following status true") // for checking
            
            setupUnFollowButton()
        } else {
            setupFollowButton()
        }
    }
    
    
    // MARK: Follow / UnFollow
    func setupFollowButton() {
        
        print("push follow") // for checking
        
        followUnfollowButton.layer.borderWidth = 1
        followUnfollowButton.layer.borderColor = UIColor.lightGray.cgColor
        followUnfollowButton.layer.cornerRadius = 5
        followUnfollowButton.clipsToBounds = true
        followUnfollowButton.setTitleColor(UIColor.white, for: .normal)
        followUnfollowButton.backgroundColor = UIColor(red: 1 / 255, green: 84 / 255, blue: 147 / 255, alpha: 1.0)
        followUnfollowButton.setTitle("Follow", for: .normal)
        followUnfollowButton.addTarget(self, action: #selector(followAction), for: .touchUpInside)
        
    }
    
    func setupUnFollowButton() {
        
        print("push unfollow")// for checking
        
        followUnfollowButton.layer.borderWidth = 1
        followUnfollowButton.layer.borderColor = UIColor.lightGray.cgColor
        followUnfollowButton.layer.cornerRadius = 5
        followUnfollowButton.clipsToBounds = true
        
        followUnfollowButton.setTitleColor(UIColor.black, for: .normal)
        followUnfollowButton.backgroundColor = UIColor.white
        followUnfollowButton.setTitle("Following", for: .normal)
        followUnfollowButton.addTarget(self, action: #selector(unFollowAction), for: .touchUpInside)
    }
    
    @objc func followAction() {
        print("follow Action")
        if user?.isFollowing == false {
            FollowApi.shared.followAction(withUser: user!.uid!) // Datenbank
            setupUnFollowButton() // View
            user?.isFollowing = true // Objekt
        }
    }
    
    @objc func unFollowAction() {
        print("unfollow Action")
        if user?.isFollowing == true {
            FollowApi.shared.unFollowAction(withUser: user!.uid!) // Datenbank
            setupFollowButton() // View
            user?.isFollowing = false // Objekt
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilImageView.layer.cornerRadius = profilImageView.frame.width / 2
        
        let tapGestureShowProfil = UITapGestureRecognizer(target: self, action: #selector(handleShowProfil))
        nameLabel.addGestureRecognizer(tapGestureShowProfil)
        nameLabel.isUserInteractionEnabled = true
    }

    // MARK: - Show User Information
    var delegate: PeopleCellDelegate?
    
    @objc func handleShowProfil() {
        
        guard let userUid = user?.uid else { return }
        delegate?.didTappedShowUserInfo(userUid: userUid)
        
//        print("UserUid: ", user?.uid)
        print("UserUid: ", userUid)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
