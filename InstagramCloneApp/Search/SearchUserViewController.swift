//
//  SearchUserViewController.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/08/11.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import UIKit

class SearchUserViewController: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - var / let
    let searchbar = UISearchBar()
    var users = [UserModel]()
    var userUid = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = 80
        
        setupSearchBar()
        
        searchUser()
    }
    
    //MARK: - Searchbar
    func setupSearchBar() {
        searchbar.searchBarStyle = .minimal
        searchbar.placeholder = "Suche User"
        searchbar.frame.size.width = view.frame.size.width - 60
        
        searchbar.delegate = self
        
        let searchItem = UIBarButtonItem(customView: searchbar)
        self.navigationItem.rightBarButtonItem = searchItem
    }
    
    func searchUser() {
        guard let searchText = searchbar.text?.lowercased() else { return }
        
        self.users.removeAll()
        self.tableView.reloadData()
        
        UserApi.shared.queryUser(withText: searchText) { (user) in
            self.isFollowing(userUid: user.uid!, completion: { (value) in
                user.isFollowing = value
                if user.uid! != UserApi.shared.CURRENT_USER_UID! {
                    self.users.append(user)
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func isFollowing(userUid: String, completion: @escaping(Bool) -> Void) {
        FollowApi.shared.isFollowing(withUser: userUid, completed: completion)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchToShowUserInfoSegue" {
            let showUserInfoVC = segue.destination as! ShowUserInfoViewController
            showUserInfoVC.userUid = userUid
        }
    }
}

// MARK: TableView Datasoruce
extension SearchUserViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PeopleTableViewCell
        
        cell.user = users[indexPath.row]
        cell.delegate = self
        
        return cell
    }
}

// MARK: - Searchbar Delegate
extension SearchUserViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchUser()
        self.searchbar.endEditing(true)
    }
}


// MARK: - PeopleCellDelgate
extension SearchUserViewController: PeopleCellDelegate {
    
    func didTappedShowUserInfo(userUid: String) {
        self.userUid = userUid
        performSegue(withIdentifier: "SearchToShowUserInfoSegue", sender: self)
    }
}















