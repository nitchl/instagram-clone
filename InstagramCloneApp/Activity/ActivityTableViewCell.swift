//
//  ActivityTableViewCell.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/08/17.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import UIKit
import SDWebImage

class ActivityTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var profilImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    
    
    // Reporting Stuff
    var reportObject: ReportingModel? {
        didSet {
            guard let _report = reportObject else { return }
            updateView(report: _report)
        }
    }
    
    //MARK: - updateView
    func updateView(report: ReportingModel) {
        if report.type == "post" {
            statusLabel.text = "Neuer Post erstellt!"
            createTime(report: report)
            
            guard let postId = report.objectId else { return }
            PostApi.shared.observePost(withPostId: postId, completion: { (post) in
                guard let postImageUrlSting = post.imageUrl else { return }
                guard let imageUrl = URL(string: postImageUrlSting) else { return }
                self.postImageView.sd_setImage(with: imageUrl, completed: { (_, _, _, _) in
                })
            })
        } else if report.type == "comment" {
            statusLabel.text = "Neues Kommentar erstellt!"
            createTime(report: report)

            guard let postId = report.objectId else { return }
            PostApi.shared.observePost(withPostId: postId, completion: { (post) in
                guard let postImageUrlSting = post.imageUrl else { return }
                guard let imageUrl = URL(string: postImageUrlSting) else { return }
                self.postImageView.sd_setImage(with: imageUrl, completed: { (_, _, _, _) in
                })
            })
        } else if report.type == "like" {
            statusLabel.text = "Neuer like!"
            createTime(report: report)

            guard let postId = report.objectId else { return }
            PostApi.shared.observePost(withPostId: postId, completion: { (post) in
                guard let postImageUrlSting = post.imageUrl else { return }
                guard let imageUrl = URL(string: postImageUrlSting) else { return }
                self.postImageView.sd_setImage(with: imageUrl, completed: { (_, _, _, _) in
                })
            })
        }
    }
    
    //MARK: - createTime
    func createTime(report: ReportingModel) {
        if let _time = report.createDate {
            let timeAgoDisplay = _time.timeAgoToDisplay()
            timeLabel.text = timeAgoDisplay
        }
    }
    
    // MARK: - User
    var user: UserModel? {
        didSet {
            
            guard let _username = user?.username else { return }
            guard let _profilImageUrl = user?.profilImageUrl else { return }
            
            setupUserInfo(username: _username, profilImageUrl: _profilImageUrl)
        }
    }
    
    //:MARK:- setupUserInfo
    func setupUserInfo(username: String, profilImageUrl: String) {
        nameLabel.text = username
        
        guard let url = URL(string: profilImageUrl) else { return }
        profilImageView.sd_setImage(with: url) { (_, _, _, _) in
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profilImageView.layer.cornerRadius = profilImageView.frame.width / 2
    }



}
