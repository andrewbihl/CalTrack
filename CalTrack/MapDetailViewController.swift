//
//  MapDetailViewController.swift
//  CalTrack
//
//  Created by Faris Sbahi on 5/27/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import UIKit

class MapDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var stopLabel: UILabel!
    
    public var northDepartures = [Date]()
    public var southDepartures = [Date]()
    
    private var northStop : StopName
    private var southStop : StopName
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        northDepartures.append(200)
        southDepartures.append(300)
        
        // Do any additional setup after loading the view.
    }
    
    public func updateStops(northStop: StopName, southStop: StopName) {
        self.northStop = northStop
        self.southStop = southStop
        self.northDepartures = DataServer.sharedInstance.getDepartureTimesForStop(id: northStop)
        self.southDepartures = DataServer.sharedInstance.getDepartureTimesForStop(id: southStop)
    }

    // MARK: - Table View Functions

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell : NorthSouthDeparturesTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NorthSouthCell") as?NorthSouthDeparturesTableViewCell {
            cell.setDepartureTime(timeInMinutes: northDepartures[indexPath.row], north: true)
            cell.setDepartureTime(timeInMinutes: southDepartures[indexPath.row], north: false)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return northDepartures.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
