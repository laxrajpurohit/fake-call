//
//  FeedBackVC.swift
//  Fake Call
//
//  Created by mac on 30/04/24.
//

import UIKit

class FeedBackVC: UIViewController {

    @IBOutlet weak var btn_Continue: UIButton!
    
    @IBOutlet weak var txt_Review: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDataNotification(_:)), name: Notification.Name("GotoNotification"), object: nil)
        setupUI()
    }
    
    // tap Continue
    @IBAction func tap_Continue(_ sender: Any) {
        let navController = storyboard?.instantiateViewController(withIdentifier: "FirstPremiumSubscriptionVC") as! FirstPremiumSubscriptionVC
        navController.IsCompletionHandlerNav = { bool in

        navController.dismiss(animated:true) { [self] in
            let navgation = self.storyboard?.instantiateViewController(withIdentifier: "OfferVC") as! OfferVC
            navgation.modalPresentationStyle = .fullScreen
            present(navgation, animated: true)
        }
    }

        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    
    @objc func handleTextDataNotification(_ notification: Notification) {
        if let userInfo = notification.object {
            if userInfo as! Bool {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                    let navgation = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                    navigationController?.pushViewController(navgation, animated: true)
                }
            }
        }
    }
    
}

extension FeedBackVC {
    
    // SetUP UI
    func setupUI() {
        btn_Continue.layer.cornerRadius = 12
        btn_Continue.layer.masksToBounds = true
        
        let attributedText = NSMutableAttributedString(string:"Feeling grateful for all the laughs? Share the love with review!!🤩")
        let range1 = ("Feeling grateful for all the laughs? Share the love with review!!🤩" as NSString).range(of: "love with review")
        attributedText.addAttribute(.foregroundColor, value: #colorLiteral(red: 0.4079999924, green: 0.8080000281, blue: 0.4040000141, alpha: 1), range: range1)
        let range2 = ("Feeling grateful for all the laughs? Share the love with review!!🤩" as NSString).range(of: "Feeling grateful for all the laughs? Share the")
        attributedText.addAttribute(.foregroundColor, value: Utils().RGBColor(red: 52, green: 61, blue: 67), range: range2)
        txt_Review.attributedText = attributedText

    }
    
}
