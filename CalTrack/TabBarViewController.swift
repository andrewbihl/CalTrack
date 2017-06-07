//
//  TabBarViewController.swift
//  CalTrack
//
//  Created by Faris Sbahi on 5/27/17.
//  Copyright © 2017 Andrew Bihl. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds

class TabBarViewController: UITabBarController, GADBannerViewDelegate {
    
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        DispatchQueue.main.async {
            self.bannerView = GADBannerView(adSize: kGADAdSizeFullBanner)
            self.view.addSubview(self.bannerView)
            self.bannerView.adUnitID = "ca-app-pub-3104334766866306/4572484271"// "ca-app-pub-3940256099942544/2934735716"
            self.bannerView.rootViewController = self
            self.bannerView.delegate = self
            self.bannerView.load(GADRequest())
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("banner received ad")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }

}
