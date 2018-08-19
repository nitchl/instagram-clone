//
//  ReportingApi.swift
//  InstagramCloneApp
//
//  Created by toyokazu nichiga on 2018/08/17.
//  Copyright © 2018年 toyokazu nichiga. All rights reserved.
//

import Foundation
import FirebaseDatabase

class ReportingApi {
    var REF_REPORTING = Database.database().reference().child("reporting")
    
    static let shared: ReportingApi = ReportingApi()
    private init() {
    }
    
    // Lade Reporting Infos aus der Datenbank und erstelle ein Reporting Objekt
    func observeReporting(userUid: String, completion: @escaping (ReportingModel) -> Void) {
        REF_REPORTING.child(userUid).observe(.childAdded) { (snapshot) in
            guard let dic = snapshot.value as? [String: Any] else { return }
            let newReportingModel = ReportingModel(dictionary: dic)
            completion(newReportingModel)
        }
    }
}
