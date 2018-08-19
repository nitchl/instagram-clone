//
//  HomeTableViewCell.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/08/03.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseDatabase
import FirebaseAuth
import AVFoundation
import KILabel

protocol HomeTableViewCellDelegate {
    func didTapCommentImageView(post: PostModel)
    func didTapNameLabel(userUid: String)
    func didTapPostTextLabel(hashtag: String)
}

class HomeTableViewCell: UITableViewCell {
    
    //MARK: - Outlet
    @IBOutlet weak var profilImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var postTextLabel: KILabel!
    
    @IBOutlet weak var soundView: UIView!
    @IBOutlet weak var soundButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    
    // MARK: - Video
    var player: AVPlayer?
    var playerlayer: AVPlayerLayer?
    var isSoundMuted = true
    
    //MARK: - Post
    var post: PostModel? {
        didSet {
            
            guard let _post = post else { return }
            
            updateCellView(post: _post)
        }
    }
  
    func updateCellView(post: PostModel) {
        postTextLabel.text = post.postText!
        postTextLabel.hashtagLinkTapHandler = { (label, string, range) in
            print(string)
            let newString = string.trimmingCharacters(in: CharacterSet.punctuationCharacters)
            print(newString)
            self.delegate?.didTapPostTextLabel(hashtag: newString)
        }
        
        
        if let ratio = post.ratio {
            //Umrechen von Verhaltnis (ratio) in die Hone und Breite
            //ratio = width / height height = width / ratio
            heightConstraint.constant = UIScreen.main.bounds.width / ratio
            layoutIfNeeded()
        }
        
        guard let url = URL(string: post.imageUrl!) else { return }
        postImageView.sd_setImage(with: url) { (_, _, _, _) in
        }
        
        //バグ修正　追加
        updateLike(post: post)
        
        //MARK: - Video
        if let _videoUrlString = post.videoUrl, let _videoUrl = URL(string: _videoUrlString) {
            player = AVPlayer(url: _videoUrl)
            playerlayer = AVPlayerLayer(player: player)
            playerlayer?.frame = postImageView.frame
            self.contentView.layer.addSublayer(playerlayer!) //for cheking
            playerlayer?.frame.size.width = UIScreen.main.bounds.width
            
            soundView.isHidden = false
            
            self.contentView.layer.addSublayer(playerlayer!)
            soundView.layer.zPosition = 1
            
            player?.play()
            player?.isMuted = isSoundMuted
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopVideo), name: NSNotification.Name.init("stopVideo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playVideo), name: NSNotification.Name.init("playVideo"), object: nil)
        
        // Time
        if let _postDate = post.postDate {
            let timeAgoDisplay = _postDate.timeAgoToDisplay()
            timeLabel.text = timeAgoDisplay
        }
    }
    
    @objc func stopVideo() {
        if player?.rate != 0 {
            player?.pause()
        }
    }
    
    @objc func playVideo() {
        if player?.rate == 0 {
            player?.play()
        }
    }
    
    
    //MARK: - User
    var user: UserModel? {
        didSet {
            
            guard let _username = user?.username else { return }
            guard let _profilImageUrl = user?.profilImageUrl else { return }
            
            setupUserInfo(username: _username, profilImageUrl: _profilImageUrl)
        }
    }
    
    func setupUserInfo(username: String, profilImageUrl: String) {
        nameLabel.text = username
        
        guard let url = URL(string: profilImageUrl) else { return }
        profilImageView.sd_setImage(with: url) { (_, _, _, _) in
        }
    }
    
    
    //MARK: - Like
    var postRef: DatabaseReference?
    
    func addTapGestureToLikeImageView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDidTapLike))
        likeImageView.addGestureRecognizer(tapGesture)
        likeImageView.isUserInteractionEnabled = true
    }
    
    @objc func handleDidTapLike() {
        guard let postId = post?.id else { return }
        
        //バグ修正 incrementLike -> updateLike
        PostApi.shared.updateLike(postId: postId, onSuccess: { (post) in
            self.updateLike(post: post)
            self.post?.likes = post.likes
            self.post?.isLiked = post.isLiked
            self.post?.likeCount = post.likeCount
            
            // Reporting Stuff
            guard let currentUserUid = UserApi.shared.CURRENT_USER_UID else { return }
            if post.uid! != currentUserUid {
                let likeTime = Date().timeIntervalSince1970
                let reportingId = ReportingApi.shared.REF_REPORTING.childByAutoId().key
                let reportingRef = ReportingApi.shared.REF_REPORTING.child(post.uid!).child(reportingId)
                
                if post.isLiked! {
                    reportingRef.setValue(["id": reportingId, "fromUserUid": currentUserUid, "type" : "like", "time": likeTime, "objectId": post.id! ])
                }
            }
            
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }

        print("push Like")
    }
    
    // Like in der Datenbank
    func updateLike(post: PostModel) {
        if post.isLiked == false || post.likes == nil {
            likeImageView.image = UIImage(named: "like")
        } else {
            likeImageView.image = UIImage(named: "idLike")
        }
        
        guard let count = post.likeCount else { return }
        if count != 0 {
            likeButton.setTitle("\(count) like", for: .normal)
        } else {
            likeButton.setTitle("0 like", for: .normal)
        }
    }
    
    //2018.8.5現在使えない状況
//    func incrementLike(postRef ref: DatabaseReference) {
//        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
//            if var post = currentData.value as? [String : AnyObject], let uid = Auth.auth().currentUser?.uid {
//
//                var likes: Dictionary<String, Bool>
//                likes = post["likes"] as? [String : Bool] ?? [:]
//                var likeCount = post["likeCount"] as? Int ?? 0
//
//                if let _ = likes[uid] {
//                    // Unstar the post and remove self from stars
//                    likeCount -= 1
//                    likes.removeValue(forKey: uid)
//                } else {
//                    // Star the post and add self to stars
//                    likeCount += 1
//                    likes[uid] = true
//                }
//
//                post["likeCount"] = likeCount as AnyObject?
//                post["likes"] = likes as AnyObject?
//
//                // Set value and report transaction success
//                currentData.value = post
//
//                return TransactionResult.success(withValue: currentData)
//            }
//            return TransactionResult.success(withValue: currentData)
//        }) { (error, committed, snapshot) in
//            if let error = error {
//                print(error.localizedDescription)
//            }
//        }
//    }
    
    //MARK: - Navigation to CommentViewController
    var delegate: HomeTableViewCellDelegate?
    //Hier wird eine Referenz vom HomeViewController gespeichert werden
    
    func addTappedGestureToCommentImageView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDidTapComment))
        commentImageView.addGestureRecognizer(tapGesture)
        commentImageView.isUserInteractionEnabled = true
    }
    
    @objc func handleDidTapComment() {
        guard let post = post else { return }
        delegate?.didTapCommentImageView(post: post)
    }
    
    
    //MARK: - Navigation to ShowUserInController
    func addTapGestureToNameLabel() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDidTapNameLabel))
        nameLabel.addGestureRecognizer(tapGesture)
        nameLabel.isUserInteractionEnabled = true
    }
    
    @objc func handleDidTapNameLabel() {
        guard let userUid = user?.uid else { return }
        delegate?.didTapNameLabel(userUid: userUid)
    }
    
    // MARK: - Sound
    @IBAction func soundButtonTapped(_ sender: UIButton) {
        if isSoundMuted == true {
            isSoundMuted = !isSoundMuted
            soundButton.setImage(UIImage(named: "Sound_On"), for: .normal)
        } else {
            isSoundMuted = !isSoundMuted
            soundButton.setImage(UIImage(named: "Sound_Off"), for: .normal)
        }
        player?.isMuted = isSoundMuted
    }
    
    
    
    
    
    //MARK: - Cell awake
    override func awakeFromNib() {
        super.awakeFromNib()
        profilImageView.layer.cornerRadius = profilImageView.frame.width / 2
        soundView.layer.cornerRadius = soundView.frame.width / 2
        
        addTappedGestureToCommentImageView()
        addTapGestureToLikeImageView()
        addTapGestureToNameLabel()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profilImageView.image = UIImage(named: "profil_placeholder")
        
        soundView.isHidden = true
        
        playerlayer?.removeFromSuperlayer()
        player?.pause()
    }
    














}
