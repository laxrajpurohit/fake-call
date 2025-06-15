//
//  OfferVC.swift
//  Fake Call
//
//  Created by mac on 30/04/24.
//

import UIKit

class OfferVC: UIViewController {
    
    @IBOutlet weak var btn_Plans_View: UIView!
    @IBOutlet weak var btn_Cancle: UIButton!
    public var IsCompletionHandlerNavs: ((Bool) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // Tap Plans
    @IBAction func tap_Plans(_ sender: Any) {
        
        
    }
    
    // Tap Cancel
    @IBAction func tap_Cancel(_ sender: Any) {
   
        NotificationCenter.default.post(name: NSNotification.Name("GotoNotification"), object: true)
        self.dismiss(animated: true)
        
    }
    
}



extension OfferVC {
    
    // SetUP UI
    func setupUI() {
        self.btn_Cancle.isHidden = true
        btn_Plans_View.layer.cornerRadius = Utils().IpadorIphone(value: 12)
        btn_Plans_View.layer.masksToBounds = true
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.btn_Cancle.isHidden = false
        }
        
    }
}
