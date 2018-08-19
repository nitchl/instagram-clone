//
//  PeopleViewController.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/08/06.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import UIKit

class PeopleViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - var / let
    var users = [UserModel]()
    var userUid = ""
    
    // MARK: - View Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = 80
        
        loadUser()
        print("load user")
    }

    // MARK: - load user
    func loadUser() {
        UserApi.shared.observeUser { (user) in
            self.isFollowing(userUid: user.uid!, completed: { (value) in
                if user.uid != UserApi.shared.CURRENT_USER_UID! {
                    user.isFollowing = value
                    self.users.append(user)
//                    print(user.username)
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func isFollowing(userUid: String, completed: @escaping (Bool) -> Void ) {
        FollowApi.shared.isFollowing(withUser: userUid, completed: completed)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Segue")
        if segue.identifier == "ShowUserInfoSegue" {
            let showUserInfoVC = segue.destination as! ShowUserInfoViewController
            showUserInfoVC.userUid = self.userUid
        }
    }
}

// PeopleCellDelegateの定義
extension PeopleViewController: PeopleCellDelegate {
    
    func didTappedShowUserInfo(userUid: String) {
        self.userUid = userUid
        print("move") //for checking
        performSegue(withIdentifier: "ShowUserInfoSegue", sender: self)
    }
}

// MARK: - TableView Datasource
extension PeopleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(users.count)
        return users.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PeopleTableViewCell
        
        cell.user = users[indexPath.row]
        // 最終的な原因！！
        cell.delegate = self
        
        return cell
    }

}
