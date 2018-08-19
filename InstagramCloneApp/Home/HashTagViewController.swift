//
//  HashTagViewController.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/08/17.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import UIKit

class HashTagViewController: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - var / let
    var posts = [PostModel]()
    var hashtag = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadPosts(hashtag: hashtag)
        //付け足してみた（当たり！）
        self.collectionView.reloadData()
    }
    
    func loadPosts(hashtag: String) {
        HashtagApi.shared.fetchPostsId(with: hashtag) { (postId) in
            PostApi.shared.observePost(withPostId: postId, completion: { (post) in
                self.posts.insert(post, at: 0)
                self.collectionView.reloadData()
            })
        }
    }
}

// MARK: - CollectionView Datasocurce
extension HashTagViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostImageCollectionViewCell", for: indexPath) as! PostImageCollectionViewCell
        
        cell.post = posts[indexPath.row]
        
        return cell
    }
}


// MARK: - CollectionView FlowLayout
extension HashTagViewController: UICollectionViewDelegateFlowLayout {
    
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
