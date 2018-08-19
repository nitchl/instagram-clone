//
//  ProfilViewController.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/07/28.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import UIKit

class ProfilViewController: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - var / let
    var user: UserModel?
    var posts = [PostModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.title = user?.username
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        fetchCurrentUser()
        loadMyPosts()
    }
    
    
    //MARK: - Fetch current user
    func fetchCurrentUser() {
        UserApi.shared.observeCurrentUser { (currentUser) in
            self.user = currentUser
            self.navigationItem.title = currentUser.username
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - load myPosts
    func loadMyPosts() {
        guard let currentUserUid = UserApi.shared.CURRENT_USER_UID else { return }
        PostApi.shared.observeMyPosts(withUid: currentUserUid) { (postId) in
            PostApi.shared.observePost(withPostId: postId, completion: { (post) in
                self.posts.insert(post, at: 0)
                self.collectionView.reloadData()
            })
        }
    }
    
}


//MARK: - CollectionView Datasource
extension ProfilViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostImageCollectionViewCell", for: indexPath) as! PostImageCollectionViewCell
        
//        cell.postImageView.image = UIImage(named: "natur")
        
        cell.post = posts[indexPath.row]
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "profilHeaderCollectionViewCell", for: indexPath) as! profilHeaderCollectionViewCell
        
        cell.contentView.isUserInteractionEnabled = false
        
        if let user = self.user {
            cell.user = user
            cell.delegate = self
        }
        
        return cell
    }
    
    // MARK: - Prepare Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserSetting_Segue" {
            let settingVC = segue.destination as! UserSettingsTableViewController
            settingVC.delegate = self
        }
    }

}


//MARK: - CollectionView FlowLayout
extension ProfilViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width / 3 - 1
        let size = CGSize(width: width, height: width)
        return size
    }
}
    
// MARK: - ProfilHeaderCollectionViewCellDelegate
extension ProfilViewController: ProfilHeaderCollectionViewCellDelegate {
    func goToSettingVC() {
        performSegue(withIdentifier: "UserSetting_Segue", sender: nil)
    }
}
    

extension ProfilViewController: UserSettingsTableViewControllerDelegate {
    func setNewName(newName: String) {
        navigationItem.title = newName
        
        fetchCurrentUser()
        collectionView.reloadData()
    }
    
    
}














