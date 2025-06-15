//
//  AdMob.swift
//  Phone Tracker
//
//  Created by Ishwar Hingu on 19/07/22.
//

import Foundation
import GoogleMobileAds

class AdMob: NSObject, GADFullScreenContentDelegate {

    static var sharedData_: AdMob? = nil

    var interstitial: GADInterstitialAd?
    var adUnitID = ""
    var isComp = false
    
    class func sharedInstance() -> AdMob? {
        let lockQueue = DispatchQueue(label: "self")
        lockQueue.sync {if sharedData_ == nil {sharedData_ = AdMob()}}
        return sharedData_
    }

    override init() {
        super.init()
    }
    
    func createAndLoadInterstitial(intID: String) -> GADInterstitialAd? {
        if Constants.USERDEFAULTS.value(forKey: "isShowAds") == nil && !intID.isEmpty{
            adUnitID = intID
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID:intID,request: request,
                completionHandler: { [self] ad, error in
                     if error != nil {
                         if let intID = Constants.USERDEFAULTS.string(forKey: "INTERTIALS2"), !intID.isEmpty{
                             _ = self.createAndLoadInterstitial(intID: intID)
                         }
                        return
                     }
                     self.interstitial = ad
                     self.interstitial?.fullScreenContentDelegate = self
                })
            return interstitial
        }
        return nil
    }
    
    func loadInste() {
//        if Constants.USERDEFAULTS.bool(forKey: "isShowAds"){
//            return
//        }
//        isComp = false
//        let adsCount = Constants.USERDEFAULTS.integer(forKey: "adsCount") + 1
//        Constants.USERDEFAULTS.set(adsCount, forKey: "adsCount")
//        let Inter_In_Click = Constants.USERDEFAULTS.integer(forKey: "ads_counter")
//        if  interstitial != nil && adsCount >= Inter_In_Click {
//            self.completionHandler = nil
            interstitial = createAndLoadInterstitial(intID: "ca-app-pub-3940256099942544/4411468910")
            if var topController = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController  {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
             interstitial?.present(fromRootViewController: topController)
            }
//        }
    }
        
    func loadInste(completionHandler: @escaping () -> Void) {
//        if Constants.USERDEFAULTS.bool(forKey: "isShowAds"){
//            return
//        }
//
//        isComp = true
//        let adsCount = Constants.USERDEFAULTS.integer(forKey: "adsCount") + 1
//        Constants.USERDEFAULTS.set(adsCount, forKey: "adsCount")
//        let Inter_In_Click = Constants.USERDEFAULTS.integer(forKey: "ads_counter")
//        if  interstitial != nil && adsCount >= Inter_In_Click {
            interstitial = createAndLoadInterstitial(intID: "ca-app-pub-3940256099942544/4411468910")
            if var topController = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                interstitial?.present(fromRootViewController: topController)
                self.completionHandler = completionHandler
            }
//        }else{
//            self.completionHandler = completionHandler
//            self.completionHandler?()
//        }
    }

    private var completionHandler: (() -> Void)?

    /// Tells the delegate that an impression has been recorded for the ad.
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("0. impression recorded")
    }

    /// Tells the delegate that the ad presented full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("1. ad presented")
    }

    /// Tells the delegate that the ad will dismiss full screen content.
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("2. willDimiss ad")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("3. didDimiss ad")
        Constants.USERDEFAULTS.removeObject(forKey: "adsCount")
        if let intID = Constants.USERDEFAULTS.string(forKey: "INTERTIALS") {
            interstitial = createAndLoadInterstitial(intID: intID)
        }
        if isComp{
            self.completionHandler?()
        }
    }
    
    /// Tells the delegate that a click has been recorded for the ad.
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("4. impression click detected")
    }
    
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("5. didFailToReceiveAdWithError: \(error.localizedDescription)")
        interstitial = nil
        if let intID = Constants.USERDEFAULTS.string(forKey: "INTERTIALS") {
            interstitial = createAndLoadInterstitial(intID: intID)
        }
    }
}
