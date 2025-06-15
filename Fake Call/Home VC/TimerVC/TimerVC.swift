//
//  TimerVC.swift
//  Fake Call
//
//  Created by mac on 27/04/24.
//

import UIKit

class TimerVC: UIViewController {

    @IBOutlet weak var tbl_Timer: UITableView!
    
    @IBOutlet weak var lbl_Info: UILabel!
    var arrTimer = ["Call Now","3 Seconds Later","5 Seconds Later","10 Seconds Later","20 Seconds Later","30 Seconds Later","40 Seconds Later","50 Seconds Later","1 Minute Later","2 Minute Later","3 Minute Later"]
    var arrTime:[Int] = [0,3,5,10,20,30,40,50,60,120,180]
    var tapIndex = 1
    var selectionChanged = false
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    
    override func viewWillDisappear(_ animated: Bool) {
          if selectionChanged, Constants.USERDEFAULTS.value(forKey: "Premium") == nil {
            AdMob.sharedInstance()?.loadInste()
        }
    }
}

extension TimerVC {
    
    // set Up Ui
    func setUpUI() {
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Timer"
    }
    
}

//  TableView Delegate Methods
extension TimerVC:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTimer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tbl_Timer_Cell", for: indexPath) as! tbl_Timer_Cell
        cell.lbl_timer.text = arrTimer[indexPath.row]
        cell.selectionStyle = .none

        
        let indext =  Constants.USERDEFAULTS.integer(forKey: "SaveTimerIndex")
        
        let isPremiumUser = Constants.USERDEFAULTS.value(forKey: "Premium") != nil
        let isSelectedRow = indext == indexPath.row

        if !isPremiumUser && indexPath.row > 1 {
            cell.img_RightTick.image = UIImage(named: "Lock")
        } else {
            if isSelectedRow {
                cell.img_RightTick.image = UIImage(named: "right Tick")
                
                if indexPath.row == 0 {
                    lbl_Info.text = "Don't lock the screen and don't return to the desktop."
                } else {
                    lbl_Info.text = "The phone will be called \(arrTimer[indexPath.row]) Later, don't lock the screen and don't return to the desktop."
                }
                
            } else {
                cell.img_RightTick.image = UIImage(named: "")
            }
        }
         return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Utils().IpadorIphone(value: 50)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        if indexPath.row == 0 || indexPath.row == 1 {
            tapIndex = indexPath.row
            
            Constants.USERDEFAULTS.set(tapIndex, forKey: "SaveTimerIndex")
            Constants.USERDEFAULTS.set(arrTime[indexPath.row], forKey: "SaveTimer")

        } else {
            if Constants.USERDEFAULTS.value(forKey: "Premium") == nil {
                let primiumVCvc = self.storyboard?.instantiateViewController(withIdentifier: "primiumVC") as! primiumVC
                primiumVCvc.modalPresentationStyle = .fullScreen
                present(primiumVCvc, animated: true)

            } else {
                tapIndex = indexPath.row
                
                Constants.USERDEFAULTS.set(tapIndex, forKey: "SaveTimerIndex")
                Constants.USERDEFAULTS.set(arrTime[indexPath.row], forKey: "SaveTimer")

            }

        }
        selectionChanged = true
        tbl_Timer.reloadData()
    }
        
}

// tbl_Timer Cell
class tbl_Timer_Cell:UITableViewCell {
    
    @IBOutlet weak var lbl_timer: UILabel!
    @IBOutlet weak var img_RightTick: UIImageView!
}
