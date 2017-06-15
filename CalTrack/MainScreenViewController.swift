//
//  MainScreenViewController.swift
//  CalTrack
//
//  Created by Andrew Bihl on 5/28/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MainScreenViewController: UIViewController, MapDetailAnimationManager, GADBannerViewDelegate {
    @IBOutlet var detailViewHeightConstraint: NSLayoutConstraint!
    
    private let DETAIL_VIEW_HEIGHT : CGFloat = 100.0
    
    @IBOutlet var routeButton: UIButton!
    @IBOutlet var mapContainerView: UIView!

    @IBOutlet var detailContainerView: UIView!
    
    var mapVC : MapViewController?
    var mapDetailVC : MapDetailViewController?
    
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.detailViewHeightConstraint.constant = DETAIL_VIEW_HEIGHT
        for vc in self.childViewControllers {
            if let detailVC = vc as? MapDetailViewController {
                self.mapDetailVC = detailVC
            } else if let mapVC = vc as? MapViewController {
                self.mapVC = mapVC
            }
        }
        
//        self.configureAd()
    }
    
    func moveAdToBottom() {
        bannerView.frame.origin.y = self.view.frame.height - bannerView.frame.height
    }
    
    func configureAd() {
        DispatchQueue.main.async {
            self.bannerView = GADBannerView(adSize: kGADAdSizeFullBanner)
            self.view.addSubview(self.bannerView)
            self.bannerView.adUnitID = "ca-app-pub-3104334766866306/4572484271"// "ca-app-pub-3940256099942544/2934735716"
            self.bannerView.rootViewController = self
            self.bannerView.delegate = self
            let request = GADRequest()
            #if DEBUG
                request.testDevices = [ kGADSimulatorID, "7a469c1981e8bca25f9c3f11270f66ec" ] // in debug mode set your device as a test device so AdMob doesn't suspend our account (each dev needs to add their device ID)
            #endif
            self.bannerView.load(request)
        }
    }

    func userSwipedUp(vc: MapDetailViewController) -> Bool {
        if !vc.isExpanded {
            self.animateDetailViewController(expand: true)
            return true
        }
        return false
    }
    
    func userSwipedDown(vc: MapDetailViewController) -> Bool {
        if vc.isExpanded {
            self.animateDetailViewController(expand: false)
            return true
        }
        return false
    }
    
    @IBAction func userPressedRouteButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let vc = self.mapDetailVC {
            vc.toggleRouteMode()
        }
    }
    
    
    public func animateDetailViewController(expand: Bool) {
        let height : CGFloat
        if expand {
            height = 0.4*self.view.frame.size.height
        } else {
            height = DETAIL_VIEW_HEIGHT
        }
        self.detailViewHeightConstraint.constant = height
        UIView.animate(withDuration: 0.25, animations: {
            self.mapVC?.setPadding(with: height)
            self.view.layoutIfNeeded()
            self.detailContainerView.layoutIfNeeded()
            self.mapContainerView.layoutIfNeeded()
        }) { (finished) in
            
        }
//        UIView.animate(withDuration: 0.25, animations: { 
//            self.view.layoutIfNeeded()
//        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - GADBannerViewDelegate
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("banner received ad")
        self.moveAdToBottom()
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }

}
