//
//  ActivityViewController.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/07/28.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController {
    
    // MARK: - Outlet
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - var / let
    var reports = [ReportingModel]()
    var users = [UserModel]()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Activity"
        
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.tableFooterView = UIView(frame: .zero)
        
        loadReports()
    }
    
    
    // MARK: - load reports
    func loadReports() {
        guard let currentUserUid = UserApi.shared.CURRENT_USER_UID else { return }
        ReportingApi.shared.observeReporting(userUid: currentUserUid) { (reportingObject) in
            guard let userUid = reportingObject.fromUserUid else { return }
            self.fetchUser(uid: userUid, completed: {
                self.reports.insert(reportingObject, at: 0)
                self.tableView.reloadData()
                self.createBadgeCount()
            })
        }
    }
    
    // MARK: - Anzahl der Reports
    func createBadgeCount() {
        // Exclamation  -> question mark へ変更
        if let tabItems = self.tabBarController?.tabBar.items as NSArray? {
            let tabItem = tabItems[3] as! UITabBarItem
            tabItem.badgeColor = UIColor.blue
            tabItem.badgeValue = "\(reports.count)"
            //tabItem.badgeValue = "10"
        }
    }
    
    // MARK: - Fetch Users
    func fetchUser(uid: String, completed: @escaping () -> Void) {
        UserApi.shared.observeUser(uid: uid) { (user) in
            self.users.insert(user, at: 0)
            completed()
        }
    }
}

extension ActivityViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityTableViewCell", for: indexPath) as! ActivityTableViewCell
        
        cell.reportObject = reports[indexPath.row]
        cell.user = users[indexPath.row]
        
        return cell
    }
}
