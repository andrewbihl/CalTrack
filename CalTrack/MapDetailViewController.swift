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
    
    private var northStop : StopName?
    private var southStop : StopName?
    
    private var updateTimer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
//        northDepartures.append(200)
//        southDepartures.append(300)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        beginUpdateTimer(intervalInSeconds: 60)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.updateTimer?.invalidate()
    }
    
    public func updateStops(northStop: StopName, southStop: StopName) {
        self.northStop = northStop
        self.southStop = southStop
        self.northDepartures = DataServer.sharedInstance.getDepartureTimesForStop(id: northStop.rawValue)
        self.southDepartures = DataServer.sharedInstance.getDepartureTimesForStop(id: southStop.rawValue)
        self.stopLabel.text = self.northStop?.stopName.replacingOccurrences(of: "Northbound", with: "")
    }

    // MARK: - Table View Functions

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell : NorthSouthDeparturesTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NorthSouthCell") as?NorthSouthDeparturesTableViewCell {
            cell.setDepartureTime(time: northDepartures[indexPath.row], north: true)
            cell.setDepartureTime(time: southDepartures[indexPath.row], north: false)
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
    
    func beginUpdateTimer(intervalInSeconds: Int){
        updateTimer = Timer(timeInterval: TimeInterval(intervalInSeconds), repeats: true, block: { (timer) in
            self.tableView.reloadData()
        });
    }
    
}
