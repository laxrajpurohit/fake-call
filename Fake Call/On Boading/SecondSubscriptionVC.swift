//
//  SecondSubscriptionVC.swift
//  Fake Call
//
//  Created by mac on 02/05/24.
//

import UIKit

class SecondSubscriptionVC: UIViewController {

    @IBOutlet weak var btn_Cancle: UIButton!
    @IBOutlet weak var tbl_Plans: UITableView!
    @IBOutlet weak var features_VIew: UIView!
    @IBOutlet weak var bg_View: UIView!
    @IBOutlet weak var btn_Continue: UIButton!
    var arrTIme = ["Monthly","Yearly","LifeTime"]
    var arrPrice = ["$1.99","$4.99","$9.99"]
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    

}
extension SecondSubscriptionVC {
    // set Up UI
    func setUpUI() {
        DispatchQueue.main.async { [self] in
            self.btn_Cancle.isHidden = true
            bg_View.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            bg_View.layer.cornerRadius = 10
            features_VIew.layer.cornerRadius = 16
            features_VIew.layer.masksToBounds = true
            btn_Continue.layer.cornerRadius = 12
            btn_Continue.layer.masksToBounds = true
            bg_View.layer.shadowColor = UIColor.black.cgColor
            bg_View.layer.shadowOpacity = 0.5
            bg_View.layer.shadowOffset = CGSize(width: 0, height: -3)
            bg_View.layer.shadowRadius = 6

        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.btn_Cancle.isHidden = false
        }
    }
}

// TableView Delegate Method
extension SecondSubscriptionVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTIme.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tbl_Plans_Cell", for: indexPath) as! tbl_Plans_Cell
        cell.selectionStyle = .none
        cell.bg_View.layer.cornerRadius = 12
        cell.bg_View.layer.masksToBounds = true
        cell.lbl_PlanTime.text = arrTIme[indexPath.row]
        cell.lbl_PlanPrice.text = arrPrice[indexPath.row]
        cell.lbl_FreeTrial.isHidden = true
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        cell.layer.backgroundColor = UIColor.clear.cgColor
        
        if indexPath.row == index {
            cell.bg_View.layer.borderWidth = 2
            cell.bg_View.layer.borderColor = #colorLiteral(red: 0.4079999924, green: 0.8080000281, blue: 0.4040000141, alpha: 1)
            let color = #colorLiteral(red: 0.4079999924, green: 0.8080000281, blue: 0.4040000141, alpha: 0.5)
            cell.bg_View.layer.backgroundColor = color.cgColor
            cell.img_RightTick.image = UIImage(named: "rightTick")

        } else {
            cell.bg_View.layer.borderWidth = 0
            cell.bg_View.layer.backgroundColor = UIColor.white.cgColor
            cell.img_RightTick.image = UIImage(named: "blankRing")
        }
        
        if indexPath.row == 1 {
            cell.topConstant_Plans.constant = 12
            cell.lbl_PlanTime.textColor = Utils().RGBColor(red: 104, green: 206, blue: 103)
            cell.lbl_PlanPrice.textColor = Utils().RGBColor(red: 104, green: 206, blue: 103)

            cell.lbl_FreeTrial.isHidden = false

        } else {
            cell.topConstant_Plans.constant = 22
            cell.lbl_FreeTrial.isHidden = true
            cell.lbl_PlanTime.textColor = .label
            cell.lbl_PlanPrice.textColor = .label

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        tbl_Plans.reloadData()
        
    }
        
}
