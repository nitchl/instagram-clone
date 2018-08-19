//
//  CommentViewController.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/08/03.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class CommentViewController: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    //MARK: - var / let
    var comments = [CommentModel]()
    var users = [UserModel]()
    var post: PostModel?  // Bekommen wir vom HomeViewController
    var userUid = ""
    var hashtag = ""
    
    
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadComments()
        
        navigationItem.title = "Comment"
        
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.keyboardDismissMode = .interactive
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        addTargetToTextField()
        empty()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: - keyboard stuff
    @objc func keyboardWillShow(_ notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        UIView.animate(withDuration: 0.1) {
            self.bottomConstraint.constant = keyboardFrame!.height
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.2) {
            self.bottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func addTargetToTextField() {
        commentTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange() {
        let isText = commentTextField.text?.count ?? 0 > 0
        
        if isText {
            sendButton.setTitleColor(.black, for: .normal)
            sendButton.isEnabled = true
        } else {
            sendButton.setTitleColor(.lightGray, for: .normal)
            sendButton.isEnabled = false
        }
    }


    //MARK: - Send comment
    @IBAction func sendButtonTapped(_ sender: UIButton) {
//        print("comment send")
        sendButton.setTitleColor(.lightGray, for: .normal)
        sendButton.isEnabled = false
        createComment()
    }
    
    //MARK: - Comment Create
    func createComment() {
        guard let postId = post?.id else { return }
        CommentApi.shared.createCommentAndUploadToDatabase(commentText: commentTextField.text!, postId: postId, onSuccess: {
            self.view.endEditing(true)
            self.empty()
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }
    
    func empty() {
        commentTextField.text = ""
        self.sendButton.isEnabled = false
        sendButton.setTitleColor(.lightGray, for: .normal)
    }
    
    
    
    //MARK: - load comments
    func loadComments() {
        guard let postId = post?.id else { return }
        print("PostId: ", postId)
        
        CommentApi.shared.observePostComments(postId: postId) { (commentId) in
            print("CommentId: ", commentId)
            CommentApi.shared.observeComment(commentId: commentId, completion: { (comment) in
                self.fetchUser(uid: comment.uid!, completed: {
                    self.comments.append(comment)
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        UserApi.shared.observeUser(uid: uid) { (user) in
            self.users.append(user)
            completed()
            }
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentToShowUserInfoSegue" {
            let showUserInfoVC = segue.destination as! ShowUserInfoViewController
            showUserInfoVC.userUid = self.userUid
        }
        
        if segue.identifier == "CommentToHashtagVCSegue" {
            let hashtagVC = segue.destination as! HashTagViewController
            hashtagVC.hashtag = self.hashtag
        }
    }
}

//MARK: - TableView Datasource
extension CommentViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as! CommentTableViewCell
        
        cell.comment = comments[indexPath.row]
        cell.user = users[indexPath.row]
        
        cell.delegate = self
        
        return cell
    }
}

extension CommentViewController: CommentTableViewCellDelegate {
    func didTapCommentTextLabel(hashtag: String) {
        self.hashtag = hashtag
        performSegue(withIdentifier: "CommentToHashtagVCSegue", sender: self)
    }
    
    
    func didTapNameLabel(userUid: String) {
        self.userUid = userUid
        performSegue(withIdentifier: "CommentToShowUserInfoSegue", sender: self)
    }
}

















