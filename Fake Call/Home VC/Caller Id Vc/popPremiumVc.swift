//
//  popPremiumVc.swift
//  Fake Call
//
//  Created by mac on 31/05/24.
//

import UIKit
import ProgressHUD
import GoogleMobileAds

class popPremiumVc: UIViewController {
    @IBOutlet weak var botToPop: UIView!
    @IBOutlet weak var bottem_Consient: NSLayoutConstraint!
    
    @IBOutlet weak var btn_Ads: UIButton!
    @IBOutlet weak var btn_Skip_Add: UIButton!
    
    private var rewardedAd: GADRewardedAd?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bottem_Consient.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func tap_Dismiss(_ sender: Any) {
                                                             
        bottem_Consient.constant = Utils().IpadorIphone(value: -200)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
                                                             
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                                 
            self.dismiss(animated: false)
        }
                                                     
    }
    
    // tap_Watch_Ad
    @IBAction func tap_Watch_Ad(_ sender: Any) {
        RewardVideoAds()
    }
    
    // tap_Skip_Ad
    @IBAction func tap_Skip_Ad(_ sender: Any) {
        let naviget = storyboard?.instantiateViewController(withIdentifier: "primiumVC") as! primiumVC
        naviget.modalPresentationStyle = .fullScreen
        present(naviget, animated: true)
    }
    
}


extension popPremiumVc {
    
    // Set Up UI
    func setUI() {
        DispatchQueue.main.async { [self] in
            botToPop.layer.cornerRadius = 30
            botToPop.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            btn_Ads.layer.cornerRadius = 10
            btn_Ads.layer.masksToBounds = true
            btn_Skip_Add.layer.cornerRadius = 10
            btn_Skip_Add.layer.masksToBounds = true
            btn_Ads.layer.borderColor = Utils().RGBColor(red: 104, green: 206, blue: 103).cgColor
            btn_Ads.layer.borderWidth = 1
         }
    }
    
    //Reward Video Ads
    func RewardVideoAds() {
        ProgressHUD.animate("Loading...", interaction: false)
        let REWARD = "ca-app-pub-3940256099942544/1712485313"

        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: REWARD, request: request) { [weak self](rewardedAd, error) in
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    ProgressHUD.dismiss()
                 
                }
                return
            }
            self?.rewardedAd = rewardedAd
            self?.rewardedAd?.fullScreenContentDelegate = self
            self?.presentRewardedVideo()
        }
    }

    func presentRewardedVideo() {
        guard let rewardedAd = rewardedAd else { return }
        rewardedAd.present(fromRootViewController: self) {
            _ = rewardedAd.adReward

            ProgressHUD.dismiss()
            Constants.USERDEFAULTS.set(true, forKey: "isReward")
        }
    }

}

extension popPremiumVc: GADFullScreenContentDelegate {
    
    /// Tells the delegate that an impression has been recorded for the ad.
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        print("0. impression recorded")
    }
    
    /// Tells the delegate that the ad will dismiss full screen content.
    func adWillDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("2. willDimiss ad")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("3. didDimiss ad")
        if Constants.USERDEFAULTS.value(forKey: "isReward") != nil {
            Constants.USERDEFAULTS.removeObject(forKey: "isReward")
        }
//        isCloseAd = true
//        navigationController?.popViewController(animated: true)
        
        
        self.dismiss(animated: false) {
            self.makeRootVC(storyBoardName: "Main", vcName: "HomeVC")
//            Utils().setupHome()
            
        }
       
         
        
//        if let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Homevc") as? HomeVC {
//                   if let navigator = self.navigationController {
//                       navigator.pushViewController(tabBarController, animated: false)
//                   }
//               }
        
        
        }
    
    /// Tells the delegate that a click has been recorded for the ad.
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        print("4. impression click detected")
    }
    
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("5. didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func makeRootVC(storyBoardName : String, vcName : String) {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {
            return
        }
        let mainStoryBoard = UIStoryboard(name: storyBoardName, bundle: nil)
        let redViewController = mainStoryBoard.instantiateViewController(withIdentifier: vcName)
        window.rootViewController = redViewController
        window.makeKeyAndVisible()
        let options: UIView.AnimationOptions = .transitionCrossDissolve
        UIView.transition(with: window, duration: 0.3, options: options, animations: {}, completion:
                            { completed in
            // maybe do something on completion here
        })
        
    }
}
