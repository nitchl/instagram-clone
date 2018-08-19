//
//  HomeViewController.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/08/11.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - Outlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activtixIndicatorView: UIActivityIndicatorView!
    
    
    // MARK: - var / let
    var posts = [PostModel]()
    var users = [UserModel]()
    var userUid = ""
    var hashtag = ""
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Home"
        
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero) // Nicht genutzte Tabellenzeilen ausblenden
        tableView.estimatedRowHeight = 500
        tableView.rowHeight = UITableViewAutomaticDimension
        
        loadPosts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name.init("stopVideo"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name.init("playVideo"), object: nil)
    }
    
    
    // MARK: - Load posts
    func loadPosts() {
        activtixIndicatorView.startAnimating()
        guard let currentUserUid = UserApi.shared.CURRENT_USER_UID else { return }
        FeedApi.shared.observeFeed(withUid: currentUserUid) { (post) in
            guard let userUid = post.uid else { return }
            self.fetchUser(uid: userUid, completed: {
                self.posts.insert(post, at: 0)
                self.activtixIndicatorView.stopAnimating()
                self.tableView.reloadData()
                self.tableView.setContentOffset(CGPoint.zero, animated: true)
            })
        }
        FeedApi.shared.observeRemoveFeed(withUid: currentUserUid) { (getPost) in
            
            // Post löschen aus posts
            self.posts = self.posts.filter { $0.id != getPost.id }
            
            // User löschen aus users
            self.users = self.users.filter { $0.uid != getPost.uid }
            
            self.tableView.reloadData()
        }
    }
    
    
    
    //    func loadPosts() {
    //        activtixIndicatorView.startAnimating()
    //
    //        PostApi.shared.observePosts { (post) in
    //            self.fetchUser(uid: post.uid!, completed: {
    //                self.posts.insert(post, at: 0)
    //                self.activtixIndicatorView.stopAnimating()
    //                self.tableView.reloadData()
    //                self.tableView.setContentOffset(CGPoint.zero, animated: true)
    //            })
    //        }
    //    }
    
    
    // MARK: - Fetch Users
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        UserApi.shared.observeUser(uid: uid) { (user) in
            self.users.insert(user, at: 0)
            completed()
        }
    }
    
    
    // MARK: - Log Out
    @IBAction func logOutButtonTapped(_ sender: UIBarButtonItem) {
        
        AuthenticationService.logOut(onSuccess: {
            let storyboard = UIStoryboard(name: "Start", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
            self.present(loginVC, animated: true, completion: nil)
        }) { (error) in
            print(error!)
        }
    }
    
    
    // MARK: - topButtonTapped
    @IBAction func topButtonTapped(_ sender: UIBarButtonItem) {
        tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    
    // MARK: - Navigation
    var post: PostModel?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCommentViewController" {
            let commentVC = segue.destination as! CommentViewController
            commentVC.post = self.post
        }
        
        if segue.identifier == "HomeToShowUserInfoSegue" {
            let showUserInfoVC = segue.destination as! ShowUserInfoViewController
            showUserInfoVC.userUid = self.userUid
        }
        
        if segue.identifier == "HomeToHashTagVCSegue" {
            let hashtagVC = segue.destination as! HashTagViewController
            hashtagVC.hashtag = self.hashtag
        }
    }
}

// MARK: - TableView Datasoruce
extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as! HomeTableViewCell
        
        cell.post = posts[indexPath.row]
        cell.user = users[indexPath.row]
        
        cell.delegate = self
        
        return cell
    }
}

// MARK: - HomeTableViewCellDelegate
extension HomeViewController: HomeTableViewCellDelegate {
    func didTapPostTextLabel(hashtag: String) {
        self.hashtag = hashtag
        performSegue(withIdentifier: "HomeToHashTagVCSegue", sender: self)
    }
    
    
    func didTapNameLabel(userUid: String) {
        self.userUid = userUid
        performSegue(withIdentifier: "HomeToShowUserInfoSegue", sender: self)
    }
    
    func didTapCommentImageView(post: PostModel) {
        self.post = post
        performSegue(withIdentifier: "showCommentViewController", sender: nil)
    }
}

