
//
//  PostImageCollectionViewCell.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/08/06.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import UIKit
import SDWebImage

class PostImageCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Outlet
    @IBOutlet weak var postImageView: UIImageView!
    
    var post: PostModel? {
        didSet {
            guard let _post = post else { return }
            updateCellView(post: _post)
            
        }
    }
    
    func updateCellView(post: PostModel) {
        guard let url = URL(string: post.imageUrl!) else { return }
        
        postImageView.sd_setImage(with: url) { (_, _, _, _) in
        }
    }
}
