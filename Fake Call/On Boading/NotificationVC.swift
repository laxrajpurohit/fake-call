//
//  NotificationVC.swift
//  Fake Call
//
//  Created by mac on 30/04/24.
//

import UIKit

class NotificationVC: UIViewController {

    @IBOutlet weak var lbl_Text: UILabel!
    @IBOutlet weak var btn_Continue: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // tap Continue
    @IBAction func tap_Continue(_ sender: Any) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            self.makeRootVC(storyBoardName: "Main", vcName: "HomeVC")
//            self.gotoCustomVC()
        }
        
//        DispatchQueue.main.async {
//            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
//                return
//            }
//            UIApplication.shared.open(settingsURL)
//        }
    }
    
    
}


extension NotificationVC {
    
    // SetUP UI
    func setupUI() {
        btn_Continue.layer.cornerRadius = 12
        btn_Continue.layer.masksToBounds = true
        lbl_Text.textColor =  Utils().RGBColor(red: 52, green: 61, blue: 67)
        let attributedText = NSMutableAttributedString(string:"Stay on top of your everyday prank calls!🤩")
        let range1 = ("Stay on top of your everyday prank calls!🤩" as NSString).range(of: "everyday prank")
        attributedText.addAttribute(.foregroundColor, value: #colorLiteral(red: 0.4079999924, green: 0.8080000281, blue: 0.4040000141, alpha: 1), range: range1)
        lbl_Text.attributedText = attributedText
    }
    
    // Make Root Home VC
    func makeRootVC(storyBoardName : String, vcName : String) {
        DispatchQueue.main.async {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            let mainStoryBoard = UIStoryboard(name: storyBoardName, bundle: nil)
            let redViewController = mainStoryBoard.instantiateViewController(withIdentifier: vcName)
            window?.rootViewController = redViewController
            window?.makeKeyAndVisible()
        }
      }
    
    // goto CustomVC
    func gotoCustomVC() {

           if let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeVC") as? HomeVC {
               let navigationController = UINavigationController(rootViewController: tabBarController)
               if let navigator = self.navigationController {
                   navigator.pushViewController(navigationController, animated: false)
               } else {
                   print("error")
               }
           }
       }
    
  
}
