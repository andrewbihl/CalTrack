//
//  ScheduleViewController.swift
//  CalTrack
//
//  Created by Andrew Bihl on 5/27/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import UIKit

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var scheduleTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scheduleTableView.delegate = self
        self.scheduleTableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    // MARK: - Table View Functions
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell")
        return cell!
    }
    
    // MARK: -

}
