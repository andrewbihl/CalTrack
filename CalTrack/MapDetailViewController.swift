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
    func addPadding(with height: CGFloat)
}

protocol MapDetailAnimationManager {
    
    /// Respond to the user swiping on the view
    ///
    /// - Returns: Return true if the view was moved/animated as a result of the swipe.
    func userSwipedUp(vc: MapDetailViewController)->Bool
    
    /// Respond to the user swiping on the view
    ///
    /// - Returns: Return true if the view was moved/animated as a result of the swipe.
    func userSwipedDown(vc: MapDetailViewController)->Bool
}

class MapDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var delegate: InformingDelegate?
    
    // Parent view exists just for separation in the Interface Builder
    @IBOutlet var tableParentView: UIView!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var stopsStackView: UIStackView!
    @IBOutlet var toLabel: UILabel!
    @IBOutlet var originStopButton: UIButton!
    @IBOutlet var destinationStopButton: UIButton!
    
    @IBOutlet var northboundLabel: UILabel!
    @IBOutlet var southboundLabel: UILabel!
    
    private var inRouteMode = false
    
    var swipeUp : UIGestureRecognizer?
    var swipeDown : UIGestureRecognizer?
    var tapBanner : UIGestureRecognizer?
    
    let GENERAL_BACKGROUND_COLOR = #colorLiteral(red: 0.7960784314, green: 0.7960784314, blue: 0.7960784314, alpha: 0.9505038681)
    let EVEN_ROW_BACKGROUND_COLOR = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2544661034)
    let LINE_COLOR = UIColor.darkGray
    let LINE_THICKNESS : CGFloat = 0.5
    
    private let CELL_HEIGHT : CGFloat = 50
    
    public var northDepartures = [Int]()
    public var southDepartures = [Int]()
    
    private var updateTimer : Timer?
    
    var sharedInstance = DataServer.sharedInstance
    
    private var northStop : Stop {
        didSet {
            if (self.isViewLoaded && (self.view.window != nil)) && !inRouteMode {
                self.originStopButton.setTitle(northStop.stopName.replacingOccurrences(of: "Northbound", with: ""), for: .normal)
            }
        }
    }
    private var southStop : Stop
    
    private var fromStop: Stop{ // when the user's current location changes we want to change the default from stop
        didSet {
            if (self.isViewLoaded && (self.view.window != nil)) && inRouteMode {
                self.originStopButton.setTitle(fromStop.stopName.replacingOccurrences(of: "Northbound", with: ""), for: .normal)
            }
        }
    }
    private var destinationStop : Stop { // we want what the user taps to change the destination stop by default
        didSet {
            if (self.isViewLoaded && (self.view.window != nil)) && inRouteMode {
                self.destinationStopButton.setTitle(destinationStop.stopName.replacingOccurrences(of: "Northbound", with: ""), for: .normal)
            }
        }
    }
    
    private var tripTimes : [(departureTime: Int, arrivalTime: Int)]?
    
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
        fromStop = defaultNorthStop
        
        southStop = defaultSouthStop
        destinationStop = defaultSouthStop
        
        super.init(coder: aDecoder)
    }
    
    init() {
        northStop = defaultNorthStop
        fromStop = defaultNorthStop
        
        southStop = defaultSouthStop
        destinationStop = defaultSouthStop
        super.init(nibName: nil, bundle: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        tableParentView.addSubview(tableView)
        self.originStopButton.isUserInteractionEnabled = false
        self.destinationStopButton.isUserInteractionEnabled = false
        
//        tableView.frame = tableParentView.frame
        
        configureGestureRecognizers()
        
        //addObserver(self, forKeyPath: #keyPath(self.sharedInstance.defaultNorthStop), options: [.old, .new], context: nil)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.frame = self.tableParentView.bounds
        tableView.backgroundColor = GENERAL_BACKGROUND_COLOR
        self.drawLineInView(view: self.view, startingPoint: CGPoint(x:0, y:0), length: self.view.frame.width, horizontal: true, thickness: LINE_THICKNESS, color: LINE_COLOR)
        let midHeaderOrigin = CGPoint(x: 0.0, y: 0.0 + self.stopsStackView.frame.height - 2)
        self.drawLineInView(view: self.view, startingPoint: midHeaderOrigin, length: self.view.frame.width, horizontal: true, thickness: LINE_THICKNESS, color: LINE_COLOR)
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
        self.stopsStackView.addGestureRecognizer(tap)
        self.view.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeDown)
        self.tapBanner = tap
        self.swipeDown = swipeDown
        self.swipeUp = swipeUp
        self.swipeDown?.isEnabled = false
    }
    
    public func updateStops(northStop: Stop, southStop: Stop) {
        self.northStop = northStop
        self.southStop = southStop
        retrieveDepartureTimes()

    }
    
    public func updateFromStop(from stop: Stop) {
        self.fromStop = stop
        retrieveTripTimes()
    }
    
    public func updateDestinationStop(to stop: Stop) {
        self.destinationStop = stop
        retrieveTripTimes()
    }
    
    private func retrieveDepartureTimes(){
        self.northDepartures = self.sharedInstance.getDepartureTimesForStop(stop: northStop)
        self.southDepartures = self.sharedInstance.getDepartureTimesForStop(stop: southStop)
    }
    
    private func retrieveTripTimes(){
        // TODO: Get the trip times t
        self.tripTimes = self.sharedInstance.getTripTimes(fromStop: self.fromStop, toStop: self.destinationStop) // wouldn't actually matter if we fed in north or south as from
    
    }
    
    public func toggleRouteMode(){
        if (!inRouteMode) {
            self.stopsStackView.addArrangedSubview(toLabel)
            self.stopsStackView.addArrangedSubview(destinationStopButton)
            self.northboundLabel.text = "Depart time"
            self.southboundLabel.text = "Arrival time"
            self.updateFromStop(from: self.fromStop)
            self.updateDestinationStop(to: self.destinationStop)
        }
        else {
            self.toLabel.removeFromSuperview()
            self.destinationStopButton.removeFromSuperview()
//            self.stopsStackView.removeArrangedSubview(toLabel)
//            self.stopsStackView.removeArrangedSubview(destinationStopButton)
            self.northboundLabel.text = "Northbound"
            self.southboundLabel.text = "Southbound"
        }
        inRouteMode = !inRouteMode
        tableView.reloadData()
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
    
    
    @IBAction func userTappedOriginStop(_ sender: Any) {
        
    }
    
    @IBAction func userTappedDestinationStop(_ sender: Any) {
        
    }
    
    
    // MARK: - Table View Functions
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.cellTypeForRow(index: indexPath.row)
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = EVEN_ROW_BACKGROUND_COLOR
        } else {
            cell.backgroundColor = UIColor.clear
        }
        return cell
    }
    
    private func cellTypeForRow(index: Int)->UITableViewCell {
        if index == 0 {
            let noRows = (inRouteMode && (tripTimes == nil || tripTimes!.count <= 0)) ||
                (!inRouteMode && max(self.northDepartures.count, self.southDepartures.count)<=0)
            if noRows {
                if let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "NoTimesCell") {
                    return cell
                }
            }
        }
        
        if inRouteMode {
            if let times = self.tripTimes?[index], let cell : TripTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TripCell") as? TripTableViewCell {
                if times.arrivalTime.timeRemaining.hours < 0 || times.departureTime.timeRemaining.hours < 0 {
                    retrieveTripTimes()
                    tableView.reloadData()
                }
                cell.setTripTimes(departure: times.departureTime, arrival: times.arrivalTime, origin: self.fromStop, destination: self.destinationStop)
                return cell
            }
        }
        else if let cell : NorthSouthDeparturesTableViewCell = tableView.dequeueReusableCell(withIdentifier: "NorthSouthCell") as? NorthSouthDeparturesTableViewCell {
            
            if northDepartures.count > index {
                let departureTime = northDepartures[index]
                if departureTime.timeRemaining.hours < 0 {
                    self.retrieveDepartureTimes()
                    tableView.reloadData()
                }
                cell.setDepartureTime(time: departureTime, north: true)
            }
            if southDepartures.count > index {
                let departureTime = southDepartures[index]
                if departureTime.timeRemaining.hours < 0 {
                    self.retrieveDepartureTimes()
                    tableView.reloadData()
                }
                cell.setDepartureTime(time: departureTime, north: false)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (!isExpanded) {
            return tableView.frame.height
        }
        return CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return inRouteMode ? self.tripTimes?.count ?? 0 : max(northDepartures.count, southDepartures.count, 1)
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
    
    
    // MARK: - Delegation
    
    func getHeight() {
        self.delegate?.addPadding(with: self.view.frame.height)
    }
    
    func closestStopChanged() {
        if let value = self.delegate?.valueChangedFromLoc() {
        print("closest stop changed", value)
            
            let north = value.stopIsNorth ? value : value.stopPartner
            let south = value.stopIsNorth ? value.stopPartner : value
            if let north = north, let south = south {
                self.updateFromStop(from: north)
                self.updateStops(northStop: north, southStop: south)
                self.tableView.reloadData()
            }
            
        } else{
            print("new closest location, same nearest stop")
        }
    }
    
    func stopTappedChanged(with stop: Stop) {
        if let value = self.delegate?.valueChangedFromTap(with: stop) {
            print("tapped stop changed", value)
            
            let north = value.stopIsNorth ? value : value.stopPartner
            let south = value.stopIsNorth ? value.stopPartner : value
            if let north = north, let south = south {
                self.updateDestinationStop(to: north)
                self.updateStops(northStop: north, southStop: south)
                self.tableView.reloadData()
            }
        } else{
            print("new tapped location, same nearest stop")
        }
    }
    
    // MARK: - Actions
    
    @IBAction func reportDelayTapped(_ sender: UIButton) {
        
        // TODO: - Let user report delay for north vs south with pop-up
        
        let reportStop = self.northStop
        
        DataServer.sharedInstance.addPotentialDelay(to: reportStop)
    }
    
    private func drawLineInView(view: UIView, startingPoint: CGPoint, length: CGFloat, horizontal: Bool, thickness: CGFloat, color: UIColor) {
        let size: CGSize
        if horizontal {
            size = CGSize(width: length, height: thickness)
        } else {
            size = CGSize(width: thickness, height: length)
        }
        let line = CGRect(origin: startingPoint, size: size)
        let lineView = UIView(frame: line)
        lineView.backgroundColor = color
        view.addSubview(lineView)
    }
    
    
}
