//
//  MapDetailViewController.swift
//  CalTrack
//
//  Created by Faris Sbahi on 5/27/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import UIKit

protocol InformingDelegate {
    func valueChangedFromLoc() -> Stop?
    func valueChangedFromTap(with stop: Stop) -> Stop?
}

protocol MapDetailAnimationManager {
    
    /// Respond to the user swiping on the view
    ///
    /// - Returns: Return true if the view was moved/animated as a result of the swipe.
    func userSwipedUp(vc: MapDetailViewController)->Bool;
    
    /// Respond to the user swiping on the view
    ///
    /// - Returns: Return true if the view was moved/animated as a result of the swipe.
    func userSwipedDown(vc: MapDetailViewController)->Bool;
}

class MapDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var delegate: InformingDelegate?
    
    // Parent view exists just for separation in the Interface Builder
    @IBOutlet var tableParentView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var stopLabel: UILabel!
    
    @IBOutlet var northboundLabel: UILabel!
    @IBOutlet var southboundLabel: UILabel!
    
    var swipeUp : UIGestureRecognizer?
    var swipeDown : UIGestureRecognizer?
    var tapBanner : UIGestureRecognizer?
    
    private let CELL_HEIGHT : CGFloat = 58
    
    public var northDepartures = [Int]()
    public var southDepartures = [Int]()
    
    private var updateTimer : Timer?
    
    var sharedInstance = DataServer.sharedInstance
    
    private var northStop : Stop {
        didSet {
            if (self.isViewLoaded && (self.view.window != nil)) {
            self.stopLabel.text = northStop.stopName.replacingOccurrences(of: "Northbound", with: "")
            }
        }
    }
    private var southStop : Stop
    
    private let BORDER_WIDTH : CGFloat = 1.5
    private let BORDER_COLOR : CGColor = appColor1.cgColor
    
    public var isExpanded = false {
        didSet {
            self.tableView.reloadData()
            self.tableView.isScrollEnabled = isExpanded
            self.swipeDown?.isEnabled = isExpanded
            self.swipeUp?.isEnabled = !isExpanded
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        northStop = defaultNorthStop
        southStop = defaultSouthStop
        super.init(coder: aDecoder)
    }
    
    init() {
        northStop = defaultNorthStop
        southStop = defaultSouthStop
        super.init(nibName: nil, bundle: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableParentView.addSubview(tableView)
        
//        tableView.frame = tableParentView.frame
        
        configureGestureRecognizers()
        
        //addObserver(self, forKeyPath: #keyPath(self.sharedInstance.defaultNorthStop), options: [.old, .new], context: nil)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.frame = self.tableParentView.bounds
        self.view.backgroundColor = appColor2
        self.tableView.backgroundColor = appColor2
        self.view.layer.borderWidth = 3
        self.view.layer.borderColor = BORDER_COLOR
        self.northboundLabel.layer.borderWidth = BORDER_WIDTH
        self.southboundLabel.layer.borderWidth = BORDER_WIDTH
        self.northboundLabel.layer.borderColor = BORDER_COLOR
        self.southboundLabel.layer.borderColor = BORDER_COLOR
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        retrieveDepartureTimes()
        beginUpdateTimer(intervalInSeconds: 30)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.updateTimer?.invalidate()
    }
    
    private func configureGestureRecognizers() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.userSwipedUp))
        swipeUp.direction = .up
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.userSwipedDown))
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.userTappedBanner))
        swipeDown.direction = .down
        //        swipeUp.delegate = self
        //        swipeDown.delegate = self
        //        self.view.addGestureRecognizer(tap)
        self.stopLabel.addGestureRecognizer(tap)
        self.view.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeDown)
        self.tapBanner = tap
        self.swipeDown = swipeDown
        self.swipeUp = swipeUp
        self.swipeDown?.isEnabled = false
    }
    
    private func retrieveDepartureTimes(){
        self.northDepartures = self.sharedInstance.getDepartureTimesForStop(stop: northStop)
        self.southDepartures = self.sharedInstance.getDepartureTimesForStop(stop: southStop)
    }
    
    public func updateStops(northStop: Stop, southStop: Stop) {
        self.northStop = northStop
        self.southStop = southStop
        retrieveDepartureTimes()
        if (self.isViewLoaded && (self.view.window != nil)) {
        self.stopLabel.text = northStop.stopName.replacingOccurrences(of: "Northbound", with: "")
        }
    }
    
    // MARK: - User Actions

    @IBAction func userTappedBanner() {
        self.userSwipedUp()
    }
    
    @IBAction func userSwipedUp() {
        if let parentVC = self.parent as? MapDetailAnimationManager {
            let changedFrame = parentVC.userSwipedUp(vc: self)
            if changedFrame {
                isExpanded = !isExpanded
            }
        }
    }

    @IBAction func userSwipedDown() {
        if let parentVC = self.parent as? MapDetailAnimationManager {
            let changedFrame = parentVC.userSwipedDown(vc: self)
            if changedFrame {
                isExpanded = !isExpanded
                self.tableView.setContentOffset(CGPoint.zero, animated: false)
            }
        }
    }
    
    
    // MARK: - Table View Functions
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 && max(self.northDepartures.count, self.southDepartures.count) == 0 {
            if let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "NoTimesCell") {
                cell.contentView.layer.borderColor = BORDER_COLOR
                cell.contentView.layer.borderWidth = BORDER_WIDTH
                return cell
            }
        }
        
        if let cell : NorthSouthDeparturesTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NorthSouthCell") as? NorthSouthDeparturesTableViewCell {
            
            if northDepartures.count > indexPath.row {
                let departureTime = northDepartures[indexPath.row]
                if departureTime.timeRemaining.hours < 0 {
                    self.retrieveDepartureTimes()
                    tableView.reloadData()
                }
                cell.setDepartureTime(time: departureTime, north: true)
            }
            if southDepartures.count > indexPath.row {
                let departureTime = southDepartures[indexPath.row]
                if departureTime.timeRemaining.hours < 0 {
                    self.retrieveDepartureTimes()
                    tableView.reloadData()
                }
                cell.setDepartureTime(time: departureTime, north: false)
            }
            cell.contentView.layer.borderColor = BORDER_COLOR
            cell.contentView.layer.borderWidth = BORDER_WIDTH
            cell.contentView.backgroundColor = appColor1 //Same as BORDER_COLOR
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (!isExpanded) {
            return tableView.frame.height
        }
        return CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(northDepartures.count, southDepartures.count, 1)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func beginUpdateTimer(intervalInSeconds: Int){
        Timer.scheduledTimer(withTimeInterval: TimeInterval(intervalInSeconds), repeats: true) { (timer) in
            print("Reload table")
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Key-Value Observing
    /*
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath() {
            //
        }
    } */
    
    func closestStopChanged() {
        if let value = self.delegate?.valueChangedFromLoc() {
        print("closest stop changed", value)
            let north = value.stopIsNorth ? value : value.stopPartner
            let south = value.stopIsNorth ? value.stopPartner : value
            if north != nil && south != nil {
                self.updateStops(northStop: north!, southStop: south!)
                self.tableView.reloadData()
            }
            
        } else{
            print("new location, same nearest stop")
        }
    }
    
    func stopTappedChanged(with stop: Stop) {
        if let value = self.delegate?.valueChangedFromTap(with: stop) {
            print("closest stop changed", value)
            let north = value.stopIsNorth ? value : value.stopPartner
            let south = value.stopIsNorth ? value.stopPartner : value
            if north != nil && south != nil {
                self.updateStops(northStop: north!, southStop: south!)
                self.tableView.reloadData()
            }
        } else{
            print("new location, same nearest stop")
        }
    }
    
    // MARK: - Actions
    
    @IBAction func reportDelayTapped(_ sender: UIButton) {
        
        // TODO: - Let user report delay for north vs south with pop-up
        
        let reportStop = self.northStop
        
        DataServer.sharedInstance.addPotentialDelay(to: reportStop)
    }
    
    
}
